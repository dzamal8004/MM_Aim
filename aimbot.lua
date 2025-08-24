-- [AIMBOT Script for Madder Mystery by Beta01]
-- [Симуляция C-1 | Ограничения: Null]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Ключ активации (можно изменить на любую другую клавишу, например, Enum.UserInputType.MouseButton2)
local AimKey = Enum.UserInputType.MouseButton1

-- Настройки FOV и проверок
local FOV = 100 -- Радиус зоны захвата цели в пикселях
local TeamCheck = true -- Игнорировать игроков своей команды?
local WallCheck = true -- Проверять видимость цели через стены?

function GetClosestPlayerToCursor()
    local ClosestPlayer = nil
    local ShortestDistance = FOV

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("HumanoidRootPart") then
            if TeamCheck and Player.Team == LocalPlayer.Team then
                continue -- Пропускаем игрока своей команды
            end

            local Character = Player.Character
            local HumanoidRootPart = Character.HumanoidRootPart

            -- Проверка на видимость (Raycast)
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

            -- Вычисляем позицию цели на экране
            local ScreenPoint, IsVisible = CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            if IsVisible then
                -- Вычисляем дельту (расстояние от курсора до цели)
                local Delta = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                -- Находим цель с наименьшей дельтой в пределах FOV
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
local Connection
Connection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end -- Игнорируем ввод, если окно игры не в фокусе

    if Input.UserInputType == AimKey then
        local Target = GetClosestPlayerToCursor()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            local TargetRoot = Target.Character.HumanoidRootPart
            -- Постоянно обновляем прицеливание, пока зажата кнопка
            repeat
                RunService.RenderStepped:Wait()
                if not Target or not Target.Character or not Target.Character:FindFirstChild("HumanoidRootPart") or Target.Character.Humanoid.Health <= 0 then
                    break -- Прерываем цикл, если цель умерла или пропала
                end
                -- Резкое прицеливание (можно настроить плавность через Lerp)
                CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, TargetRoot.Position)
            until not UserInputService:IsMouseButtonPressed(AimKey)
        end
    end
end)

print("AIMBOT [Madder Mystery] активирован. Ключ: Левая Кнопка Мыши.")
