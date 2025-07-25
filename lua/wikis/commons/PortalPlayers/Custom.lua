---
-- @Liquipedia
-- page=Module:PortalPlayers/Custom
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Lua = require('Module:Lua')

local Arguments = Lua.import('Module:Arguments')

local PortalPlayers = Lua.import('Module:PortalPlayers')

local CustomPortalPlayers = {}

---Entry Point. Builds the player portal
---@param frame Frame
---@return Html
function CustomPortalPlayers.run(frame)
	local args = Arguments.getArgs(frame)

	return PortalPlayers(args):create()
end

return CustomPortalPlayers
