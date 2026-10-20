--!nonstrict
-- Desktop card in the desk kit style: CAPS label, big "up/total", one row per service with
-- its latency. Same data as the bar widget.

local data = nil

local function card(children)
	return ui.column({ width = 300, height = 278, fill = "surface/0.86", radius = 24, padding = 20, gap = 10 }, children)
end

local function render()
	if not data or not data.total then
		desktopWidget.render(card({
			ui.label({ text = "HOMELAB", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
			ui.label({ text = "consultando…", color = "on_surface_variant" }),
		}))
		return
	end

	local healthy = data.up == data.total
	local rows = {
		ui.row({ align = "center", justify = "space_between" }, {
			ui.label({ text = "HOMELAB", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
			ui.row({ gap = 10, align = "center" }, {
				ui.glyph({ name = healthy and "server-2" or "server-bolt", size = 28, color = healthy and "primary" or "error" }),
				ui.label({ text = `{data.up}/{data.total}`, fontSize = 34, fontWeight = "bold", color = healthy and "on_surface" or "error" }),
			}),
		}),
		ui.progress({ progress = data.total > 0 and data.up / data.total or 0, fill = healthy and "primary" or "error", track = "surface_variant", radius = 3, height = 6 }),
	}

	for _, s in data.services do
		table.insert(rows, ui.row({ key = s.name, gap = 10, align = "center" }, {
			ui.glyph({ name = s.glyph, size = 16, color = s.up and "primary" or "error" }),
			ui.label({ text = s.name, fontSize = 13, fontWeight = "semibold", flexGrow = 1 }),
			ui.label({
				text = s.up and `{s.latency} ms` or "caído",
				fontSize = 12,
				color = s.up and "on_surface_variant" or "error",
			}),
		}))
	end

	desktopWidget.render(card(rows))
end

noctalia.state.watch("homelab", function(raw)
	data = raw and noctalia.json.decode(raw)
	render()
end)

local raw = noctalia.state.get("homelab")
data = raw and noctalia.json.decode(raw)
render()
