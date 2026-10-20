--!nonstrict
-- Bar island: server glyph + "up/total". Tinted by health, tooltip lists every service
-- with its latency. Left click opens the dashboard, right click forces a refresh.

local function render(raw)
	local data = raw and noctalia.json.decode(raw)
	if not data or not data.total then
		barWidget.setGlyph("server-2")
		barWidget.setText("…")
		barWidget.setGlyphColor("on_surface_variant")
		return
	end

	local healthy = data.up == data.total
	barWidget.setGlyph(healthy and "server-2" or "server-bolt")
	barWidget.setGlyphColor(healthy and "tertiary" or "error")
	barWidget.setText(`{data.up}/{data.total}`)

	local rows = { { key = data.name, value = healthy and "todo en línea" or "revisar" } }
	for _, s in data.services do
		table.insert(rows, { key = s.name, value = s.up and `{s.latency} ms` or "caído" })
	end
	if data.server and data.server.cpu then
		table.insert(rows, {
			key = "servidor",
			value = `cpu {data.server.cpu}% · ram {data.server.ram}% · {data.server.temp or "?"}°`,
		})
	end
	barWidget.setTooltip(rows)
end

noctalia.state.watch("homelab", render)
render(noctalia.state.get("homelab"))

function onClick()
	noctalia.togglePanel("sleepy/homelab:dashboard")
end

function onRightClick()
	noctalia.runAsync({ "noctalia", "msg", "plugin", "sleepy/homelab:poller", "all", "refresh" })
end
