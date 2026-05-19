local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local flyBV, flyBG
local noclipConnection -- Connection for Noclip Stepped event
local lastNoclipEnabled = false -- Track Noclip state for changes
local lastFlyToLoopEnabled = false -- Track FlyToLoop state for changes

-- FLY LOGIC
local function startFlyLoop()
    local chr = LocalPlayer.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 9e4
    flyBG.Parent = hrp

    task.spawn(function()
        while getgenv().FlyEnabled and getgenv().NyroxRunning and chr and hrp and hrp.Parent do
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end

            flyBV.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * getgenv().FlySpeed) or Vector3.new(0,0,0)
            flyBG.CFrame = camera.CFrame
            RunService.Heartbeat:Wait()
        end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end)
end

-- NOCLIP LOGIC
local function toggleNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Reset CanCollide for all parts of the current character
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.CanCollide then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- RENDER LOOPS
local teleportConnection
teleportConnection = RunService.RenderStepped:Connect(function()
    if not getgenv().NyroxRunning then
        teleportConnection:Disconnect()
        if noclipConnection then noclipConnection:Disconnect() end
        return
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not char or not hum or not hrp then return end

    -- WalkSpeed Logic
    if getgenv().WalkSpeedEnabled then
        hum.WalkSpeed = getgenv().WalkSpeed
    else
        if hum.WalkSpeed ~= 16 then -- Reset to default walkspeed if the toggle is off
            hum.WalkSpeed = 16
        end
    end

    -- JumpPower Logic
    if hum and getgenv().JumpHeightEnabled then
        hum.UseJumpPower = true -- Sicherstellen, dass JumpPower verwendet wird, wenn aktiviert
        if hum.JumpPower ~= getgenv().JumpPower then -- Nur aktualisieren, wenn der Wert sich ändert
            hum.JumpPower = getgenv().JumpPower
        end
    elseif hum and not getgenv().JumpHeightEnabled then
        -- Wenn Jump Height deaktiviert ist, auf Standardwert zurücksetzen
        if hum.JumpPower ~= 50 then -- Standard JumpPower in Roblox ist 50
            hum.JumpPower = 50
        end
    end

    -- Fly Toggle Monitor
    if getgenv().FlyEnabled and not flyBV then
        hum.PlatformStand = true
        startFlyLoop()
    elseif not getgenv().FlyEnabled and flyBV then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    -- Noclip State Monitor
    if getgenv().NoclipEnabled ~= lastNoclipEnabled then
        toggleNoclip(getgenv().NoclipEnabled)
        lastNoclipEnabled = getgenv().NoclipEnabled
    end

    -- Teleport to Loop (Follow) State Monitor
    if getgenv().FlyToLoopEnabled ~= lastFlyToLoopEnabled then
        if not getgenv().FlyToLoopEnabled then -- Just turned off
            if hum.PlatformStand then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        lastFlyToLoopEnabled = getgenv().FlyToLoopEnabled
    end

    -- Teleport Once Logic
    if getgenv().TriggerTeleport then
        getgenv().TriggerTeleport = false
        local targetName = getgenv().TeleportTarget
        local target = type(targetName) == "string" and Players:FindFirstChild(targetName) or targetName
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = target.Character.HumanoidRootPart
            local dist = (hrp.Position - targetHRP.Position).Magnitude
            
            if dist < 50 then
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 3, 0)
            else
                hum.PlatformStand = true
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(1,1,1) * math.huge
                
                local t = TweenService:Create(hrp, TweenInfo.new(dist/150, Enum.EasingStyle.Linear), {CFrame = targetHRP.CFrame * CFrame.new(0,3,0)})
                t.Completed:Connect(function()
                    bv:Destroy()
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
                t:Play()
            end
        end
    end
end)

-- Follow Loop (Heartbeat for Physics)
RunService.Heartbeat:Connect(function()
    if getgenv().FlyToLoopEnabled and getgenv().NyroxRunning then
        local targetName = getgenv().TeleportTarget
        local target = type(targetName) == "string" and Players:FindFirstChild(targetName) or targetName
        
        local targetHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and targetHRP and hum then
            hum.PlatformStand = true
            hrp.CFrame = hrp.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0, 5, 0), 0.15)
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- INFINITE JUMP LOGIC
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJumpEnabled and getgenv().NyroxRunning then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- CLICK TO TELEPORT LOGIC
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and getgenv().ClickToTeleport and getgenv().NyroxRunning then
        local mousePos = UserInputService:GetMouseLocation()
        local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, raycastParams)
        
        if raycastResult then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Player List Updater für Dropdown (Simuliert)
task.spawn(function()
    while getgenv().NyroxRunning do
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
        end
        
        local dObj = getgenv().PlayerDropdown
        if dObj and dObj.UpdateOptions then
            dObj.UpdateOptions(playerNames)
        end
        task.wait(5)
    end
end)

-- Respawn Fix
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if getgenv().NoclipEnabled then toggleNoclip(true) end -- Re-apply Noclip if it was active
    local hum = char:WaitForChild("Humanoid")
    hum.PlatformStand = false
end)