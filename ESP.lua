local plr=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")

if plr.PlayerGui:FindFirstChild("ESP_UI")then plr.PlayerGui.ESP_UI:Destroy()end

local gui=Instance.new("ScreenGui")
gui.Name="ESP_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28)
miniIcon.Position=UDim2.new(1,-35,0,70)
miniIcon.BackgroundColor3=Color3.new(0.5,0.2,0.6)
miniIcon.BackgroundTransparency=0.2
miniIcon.BorderSizePixel=0
miniIcon.Text="👁"
miniIcon.TextSize=16
miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold
miniIcon.Parent=gui
miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,140,0,90)
panel.Position=UDim2.new(1,-150,0.5,190)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16)
panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1
panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25)
title.Text="👁 透视"
title.TextColor3=Color3.new(0.8,0.6,1)
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

local btnESP=Instance.new("TextButton")
btnESP.Size=UDim2.new(0.9,0,0,30)
btnESP.Position=UDim2.new(0.05,0,0,28)
btnESP.BackgroundColor3=Color3.new(0.6,0.1,0.1)
btnESP.BackgroundTransparency=0.3
btnESP.BorderSizePixel=0
btnESP.Text="🔴 透视: 关"
btnESP.TextColor3=Color3.new(1,1,1)
btnESP.TextSize=12
btnESP.Font=Enum.Font.GothamSemibold
btnESP.Parent=panel

local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(1,0,0,18)
infoLabel.Position=UDim2.new(0,0,0,62)
infoLabel.Text="玩家: 0"
infoLabel.TextColor3=Color3.new(0.8,0.9,1)
infoLabel.TextSize=11
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

-- 彩虹颜色表
local rainbow={
    Color3.fromRGB(255,80,80),
    Color3.fromRGB(255,160,60),
    Color3.fromRGB(255,230,60),
    Color3.fromRGB(120,255,80),
    Color3.fromRGB(80,220,255),
    Color3.fromRGB(120,120,255),
    Color3.fromRGB(220,80,255),
}
local teamColorCache={}

local function getTeamColor(p)
    if not p.Team then return Color3.fromRGB(200,200,200)end
    if teamColorCache[p.Team]then return teamColorCache[p.Team]end
    -- 按阵营数量依次分配彩虹色
    local teams=game:GetService("Teams"):GetTeams()
    local idx=1
    for i,t in ipairs(teams)do
        if t==p.Team then idx=i break end
    end
    local col=rainbow[(idx-1)%#rainbow+1]
    teamColorCache[p.Team]=col
    return col
end

local function hasGameHealthBar(p)
    -- 检查角色头顶有没有游戏自带的血条
    if not p.Character then return false end
    for _,child in pairs(p.Character:GetChildren())do
        if child:IsA("BillboardGui")or child:IsA("ScreenGui")then
            local n=child.Name:lower()
            if n:find("health")or n:find("hp")or n:find("bar")then
                return true
            end
        end
    end
    return false
end

local espOn=false
local espObjects={}

local function mkESP(p)
    if p==plr or not p.Character then return end
    if espObjects[p]then return end
    local h=p.Character:FindFirstChild("Humanoid")
    if not h then return end
    
    local col=getTeamColor(p)
    
    local hl=Instance.new("Highlight")
    hl.Adornee=p.Character
    hl.FillColor=col
    hl.FillTransparency=0.7
    hl.OutlineColor=col
    hl.OutlineTransparency=0.2
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent=p.Character
    
    -- 血条（游戏自带才不画）
    local bg=nil
    if not hasGameHealthBar(p)then
        bg=Instance.new("BillboardGui")
        bg.Size=UDim2.new(0,60,0,6)
        bg.StudsOffset=Vector3.new(0,2.4,0)
        bg.MaxDistance=300
        bg.AlwaysOnTop=true
        bg.Parent=p.Character
        
        local bgFrame=Instance.new("Frame")
        bgFrame.Size=UDim2.new(1,0,1,0)
        bgFrame.BackgroundColor3=Color3.fromRGB(30,30,30)
        bgFrame.BorderSizePixel=0
        bgFrame.Parent=bg
        
        local bar=Instance.new("Frame")
        bar.Size=UDim2.new(1,0,1,0)
        bar.BackgroundColor3=Color3.fromRGB(0,200,0)
        bar.BorderSizePixel=0
        bar.Parent=bgFrame
        
        local txt=Instance.new("TextLabel")
        txt.Size=UDim2.new(1,0,1,0)
        txt.BackgroundTransparency=1
        txt.TextColor3=Color3.new(1,1,1)
        txt.TextScaled=true
        txt.Font=Enum.Font.GothamBold
        txt.Parent=bgFrame
        
        bg.Enabled=true
        
        local function upd()
            if not p.Character then return end
            local hh=p.Character:FindFirstChild("Humanoid")
            if not hh then return end
            local pct=math.clamp(hh.Health/hh.MaxHealth,0,1)
            bar.Size=UDim2.new(pct,0,1,0)
            if pct>0.5 then
                bar.BackgroundColor3=Color3.fromRGB(0,200,0)
            elseif pct>0.2 then
                bar.BackgroundColor3=Color3.fromRGB(255,200,0)
            else
                bar.BackgroundColor3=Color3.fromRGB(255,50,50)
            end
            txt.Text=math.floor(hh.Health).."/"..math.floor(hh.MaxHealth)
        end
        upd()
        h.HealthChanged:Connect(upd)
    end
    
    espObjects[p]={hl=hl,bg=bg}
end

local function rmESP(p)
    if espObjects[p]then
        if espObjects[p].hl then espObjects[p].hl:Destroy()end
        if espObjects[p].bg then espObjects[p].bg:Destroy()end
        espObjects[p]=nil
    end
end

local function clearAll()
    for p,_ in pairs(espObjects)do
        rmESP(p)
    end
end

local function refreshAll()
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr then mkESP(p)end
    end
end

btnESP.MouseButton1Click:Connect(function()
    espOn=not espOn
    if espOn then
        btnESP.Text="🟢 透视: 开"
        btnESP.BackgroundColor3=Color3.new(0,0.5,0.1)
        refreshAll()
    else
        btnESP.Text="🔴 透视: 关"
        btnESP.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        clearAll()
    end
end)

btnClose.MouseButton1Click:Connect(function()
    clearAll()
    gui:Destroy()
end)

-- 新玩家加入（修复）
game.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espOn then mkESP(p)end
    end)
    if p.Character and espOn then
        mkESP(p)
    end
end)

game.Players.PlayerRemoving:Connect(function(p)
    rmESP(p)
end)

-- 定时检查（兜底，防止遗漏）
RunService.Heartbeat:Connect(function()
    if not espOn then return end
    local count=0
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr then
            if p.Character and not espObjects[p]then
                mkESP(p)
            end
            if espObjects[p]then count=count+1 end
        end
    end
    infoLabel.Text="玩家: "..count
end)

plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if espOn then
        clearAll()
        refreshAll()
    end
end)
