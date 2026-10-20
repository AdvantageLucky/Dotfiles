--!nonstrict
-- Now playing card: cover art, title, artist, progress and transport controls.
-- Data from the mpris service (state "media"); controls go back through "media_cmd".
-- The host sizes the widget box but does not stretch the root node: sizes match config.toml.

local media = nil

local function fmt(us)
	local s = math.floor((us or 0) / 1e6)
	return string.format("%d:%02d", s // 60, s % 60)
end

local function control(method)
	noctalia.state.set("media_cmd", method)
end

-- position advances locally between the service's 1 s polls
local function position()
	if not media.position then
		return 0
	end
	if media.status ~= "Playing" or not media.at then
		return media.position
	end
	return math.min(media.position + (noctalia.nowMs() - media.at) * 1000, media.length or 0)
end

local function render()
	if not media or not media.player then
		-- distinct keys per layout: the host retains nodes across renders and would carry
		-- props (fill, justify) of the idle layout over into the playing one
		desktopWidget.render(ui.row({ key = "idle", width = 480, height = 190, fill = "surface/0.86", radius = 24, padding = 20, gap = 16, align = "center" }, {
			ui.column({ width = 72, height = 72, radius = 16, fill = "surface_variant", align = "center", justify = "center" }, {
				ui.glyph({ name = "music", size = 30, color = "on_surface_variant" }),
			}),
			ui.column({ width = 300, gap = 4 }, {
				ui.label({ text = "SONANDO AHORA", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
				ui.label({ text = "nada sonando", fontSize = 16, color = "on_surface_variant" }),
			}),
		}))
		return
	end

	local playing = media.status == "Playing"
	local pos = position()
	local art = media.cover
			and ui.image({ key = "cover", path = media.cover, width = 136, height = 136, radius = 18, fit = "cover" })
		or ui.column({ key = "nocover", width = 136, height = 136, radius = 18, fill = "surface_variant", align = "center", justify = "center" }, {
			ui.glyph({ name = "music", size = 40, color = "on_surface_variant" }),
		})

	desktopWidget.render(ui.row({ key = "playing", width = 480, height = 190, fill = "surface/0.86", radius = 24, padding = 18, gap = 18, align = "center" }, {
		art,
		-- fixed width: a flexGrow column collapses to its narrowest child here
		ui.column({ key = "info", width = 290, height = 154, gap = 4 }, {
			ui.label({ text = playing and "SONANDO AHORA" or "EN PAUSA", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
			ui.label({ text = media.title, fontSize = 19, fontWeight = "bold", color = "on_surface", maxLines = 1 }),
			ui.label({ text = media.artist, fontSize = 14, fontWeight = "semibold", color = "primary", maxLines = 1 }),
			ui.spacer({ flexGrow = 1 }),
			ui.row({ gap = 8, align = "center" }, {
				ui.label({ text = fmt(pos), fontSize = 11, color = "on_surface_variant" }),
				ui.progress({
					progress = (media.length or 0) > 0 and math.clamp(pos / media.length, 0, 1) or 0,
					fill = "primary",
					track = "surface_variant",
					radius = 3,
					height = 5,
					flexGrow = 1,
				}),
				ui.label({ text = fmt(media.length), fontSize = 11, color = "on_surface_variant" }),
			}),
			ui.row({ gap = 10, justify = "center", align = "center" }, {
				ui.button({ glyph = "player-track-prev-filled", variant = "ghost", controlSize = "sm", onClick = function() control("Previous") end }),
				ui.button({
					glyph = playing and "player-pause-filled" or "player-play-filled",
					variant = "primary",
					controlSize = "md",
					onClick = function() control("PlayPause") end,
				}),
				ui.button({ glyph = "player-track-next-filled", variant = "ghost", controlSize = "sm", onClick = function() control("Next") end }),
			}),
		}),
	}))
end

noctalia.state.watch("media", function(raw)
	media = raw and noctalia.json.decode(raw)
	render()
end)

local raw = noctalia.state.get("media")
media = raw and noctalia.json.decode(raw)
render()

-- the service only publishes on changes: tick once a second so the progress keeps moving
desktopWidget.setWantsSecondTicks(true)

function update()
	if media and media.status == "Playing" then
		render()
	end
end
