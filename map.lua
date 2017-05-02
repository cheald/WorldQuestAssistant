local addon, private = ...
local WQA = LibStub("AceAddon-3.0"):GetAddon(addon)
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")
local mod = WQA:NewModule("Map Buttons", "AceEvent-3.0", "AceHook-3.0")

function mod:OnInitialize()
  local lastWorldMapID = GetCurrentMapAreaID()

  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("WORLD_MAP_UPDATE", function()
    if GetCurrentMapAreaID() ~= lastWorldMapID then
      WQA.UI:ReleaseStaleMapButtons()
    end
    lastWorldMapID = GetCurrentMapAreaID()
  end)

  hooksecurefunc("WorldMap_UpdateQuestBonusObjectives", function()
    WQA.UI:ReleaseStaleMapButtons()
  end)

  hooksecurefunc("TaskPOI_OnEnter", function(self)
    if self.worldQuest and WQA:IsEligibleQuest(self.questID, true) and mod:IsInSameZone() then
      WorldMapTooltip:AddLine(L["Middle-click to find a group for this quest"])
      WorldMapTooltip:Show()
    end
  end)
end

function mod:IsInSameZone()
  local mapZone = GetMapInfo()
  local playerZone = GetRealZoneText()
  return mapZone == playerZone
end

function mod:PLAYER_ENTERING_WORLD()
  self:HookWorldQuestTracker()
  self:HookBaseUIPOITracker()
end

function mod:HookBaseUIPOITracker()
  hooksecurefunc("WorldMap_GetOrCreateTaskPOI", function(i)
    local button = _G["WorldMapFrameTaskPOI" .. i]
    button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "RightButtonUp")

    if not self:IsHooked(button, "OnClick") then
      self:RawHookScript(button, "OnClick", "ClickWQ")
    end
  end)
end

function mod:HookWorldQuestTracker()
  if _G.WorldQuestTrackerAddon then
    self:RawHook(WorldQuestTrackerAddon, "CreateZoneWidget", function(...)
      local button = self.hooks[WorldQuestTrackerAddon].CreateZoneWidget(...)
      if not self:IsHooked(button, "OnClick") then
        self:RawHookScript(button, "OnClick", "ClickWQ")
      end
      return button
    end)
  end
end

function mod:ClickWQ(poiButton, mouseButton, ...)
  if mouseButton == "MiddleButton" and mod:IsInSameZone() then
    if WQA:IsEligibleQuest(tonumber(poiButton.questID), true) then
      if WQA.UI:IsActiveMapButton(poiButton) then
        WQA.UI:SetMapButton(nil)
      else
        WQA:FindQuestGroups(poiButton.questID, true)
        WQA.UI:SetMapButton(poiButton)
      end
    end
  else
    return self.hooks[poiButton].OnClick(mouseButton, ...)
  end
end
