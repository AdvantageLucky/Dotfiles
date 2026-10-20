--!nonstrict
-- Compact system card: one row per metric (glyph, CAPS label, value, thin bar) instead of
-- a full card each. A row turns to the error color past its critical threshold.
-- Sized to match config.toml (the host does not stretch the root node).

local ROWS = {
	{ key = "cpu", label = "CPU", glyph = "cpu", unit = "%", critical = 90 },
	{ key = "cpu_temp", label = "TEMP", glyph = "temperature", unit = "°", critical = 85 },
	{ key = "ram", label = "RAM", glyph = "database", unit = "%", critical = 90 },
}

local function read(stats, key)
	if not stats then
		return nil
	end
	if key == "cpu" then
		return stats.cpu.usagePercent
	elseif key == "cpu_temp" then
		return stats.cpu.tempC
	elseif key == "ram" then
		return stats.ram.usagePercent
	end
	return nil
end

local function row(stats, spec)
	local value = read(stats, spec.key)
	local hot = value ~= nil and value >= spec.critical
	local accent = hot and "error" or "primary"
	return ui.column({ key = spec.key, gap = 6 }, {
		ui.row({ gap = 10, align = "center" }, {
			ui.glyph({ name = spec.glyph, size = 16, color = accent }),
			ui.label({ text = spec.label, fontSize = 12, fontWeight = "semibold", color = "on_surface_variant", flexGrow = 1 }),
			ui.label({
				text = value and `{math.floor(value + 0.5)}{spec.unit}` or "—",
				fontSize = 18,
				fontWeight = "bold",
				color = hot and "error" or "on_surface",
			}),
		}),
		ui.progress({ progress = math.clamp((value or 0) / 100, 0, 1), fill = accent, track = "surface_variant", radius = 3, height = 5 }),
	})
end

local function render()
	local stats = noctalia.systemStats()
	local rows = { ui.label({ text = "SISTEMA", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }) }
	for _, spec in ROWS do
		table.insert(rows, row(stats, spec))
	end
	desktopWidget.render(ui.column({ width = 270, height = 196, fill = "surface/0.86", radius = 24, padding = 20, gap = 12 }, rows))
end

noctalia.setUpdateInterval(2000)
render()

function update()
	render()
end
