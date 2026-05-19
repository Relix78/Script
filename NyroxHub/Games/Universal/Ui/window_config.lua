-- c:/Users/lukeb/OneDrive/Projects/Original/Scripts/NyroxHub/Games/Universal/Ui/window_config.lua
local win = getgenv().NyroxWindow

local Import = getgenv().Import
if not win then
    warn("[Nyrox] Window not found for configuration!")
    return
end

local UpdatesTab  = win:CreateTab("Updates", "rbxassetid://6031225831")
local MainTab     = win:CreateTab("Main", "rbxassetid://6031075938")
win:AddTabSeparator("Universal")
local SettingsTab = win:CreateTab("Settings", "rbxassetid://18397244060")
local MiscTab     = win:CreateTab("Misc", "rbxassetid://7733964719")

-- UPDATES TAB CONFIGURATION
local setupUpdates = Import("Games/Universal/Tabs/Updates/Update.lua")
if setupUpdates then
    setupUpdates(UpdatesTab)
end

-- MAIN TAB CONFIGURATION
MainTab:Section("Esp", "Left")
MainTab:CreateToggle({
    Title = "Enable ESP",
    Default = false,
    Callback = function(state) getgenv().EspEnabled = state end
})
MainTab:CreateToggle({
    Title = "Box ESP",
    Default = true,
    Callback = function(state) getgenv().BoxEnabled = state end
})
MainTab:CreateToggle({
    Title = "Skeleton ESP",
    Default = true,
    Callback = function(state) getgenv().SkeletonEnabled = state end
})
MainTab:CreateToggle({
    Title = "Health ESP",
    Default = true,
    Callback = function(state) getgenv().HealthEnabled = state end
})
MainTab:CreateToggle({
    Title = "Chams (Highlight)",
    Default = true,
    Callback = function(state) getgenv().HighlightEnabled = state end
})
MainTab:CreateToggle({
    Title = "Tracers",
    Default = true,
    Callback = function(state) getgenv().TracersEnabled = state end
})
MainTab:CreateToggle({
    Title = "Self ESP",
    Default = false,
    Callback = function(state) getgenv().SelfEspEnabled = state end
})

MainTab:Section("Teleport", "Right")
MainTab:CreateToggle({
    Title = "Enable WalkSpeed",
    Column = "Right",
    Callback = function(state) getgenv().WalkSpeedEnabled = state end
})
MainTab:CreateSliderWithBox({
    Title = "Walk Speed",
    Column = "Right",
    Min = 16,
    Max = 500,
    Default = 16,
    Callback = function(value) getgenv().WalkSpeed = value end
})
MainTab:CreateToggle({
    Title = "Fly",
    Column = "Right",
    Callback = function(state) getgenv().FlyEnabled = state end
})
MainTab:CreateToggle({
    Title = "Infinite Jump",
    Column = "Right",
    Callback = function(state) getgenv().InfiniteJumpEnabled = state end
})
MainTab:CreateSliderWithBox({
    Title = "Fly Speed",
    Column = "Right",
    Min = 16, Max = 1000, Default = 16,
    Callback = function(v) getgenv().FlySpeed = v end
})
MainTab:CreateSliderWithBox({
    Title = "Jump Height",
    Column = "Right",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(v) getgenv().JumpPower = v end
})
MainTab:CreateToggle({
    Title = "Enable Jump Height",
    Column = "Right",
    Callback = function(state) getgenv().JumpHeightEnabled = state end
})
MainTab:CreateToggle({
    Title = "Noclip",
    Column = "Right",
    Default = true,
    Callback = function(state) getgenv().NoclipEnabled = state end
})
MainTab:CreateToggle({
    Title = "Click to Teleport",
    Column = "Right",
    Callback = function(state) getgenv().ClickToTeleport = state end
})
getgenv().PlayerDropdown = MainTab:CreateDropdown({
    Title = "Select Player",
    Column = "Right",
    Options = {},
    Callback = function(name) getgenv().TeleportTarget = game.Players:FindFirstChild(name) end
})
MainTab:CreateButton({
    Title = "Teleport to Player Once",
    Column = "Right",
    Callback = function() getgenv().TriggerTeleport = true end
})
MainTab:CreateToggle({
    Title = "Follow Player",
    Column = "Right",
    Callback = function(state) getgenv().FlyToLoopEnabled = state end
})

-- SETTINGS TAB CONFIGURATION
SettingsTab:Section("Menu Settings", "Left")
SettingsTab:CreateButton({
    Title = "Unload Script",
    Callback = function() getgenv().NyroxRunning = false end
})

-- MISC TAB CONFIGURATION
MiscTab:Section("Server", "Left")
MiscTab:CreateButton({
    Title = "Server Hop",
    Callback = function()
        local x = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _,v in pairs(x.data) do
            if v.playing < v.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
            end
        end
    end
})
MiscTab:CreateButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

-- Lade die ESP Logik
getgenv().Import("Games/Universal/Tabs/Main/Esp/Esp.lua")
-- Lade die Teleport/Fly Logik
getgenv().Import("Games/Universal/Tabs/Main/Teleport/teleport.lua")