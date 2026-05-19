local Config = {}
local HttpService = game:GetService("HttpService")
local env = (type(getgenv) == "function") and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Der gewünschte Pfad ist: localappdata / Xeno / workspace / NyroxHub / Config / [PlayerName] / autoload.json
local SAVE_DIR = "NyroxHub/Config/" .. (LocalPlayer and LocalPlayer.Name or "ServerSide")
local SAVE_FILE = SAVE_DIR .. "/autoload.json"

-- Global table to store all toggle states
env.NyroxToggleStates = env.NyroxToggleStates or {}

function Config.loadConfig()
    local loadedData = {}
    pcall(function()
        if isfile and isfile(SAVE_FILE) then
            local content = readfile(SAVE_FILE)
            loadedData = HttpService:JSONDecode(content)
        end
    end)
    return loadedData
end

function Config.saveConfig()
    pcall(function()
        -- Ensure the directory exists
        local folders = {
            "NyroxHub",
            "NyroxHub/Config",
            SAVE_DIR}
        for _, folder in ipairs(folders) do
            if makefolder and isfolder and not isfolder(folder) then makefolder(folder) end
        end
        local jsonString = HttpService:JSONEncode(env.NyroxToggleStates)
        if writefile then writefile(SAVE_FILE, jsonString) end
    end)
end

function Config.initToggleStates()
    -- Set default values for all toggles. These will be overridden by loaded config.
    local defaultToggleStates = {
        ["Enable ESP"] = false,
        ["Box ESP"] = true,
        ["Skeleton ESP"] = true,
        ["Health ESP"] = true,
        ["Chams (Highlight)"] = true,
        ["Tracers"] = true,
        ["Self ESP"] = false,
        ["Enable WalkSpeed"] = false,
        ["Fly"] = false,
        ["Infinite Jump"] = false,
        ["Noclip"] = true,
        ["Teleport to Loop (Follow)"] = false,
        ["Click to Teleport"] = false,
        -- Slider Defaults
        ["Walk Speed"] = 16,
        ["Fly Speed"] = 16,
        ["Jump Height"] = 50,
        ["Enable Jump Height"] = false,
        ["Farm Distance"] = 15,
    }

    -- Initialize env.NyroxToggleStates with defaults
    for key, value in pairs(defaultToggleStates) do
        env.NyroxToggleStates[key] = value
    end

    -- Load saved states and override defaults in NyroxToggleStates
    local loadedStates = Config.loadConfig()
    for key, value in pairs(loadedStates) do
        env.NyroxToggleStates[key] = value
    end

    -- Apply initial states from NyroxToggleStates to corresponding environment variables
    env.EspEnabled = env.NyroxToggleStates["Enable ESP"]
    env.BoxEnabled = env.NyroxToggleStates["Box ESP"]
    env.SkeletonEnabled = env.NyroxToggleStates["Skeleton ESP"]
    env.HealthEnabled = env.NyroxToggleStates["Health ESP"]
    env.HighlightEnabled = env.NyroxToggleStates["Chams (Highlight)"]
    env.TracersEnabled = env.NyroxToggleStates["Tracers"]
    env.SelfEspEnabled = env.NyroxToggleStates["Self ESP"]
    env.WalkSpeedEnabled = env.NyroxToggleStates["Enable WalkSpeed"]
    env.FlyEnabled = env.NyroxToggleStates["Fly"]
    env.InfiniteJumpEnabled = env.NyroxToggleStates["Infinite Jump"]
    env.JumpHeightEnabled = env.NyroxToggleStates["Enable Jump Height"]
    env.NoclipEnabled = env.NyroxToggleStates["Noclip"]
    env.FlyToLoopEnabled = env.NyroxToggleStates["Teleport to Loop (Follow)"]
    env.ClickToTeleport = env.NyroxToggleStates["Click to Teleport"]
    env.WalkSpeed = env.NyroxToggleStates["Walk Speed"]
    env.FlySpeed = env.NyroxToggleStates["Fly Speed"]
    env.JumpPower = env.NyroxToggleStates["Jump Height"]

    -- Initialize other non-toggle variables with defaults
    env.TeleportTarget = nil
    env.TriggerTeleport = false
end

return Config