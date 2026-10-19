--[[ Scanner.lua - 属性扫描器 (纯文本终极防报错版) ]]
local plr=game.Players.LocalPlayer
local cam=workspace.CurrentCamera
local RS=game:GetService("RunService")

if plr.PlayerGui:FindFirstChild("SCAN_UI") then plr.PlayerGui.SCAN_UI:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="SCAN_UI" gui.Parent=plr.PlayerGui gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28) miniIcon.Position=UDim2.new(1,-35,0,250)
miniIcon.BackgroundColor3=Color3.new(0.1,0.7,0.5) miniIcon.BorderSizePixel=0
miniIcon.Text="🔍" miniIcon.TextSize=16 miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold miniIcon.Parent=gui miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,200,0,240) panel.Position=UDim2.new(1,-210,0,250)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16) panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1 panel.Parent=gui

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,25) title.Text="🔍 属性扫描 (纯文本)" title.TextColor3=Color3.new(0.5,1,0.8)
title.TextSize=11 title.Font=Enum.Font.GothamBold title.BackgroundTransparency=1 title.Parent=panel

local btnMin=Instance.new("TextButton")
btnMin.Size=UDim2.new(0,25,0,25) btnMin.Position=UDim2.new(1,-55,0,0)
btnMin.BackgroundTransparency=1 btnMin.Text="−" btnMin.TextColor3=Color3.new(1,0.8,0.3)
btnMin.TextSize=16 btnMin.Font=Enum.Font.GothamBold btnMin.Parent=panel

local btnClose=Instance.new("TextButton")
btnClose.Size=UDim2.new(0,25,0,25) btnClose.Position=UDim2.new(1,-28,0,0)
btnClose.BackgroundTransparency=1 btnClose.Text="✕" btnClose.TextColor3=Color3.new(1,0.3,0.3)
btnClose.TextSize=14 btnClose.Font=Enum.Font.GothamBold btnClose.Parent=panel

local btnScan=Instance.new("TextButton")
btnScan.Size=UDim2.new(0.9,0,0,24) btnScan.Position=UDim2.new(0.05,0,0,26)
btnScan.BackgroundColor3=Color3.new(0.6,0.1,0.1) btnScan.BorderSizePixel=0
btnScan.Text="🔴 扫描: 关" btnScan.TextColor3=Color3.new(1,1,1) btnScan.TextSize=11
btnScan.Font=Enum.Font.GothamSemibold btnScan.Parent=panel

local textBox=Instance.new("TextLabel")
textBox.Size=UDim2.new(0.9,0,0,180) textBox.Position=UDim2.new(0.05,0,0,54)
textBox.BackgroundColor3=Color3.new(0.1,0.1,0.1) textBox.BackgroundTransparency=0.5
textBox.BorderSizePixel=0 textBox.Text="等待扫描..."
textBox.TextColor3=Color3.new(0.8,0.9,1) textBox.TextSize=10
textBox.TextXAlignment=Enum.TextXAlignment.Left textBox.TextYAlignment=Enum.TextYAlignment.Top
textBox.Font=Enum.Font.Code textBox.TextWrapped=true textBox.Parent=panel

if not getgenv().NDS_UI then getgenv().NDS_UI={panels={},register=function(name,hideFn,showFn) getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn} end,showOnly=function(name) for n,p in pairs(getgenv().NDS_UI.panels)do if n==name then p.show()else p.hide()end end end} end
getgenv().NDS_UI.register("Scanner",function() panel.Visible=false miniIcon.Visible=true end,function() panel.Visible=true miniIcon.Visible=false end)
btnMin.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Scanner") end)
miniIcon.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Scanner") end)
local scanOn=false local conn=nil local lastTarget=nil
local tr = { Anchored="固定", CanCollide="碰撞", Transparency="透明", IsFake="假", Fake="假", Real="真", IsReal="真" }

local function scanTarget()
    local vs=cam.ViewportSize
    local ray=cam:ViewportPointToRay(vs.X/2,vs.Y/2)
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances={plr.Character or {}}
    local res=workspace:Raycast(ray.Origin,ray.Direction*2000,rp)
    if not res then if lastTarget then textBox.Text="未瞄准目标" lastTarget=nil end return end
    local inst=res.Instance
    if inst==lastTarget then return end
    lastTarget=inst
    
    local txt="【目标】"..inst.Name.."\n【类型】"..inst.ClassName.."\n"
    local attrs=inst:GetAttributes()
    local isFakeFound=false
    if next(attrs) then
        txt=txt.."[ 自定义属性 ]\n"
        for k,v in pairs(attrs)do 
            local zh = tr[k] or k
            local strV = tostring(v)
            if type(v) == "boolean" and (string.find(string.lower(k), "fake") or string.find(string.lower(k), "real") or string.find(string.lower(k), "glass")) then
                isFakeFound = true
                txt=txt..(v and "👉 假 " or "👉 真 ")..zh..":"..strV.."\n"
            else
                txt=txt..zh..":"..strV.."\n" 
            end
        end
    end
    if isFakeFound then txt="⚠️发现真假标记⚠️\n"..txt end

    local tags=inst:GetTags()
    if #tags>0 then txt=txt.."[ 标签 ]\n"..table.concat(tags, ", ").."\n" end
    txt=txt.."[ 常用属性 ]\n"
    pcall(function() txt=txt..tr.Anchored..":"..tostring(inst.Anchored).."\n" end)
    pcall(function() txt=txt..tr.CanCollide..":"..tostring(inst.CanCollide).."\n" end)
    
    textBox.Text=txt
end

btnScan.MouseButton1Click:Connect(function()
    scanOn=not scanOn
    if scanOn then
        btnScan.Text="🟢 扫描: 开" btnScan.BackgroundColor3=Color3.new(0,0.5,0.1)
        conn=RS.RenderStepped:Connect(scanTarget)
    else
        btnScan.Text="🔴 扫描: 关" btnScan.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        textBox.Text="等待扫描..."
        if conn then conn:Disconnect() conn=nil end
        lastTarget=nil
    end
end)
btnClose.MouseButton1Click:Connect(function() if conn then conn:Disconnect() end gui:Destroy() end)
-- Scanner.lua 结束
