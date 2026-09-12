local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid")
local UIS=game:GetService("UserInputService")

if plr.PlayerGui:FindFirstChild("SPD_UI")then plr.PlayerGui.SPD_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="SPD_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28)
miniIcon.Position=UDim2.new(1,-35,0,45)
miniIcon.BackgroundColor3=Color3.new(0.8,0.6,0.1)
miniIcon.BackgroundTransparency=0.2
miniIcon.BorderSizePixel=0
miniIcon.Text="🏃"
miniIcon.TextSize=16
miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold
miniIcon.Parent=gui
miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,110)
panel.Position=UDim2.new(1,-150,0,45)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="🏃 疾跑"
title.TextColor3=Color3.new(0.85,0.75,0.3)
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

local btnSpeed=Instance.new("TextButton")
btnSpeed.Size=UDim2.new(0.9,0,0,30)
btnSpeed.Position=UDim2.new(0.05,0,0,28)
btnSpeed.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnSpeed.BackgroundTransparency=0.3
btnSpeed.BorderSizePixel=0
btnSpeed.Text="🔴 疾跑: 关"
btnSpeed.TextColor3=Color3.new(1,1,1)
btnSpeed.TextSize=12
btnSpeed.Font=Enum.Font.GothamSemibold
btnSpeed.Parent=panel

local spdLabel=Instance.new("TextLabel")
spdLabel.Size=UDim2.new(1,0,0,18)
spdLabel.Position=UDim2.new(0,0,0,60)
spdLabel.Text="速度: 50"
spdLabel.TextColor3=Color3.new(0.8,0.9,1)
spdLabel.TextSize=11
spdLabel.BackgroundTransparency=1
spdLabel.Parent=panel

local btnMinus=Instance.new("TextButton")
btnMinus.Size=UDim2.new(0,30,0,20)
btnMinus.Position=UDim2.new(0.5,-40,0,82)
btnMinus.Text="−"
btnMinus.TextColor3=Color3.new(1,1,1)
btnMinus.TextSize=14
btnMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnMinus.BorderSizePixel=0
btnMinus.Parent=panel

local btnPlus=Instance.new("TextButton")
btnPlus.Size=UDim2.new(0,30,0,20)
btnPlus.Position=UDim2.new(0.5,10,0,82)
btnPlus.Text="+"
btnPlus.TextColor3=Color3.new(1,1,1)
btnPlus.TextSize=14
btnPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
btnPlus.BorderSizePixel=0
btnPlus.Parent=panel

btnMinimize.MouseButton1Click:Connect(function()
    panel.Visible=false
    miniIcon.Visible=true
end)

local speedOn=false
local speedVal=50
local originalSpeed=16

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
btnSpeed.MouseButton1Click:Connect(function()
    speedOn=not speedOn
    if speedOn then
        originalSpeed=hum.WalkSpeed
        btnSpeed.Text="🟢 疾跑: 开"
        btnSpeed.BackgroundColor3=Color3.new(0,0.5,0.1)
        hum.WalkSpeed=speedVal
    else
        btnSpeed.Text="🔴 疾跑: 关"
        btnSpeed.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        hum.WalkSpeed=originalSpeed
    end
end)

setupHold(btnMinus,function()
    speedVal=math.max(1,speedVal-5)
    spdLabel.Text="速度: "..speedVal
    if speedOn then hum.WalkSpeed=speedVal end
end)

setupHold(btnPlus,function()
    speedVal=math.min(500,speedVal+5)
    spdLabel.Text="速度: "..speedVal
    if speedOn then hum.WalkSpeed=speedVal end
end)

btnClose.MouseButton1Click:Connect(function()
    if speedOn then
        hum.WalkSpeed=originalSpeed
    end
    gui:Destroy()
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if speedOn and hum and hum.WalkSpeed~=speedVal then
        hum.WalkSpeed=speedVal
    end
end)

plr.CharacterAdded:Connect(function(c)
    char=c
    hum=char:WaitForChild("Humanoid")
    speedOn=false
    btnSpeed.Text="🔴 疾跑: 关"
    btnSpeed.BackgroundColor3=Color3.new(0.6,0.1,0.1)
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

getgenv().NDS_UI.register("Speed",function()
    panel.Visible=false
    miniIcon.Visible=true
end,function()
    panel.Visible=true
    miniIcon.Visible=false
end)

miniIcon.MouseButton1Click:Connect(function()
    getgenv().NDS_UI.showOnly("Speed")
end)
