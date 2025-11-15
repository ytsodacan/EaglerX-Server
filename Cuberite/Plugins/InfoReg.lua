-- InfoReg.lua
-- Loads Core and utility plugins

function Initialize(Plugin)
    local pm = cPluginManager:Get()

    -- Load Core first
    local success, err = pcall(function() pm:LoadPlugin("Core") end)
    if success then
        LOG("Core plugin loaded")
    else
        LOG("Failed to load Core: " .. tostring(err))
    end

    -- Load utility plugins
    local plugins = {
        "APIDump",
        "Debuggers",
        "DumpInfo",
        "HookNotify",
        "NetworkTest",
        "TestLuaRocks",
        "WebConsole"
    }

    for _, name in ipairs(plugins) do
        local ok, e = pcall(function() pm:LoadPlugin(name) end)
        if ok then
            LOG("Loaded plugin: " .. name)
        else
            LOG("Failed to load plugin: " .. name .. " Error: " .. tostring(e))
        end
    end

    return true
end

function OnDisable()
    LOG("InfoReg plugin disabled")
end
