local addon, private = ...
local mod = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")
local ACD3 = LibStub("AceConfigDialog-3.0")

_G.WQA = mod

local otherEligibleQuests = {
  [45795] = true,  -- Presence of Power, Azsuna invasion
  [44789] = true,  -- Holding the Ramparts, Val'Sharah invasion
  [45572] = true,  -- Holding Our Ground, Highmountain invasion
  [45406] = true,  -- The Storm's Fury, Stormheim invasion
}

function mod:OnInitialize()
  self.pendingGroups = {}
  local defaults = {
    profile = {
      usePopups = {
        joinGroup = true,
        createGroup = true
      },
      doneBehavior = "ask",
      alertComplete = true
    }
  }
	self.db = LibStub("AceDB-3.0"):New("WorldQuestAssistantDB", defaults)
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("WorldQuestAssistant", self.options)

	ACD3:AddToBlizOptions("WorldQuestAssistant", nil, nil, "config")
	ACD3:AddToBlizOptions("WorldQuestAssistant", L["Profiles"], "WorldQuestAssistant", "profiles")

  self:RegisterChatCommand("wqa", "Config")

  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("QUEST_ACCEPTED")
  self:RegisterEvent("QUEST_TURNED_IN")
  self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", "ApplyToGroups")
  self:RegisterEvent("GROUP_ROSTER_UPDATE")

  hooksecurefunc("ObjectiveTracker_Update", function()
    mod.UI:SetupTrackerBlocks()
  end)
end

function mod:Config()
  InterfaceOptionsFrame:Hide()
	ACD3:SetDefaultSize("WorldQuestAssistant", 680, 550)
	ACD3:Open("WorldQuestAssistant")
end

function mod:PLAYER_ENTERING_WORLD()
  local id = self:GetCurrentWorldQuestID()
  if id then
    self:QUEST_ACCEPTED(nil, nil, id)
  end
end

function mod:GROUP_ROSTER_UPDATE()
  if GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0 then
    table.wipe(self.pendingGroups)
    if UnitIsGroupLeader("player") and not IsInRaid() and mod:IsRaidCompatible(self.activeQuestID) then
      ConvertToRaid()
    end
  end
  self.UI:SetupTrackerBlocks()
end

function mod:QUEST_ACCEPTED(event, index, questID)
  if self:IsEligibleQuest(questID) then
    self.activeQuestID = questID
    C_Timer.After(3, function()
      self.UI:SetupTrackerBlocks()
    end)
    if GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) == 0 then
      local info = self:GetQuestInfo(questID)
      if mod.db.profile.usePopups.joinGroup then
        StaticPopupDialogs["WQA_FIND_GROUP"].text = string.format(L["Do you want to find a group for '%s'?"], info.questName)
        StaticPopup_Show("WQA_FIND_GROUP")
      end
    end
  end
end

function mod:IsEligibleQuest(questID)
  if QuestUtils_IsQuestWorldQuest(questID) and GetQuestLogIndexByID(questID) ~= 0 then
    local info = self:GetQuestInfo(questID)
    if info.worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE or
       info.worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION or
       info.worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON then
          return false
    end
    return true
  end

  if otherEligibleQuests[questID] then
    return true
  end

  return false
end

function mod:IsRaidCompatible(questID)
  local info = self:GetQuestInfo(questID)
  if info.rarity == LE_WORLD_QUEST_QUALITY_EPIC then
    return true
  elseif info.rarity == LE_WORLD_QUEST_QUALITY_RARE and info.elite then
    return true
  end
  return false
end

function mod:MaxMembersForQuest()
  if self:IsRaidCompatible(self.activeQuestID) then
    return 40
  else
    return 5
  end
end

function mod:QUEST_TURNED_IN(event, questID, experience, money)
  if QuestUtils_IsQuestWorldQuest(questID) and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0 then
    table.wipe(self.pendingGroups)
    local info = self:GetQuestInfo(questID)

    if mod.db.profile.alertComplete then
      SendChatMessage(L["[WQA] Quest '%s' complete!"]:format(info.questName), "PARTY")
    end
    if mod.db.profile.doneBehavior == "ask" then
      StaticPopup_Show("WQA_LEAVE_GROUP")
    elseif mod.db.profile.doneBehavior == "leave" then
      LeaveParty()
    end
  end
end

function mod:GetCurrentWorldQuestID()
  for i, questID in ipairs(GetTasksTable()) do
    if self:IsEligibleQuest(questID) then
      return questID
    end
  end
  return nil
end

function mod:GetQuestInfo(questID)
  if not questID then return {} end

  local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(questID);
  local tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex
  if QuestUtils_IsQuestWorldQuest(questID) then
    tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex = GetQuestTagInfo(questID)
  end

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

function mod:FindQuestGroups(questID)
  table.wipe(self.pendingGroups)
  self.activeQuestID = questID or self.activeQuestID
  local info = self:GetQuestInfo(self.activeQuestID)
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
    if members < self:MaxMembersForQuest() and name == self.currentQuestInfo.questName then
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
