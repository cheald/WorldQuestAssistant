local addon, private = ...
local mod = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")
_G.WQA = mod

function mod:OnInitialize()
  self.pendingGroups = {}

  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("QUEST_ACCEPTED")
  self:RegisterEvent("QUEST_TURNED_IN")
  self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", "ApplyToGroups")
  self:RegisterEvent("GROUP_ROSTER_UPDATE")

  hooksecurefunc("ObjectiveTracker_Update", function()
    mod.UI:SetupTrackerBlocks()
  end)
end

function mod:PLAYER_ENTERING_WORLD()
  local id = self:GetCurrentWorldQuestID()
  if id then
    self:QUEST_ACCEPTED(nil, nil, id)
  end
end

function mod:GROUP_ROSTER_UPDATE()
  self.UI:SetupTrackerBlocks()
end

function mod:QUEST_ACCEPTED(event, index, questID)
  if QuestUtils_IsQuestWorldQuest(questID) then
    self.activeQuestID = questID
    C_Timer.After(3, function()
      self.UI:SetupTrackerBlocks()
    end)
    if GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) == 0 then
      local info = self:GetQuestInfo(questID)
      StaticPopupDialogs["WQA_FIND_GROUP"].text = string.format(L["Do you want to find a group for '%s'?"], info.questName)
      StaticPopup_Show("WQA_FIND_GROUP")
    end
  end
end

function mod:QUEST_TURNED_IN(event, questID, experience, money)
  if QuestUtils_IsQuestWorldQuest(questID) and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0 then
    SendChatMessage(L["[WQA] Quest '%s' complete!"]:format(self.currentQuestInfo.questName), "PARTY")
    StaticPopup_Show("WQA_LEAVE_GROUP")
  end
end

function mod:GetCurrentWorldQuestID()
  for i, questID in ipairs(GetTasksTable()) do
    if QuestUtils_IsQuestWorldQuest(questID) and GetQuestLogIndexByID(questID) ~= 0 then
      return questID
    end
  end
  return nil
end

function mod:GetQuestInfo(questID)
  if not questID then return {} end

  local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(questID);
  if QuestUtils_IsQuestWorldQuest(questID) then
    local tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = GetQuestTagInfo(questID)
    return {
      activityID = activityID,
      categoryID = categoryID,
      filters = filters,
      questName = questName,
      tagID = tagID,
      tagName = tagName,
      worldQuestType = worldQuestType,
      rarity = rarity,
      elite = elite,
      tradeskillLineIndex = tradeskillLineIndex,
      questID = questID
    }
  end
end

function mod:FindQuestGroups(questID)
  local info = self:GetQuestInfo(questID or self.activeQuestID)
  self.currentQuestInfo = info
  C_LFGList.Search(1, info.questName, 0, 4, {})
end

function mod:CreateQuestGroup(questID)
  local info = self:GetQuestInfo(questID or self.activeQuestID)
  self.currentQuestInfo = info
  _G.C_LFGList.CreateListing(info.activityID, "", 0, 0, "", "WorldQuestAssistant QID#" .. self.activeQuestID, true, false, info.questID)
  LFGListFrame.displayedAutoAcceptConvert = true -- turn off the auto-convert to raid warning
end

function mod:ApplyToGroups()
  local searchCount, searchResults = C_LFGList.GetSearchResults()
  local applications = 0

  for i, result in ipairs(searchResults) do
    local id, _, name, description, _, ilvl, _, _, _, _, _, _, author, members, autoinv = C_LFGList.GetSearchResultInfo(result)
    if members < 5 and name == self.currentQuestInfo.questName then
      tinsert(self.pendingGroups, result)
    end
  end

  if #self.pendingGroups == 0 then
    self:Print("No acceptable groups found.")
    StaticPopup_Show("WQA_NEW_GROUP")
  else
    mod.UI:SetupTrackerBlocks()
  end
end
