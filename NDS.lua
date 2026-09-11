local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local hum=char:WaitForChild("Humanoid")
local cam=workspace.CurrentCamera
if plr.PlayerGui:FindFirstChild("NDS_UI")then plr.PlayerGui.NDS_UI:Destroy()end

local S={fly=false,heal=false,spin=false,sprint=true,dash=true,esp=true,aim=false,nocd=false,follow=false,orbit=false}
local flySpeed,sprintSpeed,spinSpeed,dashDist=60,50,300,20
local aimStrength,aimFOV,aimTeam="extreme",100,"enemy"
local aimTeams={}
local espObj={},upHeld,downHeld=false,false
local spinAng,orbitAng=0,0
local spawnPt,target=nil,nil
local targetMode,targetHL,hoverTgt=false,nil,nil
local nocdLoop=nil
local tracked={},varRows={}
local viewport=cam.ViewportSize

local function isEnemy(p)
    return not plr.Team or not p.Team or plr.Team~=p.Team
end

local function canAim(p)
    if p==plr or not p.Character then return false end
    if aimTeam=="enemy" then return isEnemy(p)
    elseif aimTeam=="ally" then return not isEnemy(p)
    elseif aimTeam=="all" then return true
    else
        for _,t in pairs(aimTeams)do
            if p.Team and p.Team.Name==t then return true end
        end
    end
    return false
end

local function scanCD(par)
    if not par then return end
    for _,c in pairs(par:GetChildren())do
        local n=c.Name:lower()
        if n:find("cooldown")or n:find("cd")or n:find("冷却")or n:find("cool")then
            if c:IsA("NumberValue")or c:IsA("IntValue")or c:IsA("FloatValue")then
                c.Value=0
                if c:IsA("NumberValue")then c.MaxValue=0 end
            end
        end
        scanCD(c)
    end
end

local function setNoCD(on)
    S.nocd=on
    if nocdLoop then task.cancel(nocdLoop)nocdLoop=nil end
    if not on then return end
    nocdLoop=task.spawn(function()
        while S.nocd do
            task.wait(0.5)
            scanCD(plr:FindFirstChild("Backpack"))
            scanCD(char)
            scanCD(plr:FindFirstChild("PlayerGui"))
            scanCD(plr:FindFirstChild("PlayerScripts"))
        end
    end)
end

local function addVars()
    local f,seen={},{}
    local function add(id,name,vType,g,s)
        if seen[id]then return end
        seen[id]=true
        local ok,v=pcall(g)
        if ok then
            table.insert(f,{id=id,name=name,value=v,varType=vType,getter=g,setter=s})
        end
    end
    pcall(function()
        for k,v in pairs(_G)do
            if type(k)=="string"then
                local t=type(v)
                if t=="number"or t=="boolean"then
                    add("_G."..k,k,t,function()return _G[k]end,function(x)_G[k]=x end)
                end
            end
        end
    end)
    pcall(function()
        for k,v in pairs(shared)do
            if type(k)=="string"then
                local t=type(v)
                if t=="number"or t=="boolean"then
                    add("shared."..k,"sh."..k,t,function()return shared[k]end,function(x)shared[k]=x end)
                end
            end
        end
    end)
    pcall(function()
        for k,v in pairs(workspace:GetAttributes())do
            local t=type(v)
            if t=="number"or t=="boolean"then
                add("ws:"..k,"ws."..k,t,function()return workspace:GetAttribute(k)end,function(x)workspace:SetAttribute(k,x)end)
            end
        end
    end)
    pcall(function()
        for k,v in pairs(plr:GetAttributes())do
            local t=type(v)
            if t=="number"or t=="boolean"then
                add("plr:"..k,"plr."..k,t,function()return plr:GetAttribute(k)end,function(x)plr:SetAttribute(k,x)end)
            end
        end
    end)
    if char then
        pcall(function()
            for k,v in pairs(char:GetAttributes())do
                local t=type(v)
                if t=="number"or t=="boolean"then
                    add("char:"..k,"char."..k,t,function()return char:GetAttribute(k)end,function(x)char:SetAttribute(k,x)end)
                end
            end
        end)
    end
    local ls=plr:FindFirstChild("leaderstats")
    if ls then
        for _,v in pairs(ls:GetChildren())do
            if v:IsA("IntValue")or v:IsA("NumberValue")then
                add("ls."..v.Name,"ls."..v.Name,"number",function()return v.Value end,function(x)v.Value=x end)
            end
        end
    end
    if hum then
        add("hum.WalkSpeed","WalkSpeed","number",function()return hum.WalkSpeed end,function(x)hum.WalkSpeed=x end)
        add("hum.Health","Health","number",function()return hum.Health end,function(x)hum.Health=x end)
        pcall(function()
            if hum.UseJumpPower then
                add("hum.JumpPower","JumpPower","number",function()return hum.JumpPower end,function(x)hum.JumpPower=x end)
            else
                add("hum.JumpHeight","JumpHeight","number",function()return hum.JumpHeight end,function(x)hum.JumpHeight=x end)
            end
        end)
    end
    return f
end

local gui=Instance.new("ScreenGui")
gui.Name="NDS_UI"
gui.Parent=plr.PlayerGui
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
gui.DisplayOrder=999

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,165,0,math.min(540,viewport.Y-30))
panel.Position=UDim2.new(1,-172,0,10)
panel.BackgroundColor3=Color3.new(.08,.1,.16)
panel.BackgroundTransparency=.1
panel.BorderSizePixel=1
panel.Parent=gui
panel.ZIndex=10

local pScroll=Instance.new("ScrollingFrame")
pScroll.Size=UDim2.new(1,0,1,-35)
pScroll.Position=UDim2.new(0,0,0,30)
pScroll.BackgroundTransparency=1
pScroll.CanvasSize=UDim2.new(0,0,0,440)
pScroll.ScrollBarThickness=3
pScroll.Parent=panel
pScroll.ZIndex=11

local bCont=Instance.new("Frame")
bCont.Size=UDim2.new(.9,0,0,440)
bCont.Position=UDim2.new(.05,0,0,0)
bCont.BackgroundTransparency=1
bCont.Parent=pScroll
bCont.ZIndex=12

local function mkBtn(y,color,text,parent)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,22)
    b.Position=UDim2.new(0,0,0,y)
    b.BackgroundColor3=color
    b.BackgroundTransparency=.35
    b.BorderSizePixel=0
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=11
    b.Font=Enum.Font.GothamSemibold
    b.Parent=parent or bCont
    b.ZIndex=12
    return b
end
local btnFly=mkBtn(0,Color3.new(.6,.1,.1),"🔴 飞行: 关")
local btnHeal=mkBtn(24,Color3.new(.5,.5,.1),"🛡️ 锁血: 关")
local btnSpin=mkBtn(48,Color3.new(.6,.2,.05),"🌀 旋转: 关")
local btnSprint=mkBtn(72,Color3.new(.5,.4,.05),"🏃 疾跑: 开")
local btnDash=mkBtn(96,Color3.new(.5,.2,.6),"💨 冲刺: 开")
local btnESP=mkBtn(120,Color3.new(.15,.15,.5),"👁️ 透视: 开")
local btnAim=mkBtn(144,Color3.new(.6,.3,.1),"🎯 自瞄: 关")
local btnStrength=mkBtn(168,Color3.new(.3,.3,.6),"💪 强度: 极")
local btnNoCD=mkBtn(192,Color3.new(.5,.1,.5),"⚡ 无CD: 关")
local btnFollow=mkBtn(216,Color3.new(.1,.5,.3),"🎯 跟随: 关")
local btnOrbit=mkBtn(240,Color3.new(.5,.1,.4),"🔄 环绕: 关")
local btnTP=mkBtn(264,Color3.new(.4,.05,.4),"⚡ 随机传送")
local btnTPTo=mkBtn(288,Color3.new(.2,.5,.7),"📌 传送至玩家")
local btnSetSpawn=mkBtn(312,Color3.new(.3,.6,.2),"📍 设置传送点")
local btnSafe=mkBtn(336,Color3.new(.05,.4,.5),"🏠 自我传送")
local btnRefresh=mkBtn(360,Color3.new(.1,.4,.2),"🔄 刷新")
local btnSettings=mkBtn(384,Color3.new(.2,.3,.5),"⚙️ 设置")
local btnVars=mkBtn(408,Color3.new(.3,.5,.7),"📝 游戏变量")
local btnTarget=mkBtn(432,Color3.new(.3,.6,.2),"🎯 目标: 无")

local btnClose=mkBtn(0,Color3.new(.6,.1,.1),"✕",panel)
btnClose.Size=UDim2.new(0,28,0,28)
btnClose.Position=UDim2.new(1,-32,0,3)
btnClose.TextSize=16
btnClose.Font=Enum.Font.GothamBold
btnClose.ZIndex=15

local btnReopen=Instance.new("TextButton")
btnReopen.Size=UDim2.new(0,24,0,24)
btnReopen.Position=UDim2.new(1,-30,0,8)
btnReopen.BackgroundColor3=Color3.new(.3,.5,.8)
btnReopen.BackgroundTransparency=.3
btnReopen.BorderSizePixel=0
btnReopen.Text="🌀"
btnReopen.TextColor3=Color3.new(1,1,1)
btnReopen.TextSize=12
btnReopen.Parent=gui
btnReopen.Visible=false
btnReopen.ZIndex=50

btnClose.MouseButton1Click:Connect(function()
    panel.Visible=false
    btnReopen.Visible=true
end)
btnReopen.MouseButton1Click:Connect(function()
    panel.Visible=true
    btnReopen.Visible=false
end)

local function showToast(text,duration)
    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(0,240,0,30)
    t.Position=UDim2.new(.5,-120,.5,-15)
    t.BackgroundColor3=Color3.new(0,0,0)
    t.BackgroundTransparency=.1
    t.BorderSizePixel=1
    t.BorderColor3=Color3.new(.5,.7,1)
    t.Text=text
    t.TextColor3=Color3.new(1,1,1)
    t.TextSize=12
    t.Font=Enum.Font.GothamBold
    t.TextWrapped=true
    t.Parent=gui
    t.ZIndex=400
    task.delay(duration or 2,function()
        if t then t:Destroy()end
    end)
end

local numEdit=Instance.new("Frame")
numEdit.Size=UDim2.new(0,280,0,160)
numEdit.Position=UDim2.new(.5,-140,.5,-80)
numEdit.BackgroundColor3=Color3.new(.1,.15,.25)
numEdit.BorderSizePixel=2
numEdit.BorderColor3=Color3.new(.3,.5,.8)
numEdit.Visible=false
numEdit.Parent=gui
numEdit.ZIndex=300

local numTitle=Instance.new("TextLabel")
numTitle.Size=UDim2.new(1,0,0,22)
numTitle.Text="编辑数值（点击输入框弹键盘）"
numTitle.TextColor3=Color3.new(.6,.85,1)
numTitle.TextSize=11
numTitle.Font=Enum.Font.GothamBold
numTitle.BackgroundTransparency=1
numTitle.Parent=numEdit
numTitle.ZIndex=301

local numBox=Instance.new("TextBox")
numBox.Size=UDim2.new(.9,0,0,32)
numBox.Position=UDim2.new(.05,0,0,26)
numBox.BackgroundColor3=Color3.new(.2,.25,.35)
numBox.BorderSizePixel=2
numBox.BorderColor3=Color3.new(.5,.7,1)
numBox.TextColor3=Color3.new(1,1,0)
numBox.TextSize=16
numBox.Font=Enum.Font.GothamBold
numBox.ClearTextOnFocus=false
numBox.TextEditable=true
numBox.PlaceholderText="输入数值"
numBox.Parent=numEdit
numBox.ZIndex=301

local qCont=Instance.new("Frame")
qCont.Size=UDim2.new(1,0,0,28)
qCont.Position=UDim2.new(0,0,0,62)
qCont.BackgroundTransparency=1
qCont.Parent=numEdit
qCont.ZIndex=301

local quickOps={{"-100",-100},{"-10",-10},{"-1",-1},{"+1",1},{"+10",10},{"+100",100}}
for i,q in pairs(quickOps)do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,42,0,26)
    b.Position=UDim2.new(0,7+(i-1)*45,0,0)
    b.BackgroundColor3=Color3.new(.2,.3,.5)
    b.BorderSizePixel=0
    b.Text=q[1]
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=11
    b.Font=Enum.Font.GothamBold
    b.Parent=qCont
    b.ZIndex=302
    b.MouseButton1Click:Connect(function()
        local cur=tonumber(numBox.Text)or 0
        numBox.Text=tostring(cur+q[2])
    end)
end

local multiOps={{"×2",function(x)return x*2 end},{"÷2",function(x)return x/2 end},{"0",function()return 0 end}}
for i,m in pairs(multiOps)do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,42,0,26)
    b.Position=UDim2.new(0,7+(i-1)*45,0,92)
    b.BackgroundColor3=Color3.new(.4,.3,.5)
    b.BorderSizePixel=0
    b.Text=m[1]
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=11
    b.Font=Enum.Font.GothamBold
    b.Parent=numEdit
    b.ZIndex=302
    b.MouseButton1Click:Connect(function()
        local cur=tonumber(numBox.Text)or 0
        numBox.Text=tostring(m[2](cur))
    end)
end

local numOK=Instance.new("TextButton")
numOK.Size=UDim2.new(0,120,0,28)
numOK.Position=UDim2.new(.5,-125,0,126)
numOK.BackgroundColor3=Color3.new(.1,.6,.1)
numOK.BorderSizePixel=0
numOK.Text="✅ 确定"
numOK.TextColor3=Color3.new(1,1,1)
numOK.TextSize=12
numOK.Font=Enum.Font.GothamBold
numOK.Parent=numEdit
numOK.ZIndex=301

local numCancel=Instance.new("TextButton")
numCancel.Size=UDim2.new(0,120,0,28)
numCancel.Position=UDim2.new(.5,5,0,126)
numCancel.BackgroundColor3=Color3.new(.6,.1,.1)
numCancel.BorderSizePixel=0
numCancel.Text="✕ 取消"
numCancel.TextColor3=Color3.new(1,1,1)
numCancel.TextSize=12
numCancel.Font=Enum.Font.GothamBold
numCancel.Parent=numEdit
numCancel.ZIndex=301

local numCb=nil
local function editNum(cur,cb)
    numBox.Text=tostring(cur)
    numEdit.Visible=true
    numCb=cb
    task.delay(0.1,function()
        pcall(function()numBox:CaptureFocus()end)
    end)
end
numBox.MouseButton1Click:Connect(function()
    pcall(function()numBox:CaptureFocus()end)
end)
numBox.Focused:Connect(function()
    pcall(function()
        numBox.CursorPosition=#numBox.Text+1
        numBox.SelectionStart=1
    end)
end)
local function closeNum()
    numEdit.Visible=false
    if numCb and tonumber(numBox.Text)then
        pcall(numCb,tonumber(numBox.Text))
    end
    numCb=nil
    pcall(function()numBox:ReleaseFocus()end)
end
numOK.MouseButton1Click:Connect(closeNum)
numCancel.MouseButton1Click:Connect(function()
    numEdit.Visible=false
    numCb=nil
    pcall(function()numBox:ReleaseFocus()end)
end)
numBox.FocusLost:Connect(function(ent)
    if ent then closeNum()end
end)
local varEd=Instance.new("Frame")
varEd.Size=UDim2.new(0,280,0,math.min(400,viewport.Y-40))
varEd.Position=UDim2.new(.5,-140,.5,-math.min(200,(viewport.Y-40)/2))
varEd.BackgroundColor3=Color3.new(.05,.07,.12)
varEd.BackgroundTransparency=.05
varEd.BorderSizePixel=1
varEd.BorderColor3=Color3.new(.3,.5,.7)
varEd.Visible=false
varEd.Parent=gui
varEd.ZIndex=100

local varTitle=Instance.new("TextLabel")
varTitle.Size=UDim2.new(1,-60,0,25)
varTitle.Position=UDim2.new(0,5,0,2)
varTitle.Text="📝 变量编辑器"
varTitle.TextColor3=Color3.new(.6,.85,1)
varTitle.TextSize=13
varTitle.Font=Enum.Font.GothamBold
varTitle.TextXAlignment=Enum.TextXAlignment.Left
varTitle.BackgroundTransparency=1
varTitle.Parent=varEd
varTitle.ZIndex=101

local varRef=Instance.new("TextButton")
varRef.Size=UDim2.new(0,24,0,24)
varRef.Position=UDim2.new(1,-56,0,2)
varRef.BackgroundTransparency=1
varRef.Text="🔄"
varRef.TextColor3=Color3.new(1,1,1)
varRef.TextSize=14
varRef.Parent=varEd
varRef.ZIndex=101

local varClose=Instance.new("TextButton")
varClose.Size=UDim2.new(0,24,0,24)
varClose.Position=UDim2.new(1,-28,0,2)
varClose.BackgroundTransparency=1
varClose.Text="✕"
varClose.TextColor3=Color3.new(1,.3,.3)
varClose.TextSize=14
varClose.Font=Enum.Font.GothamBold
varClose.Parent=varEd
varClose.ZIndex=101
varClose.MouseButton1Click:Connect(function()
    varEd.Visible=false
end)

local varSearch=Instance.new("TextBox")
varSearch.Size=UDim2.new(1,-10,0,22)
varSearch.Position=UDim2.new(0,5,0,28)
varSearch.BackgroundColor3=Color3.new(.15,.2,.3)
varSearch.BackgroundTransparency=.3
varSearch.BorderSizePixel=0
varSearch.PlaceholderText="搜索变量..."
varSearch.TextColor3=Color3.new(1,1,1)
varSearch.TextSize=11
varSearch.Font=Enum.Font.Gotham
varSearch.ClearTextOnFocus=false
varSearch.Parent=varEd
varSearch.ZIndex=101

local varScroll=Instance.new("ScrollingFrame")
varScroll.Size=UDim2.new(1,-5,1,-58)
varScroll.Position=UDim2.new(0,0,0,54)
varScroll.BackgroundTransparency=1
varScroll.CanvasSize=UDim2.new(0,0,0,0)
varScroll.ScrollBarThickness=4
varScroll.ScrollBarImageColor3=Color3.new(.3,.5,.7)
varScroll.Parent=varEd
varScroll.ZIndex=101

local function renderVars()
    for _,c in pairs(varScroll:GetChildren())do
        if c:IsA("Frame")then c:Destroy()end
    end
    varRows={}
    local st=varSearch.Text:lower()
    local shown={}
    for _,v in pairs(tracked)do
        if st==""or v.name:lower():find(st)then
            table.insert(shown,v)
        end
    end
    varScroll.CanvasSize=UDim2.new(0,0,0,#shown*32+10)
    for i,v in pairs(shown)do
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-5,0,30)
        row.Position=UDim2.new(0,0,0,(i-1)*32)
        row.BackgroundTransparency=.5
        row.BackgroundColor3=i%2==0 and Color3.new(.1,.15,.2)or Color3.new(.08,.12,.18)
        row.Parent=varScroll
        row.ZIndex=102
        varRows[v.id]=row

        local nameBtn=Instance.new("TextButton")
        nameBtn.Size=UDim2.new(.42,0,1,0)
        nameBtn.Position=UDim2.new(0,3,0,0)
        nameBtn.Text=v.name
        nameBtn.TextColor3=Color3.new(.8,.9,1)
        nameBtn.TextSize=9
        nameBtn.TextXAlignment=Enum.TextXAlignment.Left
        nameBtn.BackgroundTransparency=1
        nameBtn.TextTruncate=Enum.TextTruncate.AtEnd
        nameBtn.Parent=row
        nameBtn.ZIndex=103
        nameBtn.MouseButton1Click:Connect(function()
            showToast(v.name,2)
        end)

        if v.varType=="boolean"then
            local bb=Instance.new("TextButton")
            bb.Size=UDim2.new(0,50,0,22)
            bb.Position=UDim2.new(.44,0,0,4)
            bb.BackgroundColor3=v.value and Color3.new(0,.6,.2)or Color3.new(.5,.1,.1)
            bb.BorderSizePixel=0
            bb.Text=v.value and"TRUE"or"FALSE"
            bb.TextColor3=Color3.new(1,1,1)
            bb.TextSize=11
            bb.Font=Enum.Font.GothamBold
            bb.Parent=row
            bb.ZIndex=103
            bb.MouseButton1Click:Connect(function()
                local ok,cur=pcall(v.getter)
                if ok then
                    pcall(v.setter,not cur)
                    bb.Text=not cur and"TRUE"or"FALSE"
                    bb.BackgroundColor3=not cur and Color3.new(0,.6,.2)or Color3.new(.5,.1,.1)
                end
            end)
        else
            local vb=Instance.new("TextButton")
            vb.Size=UDim2.new(.25,0,0,22)
            vb.Position=UDim2.new(.44,0,0,4)
            vb.BackgroundColor3=Color3.new(.2,.25,.35)
            vb.BackgroundTransparency=.3
            vb.BorderSizePixel=0
            vb.Text=tostring(v.value)
            vb.TextColor3=Color3.new(1,1,0)
            vb.TextSize=10
            vb.Font=Enum.Font.GothamBold
            vb.Parent=row
            vb.ZIndex=103
            vb.MouseButton1Click:Connect(function()
                local ok,cur=pcall(v.getter)
                if ok then
                    editNum(cur,function(n)
                        pcall(v.setter,n)
                        vb.Text=tostring(n)
                    end)
                end
            end)
            local mb=Instance.new("TextButton")
            mb.Size=UDim2.new(0,22,0,22)
            mb.Position=UDim2.new(.70,0,0,4)
            mb.Text="−"
            mb.TextColor3=Color3.new(1,1,1)
            mb.TextSize=14
            mb.BackgroundColor3=Color3.new(.6,.1,.1)
            mb.BackgroundTransparency=.3
            mb.BorderSizePixel=0
            mb.Parent=row
            mb.ZIndex=103
            local pb=Instance.new("TextButton")
            pb.Size=UDim2.new(0,22,0,22)
            pb.Position=UDim2.new(.88,0,0,4)
            pb.Text="+"
            pb.TextColor3=Color3.new(1,1,1)
            pb.TextSize=14
            pb.BackgroundColor3=Color3.new(.1,.6,.1)
            pb.BackgroundTransparency=.3
            pb.BorderSizePixel=0
            pb.Parent=row
            pb.ZIndex=103
            local function adj(d)
                local ok,cur=pcall(v.getter)
                if ok and type(cur)=="number"then
                    local n=cur+d
                    pcall(v.setter,n)
                    vb.Text=tostring(n)
                end
            end
            mb.MouseButton1Click:Connect(function()adj(-1)end)
            pb.MouseButton1Click:Connect(function()adj(1)end)
        end
    end
end

local debounce=nil
varSearch:GetPropertyChangedSignal("Text"):Connect(function()
    if debounce then task.cancel(debounce)end
    debounce=task.delay(0.3,renderVars)
end)
varRef.MouseButton1Click:Connect(function()
    tracked=addVars()
    renderVars()
end)
btnVars.MouseButton1Click:Connect(function()
    varEd.Visible=not varEd.Visible
    if varEd.Visible then
        tracked=addVars()
        renderVars()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if varEd.Visible then
            for _,v in pairs(tracked)do
                local row=varRows[v.id]
                if row and row.Parent then
                    local ok,cur=pcall(v.getter)
                    if ok then
                        if v.varType=="boolean"then
                            for _,c in pairs(row:GetChildren())do
                                if c:IsA("TextButton")and(c.Text=="TRUE"or c.Text=="FALSE")then
                                    local txt=cur and"TRUE"or"FALSE"
                                    if c.Text~=txt then
                                        c.Text=txt
                                        c.BackgroundColor3=cur and Color3.new(0,.6,.2)or Color3.new(.5,.1,.1)
                                    end
                                    break
                                end
                            end
                        else
                            for _,c in pairs(row:GetChildren())do
                                if c:IsA("TextButton")and c.Position.X.Scale>0.4 and c.Position.X.Scale<0.7 then
                                    if c.Text~=tostring(cur)then
                                        c.Text=tostring(cur)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local setF=Instance.new("Frame")
setF.Size=UDim2.new(0,180,0,220)
setF.Position=UDim2.new(0,8,0,50)
setF.BackgroundColor3=Color3.new(.08,.1,.16)
setF.BackgroundTransparency=.1
setF.BorderSizePixel=1
setF.Visible=false
setF.Parent=panel
setF.ZIndex=20

local setT=Instance.new("TextLabel")
setT.Size=UDim2.new(1,0,0,22)
setT.Text="⚙️ 设置"
setT.TextColor3=Color3.new(.6,.85,1)
setT.TextSize=13
setT.Font=Enum.Font.GothamBold
setT.BackgroundTransparency=1
setT.Parent=setF
setT.ZIndex=21

local setClose=Instance.new("TextButton")
setClose.Size=UDim2.new(0,22,0,22)
setClose.Position=UDim2.new(1,-24,0,0)
setClose.BackgroundTransparency=1
setClose.Text="✕"
setClose.TextColor3=Color3.new(1,.3,.3)
setClose.TextSize=14
setClose.Font=Enum.Font.GothamBold
setClose.Parent=setF
setClose.ZIndex=21
setClose.MouseButton1Click:Connect(function()
    setF.Visible=false
end)
local function mkSetting(y,label,step,min,val,onChange)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(.6,0,0,18)
    l.Position=UDim2.new(.05,0,y,0)
    l.Text=label..": "..val
    l.TextColor3=Color3.new(.8,.9,1)
    l.TextSize=11
    l.BackgroundTransparency=1
    l.Parent=setF
    l.ZIndex=21
    local m=Instance.new("TextButton")
    m.Size=UDim2.new(0,22,0,18)
    m.Position=UDim2.new(.7,0,y,0)
    m.BackgroundTransparency=1
    m.Text="−"
    m.TextColor3=Color3.new(1,1,1)
    m.TextSize=16
    m.Parent=setF
    m.ZIndex=21
    local p=Instance.new("TextButton")
    p.Size=UDim2.new(0,22,0,18)
    p.Position=UDim2.new(.85,0,y,0)
    p.BackgroundTransparency=1
    p.Text="+"
    p.TextColor3=Color3.new(1,1,1)
    p.TextSize=16
    p.Parent=setF
    p.ZIndex=21
    local function attach(btn,dir)
        local hold=false
        btn.MouseButton1Down:Connect(function()
            hold=true
            val=math.clamp(val+dir*step,min,999999999)
            onChange(val)
            l.Text=label..": "..val
            task.spawn(function()
                local cnt=0
                while hold do
                    task.wait(.08)
                    val=math.clamp(val+dir*step,min,999999999)
                    onChange(val)
                    l.Text=label..": "..val
                    cnt=cnt+1
                    if cnt%10==0 then
                        val=math.clamp(val+dir*step*4,min,999999999)
                        onChange(val)
                        l.Text=label..": "..val
                    end
                end
            end)
        end)
        btn.MouseButton1Up:Connect(function()hold=false end)
        btn.MouseLeave:Connect(function()hold=false end)
    end
    attach(m,-1)
    attach(p,1)
end

mkSetting(.15,"飞行",5,1,flySpeed,function(v)flySpeed=v end)
mkSetting(.35,"疾跑",5,1,sprintSpeed,function(v)
    sprintSpeed=v
    dashDist=v*0.4
    if S.sprint then hum.WalkSpeed=v end
end)
mkSetting(.55,"旋转",10,1,spinSpeed,function(v)spinSpeed=v end)
mkSetting(.75,"自瞄范围",10,20,aimFOV,function(v)
    aimFOV=v
    fovCircle.Size=UDim2.new(0,v*2,0,v*2)
    fovCircle.Position=UDim2.new(.5,-v,.5,-v)
end)

local teamBtn=Instance.new("TextButton")
teamBtn.Size=UDim2.new(.9,0,0,18)
teamBtn.Position=UDim2.new(.05,0,.95,0)
teamBtn.BackgroundColor3=Color3.new(.3,.3,.6)
teamBtn.BackgroundTransparency=.3
teamBtn.BorderSizePixel=0
teamBtn.Text="自瞄阵营: 敌人"
teamBtn.TextColor3=Color3.new(1,1,1)
teamBtn.TextSize=10
teamBtn.Font=Enum.Font.GothamSemibold
teamBtn.Parent=setF
teamBtn.ZIndex=21

local teamF=Instance.new("Frame")
teamF.Size=UDim2.new(0,180,0,200)
teamF.Position=UDim2.new(.5,-90,.5,-100)
teamF.BackgroundColor3=Color3.new(.05,.07,.12)
teamF.BackgroundTransparency=.05
teamF.BorderSizePixel=1
teamF.Visible=false
teamF.Parent=gui
teamF.ZIndex=100

local teamTitle=Instance.new("TextLabel")
teamTitle.Size=UDim2.new(1,0,0,20)
teamTitle.Text="选择自瞄阵营"
teamTitle.TextColor3=Color3.new(.6,.85,1)
teamTitle.TextSize=11
teamTitle.Font=Enum.Font.GothamBold
teamTitle.BackgroundTransparency=1
teamTitle.Parent=teamF
teamTitle.ZIndex=101

local teamScroll=Instance.new("ScrollingFrame")
teamScroll.Size=UDim2.new(1,0,1,-25)
teamScroll.Position=UDim2.new(0,0,0,20)
teamScroll.BackgroundTransparency=1
teamScroll.ScrollBarThickness=3
teamScroll.Parent=teamF
teamScroll.ZIndex=101

local function upTeamBtn()
    if aimTeam=="enemy"then
        teamBtn.Text="自瞄阵营: 敌人"
    elseif aimTeam=="ally"then
        teamBtn.Text="自瞄阵营: 队友"
    elseif aimTeam=="all"then
        teamBtn.Text="自瞄阵营: 全部"
    else
        teamBtn.Text="自瞄阵营: "..(#aimTeams==0 and"自定义(空)"or(#aimTeams==1 and aimTeams[1]or#aimTeams.."个"))
    end
end

local function renderTeams()
    for _,c in pairs(teamScroll:GetChildren())do
        if c:IsA("TextButton")or c:IsA("TextLabel")then c:Destroy()end
    end
    local teams={}
    pcall(function()
        for _,t in pairs(game:GetService("Teams"):GetTeams())do
            table.insert(teams,t.Name)
        end
    end)
    table.insert(teams,"无队伍")
    teamScroll.CanvasSize=UDim2.new(0,0,0,#teams*24+100)
    local qo={{"全部敌人","enemy","🔴"},{"全部队友","ally","🟢"},{"所有人","all","⚪"}}
    for i,o in pairs(qo)do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(.9,0,0,22)
        b.Position=UDim2.new(.05,0,0,(i-1)*24)
        b.BackgroundColor3=Color3.new(.2,.3,.5)
        b.BackgroundTransparency=.3
        b.BorderSizePixel=0
        b.Text=o[3].." "..o[1]
        b.TextColor3=Color3.new(1,1,1)
        b.TextSize=11
        b.Font=Enum.Font.GothamSemibold
        b.Parent=teamScroll
        b.ZIndex=102
        b.MouseButton1Click:Connect(function()
            aimTeam=o[2]
            aimTeams={}
            upTeamBtn()
            teamF.Visible=false
        end)
    end
    for i,t in pairs(teams)do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(.9,0,0,22)
        b.Position=UDim2.new(.05,0,0,75+i*24)
        b.BackgroundColor3=Color3.new(.3,.3,.5)
        b.BackgroundTransparency=.3
        b.BorderSizePixel=0
        b.Text=t
        b.TextColor3=Color3.new(1,1,1)
        b.TextSize=11
        b.Font=Enum.Font.GothamSemibold
        b.Parent=teamScroll
        b.ZIndex=102
        local sel=false
        for _,x in pairs(aimTeams)do
            if x==t then sel=true break end
        end
        if sel then
            b.BackgroundColor3=Color3.new(0,.6,.2)
            b.Text="✓ "..t
        end
        b.MouseButton1Click:Connect(function()
            aimTeam="custom"
            local found=false
            for j,x in pairs(aimTeams)do
                if x==t then
                    table.remove(aimTeams,j)
                    found=true
                    break
                end
            end
            if not found then
                table.insert(aimTeams,t)
            end
            renderTeams()
            upTeamBtn()
        end)
    end
end

teamBtn.MouseButton1Click:Connect(function()
    teamF.Visible=not teamF.Visible
    if teamF.Visible then renderTeams()end
end)
upTeamBtn()

local function mkCircleBtn(text,color,pos)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,60,0,60)
    b.Position=pos
    b.BackgroundColor3=color
    b.BackgroundTransparency=.3
    b.BorderSizePixel=0
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.TextSize=24
    b.Font=Enum.Font.GothamBold
    b.Parent=gui
    b.ZIndex=40
    return b
end

local btnUp=mkCircleBtn("⬆",Color3.new(.1,.5,.2),UDim2.new(1,-140,.65,0))
local btnDown=mkCircleBtn("⬇",Color3.new(.5,.1,.1),UDim2.new(1,-70,.65,0))
btnUp.Visible=false
btnDown.Visible=false

btnUp.MouseButton1Down:Connect(function()
    if S.fly then upHeld=true end
end)
btnUp.MouseButton1Up:Connect(function()upHeld=false end)
btnDown.MouseButton1Down:Connect(function()
    if S.fly then downHeld=true end
end)
btnDown.MouseButton1Up:Connect(function()downHeld=false end)

local btnDashAct=Instance.new("TextButton")
btnDashAct.Size=UDim2.new(0,70,0,70)
btnDashAct.Position=UDim2.new(.5,-35,.78,0)
btnDashAct.BackgroundColor3=Color3.new(.5,.2,.6)
btnDashAct.BackgroundTransparency=.3
btnDashAct.BorderSizePixel=2
btnDashAct.Text="💨"
btnDashAct.TextColor3=Color3.new(1,1,1)
btnDashAct.TextSize=24
btnDashAct.Font=Enum.Font.GothamBold
btnDashAct.Parent=gui
btnDashAct.ZIndex=30
local preview=Instance.new("Part")
preview.Size=Vector3.new(2,2,2)
preview.Shape=Enum.PartType.Ball
preview.Material=Enum.Material.Neon
preview.Color=Color3.new(1,.5,0)
preview.Transparency=1
preview.Anchored=true
preview.CanCollide=false
preview.CanQuery=false
preview.CanTouch=false
preview.Parent=workspace

local att0=Instance.new("Attachment")
att0.Parent=root
local att1=Instance.new("Attachment")
att1.Parent=preview

local beam=Instance.new("Beam")
beam.Attachment0=att0
beam.Attachment1=att1
beam.Width0=0.3
beam.Width1=0.3
beam.Color=ColorSequence.new(Color3.new(1,.5,0))
beam.Transparency=NumberSequence.new(.5)
beam.FaceCamera=true
beam.Enabled=false
beam.Parent=root

local fovCircle=Instance.new("Frame")
fovCircle.Size=UDim2.new(0,aimFOV*2,0,aimFOV*2)
fovCircle.Position=UDim2.new(.5,-aimFOV,.5,-aimFOV)
fovCircle.BackgroundTransparency=1
fovCircle.BorderSizePixel=2
fovCircle.BorderColor3=Color3.new(1,0,0)
fovCircle.Parent=gui
fovCircle.Visible=false
fovCircle.ZIndex=1
local uc=Instance.new("UICorner")
uc.CornerRadius=UDim.new(1,0)
uc.Parent=fovCircle
local us=Instance.new("UIStroke")
us.Color=Color3.new(1,0,0)
us.Thickness=2
us.Transparency=.3
us.Parent=fovCircle

local function setColl(s)
    if not char then return end
    for _,p in pairs(char:GetDescendants())do
        if p:IsA("BasePart")then p.CanCollide=s end
    end
end

local function rmESP(p)
    if espObj[p]then
        for _,v in pairs(espObj[p])do
            if type(v)=="userdata"and v.Destroy then
                pcall(v.Destroy,v)
            elseif type(v)=="userdata"and v.Disconnect then
                pcall(v.Disconnect,v)
            end
        end
        espObj[p]=nil
    end
end

local function behindWall(p)
    if not p or not p.Character then return false end
    local h=p.Character:FindFirstChild("Head")or p.Character:FindFirstChild("HumanoidRootPart")
    if not h then return false end
    local o=cam.CFrame.Position
    local d=(h.Position-o).Unit
    local dist=(h.Position-o).Magnitude
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={char,p.Character}
    return workspace:Raycast(o,d*dist,rp)~=nil
end

local function mkESP(p)
    if espObj[p]then rmESP(p)end
    if p==plr or not p.Character then return end
    local h=p.Character:FindFirstChild("Humanoid")
    if not h then return end
    local col=isEnemy(p)and Color3.new(1,.1,.1)or Color3.new(.1,1,.1)
    local hl=Instance.new("Highlight")
    hl.Adornee=p.Character
    hl.FillColor=col
    hl.FillTransparency=.9
    hl.OutlineColor=col
    hl.OutlineTransparency=.2
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent=p.Character
    local bg=Instance.new("BillboardGui")
    bg.Size=UDim2.new(0,50,0,3)
    bg.StudsOffset=Vector3.new(0,2.2,0)
    bg.MaxDistance=500
    bg.AlwaysOnTop=true
    bg.Parent=p.Character
    local hbbg=Instance.new("Frame")
    hbbg.Size=UDim2.new(1,0,1,0)
    hbbg.BackgroundColor3=Color3.new(.1,.1,.15)
    hbbg.BackgroundTransparency=.1
    hbbg.Parent=bg
    local hb=Instance.new("Frame")
    hb.Size=UDim2.new(1,0,1,0)
    hb.BackgroundColor3=Color3.new(0,1,0)
    hb.BackgroundTransparency=.1
    hb.Parent=hbbg
    local nl=Instance.new("TextLabel")
    nl.Size=UDim2.new(1,0,0,6)
    nl.Position=UDim2.new(0,0,-1,-6)
    nl.BackgroundTransparency=1
    nl.Text=p.Name
    nl.TextColor3=col
    nl.TextSize=5
    nl.Font=Enum.Font.GothamBold
    nl.Parent=bg
    task.spawn(function()
        while espObj[p]do
            task.wait(.3)
            if not p.Character or not hl.Parent then break end
            local hh=p.Character:FindFirstChild("Humanoid")
            if hh then
                local pct=math.clamp(hh.Health/hh.MaxHealth,0,1)
                hb.Size=UDim2.new(pct,0,1,0)
                hb.BackgroundColor3=pct>.5 and Color3.new(2*(1-pct),1,0)or Color3.new(1,2*pct,0)
            end
            local tr=behindWall(p)and .6 or .9
            hl.FillTransparency=tr
            hbbg.BackgroundTransparency=1-tr
            hb.BackgroundTransparency=1-tr
        end
    end)
    local conn=h.HealthChanged:Connect(function()
        local hh=p.Character and p.Character:FindFirstChild("Humanoid")
        if hh then
            local pct=math.clamp(hh.Health/hh.MaxHealth,0,1)
            hb.Size=UDim2.new(pct,0,1,0)
            hb.BackgroundColor3=pct>.5 and Color3.new(2*(1-pct),1,0)or Color3.new(1,2*pct,0)
        end
    end)
    espObj[p]={hl,bg,conn}
end

local function visPart(part)
    if not part then return false end
    local o=cam.CFrame.Position
    local d=(part.Position-o).Unit
    local dist=(part.Position-o).Magnitude
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={char}
    return workspace:Raycast(o,d*dist,rp)==nil
end

local function bestAimPart(p)
    if not p or not p.Character then return nil end
    for _,n in pairs({"Head","UpperTorso","HumanoidRootPart","LowerTorso","LeftArm","RightArm","LeftLeg","RightLeg"})do
        local part=p.Character:FindFirstChild(n)
        if part and visPart(part)then return part end
    end
    return p.Character:FindFirstChild("Head")or p.Character:FindFirstChild("HumanoidRootPart")
end

local function aimStr()
    if aimStrength=="low"then return .15
    elseif aimStrength=="medium"then return .35
    elseif aimStrength=="high"then return .6
    else return .85 end
end

local function clearHL()
    if targetHL then
        targetHL:Destroy()
        targetHL=nil
    end
    hoverTgt=nil
end

local function centerPlayer()
    local vp=cam.ViewportSize
    local ray=cam:ViewportPointToRay(vp.X/2,vp.Y/2)
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={char}
    rp.IgnoreWater=true
    local r=workspace:Raycast(ray.Origin,ray.Direction*1000,rp)
    if r then
        local ch=r.Instance.Parent
        while ch and not ch:IsA("Model")do
            ch=ch.Parent
        end
        if ch and ch:FindFirstChild("Humanoid")and ch~=char then
            return game.Players:GetPlayerFromCharacter(ch)
        end
    end
end
local function startTargetPick()
    if targetMode then return end
    targetMode=true
    local cf=Instance.new("Frame")
    cf.Size=UDim2.new(0,60,0,60)
    cf.Position=UDim2.new(.5,-30,.5,-30)
    cf.BackgroundTransparency=1
    cf.Parent=gui
    cf.ZIndex=200
    for _,v in pairs({{UDim2.new(0,60,0,2),UDim2.new(0,0,.5,-1)},{UDim2.new(0,2,0,60),UDim2.new(.5,-1,0,0)}})do
        local l=Instance.new("Frame")
        l.Size=v[1]
        l.Position=v[2]
        l.BackgroundColor3=Color3.new(1,1,1)
        l.BackgroundTransparency=.3
        l.Parent=cf
        l.ZIndex=201
    end
    local hint=Instance.new("TextLabel")
    hint.Size=UDim2.new(0,280,0,30)
    hint.Position=UDim2.new(.5,-140,.5,50)
    hint.Text="🎯 移动视角瞄准玩家"
    hint.TextColor3=Color3.new(1,1,1)
    hint.TextSize=16
    hint.Font=Enum.Font.GothamSemibold
    hint.BackgroundTransparency=1
    hint.Parent=gui
    hint.ZIndex=200
    local ok=Instance.new("TextButton")
    ok.Size=UDim2.new(0,120,0,40)
    ok.Position=UDim2.new(.5,-60,.5,90)
    ok.BackgroundColor3=Color3.new(0,.6,.2)
    ok.BackgroundTransparency=.3
    ok.BorderSizePixel=1
    ok.Text="✅ 锁定目标"
    ok.TextColor3=Color3.new(1,1,1)
    ok.TextSize=16
    ok.Font=Enum.Font.GothamBold
    ok.Parent=gui
    ok.ZIndex=200
    local cancel=Instance.new("TextButton")
    cancel.Size=UDim2.new(0,80,0,30)
    cancel.Position=UDim2.new(.5,-40,.5,135)
    cancel.BackgroundColor3=Color3.new(.6,.1,.1)
    cancel.BackgroundTransparency=.3
    cancel.BorderSizePixel=0
    cancel.Text="取消"
    cancel.TextColor3=Color3.new(1,1,1)
    cancel.TextSize=14
    cancel.Font=Enum.Font.GothamSemibold
    cancel.Parent=gui
    cancel.ZIndex=200
    local hConn=game:GetService("RunService").Heartbeat:Connect(function()
        if not targetMode then
            hConn:Disconnect()
            return
        end
        local p=centerPlayer()
        if p~=hoverTgt then
            if p then
                clearHL()
                hoverTgt=p
                targetHL=Instance.new("Highlight")
                targetHL.Adornee=p.Character
                targetHL.FillColor=isEnemy(p)and Color3.new(1,0,0)or Color3.new(0,1,0)
                targetHL.OutlineColor=isEnemy(p)and Color3.new(1,0,0)or Color3.new(0,1,0)
                targetHL.FillTransparency=.7
                targetHL.OutlineTransparency=.3
                targetHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                targetHL.Parent=p.Character
                hint.Text="🎯 瞄准: "..p.Name
                hint.TextColor3=Color3.new(0,1,0)
            else
                clearHL()
                hint.Text="🎯 移动视角瞄准玩家"
                hint.TextColor3=Color3.new(1,1,1)
            end
        end
    end)
    ok.MouseButton1Click:Connect(function()
        if hoverTgt then
            target=hoverTgt
            targetMode=false
            btnTarget.Text="🎯 目标: "..target.Name
            btnTarget.BackgroundColor3=Color3.new(0,.8,.3)
            cf:Destroy()hint:Destroy()ok:Destroy()cancel:Destroy()
            hConn:Disconnect()
            clearHL()
        else
            hint.Text="⚠️ 没有对准玩家！"
            hint.TextColor3=Color3.new(1,.3,.3)
            task.wait(.5)
            hint.Text="🎯 移动视角瞄准玩家"
            hint.TextColor3=Color3.new(1,1,1)
        end
    end)
    cancel.MouseButton1Click:Connect(function()
        targetMode=false
        cf:Destroy()hint:Destroy()ok:Destroy()cancel:Destroy()
        hConn:Disconnect()
        clearHL()
    end)
end

setClose.MouseButton1Click:Connect(function()setF.Visible=false end)
btnSettings.MouseButton1Click:Connect(function()setF.Visible=not setF.Visible end)

btnFly.MouseButton1Click:Connect(function()
    S.fly=not S.fly
    btnFly.Text=S.fly and"🟢 飞行: 开"or"🔴 飞行: 关"
    btnUp.Visible=S.fly
    btnDown.Visible=S.fly
    hum.PlatformStand=S.fly
    setColl(not S.fly)
end)

btnHeal.MouseButton1Click:Connect(function()
    S.heal=not S.heal
    btnHeal.Text=S.heal and"🟢 锁血: 开"or"🔴 锁血: 关"
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,not S.heal)
end)

btnSpin.MouseButton1Click:Connect(function()
    S.spin=not S.spin
    btnSpin.Text=S.spin and"🟢 旋转: 开"or"🔴 旋转: 关"
    if not S.spin and not S.fly then setColl(true)end
end)

btnSprint.MouseButton1Click:Connect(function()
    S.sprint=not S.sprint
    btnSprint.Text=S.sprint and"🟢 疾跑: 开"or"🔴 疾跑: 关"
    if hum then hum.WalkSpeed=S.sprint and sprintSpeed or 16 end
end)

btnDash.MouseButton1Click:Connect(function()
    S.dash=not S.dash
    btnDash.Text=S.dash and"🟢 冲刺: 开"or"🔴 冲刺: 关"
    btnDashAct.Visible=S.dash
    if not S.dash then
        preview.Transparency=1
        beam.Enabled=false
    end
end)

btnDashAct.MouseButton1Click:Connect(function()
    if S.dash and root then
        local d=hum.MoveDirection
        if d.Magnitude<.1 then d=root.CFrame.LookVector end
        root.CFrame=CFrame.new(root.Position+d*dashDist)
    end
end)

btnESP.MouseButton1Click:Connect(function()
    S.esp=not S.esp
    btnESP.Text=S.esp and"🟢 透视: 开"or"🔴 透视: 关"
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr then
            if S.esp then mkESP(p)else rmESP(p)end
        end
    end
end)

btnAim.MouseButton1Click:Connect(function()
    S.aim=not S.aim
    btnAim.Text=S.aim and"🟢 自瞄: 开"or"🔴 自瞄: 关"
    fovCircle.Visible=S.aim
end)

btnStrength.MouseButton1Click:Connect(function()
    local st={"low","medium","high","extreme"}
    local nm={"低","中","高","极"}
    for i,s in pairs(st)do
        if aimStrength==s then
            aimStrength=st[i%#st+1]
            btnStrength.Text="💪 强度: "..nm[i%#st+1]
            break
        end
    end
end)

btnNoCD.MouseButton1Click:Connect(function()
    setNoCD(not S.nocd)
    btnNoCD.Text=S.nocd and"⚡ 无CD: 开"or"⚡ 无CD: 关"
    btnNoCD.BackgroundColor3=S.nocd and Color3.new(0,.5,.1)or Color3.new(.5,.1,.5)
end)

btnFollow.MouseButton1Click:Connect(function()
    if not target then return end
    S.follow=not S.follow
    btnFollow.Text=S.follow and"🟢 跟随: "..target.Name or"🔴 跟随: 关"
    if S.follow then
        S.orbit=false
        btnOrbit.Text="🔴 环绕: 关"
    end
end)

btnOrbit.MouseButton1Click:Connect(function()
    if not target then return end
    S.orbit=not S.orbit
    btnOrbit.Text=S.orbit and"🟢 环绕: "..target.Name or"🔴 环绕: 关"
    if S.orbit then
        S.follow=false
        btnFollow.Text="🔴 跟随: 关"
    end
end)
btnTP.MouseButton1Click:Connect(function()
    local ts={}
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
            table.insert(ts,p)
        end
    end
    if #ts>0 then
        local t=ts[math.random(1,#ts)]
        root.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
    end
end)

btnTPTo.MouseButton1Click:Connect(function()
    local ts={}
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
            table.insert(ts,p)
        end
    end
    if #ts==0 then return end
    local lf=Instance.new("Frame")
    lf.Size=UDim2.new(0,200,0,math.min(#ts*35+30,250))
    lf.Position=UDim2.new(.5,-100,.5,-125)
    lf.BackgroundColor3=Color3.new(.08,.1,.16)
    lf.BackgroundTransparency=.1
    lf.BorderSizePixel=1
    lf.Parent=gui
    lf.ZIndex=200
    local tl=Instance.new("TextLabel")
    tl.Size=UDim2.new(1,0,0,25)
    tl.Text="📌 选择玩家"
    tl.TextColor3=Color3.new(.6,.85,1)
    tl.TextSize=14
    tl.Font=Enum.Font.GothamBold
    tl.BackgroundTransparency=1
    tl.Parent=lf
    local sc=Instance.new("ScrollingFrame")
    sc.Size=UDim2.new(1,0,1,-30)
    sc.Position=UDim2.new(0,0,0,25)
    sc.BackgroundTransparency=1
    sc.CanvasSize=UDim2.new(0,0,0,#ts*30)
    sc.Parent=lf
    sc.ZIndex=210
    for i,p in pairs(ts)do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(.9,0,0,25)
        b.Position=UDim2.new(.05,0,0,(i-1)*28)
        b.BackgroundColor3=Color3.new(.15,.2,.3)
        b.BackgroundTransparency=.3
        b.BorderSizePixel=0
        b.Text=p.Name
        b.TextColor3=Color3.new(1,1,1)
        b.TextSize=13
        b.Font=Enum.Font.GothamSemibold
        b.Parent=sc
        b.ZIndex=220
        b.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
                root.CFrame=p.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
            end
            lf:Destroy()
        end)
    end
end)

btnSetSpawn.MouseButton1Click:Connect(function()
    spawnPt=root.Position
    btnSetSpawn.Text="✅ 已设置!"
    task.wait(.8)
    btnSetSpawn.Text="📍 设置传送点"
end)

btnSafe.MouseButton1Click:Connect(function()
    root.CFrame=CFrame.new(spawnPt and spawnPt+Vector3.new(0,3,0)or Vector3.new(0,13,0))
end)

btnTarget.MouseButton1Click:Connect(function()
    if target then
        target=nil
        btnTarget.Text="🎯 目标: 无"
        btnTarget.BackgroundColor3=Color3.new(.3,.6,.2)
    else
        startTargetPick()
    end
end)

btnRefresh.MouseButton1Click:Connect(function()
    btnRefresh.Text="✅ 已刷新"
    if S.esp then
        for _,p in pairs(game.Players:GetPlayers())do
            if p~=plr then mkESP(p)end
        end
    end
    if S.nocd then
        scanCD(plr:FindFirstChild("Backpack"))
        scanCD(char)
    end
    task.wait(.5)
    btnRefresh.Text="🔄 刷新"
end)

hum.WalkSpeed=sprintSpeed
task.delay(.3,function()
    for _,p in pairs(game.Players:GetPlayers())do
        if p~=plr then mkESP(p)end
    end
end)

game.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if S.esp then
            task.wait(.3)
            mkESP(p)
        end
    end)
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
    if S.heal and hum then hum.Health=hum.MaxHealth end
    if S.sprint and hum and hum.WalkSpeed~=sprintSpeed then hum.WalkSpeed=sprintSpeed end

    if S.dash and root and hum then
        local d=hum.MoveDirection
        if d.Magnitude<.1 then d=root.CFrame.LookVector end
        preview.Position=root.Position+d*dashDist
        preview.Transparency=.3
        beam.Enabled=true
    elseif preview.Transparency~=1 then
        preview.Transparency=1
        beam.Enabled=false
    end

    if S.aim then
        local t=target
        if not t or not t.Character or not canAim(t)then
            t=nil
            local bd=aimFOV
            for _,p in pairs(game.Players:GetPlayers())do
                if canAim(p)then
                    local part=bestAimPart(p)
                    if part then
                        local pos,on=cam:WorldToScreenPoint(part.Position)
                        if on then
                            local ctr=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
                            local dd=(Vector2.new(pos.X,pos.Y)-ctr).Magnitude
                            if dd<bd then
                                bd=dd
                                t=p
                            end
                        end
                    end
                end
            end
        end
        if t and t.Character then
            local part=bestAimPart(t)
            if part then
                local dir=(part.Position-cam.CFrame.Position).Unit
                cam.CFrame=CFrame.new(cam.CFrame.Position,cam.CFrame.Position+cam.CFrame.LookVector:Lerp(dir,aimStr()))
            end
        end
    end

    if S.spin and root then
        spinAng=spinAng+dt*spinSpeed
        root.CFrame=CFrame.new(root.Position)*CFrame.Angles(math.rad(90),0,0)*CFrame.Angles(0,spinAng,0)
    end

    if S.follow and target and target.Character then
        local tr=target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            root.CFrame=CFrame.new(tr.Position+Vector3.new(0,3,0))
        end
    end

    if S.orbit and target and target.Character then
        local tr=target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            orbitAng=orbitAng+dt*2
            local r=8
            root.CFrame=CFrame.new(Vector3.new(tr.Position.X+math.cos(orbitAng)*r,tr.Position.Y+3,tr.Position.Z+math.sin(orbitAng)*r),tr.Position)
        end
    end

    if S.fly and root and hum then
        for _,p in pairs(char:GetDescendants())do
            if p:IsA("BasePart")then p.CanCollide=false end
        end
        hum.PlatformStand=true
        root.Velocity=Vector3.new(0,0,0)
        root.AssemblyLinearVelocity=Vector3.new(0,0,0)
        local ld=(cam.CFrame.Position-root.Position).Unit
        ld=Vector3.new(ld.X,0,ld.Z).Unit
        if ld.Magnitude>.01 then
            root.CFrame=CFrame.new(root.Position,root.Position-ld)
        end
        local mv=hum.MoveDirection
        local fw=root.CFrame.LookVector
        local rt=root.CFrame.RightVector
        local up=Vector3.new(0,1,0)
        local v=(rt*mv:Dot(rt)+fw*mv:Dot(fw))*flySpeed*dt
        if upHeld then
            v=v+up*flySpeed*dt
        elseif downHeld then
            v=v-up*flySpeed*dt
        else
            v=v+up*3*dt
        end
        root.CFrame=root.CFrame+v
    end
end)

game.Players.PlayerRemoving:Connect(function(p)
    rmESP(p)
    if target==p then
        target=nil
        btnTarget.Text="🎯 目标: 无"
    end
end)

plr.CharacterAdded:Connect(function(c)
    char=c
    root=char:WaitForChild("HumanoidRootPart")
    hum=char:WaitForChild("Humanoid")
    S.fly=false
    btnFly.Text="🔴 飞行: 关"
    btnUp.Visible=false
    btnDown.Visible=false
    setColl(true)
    hum.PlatformStand=false
    att0.Parent=root
    beam.Parent=root
    if S.sprint and hum then hum.WalkSpeed=sprintSpeed end
    if S.esp then
        task.wait(.5)
        for _,p in pairs(game.Players:GetPlayers())do
            if p~=plr then mkESP(p)end
        end
    end
end)
