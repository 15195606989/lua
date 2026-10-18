--[[
Scanner.lua - 准星扫描器 & 中文属性翻译版
作用：准星对准目标，翻译并显示所有关键属性。高亮识别真假。
]]
local plr=game.Players.LocalPlayer
local cam=workspace.CurrentCamera
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")

if plr.PlayerGui:FindFirstChild("SCAN_UI")then plr.PlayerGui.SCAN_UI:Destroy()end
local gui=Instance.new("ScreenGui")
gui.Name="SCAN_UI" gui.Parent=plr.PlayerGui gui.ResetOnSpawn=false

local miniIcon=Instance.new("TextButton")
miniIcon.Size=UDim2.new(0,28,0,28) miniIcon.Position=UDim2.new(1,-35,0,210)
miniIcon.BackgroundColor3=Color3.new(0.1,0.7,0.5) miniIcon.BorderSizePixel=0
miniIcon.Text="🔍" miniIcon.TextSize=16 miniIcon.TextColor3=Color3.new(1,1,1)
miniIcon.Font=Enum.Font.GothamBold miniIcon.Parent=gui miniIcon.Visible=false

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,200,0,240) panel.Position=UDim2.new(1,-210,0,210)
panel.BackgroundColor3=Color3.new(0.08,0.1,0.16) panel.BackgroundTransparency=0.1
panel.BorderSizePixel=1 panel.Parent=gui

local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,25) title.Text="🔍 属性扫描 (中文)" title.TextColor3=Color3.new(0.5,1,0.8)
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

local btnScan=Instance.new("TextButton")
btnScan.Size=UDim2.new(0.9,0,0,24) btnScan.Position=UDim2.new(0.05,0,0,26)
btnScan.BackgroundColor3=Color3.new(0.6,0.1,0.1) btnScan.BorderSizePixel=0
btnScan.Text="🔴 扫描: 关" btnScan.TextColor3=Color3.new(1,1,1) btnScan.TextSize=11
btnScan.Font=Enum.Font.GothamSemibold btnScan.Parent=panel

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(0.9,0,0,180) scroll.Position=UDim2.new(0.05,0,0,54)
scroll.BackgroundColor3=Color3.new(0.1,0.1,0.1) scroll.BackgroundTransparency=0.5
scroll.BorderSizePixel=0 scroll.ScrollBarThickness=4
scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.Parent=panel

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,2) layout.SortOrder=Enum.SortOrder.LayoutOrder scroll.Parent=scroll

if not getgenv().NDS_UI then getgenv().NDS_UI={panels={},register=function(name,hideFn,showFn) getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn} end,showOnly=function(name) for n,p in pairs(getgenv().NDS_UI.panels)do if n==name then p.show()else p.hide()end end end} end
getgenv().NDS_UI.register("Scanner",function() panel.Visible=false miniIcon.Visible=true end,function() panel.Visible=true miniIcon.Visible=false end)
btnMin.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Scanner") end)
miniIcon.MouseButton1Click:Connect(function() getgenv().NDS_UI.showOnly("Scanner") end)

local scanOn=false local conn=nil local lastTarget=nil

local function addItem(text,color)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,22) btn.BackgroundColor3=Color3.new(0.2,0.2,0.2)
    btn.BackgroundTransparency=0.5 btn.BorderSizePixel=0 btn.Text=" "..text
    btn.TextColor3=color or Color3.new(0.8,0.9,1) btn.TextSize=10 
    btn.TextXAlignment=Enum.TextXAlignment.Left btn.Font=Enum.Font.Gotham
    btn.TextWrapped=true btn.AutoButtonColor=true btn.Parent=scroll
    btn.MouseButton1Click:Connect(function()
        if btn.Text:sub(1,1)==" " then btn.Text="▼"..btn.Text:sub(2) btn.BackgroundTransparency=0.2
        else btn.Text=" "..btn.Text:sub(2) btn.BackgroundTransparency=0.5 end
    end)
end

-- 翻译字典
local translations = {
    Anchored = "固定不动(Anchored)", CanCollide = "可碰撞(CanCollide)",
    Transparency = "透明度(Transparency)", Material = "材质(Material)",
    Color = "颜色(Color)", Size = "大小(Size)", Position = "位置(Position)",
    IsFake = "是否是假的(IsFake)", Fake = "假的(Fake)", Real = "真的(Real)",
    IsReal = "是否是真的(IsReal)", GlassType = "玻璃类型(GlassType)"
}

local function scanTarget()
    local vs=cam.ViewportSize
    local ray=cam:ViewportPointToRay(vs.X/2,vs.Y/2)
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances={plr.Character or {}}
    local res=workspace:Raycast(ray.Origin,ray.Direction*2000,rp)
    if not res then if lastTarget then scroll:ClearAllChildren() layout.Parent=scroll lastTarget=nil end return end
    local inst=res.Instance
    if inst==lastTarget then return end
    lastTarget=inst
    
    scroll:ClearAllChildren() layout.Parent=scroll
    addItem("【目标】"..inst.Name, Color3.new(0.5,1,0.5))
    addItem("【类型】"..inst.ClassName, Color3.new(0.5,0.5,1))

    -- 属性读取与判定
    local attrs=inst:GetAttributes()
    local isFakeFound = false
    if next(attrs) then
        addItem("[ 游戏自定义属性 ]", Color3.new(1,0.8,0.3))
        for k,v in pairs(attrs)do 
            local zh = translations[k] or k
            local strV = tostring(v)
            -- 真假判定
            if type(v) == "boolean" and (string.find(string.lower(k), "fake") or string.find(string.lower(k), "real") or string.find(string.lower(k), "glass")) then
                isFakeFound = true
                local resColor = v and Color3.new(1,0.3,0.3) or Color3.new(0.3,1,0.3)
                addItem("👉 "..zh.." : "..strV, resColor)
            else
                addItem("  "..zh.." : "..strV) 
            end
        end
    end
    
    -- 如果发现可能包含真假信息，给个大字提示
    if isFakeFound then
        addItem("⚠️ 发现真假标记属性 ⚠️", Color3.new(1,0.5,0))
    end

    local tags=inst:GetTags()
    if #tags>0 then
        addItem("[ 标签 (Tags) ]", Color3.new(1,0.8,0.3))
        for _,t in ipairs(tags)do addItem("  "..tostring(t)) end
    end

    -- 常用物理属性翻译
    addItem("[ 常用属性 ]", Color3.new(1,0.8,0.3))
    pcall(function() addItem("  "..translations.Anchored..": "..tostring(inst.Anchored)) end)
    pcall(function() addItem("  "..translations.CanCollide..": "..tostring(inst.CanCollide)) end)
    pcall(function() addItem("  "..translations.Transparency..": "..tostring(inst.Transparency)) end)
    pcall(function() addItem("  "..translations.Material..": "..tostring(inst.Material)) end)

    task.wait() scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
end

btnScan.MouseButton1Click:Connect(function()
    scanOn=not scanOn
    if scanOn then
        btnScan.Text="🟢 扫描: 开" btnScan.BackgroundColor3=Color3.new(0,0.5,0.1)
        conn=RS.RenderStepped:Connect(scanTarget)
    else
        btnScan.Text="🔴 扫描: 关" btnScan.BackgroundColor3=Color3.new(0.6,0.1,0.1)
        if conn then conn:Disconnect() conn=nil end
        scroll:ClearAllChildren() layout.Parent=scroll lastTarget=nil
    end
end)

btnClose.MouseButton1Click:Connect(function() if conn then conn:Disconnect() end gui:Destroy() end)

-- Scanner.lua 结束 | 共 167 行
