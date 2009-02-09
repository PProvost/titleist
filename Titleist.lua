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
	if #availableTitles == 0 then return end
	local titleId = availableTitles[ math.random(#availableTitles) ]
	Print("Setting title to '" .. GetTitleName(titleId) .. "'")
	SetCurrentTitle(titleId)
end

local total = 0
local function OnUpdate(self,elapsed)
	total = total + elapsed
	if total >= delay then
		ChangeTitle()
		total = 0
	end
end

Titleist = CreateFrame("Frame")

function Titleist:KNOWN_TITLES_UPDATE()
	Debug("KNOWN_TITLES_UPDATE")
	availableTitles = {}
	local numTitles = GetNumTitles()
	for i = 1, numTitles do
		if IsTitleKnown(i) == 1 then
			table.insert(availableTitles, i)
			Debug(tostring(i))
		end
	end

	ChangeTitle()
end

function Titleist:PLAYER_LOGIN()
	Debug("PLAYER_LOGIN")

	LibStub("tekKonfig-AboutPanel").new(nil, "Titleist")
	self:RegisterEvent("KNOWN_TITLES_UPDATE")

	self:KNOWN_TITLES_UPDATE()
end

Titleist:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
Titleist:SetScript("OnUpdate", OnUpdate)
if IsLoggedIn() then Titleist:PLAYER_LOGIN() else Titleist:RegisterEvent("PLAYER_LOGIN") end

