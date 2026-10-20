--!nonstrict
-- MPRIS service shared by the bar widget, the desktop card and the media panel: talks to
-- the first player on the session bus with busctl (no playerctl needed) and publishes
-- state "media" (JSON). Covers served over http (navidrome) are downloaded once per track.
-- Entries send transport commands through state "media_cmd" ("PlayPause", "Next", ...).
-- Event driven: a `busctl monitor` stream rereads the player only when it signals a change
-- (the position is interpolated by the entries), plus a slow safety poll.

local OBJ = "/org/mpris/MediaPlayer2"
local IFACE = "org.mpris.MediaPlayer2.Player"

local dataDir = noctalia.pluginDataDir()
local player = nil
local media = { player = nil }
local lastRead = 0

local function publish()
	noctalia.state.set("media", noctalia.json.encode(media))
end

-- cover file name: hash of the art URL without navidrome's per-request auth params (s, t),
-- so every cover gets its own file. Naming it after the trackid broke with players whose
-- trackid never changes (zen/firefox): one stale file, and the image cache kept showing it
local function coverName(url)
	local stable = url:gsub("([?&])[st]=[^&]*", "%1")
	local h = 5381
	for i = 1, #stable do
		h = (h * 33 + stable:byte(i)) % 4294967296
	end
	return string.format("cover-%08x.img", h)
end

-- keep the newest covers only
local MAX_COVERS = 12
local function pruneCovers()
	local files = noctalia.listDir(dataDir) or {}
	local covers = {}
	for _, name in files do
		if name:match("^cover%-") then
			local info = noctalia.fileInfo(`{dataDir}/{name}`)
			table.insert(covers, { path = `{dataDir}/{name}`, mtime = info and info.mtime or 0 })
		end
	end
	if #covers <= MAX_COVERS then
		return
	end
	table.sort(covers, function(a, b)
		return a.mtime > b.mtime
	end)
	for i = MAX_COVERS + 1, #covers do
		noctalia.removeFile(covers[i].path)
	end
end

local function fetchCover(url, key)
	media.cover = nil
	if not url or url == "" then
		return
	end
	if url:sub(1, 7) == "file://" then
		media.cover = noctalia.string.urlDecode(url:sub(8))
		return
	end
	if not dataDir then
		return
	end
	local dest = `{dataDir}/{coverName(url)}`
	if noctalia.fileExists(dest) then
		media.cover = dest
		return
	end
	noctalia.download(url, dest, function(ok)
		if ok and media.key == key then
			media.cover = dest
			publish()
			pruneCovers()
		end
	end)
end

local function readPlayer()
	lastRead = noctalia.nowMs()
	noctalia.runAsync({ "busctl", "--user", "--json=short", "get-property", player, OBJ, IFACE, "Metadata", "PlaybackStatus", "Position" }, function(res)
		if res.exitCode ~= 0 then
			player = nil
			media = { player = nil }
			publish()
			return
		end
		local lines = {}
		for line in res.stdout:gmatch("[^\n]+") do
			table.insert(lines, noctalia.json.decode(line))
		end
		local meta = lines[1] and lines[1].data or {}
		local function field(name)
			local v = meta[name]
			return v and v.data
		end
		local id = field("mpris:trackid") or field("xesam:title") or ""
		local artists = field("xesam:artist")
		local art = field("mpris:artUrl") or ""
		-- a change of track is any change of id, title or cover (some players keep one id)
		local key = `{player}|{id}|{field("xesam:title") or ""}|{(art:gsub("([?&])[st]=[^&]*", "%1"))}`
		local changed = media.key ~= key
		media.player = player
		media.id = id
		media.key = key
		media.title = field("xesam:title") or "—"
		media.artist = type(artists) == "table" and table.concat(artists, ", ") or (artists or "")
		media.album = field("xesam:album") or ""
		media.length = field("mpris:length") or 0
		media.status = lines[2] and lines[2].data or "Stopped"
		media.position = lines[3] and lines[3].data or 0
		media.at = noctalia.nowMs()
		if changed then
			fetchCover(art, key)
		end
		publish()
	end, 2000)
end

-- the MPRIS player to follow: the one playing, else the current one if still there, else
-- the first (noctalia's own dev.noctalia.Mpris is not a player)
local LIST = [[
for p in $(busctl --user list --no-legend | awk '$1 ~ /^org\.mpris\.MediaPlayer2\./ {print $1}'); do
	echo "$p $(busctl --user get-property "$p" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlaybackStatus 2>/dev/null | awk '{print $2}' | tr -d '"')"
done
]]

local function findPlayer()
	noctalia.runAsync({ "sh", "-c", LIST }, function(res)
		local first, current, playing = nil, nil, nil
		for line in res.stdout:gmatch("[^\n]+") do
			local name, status = line:match("^(%S+)%s*(%S*)")
			if name then
				first = first or name
				if name == player then
					current = name
				end
				if status == "Playing" and not playing then
					playing = name
				end
			end
		end
		player = playing or current or first
		if player then
			readPlayer()
		elseif media.player then
			media = { player = nil }
			publish()
		end
	end, 3000)
end

noctalia.state.watch("media_cmd", function(method)
	if player and method and method ~= "" then
		noctalia.runAsync({ "busctl", "--user", "call", player, OBJ, IFACE, method }, function()
			readPlayer()
		end)
		noctalia.state.set("media_cmd", "")
	end
end)

-- PropertiesChanged on the MPRIS path (track, status, seek) and players coming and going
local MONITOR = "busctl --user monitor --json=short"
	.. " --match \"type='signal',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'\""
	.. " --match \"type='signal',member='NameOwnerChanged',arg0namespace='org.mpris.MediaPlayer2'\""

local function onSignal(line)
	if line:find('"NameOwnerChanged"', 1, true) then
		findPlayer()
	elseif line:find('"PropertiesChanged"', 1, true) and player and noctalia.nowMs() - lastRead > 250 then
		readPlayer()
	end
end

-- the stream outlives a shell restart or a plugin reload (it gets reparented): kill the
-- monitors left behind by earlier runs before starting this one
noctalia.runAsync({ "pkill", "-f", "busctl --user monitor --json=short --match type='signal',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" }, function()
	noctalia.runStream(MONITOR, onSignal)
end)

function onExit()
	noctalia.runAsync({ "pkill", "-f", "busctl --user monitor --json=short --match type='signal',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'" })
end

noctalia.setUpdateInterval(15000)
findPlayer()

-- safety poll: catches a dead stream or a player that does not signal
function update()
	findPlayer()
end
