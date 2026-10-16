--[[
Vortex.lua - 本地漩涡（带投掷模式）
作用：把周围未固定物体卷向自己或投掷向选中目标。
投掷模式：吸引的物体改为朝 getgenv().NDS_Selector.player 直线飞，同时直接推目标角色。
性能优化：缓存候选部件，每 0.5 秒刷新一次。

【变量表】
plr              LocalPlayer
char             角色模型
root             HumanoidRootPart
RS               RunService
UIS              UserInputService
gui              ScreenGui
btn              开关按钮
panel            功能面板
vortexOn         漩涡是否开启
throwMode        投掷模式：物体飞向选中目标
conn             Heartbeat 连接
affectedParts    被吸部件表
cachedParts      缓存的可吸引部件
lastCache        上次刷新缓存的时间
radius           吸引半径
strength         吸引强度
showHighlight    是否高亮
highlights       高亮实例表
targetPlayer     投掷目标（从 NDS_Selector 读取）

【代码结构】
1. 初始化
2. 创建开关按钮 + 功能面板
3. isInChar() 判断部件是否在自己角色上
4. refreshCache() 刷新候选部件
5. getTarget() 读取选中目标，校验是否有效
6. setHighlight()/clearHighlights() 高亮管理
7. startVortex() 主循环：普通模式绕圈，投掷模式飞向目标
8. stopVortex() 关闭清零
9. 长按按钮 + 投掷开关绑定
10. 角色重生重置

【依赖】
Selector.lua（读取 getgenv().NDS_Selector.player 作为投掷目标）
]]

local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
if plr.PlayerGui:FindFirstChild("VORTEX_UI")then plr.PlayerGui.VORTEX_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="VORTEX_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,100,0,40)
btn.Position=UDim2.new(0,10,0.5,-20)
btn.BackgroundColor3=Color3.new(0.4,0.1,0.6)
btn.BackgroundTransparency=0.2
btn.BorderSizePixel=0
btn.Text="🌀 漩涡: 关"
btn.TextColor3=Color3.new(1,1,1)
btn.TextSize=12
btn.Font=Enum.Font.GothamBold
btn.Parent=gui

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,130,0,190)
panel.Position=UDim2.new(1,-140,0,115)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui
panel.Visible=false

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="🌀 漩涡设置"
title.TextColor3=Color3.new(0.8,0.6,1)
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

local radiusLabel=Instance.new("TextLabel")
radiusLabel.Size=UDim2.new(1,0,0,18)
radiusLabel.Position=UDim2.new(0,0,0,26)
radiusLabel.Text="范围: 50"
radiusLabel.TextColor3=Color3.new(0.8,0.9,1)
radiusLabel.TextSize=10
radiusLabel.BackgroundTransparency=1
radiusLabel.Parent=panel

local btnRMinus=Instance.new("TextButton")
btnRMinus.Size=UDim2.new(0,25,0,20)
btnRMinus.Position=UDim2.new(0.5,-35,0,46)
btnRMinus.Text="−"
btnRMinus.TextColor3=Color3.new(1,1,1)
btnRMinus.TextSize=14
btnRMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnRMinus.BorderSizePixel=0
btnRMinus.Parent=panel

local btnRPlus=Instance.new("TextButton")
btnRPlus.Size=UDim2.new(0,25,0,20)
btnRPlus.Position=UDim2.new(0.5,10,0,46)
btnRPlus.Text="+"
btnRPlus.TextColor3=Color3.new(1,1,1)
btnRPlus.TextSize=14
btnRPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
btnRPlus.BorderSizePixel=0
btnRPlus.Parent=panel

local strengthLabel=Instance.new("TextLabel")
strengthLabel.Size=UDim2.new(1,0,0,18)
strengthLabel.Position=UDim2.new(0,0,0,68)
strengthLabel.Text="强度: 80"
strengthLabel.TextColor3=Color3.new(0.8,0.9,1)
strengthLabel.TextSize=10
strengthLabel.BackgroundTransparency=1
strengthLabel.Parent=panel

local btnSMinus=Instance.new("TextButton")
btnSMinus.Size=UDim2.new(0,25,0,20)
btnSMinus.Position=UDim2.new(0.5,-35,0,88)
btnSMinus.Text="−"
btnSMinus.TextColor3=Color3.new(1,1,1)
btnSMinus.TextSize=14
btnSMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnSMinus.BorderSizePixel=0
btnSMinus.Parent=panel

local btnSPlus=Instance.new("TextButton")
btnSPlus.Size=UDim2.new(0,25,0,20)
btnSPlus.Position=UDim2.new(0.5,10,0,88)
btnSPlus.Text="+"
btnSPlus.TextColor3=Color3.new(1,1,1)
btnSPlus.TextSize=14
btnSPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1)
btnSPlus.BorderSizePixel=0
btnSPlus.Parent=panel

local btnHL=Instance.new("TextButton")
btnHL.Size=UDim2.new(0.9,0,0,24)
btnHL.Position=UDim2.new(0.05,0,0,112)
btnHL.BackgroundColor3=Color3.new(0.3,0.3,0.6)
btnHL.BackgroundTransparency=0.3
btnHL.BorderSizePixel=0
btnHL.Text="高亮: 关"
btnHL.TextColor3=Color3.new(1,1,1)
btnHL.TextSize=10
btnHL.Font=Enum.Font.GothamSemibold
btnHL.Parent=panel

local btnThrow=Instance.new("TextButton")
btnThrow.Size=UDim2.new(0.9,0,0,24)
btnThrow.Position=UDim2.new(0.05,0,0,140)
btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1)
btnThrow.BackgroundTransparency=0.3
btnThrow.BorderSizePixel=0
btnThrow.Text="💥 投掷: 关"
btnThrow.TextColor3=Color3.new(1,1,1)
btnThrow.TextSize=10
btnThrow.Font=Enum.Font.GothamSemibold
btnThrow.Parent=panel

local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(1,0,0,16)
infoLabel.Position=UDim2.new(0,0,0,168)
infoLabel.Text="吸引: 0"
infoLabel.TextColor3=Color3.new(0.7,0.7,0.7)
infoLabel.TextSize=9
infoLabel.BackgroundTransparency=1
infoLabel.Parent=panel

local vortexOn=false
local throwMode=false
local conn=nil
local affectedParts={}
local cachedParts={}
local lastCache=0
local radius=50
local strength=80
local showHighlight=false
local highlights={}
local pushTarget=nil
local pushConn=nil

local function isInChar(part)
    for _,c in pairs(char:GetDescendants())do if c==part then return true end end
    return false
end

local function refreshCache()
    cachedParts={}
    for _,p in pairs(workspace:GetDescendants())do
        if p:IsA("BasePart") and not p.Anchored and p~=root and not isInChar(p) then
            table.insert(cachedParts,p)
        end
    end
end

-- 读取选中目标，校验有效性
local function getTarget()
    local sel=getgenv().NDS_Selector
    if not sel or not sel.player then return nil end
    local p=sel.player
    if not p.Parent or not p.Character then return nil end
    local hrp=p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return p,hrp
end

local function clearHighlights()
    for part,hl in pairs(highlights)do
        if hl then hl:Destroy() end
    end
    highlights={}
end

local function setHighlight(part)
    if highlights[part] then return end
    local hl=Instance.new("Highlight")
    hl.Adornee=part
    hl.FillColor=Color3.new(0.6,0.3,1)
    hl.OutlineColor=Color3.new(0.8,0.5,1)
    hl.FillTransparency=0.85
    hl.OutlineTransparency=0.5
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent=part
    highlights[part]=hl
end

-- 给目标角色持续施加推力（投掷模式下开启）
local function startPush()
    if pushConn then pushConn:Disconnect() end
    pushConn=RS.Heartbeat:Connect(function()
        if not throwMode or not vortexOn then return end
        local p,hrp=getTarget()
        if not hrp then return end
        local dir=(hrp.Position-root.Position)
        local mag=dir.Magnitude
        if mag>0.1 then
            local dirU=dir.Unit
            hrp.AssemblyLinearVelocity=dirU*(strength*2)+Vector3.new(0,strength*0.5,0)
            hrp.AssemblyAngularVelocity=Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10))
        end
    end)
end

local function stopPush()
    if pushConn then pushConn:Disconnect() pushConn=nil end
end

local function startVortex()
    conn=RS.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local now=tick()
        if now-lastCache>0.5 then
            refreshCache()
            lastCache=now
        end
        local center=root.Position
        local count=0
        local tgtP,tgtHRP=nil,nil
        if throwMode then
            tgtP,tgtHRP=getTarget()
        end
        for _,p in pairs(cachedParts)do
            if p and p.Parent then
                local dir=p.Position-center
                local dist=dir.Magnitude
                if dist>2 and dist<radius then
                    if throwMode and tgtHRP then
                        -- 投掷模式：朝目标直线飞
                        local toTgt=(tgtHRP.Position-p.Position)
                        if toTgt.Magnitude>0.1 then
                            p.AssemblyLinearVelocity=toTgt.Unit*(strength*3)+Vector3.new(0,strength*0.3,0)
                        end
                    else
                        -- 普通漩涡：绕圈
                        local horiz=Vector3.new(dir.X,0,dir.Z)
                        if horiz.Magnitude>0.1 then
                            local tangent=Vector3.new(-horiz.Z,0,horiz.X).Unit
                            local toward=(center-p.Position).Unit
                            p.AssemblyLinearVelocity=tangent*strength+toward*(strength*0.25)+Vector3.new(0,strength*0.12,0)
                        end
                    end
                    affectedParts[p]=true
                    if showHighlight then setHighlight(p) end
                    count=count+1
                end
            end
        end
        infoLabel.Text="吸引: "..count
    end)
end

local function stopVortex()
    if conn then conn:Disconnect() conn=nil end
    stopPush()
    for p,_ in pairs(affectedParts)do
        if p and p.Parent then pcall(function()
            p.AssemblyLinearVelocity=Vector3.new(0,0,0)
            p.AssemblyAngularVelocity=Vector3.new(0,0,0)
        end) end
    end
    affectedParts={}
    clearHighlights()
    if root and  root.Parent then pcall(function()
        root.AssemblyLinearVelocity=Vector3.new(0,0,0)
        root.AssemblyAngularVelocity=Vector3.new(0,0,0)
    end) end
    infoLabel.Text="吸引: 0"
end

local function setupHold(b,cb)
    local holding=false
    b.MouseButton1Down:Connect(function()
        holding=true
        cb()
        task.spawn(function()
            task.wait(0.4)
            while holding do task.wait(0.05) if holding then cb() end end
        end)
    end)
    b.MouseButton1Up:Connect(function() holding=false end)
    b.MouseLeave:Connect(function() holding=false end)
end

setupHold(btnRMinus,function()
    radius=math.max(10,radius-5)
    radiusLabel.Text="范围: "..radius
end)

setupHold(btnRPlus,function()
    radius=math.min(300,radius+5)
    radiusLabel.Text="范围: "..radius
end)

setupHold(btnSMinus,function()
    strength=math.max(10,strength-10)
    strengthLabel.Text="强度: "..strength
end)

setupHold(btnSPlus,function()
    strength=math.min(500,strength+10)
    strengthLabel.Text="强度: "..strength
end)

btnHL.MouseButton1Click:Connect(function()
    showHighlight=not showHighlight
    if showHighlight then
        btnHL.Text="高亮: 开"
        btnHL.BackgroundColor3=Color3.new(0.1,0.6,0.3)
    else
        btnHL.Text="高亮: 关"
        btnHL.BackgroundColor3=Color3.new(0.3,0.3,0.6)
        clearHighlights()
    end
end)

btnThrow.MouseButton1Click:Connect(function()
    throwMode=not throwMode
    if throwMode then
        btnThrow.Text="💥 投掷: 开"
        btnThrow.BackgroundColor3=Color3.new(0.1,0.6,0.3)
        if vortexOn then startPush() end
    else
        btnThrow.Text="💥 投掷: 关"
        btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1)
        stopPush()
    end
end)

btn.MouseButton1Click:Connect(function()
    vortexOn=not vortexOn
    if vortexOn then
        btn.Text="🌀 漩涡: 开"
        btn.BackgroundColor3=Color3.new(0,0.5,0.1)
        panel.Visible=true
        refreshCache()
        lastCache=tick()
        startVortex()
        if throwMode then startPush() end
    else
        btn.Text="🌀 漩涡: 关"
        btn.BackgroundColor3=Color3.new(0.4,0.1,0.6)
        stopVortex()
    end
end)

plr.CharacterAdded:Connect(function(c)
    stopVortex()
    char=c
    root=c:WaitForChild("HumanoidRootPart")
    vortexOn=false
    throwMode=false
    btn.Text="🌀 漩涡: 关"
    btn.BackgroundColor3=Color3.new(0.4,0.1,0.6)
    btnThrow.Text="💥 投掷: 关"
    btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1)
end)

-- Vortex.lua 结束 | 共 339 行
