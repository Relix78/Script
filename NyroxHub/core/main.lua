local Core = {}
local env = (type(getgenv) == "function") and getgenv() or shared
local Import = env.Import

local Config  = Import("core/config.lua")
local Games   = Import("core/gamecheck.lua")
local DevMode = Import("core/devmode.lua")
local assets  = Import("assets.lua")

env.NyroxToggleStates = env.NyroxToggleStates or {}
function Core.Init()
    if not Games or not assets then
        return
    end

    local gameInfo = Games.DetectGame()

    if not gameInfo or type(gameInfo) ~= "table" or not gameInfo.Script then
        warn("[Nyrox] Game is not supported! Loading Universal Script ...")
        gameInfo = {
            Name = "Universal",
            DisplayName = "Universal Script",
            Icon = "[U]",
            Script = "Games/Universal/main.lua",
            DevMode = false
        }
    end

    local isDeveloper = (DevMode and type(DevMode.IsDeveloper) == "function") and DevMode.IsDeveloper() or false
    local isUnderMaintenance = gameInfo.DevMode == true

    env.NyroxLoading = false
    env.NyroxRunning = true
    env.NyroxDevMode = isDeveloper
    env.NyroxConfig = Config


    pcall(function()
        if Config and Config.initToggleStates then
            Config.initToggleStates()
        end
    end)

    local function loadScript(info)
        env.NyroxGameInfo = info
        local window = assets.CreateWindow(info.DisplayName, "v1.0")
        env.NyroxWindow = window
        Import(info.Script)
    end

    if isUnderMaintenance and DevMode then
        DevMode.ShowMaintenanceGui(function()
            loadScript({
                Name = "Universal",
                DisplayName = "Universal Script",
                Icon = "[U]",
                Script = "Games/Universal/main.lua",
                DevMode = false
            })
        end)
        return
    end

    loadScript(gameInfo)
end

return Core