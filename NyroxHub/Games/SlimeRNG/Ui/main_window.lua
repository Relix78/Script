-- c:/Users/lukeb/OneDrive/Projects/Original/Scripts/NyroxHub/Games/SlimeRNG/Ui/window_config.lua
local win = getgenv().NyroxWindow

if not win then
    warn("[Nyrox] Window not found for configuration!")
    return
end

local UpdatesTab  = win:CreateTab("Updates", "rbxassetid://6031225831")
local MainTab     = win:CreateTab("Main", "rbxassetid://6031075938")
win:AddTabSeparator("Universal")
local UniversalTab  = win:CreateTab("Universal", "rbxassetid://7706157512")
local SettingsTab = win:CreateTab("Settings", "rbxassetid://18397244060")

-- MAIN TAB CONFIGURATION
MainTab:Section("Farming", "Left")
MainTab:CreateToggle({
    Title = "Start Slime Farming",
    Callback = function() end
})


-- UPDATES TAB
UpdatesTab:Section("Recent Changes", "Left")
UpdatesTab:CreateLog({Text = "+ Added Slime RNG Support"})
UpdatesTab:CreateLog({Text = "= Fixed UI Loading issue"})

-- SETTINGS TAB
SettingsTab:Section("Menu Settings", "Left")
