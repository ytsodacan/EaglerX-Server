-- Is Player currently inside of an existing arena?
function IsPlayerInArena(Player)
	for _, k in pairs(Arenas) do
		for n, l in pairs(k.Players) do
			if Player:GetName() == l.Name then
				return true
			end
		end
	end
	return false
end

-- Is Player waiting to be matched?
function IsPlayerInQueue(Player)
	for _, k in pairs(PlayerQueue) do
		if k.Name == Player:GetName() then
			return true
		end
	end
	return false
end

-- Is Player in spectate mode?
function IsPlayerInSpectate(Player)
	for _, k in pairs(PlayersInSpectate) do
		if k.Name == Player:GetName() then
			return true
		end
	end
	return false
end

-- Sends message to everyone currently in queue
function BroadcastToQueue(String)
	for _, k in pairs(PlayerQueue) do
		cRoot:Get():FindAndDoWithPlayer(k.Name, function(Player)
			Player:SendMessage(String)
		end
		)
	end
end

-- Add player to waiting queue
function AddPlayerToQueue(PlayerDataTable)
	table.insert(PlayerQueue, PlayerDataTable)
end

-- Get number on players waiting in the queue
function GetNumberInQueue()
	return #PlayerQueue
end

function DoesArenaExist(ArenaName)
	for _, k in pairs(Arenas) do
		if k:GetName() == ArenaName then
			return true
		end
	end
	return false
end

function DoesKitExist(KitName)
	for _, k in pairs(Kits) do
		if k:GetName() == KitName then
			return true
		end
	end
	return false
end

-- Returns a reference to the requested arena object
function GetArenaByName(ArenaName)
	for _, k in pairs(Arenas) do
		if k:GetName() == ArenaName then
			return k
		end
	end
	return {}
end

-- Returns a reference of the requested kit object
function GetKitByName(KitName)
	for _, k in pairs(Kits) do
		if k:GetName() == KitName then
			for n, l in pairs(k.Items) do
			end			
			return k
		end
	end
	return {}
end

-- Give selected kit to player
function GiveKit(Player, KitName)	
	local a_Kit = GetKitByName(KitName)	
	Player:GetInventory():Clear()
	for _, k in pairs(Kits) do
		if k:GetName() == KitName then
			for n, l in pairs(a_Kit.Items) do
				-- If the kit has armor in it, auto-equip it				
				if IsHelmet(l) then
					Player:GetInventory():SetArmorSlot(0, cItem(l))
				elseif IsChestplate(l) then
					Player:GetInventory():SetArmorSlot(1, cItem(l))
				elseif IsLeggings(l) then
					Player:GetInventory():SetArmorSlot(2, cItem(l))
				elseif IsBoots(l) then
					Player:GetInventory():SetArmorSlot(3, cItem(l))
				else
					Player:GetInventory():AddItem(cItem(l))
				end
			end
		end
	end
end

function IsHelmet(ID)
	if ID == E_ITEM_DIAMOND_HELMET or
	ID == E_ITEM_GOLD_HELMET or
	ID == E_ITEM_IRON_HELMET or
	ID == E_ITEM_CHAIN_HELMET or
	ID == E_ITEM_LEATHER_HELMET then
		return true
	else
		return false
	end
end

function IsChestplate(ID)
	if ID == E_ITEM_DIAMOND_CHESTPLATE or
	ID == E_ITEM_GOLD_CHESTPLATE or
	ID == E_ITEM_IRON_CHESTPLATE or
	ID == E_ITEM_CHAIN_CHESTPLATE or
	ID == E_ITEM_LEATHER_CHESTPLATE then
		return true
	else
		return false
	end
end

function IsLeggings(ID)
	if ID == E_ITEM_DIAMOND_LEGGINGS or
	ID == E_ITEM_GOLD_LEGGINGS or
	ID == E_ITEM_IRON_LEGGINGS or
	ID == E_ITEM_CHAIN_LEGGINGS or
	ID == E_ITEM_LEATHER_LEGGINGS then
		return true
	else
		return false
	end
end

function IsBoots(ID)
	if ID == E_ITEM_DIAMOND_BOOTS or
	ID == E_ITEM_GOLD_BOOTS or
	ID == E_ITEM_IRON_BOOTS or
	ID == E_ITEM_CHAIN_BOOTS or
	ID == E_ITEM_LEATHER_BOOTS then
		return true
	else
		return false
	end
end

-- Not sure why I need this, but it seems to work...
function CopyVector(Vector)
	local t = {}
	t[1] = Vector.x
	t[2] = Vector.y
	t[3] = Vector.z
	local s = Vector3d(t[1], t[2], t[3])
	return s
end

-- Copy a table by values instead of by reference
function CopyTable(Table)
	local t = {}
	setmetatable(t, Table)
	self.__index = self
	return t
end

function CopycItem(Item)
	return cItem(Item)
end

function DoesPlayerHavePermissionToEdit(Player)
	local permissions = Player:GetPermissions()
	for _, k in pairs(permissions) do
		if k == "mcarena.edit" or
		k == "*" then
			return true
		end
	end
	return false
end

function GiveWand(Split, Player)
	if DoesPlayerHavePermissionToEdit(Player) == true then
		Player:SendMessageSuccess(cChatColor.LightBlue .. "You have been given the wand!")
		Player:GetInventory():AddItem(cItem(E_ITEM_GOLD_PICKAXE))
	else
		Player:SendMessageWarn(cChatColor.Rose .. "You do not have permission to do that!")
	end
	return true
end

function distance(Vector1, Vector2)
	return math.sqrt(((Vector2.x - Vector1.x)^2) + ((Vector2.y - Vector1.y)^2) + ((Vector2.z - Vector1.z)^2))
end
