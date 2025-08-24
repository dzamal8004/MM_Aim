-- ULTIMATE FIXED MADDER MYSTERY SCRIPT
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
    WeaponESP = true,
    AutoPickup = true,
    SimpleAim = true -- Простой режим аимбота без лагов
}

-- Очистка предыдущего GUI
if CoreGui:FindFirstChild("MadderMysteryGUI") then
    CoreGui.MadderMysteryGUI:Destroy()
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MadderMysteryGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Иконка меню
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

-- Основное меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "Madder Mystery Settings"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Контейнер настроек
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)
ScrollFrame.Parent = MainFrame

-- Простые настройки
local controls = {
    {"Enabled", "Toggle", "Активировать аим"},
    {"FOV", "Slider", "Поле зрения: ", 50, 200},
    {"Smoothness", "Slider", "Плавность: ", 0.1, 1},
    {"TeamCheck", "Toggle", "Игнорировать союзников"},
    {"WallCheck", "Toggle", "Проверка стен"},
    {"ShowFOV", "Toggle", "Показать FOV круг"},
    {"WeaponESP", "Toggle", "Подсветка оружия"},
    {"AutoPickup", "Toggle", "Автоподбор оружия"},
    {"SimpleAim", "Toggle", "Простой режим (меньше лагов)"}
}

-- Функция создания элементов управления
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

-- Кнопка активации аима
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

-- Функция для определения ролей
local function getPlayerRole(player)
    if not player.Character then return "Unknown" end
    
    -- Проверка на убийцу
    if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    
    -- Проверка на шерифа
    if player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    
    return "Innocent"
end

-- Упрощенная логика аимбота
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

-- Автоматическое прицеливание (только в простом режиме)
local autoAimConnection
if Settings.SimpleAim then
    autoAimConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Enabled or not LocalPlayer.Character then return end
        
        local target = FindTarget()
        if target then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end)
end

-- Функция переключения меню
ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Кнопка закрытия меню
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

-- СИСТЕМА АВТОПОДБОРА ОРУЖИЯ
local weaponESPItems = {}
local function setupAutoWeaponPickup()
    while true do
        if Settings.AutoPickup and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Ищем оружие на земле
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver") or item.Name:lower():find("pistol")) then
                    if not weaponESPItems[item] then
                        weaponESPItems[item] = true
                        
                        -- Подсветка оружия
                        if Settings.WeaponESP then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Adornee = item
                            highlight.Parent = item
                        end
                    end
                    
                    -- Автоподбор
                    local character = LocalPlayer.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and humanoid.Health > 0 then
                        local weaponPart = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                        if weaponPart then
                            local distance = (weaponPart.Position - rootPart.Position).Magnitude
                            if distance < 15 then -- Дистанция для автоподбора
                                firetouchinterest(rootPart, weaponPart, 0)
                                wait()
                                firetouchinterest(rootPart, weaponPart, 1)
                            end
                        end
                    end
                end
            end
        end
        
        -- Очистка устаревших предметов
        for weapon, _ in pairs(weaponESPItems) do
            if not weapon or not weapon.Parent or weapon.Parent == nil then
                weaponESPItems[weapon] = nil
            end
        end
        
        wait(1) -- Проверка каждую секунду
    end
end

-- Запускаем систему автоподбора
spawn(setupAutoWeaponPickup)

-- СИСТЕМА ВЫБОРА РОЛИ (ПРОСТАЯ ВЕРСИЯ)
local roleSelectionFrame = Instance.new("Frame")
roleSelectionFrame.Size = UDim2.new(0, 200, 0, 100)
roleSelectionFrame.Position = UDim2.new(0, 10, 0, 70)
roleSelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
roleSelectionFrame.BackgroundTransparency = 0.7
roleSelectionFrame.BorderSizePixel = 0
roleSelectionFrame.Visible = false
roleSelectionFrame.Parent = ScreenGui

local roleLabel = Instance.new("TextLabel")
roleLabel.Text = "Выбор роли:"
roleLabel.Size = UDim2.new(1, 0, 0, 30)
roleLabel.BackgroundTransparency = 1
roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roleLabel.Font = Enum.Font.SourceSansBold
roleLabel.TextSize = 16
roleLabel.Parent = roleSelectionFrame

local roleToggle = Instance.new("TextButton")
roleToggle.Text = "🎭"
roleToggle.Size = UDim2.new(0, 50, 0, 50)
roleToggle.Position = UDim2.new(0, 10, 0, 70)
roleToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
roleToggle.BackgroundTransparency = 0.5
roleToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
roleToggle.Font = Enum.Font.SourceSansBold
roleToggle.TextSize = 24
roleToggle.Parent = ScreenGui

roleToggle.MouseButton1Click:Connect(function()
    roleSelectionFrame.Visible = not roleSelectionFrame.Visible
end)

-- Функция для попытки выбора роли
local function trySelectRole(role)
    -- Попытка найти стандартные RemoteEvents для выбора роли
    local events = {
        "GetChosen", "RequestRole", "BecomeSheriff", "BecomeMurderer",
        "SelectRole", "RoleSelection", "GetMurderer", "GetSheriff"
    }
    
    for _, eventName in ipairs(events) do
        local event = game:GetService("ReplicatedStorage"):FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            event:FireServer(role)
            return true
        end
    end
    
    return false
end

local sheriffBtn = Instance.new("TextButton")
sheriffBtn.Text = "Шериф"
sheriffBtn.Size = UDim2.new(0.45, 0, 0, 30)
sheriffBtn.Position = UDim2.new(0, 5, 0, 40)
sheriffBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
sheriffBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sheriffBtn.Font = Enum.Font.SourceSans
sheriffBtn.TextSize = 14
sheriffBtn.Parent = roleSelectionFrame

sheriffBtn.MouseButton1Click:Connect(function()
    if trySelectRole("Sheriff") then
        roleSelectionFrame.Visible = false
    else
        -- Если не нашли RemoteEvent, просто покажем уведомление
        local notif = Instance.new("TextLabel")
        notif.Text = "Не удалось выбрать роль автоматически"
        notif.Size = UDim2.new(0, 300, 0, 40)
        notif.Position = UDim2.new(0.5, -150, 0.1, 0)
        notif.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.Font = Enum.Font.SourceSansBold
        notif.TextSize = 16
        notif.Parent = ScreenGui
        
        game:GetService("Debris"):AddItem(notif, 3)
    end
end)

local murdererBtn = Instance.new("TextButton")
murdererBtn.Text = "Убийца"
murdererBtn.Size = UDim2.new(0.45, 0, 0, 30)
murdererBtn.Position = UDim2.new(0.5, 5, 0, 40)
murdererBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
murdererBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
murdererBtn.Font = Enum.Font.SourceSans
murdererBtn.TextSize = 14
murdererBtn.Parent = roleSelectionFrame

murdererBtn.MouseButton1Click:Connect(function()
    if trySelectRole("Murderer") then
        roleSelectionFrame.Visible = false
    else
        -- Если не нашли RemoteEvent, просто покажем уведомление
        local notif = Instance.new("TextLabel")
        notif.Text = "Не удалось выбрать роль автоматически"
        notif.Size = UDim2.new(0, 300, 0, 40)
        notif.Position = UDim2.new(0.5, -150, 0.1, 0)
        notif.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.Font = Enum.Font.SourceSansBold
        notif.TextSize = 16
        notif.Parent = ScreenGui
        
        game:GetService("Debris"):AddItem(notif, 3)
    end
end)

-- Уведомление о загрузке
local notif = Instance.new("TextLabel")
notif.Text = "✅ Madder Mystery скрипт загружен!"
notif.Size = UDim2.new(0, 300, 0, 40)
notif.Position = UDim2.new(0.5, -150, 0.1, 0)
notif.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
notif.TextColor3 = Color3.fromRGB(255, 255, 255)
notif.Font = Enum.Font.SourceSansBold
notif.TextSize = 16
notif.Parent = ScreenGui

game:GetService("Debris"):AddItem(notif, 5)

print("✅ Madder Mystery скрипт загружен")
print("🎯 Аимбот: " .. (Settings.Enabled and "ВКЛ" or "ВЫКЛ"))
print("🔫 Автоподбор: " .. (Settings.AutoPickup and "ВКЛ" or "ВЫКЛ"))
print("🎭 Выбор роли: Доступен через кнопку 🎭")
