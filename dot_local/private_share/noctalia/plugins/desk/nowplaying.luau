--!nonstrict
-- Bar now-playing: a small live spectrum (PipeWire monitor, fed by the host through
-- onAudioSpectrum) next to "title - artist". It also relays the spectrum to the media
-- panel through state "spectrum", since only bar widgets receive it.
-- Left click toggles the media panel, scroll skips tracks.

local MAX_CHARS = 34
local BARS = 5

local media = nil
local bands = {}
local lastPaint = 0
local lastRelay = 0

local function render()
	if not media or not media.player then
		barWidget.render(ui.row({ gap = 6, align = "center" }, {
			ui.glyph({ name = "music", size = 14, color = "on_surface_variant" }),
		}))
		barWidget.setTooltip("nada sonando")
		return
	end

	local playing = media.status == "Playing"
	local bars = {}
	for i = 1, BARS do
		local v = playing and (bands[i] or 0) or 0
		table.insert(bars, ui.box({ width = 3, height = 3 + math.floor(v * 13), radius = 2, fill = playing and "primary" or "on_surface_variant" }))
	end

	local text = media.artist ~= "" and `{media.title} - {media.artist}` or media.title
	if #text > MAX_CHARS then
		text = text:sub(1, MAX_CHARS - 1) .. "…"
	end

	barWidget.render(ui.row({ gap = 8, align = "center" }, {
		ui.row({ gap = 2, align = "end", height = 16 }, bars),
		ui.label({ text = text, color = playing and "on_surface" or "on_surface_variant" }),
	}))
	barWidget.setTooltip({
		{ key = media.title, value = "" },
		{ key = media.artist, value = media.album or "" },
	})
end

noctalia.state.watch("media", function(raw)
	media = raw and noctalia.json.decode(raw)
	render()
end)

local raw = noctalia.state.get("media")
media = raw and noctalia.json.decode(raw)
render()

-- ~60 Hz from the host: repaint the bar at ~12 fps (each repaint makes niri recompose),
-- relay to the panel at ~20 fps only while it is open
function onAudioSpectrum(valuesCsv, stateCsv)
	local now = noctalia.nowMs()
	local relay = noctalia.state.get("mixer_open") and now - lastRelay >= 50
	if now - lastPaint < 80 and not relay then
		return -- most of the 60 calls/s: skip the parsing entirely
	end
	local values = {}
	for v in (valuesCsv or ""):gmatch("[^,]+") do
		table.insert(values, math.clamp(tonumber(v) or 0, 0, 1))
	end
	local active = (stateCsv or ""):sub(1, 1) == "1"

	-- squeeze all bands into the bar's few columns
	local per = math.max(1, #values // BARS)
	bands = {}
	for i = 1, BARS do
		local peak = 0
		for j = (i - 1) * per + 1, math.min(i * per, #values) do
			peak = math.max(peak, values[j])
		end
		bands[i] = active and peak or 0
	end

	if now - lastPaint >= 80 then
		lastPaint = now
		render()
	end
	if relay then
		lastRelay = now
		noctalia.state.set("spectrum", active and valuesCsv or "")
	end
end

function onClick()
	noctalia.togglePanel("sleepy/desk:mixer")
end

function onScroll(axis, steps)
	if axis == "vertical" then
		noctalia.state.set("media_cmd", steps > 0 and "Next" or "Previous")
	end
end
