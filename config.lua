local mod = _G.WQA
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")

local options = {
  type = "group",
  args = {
    config = {
      name = L["Behavior"],
      type = "group",
      args = {
        join = {
          name = L["Ask to join or start a group when starting a world quest"],
          type = "toggle",
          width = "full",
          get = function()
            return mod.db.profile.usePopups.joinGroup
          end,
          set = function(info, v)
            mod.db.profile.usePopups.joinGroup = v
          end
        },
        createGroup = {
          name = L["Prompt to start a new group if no groups can be found"],
          type = "toggle",
          width = "full",
          get = function()
            return mod.db.profile.usePopups.createGroup
          end,
          set = function(info, v)
            mod.db.profile.usePopups.createGroup = v
          end
        },
        onFinish = {
          name = L["When a quest is complete"],
          type = "select",
          values = {
            ask = L["Ask to leave the group"],
            leave = L["Automatically leave the group"],
            none = L["Do nothing"]
          },
          width = "full",
          get = function()
            return mod.db.profile.doneBehavior
          end,
          set = function(info, v)
            mod.db.profile.doneBehavior = v
          end
        },
        alertDone = {
          name = L["Alert party when quest is complete"],
          type = "toggle",
          width = "full",
          get = function()
            return mod.db.profile.alertComplete
          end,
          set = function(info, v)
            mod.db.profile.alertComplete = v
          end
        },
        joinPVP = {
          name = L["Join groups on PVP realms"],
          type = "toggle",
          width = "full",
          get = function()
            return mod.db.profile.joinPVP
          end,
          set = function(info, v)
            mod.db.profile.joinPVP = v
          end
        }
      }
    }
  }
}
mod.options = options
