-- AIM Script for Madder Mystery by Beta01 (Delta Calculations)
-- Симмуляция C-1 | Ограничения: Null

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Конфигурационные параметры
local AimKey = Enum.UserInputType.MouseButton2
local FOV = 90 -- Поле захвата цели в пикселях
local Smoothness = 0.15 -- Плавность прицеливания (0-1)
local TeamCheck = true -- Игнорировать союзников
local VisibilityCheck = true -- Проверка видимости через стены

-- Функция вычисления дельты и поиска цели
function FindTarget()
    local closestTarget = nil
    local shortestDelta = FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then continue end
        
        -- Проверка команды
        if TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        -- Проверка видимости
        if VisibilityCheck then
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

        -- Вычисление дельты позиции
        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local delta = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
            
            if delta < shortestDelta then
                shortestDelta = delta
                closestTarget = rootPart
            end
        end
    end
    
    return closestTarget
end

-- Основная функция прицеливания
local function AimAtTarget(target)
    if not target then return end
    
    local currentCamera = Camera
    local targetPosition = target.Position
    
    -- Плавное прицеливание с использованием дельта-интерполяции
    local startPosition = currentCamera.CFrame
    local endPosition = CFrame.new(currentCamera.CFrame.Position, targetPosition)
    
    local step = 0
    while step < 1 and target and target.Parent do
        step = step + (1 - Smoothness) * 0.1
        Camera.CFrame = startPosition:Lerp(endPosition, step)
        RunService.RenderStepped:Wait()
    end
end

-- Обработчик ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == AimKey then
        local target = FindTarget()
        if target then
            AimAtTarget(target)
        end
    end
end)

print("✅ Delta-AIM для Madder Mystery активирован")
print("🎯 Клавиша прицеливания: Правая кнопка мыши")
print("📊 FOV: " .. FOV .. "px | Smoothness: " Smoothness)
