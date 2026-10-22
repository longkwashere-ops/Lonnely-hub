-- ============================================================
-- LONELY HUB v83 - SIDEBAR FULL (ANTI MULTI-TOUCH)
-- ============================================================

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HUB_FONT = Enum.Font.GothamBold

local BG_COLOR = Color3.fromRGB(12, 12, 14)
local TAB_COLOR = Color3.fromRGB(25, 25, 28)
local TAB_SELECTED = Color3.fromRGB(50, 50, 55)
local TEXT_COLOR = Color3.fromRGB(200, 200, 200)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local THEME_COLOR = Color3.fromRGB(255, 255, 255)

local isLocked = false
local state = {
    speed = 16, jump = 50, gravity = 190, fov = 70, smoothSpeed = 40,
    speedOn = false, jumpOn = false, gravityOn = false, fovOn = false, zoomOn = false,
    minZoom = 0.5, maxZoom = 20, unlockFPS = true, statsDisplayOn = false, speedDisplayOn = false,
    head = false, torso = false, arms = false, legs = false, accessories = false, allHide = false,
    savedSpeed = 16, savedJump = 50, savedGravity = 196.2, savedFov = 70,
    savedMinZoom = 0.5, savedMaxZoom = 128, smoothOn = false, infJumpOn = false,
    trailOn = false, autoPressOn = false, realClockOn = false, sessionTimeOn = false,
    espOn = false, targetName = ""
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local function applySpeed() if humanoid and humanoid.Parent and state.speedOn and not state.smoothOn then humanoid.WalkSpeed = state.speed end end
local function applyJump() if humanoid and humanoid.Parent and state.jumpOn then humanoid.JumpPower = state.jump; humanoid.UseJumpPower = true end end
local function applyGravity() if state.gravityOn then workspace.Gravity = state.gravity end end
local function applyFOV() if state.fovOn then Camera.FieldOfView = state.fov end end
local function applyZoom() if state.zoomOn then pcall(function() LocalPlayer.CameraMinZoomDistance = state.minZoom; LocalPlayer.CameraMaxZoomDistance = state.maxZoom end) end end

RunService.RenderStepped:Connect(function()
    if not state.unlockFPS then return end
    pcall(function()
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then LocalPlayer.CameraMode = Enum.CameraMode.Classic end
        if Camera.CameraType ~= Enum.CameraType.Custom then Camera.CameraType = Enum.CameraType.Custom end
    end)
end)

local function hidePart(part) if part and part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end end
local function showPart(part) if part and part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end end
local function applyHide()
    if not character or not character.Parent then return end
    local head = character:FindFirstChild("Head"); if head then if state.head or state.allHide then hidePart(head) else showPart(head) end end
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"); if torso then if state.torso or state.allHide then hidePart(torso) else showPart(torso) end end
    local lArm, rArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftArm"), character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
    if state.arms or state.allHide then if lArm then hidePart(lArm) end; if rArm then hidePart(rArm) end else if lArm then showPart(lArm) end; if rArm then showPart(rArm) end end
    local lLeg, rLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLeg"), character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLeg")
    if state.legs or state.allHide then if lLeg then hidePart(lLeg) end; if rLeg then hidePart(rLeg) end else if lLeg then showPart(lLeg) end; if rLeg then showPart(rLeg) end end
    for _, acc in ipairs(character:GetChildren()) do if acc:IsA("Accessory") then local h = acc:FindFirstChild("Handle"); if h then if state.accessories or state.allHide then hidePart(h) else showPart(h) end end end end
end
applyHide()
RunService.Heartbeat:Connect(function() if character and character.Parent then applyHide() end end)

local bv = nil
local function setupBV()
    if bv then bv:Destroy() end
    if not rootPart or not rootPart.Parent then return end
    bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e9, 0, 1e9); bv.Velocity = Vector3.new(0, 0, 0); bv.P = 1250; bv.Parent = rootPart
    if humanoid and humanoid.Parent then humanoid.WalkSpeed = state.smoothSpeed end
end
local function destroyBV()
    if bv then bv:Destroy(); bv = nil end
    if humanoid and humanoid.Parent and state.speedOn then humanoid.WalkSpeed = state.speed end
end
RunService.Heartbeat:Connect(function()
    if state.smoothOn and bv and humanoid and humanoid.Parent and rootPart then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0.01 then bv.Velocity = Vector3.new(moveDir.X * state.smoothSpeed, 0, moveDir.Z * state.smoothSpeed) else bv.Velocity = Vector3.new(0, 0, 0) end
    end
end)

local currentTrail = nil
local function createTrail()
    pcall(function()
        if not rootPart or not rootPart.Parent then return end
        if currentTrail then currentTrail:Destroy() end
        for _, v in ipairs(rootPart:GetChildren()) do if v.Name == "TrailAtt0" or v.Name == "TrailAtt1" then v:Destroy() end end
        local a0 = Instance.new("Attachment"); a0.Name = "TrailAtt0"; a0.Position = Vector3.new(0, 0.5, 0); a0.Parent = rootPart
        local a1 = Instance.new("Attachment"); a1.Name = "TrailAtt1"; a1.Position = Vector3.new(0, -0.5, 0); a1.Parent = rootPart
        local t = Instance.new("Trail"); t.Name = "CharTrail"; t.Attachment0 = a0; t.Attachment1 = a1; t.Lifetime = 1.5; t.MinLength = 0
        t.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)) })
        t.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.3), NumberSequenceKeypoint.new(1, 1) })
        t.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        t.FaceCamera = true; t.Parent = rootPart; currentTrail = t
    end)
end
local function removeTrail()
    pcall(function()
        if currentTrail then currentTrail:Destroy(); currentTrail = nil end
        if rootPart and rootPart.Parent then for _, v in ipairs(rootPart:GetChildren()) do if v.Name == "TrailAtt0" or v.Name == "TrailAtt1" then v:Destroy() end end end
    end)
end

local espObjects = {}
local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    if not player.Character then return end
    if not player.Character:FindFirstChild("Head") then return end
    local head = player.Character:FindFirstChild("Head")
    local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Name"; billboard.Size = UDim2.new(0, 240, 0, 50); billboard.StudsOffset = Vector3.new(0, 3.2, 0); billboard.AlwaysOnTop = true; billboard.Enabled = state.espOn; billboard.Parent = head
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.Text = player.Name; label.TextSize = 22; label.Font = HUB_FONT; label.TextStrokeTransparency = 0; label.TextStrokeColor3 = Color3.fromRGB(0,0,0); label.TextColor3 = Color3.fromRGB(255,255,255); label.Parent = billboard
    espObjects[player] = billboard
end
local function removeESP(player) if espObjects[player] then pcall(function() espObjects[player]:Destroy() end); espObjects[player] = nil end end
local function refreshESP()
    for p, _ in pairs(espObjects) do removeESP(p) end
    if not state.espOn then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if state.targetName == "" or string.find(player.Name:lower(), state.targetName:lower()) then createESP(player) end
        end
    end
end
local function hookPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if state.espOn then
            if state.targetName == "" or string.find(player.Name:lower(), state.targetName:lower()) then createESP(player) end
        end
    end)
    player.CharacterRemoving:Connect(function() removeESP(player) end)
end
for _, player in ipairs(Players:GetPlayers()) do hookPlayer(player) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

local overlayGui = Instance.new("ScreenGui"); overlayGui.Name = "Overlays"; overlayGui.ResetOnSpawn = false; overlayGui.IgnoreGuiInset = true
pcall(function() overlayGui.Parent = game:GetService("CoreGui") end); if not overlayGui.Parent then overlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local autoPressTimeLeft, autoPressAccumulated = 300, 0
local sessionStart = tick()
local timerLabel = Instance.new("TextLabel"); timerLabel.Size = UDim2.new(0, 100, 0, 30); timerLabel.Position = UDim2.new(1, -110, 0, 10); timerLabel.BackgroundTransparency = 1; timerLabel.Text = "5:00"; timerLabel.TextColor3 = TEXT_WHITE; timerLabel.TextSize = 22; timerLabel.Font = Enum.Font.GothamBold; timerLabel.TextStrokeTransparency = 0; timerLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0); timerLabel.TextXAlignment = Enum.TextXAlignment.Right; timerLabel.Visible = false; timerLabel.Parent = overlayGui
local clockLabel = Instance.new("TextLabel"); clockLabel.Size = UDim2.new(0, 120, 0, 30); clockLabel.Position = UDim2.new(1, -130, 0, 45); clockLabel.BackgroundTransparency = 1; clockLabel.Text = "00:00:00"; clockLabel.TextColor3 = TEXT_WHITE; clockLabel.TextSize = 22; clockLabel.Font = Enum.Font.GothamBold; clockLabel.TextStrokeTransparency = 0; clockLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0); clockLabel.TextXAlignment = Enum.TextXAlignment.Right; clockLabel.Visible = false; clockLabel.Parent = overlayGui
local sessionLabel = Instance.new("TextLabel"); sessionLabel.Size = UDim2.new(0, 120, 0, 30); sessionLabel.Position = UDim2.new(1, -130, 0, 80); sessionLabel.BackgroundTransparency = 1; sessionLabel.Text = "00:00:00"; sessionLabel.TextColor3 = TEXT_WHITE; sessionLabel.TextSize = 22; sessionLabel.Font = Enum.Font.GothamBold; sessionLabel.TextStrokeTransparency = 0; sessionLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0); sessionLabel.TextXAlignment = Enum.TextXAlignment.Right; sessionLabel.Visible = false; sessionLabel.Parent = overlayGui
local speedLabel = Instance.new("TextLabel"); speedLabel.Size = UDim2.new(0, 300, 0, 40); speedLabel.Position = UDim2.new(0.5, -150, 0, 10); speedLabel.BackgroundTransparency = 1; speedLabel.Text = "SPEED: 0.0 S/s"; speedLabel.TextColor3 = TEXT_WHITE; speedLabel.TextSize = 20; speedLabel.Font = Enum.Font.GothamBold; speedLabel.TextStrokeTransparency = 0; speedLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0); speedLabel.Visible = false; speedLabel.Parent = overlayGui
local hue = 0
local function pressC() pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game); task.wait(0.05); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end) end
local statsGui = Instance.new("ScreenGui"); statsGui.Name = "StatsDisplay"; statsGui.ResetOnSpawn = false; statsGui.IgnoreGuiInset = true
pcall(function() statsGui.Parent = game:GetService("CoreGui") end); if not statsGui.Parent then statsGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local statsFrame = Instance.new("Frame"); statsFrame.Size = UDim2.new(0, 160, 0, 110); statsFrame.Position = UDim2.new(0, 15, 0, 15); statsFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); statsFrame.BackgroundTransparency = 0.5; statsFrame.BorderSizePixel = 0; statsFrame.Active = true; statsFrame.Draggable = true; statsFrame.ZIndex = 100; statsFrame.Visible = false; statsFrame.Parent = statsGui
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 10)
local function makeStatLbl(n, y) local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -20, 0, 20); l.Position = UDim2.new(0, 10, 0, y); l.BackgroundTransparency = 1; l.Text = n..": 0"; l.TextColor3 = TEXT_WHITE; l.TextSize = 14; l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left; l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.fromRGB(0,0,0); l.Parent = statsFrame; return l end
local lblSpeed, lblJump, lblGrav, lblFov = makeStatLbl("Speed", 10), makeStatLbl("Jump", 30), makeStatLbl("Grav", 50), makeStatLbl("FOV", 70)

RunService.Heartbeat:Connect(function(dt)
    if state.autoPressOn then
        autoPressAccumulated = autoPressAccumulated + dt
        if autoPressAccumulated >= 1 then
            autoPressAccumulated = autoPressAccumulated - 1; autoPressTimeLeft = autoPressTimeLeft - 1
            if autoPressTimeLeft <= 0 then autoPressTimeLeft = 300; pressC() end
            timerLabel.Text = string.format("%d:%02d", math.floor(autoPressTimeLeft / 60), autoPressTimeLeft % 60)
        end
    else timerLabel.Text = string.format("%d:%02d (off)", math.floor(autoPressTimeLeft / 60), autoPressTimeLeft % 60) end
    if state.realClockOn then local t = os.date("*t"); clockLabel.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec) end
    if state.sessionTimeOn then local e = tick() - sessionStart; sessionLabel.Text = string.format("%02d:%02d:%02d", math.floor(e/3600), math.floor((e%3600)/60), math.floor(e%60)) end
    if state.speedDisplayOn then
        local s = 0; if rootPart and rootPart.Parent then local v = rootPart.AssemblyLinearVelocity; s = math.sqrt(v.X^2 + v.Z^2) end
        speedLabel.Text = string.format("SPEED: %.1f S/s", s); hue = (hue + dt * 0.5) % 1; speedLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
    if state.statsDisplayOn and character and humanoid then
        lblSpeed.Text = string.format("Speed: %.0f", humanoid.WalkSpeed); lblJump.Text = string.format("Jump: %.0f", humanoid.JumpPower); lblGrav.Text = string.format("Grav: %.0f", workspace.Gravity); lblFov.Text = string.format("FOV: %.0f", Camera.FieldOfView)
    end
end)

-- ============================================================
-- GIAO DIỆN SIDEBAR
-- ============================================================
local gui = Instance.new("ScreenGui"); gui.Name = "LonelySidebar"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = false; gui.DisplayOrder = 999
pcall(function() gui.Parent = game:GetService("CoreGui") end); if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local icon = Instance.new("TextButton"); icon.Size = UDim2.new(0, 60, 0, 60); icon.Position = UDim2.new(0, 20, 0.5, -30); icon.BackgroundColor3 = Color3.fromRGB(20, 20, 20); icon.BorderSizePixel = 0; icon.Text = "L"; icon.TextColor3 = TEXT_WHITE; icon.TextSize = 24; icon.Font = HUB_FONT; icon.AutoButtonColor = false; icon.Active = true; icon.ZIndex = 100; icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)
local iconStroke = Instance.new("UIStroke", icon); iconStroke.Color = THEME_COLOR; iconStroke.Thickness = 2

local main = Instance.new("Frame"); main.Size = UDim2.new(0, 700, 0, 400); main.Position = UDim2.new(0.5, -350, 0.5, -200); main.BackgroundColor3 = BG_COLOR; main.BorderSizePixel = 0; main.Visible = false; main.ZIndex = 50; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", main); mainStroke.Color = THEME_COLOR; mainStroke.Thickness = 1.5; mainStroke.Transparency = 0.3

local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 50); header.BackgroundTransparency = 1; header.ZIndex = 51; header.Active = true; header.Parent = main
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -100, 1, 0); title.Position = UDim2.new(0, 20, 0, 0); title.BackgroundTransparency = 1; title.Text = "LONELY •"; title.TextColor3 = TEXT_WHITE; title.TextSize = 18; title.Font = HUB_FONT; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 52; title.Parent = header
local btnClose = Instance.new("TextButton"); btnClose.Size = UDim2.new(0, 30, 0, 30); btnClose.Position = UDim2.new(1, -45, 0, 10); btnClose.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btnClose.BorderSizePixel = 0; btnClose.Text = "X"; btnClose.TextColor3 = TEXT_WHITE; btnClose.TextSize = 16; btnClose.Font = HUB_FONT; btnClose.ZIndex = 52; btnClose.Parent = header
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0, 180, 1, -60); sidebar.Position = UDim2.new(0, 10, 0, 50); sidebar.BackgroundTransparency = 1; sidebar.ZIndex = 51; sidebar.Parent = main
local sidebarLayout = Instance.new("UIListLayout"); sidebarLayout.Padding = UDim.new(0, 5); sidebarLayout.Parent = sidebar

local contentArea = Instance.new("ScrollingFrame"); contentArea.Size = UDim2.new(1, -210, 1, -60); contentArea.Position = UDim2.new(0, 200, 0, 50); contentArea.BackgroundTransparency = 1; contentArea.BorderSizePixel = 0; contentArea.ScrollBarThickness = 3; contentArea.ScrollBarImageColor3 = TEXT_WHITE; contentArea.ZIndex = 51; contentArea.Parent = main
local contentLayout = Instance.new("UIListLayout"); contentLayout.Padding = UDim.new(0, 5); contentLayout.Parent = contentArea
local contentPadding = Instance.new("UIPadding"); contentPadding.PaddingRight = UDim.new(0, 10); contentPadding.Parent = contentArea
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10) end)

local function makeTab(name, iconText)
    local tab = Instance.new("TextButton"); tab.Size = UDim2.new(1, 0, 0, 40); tab.BackgroundColor3 = TAB_COLOR; tab.BorderSizePixel = 0
    tab.Text = "  " .. iconText .. "  " .. name; tab.TextColor3 = TEXT_COLOR; tab.TextSize = 14; tab.Font = HUB_FONT; tab.TextXAlignment = Enum.TextXAlignment.Left; tab.AutoButtonColor = false; tab.ZIndex = 52; tab.Parent = sidebar
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 8); return tab
end

local function selectTab(tabBtn, contentFunc)
    for _, child in ipairs(sidebar:GetChildren()) do if child:IsA("TextButton") then child.BackgroundColor3 = TAB_COLOR; child.TextColor3 = TEXT_COLOR end end
    tabBtn.BackgroundColor3 = TAB_SELECTED; tabBtn.TextColor3 = TEXT_WHITE
    for _, child in ipairs(contentArea:GetChildren()) do if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end end
    contentFunc()
end

local function makeContentBox(text)
    local box = Instance.new("Frame"); box.Size = UDim2.new(1, 0, 0, 110); box.BackgroundColor3 = Color3.fromRGB(20, 20, 22); box.BorderSizePixel = 0; box.ZIndex = 52; box.Parent = contentArea
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", box); stroke.Color = THEME_COLOR; stroke.Transparency = 0.7; stroke.Parent = box
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -20, 1, -20); lbl.Position = UDim2.new(0, 10, 0, 10); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = TEXT_WHITE; lbl.TextSize = 14; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top; lbl.TextWrapped = true; lbl.ZIndex = 53; lbl.Parent = box
end

local function makeSlider(name, stateKey, min, max, step, callback)
    local default = state[stateKey]
    local card = Instance.new("Frame"); card.Size = UDim2.new(1, 0, 0, 52); card.BackgroundColor3 = Color3.fromRGB(20, 20, 22); card.BorderSizePixel = 0; card.ZIndex = 52; card.Parent = contentArea
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", card); stroke.Color = THEME_COLOR; stroke.Transparency = 0.7; stroke.Parent = card
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5, 0, 0, 20); lbl.Position = UDim2.new(0, 12, 0, 6); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = TEXT_WHITE; lbl.TextSize = 14; lbl.Font = HUB_FONT; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 53; lbl.Parent = card
    local textBox = Instance.new("TextBox"); textBox.Size = UDim2.new(0.15, 0, 0, 24); textBox.Position = UDim2.new(0.82, 0, 0, 5); textBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0); textBox.BackgroundTransparency = 0.5; textBox.BorderSizePixel = 0; textBox.Text = tostring(default); textBox.TextColor3 = TEXT_WHITE; textBox.TextSize = 13; textBox.Font = HUB_FONT; textBox.ClearTextOnFocus = false; textBox.ZIndex = 53; textBox.Parent = card
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
    local track = Instance.new("TextButton"); track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 0, 36); track.BackgroundColor3 = Color3.fromRGB(60, 60, 65); track.BorderSizePixel = 0; track.Text = ""; track.AutoButtonColor = false; track.ZIndex = 53; track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = TEXT_WHITE; fill.BorderSizePixel = 0; fill.ZIndex = 54; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8); knob.BackgroundColor3 = TEXT_WHITE; knob.BorderSizePixel = 0; knob.ZIndex = 55; knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local localDrag, activeSliderTouch = false, nil
    local function setValue(val, fromTextBox)
        val = math.clamp(val, min, max); state[stateKey] = val; local alpha = (val - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0); knob.Position = UDim2.new(alpha, -8, 0.5, -8)
        if not fromTextBox then textBox.Text = tostring(val) end; callback(val)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not activeSliderTouch then activeSliderTouch = input; localDrag = true; local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); local raw = min + relX * (max - min); setValue(math.floor(raw / step + 0.5) * step, false) end
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if localDrag and input == activeSliderTouch and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); local raw = min + relX * (max - min); setValue(math.floor(raw / step + 0.5) * step, false)
        end
    end)
    UserInput.InputEnded:Connect(function(input)
        if input == activeSliderTouch and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then localDrag = false; activeSliderTouch = nil end
    end)
    textBox.FocusLost:Connect(function() local num = tonumber(textBox.Text); if num then setValue(num, true) else textBox.Text = tostring(default) end end)
end

local function makeToggle(name, stateKey, callback)
    local currentState = state[stateKey]
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 22); btn.BorderSizePixel = 0; btn.Text = "  " .. name; btn.TextColor3 = TEXT_WHITE; btn.TextSize = 14; btn.Font = HUB_FONT; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false; btn.ZIndex = 52; btn.Parent = contentArea
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = THEME_COLOR; stroke.Transparency = 0.7; stroke.Parent = btn
    local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 10, 0, 10); ind.Position = UDim2.new(1, -20, 0.5, -5); ind.BackgroundColor3 = currentState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0); ind.ZIndex = 53; ind.Parent = btn
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function() 
        state[stateKey] = not state[stateKey]
        local on = state[stateKey]
        ind.BackgroundColor3 = on and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0); 
        callback(on) 
    end)
end

-- ============================================================
-- CÁC TAB
-- ============================================================
local tabHome = makeTab("Dashboard", "🏠")
tabHome.MouseButton1Click:Connect(function() selectTab(tabHome, function() makeContentBox("📊 LONELY • DASHBOARD\n\n· Executor: Delta\n· Status: Active\n· Game ID: " .. tostring(game.PlaceId) .. "\n· Player: " .. LocalPlayer.Name) end) end)

local tabPlayer = makeTab("Player", "🏃")
tabPlayer.MouseButton1Click:Connect(function()
    selectTab(tabPlayer, function()
        makeSlider("SPEED", "speed", 0, 500, 2, function(v) if state.speedOn and not state.smoothOn then applySpeed() end end)
        makeSlider("JUMP", "jump", 0, 500, 5, function(v) if state.jumpOn then applyJump() end end)
        makeSlider("GRAVITY", "gravity", 0, 1000, 10, function(v) if state.gravityOn then applyGravity() end end)
        makeSlider("FOV", "fov", 70, 160, 5, function(v) if state.fovOn then applyFOV() end end)
        makeSlider("MIN ZOOM", "minZoom", 0.5, 20, 0.5, function(v) if state.zoomOn then applyZoom() end end)
        makeSlider("MAX ZOOM", "maxZoom", 0.5, 1000, 5, function(v) if state.zoomOn then applyZoom() end end)
        
        makeToggle("SPEED LOCK", "speedOn", function(v) if v then state.savedSpeed = humanoid.WalkSpeed; applySpeed() else humanoid.WalkSpeed = state.savedSpeed end end)
        makeToggle("JUMP LOCK", "jumpOn", function(v) if v then state.savedJump = humanoid.JumpPower; applyJump() else humanoid.JumpPower = state.savedJump end end)
        makeToggle("GRAVITY LOCK", "gravityOn", function(v) if v then state.savedGravity = workspace.Gravity; applyGravity() else workspace.Gravity = state.savedGravity end end)
        makeToggle("FOV LOCK", "fovOn", function(v) if v then state.savedFov = Camera.FieldOfView; applyFOV() else Camera.FieldOfView = state.savedFov end end)
        makeToggle("ZOOM LOCK", "zoomOn", function(v) 
            if v then state.savedMinZoom = LocalPlayer.CameraMinZoomDistance; state.savedMaxZoom = LocalPlayer.CameraMaxZoomDistance; applyZoom() 
            else pcall(function() LocalPlayer.CameraMinZoomDistance = state.savedMinZoom; LocalPlayer.CameraMaxZoomDistance = state.savedMaxZoom end) end
        end)
    end)
end)

local tabAuto = makeTab("Movement", "⚡")
tabAuto.MouseButton1Click:Connect(function()
    selectTab(tabAuto, function()
        makeSlider("SMOOTH SPD", "smoothSpeed", 0, 500, 2, function(v) if state.smoothOn and humanoid and humanoid.Parent then humanoid.WalkSpeed = v end end)
        makeToggle("SMOOTH SPEED", "smoothOn", function(v) if v then state.speedOn = false; setupBV() else destroyBV(); state.speedOn = true end end)
        makeToggle("INF JUMP", "infJumpOn", function(v) end)
    end)
end)

local tabVisuals = makeTab("Visuals", "🎨")
tabVisuals.MouseButton1Click:Connect(function()
    selectTab(tabVisuals, function()
        makeToggle("HEAD", "head", function(v) end)
        makeToggle("TORSO", "torso", function(v) end)
        makeToggle("ARMS", "arms", function(v) end)
        makeToggle("LEGS", "legs", function(v) end)
        makeToggle("ACCESSORIES", "accessories", function(v) end)
        makeToggle("ALL HIDE", "allHide", function(v) end)
        makeToggle("TRAIL", "trailOn", function(v) if v then createTrail() else removeTrail() end end)
    end)
end)

local tabESP = makeTab("ESP", "👁️")
tabESP.MouseButton1Click:Connect(function()
    selectTab(tabESP, function()
        makeToggle("ESP MASTER", "espOn", function(v) refreshESP() end)
        local nameBox = Instance.new("TextBox"); nameBox.Size = UDim2.new(1, 0, 0, 40); nameBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22); nameBox.BorderSizePixel = 0; nameBox.PlaceholderText = "Nhập tên (Để trống = tất cả)..."; nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); nameBox.Text = state.targetName; nameBox.TextColor3 = TEXT_WHITE; nameBox.TextSize = 14; nameBox.Font = HUB_FONT; nameBox.ZIndex = 52; nameBox.Parent = contentArea
        Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 10)
        nameBox.FocusLost:Connect(function() state.targetName = nameBox.Text; refreshESP() end)
        
        local listTitle = Instance.new("TextLabel"); listTitle.Size = UDim2.new(1, 0, 0, 20); listTitle.BackgroundTransparency = 1; listTitle.Text = "DANH SÁCH NGƯỜI CHƠI"; listTitle.TextColor3 = Color3.fromRGB(180, 180, 180); listTitle.TextSize = 12; listTitle.Font = HUB_FONT; listTitle.ZIndex = 52; listTitle.Parent = contentArea
        local scrollList = Instance.new("ScrollingFrame"); scrollList.Size = UDim2.new(1, 0, 0, 200); scrollList.BackgroundColor3 = Color3.fromRGB(20, 20, 22); scrollList.BorderSizePixel = 0; scrollList.ScrollBarThickness = 3; scrollList.ScrollBarImageColor3 = TEXT_WHITE; scrollList.ZIndex = 52; scrollList.Parent = contentArea
        Instance.new("UICorner", scrollList).CornerRadius = UDim.new(0, 10)
        local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 5); listLayout.Parent = scrollList
        local listPadding = Instance.new("UIPadding"); listPadding.PaddingTop = UDim.new(0, 5); listPadding.PaddingLeft = UDim.new(0, 5); listPadding.PaddingRight = UDim.new(0, 5); listPadding.Parent = scrollList
        
        local function updateList()
            for _, child in ipairs(scrollList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            local players = Players:GetPlayers(); table.sort(players, function(a, b) return a.Name < b.Name end)
            for _, p in ipairs(players) do
                local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); btn.BorderSizePixel = 0; btn.Text = " " .. p.Name; btn.TextColor3 = TEXT_WHITE; btn.TextSize = 13; btn.Font = HUB_FONT; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false; btn.ZIndex = 53; btn.Parent = scrollList
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.MouseButton1Click:Connect(function() nameBox.Text = p.Name; state.targetName = p.Name; if not state.espOn then state.espOn = true; refreshESP() end; refreshESP() end)
            end
        end
        updateList(); Players.PlayerAdded:Connect(function() task.wait(1); updateList() end); Players.PlayerRemoving:Connect(function() task.wait(1); updateList() end)
    end)
end)

local tabUtils = makeTab("Toggles", "⚙️")
tabUtils.MouseButton1Click:Connect(function()
    selectTab(tabUtils, function()
        makeToggle("SPEED DISPLAY", "speedDisplayOn", function(v) speedLabel.Visible = v end)
        makeToggle("AUTO PRESS C", "autoPressOn", function(v) timerLabel.Visible = v end)
        makeToggle("REAL CLOCK", "realClockOn", function(v) clockLabel.Visible = v end)
        makeToggle("SESSION TIME", "sessionTimeOn", function(v) sessionLabel.Visible = v end)
        makeToggle("STATS DISPLAY", "statsDisplayOn", function(v) statsFrame.Visible = v end)
        makeToggle("HIDE GAME UI", "hideUIOn", function(v) hideUIOn = v; applyHideUI() end)
        makeToggle("UNLOCK FPS", "unlockFPS", function(v) state.unlockFPS = v end)
    end)
end)

selectTab(tabHome, function() makeContentBox("📊 LONELY • DASHBOARD\n\n· Executor: Delta\n· Status: Active\n· Game ID: " .. tostring(game.PlaceId) .. "\n· Player: " .. LocalPlayer.Name) end)

-- KÉO THẢ HUB & NÚT L
local hubDragging, hubDragStart, hubStartPos, activeHubTouch = false, nil, nil, nil
header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if not activeHubTouch then activeHubTouch = input; hubDragging = true; hubDragStart = input.Position; hubStartPos = main.Position end end end)
UserInput.InputChanged:Connect(function(input) if hubDragging and input == activeHubTouch and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - hubDragStart; main.Position = UDim2.new(hubStartPos.X.Scale, hubStartPos.X.Offset + delta.X, hubStartPos.Y.Scale, hubStartPos.Y.Offset + delta.Y) end end)
UserInput.InputEnded:Connect(function(input) if input == activeHubTouch then hubDragging = false; activeHubTouch = nil end end)

local isAnimating = false
local function toggleHub()
    if isAnimating then return end; isAnimating = true
    if main.Visible then local closeTween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }); closeTween:Play(); closeTween.Completed:Connect(function() main.Visible = false; main.Size = UDim2.new(0, 700, 0, 400); main.BackgroundTransparency = 0; isAnimating = false end)
    else main.Size = UDim2.new(0, 0, 0, 0); main.BackgroundTransparency = 1; main.Visible = true; local openTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 700, 0, 400), BackgroundTransparency = 0 }); openTween:Play(); openTween.Completed:Connect(function() isAnimating = false end) end
end
btnClose.MouseButton1Click:Connect(toggleHub)

local iconDragStart, iconMoved, activeIconTouch = nil, false, nil
icon.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if not activeIconTouch then activeIconTouch = input; iconDragStart = input.Position; iconMoved = false end end end)
UserInput.InputChanged:Connect(function(input) if input == activeIconTouch and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - iconDragStart; iconDragStart = input.Position; if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then iconMoved = true end; if iconMoved then local vp = Camera.ViewportSize; local abs = icon.AbsolutePosition; icon.Position = UDim2.new(0, math.clamp(abs.X + delta.X, 0, vp.X - icon.AbsoluteSize.X), 0, math.clamp(abs.Y + delta.Y, 0, vp.Y - icon.AbsoluteSize.Y)) end end end)
UserInput.InputEnded:Connect(function(input) if input == activeIconTouch then if iconDragStart and not iconMoved then toggleHub() end; iconDragStart = nil; iconMoved = false; activeIconTouch = nil end end)

LocalPlayer.CharacterAdded:Connect(function(newChar) character = newChar; humanoid = newChar:WaitForChild("Humanoid"); rootPart = newChar:WaitForChild("HumanoidRootPart"); task.wait(0.5); if state.smoothOn then setupBV() else applySpeed(); applyJump() end end)

task.spawn(function() while task.wait(1) do pcall(function() if state.fovOn and Camera.FieldOfView ~= state.fov then Camera.FieldOfView = state.fov end; if humanoid and humanoid.Parent then if state.smoothOn then if humanoid.WalkSpeed ~= state.smoothSpeed then humanoid.WalkSpeed = state.smoothSpeed end else if state.speedOn and humanoid.WalkSpeed ~= state.speed then humanoid.WalkSpeed = state.speed end end; if state.jumpOn and humanoid.JumpPower ~= state.jump then humanoid.JumpPower = state.jump; humanoid.UseJumpPower = true end end; if state.gravityOn and workspace.Gravity ~= state.gravity then workspace.Gravity = state.gravity end end) end end)

print("[LONELY SIDEBAR FULL] Loaded.")