-- Plugin Options
-- I figured it would be less of a hassle for both me and you to directly put a config here ;)

-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- This value keeps unwanted players out of the arena.  These options are NOT optimal on Raspberry Pi first-gens
-- as they do a bunch of table cycles very often.
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Keeps players out of occupied arenas unless the player is an Admin
KeepPlayersOutUnlessPlaying = true

-- Protect blocks that make up the arenas
AutoProtectArenaBlocks = true

-- //////////////////////////////////////////////////////////////////////////////////
-- These options are able to be used with the Raspberry Pi with no performance impact
-- //////////////////////////////////////////////////////////////////////////////////

-- Allows players to join the queue more than once and won't kick them out of the arena even if they are the only ones
-- occupying it.  This option is used to test the features of arenas and queues and stuff
DebugMode = false

-- Disallows PvP outside of arenas
PeacefulMode = false

-- Defines the distance that the players in spectate can move before being teleported back to the initial spectate point
SpectateMoveRadius = 8

-- ////////////////////
-- End of inline config
-- ////////////////////

PLUGIN = nil
PluginFolder = ""
ConfigFolder = ""
local clock = os.clock

local Name = "MCArena Release"
local VersionMajor = 1
local VersionMinor = 2

function Initialize(Plugin)
	Plugin:SetName(Name)
	Plugin:SetVersion(VersionMajor)

	PluginFolder = Plugin:GetLocalFolder()
	ConfigFolder = PluginFolder .. "/config"
	
	if cFile:IsFolder(ConfigFolder) == false then
		LOG("Config folder does not exist!  Creating directory 'config'...")
		cFile:CreateFolder(ConfigFolder)
	end

	-- Load config
	
	-- Set up random number generator
	math.randomseed(os.time())
	
	-- Hooks here you scrub...
	
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakBlock)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_PLACING_BLOCK, OnPlayerPlaceBlock)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_TICK, OnWorldTick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnPlayerLeftClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
	cPluginManager:AddHook(cPluginManager.HOOK_KILLING, OnKilling)
	cPluginManager:AddHook(cPluginManager.HOOK_EXECUTE_COMMAND, OnExecuteCommand)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawned)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)
	cPluginManager:AddHook(cPluginManager.HOOK_EXPLODING, OnExploding)
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)

	-- Seems to be broken
	--cPluginManager:AddHook(cPluginManager.HOOK_ENTITY_TELEPORT, OnEntityTeleport)
	
	-- Conditional hooks here you scrub...

	if KeepPlayersOutUnlessPlaying == true then cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving) end

	-- The commands are already bound in the Info.lua file.  Refer to there if needed.  Full documentation also exists there.

	-- Continue
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()

	LoadArenas()
	LoadKits()

	LOG("Initialized " .. Plugin:GetName() .. " v" .. VersionMajor .. "." .. VersionMinor)
	return true
end

-- Self-explanatory
function OnDisable()
	LOG("Disabled " .. Name .. "!")
end

function CommandManager(Split, Player)
	if Split[2] == "join" then PlayerJoinArena(Split, Player)
	elseif Split[2] == "spec" then PlayerSpectateArena(Split, Player)
	elseif Split[2] == "sleave" then LeaveSpectate(Split, Player)
	elseif Split[2] == "qleave" then LeaveQueue(Split, Player)
	elseif Split[2] == "list" then ListArenas(Split, Player)
	elseif Split[2] == "listkits" then ListKits(Split, Player)
	elseif Split[2] == "create" then CreateArena(Split, Player)
	elseif Split[2] == "wand" then GiveWand(Split, Player)
	else Player:SendMessage(cChatColor.Gold .. "/mca - join, spec, sleave, qleave, list, listkits, create, wand")	
	end
	return true
end

-- Put Player in the arena and add him to the queue
function PlayerJoinArena(Split, Player)
	if GetNumberOfArenas() <= 0 then
		Player:SendMessage(cChatColor.Yellow .. "No arenas exist!  Contact an admin to set one up.")
		return true
	end

	if IsPlayerInSpectate(Player) == true then
		Player:SendMessageInfo(cChatColor.Rose .. "You can't enter queue while in spectate mode!  Use /mca sleave to exit.")
		return true
	end

	if IsPlayerInQueue(Player) == true then
		if DebugMode == false then		
			Player:SendMessageInfo(cChatColor.Gold .. "You're already in the queue!")
			return true
		end
	end

	-- No arena defined
	if Split[3] == nil then
		Player:SendMessageInfo(cChatColor.Yellow .. "Please choose a kit!  Use '/mca listkits' for avaliable kits")
		return true
	end

	if DoesKitExist(Split[3]) == false then
		Player:SendMessageInfo(cChatColor.Yellow .. "That kit does not exist!  Use /mca listkits to print a list of avaliable kits!")
		return true
	end

	local NewPlayerData = {}
	NewPlayerData.Name = Player:GetName()
	NewPlayerData.Kit = Split[3]

	AddPlayerToQueue(NewPlayerData)

	Player:SendMessageSuccess(cChatColor.LightBlue .. "You have joined the queue!")

	return true
end

-- List arenas
function ListArenas(Split, Player)
	Player:SendMessage(cChatColor.LightBlue .. "Arenas: ")
	for _, k in pairs(Arenas) do		
		Player:SendMessage(k:GetName())
	end
	return true
end

-- List kits
function ListKits(Split, Player)
	Player:SendMessage(cChatColor.Green .. "Kits: ")
	for _, k in pairs(Kits) do		
		Player:SendMessage(k:GetName())
	end
	return true
end

-- Put Player in spectate
function PlayerSpectateArena(Split, Player)
	if Split[3] == nil then
		Player:SendMessageInfo(cChatColor.LightGreen .. "You have to specify an arena!")
		return true
	end	

	if DoesArenaExist(Split[3]) == false then
		Player:SendMessageInfo(cChatColor.Yellow .. "That arena does not exist!  Use '/mca list' for a list of arenas.")
		return true
	end

	if IsPlayerInSpectate(Player) == false then
		local s_Player = SPlayer:new()
		s_Player.Name = Player:GetName()
		s_Player.PreviousPosition = CopyVector(Player:GetPosition())
		s_Player.Arena = Split[3]
		s_Player.PreviousWorld = Player:GetWorld():GetName()
		table.insert(PlayersInSpectate, s_Player)
	end

	Player:SendMessageInfo(cChatColor.LightBlue .. "Spectating arena " .. cChatColor.LightGreen .. Split[3])
	local SpecCoords = GetArenaByName(Split[3]):GetSpecCoords()
	Player:MoveToWorld(GetArenaByName(Split[3]):GetWorld())
	Player:TeleportToCoords(SpecCoords.x, SpecCoords.y + 1, SpecCoords.z)
	Player:SetCanFly(true)
	return true
end

function LeaveSpectate(Split, Player)
	if IsPlayerInSpectate(Player) == true then
		for _, k in pairs(PlayersInSpectate) do
			if Player:GetName() == k.Name then
				Player:MoveToWorld(k.PreviousWorld)
				local tp = k.PreviousPosition
				Player:TeleportToCoords(tp.x, tp.y, tp.z)
				table.remove(PlayersInSpectate, _)
				Player:SendMessage(cChatColor.LightGreen .. "Leaving spectator mode")
				Player:SetCanFly(false)
				return true
			end
		end
	end
	Player:SendMessageInfo(cChatColor.Purple .. "You're not currently spectating!")
	return true
end

function LeaveQueue(Split, Player)
	if IsPlayerInQueue(Player) == true then
		for _, k in pairs(PlayerQueue) do
			if k.Name == Player:GetName() then
				table.remove(PlayerQueue, _)
				Player:SendMessageInfo(cChatColor.Yellow .. "You left the queue.")
				return true
			end
		end
	end
	Player:SendMessageInfo(cChatColor.LightBlue .. "You're not currently in the queue!")
	return true
end
