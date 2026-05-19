local assets = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

-- Ensure global state exists to prevent nil-indexing errors
getgenv().NyroxToggleStates = getgenv().NyroxToggleStates or {}

function assets.CreateWindow(title, versionText)
    -- Cleanup System: Alte UI Instanzen schließen, falls vorhanden
    pcall(function()
        local oldGui = (gethui and gethui():FindFirstChild("NyroxGui")) or game:GetService("CoreGui"):FindFirstChild("NyroxGui") or 
                      game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("NyroxGui")
        if oldGui then oldGui:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyroxGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 2 -- Stellt sicher, dass die Haupt-UI über dem ESP liegt
    ScreenGui.Enabled = true -- UI ist standardmäßig sichtbar
    
    local success, _ = pcall(function() 
        ScreenGui.Parent = gethui() or game:GetService("CoreGui")
    end)
    if not success then 
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") 
    end

    -- RControl zum Ein-/Ausblenden der UI
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Width, Height = 820, 580
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Name = "MainFrame"
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BackgroundTransparency = 0
    Frame.Position = UDim2.new(0.5, -(Width/2), 0.5, -(Height/2))
    Frame.Size = UDim2.new(0, 0, 0, 0)
    Frame.ClipsDescendants = true

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    -- Dragging Logic
    local dragging, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = Frame.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false connection:Disconnect() end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)

    local TopBar = Instance.new("Frame", Frame)
    TopBar.Name = "TopBar"
    TopBar.BackgroundTransparency = 1
    TopBar.Size = UDim2.new(1, 0, 0, 50)

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -85, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = string.format("Nyrox Hub <font color=\"rgb(150,150,150)\" size=\"12\">%s</font>", versionText)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.RichText = true

    local mini = Instance.new("TextButton", TopBar)
    mini.Name = "Minimize"
    mini.BackgroundTransparency = 1
    mini.Position = UDim2.new(1, -70, 0, 0)
    mini.Size = UDim2.new(0, 30, 1, 0)
    mini.Font = Enum.Font.GothamBold
    mini.Text = "-"
    mini.TextColor3 = Color3.fromRGB(200, 200, 200)
    mini.TextSize = 26

    local closebutton = Instance.new("TextButton", TopBar)
    closebutton.Name = "Close"
    closebutton.BackgroundTransparency = 1
    closebutton.Position = UDim2.new(1, -35, 0, 0)
    closebutton.Size = UDim2.new(0, 30, 1, 0)
    closebutton.Font = Enum.Font.GothamBold
    closebutton.Text = "×"
    closebutton.TextColor3 = Color3.fromRGB(255, 60, 60)
    closebutton.TextSize = 26

    local TabButtonsFrame = Instance.new("Frame", Frame)
    TabButtonsFrame.Name = "TabButtons"
    TabButtonsFrame.BackgroundTransparency = 1
    TabButtonsFrame.Position = UDim2.new(0, 10, 0, 65)
    TabButtonsFrame.Size = UDim2.new(0, 150, 1, -105)
    local TabListLayout = Instance.new("UIListLayout", TabButtonsFrame)
    TabListLayout.Padding = UDim.new(0, 10)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local TabContent = Instance.new("Frame", Frame)
    TabContent.Name = "TabContent"
    TabContent.BackgroundTransparency = 1
    TabContent.Position = UDim2.new(0, 185, 0, 65)
    TabContent.Size = UDim2.new(1, -195, 1, -105)

    -- Vertikale Trennlinie zwischen Tabs und Content
    local VerticalLine = Instance.new("Frame", Frame)
    VerticalLine.Name = "VerticalLine"
    VerticalLine.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Etwas heller als der Hintergrund (15,15,15)
    VerticalLine.BorderSizePixel = 0
    VerticalLine.Position = UDim2.new(0, 172, 0, 65)
    VerticalLine.Size = UDim2.new(0, 1, 1, -105)

    -- Bottom Bar (Footer)
    local BottomBar = Instance.new("Frame", Frame)
    BottomBar.Name = "BottomBar"
    BottomBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BottomBar.BorderSizePixel = 0
    BottomBar.Position = UDim2.new(0, 0, 1, -25)
    BottomBar.Size = UDim2.new(1, 0, 0, 25)
    
    -- Rundung für die unteren Ecken
    Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 8)
    -- Filler-Frame, damit die Leiste oben flach bleibt
    local Filler = Instance.new("Frame", BottomBar)
    Filler.Size = UDim2.new(1, 0, 0, 10)
    Filler.BackgroundColor3 = BottomBar.BackgroundColor3
    Filler.BorderSizePixel = 0
    Filler.ZIndex = 0

    local GameInfoLabel = Instance.new("TextLabel", BottomBar)
    GameInfoLabel.BackgroundTransparency = 1
    GameInfoLabel.Position = UDim2.new(0, 15, 0, 0)
    GameInfoLabel.Size = UDim2.new(0.4, 0, 1, 0)
    GameInfoLabel.Font = Enum.Font.Gotham
    GameInfoLabel.Text = string.format("Game: %s | ID: %d", title, game.PlaceId)
    GameInfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    GameInfoLabel.TextSize = 11
    GameInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ErrorLabel = Instance.new("TextLabel", BottomBar)
    ErrorLabel.BackgroundTransparency = 1
    ErrorLabel.Position = UDim2.new(1, -165, 0, 0)
    ErrorLabel.Size = UDim2.new(0, 70, 1, 0)
    ErrorLabel.AnchorPoint = Vector2.new(1, 0)
    ErrorLabel.Font = Enum.Font.GothamBold
    ErrorLabel.Text = "Errors: 0"
    ErrorLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    ErrorLabel.TextSize = 11
    ErrorLabel.TextXAlignment = Enum.TextXAlignment.Right

    local WarnLabel = Instance.new("TextLabel", BottomBar)
    WarnLabel.BackgroundTransparency = 1
    WarnLabel.Position = UDim2.new(1, -90, 0, 0)
    WarnLabel.Size = UDim2.new(0, 70, 1, 0)
    WarnLabel.AnchorPoint = Vector2.new(1, 0)
    WarnLabel.Font = Enum.Font.GothamBold
    WarnLabel.Text = "Warns: 0"
    WarnLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    WarnLabel.TextSize = 11
    WarnLabel.TextXAlignment = Enum.TextXAlignment.Right

    local FPSLabel = Instance.new("TextLabel", BottomBar)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Position = UDim2.new(1, -15, 0, 0)
    FPSLabel.Size = UDim2.new(0, 70, 1, 0)
    FPSLabel.AnchorPoint = Vector2.new(1, 0)
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.Text = "FPS: 60"
    FPSLabel.TextColor3 = Color3.fromRGB(248, 191, 212)
    FPSLabel.TextSize = 11
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Error/Warn Counter Logic
    local warnCount, errorCount = 0, 0
    local logConnection = LogService.MessageOut:Connect(function(msg, msgType)
        if msgType == Enum.MessageType.MessageWarning then
            warnCount = warnCount + 1
            WarnLabel.Text = "Warns: " .. warnCount
        elseif msgType == Enum.MessageType.MessageError then
            errorCount = errorCount + 1
            ErrorLabel.Text = "Errors: " .. errorCount
        end
    end)

    -- FPS Counter Logic
    local lastIteration = tick()
    local frameHistory = {}
    local fpsConnection = RunService.RenderStepped:Connect(function()
        local now = tick()
        local fps = 1 / (now - lastIteration)
        lastIteration = now
        table.insert(frameHistory, fps)
        if #frameHistory > 60 then table.remove(frameHistory, 1) end
        
        local averageFps = 0
        for _, v in ipairs(frameHistory) do averageFps = averageFps + v end
        FPSLabel.Text = "FPS: " .. math.floor(averageFps / #frameHistory)
    end)

    local window = {Tabs = {}, TabCount = 0, CurrentTab = nil}

    function window:AddTabSeparator(text)
        self.TabCount = self.TabCount + 1
        local separator = assets.createTabSeparator(TabButtonsFrame, text)
        separator.LayoutOrder = self.TabCount
        return separator
    end

    function window:SetTab(tabName)
        if self.CurrentTab == tabName then return end
        self.CurrentTab = tabName

        for name, t in pairs(self.Tabs) do
            local isSelected = (name == tabName)
            t.container.Visible = isSelected

            if isSelected then
                local function animateWidgets(column)
                    task.spawn(function()
                        local layout = column:FindFirstChildOfClass("UIListLayout")
                        
                        -- Warten bis Roblox das Layout berechnet hat
                        for i = 1, 3 do RunService.RenderStepped:Wait() end
                        
                        local allWidgets = {}
                        local function collect(root)
                            for _, child in ipairs(root:GetChildren()) do
                                if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                                    local inner = child:FindFirstChild("container")
                                    if inner then
                                        -- Sektion selbst hinzufügen und in den Inhalt schauen
                                        table.insert(allWidgets, child)
                                        collect(inner)
                                    else
                                        table.insert(allWidgets, child)
                                    end
                                end
                            end
                        end
                        collect(column)
                        
                        table.sort(allWidgets, function(a, b)
                            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
                        end)

                        local delayCount = 0
                        for _, child in ipairs(allWidgets) do
                            local yPos = child.Position.Y
                            child.Position = UDim2.new(0, -80, yPos.Scale, yPos.Offset)
                            
                            TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delayCount), {
                                Position = UDim2.new(0, 0, yPos.Scale, yPos.Offset),
                            }):Play()
                            
                            delayCount = delayCount + 0.02
                        end
                        
                        -- Animationen sollten jetzt abgelaufen sein
                        task.wait(0.5)
                    end)
                end
                
                animateWidgets(t.left)
                animateWidgets(t.right)
            end

            t.btn:SetAttribute("Active", isSelected)
            
            -- Button Styling (Wieder weicher gemacht für Cleaner-Look)
            t.btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            TweenService:Create(t.btn, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                BackgroundTransparency = isSelected and 0 or 1,
                TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
            }):Play()

            local iconImg = t.btn:FindFirstChild("Icon")
            if iconImg then
                TweenService:Create(iconImg, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                    ImageColor3 = isSelected and Color3.fromRGB(248, 191, 212) or Color3.fromRGB(140, 140, 140)
                }):Play()
            end

            -- Stripe (Langsamere Transition)
            TweenService:Create(t.stripe, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = isSelected and UDim2.new(0, 3, 0.5, 0) or UDim2.new(0, 3, 0, 0),
                BackgroundTransparency = isSelected and 0 or 1
            }):Play()
        end
    end

    function window:CreateTab(name, icon)
        self.TabCount = self.TabCount + 1
        local container = Instance.new("Frame", TabContent)
        container.Name = name .. "Tab"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 1, 0)
        container.Visible = false

        -- Suchleiste oben im Tab
        local SearchBarFrame = Instance.new("Frame", container)
        SearchBarFrame.Size = UDim2.new(1, 0, 0, 32)
        SearchBarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        SearchBarFrame.BackgroundTransparency = 0
        Instance.new("UICorner", SearchBarFrame).CornerRadius = UDim.new(0, 5)
        
        local SearchIcon = Instance.new("ImageLabel", SearchBarFrame)
        SearchIcon.Name = "SearchIcon"
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
        SearchIcon.Size = UDim2.new(0, 16, 0, 16)
        SearchIcon.Image = "rbxassetid://395920720"
        SearchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

        local SearchInput = Instance.new("TextBox", SearchBarFrame)
        SearchInput.Position = UDim2.new(0, 30, 0, 0)
        SearchInput.Size = UDim2.new(1, -35, 1, 0)
        SearchInput.BackgroundTransparency = 1
        SearchInput.Font = Enum.Font.GothamMedium
        SearchInput.PlaceholderText = "Search features..."
        SearchInput.Text = ""
        SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        SearchInput.TextSize = 14
        SearchInput.TextXAlignment = Enum.TextXAlignment.Left

        local leftCol = Instance.new("ScrollingFrame", container)
        leftCol.Position = UDim2.new(0, 0, 0, 38)
        leftCol.Size = UDim2.new(0.5, -6, 1, -38)
        leftCol.BackgroundTransparency = 1
        leftCol.ClipsDescendants = true
        leftCol.ScrollBarThickness = 0
        local lLayout = Instance.new("UIListLayout", leftCol)
        lLayout.Padding = UDim.new(0, 7)
        lLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            leftCol.CanvasSize = UDim2.new(0, 0, 0, lLayout.AbsoluteContentSize.Y)
        end)

        local rightCol = Instance.new("ScrollingFrame", container)
        rightCol.Position = UDim2.new(0.5, 6, 0, 38)
        rightCol.Size = UDim2.new(0.5, -6, 1, -38)
        rightCol.BackgroundTransparency = 1
        rightCol.ClipsDescendants = true
        rightCol.ScrollBarThickness = 0
        local rLayout = Instance.new("UIListLayout", rightCol)
        rLayout.Padding = UDim.new(0, 7)
        rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rightCol.CanvasSize = UDim2.new(0, 0, 0, rLayout.AbsoluteContentSize.Y)
        end)

        local btn = assets.createGlassButton(name .. "Btn", name, TabButtonsFrame, icon)
        btn.LayoutOrder = self.TabCount
        btn:SetAttribute("NoHover", true)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.BackgroundTransparency = 1

        local stripe = Instance.new("Frame", btn)
        stripe.BackgroundColor3 = Color3.fromRGB(248, 191, 212)
        stripe.Size = UDim2.new(0, 3, 0, 0)
        stripe.Position = UDim2.new(0, 2, 0.25, 0)
        stripe.BackgroundTransparency = 1
        Instance.new("UICorner", stripe)

        btn.MouseButton1Click:Connect(function() self:SetTab(name) end)

        local tObj = {
            container = container, 
            btn = btn, 
            stripe = stripe, 
            left = leftCol, 
            right = rightCol, 
            currentParent = {Left = leftCol, Right = rightCol},
            lastColumn = "Left", -- Merkt sich die zuletzt genutzte Spalte für automatische Zuweisung
            filterableElements = {}
        }

        -- Such-Logik: Elemente filtern beim Tippen
        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local text = SearchInput.Text:lower()
            for _, element in ipairs(tObj.filterableElements) do
                local searchStr = (element:GetAttribute("SearchText") or ""):lower()
                element.Visible = (text == "" or searchStr:find(text) ~= nil)
            end
        end)

        SearchInput.Focused:Connect(function()
            TweenService:Create(SearchIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(248, 191, 212)}):Play()
        end)

        SearchInput.FocusLost:Connect(function()
            TweenService:Create(SearchIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end)
        
        function tObj:CreateSection(t, cfg)
            local col = cfg and cfg.Column or "Left"
            self.lastColumn = col -- Setzt den Fokus für folgende Elemente auf diese Spalte
            local sec = assets.createSection(self[col:lower()], t, cfg and cfg.Default or true, cfg and cfg.Droppable or false, cfg and cfg.Timestamp or nil)
            sec.sectionFrame:SetAttribute("SearchText", sec.title)
            table.insert(self.filterableElements, sec.sectionFrame)
            self.currentParent[col] = sec.container
            return sec.sectionFrame
        end

        function tObj:CreateButton(cfg)
            local col = cfg.Column or self.lastColumn
            local b = assets.createGlassButton(cfg.Title, cfg.Title, self.currentParent[col], cfg.Icon)
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Nur normale Buttons werden heller
            if cfg.Color then b.BackgroundColor3 = cfg.Color b:SetAttribute("IdleColor", cfg.Color) b.BackgroundTransparency = 0.9 end
            b:SetAttribute("SearchText", cfg.Title) -- Titel für die Suche speichern
            if cfg.Callback then b.MouseButton1Click:Connect(cfg.Callback) end
            table.insert(self.filterableElements, b)
            return b
        end

        function tObj:CreateToggle(cfg)
            local toggle = assets.createToggle(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Default or false, cfg.Callback)
            toggle:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, toggle)
            return toggle
        end

        function tObj:CreateSlider(cfg)
            local slider = assets.createSlider(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Min, cfg.Max, cfg.Default, cfg.Callback)
            slider:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, slider)
            return slider
        end

        function tObj:CreateSliderWithBox(cfg)
            local slider = assets.createSliderWithBox(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Min, cfg.Max, cfg.Default, cfg.Callback)
            slider:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, slider)
            return slider
        end

        function tObj:CreateStatus(cfg)
            local status = assets.createStatus(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Status, cfg.Color)
            status:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, status)
            return status
        end

        function tObj:CreateDropdown(cfg)
            local dObj = assets.createDropdown(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Options, cfg.Callback)
            local d = dObj.Frame
            d:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, d)
            return dObj
        end

        function tObj:CreateKeybind(cfg)
            local keybindObj = assets.createKeybind(self.currentParent[cfg.Column or self.lastColumn], cfg.Title, cfg.Callback)
            keybindObj.Frame:SetAttribute("SearchText", cfg.Title)
            table.insert(self.filterableElements, keybindObj.Frame)
            return keybindObj
        end

        -- Vereinfachte Section-Logik: Automatisches Zuweisen
        function tObj:Section(title, column, timestamp)
            return self:CreateSection(title, {Column = column or "Left", Droppable = true, Timestamp = timestamp})
        end


        function tObj:CreateParagraph(cfg) 
            return assets.createParagraph(self.currentParent[cfg.Column or self.lastColumn], cfg.Text) 
        end
        
        function tObj:CreateLog(cfg) 
            local col = (type(cfg) == "table" and cfg.Column) or self.lastColumn
            return assets.addUpdateLog(self.currentParent[col], type(cfg) == "table" and cfg.Text or cfg) 
        end

        self.Tabs[name] = tObj

        -- Automatisch den ersten erstellten Tab auswählen
        if self.TabCount == 1 then
            self:SetTab(name)
        end

        return tObj
    end
    
    local Minimized = false
    mini.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        local targetSize = Minimized and UDim2.new(0, 250, 0, 35) or UDim2.new(0, Width, 0, Height)
        local targetTopSize = Minimized and UDim2.new(1, 0, 0, 35) or UDim2.new(1, 0, 0, 50)
        mini.Text = Minimized and "+" or "-"
        TabButtonsFrame.Visible = not Minimized
        TabContent.Visible = not Minimized
        BottomBar.Visible = not Minimized
        TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        TweenService:Create(TopBar, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetTopSize}):Play()
    end)

    closebutton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        closeTween:Play()
        closeTween.Completed:Wait()
        
        -- Save config before closing
        local Config = getgenv().NyroxConfig -- Nur die bereits geladene Config verwenden
        if Config and Config.saveConfig then
            pcall(function() Config.saveConfig() end)
        end
        -- Cleanup Logic
        getgenv().NyroxRunning = false
        getgenv().EspEnabled = false
        pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 end)

        ScreenGui:Destroy()
        if fpsConnection then fpsConnection:Disconnect() end
        if logConnection then logConnection:Disconnect() end
    end)

    TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, Width, 0, Height), BackgroundTransparency = 0}):Play()

    return window
end

function assets.createGlassButton(name, text, parent, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Standardfarbe zurück auf Sektions-Niveau
    btn:SetAttribute("IdleTransparency", 0)
    btn.BackgroundTransparency = 0
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = icon and ("          " .. text) or text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.TextXAlignment = icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    if icon then
        local IconImg = Instance.new("ImageLabel", btn)
        IconImg.Name = "Icon"
        IconImg.BackgroundTransparency = 1
        IconImg.Position = UDim2.new(0, 12, 0.5, -9)
        IconImg.Size = UDim2.new(0, 18, 0, 18)
        IconImg.Image = icon
        IconImg.ImageColor3 = Color3.fromRGB(140, 140, 140) -- Standard Grau
    end

    return btn
end

function assets.createToggle(parent, text, initialState, callback)
    local Button = assets.createGlassButton("Toggle", "  " .. text, parent)
    Button.TextXAlignment = Enum.TextXAlignment.Left
    -- Toggles sollen immer sichtbar sein, daher Transparenz überschreiben
    Button.BackgroundTransparency = 0
    Button:SetAttribute("IdleTransparency", 0)
    
    -- Override initialState with loaded config if available
    local loadedState = getgenv().NyroxToggleStates[text]
    if loadedState ~= nil then initialState = loadedState end
    if initialState then Button.TextColor3 = Color3.fromRGB(255, 255, 255) end
    local ToggleFrame = Instance.new("Frame", Button)
    ToggleFrame.BackgroundColor3 = initialState and Color3.fromRGB(248, 191, 212) or Color3.fromRGB(45, 45, 45)
    ToggleFrame.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleFrame.Size = UDim2.new(0, 34, 0, 18)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(1, 0)
    local Circle = Instance.new("Frame", ToggleFrame)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Circle.Position = initialState and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    local Toggled = initialState

    -- Glide Effekt beim Hovern
    Button.MouseEnter:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -43, 0.5, -10)}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -42, 0.5, -9)}):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        TweenService:Create(ToggleFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Toggled and Color3.fromRGB(248, 191, 212) or Color3.fromRGB(45, 45, 45)}):Play()
        TweenService:Create(Button, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextColor3 = Toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = Toggled and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        callback(Toggled)
        
        -- Update global toggle states and save immediately
        getgenv().NyroxToggleStates[text] = Toggled
        pcall(function()
            local cfg = getgenv().NyroxConfig or getgenv().Import("core/config.lua")
            if cfg and cfg.saveConfig then
                cfg.saveConfig()
            end
        end)
    end)
    return Button
end

function assets.createSlider(parent, title, min, max, default, callback)
    -- Gespeicherten Wert laden, falls vorhanden
    local loadedValue = getgenv().NyroxToggleStates[title]
    if loadedValue ~= nil then default = loadedValue end

    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    local SliderTitle = Instance.new("TextLabel", SliderFrame)
    SliderTitle.Text = title .. ": " .. default
    SliderTitle.Size = UDim2.new(1, 0, 0, 18)
    SliderTitle.Font = Enum.Font.GothamMedium
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.TextSize = 14
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Position = UDim2.new(0, 0, 0, 28)
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(248, 191, 212)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Handle = Instance.new("Frame", Fill)
    Handle.Name = "Handle"
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.BackgroundColor3 = Color3.new(1, 1, 1)
    Handle.Position = UDim2.new(1, 0, 0.5, 0)
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(pos * (max - min)) + min
        SliderTitle.Text = title .. ": " .. value
        callback(value)

        -- Wert in Config speichern
        getgenv().NyroxToggleStates[title] = value
        pcall(function()
            local cfg = getgenv().NyroxConfig
            if cfg and cfg.saveConfig then cfg.saveConfig() end
        end)
    end
    local Trigger = Instance.new("TextButton", SliderFrame)
    Trigger.BackgroundTransparency = 1
    Trigger.Size = UDim2.new(1, 0, 0, 30)
    Trigger.Position = UDim2.new(0, 0, 0, 5)
    Trigger.Text = ""
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
    return SliderFrame
end

function assets.createSliderWithBox(parent, title, min, max, default, callback)
    -- Gespeicherten Wert laden, falls vorhanden
    local loadedValue = getgenv().NyroxToggleStates[title]
    if loadedValue ~= nil then default = loadedValue end

    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    
    local SliderTitle = Instance.new("TextLabel", SliderFrame)
    SliderTitle.Text = title
    SliderTitle.Size = UDim2.new(1, -50, 0, 18)
    SliderTitle.Font = Enum.Font.GothamMedium
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.TextSize = 14
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

    local InputBox = Instance.new("TextBox", SliderFrame)
    InputBox.Position = UDim2.new(1, -45, 0, 0) -- Nach oben neben den Titel gerückt
    InputBox.Size = UDim2.new(0, 45, 0, 20)
    InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    InputBox.Text = tostring(default)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 12
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Position = UDim2.new(0, 0, 0, 30)
    Bar.Size = UDim2.new(1, 0, 0, 6) -- Etwas dickerer Slider
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(248, 191, 212)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Handle = Instance.new("Frame", Fill)
    Handle.Name = "Handle"
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.BackgroundColor3 = Color3.new(1, 1, 1)
    Handle.Position = UDim2.new(1, 0, 0.5, 0)
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)

    local function update(value)
        value = math.clamp(value, min, max)
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        InputBox.Text = tostring(value)
        callback(value)

        -- Wert in Config speichern
        getgenv().NyroxToggleStates[title] = value
        pcall(function()
            local cfg = getgenv().NyroxConfig
            if cfg and cfg.saveConfig then cfg.saveConfig() end
        end)
    end

    InputBox.FocusLost:Connect(function()
        local val = tonumber(InputBox.Text) or default
        update(val)
    end)

    local dragging = false
    local Trigger = Instance.new("TextButton", SliderFrame)
    Trigger.BackgroundTransparency = 1
    Trigger.Size = UDim2.new(1, 0, 0, 30)
    Trigger.Position = UDim2.new(0, 0, 0, 18)
    Trigger.Text = ""
    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            update(math.floor(pos * (max - min)) + min)
        end
    end)
    return SliderFrame
end

function assets.createStatus(parent, title, statusText, color)
    local StatusFrame = Instance.new("Frame", parent)
    StatusFrame.BackgroundTransparency = 1
    StatusFrame.Size = UDim2.new(1, 0, 0, 20)
    local Title = Instance.new("TextLabel", StatusFrame)
    Title.Text = title .. ":"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    local Val = Instance.new("TextLabel", StatusFrame)
    Val.Text = statusText
    Val.Position = UDim2.new(0.5, 0, 0, 0)
    Val.Size = UDim2.new(0.5, 0, 1, 0)
    Val.BackgroundTransparency = 1
    Val.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    Val.Font = Enum.Font.GothamMedium
    Val.TextSize = 14
    Val.TextXAlignment = Enum.TextXAlignment.Right
    return StatusFrame
end

function assets.createDropdown(parent, title, options, callback)
    local frame = Instance.new("Frame", parent)
    frame.Name = title .. "DropdownFrame"
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local DropdownBtn = assets.createGlassButton(title .. "Btn", "  " .. title, frame)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Dropdowns jetzt so hell wie Buttons
    DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local Arrow = Instance.new("TextLabel", DropdownBtn)
    Arrow.BackgroundTransparency = 1
    Arrow.Position = UDim2.new(1, -25, 0, 0)
    Arrow.Size = UDim2.new(0, 20, 0, 32)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Text = ">"
    Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    Arrow.TextSize = 14
    Arrow.ZIndex = 2

    local SearchInput = Instance.new("TextBox", frame)
    SearchInput.Name = "SearchInput"
    SearchInput.Position = UDim2.new(0, 5, 0, 35)
    SearchInput.Size = UDim2.new(1, -10, 0, 25)
    SearchInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search player..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = Color3.new(1, 1, 1)
    SearchInput.TextSize = 12
    SearchInput.Visible = false
    Instance.new("UICorner", SearchInput).CornerRadius = UDim.new(0, 4)

    local Container = Instance.new("ScrollingFrame", frame)
    Container.Name = "Container"
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 5, 0, 65)
    Container.Size = UDim2.new(1, -10, 0, 100)
    Container.ScrollBarThickness = 2
    Container.Visible = false
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", Container)
    layout.Padding = UDim.new(0, 2)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    local open = false
    local function toggle()
        open = not open
        local targetSize = open and UDim2.new(1, 0, 0, 175) or UDim2.new(1, 0, 0, 32) -- Adjusted height for search bar
        local targetRotation = open and 90 or 0
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Rotation = targetRotation}):Play()
        SearchInput.Visible = open
        Container.Visible = open
    end

    DropdownBtn.MouseButton1Click:Connect(toggle)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = SearchInput.Text:lower()
        for _, btn in pairs(Container:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Visible = btn.Name:lower():find(filter) ~= nil
            end
        end
    end)

    local function updateOptions(newOptions)
        local filter = SearchInput.Text:lower()
        for _, v in pairs(Container:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, opt in pairs(newOptions) do
            local btn = assets.createGlassButton(opt, opt, Container)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.Visible = opt:lower():find(filter) ~= nil
            btn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = "  " .. opt
                callback(opt)
                toggle()
            end)
        end
    end

    if options then updateOptions(options) end
    
    return {
        Frame = frame,
        UpdateOptions = updateOptions
    }
end

function assets.createKeybind(parent, title, callback)
    local KeybindFrame = Instance.new("Frame", parent)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Size = UDim2.new(1, 0, 0, 32)

    local TitleLabel = Instance.new("TextLabel", KeybindFrame)
    TitleLabel.Text = title
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local KeyButton = assets.createGlassButton("KeybindButton", "NONE", KeybindFrame)
    KeyButton.Size = UDim2.new(0.4, 0, 1, 0)
    KeyButton.Position = UDim2.new(0.6, 0, 0, 0)
    KeyButton.TextXAlignment = Enum.TextXAlignment.Center
    KeyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Keybinds bleiben dunkel
    KeyButton.Text = "NONE" -- Default text

    local binding = false
    local currentKey = Enum.KeyCode.Unknown

    KeyButton.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        KeyButton.Text = "PRESS KEY..."
        KeyButton.TextColor3 = Color3.fromRGB(248, 191, 212) -- Highlight color

        local inputConnection
        inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                KeyButton.Text = currentKey.Name:upper()
                KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                callback(currentKey)
                binding = false
                inputConnection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                KeyButton.Text = currentKey.Name == "Unknown" and "NONE" or currentKey.Name:upper()
                KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                binding = false
                inputConnection:Disconnect()
            end
        end)
    end)

    return {
        Frame = KeybindFrame,
        SetKey = function(keyCode)
            currentKey = keyCode
            KeyButton.Text = keyCode.Name == "Unknown" and "NONE" or keyCode.Name:upper()
        end,
        GetKey = function()
            return currentKey
        end
    }
end

function assets.createParagraph(parent, text)
    local label = Instance.new("TextLabel", parent)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Text = text
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.AutomaticSize = Enum.AutomaticSize.Y
    return label
end

function assets.addUpdateLog(parent, text)
    
    local log = Instance.new("TextLabel", parent)
    log.BackgroundTransparency = 1
    log.Size = UDim2.new(1, 0, 0, 0)
    log.AutomaticSize = Enum.AutomaticSize.Y
    log.Font = Enum.Font.GothamBold
    log.TextColor3 = Color3.fromRGB(200, 200, 200)
    log.TextSize = 13
    log.RichText = true
    log.TextWrapped = true
    log.TextXAlignment = Enum.TextXAlignment.Left
    local symbol = text:sub(1,1):match("[%+%-%/%=]")
    local content = symbol and text:sub(2):gsub("^%s+", "") or text
    local color = symbol == "+" and "rgb(0,255,100)" or symbol == "-" and "rgb(255,80,80)" or symbol == "/" and "rgb(0,170,255)" or symbol == "=" and "rgb(255,255,0)" or "rgb(200,200,200)"
    log.Text = string.format(" <font color=\"%s\">[%s] %s</font>", color, symbol or " ", content)
    return log
end

function assets.createSection(parent, title, startOpen, canCollapse, timestamp)
    if canCollapse == nil then canCollapse = true end

    local sectionFrame = Instance.new("Frame", parent)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sectionFrame:SetAttribute("IdleTransparency", 0)
    sectionFrame.Size = UDim2.new(1, 0, 0, 32)
    sectionFrame.ClipsDescendants = true
    Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 5)

    local toggleBtn = Instance.new("TextButton", sectionFrame)
    
    local displayTitle = title
    if timestamp then
        local diff = os.time() - timestamp
        if diff < 86400 then
            displayTitle = "Today"
        elseif diff < 172800 then
            displayTitle = "1 day ago"
        else
            displayTitle = math.floor(diff / 86400) .. " days ago"
        end
    end

    toggleBtn.Size = UDim2.new(1, 0, 0, 32)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.AutoButtonColor = canCollapse
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.Text = "  " .. displayTitle
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.RichText = true
    toggleBtn.TextSize = 14
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextLabel", sectionFrame)
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.Size = UDim2.new(0, 20, 0, 32)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = ">"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.ZIndex = 2
    arrow.Visible = canCollapse

    local container = Instance.new("Frame", sectionFrame)
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 10, 0, 42)
    container.Size = UDim2.new(1, -20, 0, 0)
    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 8)
    
    local open = (not canCollapse) or startOpen

    local function updateSize()
        local targetSize = open and UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 55) or UDim2.new(1, 0, 0, 36)
        local targetRotation = open and 90 or 0
        
        TweenService:Create(sectionFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        if canCollapse then
            TweenService:Create(arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        end
        container.Visible = open -- Sichtbarkeit des Containers steuern
        container.Size = UDim2.new(1, -20, 0, layout.AbsoluteContentSize.Y) -- Größe des Containers anpassen
    end

    if canCollapse then
        toggleBtn.MouseButton1Click:Connect(function() open = not open updateSize() end)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
    if open then task.spawn(function() task.wait(0.1) updateSize() end) end -- Initiales Update für die Größe
    
    return {sectionFrame = sectionFrame, container = container, toggleBtn = toggleBtn, arrow = arrow, open = open, canCollapse = canCollapse, title = displayTitle}
end

function assets.createTabSeparator(parent, text)
    local container = Instance.new("Frame", parent)
    container.Name = "TabSeparator"
    container.BackgroundTransparency = 1

    if text then
        container.Size = UDim2.new(1, 0, 0, 35)
        local label = Instance.new("TextLabel", container)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Size = UDim2.new(1, -12, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 2
    else
        container.Size = UDim2.new(1, 0, 0, 10)
        local line = Instance.new("Frame", container)
        line.Name = "Line"
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        line.BorderSizePixel = 0
        line.Position = UDim2.new(0.5, 0, 0.5, 0)
        line.Size = UDim2.new(0.7, 0, 0, 1)
    end

    return container
end

return assets