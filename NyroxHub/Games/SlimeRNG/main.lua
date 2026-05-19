-- c:/Users/lukeb/OneDrive/Projects/Original/Scripts/NyroxHub/Games/SlimeRNG/main.lua
local Import = getgenv().Import

-- 1. Lade die UI Konfiguration
Import("Games/SlimeRNG/Ui/main_window.lua")

-- 2. Hier kommt die Spiellogik hin
print("[Nyrox] SlimeRNG Logic initialized.")

-- Hier könntest du deine Loops starten:
-- task.spawn(function() while _G.Farm do task.wait() ... end end)
