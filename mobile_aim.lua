-- ULTIMATE AIMBOT - ЧАСТЬ 1/2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Конфигурация по умолчанию
local Settings = {
    Enabled = true,
    FOV = 120,
    Smoothness = 0.2,
    TeamCheck = true,
    WallCheck = true,
    ShowFOV = true,
    XRay = false,
    ShowRoles = true,
    WeaponESP = true,
    SimpleRadar = true
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

-- Иконка для открытия/закрытия меню
local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Text = "⚙️"
ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
ToggleIcon.Position = UDim2.new(0, 10, 0, 10)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleIcon.BackgroundTransparency = 0.5
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.Font = Enum.Font.SourceSansBold
ToggleIcon.TextSize = 24
ToggleIcon.Parent = ScreenGui

-- Основной фрейм меню (изначально скрыт)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Visible = false
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

-- Контейнер для элементов управления
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ScrollFrame.Parent = MainFrame

-- Элементы управления
local controls = {
    {"Enabled", "Toggle", "Активировать аим"},
    {"FOV", "Slider", "Поле зрения: ", 50, 200},
    {"Smoothness", "Slider", "Плавность: ", 0.1, 1},
    {"TeamCheck", "Toggle", "Игнорировать союзников"},
    {"WallCheck", "Toggle", "Проверка стен"},
    {"ShowFOV", "Toggle", "Показать FOV круг"},
    {"XRay", "Toggle", "X-Ray видение"},
    {"ShowRoles", "Toggle", "Показывать роли"},
    {"WeaponESP", "Toggle", "Подсветка оружия"},
    {"SimpleRadar", "Toggle", "Простой радар"}
}

-- Функция для создания элементов управления
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
        
        button.MouseButton1Down:Connect(function()
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
                valueLabel.Text = string.format("Smoothness" and "%.2f" or "%.0f", Settings[name])
            end)
        end)
    end
end

-- Создание элементов управления
for i, config in ipairs(controls) do
    createControl((i-1) * 55, config)
end

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #controls * 55)

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

-- Функция для определения ролей (убийца, шериф)
local function getPlayerRole(player)
    if not player.Character then return "Unknown" end
    
    -- Проверка на убийцу (обычно имеет нож)
    if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    
    -- Проверка на шерифа (обычно имеет оружие)
    if player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    
    return "Innocent"
end

-- Основная логика аимбота
local function FindTarget()
    if not Settings.Enabled or not LocalPlayer.Character then return nil end
    
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

-- Автоматическое прицеливание
local autoAimConnection
autoAimConnection = RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not LocalPlayer.Character then return end
    
    local target = FindTarget()
    if target then
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

-- Функция переключения видимости меню
ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Кнопка закрытия GUI в меню
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Уведомление об успешной загрузке
local function showNotification(message, duration)
    local notif = Instance.new("TextLabel")
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0.1, 0)
    notif.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.SourceSansBold
    notif.TextSize = 16
    notif.Parent = ScreenGui
    
    delay(duration or 3, function()
        if notif then
            notif:Destroy()
        end
    end)
end

showNotification("✅ Часть 1/2 загружена! Запустите вторую часть.", 5)

print("✅ Часть 1/2 загружена - Основной функционал")
print("⚙️  GUI настроек создано")
print("🎯 Аимбот активирован")
print("⏳ Ожидание второй части...")
-- ULTIMATE AIMBOT - ЧАСТЬ 2/2
wait(1) -- Даем время первой части загрузиться

-- X-Ray функция
local xRayParts = {}
local function updateXRay()
    if not Settings.XRay then
        -- Отключаем X-Ray
        for _, part in pairs(xRayParts) do
            if part then
                part.LocalTransparencyModifier = 0
            end
        end
        xRayParts = {}
        return
    end
    
    -- Включаем X-Ray
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0.7
                    table.insert(xRayParts, part)
                end
            end
        end
    end
end

-- Функция для отображения ролей над игроками
local roleLabels = {}
local function updateRoleLabels()
    if not Settings.ShowRoles then
        -- Удаляем все метки
        for _, label in pairs(roleLabels) do
            if label then
                label:Destroy()
            end
        end
        roleLabels = {}
        return
    end
    
    -- Обновляем метки
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local role = getPlayerRole(player)
                
                -- Создаем или обновляем метку
                if not roleLabels[player] then
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Size = UDim2.new(0, 100, 0, 40)
                    billboardGui.AlwaysOnTop = true
                    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
                    billboardGui.Adornee = humanoidRootPart
                    billboardGui.Parent = ScreenGui
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = role
                    textLabel.TextColor3 = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                                         role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                                         Color3.fromRGB(255, 255, 255)
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextSize = 18
                    textLabel.Parent = billboardGui
                    
                    roleLabels[player] = billboardGui
                else
                    roleLabels[player].TextLabel.Text = role
                    roleLabels[player].TextLabel.TextColor3 = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                                                             role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                                                             Color3.fromRGB(255, 255, 255)
                    roleLabels[player].Adornee = humanoidRootPart
                end
            end
        end
    end
end

-- ПРОСТОЙ РАДАР (гарантированно работающий)
local radarMarkers = {}
local function updateSimpleRadar()
    if not Settings.SimpleRadar then
        for _, marker in pairs(radarMarkers) do
            if marker then
                marker:Destroy()
            end
        end
        radarMarkers = {}
        return
    end
    
    -- Создаем радар если его нет
    if not ScreenGui:FindFirstChild("RadarFrame") then
        local radarFrame = Instance.new("Frame")
        radarFrame.Name = "RadarFrame"
        radarFrame.Size = UDim2.new(0, 150, 0, 150)
        radarFrame.Position = UDim2.new(0, 20, 1, -170)
        radarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        radarFrame.BackgroundTransparency = 0.7
        radarFrame.BorderSizePixel = 2
        radarFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        radarFrame.Parent = ScreenGui
        
        -- Центр радара
        local center = Instance.new("Frame")
        center.Size = UDim2.new(0, 4, 0, 4)
        center.Position = UDim2.new(0.5, -2, 0.5, -2)
        center.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        center.BorderSizePixel = 0
        center.Parent = radarFrame
    end
    
    -- Очищаем старые маркеры
    for _, marker in pairs(radarMarkers) do
        if marker then
            marker:Destroy()
        end
    end
    radarMarkers = {}
    
    local radarFrame = ScreenGui:FindFirstChild("RadarFrame")
    if not radarFrame or not LocalPlayer.Character then return end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    -- Добавляем маркеры для игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local relativePos = rootPart.Position - localRoot.Position
                local distance = relativePos.Magnitude
                
                if distance < 100 then -- Только ближайшие игроки
                    local role = getPlayerRole(player)
                    local color = role == "Murderer" and Color3.fromRGB(255, 0, 0) or
                                 role == "Sheriff" and Color3.fromRGB(0, 0, 255) or
                                 Color3.fromRGB(255, 255, 255)
                    
                    local angle = math.atan2(relativePos.Z, relativePos.X)
                    local normalizedDistance = math.min(distance / 100, 1)
                    
                    local marker = Instance.new("Frame")
                    marker.Size = UDim2.new(0, 6, 0, 6)
                    marker.Position = UDim2.new(
                        0.5 + math.cos(angle) * normalizedDistance * 0.4 * 75 - 3,
                        0.5 + math.sin(angle) * normalizedDistance * 0.4 * 75 - 3
                    )
                    marker.BackgroundColor3 = color
                    marker.BorderSizePixel = 0
                    marker.Parent = radarFrame
                    
                    table.insert(radarMarkers, marker)
                end
            end
        end
    end
end

-- WEAPON ESP: Подсветка оружия на земле
local weaponHighlights = {}
local function updateWeaponESP()
    if not Settings.WeaponESP then
        for _, highlight in pairs(weaponHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        weaponHighlights = {}
        return
    end
    
    -- Ищем оружие на земле
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("knife")) then
            if not weaponHighlights[item] then
                -- Создаем подсветку для оружия
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = item
                highlight.Parent = item
                
                -- Добавляем текст с названием оружия
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Adornee = item.Handle or item:FindFirstChildWhichIsA("BasePart") or item
                billboard.Parent = item
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = item.Name
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 14
                textLabel.Parent = billboard
                
                weaponHighlights[item] = {highlight, billboard}
            end
        end
    end
    
    -- Удаляем подсветку для оружия которое исчезло
    for weapon, highlight in pairs(weaponHighlights) do
        if not weapon or not weapon.Parent or weapon.Parent == nil then
            if highlight[1] then highlight[1]:Destroy() end
            if highlight[2] then highlight[2]:Destroy() end
            weaponHighlights[weapon] = nil
        end
    end
end

-- Основной цикл обновления
RunService.RenderStepped:Connect(function()
    -- Обновляем видимость FOV круга
    if FOVCircle then
        FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
    end
    
    -- Обновляем X-Ray и метки ролей
    updateXRay()
    updateRoleLabels()
    
    -- Обновляем радар и Weapon ESP
    updateSimpleRadar()
    updateWeaponESP()
end)

-- Скрипт с кнопкой для анимации падения и изменения скина
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Конфигурация
local FALL_ANIMATION_ENABLED = false
local CUSTOM_SKIN_ENABLED = false
local SKIN_COLOR = Color3.fromRGB(255, 0, 0) -- Красный цвет

-- Создаем GUI с кнопкой
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationControlGUI"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0, 20, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
button.BorderSizePixel = 0
button.Text = "Включить анимацию"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16
button.Parent = screenGui

-- Создаем анимацию падения
local function createFallAnimation()
    -- Создаем анимацию с помощью ключевых кадров
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://35654637" -- ID анимации падения
    
    local animationTrack = Humanoid:LoadAnimation(animation)
    animationTrack.Looped = true
    animationTrack.Priority = Enum.AnimationPriority.Action
    
    return animationTrack
end

-- Загружаем анимацию
local fallAnimationTrack = createFallAnimation()

-- Функция для анимации падения
local function playFallAnimation()
    if not FALL_ANIMATION_ENABLED then return end
    
    -- Анимируем падение с помощью изменения положения частей тела
    while FALL_ANIMATION_ENABLED and Character and Humanoid.Health > 0 do
        -- Проверяем, стоит ли персонаж
        if Humanoid.MoveDirection.Magnitude < 0.1 then
            -- Воспроизводим анимацию падения
            fallAnimationTrack:Play()
            
            -- Добавляем дополнительную анимацию, наклоняя тело
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(10))
            wait(0.2)
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(-10))
            wait(0.2)
        else
            fallAnimationTrack:Stop()
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0, 0)
        end
        
        wait(0.1)
    end
    
    -- Останавливаем анимацию при выходе из цикла
    fallAnimationTrack:Stop()
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0, 0)
    end
end

-- Изменение внешнего вида (скина)
local function applyCustomSkin()
    if not CUSTOM_SKIN_ENABLED then return end
    
    -- Ждем полной загрузки персонажа
    Character:WaitForChild("Body Colors")
    
    -- Изменяем цвет тела
    local bodyColors = Character:FindFirstChild("Body Colors")
    if bodyColors then
        bodyColors.HeadColor3 = SKIN_COLOR
        bodyColors.LeftArmColor3 = SKIN_COLOR
        bodyColors.RightArmColor3 = SKIN_COLOR
        bodyColors.LeftLegColor3 = SKIN_COLOR
        bodyColors.RightLegColor3 = SKIN_COLOR
        bodyColors.TorsoColor3 = SKIN_COLOR
    end
    
    -- Создаем специальный материал для эффекта
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new(SKIN_COLOR)
        end
    end
    
    -- Создаем свечение
    local glow = Instance.new("SurfaceLight")
    glow.Brightness = 5
    glow.Range = 10
    glow.Color = SKIN_COLOR
    glow.Parent = HumanoidRootPart
end

-- Функция для восстановления оригинального скина
local function restoreOriginalSkin()
    -- Восстанавливаем стандартный материал
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Material = Enum.Material.Plastic
            part.BrickColor = BrickColor.new("Medium stone grey") -- Стандартный цвет
        end
    end
    
    -- Удаляем свечение
    if HumanoidRootPart:FindFirstChildWhichIsA("SurfaceLight") then
        HumanoidRootPart:FindFirstChildWhichIsA("SurfaceLight"):Destroy()
    end
    
    -- Восстанавливаем стандартные цвета тела
    local bodyColors = Character:FindFirstChild("Body Colors")
    if bodyColors then
        bodyColors.HeadColor3 = Color3.fromRGB(239, 239, 239)
        bodyColors.LeftArmColor3 = Color3.fromRGB(239, 239, 239)
        bodyColors.RightArmColor3 = Color3.fromRGB(239, 239, 239)
        bodyColors.LeftLegColor3 = Color3.fromRGB(239, 239, 239)
        bodyColors.RightLegColor3 = Color3.fromRGB(239, 239, 239)
        bodyColors.TorsoColor3 = Color3.fromRGB(239, 239, 239)
    end
end

-- Обработчик нажатия кнопки
button.MouseButton1Click:Connect(function()
    FALL_ANIMATION_ENABLED = not FALL_ANIMATION_ENABLED
    CUSTOM_SKIN_ENABLED = not CUSTOM_SKIN_ENABLED
    
    if FALL_ANIMATION_ENABLED then
        button.Text = "Выключить анимацию"
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        applyCustomSkin()
        spawn(playFallAnimation)
    else
        button.Text = "Включить анимацию"
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        restoreOriginalSkin()
    end
end)

-- Обработчик изменения персонажа
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Пересоздаем анимацию для нового персонажа
    fallAnimationTrack = createFallAnimation()
    
    -- Применяем изменения, если они активны
    if CUSTOM_SKIN_ENABLED then
        applyCustomSkin()
    end
    
    if FALL_ANIMATION_ENABLED then
        spawn(playFallAnimation)
    end
end)

print("✅ GUI с кнопкой создан!")
print("🎮 Нажмите кнопку для включения/выключения анимации и скина")
showNotification("✅ Часть 2/2 загружена! Все функции активированы.", 5)

print("✅ Часть 2/2 загружена - Дополнительные функции")
print("🔫 Weapon ESP: Видно оружие на земле")
print("📡 Simple Radar: Радар активирован")
print("👁️ X-Ray и роли работают")
print("🎉 Весь функционал активирован!")
