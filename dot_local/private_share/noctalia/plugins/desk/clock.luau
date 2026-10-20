--!nonstrict
-- Big clock: time in heavy weight, date underneath in the accent color, right aligned.
-- No card: it sits straight on the wallpaper like the reference rices.

local DAYS = { "domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado" }
local MONTHS = { "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre" }

local function render()
	local now = os.date("*t")
	-- the block sits at the right edge; inside it, time and date are centered on each other
	desktopWidget.render(ui.column({ width = 460, height = 190, align = "end", justify = "center" }, {
		ui.column({ align = "center", gap = 2 }, {
			ui.label({ text = os.date("%H:%M"), fontSize = 112, fontWeight = "heavy", color = "on_surface" }),
			-- the date sits on a dark pill: plain accent text gets lost on a busy wallpaper
			ui.row({ fill = "surface/0.8", radius = 99, paddingH = 16, paddingV = 6 }, {
				ui.label({
					text = `{DAYS[now.wday]}, {now.day} de {MONTHS[now.month]}`,
					fontSize = 20,
					fontWeight = "semibold",
					color = "primary",
				}),
			}),
		}),
	}))
end

desktopWidget.setWantsSecondTicks(true)
render()

function update()
	render()
end
