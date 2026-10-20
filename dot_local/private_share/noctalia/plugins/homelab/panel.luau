--!nonstrict
-- Homelab dashboard: header with host + uptime, four server gauges, the services as
-- clickable cards (opens them in the browser), docker containers and tailnet peers.
-- Open with: noctalia msg panel-toggle sleepy/homelab:dashboard

local data = nil

-- tcp services backed by a container (lazymc -> minecraft): "activo", "dormido" or nil
local function serverState(data, s)
	if not s.container then
		return nil
	end
	for _, c in data.containers or {} do
		if c.name == s.container then
			return c.state == "running" and "activo" or "dormido"
		end
	end
	return nil
end

local function open(url)
	local address = url:match("^tcp://(.+)$")
	if address then
		-- not a web page: copy host:port to paste in the game
		noctalia.copyToClipboard(address, "text/plain")
		noctalia.notify("Dirección copiada", address)
	else
		noctalia.runAsync({ "xdg-open", url })
	end
	panel.close()
end

local function refresh()
	noctalia.runAsync({ "noctalia", "msg", "plugin", "sleepy/homelab:poller", "all", "refresh" })
end

local function since(epoch)
	if not epoch then
		return "uptime desconocido"
	end
	local secs = os.time() - epoch
	local days = math.floor(secs / 86400)
	if days >= 1 then
		return `arriba {days} {days == 1 and "día" or "días"}`
	end
	return `arriba {math.floor(secs / 3600)} h`
end

-- "1.1 GB", "7.8 GB" -> "1.1/7.8 GB"
local function amount(used, total)
	if not used or not total then
		return nil
	end
	return `{used:match("[%d.]+") or used}/{total}`
end

local function sectionTitle(text)
	return ui.label({ text = text, fontSize = 11, fontWeight = "semibold", color = "on_surface_variant" })
end

local function card(props, children)
	props.fill = props.fill or "surface_variant/0.45"
	props.radius = props.radius or 14
	props.padding = props.padding or 12
	return ui.column(props, children)
end

-- value 0..100 with a bar; turns red past `warn`
local function gauge(label, glyph, value, detail, warn)
	local pct = value or 0
	local hot = value ~= nil and pct >= warn
	return card({ flexGrow = 1, gap = 6 }, {
		ui.row({ gap = 6, align = "center" }, {
			ui.glyph({ name = glyph, size = 14, color = hot and "error" or "primary" }),
			ui.label({ text = label, fontSize = 11, color = "on_surface_variant" }),
		}),
		ui.label({
			text = value and `{pct}{label == "temp" and "°" or "%"}` or "—",
			fontSize = 22,
			fontWeight = "bold",
			color = hot and "error" or "on_surface",
		}),
		ui.progress({
			progress = math.min(pct, 100) / 100,
			fill = hot and "error" or "primary",
			track = "surface/0.6",
			radius = 3,
			height = 5,
		}),
		ui.label({ text = detail or " ", fontSize = 10, color = "on_surface_variant", maxLines = 1 }),
	})
end

local function serviceCard(s)
	local state = serverState(data, s)
	local detail = s.up and (state and `servidor {state} · {s.latency} ms` or `{s.about} · {s.latency} ms`) or `{s.about} · caído`
	return ui.row({
		key = s.name,
		flexGrow = 1,
		gap = 10,
		align = "center",
		padding = 10,
		radius = 14,
		fill = "surface_variant/0.45",
		onClick = function()
			open(s.url)
		end,
	}, {
		ui.column({ width = 34, height = 34, radius = 10, fill = s.up and "primary/0.18" or "error/0.18", align = "center", justify = "center" }, {
			ui.glyph({ name = s.glyph, size = 18, color = s.up and "primary" or "error" }),
		}),
		ui.column({ flexGrow = 1, gap = 2 }, {
			ui.label({ text = s.name, fontWeight = "semibold", maxLines = 1 }),
			ui.label({
				text = detail,
				fontSize = 10,
				color = s.up and "on_surface_variant" or "error",
				maxLines = 1,
			}),
		}),
		ui.box({ width = 8, height = 8, radius = 4, fill = s.up and "tertiary" or "error" }),
	})
end

-- two cards per row. The poller fills data.services by index as each check answers, so
-- right after a refresh the list can have holes: keep only the services already checked.
local function serviceGrid(services)
	local list = {}
	for _, s in services do
		table.insert(list, s)
	end
	local rows = {}
	for i = 1, #list, 2 do
		local pair = { serviceCard(list[i]) }
		if list[i + 1] then
			table.insert(pair, serviceCard(list[i + 1]))
		else
			table.insert(pair, ui.spacer({ flexGrow = 1 }))
		end
		table.insert(rows, ui.row({ gap = 8 }, pair))
	end
	return ui.column({ gap = 8 }, rows)
end

local function chip(glyph, text, ok, key)
	return ui.row({ key = key, gap = 6, align = "center", paddingH = 10, paddingV = 6, radius = 99, fill = "surface_variant/0.45" }, {
		ui.box({ width = 7, height = 7, radius = 4, fill = ok and "tertiary" or "outline" }),
		ui.glyph({ name = glyph, size = 13, color = ok and "on_surface" or "on_surface_variant" }),
		ui.label({ text = text, fontSize = 11, color = ok and "on_surface" or "on_surface_variant" }),
	})
end

local function wrapRows(items, perRow)
	local rows = {}
	for i = 1, #items, perRow do
		local row = {}
		for j = i, math.min(i + perRow - 1, #items) do
			table.insert(row, items[j])
		end
		table.insert(rows, ui.row({ gap = 6 }, row))
	end
	return ui.column({ gap = 6 }, rows)
end

local osGlyph = { linux = "device-desktop", android = "device-mobile", windows = "device-laptop" }

local function render()
	if not data then
		panel.render(ui.column({ padding = 24, align = "center", justify = "center", flexGrow = 1 }, {
			ui.label({ text = "consultando el homelab…", color = "on_surface_variant" }),
		}))
		return
	end

	local server = data.server or {}
	local healthy = data.up == data.total

	local header = ui.row({ gap = 12, align = "center" }, {
		ui.column({ width = 46, height = 46, radius = 14, fill = "primary/0.2", align = "center", justify = "center" }, {
			ui.glyph({ name = "server-2", size = 24, color = "primary" }),
		}),
		ui.column({ flexGrow = 1, gap = 2 }, {
			ui.label({ text = server.host or data.name, fontSize = 18, fontWeight = "bold" }),
			ui.label({
				text = data.os and `{data.os} · {since(server.since)}` or since(server.since),
				fontSize = 11,
				color = "on_surface_variant",
			}),
		}),
		ui.row({ gap = 6, align = "center", paddingH = 10, paddingV = 6, radius = 99, fill = healthy and "tertiary/0.18" or "error/0.18" }, {
			ui.box({ width = 8, height = 8, radius = 4, fill = healthy and "tertiary" or "error" }),
			ui.label({ text = `{data.up}/{data.total} en línea`, fontSize = 11, color = healthy and "tertiary" or "error" }),
		}),
		ui.button({ glyph = "refresh", variant = "ghost", controlSize = "sm", tooltip = "actualizar", onClick = refresh }),
	})

	local gauges = ui.row({ gap = 8 }, {
		gauge("cpu", "cpu", server.cpu, nil, 85),
		gauge("ram", "database", server.ram, amount(server.ramUsed, server.ramTotal), 90),
		gauge("disco", "folders", server.disk, amount(server.diskUsed, server.diskTotal), 90),
		gauge("temp", "temperature", server.temp, nil, 75),
	})

	local containers = {}
	for _, c in data.containers or {} do
		table.insert(containers, chip("brand-docker", c.name, c.state == "running", "c" .. c.name))
	end

	local peers = {}
	for _, p in data.peers or {} do
		table.insert(peers, chip(osGlyph[p.os] or "device-desktop", p.self and `{p.name} (este)` or p.name, p.online, "p" .. p.name))
	end

	local body = {
		header,
		gauges,
		sectionTitle("SERVICIOS"),
		serviceGrid(data.services or {}),
	}
	if #containers > 0 then
		table.insert(body, sectionTitle("CONTENEDORES"))
		table.insert(body, wrapRows(containers, 4))
	end
	if #peers > 0 then
		table.insert(body, sectionTitle("TAILNET"))
		table.insert(body, wrapRows(peers, 3))
	end
	table.insert(body, ui.label({
		text = `actualizado {noctalia.formatTime("%H:%M:%S", data.updated)}`,
		fontSize = 10,
		color = "on_surface_variant",
	}))

	panel.render(ui.scroll({ flexGrow = 1 }, {
		ui.column({ padding = 18, gap = 12 }, body),
	}))
end

noctalia.state.watch("homelab", function(raw)
	data = raw and noctalia.json.decode(raw)
	render()
end)

function onOpen()
	local raw = noctalia.state.get("homelab")
	data = raw and noctalia.json.decode(raw)
	render()
	refresh()
end
