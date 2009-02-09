--[[
Titleist/Titleist.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

-- Change this if you don't like the delay
local delay = 300 --seconds

local availableTitles = {}

local function Print(...) 
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", "|cFF33FF99Titleist|r:", ...)) 
end

local debugf = tekDebug and tekDebug:GetFrame("Titleist")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end

local function ChangeTitle()
	local i = math.random(#availableTitles)

	Print("Setting title to '" .. GetTitleName(availableTitles[i]) .. "'")
	SetCurrentTitle(i)
end

local total = 0
local function OnUpdate(self,elapsed)
	total = total + elapsed
	if total >= delay then
		ChangeTitle()
		total = 0
	end
end

local f = CreateFrame("Frame")

function f:KNOWN_TITLES_UPDATE()
	availableTitles = {}
	local numTitles = GetNumTitles();
	for i = 1, numTitles do
		if IsTitleKnown(i) then
			table.insert(availableTitles, i)
			Debug( "Known title: " .. tostring(i) .. " - " .. GetTitleName(i) )
		end
	end

end

function f:PLAYER_LOGIN()
	LibStub("tekKonfig-AboutPanel").new(nil, "Titleist")

	self:KNOWN_TITLES_UPDATE()
	ChangeTitle()
end

f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
f:SetScript("OnUpdate", OnUpdate)
f:RegisterEvent("KNOWN_TITLES_UPDATE")
if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end

