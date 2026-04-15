--[[
╔══════════════════════════════════════════════════════════════════╗
║                     BranzZ Hub Tp  v1.3                         ║
║              UI iOS Dark — Cinza + Preto                         ║
║         PASSO 1: Mark Position  →  PASSO 2: TP Sky              ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis do sistema
local markedPosition = nil
local markerPart = nil
local lastPosition = nil
local isTeleporting = false
local returnConnection = nil

-- Helper de notificação (padrão BranZZ Hub)
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 4})
    end)
end

-- ══════════════════════════════════════════
--              FUNÇÕES (sem alteração)
-- ══════════════════════════════════════════

local function createMarker(position)
    if markerPart and markerPart.Parent then
        markerPart:Destroy()
    end

    local marker = Instance.new("Part")
    marker.Name = "PositionMarker"
    marker.Size = Vector3.new(3, 0.5, 3)
    marker.Position = position
    marker.Anchored = true
    marker.CanCollide = false
    marker.Transparency = 0.3
    marker.BrickColor = BrickColor.new("Bright blue")
    marker.Material = Enum.Material.Neon
    marker.Parent = Workspace

    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = marker
    selectionBox.Color3 = Color3.fromRGB(0, 150, 255)
    selectionBox.Transparency = 0.5
    selectionBox.LineThickness = 0.1
    selectionBox.Parent = marker

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(0, 150, 255)
    light.Range = 10
    light.Brightness = 2
    light.Parent = marker

    local attachment = Instance.new("Attachment")
    attachment.Parent = marker

    local particles = Instance.new("ParticleEmitter")
    particles.Parent = attachment
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Rate = 50
    particles.Lifetime = NumberRange.new(0.5)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.VelocityInheritance = 0
    particles.Speed = NumberRange.new(2)
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Color = ColorSequence.new(Color3.fromRGB(0, 150, 255))
    particles.Size = NumberSequence.new(0.5)

    local originalY = position.Y
    task.spawn(function()
        local time = 0
        while marker and marker.Parent do
            time = time + 0.05
            local newY = originalY + math.sin(time * 3) * 0.2
            pcall(function()
                marker.Position = Vector3.new(position.X, newY, position.Z)
            end)
            task.wait(0.05)
        end
    end)

    markerPart = marker

    notify(
        "✅ BranzZ Hub Tp — Posição Salva!",
        string.format("Marca definida em  X:%.0f  Y:%.0f  Z:%.0f  —  Agora use TP Sky ou Back & Forth!", position.X, position.Y, position.Z),
        5
    )

    return marker
end

local function teleportTo(position, shouldSavePosition)
    if isTeleporting then return false end
    isTeleporting = true

    pcall(function()
        if shouldSavePosition and not lastPosition then
            lastPosition = RootPart.CFrame
        end

        local originalTransparency = {}
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 0.8
            end
        end

        local teleportEffect = Instance.new("Part")
        teleportEffect.Size = Vector3.new(5, 5, 5)
        teleportEffect.Position = RootPart.Position
        teleportEffect.Anchored = true
        teleportEffect.CanCollide = false
        teleportEffect.Transparency = 0.5
        teleportEffect.BrickColor = BrickColor.new("Bright blue")
        teleportEffect.Material = Enum.Material.Neon
        teleportEffect.Parent = Workspace

        local effectAttachment = Instance.new("Attachment")
        effectAttachment.Parent = teleportEffect

        local effectParticles = Instance.new("ParticleEmitter")
        effectParticles.Parent = effectAttachment
        effectParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        effectParticles.Rate = 200
        effectParticles.Lifetime = NumberRange.new(0.3)
        effectParticles.SpreadAngle = Vector2.new(360, 360)
        effectParticles.Speed = NumberRange.new(5)
        effectParticles.Transparency = NumberSequence.new(1, 0, 1)

        task.wait(0.2)
        RootPart.CFrame = CFrame.new(position)
        if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end
        task.wait(0.1)
        teleportEffect:Destroy()

        for part, trans in pairs(originalTransparency) do
            pcall(function() part.Transparency = trans end)
        end

        local arrivalEffect = teleportEffect:Clone()
        arrivalEffect.Position = position
        arrivalEffect.Parent = Workspace
        task.wait(0.2)
        arrivalEffect:Destroy()
    end)

    task.wait(0.1)
    isTeleporting = false
    return true
end

local function tpSky()
    if not markedPosition then
        notify("⚠️ BranzZ Hub Tp", "Você ainda não marcou nenhuma posição! Clique em  [ 1 · Mark Position ]  primeiro.", 4)
        return
    end

    pcall(function()
        local currentPos = RootPart.CFrame
        local skyPos = CFrame.new(currentPos.X, 1000, currentPos.Z)
        RootPart.CFrame = skyPos
        task.wait(0.1)
        RootPart.CFrame = CFrame.new(markedPosition)
        if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end
        notify("☁️ BranzZ Hub Tp — TP Sky", "Teleportado para a posição marcada! Você vai FICAR lá.", 3)
    end)
end

local function tpBackAndForth()
    if not markedPosition then
        notify("⚠️ BranzZ Hub Tp", "Você ainda não marcou nenhuma posição! Clique em  [ 1 · Mark Position ]  primeiro.", 4)
        return
    end

    if returnConnection then
        returnConnection:Disconnect()
        returnConnection = nil
    end

    pcall(function()
        local originPos = RootPart.CFrame
        local skyPos = CFrame.new(originPos.X, 1000, originPos.Z)
        local targetPos = CFrame.new(markedPosition)

        RootPart.CFrame = skyPos
        task.wait(0.1)
        RootPart.CFrame = targetPos
        if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end

        notify("🔄 BranzZ Hub Tp — Back & Forth", "Chegou na marca! Voltando automaticamente em 2 segundos...", 2)

        returnConnection = RunService.Heartbeat:Connect(function()
            local startTime = tick()
            returnConnection:Disconnect()

            local timerConn = nil
            timerConn = RunService.Heartbeat:Connect(function()
                if tick() - startTime >= 2 then
                    timerConn:Disconnect()
                    pcall(function()
                        local currentPos = RootPart.CFrame
                        local returnSkyPos = CFrame.new(currentPos.X, 1000, currentPos.Z)
                        RootPart.CFrame = returnSkyPos
                        task.wait(0.1)
                        RootPart.CFrame = originPos
                        if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end
                        notify("🔄 BranzZ Hub Tp — Back & Forth", "Voltou para a posição original!", 3)
                    end)
                end
            end)
        end)
    end)
end

-- ══════════════════════════════════════════
--        UI — BranzZ Hub Tp  v1.3
-- ══════════════════════════════════════════

local function createUI()
    -- Limpar UI antiga
    pcall(function()
        local old = CoreGui:FindFirstChild("BranzzHubTp")
        if old then old:Destroy() end
        local old2 = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("BranzzHubTp")
        if old2 then old2:Destroy() end
    end)

    -- Paleta iOS Dark
    local C = {
        bg          = Color3.fromRGB(15, 15, 18),
        surface     = Color3.fromRGB(26, 26, 30),
        elevated    = Color3.fromRGB(36, 36, 42),
        separator   = Color3.fromRGB(52, 52, 60),
        labelPrimary   = Color3.fromRGB(245, 245, 250),
        labelSecondary = Color3.fromRGB(130, 130, 142),
        cyan        = Color3.fromRGB(0, 200, 230),
        accent      = Color3.fromRGB(10, 132, 255),
        sky         = Color3.fromRGB(94, 92, 230),
        forth       = Color3.fromRGB(48, 209, 88),
        danger      = Color3.fromRGB(255, 69, 58),
        stepBadge   = Color3.fromRGB(255, 210, 0),
    }

    local sg = Instance.new("ScreenGui")
    sg.Name = "BranzzHubTp"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false

    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then
        sg.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end

    -- ══════════════════════════════════════
    -- BANNER TOPO (estilo BranZZ Hub)
    -- ══════════════════════════════════════
    local banner = Instance.new("Frame", sg)
    banner.Size = UDim2.new(0, 420, 0, 34)
    banner.Position = UDim2.new(0.5, -210, 0, 0)
    banner.BackgroundColor3 = Color3.fromRGB(6, 6, 9)
    banner.BorderSizePixel = 0

    local bannerCorner = Instance.new("UICorner", banner)
    bannerCorner.CornerRadius = UDim.new(0, 0)

    local bannerStroke = Instance.new("UIStroke", banner)
    bannerStroke.Color = C.cyan
    bannerStroke.Thickness = 1.5

    local bannerGrad = Instance.new("UIGradient", banner)
    bannerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 28, 42)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(6, 6, 9)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 28, 42)),
    })

    local bannerTxt = Instance.new("TextLabel", banner)
    bannerTxt.Size = UDim2.new(1, -10, 1, 0)
    bannerTxt.Position = UDim2.new(0, 5, 0, 0)
    bannerTxt.BackgroundTransparency = 1
    bannerTxt.TextColor3 = C.labelPrimary
    bannerTxt.Font = Enum.Font.GothamBold
    bannerTxt.TextSize = 13
    bannerTxt.TextXAlignment = Enum.TextXAlignment.Center
    bannerTxt.RichText = true
    bannerTxt.Text = '<font color="rgb(0,200,230)">BranzZ Hub Tp</font>  —  <font color="rgb(130,130,142)">esse script e gratis somente em https://discord.gg/69xw56bg2J </font>'

    -- Borda RGB animada no banner
    task.spawn(function()
        local hue = 0
        while banner and banner.Parent do
            hue = (hue + 0.008) % 1
            bannerStroke.Color = Color3.fromHSV(hue, 0.9, 1)
            task.wait(0.04)
        end
    end)

    -- ══════════════════════════════════════
    -- FRAME PRINCIPAL
    -- ══════════════════════════════════════
    local mainFrame = Instance.new("Frame", sg)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 268, 0, 330)
    mainFrame.Position = UDim2.new(0.5, -134, 0.5, -165)
    mainFrame.BackgroundColor3 = C.bg
    mainFrame.BorderSizePixel = 0

    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 20)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = C.separator
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.35

    -- ── HEADER ──────────────────────────────
    local header = Instance.new("Frame", mainFrame)
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 54)
    header.BackgroundTransparency = 1

    -- Pill drag
    local pill = Instance.new("Frame", header)
    pill.Size = UDim2.new(0, 38, 0, 4)
    pill.Position = UDim2.new(0.5, -19, 0, 7)
    pill.BackgroundColor3 = C.separator
    pill.BorderSizePixel = 0
    local pillC = Instance.new("UICorner", pill)
    pillC.CornerRadius = UDim.new(1, 0)

    -- Ícone BZ
    local iconBg = Instance.new("Frame", header)
    iconBg.Size = UDim2.new(0, 30, 0, 30)
    iconBg.Position = UDim2.new(0, 14, 0, 16)
    iconBg.BackgroundColor3 = C.cyan
    iconBg.BorderSizePixel = 0
    local iconBgC = Instance.new("UICorner", iconBg)
    iconBgC.CornerRadius = UDim.new(0, 9)
    local iconBgGrad = Instance.new("UIGradient", iconBg)
    iconBgGrad.Color = ColorSequence.new(Color3.fromRGB(0,180,210), Color3.fromRGB(10,132,255))
    iconBgGrad.Rotation = 135

    local iconLbl = Instance.new("TextLabel", iconBg)
    iconLbl.Text = "BZ"
    iconLbl.TextColor3 = Color3.fromRGB(255,255,255)
    iconLbl.TextSize = 12
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.BackgroundTransparency = 1
    iconLbl.Size = UDim2.new(1,0,1,0)

    -- Título
    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Text = "BranzZ Hub Tp"
    titleLbl.TextColor3 = C.labelPrimary
    titleLbl.TextSize = 15
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 52, 0, 14)
    titleLbl.Size = UDim2.new(0, 170, 0, 20)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local verLbl = Instance.new("TextLabel", header)
    verLbl.Text = "v1.3"
    verLbl.TextColor3 = C.labelSecondary
    verLbl.TextSize = 11
    verLbl.Font = Enum.Font.Gotham
    verLbl.BackgroundTransparency = 1
    verLbl.Position = UDim2.new(0, 52, 0, 33)
    verLbl.Size = UDim2.new(0, 60, 0, 14)
    verLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão fechar
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Text = ""
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -42, 0, 14)
    closeBtn.BackgroundColor3 = C.elevated
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    local closeBtnC = Instance.new("UICorner", closeBtn)
    closeBtnC.CornerRadius = UDim.new(1, 0)
    local closeIcon = Instance.new("TextLabel", closeBtn)
    closeIcon.Text = "❌❌️"
    closeIcon.TextColor3 = C.labelSecondary
    closeIcon.TextSize = 12
    closeIcon.Font = Enum.Font.GothamBold
    closeIcon.BackgroundTransparency = 1
    closeIcon.Size = UDim2.new(1,0,1,0)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.danger}):Play()
        TweenService:Create(closeIcon, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.elevated}):Play()
        TweenService:Create(closeIcon, TweenInfo.new(0.15), {TextColor3 = C.labelSecondary}):Play()
    end)

    -- Separador
    local sep = Instance.new("Frame", mainFrame)
    sep.Size = UDim2.new(1, -28, 0, 1)
    sep.Position = UDim2.new(0, 14, 0, 54)
    sep.BackgroundColor3 = C.separator
    sep.BackgroundTransparency = 0.45
    sep.BorderSizePixel = 0

    -- ── STATUS CARD ─────────────────────────
    local statusCard = Instance.new("Frame", mainFrame)
    statusCard.Size = UDim2.new(1, -28, 0, 46)
    statusCard.Position = UDim2.new(0, 14, 0, 64)
    statusCard.BackgroundColor3 = C.surface
    statusCard.BorderSizePixel = 0
    local scC = Instance.new("UICorner", statusCard)
    scC.CornerRadius = UDim.new(0, 12)

    local statusDot = Instance.new("Frame", statusCard)
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 14, 0.5, -4)
    statusDot.BackgroundColor3 = C.labelSecondary
    statusDot.BorderSizePixel = 0
    local sdC = Instance.new("UICorner", statusDot)
    sdC.CornerRadius = UDim.new(1, 0)

    local statusTitle = Instance.new("TextLabel", statusCard)
    statusTitle.Text = "Sem posição marcada"
    statusTitle.TextColor3 = C.labelSecondary
    statusTitle.TextSize = 12
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.BackgroundTransparency = 1
    statusTitle.Position = UDim2.new(0, 30, 0, 6)
    statusTitle.Size = UDim2.new(1, -44, 0, 16)
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left

    local statusSub = Instance.new("TextLabel", statusCard)
    statusSub.Text = "Clique no botão 1 abaixo para marcar"
    statusSub.TextColor3 = C.labelSecondary
    statusSub.TextSize = 10
    statusSub.Font = Enum.Font.Gotham
    statusSub.BackgroundTransparency = 1
    statusSub.Position = UDim2.new(0, 30, 0, 24)
    statusSub.Size = UDim2.new(1, -44, 0, 14)
    statusSub.TextXAlignment = Enum.TextXAlignment.Left

    -- ── HELPER: criar botão com badge de passo ──
    local function makeButton(yPos, stepNum, icon, label, sublabel, accentColor, callback)
        local card = Instance.new("TextButton", mainFrame)
        card.Text = ""
        card.Size = UDim2.new(1, -28, 0, 54)
        card.Position = UDim2.new(0, 14, 0, yPos)
        card.BackgroundColor3 = C.surface
        card.BorderSizePixel = 0
        card.AutoButtonColor = false

        local cardCorner = Instance.new("UICorner", card)
        cardCorner.CornerRadius = UDim.new(0, 14)

        -- Badge de passo (número)
        local badge = Instance.new("Frame", card)
        badge.Size = UDim2.new(0, 18, 0, 18)
        badge.Position = UDim2.new(0, 8, 0, 6)
        badge.BackgroundColor3 = accentColor
        badge.BackgroundTransparency = 0.3
        badge.BorderSizePixel = 0
        local badgeC = Instance.new("UICorner", badge)
        badgeC.CornerRadius = UDim.new(1, 0)
        local badgeTxt = Instance.new("TextLabel", badge)
        badgeTxt.Text = tostring(stepNum)
        badgeTxt.TextColor3 = Color3.fromRGB(255,255,255)
        badgeTxt.TextSize = 10
        badgeTxt.Font = Enum.Font.GothamBold
        badgeTxt.BackgroundTransparency = 1
        badgeTxt.Size = UDim2.new(1,0,1,0)

        -- Ícone colorido
        local iconBox = Instance.new("Frame", card)
        iconBox.Size = UDim2.new(0, 34, 0, 34)
        iconBox.Position = UDim2.new(0, 12, 0.5, -17)
        iconBox.BackgroundColor3 = accentColor
        iconBox.BackgroundTransparency = 0.78
        iconBox.BorderSizePixel = 0
        local ibC = Instance.new("UICorner", iconBox)
        ibC.CornerRadius = UDim.new(0, 10)

        local iconTxt = Instance.new("TextLabel", iconBox)
        iconTxt.Text = icon
        iconTxt.TextSize = 17
        iconTxt.Font = Enum.Font.GothamBold
        iconTxt.BackgroundTransparency = 1
        iconTxt.Size = UDim2.new(1,0,1,0)
        iconTxt.TextColor3 = accentColor

        -- Label principal
        local mainTxt = Instance.new("TextLabel", card)
        mainTxt.Text = label
        mainTxt.TextColor3 = C.labelPrimary
        mainTxt.TextSize = 13
        mainTxt.Font = Enum.Font.GothamBold
        mainTxt.BackgroundTransparency = 1
        mainTxt.Position = UDim2.new(0, 54, 0, 9)
        mainTxt.Size = UDim2.new(1, -70, 0, 18)
        mainTxt.TextXAlignment = Enum.TextXAlignment.Left

        -- Sublabel
        local subTxt = Instance.new("TextLabel", card)
        subTxt.Text = sublabel
        subTxt.TextColor3 = C.labelSecondary
        subTxt.TextSize = 10
        subTxt.Font = Enum.Font.Gotham
        subTxt.BackgroundTransparency = 1
        subTxt.Position = UDim2.new(0, 54, 0, 28)
        subTxt.Size = UDim2.new(1, -70, 0, 16)
        subTxt.TextXAlignment = Enum.TextXAlignment.Left

        -- Chevron
        local chev = Instance.new("TextLabel", card)
        chev.Text = "›"
        chev.TextColor3 = C.separator
        chev.TextSize = 22
        chev.Font = Enum.Font.GothamBold
        chev.BackgroundTransparency = 1
        chev.Position = UDim2.new(1, -20, 0.5, -13)
        chev.Size = UDim2.new(0, 14, 0, 26)

        -- Hover / press
        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C.elevated}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C.surface}):Play()
        end)
        card.MouseButton1Down:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.07), {BackgroundTransparency = 0.38}):Play()
        end)
        card.MouseButton1Up:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.07), {BackgroundTransparency = 0}):Play()
        end)
        card.MouseButton1Click:Connect(function()
            pcall(callback)
        end)

        return card
    end

    -- ── BOTÃO 1: Mark Position ───────────────
    makeButton(120, 1, "📍", "Mark Position", "marca uma posição pra tp", C.accent, function()
        if Character and RootPart then
            local pos = RootPart.Position
            markedPosition = pos
            createMarker(pos)

            -- Atualiza status card
            statusDot.BackgroundColor3 = C.forth
            statusTitle.Text = "✅  Posição marcada!"
            statusTitle.TextColor3 = C.forth
            statusSub.Text = string.format("X:%.0f  Y:%.0f  Z:%.0f  —  já pode usar o TP", pos.X, pos.Y, pos.Z)
            statusSub.TextColor3 = C.labelSecondary
        end
    end)

    -- ── BOTÃO 2: TP Sky ──────────────────────
    makeButton(184, 2, "☁️", "TP Flash", "Teleporta para a sua posição", C.sky, function()
        tpSky()
    end)

    -- ── BOTÃO 3: TP Back & Forth ─────────────
    makeButton(248, 3, "🔄", "TP Back & Forth", "Vai e volta para posição", C.forth, function()
        tpBackAndForth()
    end)

    -- ── DRAG ────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil

    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, 820)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 34, 520)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    -- Fechar
    closeBtn.MouseButton1Click:Connect(function()
        if markerPart and markerPart.Parent then markerPart:Destroy() end
        if returnConnection then returnConnection:Disconnect() end
        TweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 268, 0, 0),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.2, function() sg:Destroy() end)
    end)

    return sg
end

-- ══════════════════════════════════════════
--               INIT
-- ══════════════════════════════════════════
local function init()
    print("═══════════════════════════════════════════════════════════")
    print("          BranzZ Hub Tp  v1.3  —  iOS Dark                ")
    print("═══════════════════════════════════════════════════════════")

    createUI()

    notify(
        "BranzZ Hub Tp  v1.3",
        "Carregado!  PASSO 1: Mark Position  →  PASSO 2: TP Sky",
        5
    )
end

local ok, err = pcall(init)
if not ok then
    warn("Erro: " .. tostring(err))
    pcall(createUI)
end

-- Limpeza ao resetar personagem
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    isTeleporting = false
    if returnConnection then
        returnConnection:Disconnect()
        returnConnection = nil
    end
end)
