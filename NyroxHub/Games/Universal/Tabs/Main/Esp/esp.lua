local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Zeichnungs-Container
local Gui = Instance.new("ScreenGui")
Gui.Name = "NyroxESP_Internal"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 1 -- Stellt sicher, dass ESP unter der Haupt-UI liegt
Gui.IgnoreGuiInset = true
local success, _ = pcall(function() Gui.Parent = gethui() or game:GetService("CoreGui") end)
if not success then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local THICKNESS = 1
local BOX_COLOR = Color3.fromRGB(255, 0, 0)
local SKELETON_COLOR = Color3.fromRGB(255, 255, 255)
local HIGHLIGHT_COLOR = Color3.fromRGB(0, 170, 255)
local TRACER_COLOR = Color3.fromRGB(255, 255, 255)

local ESP = {}
local SkeletonParts = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"}, {"Torso","Left Leg"}, {"Torso","Right Leg"},
}

local function CreateLine(parent, color, thickness, z)
    local line = Instance.new("Frame")
    line.Parent = parent
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = color
    line.Visible = false
    line.ZIndex = z
    return line
end

local function CreateOutlinedLine(parent, color)
    return {
        Outline = CreateLine(parent, Color3.new(0, 0, 0), THICKNESS + 2, 4),
        Line = CreateLine(parent, color, THICKNESS, 5)
    }
end

local function DrawLine(obj, from, to)
    local dist = (from - to).Magnitude
    local rot = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
    obj.Outline.Size = UDim2.new(0, dist + 2, 0, THICKNESS + 2)
    obj.Outline.Position = UDim2.new(0, (from.X + to.X)/2, 0, (from.Y + to.Y)/2)
    obj.Outline.Rotation = rot
    obj.Outline.Visible = true
    obj.Line.Size = UDim2.new(0, dist, 0, THICKNESS)
    obj.Line.Position = UDim2.new(0, (from.X + to.X)/2, 0, (from.Y + to.Y)/2)
    obj.Line.Rotation = rot
    obj.Line.Visible = true
end

local function Hide(obj)
    obj.Line.Visible = false
    obj.Outline.Visible = false
end

local function CreateESP(player)
    if ESP[player] then return end
    local Folder = Instance.new("Folder", Gui)
    local Box = {}
    for i = 1, 8 do Box[i] = CreateOutlinedLine(Folder, BOX_COLOR) end
    local Skeleton = {}
    for i = 1, #SkeletonParts do Skeleton[i] = CreateOutlinedLine(Folder, SKELETON_COLOR) end

    local Name = Instance.new("TextLabel", Folder)
    Name.BackgroundTransparency = 1
    Name.Font = Enum.Font.GothamBold
    Name.TextColor3 = Color3.new(1, 1, 1)
    Name.TextStrokeTransparency = 0
    Name.TextSize = 11
    Name.Visible = false

    local Distance = Instance.new("TextLabel", Folder)
    Distance.BackgroundTransparency = 1
    Distance.Font = Enum.Font.GothamBold
    Distance.TextColor3 = Color3.fromRGB(200, 200, 200)
    Distance.TextStrokeTransparency = 0
    Distance.TextStrokeColor3 = Color3.new(0,0,0)
    Distance.TextSize = 9
    Distance.Visible = false
    Distance.ZIndex = 6

    local HealthBG = Instance.new("Frame", Folder)
    HealthBG.BackgroundColor3 = Color3.new(0, 0, 0)
    HealthBG.BorderSizePixel = 0
    HealthBG.Visible = false
    local Health = Instance.new("Frame", HealthBG) -- Moved this line here
    Health.BorderSizePixel = 0
    Health.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Moved this line here

    local Highlight = Instance.new("Highlight", Folder)
    Highlight.FillColor = HIGHLIGHT_COLOR
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    ESP[player] = {
        Folder = Folder, Box = Box, Skeleton = Skeleton,
        Name = Name, Distance = Distance, HealthBG = HealthBG, Health = Health,
        Tracer = CreateOutlinedLine(Folder, TRACER_COLOR), Highlight = Highlight
    }
end

local function RemoveESP(player)
    if ESP[player] then ESP[player].Folder:Destroy() ESP[player] = nil end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

local connection
connection = RunService.RenderStepped:Connect(function()
    if getgenv().NyroxRunning == false then
        connection:Disconnect()
        if Gui then Gui:Destroy() end
        ESP = nil
        return
    end

    for player, esp in pairs(ESP) do
        local allowed = player ~= LocalPlayer or getgenv().SelfEspEnabled
        if not getgenv().EspEnabled or not allowed then
            for _, v in pairs(esp.Box) do Hide(v) end
            for _, v in pairs(esp.Skeleton) do Hide(v) end
            Hide(esp.Tracer)
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBG.Visible = false
            esp.Highlight.Enabled = false
            continue
        end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and root and hum.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            esp.Highlight.Enabled = getgenv().HighlightEnabled
            esp.Highlight.Adornee = char

            if onScreen and rootPos.Z > 0 then
                local scale = 1 / (rootPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                local w, h = 3.8 * scale, 5.2 * scale
                local minX, minY = rootPos.X - (w / 2), rootPos.Y - (h / 2) - (scale * 0.4)
                local maxX, maxY = rootPos.X + (w / 2), rootPos.Y + (h / 2) - (scale * 0.4)

                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if getgenv().BoxEnabled then
                    local cSize = math.clamp(w * 0.25, 6, 15)
                    local b = esp.Box
                    DrawLine(b[1], Vector2.new(minX, minY), Vector2.new(minX + cSize, minY))
                    DrawLine(b[2], Vector2.new(minX, minY), Vector2.new(minX, minY + cSize))
                    DrawLine(b[3], Vector2.new(maxX, minY), Vector2.new(maxX - cSize, minY))
                    DrawLine(b[4], Vector2.new(maxX, minY), Vector2.new(maxX, minY + cSize))
                    DrawLine(b[5], Vector2.new(minX, maxY), Vector2.new(minX + cSize, maxY))
                    DrawLine(b[6], Vector2.new(minX, maxY), Vector2.new(minX, maxY - cSize))
                    DrawLine(b[7], Vector2.new(maxX, maxY), Vector2.new(maxX - cSize, maxY))
                    DrawLine(b[8], Vector2.new(maxX, maxY), Vector2.new(maxX, maxY - cSize))
                else
                    for _, v in pairs(esp.Box) do Hide(v) end
                end

                local dynamicTextSize = math.clamp(math.ceil(0.4 * scale), 10, 16)
                local dynamicDistSize = math.clamp(math.ceil(0.3 * scale), 8, 14)

                esp.Name.Text = player.Name
                esp.Name.TextSize = dynamicTextSize
                esp.Name.Position = UDim2.new(0, rootPos.X - 100, 0, minY - 15)
                esp.Name.Size = UDim2.new(0, 200, 0, 15)
                esp.Name.Visible = true

                esp.Distance.Text = math.floor(dist) .. "m"
                esp.Distance.TextSize = dynamicDistSize
                esp.Distance.Position = UDim2.new(0, rootPos.X - 100, 0, maxY + 2)
                esp.Distance.Size = UDim2.new(0, 200, 0, dynamicDistSize)
                esp.Distance.Visible = true

                if getgenv().HealthEnabled then
                    esp.HealthBG.Position = UDim2.new(0, minX - 6, 0, minY)
                    esp.HealthBG.Size = UDim2.new(0, 2, 0, h)
                    esp.HealthBG.Visible = true
                    local healthScale = hum.Health / hum.MaxHealth
                    esp.Health.Size = UDim2.new(1, 0, 0, h * healthScale)
                    esp.Health.Position = UDim2.new(0, 0, 1, -(h * healthScale))
                else
                    esp.HealthBG.Visible = false
                end

                if getgenv().SkeletonEnabled then
                    for i, bone in pairs(SkeletonParts) do
                        local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                        if p1 and p2 then
                            local v1, v2 = Camera:WorldToViewportPoint(p1.Position), Camera:WorldToViewportPoint(p2.Position)
                            if v1.Z > 0 and v2.Z > 0 then
                                DrawLine(esp.Skeleton[i], Vector2.new(v1.X, v1.Y), Vector2.new(v2.X, v2.Y))
                            else Hide(esp.Skeleton[i]) end
                        else Hide(esp.Skeleton[i]) end
                    end
                else
                    for _, v in pairs(esp.Skeleton) do Hide(v) end
                end

                if getgenv().TracersEnabled then
                    local myChar = LocalPlayer.Character
                    local myHead = myChar and myChar:FindFirstChild("Head")
                    local origin
                    if myHead then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(myHead.Position)
                        origin = headOnScreen and Vector2.new(headPos.X, headPos.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    else
                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    end
                    DrawLine(esp.Tracer, origin, Vector2.new(rootPos.X, rootPos.Y))
                else Hide(esp.Tracer) end
            else
                for _, v in pairs(esp.Box) do Hide(v) end
                for _, v in pairs(esp.Skeleton) do Hide(v) end
                Hide(esp.Tracer)
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBG.Visible = false
            end
        else
            for _, v in pairs(esp.Box) do Hide(v) end
            for _, v in pairs(esp.Skeleton) do Hide(v) end
            Hide(esp.Tracer)
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBG.Visible = false
            esp.Highlight.Enabled = false
        end
    end
end)