-- Script Subscription Check System
-- Проверяет наличие юзернейма в базе GitHub и загружает скрипт

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerUsername = player.Name

-- URL твоего GitHub файла с базой покупателей (RAW)
-- Формат: один ник на строку
local DATABASE_URL = "https://raw.githubusercontent.com/ryutohks/xdscript/refs/heads/main/database"

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SubscriptionGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Затемненный фон
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = screenGui

-- Главное окно подписки
local subFrame = Instance.new("Frame")
subFrame.Name = "SubscriptionFrame"
subFrame.Size = UDim2.new(0, 400, 0, 300)
subFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
subFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
subFrame.BorderSizePixel = 0
subFrame.ZIndex = 2
subFrame.Parent = screenGui

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 15)
subCorner.Parent = subFrame

local subStroke = Instance.new("UIStroke")
subStroke.Color = Color3.fromRGB(255, 70, 70)
subStroke.Thickness = 3
subStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
subStroke.Parent = subFrame

local subGradient = Instance.new("UIGradient")
subGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
subGradient.Rotation = 45
subGradient.Parent = subFrame

-- Иконка замка
local lockIcon = Instance.new("TextLabel")
lockIcon.Size = UDim2.new(0, 60, 0, 60)
lockIcon.Position = UDim2.new(0.5, -30, 0, 20)
lockIcon.BackgroundTransparency = 1
lockIcon.Text = "🔒"
lockIcon.TextSize = 50
lockIcon.ZIndex = 3
lockIcon.Parent = subFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 80)
titleLabel.Position = UDim2.new(0, 20, 0, 90)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Script subscription not found.\nPay the invoice below."
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextWrapped = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextYAlignment = Enum.TextYAlignment.Top
titleLabel.ZIndex = 3
titleLabel.Parent = subFrame

-- Цена
local priceLabel = Instance.new("TextLabel")
priceLabel.Size = UDim2.new(1, -40, 0, 40)
priceLabel.Position = UDim2.new(0, 20, 0, 175)
priceLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
priceLabel.BorderSizePixel = 0
priceLabel.Text = "LIFETIME - 200 ROBUX"
priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
priceLabel.TextSize = 20
priceLabel.Font = Enum.Font.GothamBold
priceLabel.ZIndex = 3
priceLabel.Parent = subFrame

local priceCorner = Instance.new("UICorner")
priceCorner.CornerRadius = UDim.new(0, 10)
priceCorner.Parent = priceLabel

local priceGlow = Instance.new("UIStroke")
priceGlow.Color = Color3.fromRGB(100, 255, 100)
priceGlow.Thickness = 2
priceGlow.Transparency = 0.5
priceGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
priceGlow.Parent = priceLabel

-- Кнопка покупки
local buyButton = Instance.new("TextButton")
buyButton.Size = UDim2.new(0, 360, 0, 50)
buyButton.Position = UDim2.new(0, 20, 0, 230)
buyButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
buyButton.BorderSizePixel = 0
buyButton.Text = "COPY GAMEPASS LINK"
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.TextSize = 18
buyButton.Font = Enum.Font.GothamBold
buyButton.AutoButtonColor = false
buyButton.ZIndex = 3
buyButton.Parent = subFrame

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 10)
buyCorner.Parent = buyButton

local buyGradient = Instance.new("UIGradient")
buyGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 60, 60))
}
buyGradient.Rotation = 90
buyGradient.Parent = buyButton

-- Индикатор загрузки
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1, 0, 1, 0)
loadingLabel.Position = UDim2.new(0, 0, 0, 0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "Checking subscription..."
loadingLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
loadingLabel.TextSize = 20
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.Visible = false
loadingLabel.ZIndex = 4
loadingLabel.Parent = subFrame

-- Анимация кнопки
buyButton.MouseEnter:Connect(function()
    TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
end)

buyButton.MouseLeave:Connect(function()
    TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
end)

-- Функция копирования ссылки
buyButton.MouseButton1Click:Connect(function()
    local gamepassLink = "https://www.roblox.com/game-pass/1510990696/INSTANT-STEAL"
    
    -- Копируем в буфер обмена
    setclipboard(gamepassLink)
    
    -- Визуальная обратная связь
    local originalText = buyButton.Text
    buyButton.Text = "✓ COPIED TO CLIPBOARD!"
    buyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    
    wait(2)
    
    buyButton.Text = originalText
    TweenService:Create(buyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
end)

-- Функция проверки белого списка
local function checkWhitelist()
    loadingLabel.Visible = true
    subFrame.Visible = false
    
    local success, result = pcall(function()
        return game:HttpGet(DATABASE_URL)
    end)
    
    if success then
        -- Разбиваем текст на строки
        local whitelist = {}
        for username in string.gmatch(result, "[^\r\n]+") do
            -- Убираем пробелы
            username = username:match("^%s*(.-)%s*$")
            if username ~= "" then
                table.insert(whitelist, username:lower())
            end
        end
        
        -- Проверяем есть ли игрок в списке
        local isWhitelisted = false
        for _, name in pairs(whitelist) do
            if name == playerUsername:lower() then
                isWhitelisted = true
                break
            end
        end
        
        if isWhitelisted then
            -- Игрок найден в базе - загружаем основной скрипт
            print("✓ Subscription verified for: " .. playerUsername)
            loadingLabel.Text = "✓ Access Granted!"
            loadingLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            wait(1)
            
            -- Удаляем окно подписки
            screenGui:Destroy()
            
            -- ЗДЕСЬ ЗАГРУЖАЕМ ТВОЙ ОСНОВНОЙ СКРИПТ
            loadMainScript()
        else
            -- Игрок не найден
            print("✗ Subscription not found for: " .. playerUsername)
            loadingLabel.Visible = false
            subFrame.Visible = true
        end
    else
        -- Ошибка загрузки базы данных
        warn("Failed to load whitelist database: " .. tostring(result))
        loadingLabel.Text = "✗ Error checking subscription"
        loadingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        loadingLabel.Visible = false
        subFrame.Visible = true
    end
end

-- Функция загрузки основного скрипта
function loadMainScript()
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Переменная для хранения спавна
    local spawnPosition = nil
    local spawnCaptured = false
    
    -- Убиваем персонажа при загрузке скрипта чтобы запомнить спавн
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
            print("Персонаж убит для определения спавна...")
        end
    end
    
    -- Ждем респавна и запоминаем позицию
    player.CharacterAdded:Connect(function(char)
        character = char
        humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        
        if not spawnCaptured then
            wait(0.3)
            spawnPosition = humanoidRootPart.CFrame
            spawnCaptured = true
            print("Позиция спавна сохранена: " .. tostring(spawnPosition))
        end
    end)
    
    -- Создаем новый ScreenGui для основного скрипта
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ExploitGui"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = player:WaitForChild("PlayerGui")
    
    -- ========== INSTANT TP ОКНО ==========
    local tpFrame = Instance.new("Frame")
    tpFrame.Name = "TPFrame"
    tpFrame.Size = UDim2.new(0, 300, 0, 150)
    tpFrame.Position = UDim2.new(0.5, -400, 0.5, -75)
    tpFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    tpFrame.BorderSizePixel = 0
    tpFrame.Active = true
    tpFrame.Draggable = true
    tpFrame.Parent = mainGui
    
    local tpCorner = Instance.new("UICorner")
    tpCorner.CornerRadius = UDim.new(0, 15)
    tpCorner.Parent = tpFrame
    
    local tpStroke = Instance.new("UIStroke")
    tpStroke.Color = Color3.fromRGB(60, 60, 70)
    tpStroke.Thickness = 2
    tpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tpStroke.Parent = tpFrame
    
    local tpGradient = Instance.new("UIGradient")
    tpGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    tpGradient.Rotation = 45
    tpGradient.Parent = tpFrame
    
    local tpTitle = Instance.new("TextLabel")
    tpTitle.Size = UDim2.new(1, -40, 0, 50)
    tpTitle.Position = UDim2.new(0, 20, 0, 15)
    tpTitle.BackgroundTransparency = 1
    tpTitle.Text = "INSTANT TP"
    tpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpTitle.TextSize = 24
    tpTitle.Font = Enum.Font.GothamBold
    tpTitle.TextXAlignment = Enum.TextXAlignment.Left
    tpTitle.Parent = tpFrame
    
    local tpTextGlow = Instance.new("UIStroke")
    tpTextGlow.Color = Color3.fromRGB(100, 150, 255)
    tpTextGlow.Thickness = 1
    tpTextGlow.Transparency = 0.5
    tpTextGlow.Parent = tpTitle
    
    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0, 260, 0, 50)
    tpButton.Position = UDim2.new(0, 20, 0, 80)
    tpButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    tpButton.BorderSizePixel = 0
    tpButton.Text = "TP TO SPAWN"
    tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpButton.TextSize = 20
    tpButton.Font = Enum.Font.GothamBold
    tpButton.AutoButtonColor = false
    tpButton.Parent = tpFrame
    
    local tpBtnCorner = Instance.new("UICorner")
    tpBtnCorner.CornerRadius = UDim.new(0, 10)
    tpBtnCorner.Parent = tpButton
    
    local tpBtnGradient = Instance.new("UIGradient")
    tpBtnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 230))
    }
    tpBtnGradient.Rotation = 90
    tpBtnGradient.Parent = tpButton
    
    -- ========== FLING ОКНО ==========
    local flingFrame = Instance.new("Frame")
    flingFrame.Name = "FlingFrame"
    flingFrame.Size = UDim2.new(0, 300, 0, 400)
    flingFrame.Position = UDim2.new(0.5, 50, 0.5, -200)
    flingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    flingFrame.BorderSizePixel = 0
    flingFrame.Active = true
    flingFrame.Draggable = true
    flingFrame.Parent = mainGui
    
    local flingCorner = Instance.new("UICorner")
    flingCorner.CornerRadius = UDim.new(0, 15)
    flingCorner.Parent = flingFrame
    
    local flingStroke = Instance.new("UIStroke")
    flingStroke.Color = Color3.fromRGB(60, 60, 70)
    flingStroke.Thickness = 2
    flingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    flingStroke.Parent = flingFrame
    
    local flingGradient = Instance.new("UIGradient")
    flingGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    flingGradient.Rotation = 45
    flingGradient.Parent = flingFrame
    
    local flingTitle = Instance.new("TextLabel")
    flingTitle.Size = UDim2.new(1, -40, 0, 50)
    flingTitle.Position = UDim2.new(0, 20, 0, 15)
    flingTitle.BackgroundTransparency = 1
    flingTitle.Text = "PLAYER FLING"
    flingTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    flingTitle.TextSize = 24
    flingTitle.Font = Enum.Font.GothamBold
    flingTitle.TextXAlignment = Enum.TextXAlignment.Left
    flingTitle.Parent = flingFrame
    
    local flingTextGlow = Instance.new("UIStroke")
    flingTextGlow.Color = Color3.fromRGB(255, 100, 100)
    flingTextGlow.Thickness = 1
    flingTextGlow.Transparency = 0.5
    flingTextGlow.Parent = flingTitle
    
    local playerListFrame = Instance.new("ScrollingFrame")
    playerListFrame.Size = UDim2.new(0, 260, 0, 250)
    playerListFrame.Position = UDim2.new(0, 20, 0, 75)
    playerListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    playerListFrame.BorderSizePixel = 0
    playerListFrame.ScrollBarThickness = 6
    playerListFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerListFrame.Parent = flingFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = playerListFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = playerListFrame
    
    local selectedPlayer = nil
    local flinging = false
    local flingConnection = nil
    local originalVelocity = nil
    
    local function createPlayerButton(plr)
        if plr == player then return end
        
        local btn = Instance.new("TextButton")
        btn.Name = plr.Name
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.BorderSizePixel = 0
        btn.Text = plr.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 16
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        btn.Parent = playerListFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = plr
            for _, child in pairs(playerListFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        end)
    end
    
    local function updatePlayerList()
        for _, child in pairs(playerListFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            createPlayerButton(plr)
        end
        playerListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    
    local flingButton = Instance.new("TextButton")
    flingButton.Size = UDim2.new(0, 125, 0, 45)
    flingButton.Position = UDim2.new(0, 20, 0, 340)
    flingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    flingButton.BorderSizePixel = 0
    flingButton.Text = "FLING"
    flingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flingButton.TextSize = 18
    flingButton.Font = Enum.Font.GothamBold
    flingButton.AutoButtonColor = false
    flingButton.Parent = flingFrame
    
    local flingBtnCorner = Instance.new("UICorner")
    flingBtnCorner.CornerRadius = UDim.new(0, 10)
    flingBtnCorner.Parent = flingButton
    
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0, 125, 0, 45)
    stopButton.Position = UDim2.new(0, 155, 0, 340)
    stopButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    stopButton.BorderSizePixel = 0
    stopButton.Text = "STOP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 18
    stopButton.Font = Enum.Font.GothamBold
    stopButton.AutoButtonColor = false
    stopButton.Parent = flingFrame
    
    local stopBtnCorner = Instance.new("UICorner")
    stopBtnCorner.CornerRadius = UDim.new(0, 10)
    stopBtnCorner.Parent = stopButton
    
    local function startFling()
        if not selectedPlayer or flinging then return end
        local targetChar = selectedPlayer.Character
        if not targetChar then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        flinging = true
        flingButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        originalVelocity = hrp.AssemblyLinearVelocity
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        
        flingConnection = RunService.Heartbeat:Connect(function()
            if not targetChar or not targetChar.Parent or not targetHRP or not targetHRP.Parent then
                stopButton:Activate()
                return
            end
            hrp.CFrame = targetHRP.CFrame
            hrp.AssemblyLinearVelocity = Vector3.new(0, 99999, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
        end)
    end
    
    local function stopFling()
        if not flinging then return end
        flinging = false
        flingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
        
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and originalVelocity then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
    
    flingButton.MouseButton1Click:Connect(startFling)
    stopButton.MouseButton1Click:Connect(stopFling)
    
    local function teleportToSpawn()
        if not spawnCaptured or not spawnPosition then
            warn("Позиция спавна еще не сохранена!")
            return
        end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spawnPosition
                print("Телепортирован на спавн!")
            end
        end
    end
    
    tpButton.MouseButton1Click:Connect(teleportToSpawn)
    
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    updatePlayerList()
    
    player.CharacterAdded:Connect(function(char)
        character = char
        humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        stopFling()
        
        if not spawnCaptured then
            wait(0.3)
            spawnPosition = humanoidRootPart.CFrame
            spawnCaptured = true
            print("Позиция спавна сохранена: " .. tostring(spawnPosition))
        end
    end)
    
    tpFrame.Size = UDim2.new(0, 0, 0, 0)
    flingFrame.Size = UDim2.new(0, 0, 0, 0)
    
    local openTween1 = TweenService:Create(tpFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 150)})
    local openTween2 = TweenService:Create(flingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 400)})
    
    openTween1:Play()
    wait(0.1)
    openTween2:Play()
    
    print("✓ Exploit GUI загружен успешно!")
end

-- Анимация появления
subFrame.Size = UDim2.new(0, 0, 0, 0)
overlay.BackgroundTransparency = 1

TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
TweenService:Create(subFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 300)}):Play()

-- Анимация замка (качание)
spawn(function()
    while lockIcon.Parent do
        TweenService:Create(lockIcon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 10}):Play()
        wait(1)
        TweenService:Create(lockIcon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = -10}):Play()
        wait(1)
    end
end)

-- Запускаем проверку
wait(0.5)
checkWhitelist()
