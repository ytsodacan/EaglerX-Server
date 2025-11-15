-- main.lua
-- Main plugin entrypoint

local pm = cPluginManager:Get()
local pluginPath = pm:GetPluginsPath()

function Initialize(Plugin)
    Plugin:SetName(g_PluginInfo.Name)

    -- Load Core plugin first
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

    -- Register hooks
    local hooks = {
        {cPluginManager.HOOK_BLOCK_SPREAD,          OnBlockSpread},
        {cPluginManager.HOOK_CHAT,                  OnChat},
        {cPluginManager.HOOK_CRAFTING_NO_RECIPE,    OnCraftingNoRecipe},
        {cPluginManager.HOOK_PLAYER_DESTROYED,      OnDisconnect},
        {cPluginManager.HOOK_EXPLODING,             OnExploding},
        {cPluginManager.HOOK_KILLING,               OnKilling},
        {cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock},
        {cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined},
        {cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined_WebChat},
        {cPluginManager.HOOK_PLAYER_MOVING,         OnPlayerMoving},
        {cPluginManager.HOOK_PLAYER_PLACING_BLOCK,  OnPlayerPlacingBlock},
        {cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    OnPlayerRightClick},
        {cPluginManager.HOOK_SPAWNING_MONSTER,      OnSpawningMonster},
        {cPluginManager.HOOK_TAKE_DAMAGE,           OnTakeDamage},
        {cPluginManager.HOOK_TICK,                  OnTick},
        {cPluginManager.HOOK_WORLD_TICK,            OnWorldTick},
    }

    for _, h in ipairs(hooks) do
        pm:AddHook(h[1], h[2])
    end

    -- Load InfoReg.lua and register commands safely
    local infoRegFile = pluginPath .. "/InfoReg.lua"
    if io.open(infoRegFile, "r") then
        dofile(infoRegFile)
        if RegisterPluginInfoCommands then RegisterPluginInfoCommands() end
        if RegisterPluginInfoConsoleCommands then RegisterPluginInfoConsoleCommands() end
    else
        LOG("InfoReg.lua not found: " .. infoRegFile)
    end

    -- Load world settings
    if LoadWorldSettings then
        cRoot:Get():ForEachWorld(function(World)
            LoadWorldSettings(World)
        end)
    end

    -- Initialize banlist, whitelist, item blacklist
    if InitializeBanlist then InitializeBanlist() end
    if InitializeWhitelist then InitializeWhitelist() end
    if InitializeItemBlacklist then InitializeItemBlacklist(Plugin) end

    -- WebAdmin tabs
    if cWebAdmin then
        local tabs = {
            {"Manage Server",   "manage-server",   HandleRequest_ManageServer},
            {"Server Settings", "server-settings", HandleRequest_ServerSettings},
            {"Chat",            "chat",            HandleRequest_Chat},
            {"Players",         "players",         HandleRequest_Players},
            {"Whitelist",       "whitelist",       HandleRequest_WhiteList},
            {"Permissions",     "permissions",     HandleRequest_Permissions},
            {"Plugins",         "plugins",         HandleRequest_ManagePlugins},
            {"Time & Weather",  "time-weather",    HandleRequest_Weather},
            {"Ranks",           "ranks",           HandleRequest_Ranks},
            {"Player Ranks",    "player-ranks",    HandleRequest_PlayerRanks},
        }
        for _, t in ipairs(tabs) do
            cWebAdmin:AddWebTab(t[1], t[2], t[3])
        end
    end

    -- Load MOTD
    if LoadMOTD then LoadMOTD() end

    WEBLOGINFO("Core and InfoReg plugins initialized")
    LOG("Server plugin fully initialized!")

    return true
end

function OnDisable()
    LOG("Server plugin disabled")
end
