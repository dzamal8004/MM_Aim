-- AIM Script for Madder Mystery by Beta01 (Delta-based)
-- Симуляция C-1 | Ограничения: Null

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CurrentCamera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки
local AimKey = Enum.UserInputType.MouseButton2 -- Правая кнопка мыши для прицеливания
local FOV = 100 -- Радиус зоны захвата в пикселях
local TeamCheck = true -- Проверять команду?
local WallCheck = true -- Проверять стены?
local Smoothness = 0.1 -- Плавность прицеливания (0 - мгновенно, 1 - очень плавно)

-- Функция получения ближайшего игрока к курсору
function GetClosestPlayerToCursor()
    local ClosestPlayer = nil
    local ShortestDistance = FOV

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("HumanoidRootPart") then
            if TeamCheck and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
                continue -- Пропускаем своих
            end

            local Character = Player.Character
            local HumanoidRootPart = Character.HumanoidRootPart

            -- Проверка на видимость (WallCheck)
            if WallCheck then
                local Origin = CurrentCamera.CFrame.Position
                local Destination = HumanoidRootPart.Position
                local RaycastParams = RaycastParams.new()
                RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, CurrentCamera}
                local RaycastResult = workspace:Raycast(Origin, (Destination - Origin), RaycastParams)

                if RaycastResult and RaycastResult.Instance:FindFirstAncestorWhichIsA("Model") ~= Character then
                    continue -- Цель не видна, пропускаем
                end
            end

            -- Преобразуем мировые координаты в экранные
            local ScreenPoint, IsVisible = CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            if IsVisible then
                -- Вычисляем дельту (расстояние от курсора до цели на экране)
                local Delta = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                if Delta < ShortestDistance then
                    ShortestDistance = Delta
                    ClosestPlayer = Player
                end
            end
        end
    end
    return ClosestPlayer
end

-- Основной цикл прицеливания
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end

    if Input.UserInputType == AimKey then
        local Target = GetClosestPlayerToCursor()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            local TargetRoot = Target.Character.HumanoidRootPart
            -- Захватываем цель и начинаем прицеливание
            while UserInputService:IsMouseButtonPressed(AimKey) and Target and Target.Character and Target.Character.Humanoid.Health > 0 do
                RunService.RenderStepped:Wait()
                local CurrentCFrame = CurrentCamera.CFrame
                local TargetPosition = TargetRoot.Position
                -- Плавное прицеливание с использованием Lerp
                local NewCFrame = CFrame.new(CurrentCFrame.Position, TargetPosition)
                CurrentCamera.CFrame = CurrentCFrame:Lerp(NewCFrame, 1 - Smoothness)
            end
        end
    end
end)

print("AIMBOT [Madder Mystery] активирован. Ключ: Правая Кнопка Мыши.")
