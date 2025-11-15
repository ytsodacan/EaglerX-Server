ArenaIniFile = cIniFile()
KitIniFile = cIniFile()

Arenas = {}
Kits = {}
Lobby = {}
PlayerQueue = {}

QueueWaiting = false

local ArenasFile = ""
local KitsFile = ""

function LoadArenas()
	ArenasFile = ConfigFolder .. "/arenas.ini"

	if ArenaIniFile:ReadFile(ArenasFile) == false then
		LOG("Arena config file does not exist or is empty, generating a new one")
		ArenaIniFile:WriteFile(ArenasFile)
	end

	for c = 0, ArenaIniFile:GetNumKeys() - 1 do
		if DoesArenaExist(ArenaIniFile:GetKeyName(c)) == false then
			local m_Arena = Arena:new()
			m_Arena:SetName(ArenaIniFile:GetKeyName(c))
			local Min = Vector3f()
				Min.x = ArenaIniFile:GetValueF(m_Arena.Name, "MinX")
				Min.y = ArenaIniFile:GetValueF(m_Arena.Name, "MinY")
				Min.z = ArenaIniFile:GetValueF(m_Arena.Name, "MinZ")
			local Max = Vector3f()
				Max.x = ArenaIniFile:GetValueF(m_Arena.Name, "MaxX")
				Max.y = ArenaIniFile:GetValueF(m_Arena.Name, "MaxY")
				Max.z = ArenaIniFile:GetValueF(m_Arena.Name, "MaxZ")
			local SpecWarp = Vector3f()
				SpecWarp.x = ArenaIniFile:GetValueF(m_Arena.Name, "SpecX")
				SpecWarp.y = ArenaIniFile:GetValueF(m_Arena.Name, "SpecY")
				SpecWarp.z = ArenaIniFile:GetValueF(m_Arena.Name, "SpecZ")
			local w = ArenaIniFile:GetValue(m_Arena.Name, "World")	
			m_Arena:SetWorld(w)
			m_Arena:SetBoundingBox(Min, Max)
			m_Arena:SetSpectatorWarp(SpecWarp)
			table.insert(Arenas, m_Arena)
		end
	end
end

function LoadKits()
	KitsFile = ConfigFolder .. "/kits.ini"
	if KitIniFile:ReadFile(KitsFile) == false then
		LOG("Kit config file does not exist or is empty, generating a new one")
		-- If no kits exist, this function creates default kit
		KitIniFile:AddKeyName("default")
		KitIniFile:SetValueI("default", "item1", E_ITEM_DIAMOND_SWORD, true)
		KitIniFile:SetValueI("default", "amount1", 1, true)
		KitIniFile:WriteFile(KitsFile)
		-- End default kit
	end

	for c = 0, KitIniFile:GetNumKeys() - 1 do
		if DoesKitExist(KitIniFile:GetKeyName(c)) == false then
			local m_Kit = Kit:new()
			m_Kit:SetName(KitIniFile:GetKeyName(c))
			local NumOfItems = 0
			while KitIniFile:GetValueI(m_Kit:GetName(), "item" .. tostring(NumOfItems+1)) ~= 0 do NumOfItems = NumOfItems + 1 
				for i = 0, NumOfItems do
					local itemID = KitIniFile:GetValueI(m_Kit:GetName(), "item" .. tostring(i+1))
					local itemAmount = KitIniFile:GetValueI(m_Kit:GetName(), "amount" .. tostring(i+1))
					if itemAmount == 0 then
						itemAmount = 1
					end
					for c = 1, itemAmount do
						m_Kit:AddItem(itemID)
					end
				end
			end
			table.insert(Kits, m_Kit)
		end
	end
end

function CreateArena(Split, Player)
	if DoesPlayerHavePermissionToEdit(Player) == false then
		Player:SendMessageInfo("You do not have permission to do that!")
		return true
	end	

	if Split[3] == nil then
		Player:SendMessageInfo("Usage: /mca create <name>")
		return true
	end

	ArenaIniFile:Clear()
	ArenaIniFile:ReadFile(ArenasFile)

	ArenaIniFile:DeleteKey(Split[3])
	ArenaIniFile:AddKeyName(Split[3])
	
	if PlayerSelection[Player:GetName()] == nil then
		Player:SendMessageInfo(cChatColor.Rose .. "Points pos1, pos2 or specpoint were not selected, please reselect the region.")
		return true
	end

	if PlayerSelection[Player:GetName()]["select1"] == nil or
	PlayerSelection[Player:GetName()]["select2"] == nil or
	PlayerSelection[Player:GetName()]["spec"] == nil then
		Player:SendMessageInfo(cChatColor.Rose .. "Points pos1, pos2 or specpoint were not selected, please reselect the region.")
		return true
	end

	local Min = PlayerSelection[Player:GetName()]["select1"]
	local Max = PlayerSelection[Player:GetName()]["select2"]
	local Spec = PlayerSelection[Player:GetName()]["spec"]

	if Min.x > Max.x then
		local s = Max.x
		Max.x = Min.x
		Min.x = s
	end
	if Min.y > Max.y then
		local t = Max.y
		Max.y = Min.y
		Min.y = t
	end
	if Min.z > Max.z then
		local u = Max.z
		Max.z = Min.z
		Min.z = u
	end

	-- Check if the spectate point is in the arena.  We don't want that.
	local CheckBox = cBoundingBox(Min.x, Max.x, Min.y, Max.y, Min.z, Max.z)
	if CheckBox:IsInside(Vector3d(Spec)) then
		Player:SendMessageInfo(cChatColor.Rose .. "The spectate teleport cannot be inside the arena!  Please reselect your region.")
		return true	
	end

	ArenaIniFile:SetValue(Split[3], "MinX", Min.x)
	ArenaIniFile:SetValue(Split[3], "MinY", Min.y)
	ArenaIniFile:SetValue(Split[3], "MinZ", Min.z)
	ArenaIniFile:SetValue(Split[3], "MaxX", Max.x)
	ArenaIniFile:SetValue(Split[3], "MaxY", Max.y)
	ArenaIniFile:SetValue(Split[3], "MaxZ", Max.z)
	ArenaIniFile:SetValue(Split[3], "SpecX", Spec.x)
	ArenaIniFile:SetValue(Split[3], "SpecY", Spec.y)
	ArenaIniFile:SetValue(Split[3], "SpecZ", Spec.z)
	ArenaIniFile:SetValue(Split[3], "World", Player:GetWorld():GetName())
	
	ArenaIniFile:WriteFile(ArenasFile)
	LoadArenas()
	
	Player:SendMessageSuccess("Arena successfully created/modified!")

	PlayerSelection[Player:GetName()] = nil

	return true
end

function AddPlayerToArena(ArenaName, PlayerData)
	for _, k in pairs(Arenas) do
		if k:GetName() == ArenaName then
			k:AddPlayer(PlayerData)
			return true
		end			
	end
end

function GetNumberOfArenas()	
	return #Arenas
end

-- Remove player from arena if is currently in one
function RemovePlayer(Player)
	for _, k in pairs(Arenas) do
		for n, l in pairs(k.Players) do
			if Player:GetName() == l.Name then
				table.remove(k.Players, n)
				l:RestoreInfo(Player)
				Player:SendMessage(cChatColor.Navy .. "You have been eliminated!")
			end
		end
	end
end

function IsAnArenaAvaliable()
	local a = false	
	for n, l in pairs(Arenas) do
		if l.Players[1] == nil then
			a = true
			break
		end
	end
	return a
end

-- Dump all waiting players into the same randomly chosen arena and empty queue line
function DumpQueueToArena()
	-- Are all arenas filled?		
	if IsAnArenaAvaliable() == false then
		return false
	end

	local ArenaSelection
	repeat ArenaSelection = math.random(1, GetNumberOfArenas()) until Arenas[ArenaSelection]:IsAvaliable() == true
	
	for _, k in pairs(PlayerQueue) do
		AddPlayerToArena(Arenas[ArenaSelection].Name, k)
	end
	PlayerQueue = {}
	return true
end
