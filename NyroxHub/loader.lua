local env = (type(getgenv) == "function") and getgenv() or shared

-- Configuration
-- Make sure the path points to the root of your NyroxHub folder on the server.
local UseGitHub = true -- Auf true setzen, um von GitHub zu laden
local GitHubURL = "https://raw.githubusercontent.com/Relix78/Script/main/NyroxHub/"
local LiveServerURL = "http://127.0.0.1:5500/"

local BaseURL = UseGitHub and GitHubURL or LiveServerURL

-- Initialize global state tables to prevent nil errors
env.NyroxToggleStates = env.NyroxToggleStates or {}
env.NyroxConfig = env.NyroxConfig or nil -- Config will be loaded later, but ensure it's not nil if accessed prematurely
-- Set loading flag (will be set to false in Core if errors occur)
env.NyroxLoading = true

-- The Import function enables modular loading of files from the Live Server.
local function Import(path)
    -- Verhindert doppelte Slashes in der URL
    local cleanPath = path
    if cleanPath:sub(1,1) == "/" then cleanPath = cleanPath:sub(2) end
    
    local requestURL = BaseURL .. cleanPath
    
    local success, content = pcall(function()
        return game:HttpGet(requestURL)
    end)

    if not success then
        warn("[Nyrox] Netzwerkfehler beim Laden von: " .. cleanPath)
        print("[Nyrox] URL: " .. requestURL)
        return nil
    end

    -- Verhindert Syntax-Errors durch HTML-Fehlerseiten oder 404-Meldungen
    if content == "404: Not Found" or content:find("404") == 1 or content:find("<!DOCTYPE html>") then
        warn("[Nyrox] Laden fehlgeschlagen: " .. cleanPath)
        print("[Nyrox] Die URL war: " .. requestURL)
        error("\n[Nyrox ERROR] Datei nicht gefunden!\nHinweis: Prüfe Groß-/Kleinschreibung (z.B. core vs Core) auf GitHub!")
        return nil
    end

    local func, err = loadstring(content)
    if not func then
        warn("[Nyrox] Syntax Fehler in Datei: " .. cleanPath .. "\nFehler: " .. tostring(err))
        print("[Nyrox] Inhalt vom Server (Vorschau): " .. string.sub(content, 1, 100))
        error("[Nyrox] loadstring fehlgeschlagen.")
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