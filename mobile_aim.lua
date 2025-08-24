-- Ultra Mobile AIM Script for Madder Mystery by Beta01
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Конфигурация по умолчанию
local Settings = {
    Enabled = true,
    FOV = 120,
    Smoothness = 0.2,
    TeamCheck = true,
    WallCheck = true,
    ShowFOV = true
}

-- Удаляем старый GUI если существует
if CoreGui:FindFirstChild("MobileAimGUI") then
    CoreGui.MobileAimGUI:Destroy()
end

-- Создание мобильного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Основной фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "Mobile Aim Settings"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Кнопка сворачивания
local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "−"
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(1, -40, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Parent = MainFrame

-- Контейнер для элементов управления
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
ScrollFrame.Parent = MainFrame

-- Элементы управления
local controls = {
    {"Enabled", "Toggle", "Активировать аим"},
    {"FOV", "Slider", "Поле зрения: ", 50, 200},
    {"Smoothness", "Slider", "Плавность: ", 0.1, 1},
    {"TeamCheck", "Toggle", "Игнорировать союзников"},
    {"WallCheck", "Toggle", "Проверка стен"},
    {"ShowFOV", "Toggle", "Показать FOV круг"}
}

local function createControl(yPosition, config)
    local name, type, text, min, max = unpack(config)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, yPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollFrame
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame
    
    if type == "Toggle" then
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 30)
        toggle.Position = UDim2.new(1, -50, 0.5, -15)
        toggle.Text = Settings[name] and "ON" or "OFF"
        toggle.BackgroundColor3 = Settings[name] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Font = Enum.Font.SourceSansBold
        toggle.Name = name
        toggle.Parent = frame
        
        toggle.MouseButton1Click:Connect(function()
            Settings[name] = not Settings[name]
            toggle.Text = Settings[name] and "ON" or "OFF"
            toggle.BackgroundColor3 = Settings[name] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        end)
        
    elseif type == "Slider" then
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = tostring(Settings[name])
        valueLabel.Size = UDim2.new(0, 50, 1, 0)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.TextSize = 16
        valueLabel.Parent = frame
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0.7, -60, 0, 10)
        sliderFrame.Position = UDim2.new(0, 0, 1, -15)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Settings[name] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderFrame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 3, 0)
        button.Position = UDim2.new(0, 0, -1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = sliderFrame
        
        button.MouseButton1Down:Connect(function(x, y)
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    connection:Disconnect()
                    return
                end
                
                local mousePos = UserInputService:GetMouseLocation()
                local percent = math.clamp((mousePos.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                Settings[name] = min + (max - min) * percent
                fill.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = string.format(type == "Smoothness" and "%.2f" or "%.0f", Settings[name])
            end)
        end)
    end
end

-- Создание элементов управления
for i, config in ipairs(controls) do
    createControl((i-1) * 55, config)
end

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #controls * 55)

-- Функционал сворачивания
local minimized = false
ToggleButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ToggleButton.Text = minimized and "+" or "−"
    
    if minimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        ScrollFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        ScrollFrame.Visible = true
    end
end)

-- Функция перетаскивания окна
local dragging = false
local dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- FOV круг
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
FOVCircle.ZIndex = 0
FOVCircle.Parent = ScreenGui

-- Кнопка активации аима на экране
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 80, 0, 80)
AimButton.Position = UDim2.new(1, -90, 1, -90)
AimButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AimButton.BackgroundTransparency = 0.5
AimButton.Text = "AIM"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Font = Enum.Font.SourceSansBold
AimButton.TextSize = 16
AimButton.Parent = ScreenGui

-- Основная логика аимбота
local function FindTarget()
    if not Settings.Enabled then return nil end
    
    local closestTarget = nil
    local shortestDelta = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then continue end
        
        if Settings.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            continue
        end
        
        if Settings.WallCheck then
            local origin = Camera.CFrame.Position
            local direction = (rootPart.Position - origin).Unit * 1000
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            local result = workspace:Raycast(origin, direction, raycastParams)
            
            if result and result.Instance:FindFirstAncestor(player.Name) == nil then
                continue
            end
        end

        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local delta = (center - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
            
            if delta < shortestDelta then
                shortestDelta = delta
                closestTarget = rootPart
            end
        end
    end
    
    return closestTarget
end

-- Обработка касаний для аимбота
AimButton.MouseButton1Down:Connect(function()
    if not Settings.Enabled then return end
    
    local target = FindTarget()
    if target then
        local startCFrame = Camera.CFrame
        local endCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        
        local tweenInfo = TweenInfo.new(Settings.Smoothness, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = endCFrame})
        tween:Play()
    end
end)

-- Автоматическое прицеливание при наведении на врага
local autoAimConnection
autoAimConnection = RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    local target = FindTarget()
    if target then
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

-- Обновление FOV круга
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
end)

-- Кнопка закрытия GUI
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if autoAimConnection then
        autoAimConnection:Disconnect()
    end
end)

print("✅ Ultra Mobile AIM активирован")
print("📱 Полная совместимость с мобильными устройствами")
print("🎯 Автоматическое прицеливание + кнопка ручного управления")          
