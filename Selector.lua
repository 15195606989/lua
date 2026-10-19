-- Selector.lua - 极简目标选择器 (高亮+隐身)
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local RS = game:GetService("RunService")

if not getgenv().NDS_Selector then getgenv().NDS_Selector = {player=nil, object=nil, mode="player"} end
if plr.PlayerGui:FindFirstChild("SEL_UI") then plr.PlayerGui.SEL_UI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SEL_UI" gui.Parent = plr.PlayerGui gui.ResetOnSpawn = false

-- 准星
local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.new(0,60,0,60) crosshair.Position = UDim2.new(0.5,-30,0.5,-30)
crosshair.BackgroundTransparency = 1 crosshair.ZIndex = 100 crosshair.Visible = false crosshair.Parent = gui
local function makeLine(sx,sy,px,py)
    local l = Instance.new("Frame") l.Size = UDim2.new(0,sx,0,sy)
    l.Position = UDim2.new(0.5,px,0.5,py) l.BackgroundColor3 = Color3.new(0,1,0)
    l.BorderSizePixel = 0 l.Parent = crosshair
end
makeLine(2,10,-1,-18) makeLine(2,10,-1,8) makeLine(10,2,-18,-1) makeLine(10,2,8,-1)

-- 按钮容器
local btnScan = Instance.new("TextButton")
btnScan.Size = UDim2.new(0,120,0,36) btnScan.Position = UDim2.new(0,10,0.5,40)
btnScan.BackgroundColor3 = Color3.new(0.1,0.4,0.8) btnScan.BorderSizePixel = 0
btnScan.Text = "🎯 开始选择" btnScan.TextColor3 = Color3.new(1,1,1) btnScan.TextSize = 12
btnScan.Font = Enum.Font.GothamBold btnScan.Parent = gui

local btnConfirm = Instance.new("TextButton")
btnConfirm.Size = UDim2.new(0,120,0,36) btnConfirm.Position = UDim2.new(0,10,0.5,80)
btnConfirm.BackgroundColor3 = Color3.new(0.1,0.6,0.2) btnConfirm.BorderSizePixel = 0
btnConfirm.Text = "✅ 确认目标" btnConfirm.TextColor3 = Color3.new(1,1,1) btnConfirm.TextSize = 12
btnConfirm.Font = Enum.Font.GothamBold btnConfirm.Parent = gui btnConfirm.Visible = false

local scanOn = false local conn = nil local currentTarget = nil local hl = nil
local autoInv = true local isInv = false local invConn = nil local savedTrans = {}

local function clearHighlight() if hl then hl:Destroy() hl = nil end end

local function setTrans(alpha)
    if not plr.Character then return end
    for _,p in pairs(plr.Character:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") or p:IsA("Texture") then
            if alpha then
                if not savedTrans[p] then savedTrans[p] = p.Transparency end
                if p:IsA("BasePart") then p.LocalTransparencyModifier = alpha else p.Transparency = alpha end
            else
                if savedTrans[p] then 
                    if p:IsA("BasePart") then p.LocalTransparencyModifier = savedTrans[p] else p.Transparency = savedTrans[p] end
                    savedTrans[p] = nil 
                end
            end
        end
    end
end

local function scanTarget()
    local vs = cam.ViewportSize
    local screenCenter = Vector2.new(vs.X/2, vs.Y/2)
    local closest = nil local minDist = 40 -- 容错像素
    
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = cam:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if dist < minDist then minDist = dist closest = p end
            end
        end
    end
    
    if closest == currentTarget then return end
    currentTarget = closest clearHighlight()
    
    if currentTarget then
        hl = Instance.new("Highlight")
        hl.Adornee = currentTarget.Character hl.FillColor = Color3.new(1,1,0) hl.OutlineColor = Color3.new(1,1,0)
        hl.FillTransparency = 0.7 hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = currentTarget.Character
    end
end

btnScan.MouseButton1Click:Connect(function()
    scanOn = not scanOn
    if scanOn then
        btnScan.Text = "🔍 扫描中..." btnScan.BackgroundColor3 = Color3.new(0.8,0.5,0.1)
        crosshair.Visible = true btnConfirm.Visible = true
        conn = RS.RenderStepped:Connect(scanTarget)
    else
        btnScan.Text = "🎯 开始选择" btnScan.BackgroundColor3 = Color3.new(0.1,0.4,0.8)
        crosshair.Visible = false btnConfirm.Visible = false
        if conn then conn:Disconnect() conn = nil end
        currentTarget = nil clearHighlight()
    end
end)

btnConfirm.MouseButton1Click:Connect(function()
    if not currentTarget then return end
    getgenv().NDS_Selector.player = currentTarget
    btnScan.Text = "🎯 已选: "..currentTarget.Name
    
    -- 隐身
    if autoInv and not isInv then
        isInv = true
        if not invConn then invConn = RS.Heartbeat:Connect(function() setTrans(0.6) end) end
    end
    
    -- 停止扫描
    scanOn = false btnScan.BackgroundColor3 = Color3.new(0.1,0.6,0.2)
    crosshair.Visible = false btnConfirm.Visible = false
    if conn then conn:Disconnect() conn = nil end
    clearHighlight()
end)

plr.CharacterAdded:Connect(function()
    savedTrans = {}
    if isInv then task.wait(1) setTrans(0.6) end
end)
