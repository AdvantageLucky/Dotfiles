--!nonstrict
-- One metric card: CAPS label, glyph on the left, big value on the right, thin bar below.
-- The value and bar turn to the error color past the metric's critical threshold.

local KINDS = {
	cpu = { label = "USO DE CPU", glyph = "cpu", unit = "%", max = 100, critical = 90 },
	cpu_temp = { label = "TEMPERATURA CPU", glyph = "temperature", unit = "°C", max = 100, critical = 85 },
	gpu_temp = { label = "TEMPERATURA GPU", glyph = "temperature", unit = "°C", max = 100, critical = 85 },
	ram = { label = "MEMORIA", glyph = "database", unit = "%", max = 100, critical = 90 },
	disk = { label = "DISCO", glyph = "folders", unit = "%", max = 100, critical = 90 },
}

-- the host sizes the widget box but does not stretch the root node: match config.toml

local kind = KINDS[noctalia.getConfig("stat") or "cpu"] or KINDS.cpu
local key = noctalia.getConfig("stat") or "cpu"

local function read()
	if key == "disk" then
		local disk = noctalia.diskStats("/")
		return disk and disk.usagePercent
	end
	local stats = noctalia.systemStats()
	if not stats then
		return nil
	end
	if key == "cpu" then
		return stats.cpu.usagePercent
	elseif key == "cpu_temp" then
		return stats.cpu.tempC
	elseif key == "gpu_temp" then
		return stats.gpu.tempC
	elseif key == "ram" then
		return stats.ram.usagePercent
	end
	return nil
end

local function render()
	local value = read()
	local hot = value ~= nil and value >= kind.critical
	local accent = hot and "error" or "primary"
	desktopWidget.render(ui.column({ width = 240, height = 150, fill = "surface/0.86", radius = 24, padding = 20, gap = 12, justify = "center" }, {
		ui.label({ text = kind.label, fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
		ui.row({ align = "center", justify = "space_between" }, {
			ui.glyph({ name = kind.glyph, size = 28, color = accent }),
			ui.label({
				text = value and `{math.floor(value + 0.5)}{kind.unit}` or "—",
				fontSize = 38,
				fontWeight = "bold",
				color = hot and "error" or "on_surface",
			}),
		}),
		ui.progress({ progress = math.clamp((value or 0) / kind.max, 0, 1), fill = accent, track = "surface_variant", radius = 3, height = 6 }),
	}))
end

noctalia.setUpdateInterval(2000)
render()

function update()
	render()
end
