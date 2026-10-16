--[[
Vortex.lua - 本地漩涡
作用：在本地客户端把周围未固定物体卷向自己，仅在本地生效，不影响服务器物理。
说明：所有物理修改仅对本地生效，其他玩家看不到，服务端也可能会拒绝部分物体的速度修改。

【变量表】
plr            LocalPlayer，本地玩家
char           玩家角色模型
root           角色 HumanoidRootPart（漩涡中心）
RS              RunService 服务
gui             ScreenGui 容器
btn             开关按钮
vortexOn        布尔，漩涡是否开启
conn            Heartbeat 连接句柄，关闭时断开
affectedParts   表，记录被吸过的部件，关闭时用于清零速度
isInChar()      函数，判断部件是否属于自己角色
startVortex()   函数，开启漩涡主循环
stopVortex()    函数，关闭漩涡并清零速度

【代码结构】
1. 初始化：拿玩家、角色、root、服务
2. 清理旧 UI：防止重复加载叠加
3. 创建 GUI 与开关按钮
4. 状态变量：vortexOn / conn / affectedParts
5. isInChar()：遍历角色所有子孙，判断部件是否在角色身上
6. startVortex()：每帧遍历 workspace，对距离 2~100 的非固定部件施加切向+向心速度，模拟漩涡
7. stopVortex()：断开连接，遍历 affectedParts 把速度归零，并清自己 root 速度
8. 按钮点击：切换开关，调 start/stop
9. 角色重生：停止漩涡并重置状态

【依赖】
无。独立文件。
]]

local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local RS=game:GetService("RunService")
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
local vortexOn=false
local conn=nil
local affectedParts={}
-- 判断某部件是否属于自己角色，避免吸自己
local function isInChar(part)
    for _,c in pairs(char:GetDescendants())do if c==part then return true end end
    return false
end
-- 开启漩涡：每帧施加切向+向心速度
local function startVortex()
    conn=RS.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local center=root.Position
        for _,p in pairs(workspace:GetDescendants())do
            if p:IsA("BasePart") and not p.Anchored and p~=root and not isInChar(p) then
                local dir=p.Position-center
                local horiz=Vector3.new(dir.X,0,dir.Z)
                if horiz.Magnitude>2 and horiz.Magnitude<100 then
                    local tangent=Vector3.new(-horiz.Z,0,horiz.X).Unit
                    local toward=(center-p.Position).Unit
                    p.AssemblyLinearVelocity=tangent*80+toward*20+Vector3.new(0,10,0)
                    affectedParts[p]=true
                end
            end
        end
    end)
end
-- 关闭漩涡：清零被吸物体速度 + 清自己残留速度
local function stopVortex()
    if conn then conn:Disconnect() conn=nil end
    for p,_ in pairs(affectedParts)do
        if p and p.Parent then pcall(function()
            p.AssemblyLinearVelocity=Vector3.new(0,0,0)
            p.AssemblyAngularVelocity=Vector3.new(0,0,0)
        end) end
    end
    affectedParts={}
    if root and root.Parent then pcall(function()
        root.AssemblyLinearVelocity=Vector3.new(0,0,0)
        root.AssemblyAngularVelocity=Vector3.new(0,0,0)
    end) end
end
btn.MouseButton1Click:Connect(function()
    vortexOn=not vortexOn
    if vortexOn then
        btn.Text="🌀 漩涡: 开"
        btn.BackgroundColor3=Color3.new(0,0.5,0.1)
        startVortex()
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
    btn.Text="🌀 漩涡: 关"
    btn.BackgroundColor3=Color3.new(0.4,0.1,0.6)
end)
-- Vortex.lua 结束 | 共 96 行
