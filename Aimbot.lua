local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid")
local cam=workspace.CurrentCamera
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

if plr.PlayerGui:FindFirstChild("AIM_UI")then plr.PlayerGui.AIM_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="AIM_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28)
miniIcon.Position=UDim2.new(1,-35,0,150)
miniIcon.BackgroundColor3=Color3.new(0.8,0.3,0.1)
miniIcon.BackgroundTransparency=0.2
miniIcon.BorderSizePixel=0
miniIcon.Text="🎯"
miniIcon.TextSize=16
miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold
miniIcon.Parent=gui
miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,160)
panel.Position=UDim2.new(1,-150,0,150)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="🎯 自瞄"
title.TextColor3=Color3.new(1,0.6,0.3)
title.TextSize=12
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

local btnMinimize=Instance.new("TextButton")
btnMinimize.Size=UDim2.new(0,25,0,25)
btnMinimize.Position=UDim2.new(1,-55,0,0)
btnMinimize.BackgroundTransparency=1
btnMinimize.Text="−"
btnMinimize.TextColor3=Color3.new(1,0.8,0.3)
btnMinimize.TextSize=16
btnMinimize.Font=Enum.Font.GothamBold
btnMinimize.Parent=panel

local btnClose=Instance.new("TextButton")
btnClose.Size=UDim2.new(0,25,0,25)
btnClose.Position=UDim2.new(1,-28,0,0)
btnClose.BackgroundTransparency=1
btnClose.Text="✕"
btnClose.TextColor3=Color3.new(1,0.3,0.3)
btnClose.TextSize=14
btnClose.Font=Enum.Font.GothamBold
btnClose.Parent=panel

local btnAim=Instance.new("TextButton")
btnAim.Size=UDim2.new(0.9,0,0,28)
btnAim.Position=UDim2.new(0.05,0,0,28)
btnAim.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnAim.BackgroundTransparency=0.3
btnAim.BorderSizePixel=0
btnAim.Text="🔴 自瞄: 关"
btnAim.TextColor3=Color3.new(1,1,1)
btnAim.TextSize=11
btnAim.Font=Enum.Font.GothamSemibold
btnAim.Parent=panel

local btnStrength=Instance.new("TextButton")
btnStrength.Size=UDim2.new(0.9,0,0,24)
btnStrength.Position=UDim2.new(0.05,0,0,60)
btnStrength.BackgroundColor3=Color3.new(0.3,0.3,0.6)
btnStrength.BackgroundTransparency=0.3
btnStrength.BorderSizePixel=0
btnStrength.Text="💪 强度: 中"
btnStrength.TextColor3=Color3.new(1,1,1)
btnStrength.TextSize=11
btnStrength.Font=Enum.Font.GothamSemibold
btnStrength.Parent=panel

local btnTeam=Instance.new("TextButton")
btnTeam.Size=UDim2.new(0.9,0,0,24)
btnTeam.Position=UDim2.new(0.05,0,0,88)
btnTeam.BackgroundColor3=Color3.new(0.4,0.2,0.4)
btnTeam.BackgroundTransparency=0.3
btnTeam.BorderSizePixel=0
btnTeam.Text="阵营: 敌人"
btnTeam.TextColor3=Color3.new(1,1,1)
btnTeam.TextSize=11
btnTeam.Font=Enum.Font.GothamSemibold
btnTeam.Parent=panel

local fovLabel=Instance.new("TextLabel")
fovLabel.Size=UDim2.new(1,0,0,18)
fovLabel.Position=UDim2.new(0,0,0,116)
fovLabel.Text="范围: 200"
fovLabel.TextColor3=Color3.new(0.8,0.9,1)
fovLabel.TextSize=11
fovLabel.BackgroundTransparency=1
fovLabel.Parent=panel

local btnFovMinus=Instance.new("TextButton")
btnFovMinus.Size=UDim2.new(0,25,0,20)
btnFovMinus.Position=UDim2.new(0.5,-32,0,136)
btnFovMinus.Text="−"
btnFovMinus.TextColor3=Color3.new(1,1,1)
btnFovMinus.TextSize=14
btnFovMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnFovMinus.BorderSizePixel=0
btnFovMinus.Parent=panel

local btnFovPlus=Instance.new("TextButton")
btnFovPlus.Size=UDim2.new(0,25,0,20)
btnFovPlus.Position=UDim2.new(0.5,7,0,136)
btnFovPlus.Text="+"
btnFovPlus.TextColor3=Color3.new(1,1,1)
btnFovPlus.TextSize=14
btnFovPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
btnFovPlus.BorderSizePixel=0
btnFovPlus.Parent=panel

btnMinimize.MouseButton1Click:Connect(function()
    panel.Visible=false
    miniIcon.Visible=true
end)

local fovCircle=Instance.new("Frame")
fovCircle.Size=UDim2.new(0,400,0,400)
fovCircle.Position=UDim2.new(0.5,-200,0.5,-200)
fovCircle.BackgroundTransparency=1
fovCircle.BorderSizePixel=2
fovCircle.BorderColor3=Color3.new(1,0.3,0.1)
fovCircle.Parent=gui
fovCircle.Visible=false
fovCircle.ZIndex=1

local uc=Instance.new("UICorner")
uc.CornerRadius=UDim.new(1,0)
uc.Parent=fovCircle

local aimOn=false
local aimStrength="medium"
local aimTeam="enemy"
local aimFOV=200
local currentTarget=nil

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
local function isEnemy(p)
    if not plr.Team or not p.Team then return true end
    return plr.Team~=p.Team
end

local function canAim(p)
    if p==plr or not p.Character then return false end
    if aimTeam=="enemy" then return isEnemy(p)
    elseif aimTeam=="ally" then return not isEnemy(p)
    elseif aimTeam=="all" then return true
    end
    return false
end

local function getAimStrength()
    if aimStrength=="low" then return 0.15
    elseif aimStrength=="medium" then return 0.35
    elseif aimStrength=="high" then return 0.6
    else return 0.85 end
end

local function getBestAimPart(p)
    if not p or not p.Character then return nil end
    for _,n in pairs({"Head","UpperTorso","HumanoidRootPart","Torso"})do
        local part=p.Character:FindFirstChild(n)
        if part then return part end
    end
    return p.Character:FindFirstChild("Head")
end

local function getBestTarget()
    local best=nil
    local bestDist=aimFOV
    local screenCenter=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    for _,p in pairs(game.Players:GetPlayers())do
        if canAim(p)then
            local part=getBestAimPart(p)
            if part then
                local pos,onScreen=cam:WorldToScreenPoint(part.Position)
                if onScreen then
                    local d=(Vector2.new(pos.X,pos.Y)-screenCenter).Magnitude
                    if d<bestDist then
                        bestDist=d
                        best=p
                    end
                end
            end
        end
    end
    return best
end

local function updateFovCircle()
    local size=aimFOV*2
    fovCircle.Size=UDim2.new(0,size,0,size)
    fovCircle.Position=UDim2.new(0.5,-aimFOV,0.5,-aimFOV)
end

updateFovCircle()

btnAim.MouseButton1Click:Connect(function()
    aimOn=not aimOn
    if aimOn then
        btnAim.Text="🟢 自瞄: 开"
        btnAim.BackgroundColor3=Color3.new(0,0.5,0.1)
        fovCircle.Visible=true
    else
        btnAim.Text="🔴 自瞄: 关"
        btnAim.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        fovCircle.Visible=false
        currentTarget=nil
    end
end)

btnStrength.MouseButton1Click:Connect(function()
    if aimStrength=="low" then
        aimStrength="medium"
        btnStrength.Text="💪 强度: 中"
    elseif aimStrength=="medium" then
        aimStrength="high"
        btnStrength.Text="💪 强度: 高"
    elseif aimStrength=="high" then
        aimStrength="extreme"
        btnStrength.Text="💪 强度: 极"
    else
        aimStrength="low"
        btnStrength.Text="💪 强度: 低"
    end
end)

btnTeam.MouseButton1Click:Connect(function()
    if aimTeam=="enemy" then
        aimTeam="ally"
        btnTeam.Text="阵营: 队友"
    elseif aimTeam=="ally" then
        aimTeam="all"
        btnTeam.Text="阵营: 全部"
    else
        aimTeam="enemy"
        btnTeam.Text="阵营: 敌人"
    end
end)

setupHold(btnFovMinus,function()
    aimFOV=math.max(50,aimFOV-20)
    fovLabel.Text="范围: "..aimFOV
    updateFovCircle()
end)

setupHold(btnFovPlus,function()
    aimFOV=math.min(800,aimFOV+20)
    fovLabel.Text="范围: "..aimFOV
    updateFovCircle()
end)

btnClose.MouseButton1Click:Connect(function()
    fovCircle:Destroy()
    gui:Destroy()
end)

RunService.Heartbeat:Connect(function()
    if not aimOn then return end
    if not cam or not char or not char.Parent then return end
    local target=getBestTarget()
    if target then
        local part=getBestAimPart(target)
        if part then
            local strength=getAimStrength()
            local targetDir=(part.Position-cam.CFrame.Position).Unit
            local newDir=cam.CFrame.LookVector:Lerp(targetDir,strength)
            cam.CFrame=CFrame.new(cam.CFrame.Position,cam.CFrame.Position+newDir)
        end
    end
end)

plr.CharacterAdded:Connect(function(c)
    char=c
    hum=c:WaitForChild("Humanoid")
    currentTarget=nil
end)

if not getgenv().NDS_UI then
    getgenv().NDS_UI={
        panels={},
        register=function(name,hideFn,showFn)
            getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn}
        end,
        showOnly=function(name)
            for n,p in pairs(getgenv().NDS_UI.panels)do
                if n==name then p.show()else p.hide()end
            end
        end
    }
end

getgenv().NDS_UI.register("Aimbot",function()
    panel.Visible=false
    miniIcon.Visible=true
end,function()
    panel.Visible=true
    miniIcon.Visible=false
end)

miniIcon.MouseButton1Click:Connect(function()
    getgenv().NDS_UI.showOnly("Aimbot")
end)
