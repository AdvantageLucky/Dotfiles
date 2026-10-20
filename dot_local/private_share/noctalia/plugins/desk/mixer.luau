--!nonstrict
-- Media panel: audio card (output volume + microphone, with mute) next to a big player
-- card (cover, title, artist, live spectrum, progress, controls). Volumes go through wpctl;
-- the player comes from the mpris service and the spectrum from the bar widget.
-- Open with: noctalia msg panel-toggle sleepy/desk:mixer

local SINK = "@DEFAULT_AUDIO_SINK@"
local SOURCE = "@DEFAULT_AUDIO_SOURCE@"
local SPECTRUM_BARS = 30

local media = nil
local spectrum = {}
local audio = { sink = { volume = 0, muted = false }, source = { volume = 0, muted = false } }
local open = false
local lastPaint = 0

local function fmt(us)
	local s = math.floor((us or 0) / 1e6)
	return string.format("%d:%02d", s // 60, s % 60)
end

local function control(method)
	noctalia.state.set("media_cmd", method)
end

local function readVolume(target, slot)
	noctalia.runAsync({ "wpctl", "get-volume", target }, function(res)
		local v = tonumber(res.stdout:match("Volume:%s*([%d.]+)"))
		if v then
			audio[slot] = { volume = math.floor(v * 100 + 0.5), muted = res.stdout:find("MUTED", 1, true) ~= nil }
			render()
		end
	end)
end

local function readAudio()
	readVolume(SINK, "sink")
	readVolume(SOURCE, "source")
end

local function setVolume(target, slot, value)
	local v = math.clamp(tonumber(value) or 0, 0, 100)
	audio[slot].volume = v
	noctalia.runAsync({ "wpctl", "set-volume", target, string.format("%.2f", v / 100) })
end

local function toggleMute(target, slot)
	noctalia.runAsync({ "wpctl", "set-mute", target, "toggle" }, function()
		readVolume(target, slot)
	end)
end

local function position()
	if not media or not media.position then
		return 0
	end
	if media.status ~= "Playing" or not media.at then
		return media.position
	end
	return math.min(media.position + (noctalia.nowMs() - media.at) * 1000, media.length or 0)
end

local function volumeRow(label, target, slot, glyphOn, glyphOff)
	local a = audio[slot]
	return ui.column({ gap = 8 }, {
		ui.row({ gap = 8, align = "center" }, {
			ui.label({ text = label, fontSize = 12, fontWeight = "semibold", color = "on_surface_variant", flexGrow = 1 }),
			ui.label({ text = a.muted and "silencio" or `{a.volume}%`, fontSize = 14, fontWeight = "bold", color = a.muted and "error" or "on_surface" }),
		}),
		ui.row({ gap = 8, align = "center" }, {
			ui.button({
				glyph = a.muted and glyphOff or glyphOn,
				variant = a.muted and "destructive" or "secondary",
				controlSize = "sm",
				tooltip = a.muted and "activar" or "silenciar",
				onClick = function() toggleMute(target, slot) end,
			}),
			ui.slider({
				key = slot,
				min = 0,
				max = 100,
				step = 1,
				value = a.volume,
				flexGrow = 1,
				onChange = function(v) setVolume(target, slot, v) end,
			}),
		}),
	})
end

local function spectrumRow()
	local bars = {}
	local per = math.max(1, #spectrum // SPECTRUM_BARS)
	for i = 1, SPECTRUM_BARS do
		local peak = 0
		for j = (i - 1) * per + 1, math.min(i * per, #spectrum) do
			peak = math.max(peak, spectrum[j])
		end
		table.insert(bars, ui.box({ key = `b{i}`, width = 5, height = 4 + math.floor(peak * 56), radius = 3, fill = "primary" }))
	end
	return ui.row({ gap = 3, align = "end", height = 60 }, bars)
end

function render()
	if not open then
		return
	end

	local audioCard = ui.column({ width = 250, fill = "surface_variant/0.45", radius = 22, padding = 18, gap = 18 }, {
		ui.label({ text = "AUDIO", fontSize = 12, fontWeight = "semibold", color = "on_surface_variant" }),
		volumeRow("VOLUMEN", SINK, "sink", "volume", "volume-off"),
		volumeRow("MICRÓFONO", SOURCE, "source", "microphone", "microphone-off"),
	})

	local player
	if not media or not media.player then
		-- distinct keys per layout (see desk/media.luau): retained nodes keep stale props
		player = ui.column({ key = "idle", flexGrow = 1, fill = "surface_variant/0.45", radius = 22, padding = 18, align = "center", justify = "center" }, {
			ui.glyph({ name = "music", size = 34, color = "on_surface_variant" }),
			ui.label({ text = "nada sonando", color = "on_surface_variant" }),
		})
	else
		local playing = media.status == "Playing"
		local pos = position()
		local art = media.cover and ui.image({ key = "cover", path = media.cover, width = 196, height = 196, radius = 20, fit = "cover" })
			or ui.column({ key = "nocover", width = 196, height = 196, radius = 20, fill = "surface", align = "center", justify = "center" }, {
				ui.glyph({ name = "music", size = 48, color = "on_surface_variant" }),
			})
		player = ui.row({ key = "playing", flexGrow = 1, fill = "surface_variant/0.45", radius = 22, padding = 14, gap = 18, align = "center" }, {
			art,
			ui.column({ flexGrow = 1, gap = 6 }, {
				ui.label({ text = media.title, fontSize = 22, fontWeight = "bold", maxLines = 1 }),
				ui.label({ text = media.artist, fontSize = 15, fontWeight = "semibold", color = "primary", maxLines = 1 }),
				spectrumRow(),
				ui.row({ gap = 8, align = "center" }, {
					ui.label({ text = fmt(pos), fontSize = 11, color = "on_surface_variant" }),
					ui.progress({
						progress = (media.length or 0) > 0 and math.clamp(pos / media.length, 0, 1) or 0,
						fill = "primary",
						track = "surface",
						radius = 3,
						height = 5,
						flexGrow = 1,
					}),
					ui.label({ text = fmt(media.length), fontSize = 11, color = "on_surface_variant" }),
				}),
				ui.row({ gap = 14, justify = "center", align = "center" }, {
					ui.button({ glyph = "player-track-prev-filled", variant = "ghost", controlSize = "md", onClick = function() control("Previous") end }),
					ui.button({
						glyph = playing and "player-pause-filled" or "player-play-filled",
						variant = "primary",
						controlSize = "lg",
						onClick = function() control("PlayPause") end,
					}),
					ui.button({ glyph = "player-track-next-filled", variant = "ghost", controlSize = "md", onClick = function() control("Next") end }),
				}),
			}),
		})
	end

	panel.render(ui.row({ flexGrow = 1, padding = 16, gap = 14 }, { audioCard, player }))
end

noctalia.state.watch("media", function(raw)
	media = raw and noctalia.json.decode(raw)
	render()
end)

-- relayed by the bar widget at ~20 fps while audio plays
noctalia.state.watch("spectrum", function(csv)
	spectrum = {}
	for v in (csv or ""):gmatch("[^,]+") do
		table.insert(spectrum, tonumber(v) or 0)
	end
	local now = noctalia.nowMs()
	if now - lastPaint >= 45 then
		lastPaint = now
		render()
	end
end)

function onOpen()
	open = true
	noctalia.state.set("mixer_open", true) -- the bar widget relays the spectrum only now
	panel.setWantsSecondTicks(true) -- progress keeps moving between the service's updates
	local raw = noctalia.state.get("media")
	media = raw and noctalia.json.decode(raw)
	readAudio()
	render()
end

function onClose()
	open = false
	noctalia.state.set("mixer_open", false)
end

function update()
	render()
end
