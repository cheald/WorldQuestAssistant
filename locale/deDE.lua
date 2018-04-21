local L = LibStub("AceLocale-3.0"):NewLocale("WorldQuestAssistant", "deDE")
if not L then return end

L["[WQA] Quest '%s' complete!"] = "[WQA] Quest '%s' beendet!"

L["Advanced"] = "Erweitert"
L["Alert party when quest is complete - Description"] = "Wenn eine Quest beendet ist, kann WQA eine freundliche Nachricht an die Gruppe senden, um deine Mitglieder wissen zu lassen, warum du die Gruppe verlässt."
L["Alert party when quest is complete"] = "Benachrichtige Gruppe, wenn die Quest fertig ist"
L["Allow group queueing help"] = "Gestatte WQA, nach Weltquestgruppen zu suchen und ihnen beizutreten, auch wenn du bereits in einer Gruppe bist. Die meisten Leute wollen dies nicht, aber es könnte nützlich sein, falls du Weltquests mit einem Freund machen möchtest"
L["Allow group queueing"] = "Gestatte Anmeldungen als Gruppe"
L["Anti-Leeching"] = "Anti-Leeching"
L["Apply to groups for this quest"] = "Für diese Quest bei Gruppen anmelden"
L["Apply: %s groups"] = "Angemeldet: %s Gruppen"
L["Applying to %s - %s (%s - %s members)"] = "Anmelden für %s - %s (%s - %s Mitglieder)"
L["Ask To Join - Description"] = "Soll WQA dir ein Popup zeigen mit der Frage, ob du beitreten oder selber eine Gruppe öffnen möchtest, wenn du einer Gruppe beitrittst?"
L["Ask to join or start a group when starting a world quest"] = "Frage, ob du einer Gruppe beitreten oder eine öffnen möchtest, wenn du mit einer Weltquest beginnst"
L["Ask to leave the group"] = "Frage, ob du die Gruppe verlassen willst"
L["Auto-kick notice"] = "Automatisch entfernt: %s: %s"
L["Automate group find/join"] = "Automatisch Gruppe finden/beitreten"
L["Automate: Finding groups"] = "Automatisch: Gruppen finden"
L["Automate: Joining next group"] = "Automatisch: Nächster Gruppe beitreten"
L["Automate: No groups found, creating a new one"] = "Automatisch: Keine Gruppen gefunden, eine neue erstellen"
L["Automatically kick members flagged as idle"] = "Automatisches Entfernen von Mitgliedern, die als untätig markiert sind"
L["Automatically leave after a delay"] = "Automatisches Verlassen nach einer gewissen Verzögerung"
L["Automatically leave once you're flying"] = "Automatisches Verlassen, sobald du fliegst"
L["Automatically leave the group"] = "Automatisch die Gruppe verlassen"
L["Automation Keybind Help"] = "Belegt eine Taste, die benutzt werden kann, um Gruppen zu finden, bei Gruppen anzumelden, neue Gruppen zu erstellen und Gruppeneinladungen anzunehmen."
L["Automation Keybind"] = "Automatische Tastenbelegung"
L["Behavior"] = "Verhalten"
L["Cancel group leave help"] = "Belegt eine Taste, die benutzt werden kann, um das automatische Verlassen von Gruppen nach Beendigung einer Quest abzubrechen. Du bleibst in der Gruppe, bis du sie manuell verlässt."
L["Cancel group leave"] = "Abbruch des Verlassens der Gruppe"
L["Create a new group help"] = "Belegt eine Taste, die benutzt werden kann, um eine neue Gruppe für die aktive Weltquest zu erstellen."
L["Create a new group"] = "Erstelle eine neue Gruppe"
L["Credits"] = "Credits"
L["Do nothing"] = "Nichts tun"
L["Do you want to find a group for '%s'?"] = "Möchtest du eine Gruppe für '%s' finden?"
L["Do you want to find a group for this quest?"] = "Möchtest du eine Gruppe für diese Quest finden?"
L["Do you want to leave the group?"] = "Möchtest du die Gruppe verlassen?"
L["Find a new group for this world quest"] = "Finde eine neue Gruppe für diese Weltquest"
L["Find group"] = "Gruppe finden"
L["Finishing Quests"] = "Quests beenden"
L["Flag far-away group members"] = "Markiere weit entfernte Gruppenmitglieder"
L["Flag idling group members"] = "Markiere untätige Gruppenmitglieder"
L["Found %s open groups (%s total). %s"] = "%s offene Gruppen gefunden (%s insgesamt). %s"
L["Join groups on PVP realms - Description"] = "Falls nicht markiert, wird WQA versuchen, den Beitritt in Gruppen von PVP Realms zu vermeiden. Funkioniert (derzeit) nicht immer wie erwartet."
L["Join groups on PVP realms"] = "Trete Gruppen auf PVP Realms bei"
L["Keybind: Kick flagged party members"] = "Tastenbelegung: Entferne markierte Gruppenmitglieder"
L["Keybindings"] = "Tastenbelegungen"
L["Kick flagged group members"] = "Entferne markierte Gruppenmitglieder"
L["Kick keybind help"] = "Entferne alle Gruppenmitglieder, die als nicht zu der Weltquest beitragend markiert wurden."
L["Kick keybind prompt"] = "Drücke %s zum Entfernen von %s."
L["Kick leeching group members"] = "Entferne schmarotzende Gruppenmitglieder"
L["Kick prompt"] = "%s %s"
L["kick_reason_idle_flying"] = "ist zu lange untätig"
L["kick_reason_idle"] = "ist zu lange untätig"
L["kick_reason_oob_and_idle"] = "ist zu weit entfernt und untätig (%s Meter entfernt)"
L["kick_reason_oob"] = "ist zu weit entfernt (%s Meter entfernt)"
L["Kicked member rejoined"] = "Zuvor entferntes Mitglied %s ist der Gruppe erneut beigetreten."
L["Leave Party"] = "Gruppe verlassen"
L["Leaving group in %s seconds - grab your loot!"] = "Verlasse Gruppe in %s Sekunden - plündere deine Beute!"
L["Middle-click or ctrl-right-click to find a group for this quest"] = "Mittelklick oder Strg-Klick, um eine Gruppe für diese Quest zu finden"
L["New group"] = "Neue Gruppe"
L["No open groups found. Do you want to create a new group?"] = "Keine offene Gruppe gefunden. Möchtest du eine neue Gruppe erstellen?"
L["No"] = "Nein"
L["Non-Elite Filter Description"] = "Trete Gruppen für Nicht-Elite Weltquests bei"
L["Non-Elite Quests"] = "Nicht-Elite Quests"
L["Pet Battle Quests"] = "Kampfhaustierquests"
L["Pet Battles Filter Description"] = "Trete Gruppen für Kampfhaustierquests bei"
L["Prefer groups on home realm - Description"] = "Versuche zunächst, Gruppen deines eigenen Realms beizutreten, bevor es bei Gruppen von anderen Realms probiert wird. Dies kann Servertransfer und Phasenverschiebungen vorbeugen, wenn du Gruppen beitrittst oder sie verlässt."
L["Prefer groups on home realm"] = "Bevorzuge Gruppen des eigenen Realms"
L["Press %s to join a group."] = "Drücke %s, um einer Gruppe beizutreten"
L["Profiles"] = "Profile"
L["Prompt me to start a group"] = "Fordere mich auf, eine Gruppe zu starten"
L["Prompt to start a new group - Description"] = "Soll WQA ein Popup mit der Frage zeigen, ob du eine eigene Gruppe öffnen möchtest, falls keine Gruppe gefunden werden kann, nachdem du eine gesucht hast?"
L["Prompt to start a new group if no groups can be found"] = "Fordere mich auf, eine neue Gruppe zu erstellen, falls keine Gruppen gefunden werden können"
L["PVP Filter Description"] = "Trete Gruppen für PVP Weltquests bei"
L["PVP Quests"] = "PVP Quests"
L["Quest Filters"] = "Questfilter"
L["Seconds to wait before automatically leaving the group"] = "Abzuwartende Sekunden, bevor die Gruppe automatisch verlassen wird"
L["sex_1"] = "sie"
L["sex_2"] = "ihn"
L["sex_3"] = "sie"
L["Show tracker buttons help"] = "Zeige die Knöpfe zum Gruppe finden/Gruppe erstellen/Gruppe beitreten neben den Quests in der Questverfolgung. Falls du dies abschaltest, wirst du keine WQA-Interfaceelemente haben, sondern nur Tastenbelegungen"
L["Show tracker buttons"] = "Zeige Interfaceknöpfe"
L["Starting Quests"] = "Quests beginnen"
L["Tradeskill Quests"] = "Berufequests"
L["Tradeskills Filter Description"] = "Trete Gruppen für Berufeweltquests bei"
L["When a quest is complete"] = "Wenn eine Quest fertig ist"
L["Will not automatically leave this group"] = "Diese Gruppe wird nicht automatisch verlassen"
L["World Quest Assistant"] = "World Quest Assistant"
L["Yes"] = "Ja"
