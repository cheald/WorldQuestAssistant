local mod = _G.WQA
local L = LibStub("AceLocale-3.0"):GetLocale("WorldQuestAssistant")

local options = {
  type = "group",
  args = {
    config = {
      name = L["Behavior"],
      type = "group",
      args = {
        keybinding = {
          type = "keybinding",
          name = L["Automation Keybind"],
          desc = L["Automation Keybind Help"],
          get = function()
            return GetBindingKey("WQA_AUTOMATE")
          end,
          set = function(info, v)
            local old = GetBindingKey("WQA_AUTOMATE")
            if old then
              SetBinding(old)
            end
            SetBinding(v, "WQA_AUTOMATE")
            SaveBindings(GetCurrentBindingSet())
          end
        },
        onStart = {
          type = "group",
          name = L["Starting Quests"],
          order = 50,
          inline = true,
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
            },
            preferHome = {
              name = L["Prefer groups on home realm"],
              type = "toggle",
              width = "full",
              get = function(info)
                return mod.db.profile.preferHome
              end,
              set = function(info, v)
                mod.db.profile.preferHome = v
              end
            }
          }
        },
        onFinish = {
          type = "group",
          name = L["Finishing Quests"],
          order = 55,
          inline = true,
          args = {
            action = {
              name = L["When a quest is complete"],
              type = "select",
              values = {
                ask = L["Ask to leave the group"],
                leave = L["Automatically leave the group"],
                none = L["Do nothing"]
              },
              order = 105,
              width = "full",
              get = function()
                return mod.db.profile.doneBehavior
              end,
              set = function(info, v)
                mod.db.profile.doneBehavior = v
              end
            },
            leaveDelay = {
              name = L["Seconds to wait before automatically leaving the group"],
              order = 110,
              type = "range",
              min = 0,
              max = 120,
              step = 1,
              bigStep = 5,
              get = function(info)
                return mod.db.profile.leaveDelay
              end,
              set = function(info, v)
                mod.db.profile.leaveDelay = v
              end,
              disabled = function()
                return mod.db.profile.doneBehavior ~= "leave"
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
            }
          }
        }
      }
    }
  }
}
mod.options = options
