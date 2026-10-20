--!nonstrict
-- Launcher provider: `/hl` lists the homelab services (with their health), and they also
-- show up in the global search. Activating one opens it in the browser.

local function services()
	local raw = noctalia.state.get("homelab")
	local data = raw and noctalia.json.decode(raw)
	if data and data.services and #data.services > 0 then
		return data.services
	end
	-- before the first poll: straight from the config, health unknown
	local config = noctalia.json.decode(noctalia.readFile("homelab.json") or "{}") or {}
	return config.services or {}
end

function onQuery(text)
	local results = {}
	for _, s in services() do
		local score = text == "" and 1 or noctalia.fuzzyScore(text, `{s.name} {s.about or ""}`)
		if score then
			local health = s.up == nil and "" or (s.up and ` · {s.latency} ms` or " · caído")
			table.insert(results, {
				id = s.url,
				title = s.name,
				subtitle = `{s.about or "homelab"}{health}`,
				glyph = s.glyph or "world",
				badge = s.up == false and "caído" or nil,
				score = score,
			})
		end
	end
	launcher.setResults(text, results)
end

function onActivate(id)
	local address = id:match("^tcp://(.+)$")
	if address then
		noctalia.copyToClipboard(address, "text/plain")
		noctalia.notify("Dirección copiada", address)
	else
		noctalia.runAsync({ "xdg-open", id })
	end
end
