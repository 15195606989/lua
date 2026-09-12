getgenv().NDS_UI=getgenv().NDS_UI or {
    panels={},
    register=function(name,hideFn,showFn)
        getgenv().NDS_UI.panels[name]={hide=hideFn,show=showFn}
    end,
    showOnly=function(name)
        for n,p in pairs(getgenv().NDS_UI.panels)do
            if n==name then
                p.show()
            else
                p.hide()
            end
        end
    end
}
