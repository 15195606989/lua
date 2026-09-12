local base="https://raw.githubusercontent.com/15195606989/lua/refs/heads/main/"
local scripts={"Fly.lua","Speed.lua","ESP.lua","Vortex.lua"}
for _,name in ipairs(scripts)do
    local ok,err=pcall(function()
        loadstring(game:HttpGet(base..name))()
    end)
    if not ok then
        warn("加载失败: "..name.." - "..tostring(err))
    end
end
