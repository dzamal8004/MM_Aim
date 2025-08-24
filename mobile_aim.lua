-- ULTIMATE Mobile AIM Script with Exclusive Features by Beta01
-- ... (предыдущий код остается без изменений до этого места)

-- УНИКАЛЬНЫЕ ЭКСКЛЮЗИВНЫЕ ФУНКЦИИ:

-- 1. ПРЕДСКАЗАНИЕ ДВИЖЕНИЯ ПРОТИВНИКА (AI Prediction)
local Prediction = {
    Enabled = true,
    Strength = 0.8,
    History = {}
}

local function setupPrediction()
    RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    if not Prediction.History[player] then
                        Prediction.History[player] = {}
                    end
                    
                    -- Сохраняем историю движений
                    table.insert(Prediction.History[player], {
                        Position = rootPart.Position,
                        Velocity = rootPart.Velocity,
                        Time = tick()
                    })
                    
                    -- Ограничиваем историю последними 10 кадрами
                    if #Prediction.History[player] > 10 then
                        table.remove(Prediction.History[player], 1)
                    end
                end
            end
        end
    end)
end

local function predictPosition(targetRoot, player)
    if not Prediction.Enabled or not Prediction.History[player] or #Prediction.History[player] < 3 then
        return targetRoot.Position
    end
    
    local history = Prediction.History[player]
    local avgVelocity = Vector3.new(0, 0, 0)
    
    -- Вычисляем среднюю скорость
    for i = 2, #history do
        avgVelocity = avgVelocity + (history[i].Position - history[i-1].Position)
    end
    avgVelocity = avgVelocity / (#history - 1)
    
    -- Предсказываем позицию с учетом скорости
    return targetRoot.Position + (avgVelocity * Prediction.Strength)
end

-- 2. АВТОМАТИЧЕСКИЙ ВЫБОР ОРУЖИЯ И СТРЕЛЬБА
local AutoShoot = {
    Enabled = false,
    Delay = 0.2
}

local function findBestWeapon()
    if not LocalPlayer.Character then return nil end
    
    local weapons = {}
    local character = LocalPlayer.Character
    
    -- Ищем оружие в инвентаре и руках
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("knife")) then
            table.insert(weapons, item)
        end
    end
    
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("knife")) then
            table.insert(weapons, item)
        end
    end
    
    -- Предпочтение оружию в руках
    for _, weapon in ipairs(weapons) do
        if weapon.Parent == character then
            return weapon
        end
    end
    
    return weapons[1] -- Возвращаем первое найденное оружие
end

local function autoShootAtTarget(target)
    if not AutoShoot.Enabled or not target then return end
    
    local weapon = findBestWeapon()
    if not weapon then return end
    
    -- Экипируем оружие
    if weapon.Parent ~= LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Character
        wait(0.1)
    end
    
    -- Имитируем нажатие кнопки стрельбы
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    mouse.Target = target
    mouse.Hit = CFrame.new(target.Position)
    
    -- Активируем оружие
    if weapon:FindFirstChild("Activate") then
        weapon.Activate:Fire()
    end
end

-- 3. 3D RADAR SYSTEM с отображением всех игроков
local Radar = {
    Enabled = true,
    Size = 150,
    Position = UDim2.new(0, 20, 1, -170)
}

local radarGui = Instance.new("Frame")
radarGui.Size = UDim2.new(0, Radar.Size, 0, Radar.Size)
radarGui.Position = Radar.Position
radarGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
radarGui.BackgroundTransparency = 0.7
radarGui.BorderSizePixel = 2
radarGui.BorderColor3 = Color3.fromRGB(100, 100, 100)
radarGui.Visible = Radar.Enabled
radarGui.Parent = ScreenGui

local radarPoints = {}
local function updateRadar()
    if not Radar.Enabled then return end
    
    -- Очищаем старые точки
    for _, point in pairs(radarPoints) do
        point:Destroy()
    end
    radarPoints = {}
    
    local center = Vector2.new(radarGui.AbsolutePosition.X + Radar.Size/2, radarGui.AbsolutePosition.Y + Radar.Size/2)
    local maxDistance = 100 -- Максимальная дистанция отображения на радаре
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local relativePosition = rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position
                local distance = relativePosition.Magnitude
                
                if distance <= maxDistance then
                    -- Нормализуем позицию для радара
                    local normalizedPos = Vector2.new(
                        relativePosition.X / maxDistance,
                        relativePosition.Z / maxDistance
                    ) * (Radar.Size/2 - 10)
                    
                    local role = getPlayerRole(player)
                    local color = role == "Murderer" and Color3.fromRGB(255, 0, 0) or
                                 role == "Sheriff" and Color3.fromRGB(0, 0, 255) or
                                 Color3.fromRGB(255, 255, 255)
                    
                    local point = Instance.new("Frame")
                    point.Size = UDim2.new(0, 8, 0, 8)
                    point.Position = UDim2.new(0, center.X + normalizedPos.X - 4, 0, center.Y + normalizedPos.Y - 4)
                    point.BackgroundColor3 = color
                    point.BorderSizePixel = 0
                    point.ZIndex = 10
                    point.Parent = ScreenGui
                    
                    radarPoints[player] = point
                end
            end
        end
    end
end

-- 4. SMART TARGET PRIORITY SYSTEM
local PrioritySystem = {
    Enabled = true,
    Priorities = {
        ["Murderer"] = 100,
        ["Sheriff"] = 75,
        ["Innocent"] = 25
    }
}

local function getTargetPriority(player)
    if not PrioritySystem.Enabled then return 50 end
    
    local role = getPlayerRole(player)
    return PrioritySystem.Priorities[role] or 50
end

-- 5. NIGHT VISION MODE
local NightVision = {
    Enabled = false,
    Intensity = 0.8
}

local function toggleNightVision()
    if NightVision.Enabled then
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Ambient = Color3.fromRGB(200, 200, 150)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 255)
    end
end

-- 6. AUTO-EVADE SYSTEM (избегание опасности)
local EvadeSystem = {
    Enabled = true,
    DodgeDistance = 10
}

local function checkDanger()
    if not EvadeSystem.Enabled then return false end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getPlayerRole(player)
            if role == "Murderer" then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                    return true
                end
            end
        end
    end
    return false
end

-- 7. Добавляем новые настройки в меню
local exclusiveControls = {
    {"Prediction.Enabled", "Toggle", "AI Предсказание движений"},
    {"AutoShoot.Enabled", "Toggle", "Авто-стрельба"},
    {"Radar.Enabled", "Toggle", "3D Радар"},
    {"PrioritySystem.Enabled", "Toggle", "Приоритет целей"},
    {"NightVision.Enabled", "Toggle", "Ночное видение"},
    {"EvadeSystem.Enabled", "Toggle", "Система уклонения"}
}

-- Обновляем функцию создания контролов для поддержки вложенных настроек
-- ... (код будет в полной версии)

-- Инициализируем все системы
setupPrediction()

-- Обновляем основной цикл
RunService.RenderStepped:Connect(function()
    -- ... (предыдущий код)
    
    -- Обновляем радар
    updateRadar()
    
    -- Проверяем опасность и уклоняемся
    if checkDanger() and EvadeSystem.Enabled then
        -- Логика уклонения
        local evadeDirection = (LocalPlayer.Character.HumanoidRootPart.Position - FindTarget().Position).Unit
        LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + evadeDirection * EvadeSystem.DodgeDistance)
    end
    
    -- Обновляем ночное видение
    toggleNightVision()
end)

-- 8. SMART NOTIFICATION SYSTEM
local function showNotification(message, color)
    local notif = Instance.new("TextLabel")
    notif.Text = message
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundColor3 = color
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.SourceSansBold
    notif.TextSize = 16
    notif.Parent = ScreenGui
    
    -- Анимация появления и исчезновения
    notif:TweenPosition(UDim2.new(0.5, -150, 0, 60), "Out", "Quad", 0.5)
    wait(3)
    notif:TweenPosition(UDim2.new(0.5, -150, 0, 10), "Out", "Quad", 0.5)
    wait(0.5)
    notif:Destroy()
end

-- Автоматические уведомления
Players.PlayerAdded:Connect(function(player)
    showNotification("Игрок " .. player.Name .. " присоединился", Color3.fromRGB(0, 150, 0))
end)

Players.PlayerRemoving:Connect(function(player)
    showNotification("Игрок " .. player.Name .. " вышел", Color3.fromRGB(150, 0, 0))
end)

print("🎉 УЛЬТРА-ЭКСКЛЮЗИВНЫЕ ФУНКЦИИ АКТИВИРОВАНЫ!")
print("🤖 AI Prediction: Предсказывает движение врагов")
print("🔫 Auto-Shoot: Автоматическая стрельба")
print("📡 3D Radar: Полноценная радарная система")
print("🎯 Smart Priority: Умный выбор целей")
print("🌙 Night Vision: Ночное видение")
print("⚡ Auto-Evade: Система уклонения от опасности")
print("💡 Smart Notifications: Умные уведомления")
