-- ULTIMATE OPTIMIZED MADDER MYSTERY SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    SimpleRadar = true,
    AutoPickup = true, -- Автоподбор оружия
    RoleSelector = false, -- Выбор роли
    AntiLag = true -- Антилаг режим
}

-- Оптимизация: кэшируем часто используемые функции
local table_insert = table.insert
local math_clamp = math.clamp
local math_atan2 = math.atan2
local math_cos = math.cos
local math_sin = math.sin
local math_min = math.min
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local UDim2_new = UDim2.new
local CFrame_new = CFrame.new
local Color3_fromRGB = Color3.fromRGB
local Instance_new = Instance.new

-- Удаляем старый GUI если существует
if CoreGui:FindFirstChild("MobileAimGUI") then
    CoreGui.MobileAimGUI:Destroy()
end

-- Создание мобильного GUI
local ScreenGui = Instance_new("ScreenGui")
ScreenGui.Name = "MobileAimGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Иконка для открытия/закрытия меню
local ToggleIcon = Instance_new("TextButton")
ToggleIcon.Text = "⚙️"
ToggleIcon.Size = UDim2_new(0, 50, 0, 50)
ToggleIcon.Position = UDim2_new(0, 10, 0, 10)
ToggleIcon.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
ToggleIcon.BackgroundTransparency = 0.5
ToggleIcon.TextColor3 = Color3_fromRGB(255, 255, 255)
ToggleIcon.Font = Enum.Font.SourceSansBold
ToggleIcon.TextSize = 24
ToggleIcon.Parent = ScreenGui

-- Основной фрейм меню (изначально скрыт)
local MainFrame = Instance_new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2_new(0, 300, 0, 500)
MainFrame.Position = UDim2_new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3_fromRGB(80, 80, 80)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance_new("TextLabel")
Title.Text = "Mobile Aim Settings"
Title.Size = UDim2_new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3_fromRGB(30, 30, 30)
Title.TextColor3 = Color3_fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Контейнер для элементов управления
local ScrollFrame = Instance_new("ScrollingFrame")
ScrollFrame.Size = UDim2_new(1, -10, 1, -50)
ScrollFrame.Position = UDim2_new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2_new(0, 0, 0, 480)
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
    {"SimpleRadar", "Toggle", "Простой радар"},
    {"AutoPickup", "Toggle", "Автоподбор оружия"},
    {"AntiLag", "Toggle", "Антилаг режим"}
}

-- Функция для создания элементов управления
local function createControl(yPosition, config)
    local name, type, text, min, max = unpack(config)
    
    local frame = Instance_new("Frame")
    frame.Size = UDim2_new(1, -10, 0, 50)
    frame.Position = UDim2_new(0, 5, 0, yPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollFrame
    
    local label = Instance_new("TextLabel")
    label.Text = text
    label.Size = UDim2_new(0.7, 0, 1, 0)
    label.TextColor3 = Color3_fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = frame
    
    if type == "Toggle" then
        local toggle = Instance_new("TextButton")
        toggle.Size = UDim2_new(0, 50, 0, 30)
        toggle.Position = UDim2_new(1, -50, 0.5, -15)
        toggle.Text = Settings[name] and "ON" or "OFF"
        toggle.BackgroundColor3 = Settings[name] and Color3_fromRGB(0, 170, 0) or Color3_fromRGB(170, 0, 0)
        toggle.TextColor3 = Color3_fromRGB(255, 255, 255)
        toggle.Font = Enum.Font.SourceSansBold
        toggle.Name = name
        toggle.Parent = frame
        
        toggle.MouseButton1Click:Connect(function()
            Settings[name] = not Settings[name]
            toggle.Text = Settings[name] and "ON" or "OFF"
            toggle.BackgroundColor3 = Settings[name] and Color3_fromRGB(0, 170, 0) or Color3_fromRGB(170, 0, 0)
        end)
        
    elseif type == "Slider" then
        local valueLabel = Instance_new("TextLabel")
        valueLabel.Text = tostring(Settings[name])
        valueLabel.Size = UDim2_new(0, 50, 1, 0)
        valueLabel.Position = UDim2_new(1, -50, 0, 0)
        valueLabel.TextColor3 = Color3_fromRGB(255, 255, 255)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.TextSize = 16
        valueLabel.Parent = frame
        
        local sliderFrame = Instance_new("Frame")
        sliderFrame.Size = UDim2_new(0.7, -60, 0, 10)
        sliderFrame.Position = UDim2_new(0, 0, 1, -15)
        sliderFrame.BackgroundColor3 = Color3_fromRGB(100, 100, 100)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = frame
        
        local fill = Instance_new("Frame")
        fill.Size = UDim2_new((Settings[name] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3_fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderFrame
        
        local button = Instance_new("TextButton")
        button.Size = UDim2_new(1, 0, 3, 0)
        button.Position = UDim2_new(0, 0, -1, 0)
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
                local percent = math_clamp((mousePos.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                Settings[name] = min + (max - min) * percent
                fill.Size = UDim2_new(percent, 0, 1, 0)
                valueLabel.Text = string.format("Smoothness" and "%.2f" or "%.0f", Settings[name])
            end)
        end)
    end
end

-- Создание элементов управления
for i, config in ipairs(controls) do
    createControl((i-1) * 55, config)
end

ScrollFrame.CanvasSize = UDim2_new(0, 0, 0, #controls * 55)

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
        MainFrame.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- FOV круг
local FOVCircle = Instance_new("Frame")
FOVCircle.Size = UDim2_new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2_new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
FOVCircle.ZIndex = 0
FOVCircle.Parent = ScreenGui

-- Кнопка активации аима на экране
local AimButton = Instance_new("TextButton")
AimButton.Size = UDim2_new(0, 80, 0, 80)
AimButton.Position = UDim2_new(1, -90, 1, -90)
AimButton.BackgroundColor3 = Color3_fromRGB(0, 120, 255)
AimButton.BackgroundTransparency = 0.5
AimButton.Text = "AIM"
AimButton.TextColor3 = Color3_fromRGB(255, 255, 255)
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
            local center = Vector2_new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local delta = (center - Vector2_new(screenPosition.X, screenPosition.Y)).Magnitude
            
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
        local endCFrame = CFrame_new(Camera.CFrame.Position, target.Position)
        
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
        local targetCFrame = CFrame_new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

-- Функция переключения видимости меню
ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Кнопка закрытия GUI в меню
local CloseButton = Instance_new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2_new(0, 30, 0, 30)
CloseButton.Position = UDim2_new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3_fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3_fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Уникальные функции

-- 1. АВТОМАТИЧЕСКИЙ ПОДБОР ОРУЖИЯ ПОСЛЕ СМЕРТИ ШЕРИФА
local weaponESPItems = {}
local function setupAutoWeaponPickup()
    local function findWeapons()
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver") or item.Name:lower():find("pistol")) then
                if not weaponESPItems[item] then
                    weaponESPItems[item] = true
                    
                    -- Подсветка оружия
                    if Settings.WeaponESP then
                        local highlight = Instance_new("Highlight")
                        highlight.FillColor = Color3_fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3_fromRGB(0, 200, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Adornee = item
                        highlight.Parent = item
                        
                        local billboard = Instance_new("BillboardGui")
                        billboard.Size = UDim2_new(0, 100, 0, 40)
                        billboard.AlwaysOnTop = true
                        billboard.StudsOffset = Vector3_new(0, 2, 0)
                        billboard.Adornee = item.Handle or item:FindFirstChildWhichIsA("BasePart") or item
                        billboard.Parent = item
                        
                        local textLabel = Instance_new("TextLabel")
                        textLabel.Size = UDim2_new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = item.Name
                        textLabel.TextColor3 = Color3_fromRGB(0, 255, 0)
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.TextSize = 14
                        textLabel.Parent = billboard
                    end
                    
                    -- Автоподбор
                    if Settings.AutoPickup then
                        item.AncestryChanged:Connect(function()
                            if not item.Parent and weaponESPItems[item] then
                                weaponESPItems[item] = nil
                            end
                        end)
                    end
                end
            end
        end
    end

    -- Поиск оружия каждые 2 секунды
    while true do
        if Settings.AutoPickup then
            findWeapons()
            
            -- Автоподбор ближайшего оружия
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local character = LocalPlayer.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 then
                    local closestWeapon = nil
                    local closestDistance = 20 -- Максимальная дистанция для автоподбора
                    
                    for weapon, _ in pairs(weaponESPItems) do
                        if weapon and weapon.Parent == Workspace then
                            local weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildWhichIsA("BasePart")
                            if weaponPart then
                                local distance = (weaponPart.Position - rootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestWeapon = weapon
                                end
                            end
                        end
                    end
                    
                    -- Подбираем оружие
                    if closestWeapon then
                        firetouchinterest(rootPart, closestWeapon.Handle or closestWeapon:FindFirstChildWhichIsA("BasePart"), 0)
                        wait()
                        firetouchinterest(rootPart, closestWeapon.Handle or closestWeapon:FindFirstChildWhichIsA("BasePart"), 1)
                    end
                end
            end
        end
        wait(2)
    end
end

-- 2. СИСТЕМА ВЫБОРА РОЛИ В СЛЕДУЮЩЕЙ ИГРЕ
local function setupRoleSelector()
    local roleFrame = Instance_new("Frame")
    roleFrame.Size = UDim2_new(0, 200, 0, 100)
    roleFrame.Position = UDim2_new(0, 10, 0, 70)
    roleFrame.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
    roleFrame.BackgroundTransparency = 0.7
    roleFrame.BorderSizePixel = 0
    roleFrame.Visible = false
    roleFrame.Parent = ScreenGui
    
    local roleLabel = Instance_new("TextLabel")
    roleLabel.Text = "Выбор роли:"
    roleLabel.Size = UDim2_new(1, 0, 0, 30)
    roleLabel.BackgroundTransparency = 1
    roleLabel.TextColor3 = Color3_fromRGB(255, 255, 255)
    roleLabel.Font = Enum.Font.SourceSansBold
    roleLabel.TextSize = 16
    roleLabel.Parent = roleFrame
    
    local sheriffBtn = Instance_new("TextButton")
    sheriffBtn.Text = "Шериф"
    sheriffBtn.Size = UDim2_new(0.45, 0, 0, 30)
    sheriffBtn.Position = UDim2_new(0, 5, 0, 40)
    sheriffBtn.BackgroundColor3 = Color3_fromRGB(0, 100, 255)
    sheriffBtn.TextColor3 = Color3_fromRGB(255, 255, 255)
    sheriffBtn.Font = Enum.Font.SourceSans
    sheriffBtn.TextSize = 14
    sheriffBtn.Parent = roleFrame
    
    local murdererBtn = Instance_new("TextButton")
    murdererBtn.Text = "Убийца"
    murdererBtn.Size = UDim2_new(0.45, 0, 0, 30)
    murdererBtn.Position = UDim2_new(0.5, 5, 0, 40)
    murdererBtn.BackgroundColor3 = Color3_fromRGB(255, 50, 50)
    murdererBtn.TextColor3 = Color3_fromRGB(255, 255, 255)
    murdererBtn.Font = Enum.Font.SourceSans
    murdererBtn.TextSize = 14
    murdererBtn.Parent = roleFrame
    
    -- Кнопка показа/скрытия выбора роли
    local roleToggle = Instance_new("TextButton")
    roleToggle.Text = "🎭"
    roleToggle.Size = UDim2_new(0, 50, 0, 50)
    roleToggle.Position = UDim2_new(0, 10, 0, 70)
    roleToggle.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
    roleToggle.BackgroundTransparency = 0.5
    roleToggle.TextColor3 = Color3_fromRGB(255, 255, 255)
    roleToggle.Font = Enum.Font.SourceSansBold
    roleToggle.TextSize = 24
    roleToggle.Parent = ScreenGui
    
    roleToggle.MouseButton1Click:Connect(function()
        roleFrame.Visible = not roleFrame.Visible
    end)
    
    sheriffBtn.MouseButton1Click:Connect(function()
        -- Попытка стать шерифом
        if ReplicatedStorage:FindFirstChild("GetChosen") then
            ReplicatedStorage.GetChosen:FireServer()
        end
        roleFrame.Visible = false
    end)
    
    murdererBtn.MouseButton1Click:Connect(function()
        -- Попытка стать убийцей
        if ReplicatedStorage:FindFirstChild("RequestRole") then
            ReplicatedStorage.RequestRole:FireServer("Murderer")
        end
        roleFrame.Visible = false
    end)
end

-- 3. АНТИЛАГ СИСТЕМА
local function setupAntiLag()
    if not Settings.AntiLag then return end
    
    -- Уменьшаем качество графики для повышения производительности
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshCacheSize = 10
    settings().Rendering.TextureCacheSize = 10
    
    -- Оптимизация частиц
    for _, effect in ipairs(Workspace:GetDescendants()) do
        if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
            effect.Enabled = false
        end
    end
    
    -- Оптимизация освещения
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FantasySky.Enabled = false
end

-- 4. СИСТЕМА УВЕДОМЛЕНИЙ
local notificationQueue = {}
local function showNotification(message, color, duration)
    duration = duration or 3
    table_insert(notificationQueue, {message = message, color = color, duration = duration})
end

local function processNotifications()
    while #notificationQueue > 0 do
        local notifData = table.remove(notificationQueue, 1)
        
        local notif = Instance_new("TextLabel")
        notif.Text = notifData.message
        notif.Size = UDim2_new(0, 300, 0, 40)
        notif.Position = UDim2_new(0.5, -150, 0.1, 0)
        notif.BackgroundColor3 = notifData.color or Color3_fromRGB(40, 40, 40)
        notif.TextColor3 = Color3_fromRGB(255, 255, 255)
        notif.Font = Enum.Font.SourceSansBold
        notif.TextSize = 16
        notif.Parent = ScreenGui
        
        wait(notifData.duration)
        if notif then
            notif:Destroy()
        end
    end
end

-- Запускаем все системы
spawn(setupAutoWeaponPickup)
spawn(setupRoleSelector)
if Settings.AntiLag then
    setupAntiLag()
end

-- Уведомление об успешной загрузке
showNotification("✅ Ultimate AIM загружен! Нажми ⚙️ для настроек", Color3_fromRGB(0, 150, 0), 5)

print("✅ Ultimate Mobile AIM активирован")
print("🔫 Auto Weapon Pickup: Автоподбор оружия")
print("🎭 Role Selector: Выбор роли в следующей игре")
print("⚡ Anti-Lag: Оптимизация производительности")
print("📢 Notification System: Умные уведомления")
