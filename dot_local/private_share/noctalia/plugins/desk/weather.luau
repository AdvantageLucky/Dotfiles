--!nonstrict
-- Weather card: CAPS label, big temperature, condition and today's max/min, a large glyph.
-- Location from the public IP (ipwho.is), weather from open-meteo; refreshed every 15 min.

local WMO = {
	[0] = { "Despejado", "sun", "moon" },
	[1] = { "Casi despejado", "cloud-sun", "moon" },
	[2] = { "Parcialmente nublado", "cloud-sun", "cloud" },
	[3] = { "Nublado", "cloud", "cloud" },
	[45] = { "Niebla", "cloud-fog", "cloud-fog" },
	[48] = { "Niebla", "cloud-fog", "cloud-fog" },
	[51] = { "Llovizna", "cloud-rain", "cloud-rain" },
	[53] = { "Llovizna", "cloud-rain", "cloud-rain" },
	[55] = { "Llovizna", "cloud-rain", "cloud-rain" },
	[61] = { "Lluvia ligera", "cloud-rain", "cloud-rain" },
	[63] = { "Lluvia", "cloud-rain", "cloud-rain" },
	[65] = { "Lluvia fuerte", "cloud-rain", "cloud-rain" },
	[71] = { "Nieve", "cloud-snow", "cloud-snow" },
	[80] = { "Chubascos", "cloud-rain", "cloud-rain" },
	[81] = { "Chubascos", "cloud-rain", "cloud-rain" },
	[82] = { "Chubascos fuertes", "cloud-rain", "cloud-rain" },
	[95] = { "Tormenta", "cloud-storm", "cloud-storm" },
	[96] = { "Tormenta", "cloud-storm", "cloud-storm" },
	[99] = { "Tormenta", "cloud-storm", "cloud-storm" },
}

local place = nil
local weather = nil

local function render()
	if not weather then
		desktopWidget.render(ui.column({ width = 270, height = 200, fill = "surface/0.86", radius = 24, padding = 20, justify = "center" }, {
			ui.label({ text = "CLIMA", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
			ui.label({ text = "consultando…", color = "on_surface_variant" }),
		}))
		return
	end
	local code = WMO[weather.code] or { "—", "cloud", "cloud" }
	local glyph = weather.isDay and code[2] or code[3]
	desktopWidget.render(ui.column({ width = 270, height = 200, fill = "surface/0.86", radius = 24, padding = 20, gap = 4 }, {
		ui.label({ text = "CLIMA", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
		ui.label({ text = `{math.floor(weather.temp + 0.5)}°`, fontSize = 58, fontWeight = "heavy", color = "on_surface" }),
		ui.spacer({ flexGrow = 1 }),
		ui.row({ align = "end", gap = 8 }, {
			ui.column({ flexGrow = 1, gap = 2 }, {
				ui.label({ text = code[1], fontSize = 14, fontWeight = "semibold", color = "on_surface" }),
				ui.label({
					text = `Máx {math.floor(weather.max + 0.5)}° · Mín {math.floor(weather.min + 0.5)}°`,
					fontSize = 12,
					color = "on_surface_variant",
				}),
			}),
			ui.glyph({ name = glyph, size = 40, color = "primary" }),
		}),
	}))
end

local function fetchWeather()
	if not place then
		return
	end
	local url = `https://api.open-meteo.com/v1/forecast?latitude={place.lat}&longitude={place.lon}`
		.. "&current=temperature_2m,weather_code,is_day&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1"
	noctalia.http({ url = url }, function(res)
		local data = res.ok and res.status == 200 and noctalia.json.decode(res.body)
		if data and data.current then
			weather = {
				temp = data.current.temperature_2m,
				code = data.current.weather_code,
				isDay = data.current.is_day == 1,
				max = data.daily.temperature_2m_max[1],
				min = data.daily.temperature_2m_min[1],
			}
			render()
		end
	end)
end

local function refresh()
	if place then
		fetchWeather()
		return
	end
	noctalia.http({ url = "https://ipwho.is/" }, function(res)
		local data = res.ok and noctalia.json.decode(res.body)
		if data and data.latitude then
			place = { lat = data.latitude, lon = data.longitude }
			fetchWeather()
		end
	end)
end

noctalia.setUpdateInterval(15 * 60 * 1000)
render()
refresh()

function update()
	refresh()
end
