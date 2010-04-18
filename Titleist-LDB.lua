local L = setmetatable({}, {__index=function(t,i) return i end})
local function Print(...) print("|cFF33FF99Titleist|r:", ...) end
local debugf = tekDebug and tekDebug:GetFrame("Titleist")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

local availableTitles = {}

local f = CreateFrame("frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")

function f:ADDON_LOADED(event, addon)
	if addon:lower() ~= "titleist" then return end

	LibStub("tekKonfig-AboutPanel").new("Titleist", "Titleist") -- Make first arg nil if no parent config panel
	self:RegisterEvent("KNOWN_TITLES_UPDATE")

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function f:PLAYER_LOGIN()
	self:KNOWN_TITLES_UPDATE()
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function f:KNOWN_TITLES_UPDATE()
	availableTitles = {}
	local numTitles = GetNumTitles()
	for i = 1, numTitles do
		if IsTitleKnown(i) == 1 then
			table.insert(availableTitles, i)
		end
	end
end

local function GetFullTitleName(titleId)
	local title = GetTitleName(titleId)
	if strsub( title, strlen(title) ) == " " then
		return title .. UnitName("player")
	else 
		return UnitName("player") .. title
	end
end

local function SetRandomTitle()
	if #availableTitles == 0 then return end
	local titleId = availableTitles[ math.random(#availableTitles) ]
	Print("Setting title to '" .. GetFullTitleName(titleId) .. "'")
	SetCurrentTitle(titleId)
end

SLASH_TITLEIST1 = "/titleist"
SlashCmdList.TITLEIST = function(msg)
	SetRandomTitle()
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("Titleist") or ldb:NewDataObject("Titleist", {
	type = "launcher", 
	icon = "Interface\\Addons\\Titleist\\Icon"
})

dataobj.OnClick = SlashCmdList.TITLEIST

-- Tooltip stuff

local tooltip
local LibQTip = LibStub('LibQTip-1.0')

dataobj.OnEnter = function(self)
	tooltip = LibQTip:Acquire("TitleistTooltip", 1, "LEFT")
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)

	local headerFont = GameTooltipHeaderText
	headerFont:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	tooltip:SetHeaderFont(headerFont)
	tooltip:SetFont(GameTooltipText)

	tooltip:AddHeader("Titleist")

	local lineNum
	for i = 1,#availableTitles do
		local index = i
		lineNum = tooltip:AddLine(GetFullTitleName(availableTitles[i]))
		tooltip:SetLineScript(lineNum, "OnMouseDown", function(self, button) 
			Print("Setting title to '" .. GetFullTitleName(index) .. "'")
			SetCurrentTitle(index)
		end)
	end

	tooltip:AddLine("|cff00ff00Click to choose a random title.|r")

	tooltip:Show()
end

dataobj.OnLeave = function(self)
end
