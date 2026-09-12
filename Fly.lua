local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local hum=char:WaitForChild("Humanoid")
local cam=workspace.CurrentCamera
local UIS=game:GetService("UserInputService")

if plr.PlayerGui:FindFirstChild("FLY_UI")then plr.PlayerGui.FLY_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="FLY_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,130)
panel.Position=UDim2.new(1,-150,0.5,-65)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui
panel.Active=true

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="✈️ 飞行 (长按拖动)"
title.TextColor3=Color3.new(0.6,0.85,1)
title.TextSize=11
title.Font=Enum.Font.GothamBold
title.BackgroundTransparency=1
title.Parent=panel

local dragging=false
local dragStart=nil
local startPos=nil

title.MouseButton1Down:Connect(function()
    dragging=true
    dragStart=Vector2.new(title.AbsolutePosition.X,title.AbsolutePosition.Y)
    startPos=panel.Position
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

local btnFly=Instance.new("TextButton")
btnFly.Size=UDim2.new(0.9,0,0,30)
btnFly.Position=UDim2.new(0.05,0,0,30)
btnFly.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnFly.BackgroundTransparency=0.3
btnFly.BorderSizePixel=0
btnFly.Text="🔴 飞行: 关"
btnFly.TextColor3=Color3.new(1,1,1)
btnFly.TextSize=12
btnFly.Font=Enum.Font.GothamSemibold
btnFly.Parent=panel

local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(1,0,0,20)
speedLabel.Position=UDim2.new(0,0,0,62)
speedLabel.Text="速度: 60"
speedLabel.TextColor3=Color3.new(0.8,0.9,1)
speedLabel.TextSize=11
speedLabel.BackgroundTransparency=1
speedLabel.Parent=panel

local btnMinus=Instance.new("TextButton")
btnMinus.Size=UDim2.new(0,30,0,20)
btnMinus.Position=UDim2.new(0.5,-40,0,84)
btnMinus.Text="−"
btnMinus.TextColor3=Color3.new(1,1,1)
btnMinus.TextSize=14
btnMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnMinus.BackgroundTransparency=0.3
btnMinus.BorderSizePixel=0
btnMinus.Parent=panel

local btnPlus=Instance.new("TextButton")
btnPlus.Size=UDim2.new(0,30,0,20)
btnPlus.Position=UDim2.new(0.5,10,0,84)
btnPlus.Text="+"
btnPlus.TextColor3=Color3.new(1,1,1)
btnPlus.TextSize=14
btnPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
btnPlus.BackgroundTransparency=0.3
btnPlus.BorderSizePixel=0
btnPlus.Parent=panel

local btnClose=Instance.new("TextButton")
btnClose.Size=UDim2.new(0,25,0,25)
btnClose.Position=UDim2.new(1,-28,0,0)
btnClose.BackgroundTransparency=1
btnClose.Text="✕"
btnClose.TextColor3=Color3.new(1,0.3,0.3)
btnClose.TextSize=14
btnClose.Font=Enum.Font.GothamBold
btnClose.Parent=panel

local btnUp=Instance.new("TextButton")
btnUp.Size=UDim2.new(0,55,0,55)
btnUp.Position=UDim2.new(1,-65,0.5,0)
btnUp.BackgroundColor3=Color3.new(0.1,0.5,0.2)
btnUp.BackgroundTransparency=0.3
btnUp.BorderSizePixel=0
btnUp.Text="⬆"
btnUp.TextColor3=Color3.new(1,1,1)
btnUp.TextSize=22
btnUp.Font=Enum.Font.GothamBold
btnUp.Parent=gui
btnUp.Visible=false
btnUp.ZIndex=50

local btnDown=Instance.new("TextButton")
btnDown.Size=UDim2.new(0,55,0,55)
btnDown.Position=UDim2.new(1,-65,0.5,60)
btnDown.BackgroundColor3=Color3.new(0.5,0.1,0.1)
btnDown.BackgroundTransparency=0.3
btnDown.BorderSizePixel=0
btnDown.Text="⬇"
btnDown.TextColor3=Color3.new(1,1,1)
btnDown.TextSize=22
btnDown.Font=Enum.Font.GothamBold
btnDown.Parent=gui
btnDown.Visible=false
btnDown.ZIndex=50

local flyOn=false
local flySpeed=60
local upHeld=false
local downHeld=false
local antiGravForce=nil
local healConn=nil

local function setupHold(btn,callback,delayTime)
    local holding=false
    btn.MouseButton1Down:Connect(function()
        holding=true
        callback()
        task.spawn(function()
            task.wait(delayTime or 0.3)
            while holding do
                task.wait(0.05)
                if holding then callback()end
            end
        end)
    end)
    btn.MouseButton1Up:Connect(function()holding=false end)
    btn.MouseLeave:Connect(function()holding=false end)
end

local function findJump()
    local ok,jump=pcall(function()
        return plr.PlayerGui:FindFirstChild("JumpButton")or plr.PlayerGui:FindFirstChild("Jump")
    end)
    if ok and jump then return jump end
    for _,child in pairs(plr.PlayerGui:GetChildren())do
        if child.Name:lower():find("jump")then return child end
    end
    for _,child in pairs(plr.PlayerGui:GetDescendants())do
        if child.Name:lower():find("jump")then return child end
    end
    return nil
end

local function hideJump()
    local j=findJump()
    if j then j.Visible=false end
end

local function showJump()
    local j=findJump()
    if j then j.Visible=true end
end

local function createAntiGrav()
    if antiGravForce then antiGravForce:Destroy()end
    antiGravForce=Instance.new("BodyForce")
    antiGravForce.Force=Vector3.new(0,workspace.Gravity*root:GetMass(),0)
    antiGravForce.Parent=root
end

local function removeAntiGrav()
    if antiGravForce then
        antiGravForce:Destroy()
        antiGravForce=nil
    end
end

-- 防摔死：临时无敌 + 禁用摔落状态
local function startInvincible()
    if healConn then healConn:Disconnect()end
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    hum.Health=hum.MaxHealth
    healConn=game:GetService("RunService").Heartbeat:Connect(function()
        if hum then hum.Health=hum.MaxHealth end
    end)
    task.delay(1.5,function()
        if healConn then
            healConn:Disconnect()
            healConn=nil
        end
    end)
end

local function endInvincible()
    if healConn then
        healConn:Disconnect()
        healConn=nil
    end
end

btnFly.MouseButton1Click:Connect(function()
    flyOn=not flyOn
    if flyOn then
        btnFly.Text="🟢 飞行: 开"
        btnFly.BackgroundColor3=Color3.new(0,0.5,0.1)
        startInvincible()
        hum.PlatformStand=true
        hum.JumpPower=0
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=false end
        end
        createAntiGrav()
        btnUp.Visible=true
        btnDown.Visible=true
        hideJump()
    else
        btnFly.Text="🔴 飞行: 关"
        btnFly.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        hum.PlatformStand=false
        hum.JumpPower=50
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=true end
        end
        removeAntiGrav()
        btnUp.Visible=false
        btnDown.Visible=false
        upHeld=false
        downHeld=false
        showJump()
        task.delay(1.5,function()
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)end
        end)
    end
end)

btnUp.MouseButton1Down:Connect(function()if flyOn then upHeld=true end end)
btnUp.MouseButton1Up:Connect(function()upHeld=false end)
btnUp.MouseLeave:Connect(function()upHeld=false end)

btnDown.MouseButton1Down:Connect(function()if flyOn then downHeld=true end end)
btnDown.MouseButton1Up:Connect(function()downHeld=false end)
btnDown.MouseLeave:Connect(function()downHeld=false end)

setupHold(btnMinus,function()
    flySpeed=math.max(10,flySpeed-5)
    speedLabel.Text="速度: "..flySpeed
end,0.4)

setupHold(btnPlus,function()
    flySpeed=math.min(500,flySpeed+5)
    speedLabel.Text="速度: "..flySpeed
end,0.4)

btnClose.MouseButton1Click:Connect(function()
    if flyOn then
        hum.PlatformStand=false
        hum.JumpPower=50
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=true end
        end
        removeAntiGrav()
        showJump()
        task.delay(1.5,function()
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)end
        end)
    end
    gui:Destroy()
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if not flyOn then return end
    if not root or not hum then return end
    
    for _,p in pairs(char:GetDescendants())do
        if p:IsA("BasePart")then p.CanCollide=false end
    end
    hum.PlatformStand=true
    
    root.Velocity=Vector3.new(0,0,0)
    root.AssemblyLinearVelocity=Vector3.new(0,0,0)
    
    local lookDir=(cam.CFrame.Position-root.Position).Unit
    lookDir=Vector3.new(lookDir.X,0,lookDir.Z).Unit
    if lookDir.Magnitude>0.01 then
        root.CFrame=CFrame.new(root.Position,root.Position-lookDir)
    end
    
    local move=hum.MoveDirection
    local fwd=root.CFrame.LookVector
    local right=root.CFrame.RightVector
    local up=Vector3.new(0,1,0)
    
    local mv=(right*move:Dot(right)+fwd*move:Dot(fwd))*flySpeed*dt
    
    if upHeld then
        mv=mv+up*flySpeed*dt
    elseif downHeld then
        mv=mv-up*flySpeed*dt
    end
    
    if mv.Magnitude>0 then
        root.CFrame=root.CFrame+mv
    end
end)

plr.CharacterAdded:Connect(function(c)
    char=c
    root=char:WaitForChild("HumanoidRootPart")
    hum=char:WaitForChild("Humanoid")
    flyOn=false
    antiGravForce=nil
    upHeld=false
    downHeld=false
    if healConn then
        healConn:Disconnect()
        healConn=nil
    end
    btnFly.Text="🔴 飞行: 关"
    btnFly.BackgroundColor3=Color3.new(0.6,0.1,0.1)
    btnUp.Visible=false
    btnDown.Visible=false
    showJump()
end)
