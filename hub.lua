-- ============================================================
-- LONELY HUB v90 FINAL - FULL FIXED VERSION
-- Fix: Smooth Speed (BV+BG không khóa hướng), Speed Display
-- Không đổi tên ngẫu nhiên - giữ nguyên tên gốc
-- ============================================================

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local HUB_FONT = Enum.Font.Creepster
local ESP_FONT = Enum.Font.Creepster

local isDraggingSlider = false
local isLocked = false
local activeSlider = nil

local state = {
    speed = 16, jump = 50, gravity = 190, fov = 70, smoothSpeed = 40,
    speedOn = true, jumpOn = true,
    minZoom = 0.5, maxZoom = 20, unlockFPS = true,
    head = false, torso = false, arms = false, legs = false, accessories = false, allHide = false
}

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local function applySpeed() if humanoid and humanoid.Parent and state.speedOn then humanoid.WalkSpeed = state.speed end end
local function applyJump() if humanoid and humanoid.Parent and state.jumpOn then humanoid.JumpPower = state.jump; humanoid.UseJumpPower = true end end
local function applyGravity() workspace.Gravity = state.gravity end
local function applyFOV() Camera.FieldOfView = state.fov end
local function applyZoom()
    pcall(function()
        LocalPlayer.CameraMinZoomDistance = state.minZoom
        LocalPlayer.CameraMaxZoomDistance = state.maxZoom
    end)
end
applyZoom()

-- ===== UNLOCK FPS LOOP =====
RunService.RenderStepped:Connect(function()
    if not state.unlockFPS then return end
    pcall(function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.CameraMinZoomDistance ~= state.minZoom then
            LocalPlayer.CameraMinZoomDistance = state.minZoom
        end
        if LocalPlayer.CameraMaxZoomDistance ~= state.maxZoom then
            LocalPlayer.CameraMaxZoomDistance = state.maxZoom
        end
    end)
end)

-- ===== HIDE BODY =====
local function hidePart(part) if part and part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end end
local function showPart(part) if part and part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end end

local function applyHide()
    if not character or not character.Parent then return end
    local head = character:FindFirstChild("Head")
    if head then if state.head or state.allHide then hidePart(head) else showPart(head) end end

    local torso = character:FindFirstChild("Torso")
    local upperTorso = character:FindFirstChild("UpperTorso")
    local lowerTorso = character:FindFirstChild("LowerTorso")
    if state.torso or state.allHide then
        if torso then hidePart(torso) end
        if upperTorso then hidePart(upperTorso) end
        if lowerTorso then hidePart(lowerTorso) end
    else
        if torso then showPart(torso) end
        if upperTorso then showPart(upperTorso) end
        if lowerTorso then showPart(lowerTorso) end
    end

    local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftArm")
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightArm")
    if state.arms or state.allHide then
        if leftArm then hidePart(leftArm) end
        if rightArm then hidePart(rightArm) end
    else
        if leftArm then showPart(leftArm) end
        if rightArm then showPart(rightArm) end
    end

    local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLeg")
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLeg")
    if state.legs or state.allHide then
        if leftLeg then hidePart(leftLeg) end
        if rightLeg then hidePart(rightLeg) end
    else
        if leftLeg then showPart(leftLeg) end
        if rightLeg then showPart(rightLeg) end
    end

    for _, acc in ipairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                if state.accessories or state.allHide then hidePart(handle) else showPart(handle) end
            end
        end
    end
end
applyHide()
RunService.Heartbeat:Connect(function() if character and character.Parent then applyHide() end end)

-- ===== TIMER GUI =====
local timerGui = Instance.new("ScreenGui")
timerGui.Name = "TimerDisplay"
timerGui.ResetOnSpawn = false
timerGui.IgnoreGuiInset = true
pcall(function() timerGui.Parent = game:GetService("CoreGui") end)
if not timerGui.Parent then timerGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local autoPressOn = false
local autoPressTimeLeft = 300
local autoPressAccumulated = 0

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 100, 0, 30)
timerLabel.Position = UDim2.new(1, -110, 0, 10)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "5:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 22
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextStrokeTransparency = 0
timerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
timerLabel.TextXAlignment = Enum.TextXAlignment.Right
timerLabel.Visible = false
timerLabel.Parent = timerGui

local clockLabel = Instance.new("TextLabel")
clockLabel.Size = UDim2.new(0, 120, 0, 30)
clockLabel.Position = UDim2.new(1, -130, 0, 45)
clockLabel.BackgroundTransparency = 1
clockLabel.Text = "00:00:00"
clockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
clockLabel.TextSize = 22
clockLabel.Font = Enum.Font.GothamBold
clockLabel.TextStrokeTransparency = 0
clockLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
clockLabel.TextXAlignment = Enum.TextXAlignment.Right
clockLabel.Visible = false
clockLabel.Parent = timerGui

local function pressC()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end)
end

RunService.Heartbeat:Connect(function(dt)
    if autoPressOn then
        autoPressAccumulated = autoPressAccumulated + dt
        if autoPressAccumulated >= 1 then
            autoPressAccumulated = autoPressAccumulated - 1
            autoPressTimeLeft = autoPressTimeLeft - 1
            if autoPressTimeLeft <= 0 then autoPressTimeLeft = 300; pressC() end
            local m = math.floor(autoPressTimeLeft / 60)
            local s = autoPressTimeLeft % 60
            timerLabel.Text = string.format("%d:%02d", m, s)
        end
    else
        local m2 = math.floor(autoPressTimeLeft / 60)
        local s2 = autoPressTimeLeft % 60
        timerLabel.Text = string.format("%d:%02d (off)", m2, s2)
    end
    if clockLabel.Visible then
        local t = os.date("*t")
        clockLabel.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
    end
end)

-- ===== SPEED DISPLAY =====
local speedGui = Instance.new("ScreenGui")
speedGui.Name = "SpeedDisplay"
speedGui.ResetOnSpawn = false
speedGui.IgnoreGuiInset = true
pcall(function() speedGui.Parent = game:GetService("CoreGui") end)
if not speedGui.Parent then speedGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 300, 0, 40)
speedLabel.Position = UDim2.new(0.5, -150, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: 0.0 S/s"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 20
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextStrokeTransparency = 0
speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.Visible = false
speedLabel.Parent = speedGui

local speedDisplayOn = false
local hue = 0

-- ===== SMOOTH SPEED (BV + BG, KHÔNG KHÓA HƯỚNG) =====
local bv = nil
local bg = nil
local smoothOn = false

local function setupBV()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    if not rootPart or not rootPart.Parent then return end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 500
    bv.Parent = rootPart

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(0, 1e5, 0)
    bg.P = 3000
    bg.D = 500
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart

    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = 0
        humanoid.AutoRotate = false
    end
end

local function destroyBV()
    if bv then bv:Destroy(); bv = nil end
    if bg then bg:Destroy(); bg = nil end
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = state.speed
        humanoid.AutoRotate = true
    end
end

-- ===== TRAIL =====
local trailOn = false
local currentTrail = nil

local function createTrail()
    pcall(function()
        if not rootPart or not rootPart.Parent then return end
        if currentTrail then currentTrail:Destroy() end
        for _, v in ipairs(rootPart:GetChildren()) do
            if v.Name == "TrailAtt0" or v.Name == "TrailAtt1" then v:Destroy() end
        end
        local a0 = Instance.new("Attachment"); a0.Name = "TrailAtt0"; a0.Position = Vector3.new(0, 0.5, 0); a0.Parent = rootPart
        local a1 = Instance.new("Attachment"); a1.Name = "TrailAtt1"; a1.Position = Vector3.new(0, -0.5, 0); a1.Parent = rootPart
        local t = Instance.new("Trail")
        t.Name = "CharTrail"
        t.Attachment0 = a0; t.Attachment1 = a1
        t.Lifetime = 1.5; t.MinLength = 0
        t.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        })
        t.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        t.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        t.FaceCamera = true
        t.Parent = rootPart
        currentTrail = t
    end)
end

local function removeTrail()
    pcall(function()
        if currentTrail then currentTrail:Destroy(); currentTrail = nil end
        if rootPart and rootPart.Parent then
            for _, v in ipairs(rootPart:GetChildren()) do
                if v.Name == "TrailAtt0" or v.Name == "TrailAtt1" then v:Destroy() end
            end
        end
    end)
end

-- ===== MAIN HEARTBEAT =====
RunService.Heartbeat:Connect(function(dt)
    if smoothOn and bv and bg and humanoid and humanoid.Parent and rootPart then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0.01 then
            bv.Velocity = Vector3.new(moveDir.X * state.smoothSpeed, 0, moveDir.Z * state.smoothSpeed)
            local lookAt = Vector3.new(moveDir.X, 0, moveDir.Z)
            if lookAt.Magnitude > 0.01 then
                bg.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookAt)
            end
        else
            bv.Velocity = Vector3.new(0, 0, 0)
            bg.CFrame = rootPart.CFrame
        end
    end

    if speedDisplayOn then
        local speed = 0
        if rootPart and rootPart.Parent then
            local v = rootPart.AssemblyLinearVelocity
            speed = math.sqrt(v.X * v.X + v.Z * v.Z)
        end
        speedLabel.Text = string.format("SPEED: %.1f S/s", speed)
        hue = (hue + dt * 0.5) % 1
        speedLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "LonelyHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 999
local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 44, 0, 44)
icon.Position = UDim2.new(0.5, -22, 0.08, 0)
icon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
icon.BackgroundTransparency = 0.15
icon.BorderSizePixel = 0
icon.Text = "L"
icon.TextColor3 = Color3.fromRGB(255, 255, 255)
icon.TextSize = 24
icon.Font = HUB_FONT
icon.Visible = true
icon.AutoButtonColor = false
icon.ZIndex = 100
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
local iconStroke = Instance.new("UIStroke", icon)
iconStroke.Color = Color3.fromRGB(255, 255, 255); iconStroke.Thickness = 2

local iconHue = 0
task.spawn(function()
    while task.wait(0.1) do
        iconHue = (iconHue + 0.05) % 1
        local val = math.floor((math.sin(iconHue * math.pi * 2) * 0.5 + 0.5) * 255)
        icon.BackgroundColor3 = Color3.fromRGB(val, val, val)
        icon.TextColor3 = Color3.fromRGB(255 - val, 255 - val, 255 - val)
    end
end)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 460)
main.Position = UDim2.new(0.5, -210, 0.5, -230)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = false
main.Visible = false
main.ZIndex = 50
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(255, 255, 255); mainStroke.Thickness = 1.5; mainStroke.Transparency = 0.4

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.ZIndex = 51
header.Active = false
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local headerBottom = Instance.new("Frame")
headerBottom.Size = UDim2.new(1, 0, 0, 14)
headerBottom.Position = UDim2.new(0, 0, 1, -14)
headerBottom.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
headerBottom.BackgroundTransparency = 0.15
headerBottom.BorderSizePixel = 0
headerBottom.ZIndex = 51
headerBottom.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LONELY"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 24
title.Font = HUB_FONT
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 52
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 80, 1, 0)
subtitle.Position = UDim2.new(1, -100, 0, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "HUB v83"
subtitle.TextColor3 = Color3.fromRGB(80, 80, 80)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Right
subtitle.ZIndex = 52
subtitle.Parent = header

local hubDragStart, hubStartPos, hubDragging = nil, nil, false
header.InputBegan:Connect(function(input)
    if isDraggingSlider then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hubDragging = true; hubDragStart = input.Position; hubStartPos = main.Position
    end
end)
UserInput.InputChanged:Connect(function(input)
    if not hubDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - hubDragStart
        main.Position = UDim2.new(hubStartPos.X.Scale, hubStartPos.X.Offset + delta.X, hubStartPos.Y.Scale, hubStartPos.Y.Offset + delta.Y)
    end
end)
UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hubDragging = false end
end)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 30, 0, 30)
btnMin.Position = UDim2.new(1, -72, 0, 10)
btnMin.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btnMin.BackgroundTransparency = 0.75
btnMin.BorderSizePixel = 0
btnMin.Text = "-"
btnMin.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMin.TextSize = 18
btnMin.Font = HUB_FONT
btnMin.ZIndex = 55
btnMin.AutoButtonColor = false
btnMin.Parent = header
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 8)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -38, 0, 10)
btnClose.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btnClose.BackgroundTransparency = 0.75
btnClose.BorderSizePixel = 0
btnClose.Text = "X"
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.TextSize = 16
btnClose.Font = HUB_FONT
btnClose.ZIndex = 55
btnClose.AutoButtonColor = false
btnClose.Parent = header
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 8)

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -70)
container.Position = UDim2.new(0, 10, 0, 60)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ZIndex = 51
container.ScrollBarThickness = 3
container.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.ScrollingDirection = Enum.ScrollingDirection.Y
container.ClipsDescendants = true
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

local padding = Instance.new("UIPadding")
padding.PaddingRight = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = container

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end)

local function makeSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = HUB_FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 52
    lbl.Parent = container
    return lbl
end

local function makeSlider(name, default, min, max, step, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.85
    card.BorderSizePixel = 0
    card.ZIndex = 51
    card.Active = false
    card.Parent = container
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(255, 255, 255); cardStroke.Thickness = 1; cardStroke.Transparency = 0.7

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 16
    lbl.Font = HUB_FONT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 52
    lbl.Parent = card

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.18, 0, 0, 26)
    textBox.Position = UDim2.new(0.78, 0, 0, 5)
    textBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textBox.BackgroundTransparency = 0.7
    textBox.BorderSizePixel = 0
    textBox.Text = tostring(default)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 15
    textBox.Font = HUB_FONT
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 52
    textBox.Parent = card
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
    local tbStroke = Instance.new("UIStroke", textBox)
    tbStroke.Color = Color3.fromRGB(255, 255, 255); tbStroke.Thickness = 1; tbStroke.Transparency = 0.7

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    track.BackgroundTransparency = 0.6
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.ZIndex = 52
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 0.1
    fill.BorderSizePixel = 0
    fill.ZIndex = 53
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 54
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = Color3.fromRGB(0, 0, 0); knobStroke.Thickness = 2

    local localDrag = false
    local currentVal = default

    local function setValue(val, fromTextBox)
        if isLocked and not fromTextBox then return end
        val = math.clamp(val, min, max)
        currentVal = val
        local alpha = (val - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -10, 0.5, -10)
        if not fromTextBox then textBox.Text = tostring(val) end
        callback(val)
    end

    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = min + relX * (max - min)
        local val = math.floor(raw / step + 0.5) * step
        setValue(val, false)
    end

    track.InputBegan:Connect(function(input)
        if isLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local knobCenterX = knob.AbsolutePosition.X + knob.AbsoluteSize.X / 2
            if math.abs(input.Position.X - knobCenterX) > 30 then return end
            if activeSlider ~= nil then return end
            activeSlider = track
            isDraggingSlider = true
            hubDragging = false
            container.ScrollingEnabled = false
            localDrag = true
        end
    end)

    UserInput.InputChanged:Connect(function(input)
        if not localDrag then return end
        if activeSlider ~= track then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromInput(input)
        end
    end)

    UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if localDrag then
                localDrag = false
                isDraggingSlider = false
                container.ScrollingEnabled = true
                if activeSlider == track then activeSlider = nil end
            end
        end
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        if isLocked then
            textBox.Text = tostring(currentVal)
            if enterPressed then textBox:ReleaseFocus() end
            return
        end
        local num = tonumber(textBox.Text)
        if num then setValue(num, true) else textBox.Text = tostring(currentVal) end
        if enterPressed then textBox:ReleaseFocus() end
    end)

    return { set = function(v) setValue(v, false) end, get = function() return currentVal end }
end

local function makeToggle(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = HUB_FONT
    btn.AutoButtonColor = false
    btn.ZIndex = 51
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(255, 255, 255); btnStroke.Thickness = 1; btnStroke.Transparency = 0.7

    local on = defaultState or false
    if on then
        btn.Text = name .. ": ON"
        btn.BackgroundTransparency = 0.6
        btnStroke.Transparency = 0.4
    end

    btn.MouseButton1Click:Connect(function()
        if isLocked then return end
        on = not on
        btn.Text = name .. ": " .. (on and "ON" or "OFF")
        btn.BackgroundTransparency = on and 0.6 or 0.85
        btnStroke.Transparency = on and 0.4 or 0.7
        callback(on)
    end)

    return {
        set = function(v)
            on = v
            btn.Text = name .. ": " .. (on and "ON" or "OFF")
            btn.BackgroundTransparency = on and 0.6 or 0.85
            btnStroke.Transparency = on and 0.4 or 0.7
            callback(on)
        end,
        get = function() return on end
    }
end

makeSection("> STATS")
local speedSlider = makeSlider("SPEED", state.speed, 0, 500, 2, function(v) state.speed = v; if not smoothOn then applySpeed() end end)
local jumpSlider = makeSlider("JUMP", state.jump, 0, 500, 5, function(v) state.jump = v; applyJump() end)
local gravSlider = makeSlider("GRAVITY", state.gravity, 0, 500, 10, function(v) state.gravity = v; applyGravity() end)
local fovSlider = makeSlider("FOV", state.fov, 70, 160, 5, function(v) state.fov = v; applyFOV() end)
local smoothSpeedSlider = makeSlider("SMOOTH SPD", state.smoothSpeed, 0, 500, 2, function(v) state.smoothSpeed = v end)

makeSection("> ZOOM")
local minZoomSlider = makeSlider("MIN ZOOM", state.minZoom, 0.5, 20, 0.5, function(v) state.minZoom = v end)
local maxZoomSlider = makeSlider("MAX ZOOM", state.maxZoom, 0.5, 1000, 5, function(v) state.maxZoom = v end)

local unlockToggle = makeToggle("UNLOCK FPS", true, function(v)
    state.unlockFPS = v
    if not v then
        pcall(function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 0.5
        end)
    end
end)

makeSection("> HIDE BODY")
local headToggle = makeToggle("HEAD", false, function(v) state.head = v end)
local torsoToggle = makeToggle("TORSO", false, function(v) state.torso = v end)
local armsToggle = makeToggle("ARMS", false, function(v) state.arms = v end)
local legsToggle = makeToggle("LEGS", false, function(v) state.legs = v end)
local accToggle = makeToggle("ACCESSORIES", false, function(v) state.accessories = v end)
local allHideToggle = makeToggle("ALL HIDE", false, function(v)
    state.allHide = v
    headToggle.set(v); torsoToggle.set(v); armsToggle.set(v); legsToggle.set(v); accToggle.set(v)
end)

makeSection("> LOCKS")
local speedToggle = makeToggle("SPEED LOCK", true, function(v) state.speedOn = v end)
local jumpToggle = makeToggle("JUMP LOCK", true, function(v) state.jumpOn = v end)

makeSection("> TOGGLES")
local infJumpOn = false
local infJumpToggle = makeToggle("INF JUMP", false, function(v) infJumpOn = v end)

UserInput.JumpRequest:Connect(function()
    if isLocked then return end
    if infJumpOn and humanoid and humanoid.Parent then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local speedDisplayToggle = makeToggle("SPEED DISPLAY", false, function(v) speedDisplayOn = v; speedLabel.Visible = v end)

local smoothToggle = makeToggle("SMOOTH SPEED", false, function(v)
    smoothOn = v
    if v then
        state.speedOn = false
        if speedToggle then speedToggle.set(false) end
        setupBV()
    else
        destroyBV()
        state.speedOn = true
        if speedToggle then speedToggle.set(true) end
    end
end)

local trailToggle = makeToggle("TRAIL", false, function(v)
    trailOn = v
    if v then createTrail() else removeTrail() end
end)

local autoPressToggle = makeToggle("AUTO PRESS C", false, function(v)
    autoPressOn = v
    timerLabel.Visible = v
    if v then autoPressTimeLeft = 300; autoPressAccumulated = 0 end
end)

local realClockToggle = makeToggle("REAL CLOCK", false, function(v) clockLabel.Visible = v end)

-- ===== ESP =====
local espEnabled = false
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    if not player.Character then return end
    if not player.Character:FindFirstChild("Head") then return end
    local head = player.Character:FindFirstChild("Head")
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Size = UDim2.new(0, 240, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = espEnabled
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextSize = 22
    label.Font = ESP_FONT
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = billboard

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160,160,160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    })
    gradient.Rotation = 90
    gradient.Parent = label

    espObjects[player] = billboard
end

local function removeESP(player)
    if espObjects[player] then
        pcall(function() espObjects[player]:Destroy() end)
        espObjects[player] = nil
    end
end

local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then createESP(player) end
    end
end

local function hookPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then createESP(player) end
    end)
    player.CharacterRemoving:Connect(function() removeESP(player) end)
end

for _, player in ipairs(Players:GetPlayers()) do hookPlayer(player) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

local espToggle = makeToggle("ESP", false, function(v)
    espEnabled = v
    if v then refreshESP() else for player, _ in pairs(espObjects) do removeESP(player) end end
end)

makeSection("> UTILS")
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(1, 0, 0, 40)
lockBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.BackgroundTransparency = 0.85
lockBtn.BorderSizePixel = 0
lockBtn.Text = "LOCK: OFF"
lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.TextSize = 16
lockBtn.Font = HUB_FONT
lockBtn.AutoButtonColor = false
lockBtn.ZIndex = 51
lockBtn.Parent = container
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 10)
local lockStroke = Instance.new("UIStroke", lockBtn)
lockStroke.Color = Color3.fromRGB(255, 255, 255); lockStroke.Thickness = 1; lockStroke.Transparency = 0.7

lockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    lockBtn.Text = "LOCK: " .. (isLocked and "ON" or "OFF")
    lockBtn.BackgroundTransparency = isLocked and 0.6 or 0.85
    lockStroke.Transparency = isLocked and 0.4 or 0.7
end)

local btnReset = Instance.new("TextButton")
btnReset.Size = UDim2.new(1, 0, 0, 38)
btnReset.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btnReset.BackgroundTransparency = 0.55
btnReset.BorderSizePixel = 0
btnReset.Text = "RESET ALL"
btnReset.TextColor3 = Color3.fromRGB(0, 0, 0)
btnReset.TextSize = 16
btnReset.Font = HUB_FONT
btnReset.AutoButtonColor = false
btnReset.ZIndex = 51
btnReset.Parent = container
Instance.new("UICorner", btnReset).CornerRadius = UDim.new(0, 10)

btnReset.MouseButton1Click:Connect(function()
    if isLocked then return end
    speedSlider.set(16); state.speed = 16; applySpeed()
    jumpSlider.set(50); state.jump = 50; applyJump()
    gravSlider.set(190); state.gravity = 190; applyGravity()
    fovSlider.set(70); state.fov = 70; applyFOV()
    smoothSpeedSlider.set(40); state.smoothSpeed = 40
    minZoomSlider.set(0.5); state.minZoom = 0.5
    maxZoomSlider.set(20); state.maxZoom = 20
    speedToggle.set(true); state.speedOn = true
    jumpToggle.set(true); state.jumpOn = true
    unlockToggle.set(true); state.unlockFPS = true
    headToggle.set(false); state.head = false
    torsoToggle.set(false); state.torso = false
    armsToggle.set(false); state.arms = false
    legsToggle.set(false); state.legs = false
    accToggle.set(false); state.accessories = false
    allHideToggle.set(false); state.allHide = false
    infJumpToggle.set(false); infJumpOn = false
    speedDisplayToggle.set(false); speedDisplayOn = false; speedLabel.Visible = false
    smoothToggle.set(false); smoothOn = false
    destroyBV()
    trailToggle.set(false); trailOn = false
    removeTrail()
    autoPressToggle.set(false); autoPressOn = false; timerLabel.Visible = false
    autoPressTimeLeft = 300
    realClockToggle.set(false); clockLabel.Visible = false
end)

btnMin.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

local iconDragStart, iconStartPos, iconMoved = nil, nil, false
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragStart = input.Position
        iconStartPos = icon.Position
        iconMoved = false
    end
end)
UserInput.InputChanged:Connect(function(input)
    if not iconDragStart then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - iconDragStart
        if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then iconMoved = true end
        if iconMoved then
            icon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end
end)
UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if iconDragStart and not iconMoved then main.Visible = true; icon.Visible = false end
        iconDragStart = nil
        iconMoved = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if smoothOn then setupBV() else applySpeed(); applyJump() end
    if trailOn then createTrail() end
    applyHide()
end)

applySpeed(); applyJump(); applyGravity(); applyFOV(); applyZoom()

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Camera.FieldOfView ~= state.fov then Camera.FieldOfView = state.fov end
            if humanoid and humanoid.Parent then
                if smoothOn then
                    if humanoid.WalkSpeed ~= 0 then humanoid.WalkSpeed = 0 end
                else
                    if state.speedOn and humanoid.WalkSpeed ~= state.speed then humanoid.WalkSpeed = state.speed end
                end
                if state.jumpOn and humanoid.JumpPower ~= state.jump then
                    humanoid.JumpPower = state.jump
                    humanoid.UseJumpPower = true
                end
            end
            if workspace.Gravity ~= state.gravity then workspace.Gravity = state.gravity end
        end)
    end
end)

print("[Lonely Hub v90] READY")