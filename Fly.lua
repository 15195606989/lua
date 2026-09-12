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
title.TextSize=12
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

local spdLabel=Instance.new("TextLabel")
spdLabel.Size=UDim2.new(1,0,0,20)
spdLabel.Position=UDim2.new(0,0,0,62)
spdLabel.Text="速度: 60"
spdLabel.TextColor3=Color3.new(0.8,0.9,1)
spdLabel.TextSize=11
spdLabel.BackgroundTransparency=1
spdLabel.Parent=panel

local btnMinus=Instance.new("TextButton")
btnMinus.Size=UDim2.new(0,30,0,20)
btnMinus.Position=UDim2.new(0.5,-40,0,84)
btnMinus.Text="−"
btnMinus.TextColor3=Color3.new(1,1,1)
btnMinus.TextSize=14
btnMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnMinus.BorderSizePixel=0
btnMinus.Parent=panel

local btnPlus=Instance.new("TextButton")
btnPlus.Size=UDim2.new(0,30,0,20)
btnPlus.Position=UDim2.new(0.5,10,0,84)
btnPlus.Text="+"
btnPlus.TextColor3=Color3.new(1,1,1)
btnPlus.TextSize=14
btnPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
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

local flyOn=false
local flySpeed=60
local upH=false
local downH=false

local function setupHold(btn,cb)
    local holding=false
    btn.MouseButton1Down:Connect(function()
        holding=true
        cb()
        task.spawn(function()
            task.wait(0.4)
            while holding do
                task.wait(0.05)
                if holding then cb()end
            end
        end)
    end)
    btn.MouseButton1Up:Connect(function()holding=false end)
    btn.MouseLeave:Connect(function()holding=false end)
end

local function findJump()
    local ok,j=pcall(function()
        return plr.PlayerGui:FindFirstChild("JumpButton")or plr.PlayerGui:FindFirstChild("Jump")
    end)
    if ok and j then return j end
    for _,c in pairs(plr.PlayerGui:GetChildren())do
        if c.Name:lower():find("jump")then return c end
    end
    for _,c in pairs(plr.PlayerGui:GetDescendants())do
        if c.Name:lower():find("jump")then return c end
    end
end

local function hideJump()
    local j=findJump()
    if j then j.Visible=false end
end

local function showJump()
    local j=findJump()
    if j then j.Visible=true end
end

local agForce=nil
local function antiGrav(on)
    if agForce then agForce:Destroy()agForce=nil end
    if on then
        agForce=Instance.new("BodyForce")
        agForce.Force=Vector3.new(0,workspace.Gravity*root:GetMass(),0)
        agForce.Parent=root
    end
end

btnFly.MouseButton1Click:Connect(function()
    flyOn=not flyOn
    if flyOn then
        btnFly.Text="🟢 飞行: 开"
        btnFly.BackgroundColor3=Color3.new(0,0.5,0.1)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        hum.PlatformStand=true
        hum.JumpPower=0
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=false end
        end
        antiGrav(true)
        root.AssemblyLinearVelocity=Vector3.new(0,100,0)
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
        antiGrav(false)
        btnUp.Visible=false
        btnDown.Visible=false
        upH=false
        downH=false
        showJump()
        task.delay(2,function()
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)end
        end)
    end
end)

btnUp.MouseButton1Down:Connect(function()if flyOn then upH=true end end)
btnUp.MouseButton1Up:Connect(function()upH=false end)
btnUp.MouseLeave:Connect(function()upH=false end)
btnDown.MouseButton1Down:Connect(function()if flyOn then downH=true end end)
btnDown.MouseButton1Up:Connect(function()downH=false end)
btnDown.MouseLeave:Connect(function()downH=false end)

setupHold(btnMinus,function()
    flySpeed=math.max(10,flySpeed-5)
    spdLabel.Text="速度: "..flySpeed
end)

setupHold(btnPlus,function()
    flySpeed=math.min(500,flySpeed+5)
    spdLabel.Text="速度: "..flySpeed
end)

btnClose.MouseButton1Click:Connect(function()
    if flyOn then
        hum.PlatformStand=false
        hum.JumpPower=50
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=true end
        end
        antiGrav(false)
        showJump()
    end
    gui:Destroy()
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if not flyOn or not root or not hum then return end
    for _,p in pairs(char:GetDescendants())do
        if p:IsA("BasePart")then p.CanCollide=false end
    end
    hum.PlatformStand=true
    root.Velocity=Vector3.new(0,0,0)
    root.AssemblyLinearVelocity=Vector3.new(0,0,0)
    local ld=(cam.CFrame.Position-root.Position).Unit
    ld=Vector3.new(ld.X,0,ld.Z).Unit
    if ld.Magnitude>0.01 then
        root.CFrame=CFrame.new(root.Position,root.Position-ld)
    end
    local mv=hum.MoveDirection
    local fw=root.CFrame.LookVector
    local rt=root.CFrame.RightVector
    local up=Vector3.new(0,1,0)
    local v=(rt*mv:Dot(rt)+fw*mv:Dot(fw))*flySpeed*dt
    if upH then
        v=v+up*flySpeed*dt
    elseif downH then
        v=v-up*flySpeed*dt
    end
    if v.Magnitude>0 then
        root.CFrame=root.CFrame+v
    end
end)

plr.CharacterAdded:Connect(function(c)
    char=c
    root=char:WaitForChild("HumanoidRootPart")
    hum=char:WaitForChild("Humanoid")
    flyOn=false
    agForce=nil
    upH=false
    downH=false
    btnFly.Text="🔴 飞行: 关"
    btnFly.BackgroundColor3=Color3.new(0.6,0.1,0.1)
    btnUp.Visible=false
    btnDown.Visible=false
    showJump()
end)
