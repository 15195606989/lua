local plr=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local cam=workspace.CurrentCamera

if not getgenv().NDS_Selector then
    getgenv().NDS_Selector={
        player=nil,
        object=nil,
        mode="player"
    }
end

if plr.PlayerGui:FindFirstChild("SEL_UI")then plr.PlayerGui.SEL_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="SEL_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28)
miniIcon.Position=UDim2.new(1,-35,0,185)
miniIcon.BackgroundColor3=Color3.new(0.3,0.7,0.4)
miniIcon.BackgroundTransparency=0.2
miniIcon.BorderSizePixel=0
miniIcon.Text="🎯"
miniIcon.TextSize=16
miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold
miniIcon.Parent=gui
miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,110)
panel.Position=UDim2.new(1,-150,0,185)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="🎯 目标选择"
title.TextColor3=Color3.new(0.6,1,0.7)
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

local btnMode=Instance.new("TextButton")
btnMode.Size=UDim2.new(0.9,0,0,28)
btnMode.Position=UDim2.new(0.05,0,0,28)
btnMode.BackgroundColor3=Color3.new(0.2,0.4,0.8)
btnMode.BackgroundTransparency=0.3
btnMode.BorderSizePixel=0
btnMode.Text="模式: 选人"
btnMode.TextColor3=Color3.new(1,1,1)
btnMode.TextSize=11
btnMode.Font=Enum.Font.GothamSemibold
btnMode.Parent=panel

local btnPick=Instance.new("TextButton")
btnPick.Size=UDim2.new(0.9,0,0,28)
btnPick.Position=UDim2.new(0.05,0,0,60)
btnPick.BackgroundColor3=Color3.new(0.1,0.6,0.2)
btnPick.BackgroundTransparency=0.3
btnPick.BorderSizePixel=0
btnPick.Text="开始选择"
btnPick.TextColor3=Color3.new(1,1,1)
btnPick.TextSize=11
btnPick.Font=Enum.Font.GothamSemibold
btnPick.Parent=panel

local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(1,0,0,18)
infoLabel.Position=UDim2.new(0,0,0,92)
infoLabel.Text="当前: 无"
infoLabel.TextColor3=Color3.new(0.8,0.9,1)
infoLabel.TextSize=10
infoLabel.BackgroundTransparency=1
infoLabel.Parent=panel

btnMinimize.MouseButton1Click:Connect(function()
    panel.Visible=false
    miniIcon.Visible=true
end)

miniIcon.MouseButton1Click:Connect(function()
    panel.Visible=true
    miniIcon.Visible=false
end)

local selectMode="player"
local picking=false
local pickConn=nil
local pickHL=nil
local hoverTgt=nil

local function clearHL()
    if pickHL then pickHL:Destroy()pickHL=nil end
    hoverTgt=nil
end

local function getPlayerAtCenter()
    local vs=cam.ViewportSize
    local ray=cam:ViewportPointToRay(vs.X/2,vs.Y/2)
    -- 穿墙：用白名单只检测玩家角色
    local chars={}
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr and p.Character then
            table.insert(chars,p.Character)
        end
    end
    if #chars==0 then return nil end
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Whitelist
    rp.FilterDescendantsInstances=chars
    rp.IgnoreWater=true
    local r=workspace:Raycast(ray.Origin,ray.Direction*2000,rp)
    if r then
        local ch=r.Instance.Parent
        while ch and not ch:IsA("Model")do ch=ch.Parent end
        if ch then
            local p=game.Players:GetPlayerFromCharacter(ch)
            if p then return p end
        end
    end
    return nil
end

local function getObjectAtCenter()
    local vs=cam.ViewportSize
    local ray=cam:ViewportPointToRay(vs.X/2,vs.Y/2)
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={plr.Character or {}}
    rp.IgnoreWater=true
    local r=workspace:Raycast(ray.Origin,ray.Direction*2000,rp)
    if r then return r.Instance end
    return nil
end

local function startPicking()
    if picking then return end
    picking=true
    btnPick.Text="点击屏幕选择"
    btnPick.BackgroundColor3=Color3.new(0.8,0.5,0.1)
    
    pickConn=RunService.Heartbeat:Connect(function()
        local tgt
        if selectMode=="player"then
            tgt=getPlayerAtCenter()
        else
            tgt=getObjectAtCenter()
        end
        if tgt~=hoverTgt then
            clearHL()
            hoverTgt=tgt
            if tgt then
                pickHL=Instance.new("Highlight")
                if selectMode=="player"then
                    pickHL.Adornee=tgt.Character
                else
                    pickHL.Adornee=tgt
                end
                pickHL.FillColor=Color3.new(0,1,0)
                pickHL.OutlineColor=Color3.new(0,1,0)
                pickHL.FillTransparency=0.7
                pickHL.OutlineTransparency=0.2
                pickHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                if selectMode=="player"then
                    pickHL.Parent=tgt.Character
                else
                    pickHL.Parent=tgt
                end
            end
        end
    end)
end

local function stopPicking()
    if pickConn then pickConn:Disconnect()pickConn=nil end
    picking=false
    btnPick.Text="开始选择"
    btnPick.BackgroundColor3=Color3.new(0.1,0.6,0.2)
    clearHL()
end

local function confirmPick()
    if not hoverTgt then return end
    if selectMode=="player"then
        getgenv().NDS_Selector.player=hoverTgt
        infoLabel.Text="玩家: "..hoverTgt.Name
    else
        getgenv().NDS_Selector.object=hoverTgt
        infoLabel.Text="物件: "..hoverTgt.Name
    end
    stopPicking()
end

btnMode.MouseButton1Click:Connect(function()
    if selectMode=="player"then
        selectMode="object"
        btnMode.Text="模式: 选物"
        btnMode.BackgroundColor3=Color3.new(0.6,0.3,0.1)
    else
        selectMode="player"
        btnMode.Text="模式: 选人"
        btnMode.BackgroundColor3=Color3.new(0.2,0.4,0.8)
    end
    getgenv().NDS_Selector.mode=selectMode
end)

btnPick.MouseButton1Click:Connect(function()
    if picking then
        confirmPick()
    else
        startPicking()
    end
end)

btnClose.MouseButton1Click:Connect(function()
    stopPicking()
    gui:Destroy()
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

getgenv().NDS_UI.register("Selector",function()
    panel.Visible=false
    miniIcon.Visible=true
end,function()
    panel.Visible=true
    miniIcon.Visible=false
end)

miniIcon.MouseButton1Click:Connect(function()
    getgenv().NDS_UI.showOnly("Selector")
end)
