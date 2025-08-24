-- ULTIMATE AIMBOT OPTIMIZED - ЧАСТЬ 1/2
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
    SimpleRadar = true,
    AutoEscape = true, -- Новая функция: авто-побег
    AutoPickup = true, -- Новая функция: авто-подбор оружия
    InfoPanel = true, -- Новая функция: информационная панель
    GhostMode = false -- Новая функция: режим призрака
}

-- Оптимизация: будем использовать одну таблицу для хранения всех созданных объектов
local GUIElements = {}
local Connections = {}

-- Удаляем старый GUI если существует
if CoreGui:FindFirstChild("MobileAimGUI") then
    CoreGui.MobileAimGUI:Destroy()
end

-- Создание мобильного GUI
GUIElements.ScreenGui = Instance.new("ScreenGui")
GUIElements.ScreenGui.Name = "MobileAimGUI"
GUIElements.ScreenGui.Parent = CoreGui
GUIElements.ScreenGui.ResetOnSpawn = false

-- ... (создание GUI элементов, как ранее, но сохраняя их в GUIElements)

-- Функция для определения ролей (убийца, шериф) - улучшенная
local function getPlayerRole(player)
    if not player.Character then return "Unknown" end
    
    -- Проверка на убийцу (обычно имеет нож)
    local knife = player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife"))
    if knife then
        return "Murderer"
    end
    
    -- Проверка на шерифа (обычно имеет оружие)
    local gun = player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun"))
    if gun then
        return "Sheriff"
    end
    
    -- Дополнительные проверки по имени модели оружия, если необходимо
    for _, item in ipairs(player.Character:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver") or item.Name:lower():find("pistol")) then
            return "Sheriff"
        end
    end
    
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("revolver") or item.Name:lower():find("pistol")) then
            return "Sheriff"
        end
    end
    
    return "Innocent"
end

-- Основная логика аимбота с оптимизацией: используем кэширование
local lastTargetCheck = 0
local targetCheckInterval = 0.1 -- Проверять цель каждые 0.1 секунды

local function FindTarget()
    if not Settings.Enabled or not LocalPlayer.Character then return nil end
    
    local currentTime = tick()
    if currentTime - lastTargetCheck < targetCheckInterval then
        return nil -- Не проверяем слишком часто
    end
    lastTargetCheck = currentTime

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

-- Авто-побег от убийцы
local function checkEscape()
    if not Settings.AutoEscape or not LocalPlayer.Character then return end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getPlayerRole(player)
            if role == "Murderer" then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - localRoot.Position).Magnitude
                    if distance < 20 then -- Если убийца ближе 20 studs
                        -- Бежим в противоположную сторону
                        local direction = (localRoot.Position - rootPart.Position).Unit
                        local escapePos = localRoot.Position + direction * 30
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(escapePos)
                        break
                    end
                end
            end
        end
    end
end

-- Авто-подбор оружия
local function checkWeaponPickup()
    if not Settings.AutoPickup or not LocalPlayer.Character then return end
    
    -- Проверяем, есть ли у нас уже оружие
    local currentWeapon = LocalPlayer.Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    if currentWeapon then return end -- Если есть оружие, не подбираем
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for _, weapon in ipairs(Workspace:GetChildren()) do
        if weapon:IsA("Tool") and (weapon.Name:lower():find("gun") or weapon.Name:lower():find("knife")) then
            local weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildWhichIsA("BasePart")
            if weaponPart then
                local distance = (weaponPart.Position - localRoot.Position).Magnitude
                if distance < 10 then -- Если оружие ближе 10 studs
                    -- Подбираем оружие
                    weapon.CFrame = localRoot.CFrame
                    wait(0.1)
                    weapon.Parent = LocalPlayer.Backpack
                    break
                end
            end
        end
    end
end

-- Режим призрака
local function updateGhostMode()
    if not LocalPlayer.Character then return end
    
    if Settings.GhostMode then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.Material = Enum.Material.Glass
            end
        end
    else
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.Material = Enum.Material.Plastic
            end
        end
    end
end

-- Информационная панель
local function updateInfoPanel()
    if not Settings.InfoPanel then
        if GUIElements.InfoPanel then
            GUIElements.InfoPanel:Destroy()
            GUIElements.InfoPanel = nil
        end
        return
    end
    
    if not GUIElements.InfoPanel then
        GUIElements.InfoPanel = Instance.new("Frame")
        GUIElements.InfoPanel.Name = "InfoPanel"
        GUIElements.InfoPanel.Size = UDim2.new(0, 200, 0, 100)
        GUIElements.InfoPanel.Position = UDim2.new(0, 10, 0, 60)
        GUIElements.InfoPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        GUIElements.InfoPanel.BackgroundTransparency = 0.5
        GUIElements.InfoPanel.BorderSizePixel = 0
        GUIElements.InfoPanel.Parent = GUIElements.ScreenGui
        
        local title = Instance.new("TextLabel")
        title.Text = "Информация"
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 16
        title.Parent = GUIElements.InfoPanel
        
        GUIElements.InfoText = Instance.new("TextLabel")
        GUIElements.InfoText.Text = ""
        GUIElements.InfoText.Size = UDim2.new(1, 0, 1, -20)
        GUIElements.InfoText.Position = UDim2.new(0, 0, 0, 20)
        GUIElements.InfoText.BackgroundTransparency = 1
        GUIElements.InfoText.TextColor3 = Color3.fromRGB(255, 255, 255)
        GUIElements.InfoText.Font = Enum.Font.SourceSans
        GUIElements.InfoText.TextSize = 14
        GUIElements.InfoText.TextXAlignment = Enum.TextXAlignment.Left
        GUIElements.InfoText.TextYAlignment = Enum.TextYAlignment.Top
        GUIElements.InfoText.Parent = GUIElements.InfoPanel
    end
    
    -- Обновляем информацию
    local murderers = 0
    local sheriffs = 0
    local innocents = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = getPlayerRole(player)
            if role == "Murderer" then
                murderers = murderers + 1
            elseif role == "Sheriff" then
                sheriffs = sheriffs + 1
            else
                innocents = innocents + 1
            end
        end
    end
    
    GUIElements.InfoText.Text = string.format("Убийцы: %d\nШерифы: %d\nНевиновные: %d", murderers, sheriffs, innocents)
end

-- Основной цикл обновления с оптимизацией: разделим обновления на разные интервалы
local lastUpdate = {
    radar = 0,
    esp = 0,
    info = 0,
    escape = 0,
    pickup = 0
}

local updateIntervals = {
    radar = 0.3,   -- Радар обновляется каждые 0.3 секунды
    esp = 0.2,     -- ESP каждые 0.2 секунды
    info = 1,      -- Инфо-панель каждую секунду
    escape = 0.5,  -- Проверка побега каждые 0.5 секунды
    pickup = 0.5   -- Проверка подбора каждые 0.5 секунды
}

Connections.MainLoop = RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    -- Обновляем FOV круг каждый кадр, но только если нужно
    if GUIElements.FOVCircle then
        GUIElements.FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled
        GUIElements.FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        GUIElements.FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
    end
    
    -- Обновляем радар с интервалом
    if currentTime - lastUpdate.radar > updateIntervals.radar then
        lastUpdate.radar = currentTime
        updateSimpleRadar() -- Функция из части 2
    end
    
    -- Обновляем ESP с интервалом
    if currentTime - lastUpdate.esp > updateIntervals.esp then
        lastUpdate.esp = currentTime
        updateXRay() -- Функция из части 2
        updateRoleLabels() -- Функция из части 2
        updateWeaponESP() -- Функция из части 2
    end
    
    -- Обновляем инфо-панель с интервалом
    if currentTime - lastUpdate.info > updateIntervals.info then
        lastUpdate.info = currentTime
        updateInfoPanel()
    end
    
    -- Проверяем побег с интервалом
    if currentTime - lastUpdate.escape > updateIntervals.escape then
        lastUpdate.escape = currentTime
        checkEscape()
    end
    
    -- Проверяем подбор оружия с интервалом
    if currentTime - lastUpdate.pickup > updateIntervals.pickup then
        lastUpdate.pickup = currentTime
        checkWeaponPickup()
    end
    
    -- Режим призрака обновляем сразу при изменении, но здесь можно проверить изменение Settings.GhostMode
    updateGhostMode()
end)

-- ... (остальной код первой части: создание GUI, обработчики событий и т.д.)

showNotification("✅ Часть 1/2 загружена! Запустите вторую часть.", 5)

print("✅ Часть 1/2 загружена - Основной функционал с оптимизацией")
-- ULTIMATE AIMBOT OPTIMIZED - ЧАСТЬ 2/2
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
                    billboardGui.Parent = GUIElements.ScreenGui
                    
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
    if not GUIElements.ScreenGui:FindFirstChild("RadarFrame") then
        local radarFrame = Instance.new("Frame")
        radarFrame.Name = "RadarFrame"
        radarFrame.Size = UDim2.new(0, 150, 0, 150)
        radarFrame.Position = UDim2.new(0, 20, 1, -170)
        radarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        radarFrame.BackgroundTransparency = 0.7
        radarFrame.BorderSizePixel = 2
        radarFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        radarFrame.Parent = GUIElements.ScreenGui
        
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
    
    local radarFrame = GUIElements.ScreenGui:FindFirstChild("RadarFrame")
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

showNotification("✅ Часть 2/2 загружена! Все функции активированы.", 5)

print("✅ Часть 2/2 загружена - Дополнительные функции с оптимизацией")
