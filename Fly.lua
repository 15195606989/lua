local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local hum=char:WaitForChild("Humanoid")
local cam=workspace.CurrentCamera

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

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,25)
title.Text="✈️ 飞行"
title.TextColor3=Color3.new(0.6,0.85,1)
title.TextSize=13
title.Font=Enum.Font.GothamBold
title.BackgroundTransparency=1
title.Parent=panel

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

-- 上升/下降键
local btnUp=Instance.new("TextButton")
btnUp.Size=UDim2.new(0,55,0,55)
btnUp.Position=UDim2.new(1,-65,0.65,0)
btnUp.BackgroundColor3=Color3.new(0.1,0.5,0.2)
btnUp.BackgroundTransparency=0.3
btnUp.BorderSizePixel=0
btnUp.Text="⬆"
btnUp.TextColor3=Color3.new(1,1,1)
btnUp.TextSize=22
btnUp.Font=Enum.Font.GothamBold
btnUp.Parent=gui
btnUp.Visible=false

local btnDown=Instance.new("TextButton")
btnDown.Size=UDim2.new(0,55,0,55)
btnDown.Position=UDim2.new(1,-65,0.65,60)
btnDown.BackgroundColor3=Color3.new(0.5,0.1,0.1)
btnDown.BackgroundTransparency=0.3
btnDown.BorderSizePixel=0
btnDown.Text="⬇"
btnDown.TextColor3=Color3.new(1,1,1)
btnDown.TextSize=22
btnDown.Font=Enum.Font.GothamBold
btnDown.Parent=gui
btnDown.Visible=false

local flyOn=false
local flySpeed=60
local upHeld=false
local downHeld=false
local antiGravForce=nil

-- 隐藏跳跃键
local function hideJump()
    local jump=plr.PlayerGui:FindFirstChild("JumpButton")or plr.PlayerGui:FindFirstChild("Jump")
    if not jump then
        for _,child in pairs(plr.PlayerGui:GetChildren())do
            if child.Name:lower():find("jump")then
                jump=child
                break
            end
        end
    end
    if jump then jump.Visible=false end
end

local function showJump()
    local jump=plr.PlayerGui:FindFirstChild("JumpButton")or plr.PlayerGui:FindFirstChild("Jump")
    if not jump then
        for _,child in pairs(plr.PlayerGui:GetChildren())do
            if child.Name:lower():find("jump")then
                jump=child
                break
            end
        end
    end
    if jump then jump.Visible=true end
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

btnFly.MouseButton1Click:Connect(function()
    flyOn=not flyOn
    if flyOn then
        btnFly.Text="🟢 飞行: 开"
        btnFly.BackgroundColor3=Color3.new(0,0.5,0.1)
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
    end
end)

btnUp.MouseButton1Down:Connect(function()if flyOn then upHeld=true end end)
btnUp.MouseButton1Up:Connect(function()upHeld=false end)
btnUp.MouseLeave:Connect(function()upHeld=false end)

btnDown.MouseButton1Down:Connect(function()if flyOn then downHeld=true end end)
btnDown.MouseButton1Up:Connect(function()downHeld=false end)
btnDown.MouseLeave:Connect(function()downHeld=false end)

btnMinus.MouseButton1Click:Connect(function()
    flySpeed=math.max(10,flySpeed-10)
    speedLabel.Text="速度: "..flySpeed
end)

btnPlus.MouseButton1Click:Connect(function()
    flySpeed=math.min(500,flySpeed+10)
    speedLabel.Text="速度: "..flySpeed
end)

btnClose.MouseButton1Click:Connect(function()
    if flyOn then
        hum.PlatformStand=false
        hum.JumpPower=50
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=true end
        end
        removeAntiGrav()
        showJump()
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
    btnFly.Text="🔴 飞行: 关"
    btnFly.BackgroundColor3=Color3.new(0.6,0.1,0.1)
    btnUp.Visible=false
    btnDown.Visible=false
    showJump()
end)
