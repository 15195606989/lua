local plr=game.Players.LocalPlayer
local char=plr.Character or plr.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local RunService=game:GetService("RunService")

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
local storedVels={}

local function startVortex()
    conn=RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local center=root.Position
        
        for _,part in pairs(workspace:GetDescendants())do
            if part:IsA("BasePart")and not part.Anchored and part~=root then
                local inChar=false
                for _,cp in pairs(char:GetDescendants())do
                    if cp==part then inChar=true break end
                end
                if not inChar then
                    local dir=part.Position-center
                    local horiz=Vector3.new(dir.X,0,dir.Z)
                    if horiz.Magnitude>2 and horiz.Magnitude<100 then
                        local tangent=Vector3.new(-horiz.Z,0,horiz.X).Unit
                        local toward=(center-part.Position).Unit
                        local v=tangent*80+toward*20+Vector3.new(0,10,0)
                        part.AssemblyLinearVelocity=v
                    end
                end
            end
        end
    end)
end

local function stopVortex()
    if conn then conn:Disconnect()conn=nil end
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
    char=c
    root=c:WaitForChild("HumanoidRootPart")
end)
