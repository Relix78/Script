local env = (type(getgenv) == "function") and getgenv() or shared

-- Configuration
-- Make sure the path points to the root of your NyroxHub folder on the server.
local LiveServerURL = "http://127.0.0.1:5500/" 

-- Initialize global state tables to prevent nil errors
env.NyroxToggleStates = env.NyroxToggleStates or {}
env.NyroxConfig = env.NyroxConfig or nil -- Config will be loaded later, but ensure it's not nil if accessed prematurely
-- Set loading flag (will be set to false in Core if errors occur)
env.NyroxLoading = true

-- The Import function enables modular loading of files from the Live Server.
local function Import(path)
    local success, content = pcall(function()
        return game:HttpGet(LiveServerURL .. path)
    end)

    if not success then
        warn("[Nyrox] File could not be loaded from Live Server: " .. path .. " (Check LiveServerURL and server status)")
        print("[Nyrox] Connection Error. Attempted URL: " .. LiveServerURL .. path)
        return nil
    end

    local func, err = loadstring(content)
    if not func then
        error("[Nyrox] Syntax Error in " .. path .. ": " .. err)
    end

    return func()
end

env.Import = Import

-- Ensure gamecheck and devmode are accessible
print("[Nyrox] Initializing Bootstrapper...")

-- Start the Core
local Core = Import("core/main.lua")
if Core and Core.Init then
    local success, err = pcall(function()
        Core.Init()
    end)
    if not success then
        error("[Nyrox] Critical Error during Core Initialization: " .. tostring(err))
    end
end