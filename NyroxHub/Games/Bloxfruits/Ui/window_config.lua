-- c:/Users/lukeb/OneDrive/Projects/Original/Scripts/NyroxHub/Games/Bloxfruits/window_config.lua
local win = getgenv().NyroxWindow

if not win then
    warn("[Nyrox] Window not found for configuration!")
    return
end

local UpdatesTab  = win:CreateTab("Updates", "rbxassetid://6031225831")
local MainTab     = win:CreateTab("Main", "rbxassetid://6031075938")
win:AddTabSeparator("Universal")
local SettingsTab = win:CreateTab("Settings", "rbxassetid://18397244060")

-- MAIN TAB CONFIGURATION
MainTab:Section("Script Status", "Left")
MainTab:CreateStatus({
    Title = "Farming Status",
    Status = "Ready",
    Color = Color3.fromRGB(0, 255, 100)
})

MainTab:CreateStatus({
    Title = "Player Position",
    Status = "Sea 1",
    Color = Color3.fromRGB(255, 255, 255)
})

MainTab:Section("Autofarm", "Left")
MainTab:CreateButton({
    Title = "Start Level Farm",
    Callback = function() print("Level Farm gestartet!") end
})

MainTab:CreateSliderWithBox({
    Title = "Farm Distance",
    Min = 1, Max = 50, Default = 15,
    Column = "Left",
    Callback = function(v) print("Distance:", v) end
})

UpdatesTab:Section("Latest Updates", "Left")
UpdatesTab:CreateLog({Text = "+ Moved UI config to window_config.lua"})
UpdatesTab:CreateLog({Text = "/ Refined tab order"})

UpdatesTab:Section("Links", "Right")
UpdatesTab:CreateButton({
    Title = "Copy Discord",
    Column = "Right",
    Color = Color3.fromRGB(88, 101, 242),
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/solixhub") end
    end
})

MainTab:CreateToggle({
    Title = "Auto-Quest",
    Default = true,
    Callback = function(val)
        print("Auto-Quest:", val)
    end
})

MainTab:Section("Combat", "Right")
MainTab:CreateToggle({
    Title = "Kill Aura",
    Callback = function(val)
        print("Kill Aura:", val)
    end
})

SettingsTab:Section("UI Settings", "Left")
SettingsTab:CreateSliderWithBox({
    Title = "WalkSpeed",
    Min = 16, Max = 250, Default = 16,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

-- Hinweis: win:SetTab wird nicht mehr benötigt, da der erste Tab (Main) automatisch startet.