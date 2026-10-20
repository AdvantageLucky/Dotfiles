--!nonstrict
-- MPRIS service shared by the bar widget, the desktop card and the media panel: talks to
-- the first player on the session bus with busctl (no playerctl needed) and publishes
-- state "media" (JSON). Covers served over http (navidrome) are downloaded once per track.
-- Entries send transport commands through state "media_cmd" ("PlayPause", "Next", ...).
-- Event driven: a `busctl monitor` stream rereads the player only when it signals a change
-- (the position is interpolated by the entries), plus a slow safety poll.

local OBJ = "/org/mpris/MediaPlayer2"
local IFACE = "org.mpris.MediaPlayer2.Player"

local dataDir = noctalia.pluginDataDir()
local player = nil
local media = { player = nil }
local lastRead = 0

local function publish()
	noctalia.state.set("media", noctalia.json.encode(media))
end

local function fetchCover(url, id)
	media.cover = nil
	if not url or url == "" then
		return
	end
	if url:sub(1, 7) == "file://" then
		media.cover = noctalia.string.urlDecode(url:sub(8))
		return
	end
	if not dataDir then
		return
	end
	local dest = `{dataDir}/cover-{(id:match("[^/]+$") or "track"):gsub("[^%w]", "")}.img`
	if noctalia.fileExists(dest) then
		media.cover = dest
		return
	end
	noctalia.download(url, dest, function(ok)
		if ok and media.id == id then
			media.cover = dest
			publish()
		end
	end)
end

local function readPlayer()
	lastRead = noctalia.nowMs()
	noctalia.runAsync({ "busctl", "--user", "--json=short", "get-property", player, OBJ, IFACE, "Metadata", "PlaybackStatus", "Position" }, function(res)
		if res.exitCode ~= 0 then
			player = nil
			media = { player = nil }
			publish()
			return
		end
		local lines = {}
		for line in res.stdout:gmatch("[^\n]+") do
			table.insert(lines, noctalia.json.decode(line))
		end
		local meta = lines[1] and lines[1].data or {}
		local function field(name)
			local v = meta[name]
			return v and v.data
		end
		local id = field("mpris:trackid") or field("xesam:title") or ""
		local artists = field("xesam:artist")
		local changed = media.id ~= id
		media.player = player
		media.id = id
		media.title = field("xesam:title") or "—"
		media.artist = type(artists) == "table" and table.concat(artists, ", ") or (artists or "")
		media.album = field("xesam:album") or ""
		media.length = field("mpris:length") or 0
		media.status = lines[2] and lines[2].data or "Stopped"
		media.position = lines[3] and lines[3].data or 0
		media.at = noctalia.nowMs()
		if changed then
			fetchCover(field("mpris:artUrl"), id)
		end
		publish()
	end, 2000)
end

-- the first MPRIS player (noctalia's own dev.noctalia.Mpris is not one)
local function findPlayer()
	noctalia.runAsync({ "busctl", "--user", "list", "--no-legend" }, function(res)
		player = nil
		for line in res.stdout:gmatch("[^\n]+") do
			local name = line:match("^(org%.mpris%.MediaPlayer2%.%S+)")
			if name then
				player = name
				break
			end
		end
		if player then
			readPlayer()
		elseif media.player then
			media = { player = nil }
			publish()
		end
	end, 2000)
end

noctalia.state.watch("media_cmd", function(method)
	if player and method and method ~= "" then
		noctalia.runAsync({ "busctl", "--user", "call", player, OBJ, IFACE, method }, function()
			readPlayer()
		end)
		noctalia.state.set("media_cmd", "")
	end
end)

-- PropertiesChanged on the MPRIS path (track, status, seek) and players coming and going
local MONITOR = "busctl --user monitor --json=short"
	.. " --match \"type='signal',member='PropertiesChanged',path='/org/mpris/MediaPlayer2'\""
	.. " --match \"type='signal',member='NameOwnerChanged',arg0namespace='org.mpris.MediaPlayer2'\""

noctalia.runStream(MONITOR, function(line)
	if line:find('"NameOwnerChanged"', 1, true) then
		findPlayer()
	elseif line:find('"PropertiesChanged"', 1, true) and player and noctalia.nowMs() - lastRead > 250 then
		readPlayer()
	end
end)

noctalia.setUpdateInterval(15000)
findPlayer()

-- safety poll: catches a dead stream or a player that does not signal
function update()
	findPlayer()
end
