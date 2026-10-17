-- Vortex.lua - 本地漩涡（目标风暴 / 引力保留）
local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
if plr.PlayerGui:FindFirstChild("VORTEX_UI")then plr.PlayerGui.VORTEX_UI:Destroy()end
local gui=Instance.new("ScreenGui")
gui.Name="VORTEX_UI" gui.Parent=plr.PlayerGui gui.ResetOnSpawn=false
local mainBtn=Instance.new("TextButton")
mainBtn.Size=UDim2.new(0,100,0,40) mainBtn.Position=UDim2.new(0,10,0.5,-20)
mainBtn.BackgroundColor3=Color3.new(0.4,0.1,0.6) mainBtn.BackgroundTransparency=0.2
mainBtn.BorderSizePixel=0 mainBtn.Text="🌀 漩涡: 关" mainBtn.TextColor3=Color3.new(1,1,1)
mainBtn.TextSize=12 mainBtn.Font=Enum.Font.GothamBold mainBtn.Parent=gui
local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28) miniIcon.Position=UDim2.new(1,-35,0,115)
miniIcon.BackgroundColor3=Color3.new(0.4,0.1,0.6) miniIcon.BorderSizePixel=0
miniIcon.Text="🌀" miniIcon.TextSize=16 miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold miniIcon.Parent=gui miniIcon.Visible=false
local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,130,0,180) panel.Position=UDim2.new(1,-140,0,115)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16) panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1 panel.Parent=gui
local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25) title.Text="🌀 漩涡设置" title.TextColor3=Color3.new(0.8,0.6,1)
title.TextSize=11 title.Font=Enum.Font.GothamBold title.BackgroundTransparency=1 title.Parent=panel
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
local radiusLabel=Instance.new("TextLabel")
radiusLabel.Size=UDim2.new(1,0,0,16) radiusLabel.Position=UDim2.new(0,0,0,28)
radiusLabel.Text="范围: 50" radiusLabel.TextColor3=Color3.new(0.8,0.9,1)
radiusLabel.TextSize=9 radiusLabel.BackgroundTransparency=1 radiusLabel.Parent=panel
local btnRMinus=Instance.new("TextButton")
btnRMinus.Size=UDim2.new(0,25,0,18) btnRMinus.Position=UDim2.new(0.5,-35,0,46)
btnRMinus.Text="−" btnRMinus.TextColor3=Color3.new(1,1,1) btnRMinus.TextSize=12
btnRMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1) btnRMinus.BorderSizePixel=0 btnRMinus.Parent=panel
local btnRPlus=Instance.new("TextButton")
btnRPlus.Size=UDim2.new(0,25,0,18) btnRPlus.Position=UDim2.new(0.5,10,0,46)
btnRPlus.Text="+" btnRPlus.TextColor3=Color3.new(1,1,1) btnRPlus.TextSize=12
btnRPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1) btnRPlus.BorderSizePixel=0 btnRPlus.Parent=panel
local strengthLabel=Instance.new("TextLabel")
strengthLabel.Size=UDim2.new(1,0,0,16) strengthLabel.Position=UDim2.new(0,0,0,68)
strengthLabel.Text="强度: 80" strengthLabel.TextColor3=Color3.new(0.8,0.9,1)
strengthLabel.TextSize=9 strengthLabel.BackgroundTransparency=1 strengthLabel.Parent=panel
local btnSMinus=Instance.new("TextButton")
btnSMinus.Size=UDim2.new(0,25,0,18) btnSMinus.Position=UDim2.new(0.5,-35,0,86)
btnSMinus.Text="−" btnSMinus.TextColor3=Color3.new(1,1,1) btnSMinus.TextSize=12
btnSMinus.BackgroundColor3=Color3.new(0.6,0.1,0.1) btnSMinus.BorderSizePixel=0 btnSMinus.Parent=panel
local btnSPlus=Instance.new("TextButton")
btnSPlus.Size=UDim2.new(0,25,0,18) btnSPlus.Position=UDim2.new(0.5,10,0,86)
btnSPlus.Text="+" btnSPlus.TextColor3=Color3.new(1,1,1) btnSPlus.TextSize=12
btnSPlus.BackgroundColor3=Color3.new(0.1,0.6,0.1) btnSPlus.BorderSizePixel=0 btnSPlus.Parent=panel
local btnHL=Instance.new("TextButton")
btnHL.Size=UDim2.new(0.9,0,0,22) btnHL.Position=UDim2.new(0.05,0,0,110)
btnHL.BackgroundColor3=Color3.new(0.3,0.3,0.6) btnHL.BorderSizePixel=0
btnHL.Text="高亮: 关" btnHL.TextColor3=Color3.new(1,1,1) btnHL.TextSize=9
btnHL.Font=Enum.Font.GothamSemibold btnHL.Parent=panel
local btnThrow=Instance.new("TextButton")
btnThrow.Size=UDim2.new(0.9,0,0,22) btnThrow.Position=UDim2.new(0.05,0,0,136)
btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1) btnThrow.BorderSizePixel=0
btnThrow.Text="💥 投掷: 关" btnThrow.TextColor3=Color3.new(1,1,1) btnThrow.TextSize=9
btnThrow.Font=Enum.Font.GothamSemibold btnThrow.Parent=panel
local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(1,0,0,14) infoLabel.Position=UDim2.new(0,0,0,160)
infoLabel.Text="吸引: 0" infoLabel.TextColor3=Color3.new(0.7,0.7,0.7)
infoLabel.TextSize=9 infoLabel.BackgroundTransparency=1 infoLabel.Parent=panel
if not getgenv().NDS_UI then getgenv().NDS_UI={panels={},register=function(name,hideFn,showFn) getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn} end,showOnly=function(name) for n,p in pairs(getgenv().NDS_UI.panels)do if n==name then p.show()else p.hide()end end end} end
getgenv().NDS_UI.register("Vortex",function() panel.Visible=false miniIcon.Visible=true end,function() panel.Visible=true miniIcon.Visible=false end)
btnMin.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Vortex") end)
miniIcon.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Vortex") end)
local vortexOn=false local throwMode=false local showHighlight=false
local conn=nil local hlTask=nil local cachedParts={} local affectedParts={}
local lastCache=0 local radius=50 local strength=80 local highlights={}
local targetPlayer=nil local targetHL=nil
local function isInChar(part) for _,c in pairs(char:GetDescendants())do if c==part then return true end end return false end
local function refreshCache()
    cachedParts={}
    for _,p in pairs(workspace:GetDescendants())do if p:IsA("BasePart") and not p.Anchored and p~=root and not isInChar(p) then table.insert(cachedParts,p) end end
end
local function getTarget()
    local sel=getgenv().NDS_Selector
    if not sel or not sel.player then return nil end
    local p=sel.player
    if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return nil end
    return p
end
local function clearHighlights() for part,hl in pairs(highlights)do if hl then hl:Destroy() end end highlights={} end
local function setHighlight(part)
    if highlights[part] then return end
    local hl=Instance.new("Highlight") hl.Adornee=part hl.FillColor=Color3.new(0.6,0.3,1)
    hl.OutlineColor=Color3.new(0.8,0.5,1) hl.FillTransparency=0.85 hl.OutlineTransparency=0.5
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Parent=part highlights[part]=hl
end
local function clearTargetHL() if targetHL then targetHL:Destroy() targetHL=nil end end
local function setTargetHL(p)
    clearTargetHL()
    if not p or not p.Character then return end
    targetHL=Instance.new("Highlight") targetHL.Adornee=p.Character
    targetHL.FillColor=Color3.new(1,0.8,0) targetHL.OutlineColor=Color3.new(1,0.8,0)
    targetHL.FillTransparency=0.7 targetHL.OutlineTransparency=0.2
    targetHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop targetHL.Parent=p.Character
end
local function updateHL()
    if not showHighlight then return end
    clearHighlights() refreshCache()
    local center=root.Position
    for _,p in pairs(cachedParts)do if p and p.Parent and (p.Position-center).Magnitude<radius then setHighlight(p) end end
end
local function toggleHL(on)
    showHighlight=on
    if showHighlight then
        btnHL.Text="高亮: 开" btnHL.BackgroundColor3=Color3.new(0.1,0.6,0.3)
        updateHL() if hlTask then task.cancel(hlTask) end
        hlTask=task.spawn(function() while showHighlight do task.wait(10) if showHighlight then updateHL() end end end)
    else
        btnHL.Text="高亮: 关" btnHL.BackgroundColor3=Color3.new(0.3,0.3,0.6)
        if hlTask then task.cancel(hlTask) hlTask=nil end clearHighlights()
    end
end
local function startVortex()
    conn=RS.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local now=tick()
        if now-lastCache>0.5 then refreshCache() lastCache=now end
        local center=root.Position local count=0 local tgt=nil
        if throwMode then
            tgt=getTarget()
            if tgt and tgt.Character then if targetPlayer~=tgt then targetPlayer=tgt setTargetHL(tgt) end
            else if targetPlayer then clearTargetHL() targetPlayer=nil end end
        else if targetPlayer then clearTargetHL() targetPlayer=nil end end
        for _,p in pairs(cachedParts)do
            if p and p.Parent then
                local dir=p.Position-center local dist=dir.Magnitude
                if dist>2 and dist<radius then
                    if throwMode and tgt and tgt.Character then
                        local hrp=tgt.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local toTgt=hrp.Position-p.Position
                            local tDist=toTgt.Magnitude
                            p.CanCollide=false -- 投掷期间穿墙
                            if tDist>8 then
                                -- 距离远：极强拉力飞过去，弱切向力
                                local pull=toTgt.Unit * strength * 4
                                local horiz=Vector3.new(dir.X,0,dir.Z)
                                local tangent=Vector3.new(-horiz.Z,0,horiz.X).Unit * strength * 0.5
                                p.AssemblyLinearVelocity=pull+tangent+Vector3.new(0,strength*0.5,0)
                            else
                                -- 距离近：绕着目标高速旋转刮人
                                local pDir=p.Position-hrp.Position
                                local tangent=Vector3.new(-pDir.Z,0,pDir.X).Unit * strength * 2.5
                                local pull=(hrp.Position-p.Position).Unit * strength * 0.5
                                p.AssemblyLinearVelocity=tangent+pull+Vector3.new(0,strength*0.2,0)
                            end
                        end
                    else
                        -- 普通模式
                        local horiz=Vector3.new(dir.X,0,dir.Z)
                        local tangent=Vector3.new(-horiz.Z,0,horiz.X).Unit
                        local toward=(center-p.Position).Unit
                        p.CanCollide=true
                        p.AssemblyLinearVelocity=(tangent*strength+toward*(strength*0.25)+Vector3.new(0,strength*0.12,0))
                        affectedParts[p]=true
                    end
                    count=count+1
                end
            end
        end
        infoLabel.Text="吸引: "..count
    end)
end
local function stopVortex()
    if conn then conn:Disconnect() conn=nil end
    clearTargetHL()
    for p,_ in pairs(affectedParts)do if p and p.Parent then pcall(function() p.CanCollide=true p.AssemblyLinearVelocity=Vector3.new(0,0,0) p.AssemblyAngularVelocity=Vector3.new(0,0,0) end) end end
    affectedParts={}
    if root and root.Parent then pcall(function() root.AssemblyLinearVelocity=Vector3.new(0,0,0) root.AssemblyAngularVelocity=Vector3.new(0,0,0) end) end
    infoLabel.Text="吸引: 0"
end
local function setupHold(b,cb)
    local holding=false
    b.MouseButton1Down:Connect(function() holding=true cb() task.spawn(function() task.wait(0.4) while holding do task.wait(0.05) if holding then cb() end end end) end)
    b.MouseButton1Up:Connect(function() holding=false end)
    b.MouseLeave:Connect(function() holding=false end)
end
setupHold(btnRMinus,function() radius=math.max(10,radius-5) radiusLabel.Text="范围: "..radius end)
setupHold(btnRPlus,function() radius=math.min(300,radius+5) radiusLabel.Text="范围: "..radius end)
setupHold(btnSMinus,function() strength=math.max(10,strength-10) strengthLabel.Text="强度: "..strength end)
setupHold(btnSPlus,function() strength=math.min(500,strength+10) strengthLabel.Text="强度: "..strength end)
btnHL.MouseButton1Click:Connect(function() toggleHL(not showHighlight) end)
btnThrow.MouseButton1Click:Connect(function()
    throwMode=not throwMode
    if throwMode then btnThrow.Text="💥 投掷: 开" btnThrow.BackgroundColor3=Color3.new(0.1,0.6,0.3)
    else btnThrow.Text="💥 投掷: 关" btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1) end
end)
mainBtn.MouseButton1Click:Connect(function()
    vortexOn=not vortexOn
    if vortexOn then
        mainBtn.Text="🌀 漩涡: 开" mainBtn.BackgroundColor3=Color3.new(0,0.5,0.1)
        refreshCache() lastCache=tick() startVortex()
    else
        mainBtn.Text="🌀 漩涡: 关" mainBtn.BackgroundColor3=Color3.new(0.4,0.1,0.6) stopVortex()
    end
end)
btnClose.MouseButton1Click:Connect(function()
    if conn then conn:Disconnect() end
    if hlTask then task.cancel(hlTask) end
    clearHighlights() clearTargetHL() gui:Destroy()
end)
plr.CharacterAdded:Connect(function(c)
    stopVortex() char=c root=c:WaitForChild("HumanoidRootPart")
    vortexOn=false throwMode=false toggleHL(false)
    mainBtn.Text="🌀 漩涡: 关" mainBtn.BackgroundColor3=Color3.new(0.4,0.1,0.6)
    btnThrow.Text="💥 投掷: 关" btnThrow.BackgroundColor3=Color3.new(0.5,0.1,0.1)
end)
-- Vortex.lua 结束 | 共 256 行
