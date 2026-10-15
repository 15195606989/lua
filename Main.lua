local base="https://raw.githubusercontent.com/15195606989/lua"
local scripts={"Fly.lua","Speed.lua","ESP.lua","Vortex.lua","Aimbot.lua"}

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title="NDS 加载中",
    Text="正在加载 "..#scripts.." 个功能...",
    Duration=3
})

local okList={}
local failList={}

for _,name in ipairs(scripts)do
    local ok,err=pcall(function()
        local code=game:HttpGet(base..name)
        local fn,lerr=loadstring(code)
        if not fn then
            error("语法错误: "..tostring(lerr):sub(1,60))
        end
        fn()
    end)
    if ok then
        table.insert(okList,name)
    else
        table.insert(failList,name.." - "..tostring(err):sub(1,60))
    end
end

-- 显示成功
if #okList>0 then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="✅ 加载成功 ("..#okList..")",
        Text=table.concat(okList,", "),
        Duration=8
    })
end

-- 显示失败
if #failList>0 then
    for _,info in ipairs(failList)do
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="❌ 加载失败",
            Text=info,
            Duration=15
        })
        task.wait(0.3)
    end
end
