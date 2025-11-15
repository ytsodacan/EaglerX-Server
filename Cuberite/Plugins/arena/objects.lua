-- Arena object that resides in the Arenas table
-- Represents the arena data loaded from the arenas.ini file
Arena = {
	Name = "",
	BoundingBox = nil,
	NumberOfPlayers = 0,
	SpectatorWarp = Vector3f(),
	Center = Vector3f(),
	World = "",
	Players = {}
}

-- Temporarily holds the Player's previous game data such as:
-- health, XP, hunger, previous position.
-- APlayer = ArenaPlayer
APlayer = {
	PreviousPosition = Vector3d(),
	PreviousArmor = {},
	PreviousInventory = {},
	PreviousHotbar = {},
	PreviousHealth = 0,
	PreviousHunger = 0,
	PreviousXP = 0,
	KitName = "",
	PreviousWorld = ""
}

-- SPlayer = SpectatingPlayer
SPlayer = {
	Name = "",
	PreviousPosition = Vector3d(),
	Arena = "",
	PreviousWorld = ""
}

-- A predefined "inventory" that is given to the player upon joining an arena
Kit = {
	Name = "",
	Items = {}
}

function Arena:new()
	local o = {}
	setmetatable(o, Arena)
	self.__index = self
	o.Players = {}
	setmetatable(o.Players, Arena.Players)
	self.Players.__index = self.Players
	return o
end

function APlayer:new()
	local o = {}
	setmetatable(o, APlayer)
	self.__index = self
	o.PreviousArmor = {}
	setmetatable(o.PreviousArmor, APlayer.PreviousArmor)
	self.PreviousArmor.__index = self.PreviousArmor
	o.PreviousInventory = {}
	setmetatable(o.PreviousInventory, APlayer.PreviousInventory)
	self.PreviousInventory.__index = self.PreviousInventory
	o.PreviousHotbar = {}
	setmetatable(o.PreviousHotbar, APlayer.PreviousHotbar)
	self.PreviousHotbar.__index = self.PreviousHotbar
	return o
end

function SPlayer:new()
	local o = {}
	setmetatable(o, APlayer)
	self.__index = self
	return o
end

function Kit:new()
	local o = {}
	setmetatable(o, Kit)
	self.__index = self
	o.Items = {}
	setmetatable(o.Items, Kit.Items)
	self.Items.__index = self.Items
	return o
end

function Arena:SetBoundingBox(Min, Max)
	-- We want all of the values of the minimum point to be smaller so we don't run into any boundary problems	
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
	
	self.Center = Vector3f((Min.x + Max.x) / 2, (Min.y + Max.y) / 2, (Min.z + Max.z) / 2)
	self.BoundingBox = cBoundingBox(Min.x, Max.x, Min.y, Max.y, Min.z, Max.z)
end

function Arena:SetSpectatorWarp(Warp)
	self.SpectatorWarp = Warp
end

function Arena:GetSpecCoords()
	return self.SpectatorWarp
end

function Arena:SetName(NewName)
	self.Name = NewName
end

function Arena:SetWorld(WorldName)
	self.World = WorldName
end

function Arena:GetWorld()
	return self.World
end

function Arena:KeepPlayersInBounds()
	function ContainPlayer(Player)
		if Player:GetWorld():GetName() ~= self:GetWorld() then
			Player:MoveToWorld(self:GetWorld(), false)
		end	
		if self.BoundingBox:IsInside(Player:GetPosition()) == false then
			Player:SetSpeed((Vector3d(self:GetCenter()) - Player:GetPosition()) * 2)
		end
	end

	for _, a_Player in pairs(self.Players) do
		cRoot:Get():FindAndDoWithPlayer(a_Player.Name, ContainPlayer)
	end

	if self:GetNumberOfPlayers() <= 1 - (DebugMode and 1 or 0) then
		for _, k in pairs(self.Players) do
			cRoot:Get():FindAndDoWithPlayer(k.Name, function(Player)
				Player:SendMessageSuccess(cChatColor.Gold .. "You have claimed victory!")
				RemovePlayer(Player)
			end
			)
		end
		self.Players = {}
	end
end

function Arena:AddPlayer(PlayerData)
	for _, a_PlayerName in pairs(self.Players) do
		if PlayerData.Name == a_PlayerName.Name then
			return true
		end
	end
	local a_Player = APlayer:new()
	cRoot:Get():FindAndDoWithPlayer(PlayerData.Name, function(Player)
		a_Player:CopyInfo(Player)
	end
	)
	a_Player:AssignKit(PlayerData.Kit)	
	table.insert(self.Players, a_Player)

	cRoot:Get():FindAndDoWithPlayer(PlayerData.Name, function(Player)
		-- Set gamemode and reset stats
		Player:SetGameMode(gmSurvival)
		Player:Heal(1337)
		Player:Feed(20, 1337)
		Player:SetCurrentExperience(0)

		local X, Z
		
		local attempts = 0
		local vPos = Vector3d()

		repeat
			local X = math.random(self:GetCenter().x - 4, self:GetCenter().x + 4)
			local Z = math.random(self:GetCenter().z - 4, self:GetCenter().z + 4)

			local bool, Y = Player:GetWorld():TryGetHeight(X, Z)
			vPos = Vector3d(X, Y, Z)
			attempts = attempts + 1
		until
			self.BoundingBox:IsInside(vPos) == true or attempts > 64 

		-- If the world that the arena resides in is NOT loaded, cancel and remove the player.
		if cRoot:Get():GetWorld(self:GetWorld()) == nil then
			RemovePlayer(Player)
			return false
		end

		if Player:GetWorld():GetName() ~= self:GetWorld() then
			Player:MoveToWorld(self:GetWorld(), false)
		end

		if attempts > 64 then
			Player:TeleportToCoords(self:GetCenter().x, self:GetCenter().y, self:GetCenter().z)
		else
			Player:TeleportToCoords(vPos.x, vPos.y, vPos.z)
		end

		-- Give assigned kit
		GiveKit(Player, PlayerData.Kit)
	end
	)
end

function Arena:GetCenter()
	return self.Center
end

function Arena:GetName()
	return self.Name
end

function Arena:IsAvaliable()
	if self.Players[1] ~= nil then		
		return false
	end
	return true
end

function APlayer:CopyInfo(Player)
	self.Name = Player:GetName()
	self.PreviousPosition = CopyVector(Player:GetPosition())
	self.PreviousHealth = Player:GetHealth()
	self.PreviousHunger = Player:GetFoodLevel()
	self.PreviousXP = Player:GetCurrentXp()

	for c = 0, 3 do
		self.PreviousArmor[c] = CopycItem(Player:GetInventory():GetArmorSlot(c))
	end
	for d = 0, 26 do
		self.PreviousInventory[d] = CopycItem(Player:GetInventory():GetInventorySlot(d))
	end
	for e = 0, 8 do
		self.PreviousHotbar[e] = CopycItem(Player:GetInventory():GetHotbarSlot(e))
	end

	self.PreviousWorld = Player:GetWorld():GetName()
end

function APlayer:RestoreInfo(Player)
	Player:TeleportToCoords(self.PreviousPosition.x, self.PreviousPosition.y, self.PreviousPosition.z)
	Player:SetHealth(self.PreviousHealth)
	Player:SetFoodLevel(self.PreviousHunger)
	Player:SetCurrentExperience(self.PreviousXP)

	for c = 0, 3 do
		Player:GetInventory():SetArmorSlot(c, self.PreviousArmor[c])
	end
	for d = 0, 26 do
		Player:GetInventory():SetInventorySlot(d, self.PreviousInventory[d])
	end
	for e = 0, 8 do
		Player:GetInventory():SetHotbarSlot(e, self.PreviousHotbar[e])
	end
	if Player:GetWorld():GetName() ~= self.PreviousWorld then
		Player:MoveToWorld(self.PreviousWorld, false)
	end

	Player:AddEntityEffect(12, 12, 5, 5)
	Player:StopBurning()
end

function APlayer:AssignKit(KitName)
	if DoesKitExist(KitName) then	
		self.KitName = KitName
	end
end

function APlayer:GetKit()
	return self.KitName
end

function Arena:GetNumberOfPlayers()
	return #self.Players
end

function Kit:SetName(NewName)
	self.Name = NewName
end

function Kit:GetName()
	return self.Name
end

function Kit:AddItem(ItemID)
	table.insert(self.Items, ItemID)
end
