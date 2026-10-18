--[[
Selector.lua - 目标选择器 (两步确认 + 隐身)
]]
local plr=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local cam=workspace.CurrentCamera

if not getgenv().NDS_Selector then getgenv().NDS_Selector={player=nil, object=nil, mode="player"} end
if plr.PlayerGui:FindFirstChild("SEL_UI")then plr.PlayerGui.SEL_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="SEL_UI" gui.Parent=plr.PlayerGui gui.ResetOnSpawn=false

local crosshair=Instance.new("Frame")
crosshair.Size=UDim2.new(0,80,0,80) crosshair.Position=UDim2.new(0.5,-40,0.5,-40)
crosshair.BackgroundTransparency=1 crosshair.BorderSizePixel=0 crosshair.ZIndex=100
crosshair.Parent=gui crosshair.Visible=false

local function createLine(sx,sy,px,py)
    local l=Instance.new("Frame")
    l.Size=UDim2.new(0,sx,0,sy) l.Position=UDim2.new(0.5,px,0.5,py)
    l.BackgroundColor3=Color3.new(0,1,0) l.BorderSizePixel=0 l.Parent=crosshair
end
createLine(2,12, -1,-22) createLine(2,12, -1,10)
createLine(12,2, -22,-1) createLine(12,2, 10,-1)

local chDot=Instance.new("Frame")
chDot.Size=UDim2.new(0,4,0,4) chDot.Position=UDim2.new(0.5,-2,0.5,-2)
chDot.BackgroundColor3=Color3.new(0,1,0) chDot.BorderSizePixel=0 chDot.Parent=crosshair

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28) miniIcon.Position=UDim2.new(1,-35,0,185)
miniIcon.BackgroundColor3=Color3.new(0.3,0.7,0.4) miniIcon.BorderSizePixel=0
miniIcon.Text="🎯" miniIcon.TextSize=16 miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold miniIcon.Parent=gui miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,170) panel.Position=UDim2.new(1,-150,0,185)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16) panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1 panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25) title.Text="🎯 目标选择" title.TextColor3=Color3.new(0.6,1,0.7)
title.TextSize=12 title.Font=Enum.Font.GothamBold title.BackgroundTransparency=1 title.Parent=panel

local btnMin=Instance.new("TextButton")
btnMin.Size=UDim2.new(0,25,0,25) btnMin.Position=UDim2.new(1,-55,0,0)
btnMin.BackgroundTransparency=1 btnMin.Text="−" btnMin.TextColor3=Color3.new(1,0.8,0.3)
btnMin.TextSize=16 btnMin.Font=Enum.Font.GothamBold btnMin.Parent=panel

local btnClose=Instance.new("TextButton")
btnClose.Size=UDim2.new(0,25,0,25) btnClose.Position=UDim2.new(1,-28,0,0)
btnClose.BackgroundTransparency=1 btnClose.Text="✕" btnClose.TextColor3=Color3.new(1,0.3,0.3)
btnClose.TextSize=14 btnClose.Font=Enum.Font.GothamBold btnClose.Parent=panel

local dragging=false local dragStart=nil local startPos=nil
title.MouseButton1Down:Connect(function() dragging=true dragStart=Vector2.new(title.AbsolutePosition.X,title.AbsolutePosition.Y) startPos=panel.Position end)
UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

local btnMode=Instance.new("TextButton")
btnMode.Size=UDim2.new(0.9,0,0,28) btnMode.Position=UDim2.new(0.05,0,0,28)
btnMode.BackgroundColor3=Color3.new(0.2,0.4,0.8) btnMode.BorderSizePixel=0
btnMode.Text="模式: 选人" btnMode.TextColor3=Color3.new(1,1,1) btnMode.TextSize=11
btnMode.Font=Enum.Font.GothamSemibold btnMode.Parent=panel

local btnStart=Instance.new("TextButton")
btnStart.Size=UDim2.new(0.9,0,0,28) btnStart.Position=UDim2.new(0.05,0,0,60)
btnStart.BackgroundColor3=Color3.new(0.1,0.6,0.2) btnStart.BorderSizePixel=0
btnStart.Text="开始扫描" btnStart.TextColor3=Color3.new(1,1,1) btnStart.TextSize=11
btnStart.Font=Enum.Font.GothamSemibold btnStart.Parent=panel

local btnConfirm=Instance.new("TextButton")
btnConfirm.Size=UDim2.new(0.9,0,0,28) btnConfirm.Position=UDim2.new(0.05,0,0,92)
btnConfirm.BackgroundColor3=Color3.new(0.1,0.4,0.7) btnConfirm.BorderSizePixel=0
btnConfirm.Text="✅ 锁定目标" btnConfirm.TextColor3=Color3.new(1,1,1) btnConfirm.TextSize=11
btnConfirm.Font=Enum.Font.GothamSemibold btnConfirm.Parent=panel btnConfirm.Active=false

local btnTrans=Instance.new("TextButton")
btnTrans.Size=UDim2.new(0.9,0,0,24) btnTrans.Position=UDim2.new(0.05,0,0,126)
btnTrans.BackgroundColor3=Color3.new(0.4,0.2,0.5) btnTrans.BorderSizePixel=0
btnTrans.Text="👻 选后隐身: 开" btnTrans.TextColor3=Color3.new(1,1,1) btnTrans.TextSize=11
btnTrans.Font=Enum.Font.GothamSemibold btnTrans.Parent=panel

local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(1,0,0,18) infoLabel.Position=UDim2.new(0,0,0,152)
infoLabel.Text="当前: 无" infoLabel.TextColor3=Color3.new(0.8,0.9,1)
infoLabel.TextSize=10 infoLabel.BackgroundTransparency=1 infoLabel.Parent=panel
if not getgenv().NDS_UI then getgenv().NDS_UI={panels={},register=function(name,hideFn,showFn) getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn} end,showOnly=function(name) for n,p in pairs(getgenv().NDS_UI.panels)do if n==name then p.show()else p.hide()end end end} end
getgenv().NDS_UI.register("Selector",function() panel.Visible=false miniIcon.Visible=true end,function() panel.Visible=true miniIcon.Visible=false end)
btnMin.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Selector") end)
miniIcon.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Selector") end)

local selectMode="player" local scanning=false local scanConn=nil
local pickHL=nil local hoverTgt=nil local lockedTgt=nil

local autoInv=true local isInv=false local invConn=nil local savedTrans={}

local function clearHL() if pickHL then pickHL:Destroy() pickHL=nil end end

local function setTrans(alpha)
    if not plr.Character then return end
    for _,p in pairs(plr.Character:GetDescendants())do
        if p:IsA("BasePart") then
            if alpha then
                if not savedTrans[p] then savedTrans[p]=p.Transparency end
                p.LocalTransparencyModifier=alpha
            else
                if savedTrans[p] then p.LocalTransparencyModifier=savedTrans[p] savedTrans[p]=nil end
            end
        elseif p:IsA("Decal") or p:IsA("Texture") then
            if alpha then
                if not savedTrans[p] then savedTrans[p]=p.Transparency end
                p.Transparency=alpha
            else
                if savedTrans[p] then p.Transparency=savedTrans[p] savedTrans[p]=nil end
            end
        end
    end
end

local function toggleInv(on)
    isInv=on
    if isInv then
        setTrans(0.6)
        if not invConn then invConn=RS.Heartbeat:Connect(function() if isInv then setTrans(0.6) end end) end
    else
        if invConn then invConn:Disconnect() invConn=nil end
        setTrans(nil)
    end
end

local function getPlayerAtCenter()
    local vs=cam.ViewportSize local screenCenter=Vector2.new(vs.X/2,vs.Y/2)
    local closest=nil local minDist=40 
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
            local pos,onScreen=cam:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist=(Vector2.new(pos.X,pos.Y)-screenCenter).Magnitude
                if dist<minDist then minDist=dist closest=p end
            end
        end
    end
    return closest
end

local function getObjectAtCenter()
    local vs=cam.ViewportSize local ray=cam:ViewportPointToRay(vs.X/2,vs.Y/2)
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={plr.Character or {}}
    local r=workspace:Raycast(ray.Origin,ray.Direction*2000,rp)
    if r then return r.Instance end return nil
end

local function startScan()
    if scanning then return end
    scanning=true btnStart.Text="扫描中..." btnStart.BackgroundColor3=Color3.new(0.8,0.5,0.1)
    crosshair.Visible=true btnConfirm.Active=true btnConfirm.Text="✅ 锁定目标"
    scanConn=RS.RenderStepped:Connect(function()
        local tgt = (selectMode=="player") and getPlayerAtCenter() or getObjectAtCenter()
        if tgt~=hoverTgt then
            clearHL() hoverTgt=tgt
            if tgt then
                pickHL=Instance.new("Highlight")
                pickHL.Adornee=(selectMode=="player") and tgt.Character or tgt
                pickHL.FillColor=Color3.new(0,1,0) pickHL.OutlineColor=Color3.new(0,1,0)
                pickHL.FillTransparency=0.7 pickHL.OutlineTransparency=0.2
                pickHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                pickHL.Parent=(selectMode=="player") and tgt.Character or tgt
                infoLabel.Text="锁定中: "..tgt.Name
            else
                infoLabel.Text="未扫到目标"
            end
        end
    end)
end

local function stopScan()
    if scanConn then scanConn:Disconnect() scanConn=nil end
    scanning=false btnStart.Text="开始扫描" btnStart.BackgroundColor3=Color3.new(0.1,0.6,0.2)
    crosshair.Visible=false btnConfirm.Active=false btnConfirm.Text="✅ 锁定目标" clearHL() hoverTgt=nil
end

btnConfirm.MouseButton1Click:Connect(function()
    if not scanning and not lockedTgt then return end
    if scanning then
        if hoverTgt then
            lockedTgt=hoverTgt
            btnConfirm.Text="⚠️ 确认生效" btnConfirm.BackgroundColor3=Color3.new(0.8,0.1,0.1)
            infoLabel.Text="已锁定: "..lockedTgt.Name.."，再点确认"
            stopScan()
            pickHL=Instance.new("Highlight")
            pickHL.Adornee=(selectMode=="player") and lockedTgt.Character or lockedTgt
            pickHL.FillColor=Color3.new(1,0.8,0) pickHL.OutlineColor=Color3.new(1,0.8,0)
            pickHL.FillTransparency=0.5 pickHL.OutlineTransparency=0.2
            pickHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            pickHL.Parent=(selectMode=="player") and lockedTgt.Character or lockedTgt
        end
    else
        if lockedTgt then
            if selectMode=="player" then getgenv().NDS_Selector.player=lockedTgt infoLabel.Text="已生效玩家: "..lockedTgt.Name
            else getgenv().NDS_Selector.object=lockedTgt infoLabel.Text="已生效物件: "..lockedTgt.Name end
            if autoInv then toggleInv(true) end
            clearHL() lockedTgt=nil
            btnConfirm.Text="✅ 锁定目标" btnConfirm.BackgroundColor3=Color3.new(0.1,0.4,0.7)
        end
    end
end)

btnStart.MouseButton1Click:Connect(function() 
    if scanning then stopScan() else 
        lockedTgt=nil clearHL() 
        startScan() 
    end 
end)

btnTrans.MouseButton1Click:Connect(function()
    autoInv=not autoInv
    if autoInv then btnTrans.Text="👻 选后隐身: 开" btnTrans.BackgroundColor3=Color3.new(0.4,0.2,0.5)
    else btnTrans.Text="👻 选后隐身: 关" btnTrans.BackgroundColor3=Color3.new(0.3,0.3,0.3) 
         if isInv then toggleInv(false) end
    end
end)

btnMode.MouseButton1Click:Connect(function()
    if selectMode=="player" then selectMode="object" btnMode.Text="模式: 选物" btnMode.BackgroundColor3=Color3.new(0.6,0.3,0.1)
    else selectMode="player" btnMode.Text="模式: 选人" btnMode.BackgroundColor3=Color3.new(0.2,0.4,0.8) end
    getgenv().NDS_Selector.mode=selectMode 
    lockedTgt=nil clearHL() stopScan()
end)

btnClose.MouseButton1Click:Connect(function() 
    stopScan() toggleInv(false) gui:Destroy() 
end)

plr.CharacterAdded:Connect(function(c)
    savedTrans={}
    if isInv then task.wait(1) setTrans(0.6) end
end)
-- Selector.lua 结束
