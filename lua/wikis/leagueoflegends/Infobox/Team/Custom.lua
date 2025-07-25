---
-- @Liquipedia
-- page=Module:Infobox/Team/Custom
--
-- Please see https://github.com/Liquipedia/Lua-Modules to contribute
--

local Lua = require('Module:Lua')

local Class = Lua.import('Module:Class')
local Logic = Lua.import('Module:Logic')
local RoleOf = Lua.import('Module:RoleOf')
local String = Lua.import('Module:StringUtils')

local OpponentLibraries = Lua.import('Module:OpponentLibraries')
local OpponentDisplay = OpponentLibraries.OpponentDisplay

local Achievements = Lua.import('Module:Infobox/Extension/Achievements')
local Injector = Lua.import('Module:Widget/Injector')
local Region = Lua.import('Module:Region')
local Team = Lua.import('Module:Infobox/Team')

local Widgets = Lua.import('Module:Widget/All')
local Cell = Widgets.Cell
local UpcomingTournaments = Lua.import('Module:Widget/Infobox/UpcomingTournaments')

local REGION_REMAPPINGS = {
	['south america'] = 'latin america',
	['asia-pacific'] = 'pacific',
	['asia'] = 'pacific',
	['taiwan'] = 'pacific',
	['southeast asia'] = 'pacific',
}

---@class LeagueoflegendsInfoboxTeam: InfoboxTeam
local CustomTeam = Class.new(Team)
local CustomInjector = Class.new(Injector)

---@param frame Frame
---@return Html
function CustomTeam.run(frame)
	local team = CustomTeam(frame)
	team:setWidgetInjector(CustomInjector(team))

	-- Automatically load achievements
	team.args.achievements = Achievements.team{noTemplate = true, baseConditions = {
		'[[liquipediatiertype::]]',
		'[[liquipediatier::1]]',
		'[[placement::1]]',
		'[[publishertier::true]]'
	}}

	-- Automatic org people
	team.args.coach = RoleOf.get{role = 'Coach'}
	team.args.manager = RoleOf.get{role = 'Manager'}
	team.args.captain = RoleOf.get{role = 'Captain'}

	return team:createInfobox()
end

---@param region string?
---@return {display: string?, region: string?}
function CustomTeam:createRegion(region)
	if Logic.isEmpty(region) then return {} end

	local regionData = Region.run{region = region} or {}
	local remappedRegion = regionData.region and REGION_REMAPPINGS[(regionData.region or ''):lower()]

	return remappedRegion and self:createRegion(remappedRegion) or regionData
end

---@return Widget
function CustomTeam:createBottomContent()
	return UpcomingTournaments{name = self.name}
end

---@param id string
---@param widgets Widget[]
---@return Widget[]
function CustomInjector:parse(id, widgets)
	local args = self.caller.args
	if id == 'custom' then
		return {
			Cell{name = 'Abbreviation', content = {args.abbreviation}},
			Cell{name = '[[Affiliate_Partnerships|Affiliate]]', content = {
				args.affiliate and OpponentDisplay.InlineTeamContainer{template = args.affiliate, displayType = 'standard'} or nil}}
		}
	end

	return widgets
end

---@param lpdbData table
---@param args table
---@return table
function CustomTeam:addToLpdb(lpdbData, args)
	if String.isNotEmpty(args.league) then
		lpdbData.extradata.competesin = string.upper(args.league)
	end

	return lpdbData
end

---@param args table
---@return string[]
function CustomTeam:getWikiCategories(args)
	local categories = {}

	if String.isNotEmpty(args.league) then
		local division = string.upper(args.league)
		table.insert(categories, division .. ' Teams')
	end

	return categories
end

return CustomTeam
