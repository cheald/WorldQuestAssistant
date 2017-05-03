local addon, private = ...
local mod = LibStub("AceAddon-3.0"):NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")
local ACD3 = LibStub("AceConfigDialog-3.0")
local LRI = LibStub("LibRealmInfo")

_G.WQA = mod

local automation = {
  lastTime = 0,
  hasSearched = false,
  didAutomatedSearch = false,
  questComplete = false
}
local homeRealms = {}

function mod:OnInitialize()
  self.pendingGroups = {}
  mod.QuestDB = mod.QuestDB or {Eligible = {}, Blacklist = {}, Raid = {}}

  local defaults = {
    profile = {
      usePopups = {
        joinGroup = true,
        createGroup = true
      },
      doneBehavior = "ask",
      leaveDelay = 10,
      alertComplete = true,
      joinPVP = true,
      preferHome = true,
      filters = {
        petBattles = false,
        tradeskills = false,
        pvp = true,
        nonElite = true
      }
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
  self:RegisterEvent("GROUP_ROSTER_UPDATE")
  self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", "FilterGroups")

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
  local realmType = select(4, LRI:GetRealmInfoByUnit("player"))
  mod.homeRealmType = (realmType or ""):match("PVP") and "PVP" or "PVE"
  for i, realm in ipairs(GetAutoCompleteRealms()) do
    homeRealms[realm] = true
  end

  local id = self:GetCurrentWorldQuestID()
  if id then
    self:QUEST_ACCEPTED(nil, nil, id)
  end
end

function mod:GROUP_ROSTER_UPDATE()
  if self:IsInParty() then
    table.wipe(self.pendingGroups)
    if self.activeQuestID then
      if UnitIsGroupLeader("player") then
        local groupSize = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
        if not IsInRaid() and mod:IsRaidCompatible(self.activeQuestID) and groupSize > 4 then
          ConvertToRaid()
        elseif groupSize < 5 and IsInRaid() then
          ConvertToParty()
        end
      end
      self:TurnOffRaidConvertWarning()
    end
  else
    mod:ResetAutomation()
    mod:AbortPartyLeave()
    StaticPopup_Hide("WQA_LEAVE_GROUP")
  end
  self.UI:SetupTrackerBlocks()
end

function mod:AbortPartyLeave(notice)
  if mod.leaveTimer then
    mod.leaveTimer:Cancel()
    mod.leaveTimer = nil
    if notice then
      self:Print(L["Will not automatically leave this group"])
    end
  end
end

function mod:IsInParty()
  return GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0
end

function mod:QUEST_ACCEPTED(event, index, questID)
  if self:IsEligibleQuest(questID) then
    self.activeQuestID = questID
    self:ResetAutomation()
    C_Timer.After(3, function()
      self.UI:SetupTrackerBlocks()
    end)
    if not mod:IsInParty() and not mod:IsInOtherQueues() then
      local info = self:GetQuestInfo(questID)
      if mod.db.profile.usePopups.joinGroup then
        C_Timer.After(1.5, function()
          StaticPopupDialogs["WQA_FIND_GROUP"].text = string.format(L["Do you want to find a group for '%s'?"], info.questName)
          StaticPopupDialogs["WQA_FIND_GROUP"].OnAccept = function()
            mod:FindQuestGroups(questID)
          end
          StaticPopup_Show("WQA_FIND_GROUP")
        end)
      end
    end
  end
end

function mod:IsInOtherQueues()
  for i = 1, _G.NUM_LE_LFG_CATEGORYS do
    local mode, submode = GetLFGMode(i)
    if mode == "queued" then
      return true
    end
  end
  return false
end

function mod:IsEligibleQuest(questID, skipLogCheck)
  if QuestUtils_IsQuestWorldQuest(questID) and (GetQuestLogIndexByID(questID) ~= 0 or skipLogCheck) then
    local info = self:GetQuestInfo(questID)
    if (info.worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE and not mod.db.profile.filters.petBattles) or
       (info.worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and not mod.db.profile.filters.tradeskills) or
       (info.worldQuestType == LE_QUEST_TAG_TYPE_PVP and not mod.db.profile.filters.pvp) or
       (not info.elite and not mod.db.profile.filters.nonElite) or
       info.worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON then
          return false
    end
    if mod.QuestDB.Blacklist[questID] then
      return false
    end
    return true
  end

  if mod.QuestDB.Eligible[questID] then
    return true
  end

  return false
end

function mod:IsRaidCompatible(questID)
  local info = self:GetQuestInfo(questID)
  if info.rarity == LE_WORLD_QUEST_QUALITY_EPIC then
    return true
  elseif mod.QuestDB.Raid[questID] then
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
    automation.questComplete = true

    if mod.db.profile.alertComplete then
      local questName = self.currentQuestInfo and self.currentQuestInfo.questName or self:GetQuestInfo(questID).questName
      SendChatMessage(L["[WQA] Quest '%s' complete!"]:format(questName), IsInRaid() and "RAID" or "PARTY")
    end
    if mod.db.profile.doneBehavior == "ask" then
      StaticPopup_Show("WQA_LEAVE_GROUP")
    elseif mod.db.profile.doneBehavior == "leave" then
      mod.leaveTimer = C_Timer.NewTimer(mod.db.profile.leaveDelay or 0, function()
        mod:MaybeLeaveParty()
      end)
      if (mod.db.profile.leaveDelay or 0) > 0 then
        mod:Print(L["Leaving group in %s seconds - grab your loot!"]:format(mod.db.profile.leaveDelay))
      end
    end
    table.wipe(self.pendingGroups)
    self.activeQuestID = nil
  end
end

function mod:MaybeLeaveParty()
  if IsInInstance() then
    return
  end
  LeaveParty()
end

function mod:GetCurrentWorldQuestID()
  for i, questID in ipairs(GetTasksTable()) do
    if self:IsEligibleQuest(questID) then
      return questID
    end
  end

  for i, module in ipairs(ObjectiveTrackerFrame.MODULES) do
    for name, block in pairs(module.usedBlocks) do
      if self:IsEligibleQuest(block.id) then
        return block.id
      end
    end
  end

  return nil
end

function mod:GetQuestInfo(questID)
  if not questID then return {} end

  local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(questID)
  local tagID, tagName, worldQuestType, rarity, elite, tradeskillLineIndex
  questName = questName or QuestUtils_GetQuestName(questID)
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


function mod:CreateQuestGroup(questID)
  StaticPopup_Hide("WQA_FIND_GROUP")
  StaticPopup_Hide("WQA_NEW_GROUP")
  local info = self:GetQuestInfo(questID or self.activeQuestID)
  self.currentQuestInfo = info
  _G.C_LFGList.CreateListing(info.activityID, "", 0, 0, "", string.format("Created by World Quest Assistant #WQ:%s#%s#", self.activeQuestID, self.homeRealmType), true, false, info.questID)
  self:TurnOffRaidConvertWarning()
end

function mod:TurnOffRaidConvertWarning()
  LFGListFrame.displayedAutoAcceptConvert = true
end

do
  local requestedGroupsViaWQA = false
  local skipWorldQuestCheck = false

  function mod:FindQuestGroups(questID, skipWQCheck)
    StaticPopup_Hide("WQA_FIND_GROUP")
    StaticPopup_Hide("WQA_NEW_GROUP")
    table.wipe(self.pendingGroups)
    self.activeQuestID = questID or self.activeQuestID
    local info = self:GetQuestInfo(self.activeQuestID)
    self.currentQuestInfo = info
    skipWorldQuestCheck = skipWQCheck
    requestedGroupsViaWQA = true
    C_LFGList.Search(1, info.questName, 0, 4, {})
  end

  function mod:FilterGroups()
    local searchCount, searchResults = C_LFGList.GetSearchResults()
    if not ((skipWorldQuestCheck or self:GetCurrentWorldQuestID()) and requestedGroupsViaWQA) then
      return
    end
    requestedGroupsViaWQA = false
    skipWorldQuestCheck = false

    local realmInfo = {}
    for i, result in ipairs(searchResults) do
      local id, _, name, description, _, _, _, _, _, _, _, _, author, members, autoinv = C_LFGList.GetSearchResultInfo(result)
      local leader, realm = strsplit("-", author or "Unknown", 2)
      local canJoin = mod.db.profile.joinPVP

      if not canJoin then
        if self.currentQuestInfo.worldQuestType == LE_QUEST_TAG_TYPE_PVP then
          canJoin = true
        elseif realm then
          local realmType = select(4, LRI:GetRealmInfo(realm))
          canJoin = not (realmType == "PVP" or realmType == "RPPVP")
        elseif description:match("#PVE#") then
          canJoin = true
        end
      end
      if members < self:MaxMembersForQuest() and name == self.currentQuestInfo.questName and canJoin then
        tinsert(self.pendingGroups, result)
        realmInfo[result] = {members = members, realm = realm, autoinv = false}
      end
    end

    table.sort(self.pendingGroups, function(a, b)
      if mod.db.profile.preferHome and homeRealms[realmInfo[b].realm] and not homeRealms[realmInfo[a].realm] then
        return true
      elseif realmInfo[b].autoinv and not realmInfo[a].autoinv then
        return true
      else
        return realmInfo[b].members > realmInfo[a].members
      end
    end)

    local binding = GetBindingKey("WQA_AUTOMATE")
    mod:Print(L["Found %s open groups (%s total). %s"]:format(
      #self.pendingGroups,
      #searchResults,
      #self.pendingGroups > 0 and binding and L["Press %s to join a group."]:format(GetBindingKey("WQA_AUTOMATE")) or ""
    ))

    if #self.pendingGroups == 0 then
      if mod.db.profile.usePopups.createGroup and not automation.didAutomatedSearch then
        StaticPopup_Show("WQA_NEW_GROUP")
      end
    else
      mod.UI:SetupTrackerBlocks()
    end

    automation.didAutomatedSearch = false
  end
end

function mod:JoinNextGroup(questID)
  local spec = GetSpecializationRole(GetSpecialization())
  local result = tremove(mod.pendingGroups)
  if result then
    local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, author, members, autoinv = C_LFGList.GetSearchResultInfo(result)
    if members and members < mod:MaxMembersForQuest() and not isDelisted then
      self:Debug("Applied to", comment, author)
      C_LFGList.ApplyToGroup(result, "WorldQuestAssistantUser-" .. tostring(questID), spec == "TANK", spec == "HEALER", spec == "DAMAGER")
    end
  end
  mod.UI:SetupTrackerBlocks()
end

function mod:ResetAutomation()
  automation.hasSearched = false
  automation.didAutomatedSearch = false
  automation.lastTime = 0
end

function mod:Automate()
  if mod:IsInParty() then
    if automation.questComplete then
      LeaveParty()
    end
  elseif LFGListInviteDialog:IsVisible() then
    LFGListInviteDialog.AcceptButton:Click()
  elseif self.activeQuestID and #self.pendingGroups == 0 then
    local wantsNewGroup = GetTime() - automation.lastTime < 3
    if automation.hasSearched and wantsNewGroup then
      self:Print(L["Automate: No groups found, creating a new one"])
      self:CreateQuestGroup(self.activeQuestID)
    else
      automation.didAutomatedSearch = true
      automation.hasSearched = true
      self:FindQuestGroups(self.activeQuestID)
    end
  elseif #self.pendingGroups > 0 then
    self:Print(L["Automate: Joining next group"])
    mod:JoinNextGroup(self.activeQuestID)
  end
  automation.questComplete = false
  automation.lastTime = GetTime()
end

function mod:Debug(...)
  if self.debug then
    self:Print(...)
  end
end
