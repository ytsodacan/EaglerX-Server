function Initialize(Plugin)
    -- Expose an HTTP endpoint
    cPluginManager:AddHook(cPluginManager.HOOK_WEB_REQUEST, HandleWebRequest)
    LOG("WebConsole loaded")
    return true
end

function HandleWebRequest(Request)
    local url = Request:GetURLPath()
    if url:find("/execute-command") then
        local cmd = Request:GetPostData() or ""
        if cmd ~= "" then
            cRoot:Get():BroadcastChat("/" .. cmd) -- executes command
        end
        Request:Send(200, "text/plain", "Command executed: " .. cmd)
        return true
    end
    return false
end
