local mod = _G.WQA
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")
mod.UI = {}

BINDING_HEADER_WQAHEAD = L["World Quest Assistant"]
BINDING_NAME_WQA_AUTOMATE = L["Automate group find/join"]

StaticPopupDialogs["WQA_FIND_GROUP"] = {
  text = L["Do you want to find a group for this quest?"],
  button1 = L["Yes"],
  button2 = L["No"],
  button3 = L["New group"],
  OnAccept = function()
    mod:FindQuestGroups()
  end,
  OnAlt = function()
    mod:CreateQuestGroup()
  end,
  timeout = 45,
  whileDead = false,
  hideOnEscape = true,
  preferredIndex = 3
}

StaticPopupDialogs["WQA_NEW_GROUP"] = {
  text = L["No open groups found. Do you want to create a new group?"],
  button1 = L["Yes"],
  button2 = L["No"],
  OnAccept = function()
    mod:CreateQuestGroup()
  end,
  timeout = 30,
  whileDead = false,
  hideOnEscape = true,
  preferredIndex = 3
}

StaticPopupDialogs["WQA_LEAVE_GROUP"] = {
  text = L["Do you want to leave the group?"],
  button1 = L["Yes"],
  button2 = L["No"],
  OnAccept = function()
    LeaveParty()
  end,
  timeout = 45,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3
}

local buttonGroups = {}
local blockAttachments = {}

local function ReleaseButtonGroup(group)
  if group then
    group:Hide()
    group:ClearAllPoints()
    tinsert(buttonGroups, group)
  end
end

local function showTooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
  GameTooltip:Show()
end

local function hideTooltip(self)
  GameTooltip:Hide()
end

local function CreateButtonGroup()
  local ButtonsFrame = CreateFrame("Frame", nil, UIParent)
  local ApplyFrame = CreateFrame("Button", nil, ButtonsFrame, "UIPanelButtonTemplate")
  local SearchFrame = CreateFrame("Button", nil, ButtonsFrame, "UIPanelButtonTemplate")
  local NewGroupFrame = CreateFrame("Button", nil, ButtonsFrame, "UIPanelButtonTemplate")
  local LeavePartyFrame = CreateFrame("Button", nil, ButtonsFrame, "UIPanelCloseButton")
  local SIZE = 25

  local function updateLayout(block)
    local anchor = ObjectiveTrackerFrame:GetLeft() > (UIParent:GetWidth() / 2) and "RIGHT" or "LEFT"
    local otherAnchor = anchor == "LEFT" and "RIGHT" or "LEFT"
    local SPACING = anchor == "RIGHT" and -4 or 4
    local OFFSET = anchor == "RIGHT" and -12 or 12

    SearchFrame:ClearAllPoints()
    SearchFrame:SetPoint("TOP" .. anchor, ButtonsFrame, "TOP" .. anchor)
    NewGroupFrame:ClearAllPoints()
    NewGroupFrame:SetPoint("TOP" .. anchor, SearchFrame, "TOP" .. otherAnchor, SPACING, 0)
    ApplyFrame:ClearAllPoints()
    ApplyFrame:SetPoint("TOP" .. anchor, NewGroupFrame, "TOP" .. otherAnchor, SPACING, 0)
    LeavePartyFrame:ClearAllPoints()
    LeavePartyFrame:SetPoint("TOP" .. anchor, ButtonsFrame, "TOP" .. anchor, 0, 0)
    ButtonsFrame:ClearAllPoints()
    ButtonsFrame:SetPoint("TOP" .. anchor, block, "TOP" .. otherAnchor, OFFSET, 0)
  end

  local f

  f = SearchFrame
  f:SetSize(SIZE, SIZE)
  f.tooltipText = L["Find a new group for this world quest"]
  f:SetNormalTexture("Interface/Icons/inv_darkmoon_eye")
  f:SetScript("OnEnter", showTooltip)
  f:SetScript("OnLeave", hideTooltip)
  f:SetScript("OnClick", function()
    mod:FindQuestGroups(ButtonsFrame.questID)
  end)

  f = NewGroupFrame
  f:SetSize(SIZE, SIZE)
  f:SetNormalTexture("Interface/Icons/inv_misc_groupneedmore")
  f.tooltipText = L["Create a new group"]
  f:SetScript("OnEnter", showTooltip)
  f:SetScript("OnLeave", hideTooltip)
  f:SetScript("OnClick", function()
    mod:CreateQuestGroup(ButtonsFrame.questID)
  end)

  f = ApplyFrame
  f.SetPendingInvites = function(self)
    self:SetEnabled(#mod.pendingGroups > 0)
    self:SetText(#mod.pendingGroups)
    if #mod.pendingGroups == 0 or mod.activeQuestID ~= ButtonsFrame.questID then
      self:Hide()
    else
      self:Show()
    end
  end
  f:SetSize(SIZE, SIZE)
  f:SetNormalTexture("Interface/Tooltips/CHATBUBBLE-BACKGROUND")
  f:SetScript("OnClick", function()
    mod:JoinNextGroup(ButtonsFrame.questID)
  end)
  f.tooltipText = L["Apply to groups for this quest"]
  f:SetScript("OnEnter", showTooltip)
  f:SetScript("OnLeave", hideTooltip)
  f.glow = CreateFrame("Frame", nil, ApplyFrame, "ActionBarButtonSpellActivationAlert")

  f.glow.animIn:Stop()
  local frameWidth, frameHeight = f:GetSize()
  f.glow:SetSize(frameWidth * 1.4, frameHeight * 1.4)
	f.glow:SetPoint("TOPLEFT", ApplyFrame, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2);
	f.glow:SetPoint("BOTTOMRIGHT", ApplyFrame, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2);
  f.glow.animIn:Play()

  _G.app = f

  f = LeavePartyFrame
  f:Hide()
  f:SetSize(30, 30)
  f:SetScript("OnClick", function()
    LeaveParty()
  end)
  f.tooltipText = L["Leave Party"]
  f:SetScript("OnEnter", showTooltip)
  f:SetScript("OnLeave", hideTooltip)

  f = ButtonsFrame
  f:SetSize(1, 1)
  f:Hide()

  ButtonsFrame.Attach = function(self, block)
    if block and block.id then
      f.questID = block.id
      blockAttachments[block.id] = f
      f:Show()
      updateLayout(block)
    else
      f:Hide()
    end
  end

  ButtonsFrame.Update = function(self)
    ApplyFrame:SetPendingInvites()
    if mod:IsInParty() then
      ApplyFrame:Hide()
      NewGroupFrame:Hide()
      SearchFrame:Hide()
      LeavePartyFrame:Show()
    else
      NewGroupFrame:Show()
      SearchFrame:Show()
      LeavePartyFrame:Hide()
    end
  end

  return ButtonsFrame
end

local function GetButtonGroup()
  if #buttonGroups > 0 then
    return tremove(buttonGroups)
  else
    return CreateButtonGroup()
  end
end

function mod.UI:SetSearch()
  for id, attachment in pairs(blockAttachments) do
    attachment:SetSearch()
  end
end

function mod.UI:SetPendingInvites()
  for id, attachment in pairs(blockAttachments) do
    attachment:SetSearch()
  end
end

function mod.UI:ReleaseBlock(block)
  if block and block.id then
    ReleaseButtonGroup(blockAttachments[block.id])
  end
end

function mod.UI:SetupTrackerBlocks()
  local preserved = {}
  mod.UI:GetTrackerBlocks(function(block)
    local group = blockAttachments[block.id] or GetButtonGroup()
    preserved[block.id] = true
    if mod:IsInOtherQueues() then
      group:Hide()
    else
      group:Attach(block)
      group:Update()
    end
  end)

  for id, block in pairs(blockAttachments) do
    if not preserved[id] then
      blockAttachments[id] = nil
      ReleaseButtonGroup(block)
    end
  end
end

function mod.UI:GetTrackerBlocks(callback)
  if not ObjectiveTrackerFrame.MODULES then return end
  for i, module in ipairs(ObjectiveTrackerFrame.MODULES) do
    for name, block in pairs(module.usedBlocks) do
      if mod:IsEligibleQuest(block.id) then
        callback(block)
      end
    end
  end
end
