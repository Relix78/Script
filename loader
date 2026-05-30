repeat wait() until game:IsLoaded()

if not LPH_OBFUSCATED then
	LPH_JIT_MAX = function(...) return ... end
	LPH_NO_VIRTUALIZE = function(f) return f end
	LPH_NO_UPVALUES = function(...) return ... end
	LPH_CRASH = function(...) return ... end
else
	print = function() end
	warn = function() end
end

local cloneref = cloneref or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local Workspace = cloneref(game:GetService("Workspace"))
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

local LocalPlayer = cloneref(Players.LocalPlayer)
local Mouse = cloneref(LocalPlayer:GetMouse())

if (identifyexecutor() == "Wave") then
	getgenv().gethui = function()
		return game:GetService("CoreGui")
	end
end

print("⚠️Detected Executor: " .. identifyexecutor())

local Folder_Configs = {
	Directory = "goonhub",
	Assets = "goonhub/Assets",
	Configs = "goonhub/Configs",
	Datas = "goonhub/Datas",
	Images = "goonhub/Images",
	Themes = "goonhub/Themes"
}

for _, Folder in Folder_Configs do
	if not isfolder(Folder) then
		makefolder(Folder)
	end
end

local GameId = tostring(game.GameId)
local GameConfigFolder = Folder_Configs.Configs .. "/" .. GameId

if not isfolder(GameConfigFolder) then
	makefolder(GameConfigFolder)
end

local GameList = {
	["7326934954"] = { id = "9d3e5f1ab847c260de91f4a72bc8e6d1", devmode = true },  -- 99 Nights in the Forest
	["9073513091"] = { id = "c71a9e4d5f2b8036a1dc97e84b6f23aa", devmode = true },  -- Anime Apocalypse
	["4658598196"] = { id = "5e8c1d7f2ab34960cde4719fa862b3d0", devmode = true },  -- Attack on Titan Revolution
	["9875383684"] = { id = "f2a7c49d81be6035dce91a47b8f26d3e", devmode = true }, -- Be a Brainrot
	["9787206684"] = { id = "1bc8d7e49fa26305d1e7c4ab986f23dd", devmode = true }, -- Be a Lucky Block
	["5130394318"] = { id = "7e4a1d9cb82f6350aef471c9d2b68aa1", devmode = true }, -- Bizarre Lineage
	["994732206"]  = { id = "a4f91c7d2e8b6a53f0d14c9be67231aa", devmode = false }, -- Blox Fruits
	["7018190066"] = { id = "d5f3a7c1e98b4602cf71da84b2e639ff", devmode = true },  -- Dead Rails
	["9363735110"] = { id = "3fa7d1c9e4b86205ad71fc48b26e93cc", devmode = true }, -- Escape Tsunami For Brainrots!
	["3808223175"] = { id = "be47d2a1c8f96305e1da74bc829f6a0d", devmode = true }, -- Jujutsu Infinite
	["66654135"]   = { id = "6c1e9d4ab827f350de471ac98b2f63aa", devmode = false },  -- Murder Mystery 2
	["9186719164"] = { id = "2d7a4c1f9be86035ac71de48b29f61ee", devmode = true },  -- Sailor Piece
	["1511883870"] = { id = "f9c1d7a4be826305de471fa98b2c63dd", devmode = true }, -- Shindo Life
	["7671049560"] = { id = "a7d4c1e9fb826350de14ac78b29f63aa", devmode = true }, -- The Forge
	["245662005"]  = { id = "4c1e7d9ab826f350de471ac98b2f63bc", devmode = true },  -- Jailbreak
	["9792947201"] = { id = "8f3b2c7d1a9e4f60bc2d5a7e18c4d9f1", devmode = false }  -- Slime RNG
}

local GameConfig = GameList[GameId]

if not GameConfig then
	StarterGui:SetCore("SendNotification",{
		Title = "Goon Hub",
		Text = "This game is not supported.",
		Icon = "rbxassetid://135630585467568",
	})
	return
end

if GameConfig.devmode then
	StarterGui:SetCore("SendNotification",{
		Title = "Goon Hub",
		Text = "This game is being updated.",
		Icon = "rbxassetid://135630585467568",
	})
	return
end

local ScriptId = GameConfig.id

if hookfunction and hookmetamethod then
	getgenv().lukas = true
else
	getgenv().lukas = false
end

if IsMobile then
	getgenv().relix = true
else
	getgenv().relix = false
end

local Success, ScriptContent = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/L5ks8/GoonHub/main/Scripts/" .. ScriptId .. "/" .. ScriptId .. ".lua")

if Success then
	local Exec, Error = loadstring(ScriptContent)
	if Exec then
		Exec()
	else
		StarterGui:SetCore("SendNotification", {
			Title = "Goon Hub",
			Text = "Error loading script.",
			Icon = "rbxassetid://135630585467568",
		})
	end
end


