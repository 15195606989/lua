-- Scanner.lua - 智能准星扫描器 (高亮版)
local plr = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local RS = game:GetService("RunService")

if plr.PlayerGui:FindFirstChild("SCAN_UI") then plr.PlayerGui.SCAN_UI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SCAN_UI" gui.Parent = plr.PlayerGui gui.ResetOnSpawn = false

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

-- 右侧面板
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,180,0,200) panel.Position = UDim2.new(1,-190,0,250)
panel.BackgroundColor3 = Color3.new(0.08,0.1,0.16) panel.BorderSizePixel = 1
panel.Visible = false panel.Parent = gui

local textBox = Instance.new("TextLabel")
textBox.Size = UDim2.new(0.9,0,0.9,0) textBox.Position = UDim2.new(0.05,0,0.05,0)
textBox.BackgroundTransparency = 1 textBox.Text = "等待瞄准..."
textBox.TextColor3 = Color3.new(0.8,0.9,1) textBox.TextSize = 10
textBox.TextXAlignment = Enum.TextXAlignment.Left textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.Font = Enum.Font.Code textBox.TextWrapped = true textBox.Parent = panel

-- 主开关
local btnScan = Instance.new("TextButton")
btnScan.Size = UDim2.new(0,120,0,36) btnScan.Position = UDim2.new(0,10,0.5,0)
btnScan.BackgroundColor3 = Color3.new(0.6,0.1,0.1) btnScan.BorderSizePixel = 0
btnScan.Text = "🔍 扫描: 关" btnScan.TextColor3 = Color3.new(1,1,1) btnScan.TextSize = 12
btnScan.Font = Enum.Font.GothamBold btnScan.Parent = gui

local scanOn = false local conn = nil local currentTarget = nil local hl = nil

local function clearHighlight() if hl then hl:Destroy() hl = nil end end

local function scanTarget()
    local vs = cam.ViewportSize
    local ray = cam:ViewportPointToRay(vs.X/2, vs.Y/2)
    local rp = RaycastParams.new() rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {plr.Character or {}}
    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
    
    if not res then
        if currentTarget then textBox.Text = "未瞄准目标" currentTarget = nil clearHighlight() end
        return
    end
    
    local inst = res.Instance
    local char = inst:FindFirstAncestorOfClass("Model")
    local p = char and game.Players:GetPlayerFromCharacter(char)
    local targetObj = p and char or inst
    
    if targetObj == currentTarget then return end
    currentTarget = targetObj clearHighlight()
    
    hl = Instance.new("Highlight")
    hl.Adornee = targetObj hl.FillColor = Color3.new(1,1,0) hl.OutlineColor = Color3.new(1,1,0)
    hl.FillTransparency = 0.7 hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = targetObj
    
    local txt = ""
    if p then
        txt = "【玩家】"..p.Name.."\n"
        if char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            txt = txt.."血量: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth).."\n速度: "..math.floor(hum.WalkSpeed).."\n"
        end
    else txt = "【物件】"..inst.Name.."\n类型: "..inst.ClassName.."\n" end
    
    local attrs = inst:GetAttributes()
    if next(attrs) then
        txt = txt.."\n[ 属性 ]\n"
        for k,v in pairs(attrs) do txt = txt..tostring(k)..": "..tostring(v).."\n" end
    end
    local tags = inst:GetTags()
    if #tags > 0 then txt = txt.."\n[ 标签 ]\n"..table.concat(tags, ", ").."\n" end
    
    textBox.Text = txt
end

btnScan.MouseButton1Click:Connect(function()
    scanOn = not scanOn
    if scanOn then
        btnScan.Text = "🟢 扫描: 开" btnScan.BackgroundColor3 = Color3.new(0,0.5,0.1)
        crosshair.Visible = true panel.Visible = true
        conn = RS.RenderStepped:Connect(scanTarget)
    else
        btnScan.Text = "🔍 扫描: 关" btnScan.BackgroundColor3 = Color3.new(0.6,0.1,0.1)
        crosshair.Visible = false panel.Visible = false
        if conn then conn:Disconnect() conn = nil end
        currentTarget = nil clearHighlight() textBox.Text = "等待瞄准..."
    end
end)
