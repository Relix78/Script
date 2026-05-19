local DevMode = {}
local env = (type(getgenv) == "function") and getgenv() or shared
local Import = env.Import
local assets = Import("assets.lua")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- Konfiguration für Entwickler (Hier UserIds eintragen)
local DeveloperIds = {
    [3537243916] = true, -- Beispiel ID (Deine ID hier rein)
    [1] = true          -- Roblox System
}

function DevMode.IsDeveloper()
    return DeveloperIds[Players.LocalPlayer.UserId] or false
end

function DevMode.ShowMaintenanceGui(onLoadUniversal)
    -- Prüfen, ob das assets-Modul verfügbar ist, bevor es verwendet wird
    if not assets or type(assets.CreateWindow) ~= "function" then
        warn("[Nyrox] assets module not available for DevMode.ShowMaintenanceGui! Cannot display GUI.")
        return
    end
    local win = assets.CreateWindow("Maintenance", "Under Development")
    local UpdatesTab = win:CreateTab("Updates")
    local InfoTab = win:CreateTab("Info")

    -- Populate Updates Tab
    UpdatesTab:CreateSection("Updates", {Column = "Left", Droppable = false})
    UpdatesTab:CreateLog({Text = "/ Refactoring core logic"})
    UpdatesTab:CreateLog({Text = "+ Improving detection bypass"})
    UpdatesTab:CreateLog({Text = "+ Porting UI system to DevMode"})


    UpdatesTab:CreateSection("Universal Script", {Column = "Right", Droppable = false})
    UpdatesTab:CreateParagraph({Text = "The script for this game is currently under development.", Column = "Right"})
    UpdatesTab:CreateButton({
        Title = "Load Universal Script",
        Callback = onLoadUniversal,
        Column = "Right",
    })

    -- Populate Info Tab
    InfoTab:CreateSection("Why Maintenance?", {Column = "Left", Droppable = false})
    InfoTab:CreateParagraph({Text = "We are currently updating."})

    InfoTab:CreateSection("Stay Updated", {Column = "Right", Droppable = false})
    InfoTab:CreateButton({
        Title = "Join Discord Server",
        Column = "Right",
        Color = Color3.fromRGB(88, 101, 242),
        Callback = function()
            if setclipboard then setclipboard("https://discord.gg/solixhub") end
        end
    })

    win:SetTab("Updates")
end

return DevMode
