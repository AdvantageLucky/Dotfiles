--!nonstrict
-- Background poller: checks every service of homelab.json, scrapes the server stats and
-- docker containers out of Glance, and reads the tailscale peers. Everything lands in the
-- plugin state as one JSON blob ("homelab"), which the widget, panel and launcher render.
-- `noctalia msg plugin sleepy/homelab:poller all refresh` forces a poll.

local config = noctalia.json.decode(noctalia.readFile("homelab.json") or "{}") or {}
local services = config.services or {}
local refreshMs = (config.refresh_seconds or 30) * 1000

local data = {
	name = config.name or "homelab",
	-- Glance runs in an alpine container, so its PLATFORM is not the host's
	os = config.os,
	glance = config.glance,
	services = {},
	server = nil,
	containers = {},
	peers = {},
	updated = 0,
}

local function publish()
	local up = 0
	for _, s in data.services do
		if s.up then
			up += 1
		end
	end
	data.up = up
	data.total = #services
	data.updated = os.time()
	noctalia.state.set("homelab", noctalia.json.encode(data))
end

-- @Services: any HTTP answer below 500 counts as up (redirects to a login page included).
-- "check": "tcp" services (lazymc, minecraft protocol) only need the port to accept a
-- connection. "container" names the docker container whose state Glance reports (lazymc
-- stops the minecraft server when nobody plays: "dormido").
local function result(i, svc, up, status, started)
	data.services[i] = {
		name = svc.name,
		url = svc.url,
		glyph = svc.glyph or "world",
		about = svc.about or "",
		check = svc.check or "http",
		container = svc.container,
		up = up,
		status = status,
		latency = math.floor(noctalia.nowMs() - started),
	}
	publish()
end

local function checkServices()
	for i, svc in services do
		local started = noctalia.nowMs()
		if svc.check == "tcp" then
			local host, port = svc.url:match("^tcp://([^:/]+):(%d+)")
			noctalia.runAsync({ "bash", "-c", `exec 3<>/dev/tcp/{host}/{port}` }, function(res)
				result(i, svc, res.exitCode == 0 and not res.timedOut, res.exitCode, started)
			end, 3000)
		else
			noctalia.http({ url = svc.url, allow_insecure_tls = true, follow_redirects = false }, function(res)
				result(i, svc, res.ok and res.status > 0 and res.status < 500, res.status, started)
			end)
		end
	end
end

-- @Glance: its server-stats and docker widgets only exist as HTML, so read them from the text
-- one widget of the page: from its `widget-type-<kind>` class up to the next widget
local function section(html, kind)
	local from = html:find(`widget-type-{kind}`, 1, true)
	if not from then
		return nil
	end
	local to = html:find('class="widget widget-type-', from, true)
	return html:sub(from, to and to - 1 or #html)
end

local function text(html)
	return (html:gsub("<[^>]+>", " "):gsub("&[%w#]+;", " "):gsub("%s+", " "))
end

local function parseServer(html)
	local from = html:find("server%-name")
	if not from then
		return nil
	end
	local chunk = html:sub(from, from + 12000)
	local t = text(chunk)
	return {
		host = t:match("^[^>]*>%s*(%S+)") or data.name,
		since = tonumber(chunk:match('data%-dynamic%-relative%-time="(%d+)"')),
		platform = t:match("PLATFORM (%S+)"),
		cpu = tonumber(t:match("CPU (%d+) %%")),
		temp = tonumber(t:match("TEMP C (%d+)")),
		ram = tonumber(t:match("RAM (%d+) %%")),
		ramUsed = t:match("RAM ([%d.]+ %a+) /"),
		ramTotal = t:match("RAM [%d.]+ %a+ / ([%d.]+ %a+)"),
		disk = tonumber(t:match("DISK (%d+) %%")),
		diskUsed = t:match("DISK %d+ %% %S+ ([%d.]+ %a+) /"),
		diskTotal = t:match("DISK %d+ %% %S+ [%d.]+ %a+ / ([%d.]+ %a+)"),
	}
end

-- plain finds only: a `.-` pattern over the whole page blows the callback CPU budget
local function parseContainers(html)
	local list = {}
	local pos = 1
	while true do
		local from, to = html:find('<li class="docker-container', pos, true)
		if not from then
			break
		end
		local close = html:find("</li>", to, true) or #html
		local item = html:sub(from, close)
		table.insert(list, {
			name = item:match('size%-title%-dynamic">%s*([^<]-)%s*<') or "?",
			image = item:match('text%-truncate block">%s*([^<]-)%s*<') or "",
			state = item:match('data%-popover%-text="([^"]+)"') or "unknown",
			uptime = item:match('visually%-hidden" aria%-label="([^"]+)"') or "",
		})
		pos = close
	end
	return list
end

local function checkGlance()
	if not config.glance then
		return
	end
	noctalia.http({ url = config.glance .. "/api/pages/home/content/", allow_insecure_tls = true }, function(res)
		if not (res.ok and res.status == 200) then
			data.server = nil
			publish()
			return
		end
		-- each callback has its own CPU budget and parsing the whole page in one went over it:
		-- cut out the two widgets, parse the server here and the containers in a second
		-- callback (`true` exits at once, it only gives us that fresh budget)
		local docker = section(res.body, "docker-containers")
		data.server = parseServer(section(res.body, "server-stats") or "")
		publish()
		noctalia.runAsync({ "true" }, function()
			data.containers = docker and parseContainers(docker) or {}
			publish()
		end)
	end)
end

-- @Tailscale: peers of the tailnet, this machine first
local function checkTailscale()
	noctalia.runAsync({ "tailscale", "status", "--json" }, function(res)
		if res.exitCode ~= 0 then
			return
		end
		local status = noctalia.json.decode(res.stdout)
		if not status then
			return
		end
		local peers = {}
		if status.Self then
			table.insert(peers, { name = status.Self.HostName, os = status.Self.OS, online = true, self = true })
		end
		for _, p in status.Peer or {} do
			table.insert(peers, { name = p.HostName, os = p.OS, online = p.Online == true, self = false })
		end
		table.sort(peers, function(a, b)
			if a.self ~= b.self then
				return a.self
			end
			if a.online ~= b.online then
				return a.online
			end
			return a.name:lower() < b.name:lower()
		end)
		data.peers = peers
		publish()
	end, 5000)
end

local function poll()
	checkServices()
	checkGlance()
	checkTailscale()
end

noctalia.setUpdateInterval(refreshMs)
poll()

function update()
	poll()
end

function onIpc(event)
	if event == "refresh" then
		poll()
	end
end
