PlayerSelection = {}
PlayersInSpectate = {}

-- If Player is in survival, do not let him break blocks
function OnPlayerBreakBlock(Player, X, Y, Z)
	for _, k in pairs(Arenas) do
		if k.BoundingBox:IsInside(Vector3d(X, Y, Z)) == true and
		AutoProtectArenaBlocks == true and
		DoesPlayerHavePermissionToEdit(Player) == false and
		k:GetWorld() == Player:GetWorld():GetName() then
			Player:SendMessageWarning(cChatColor.Red .. "You do not have permission to edit arenas!")
			return true
		end
	end

	if Player:GetGameMode() == gmSurvival and
	IsPlayerInArena(Player) == true then
		return true
	else
		return false
	end
end

function OnWorldTick(World, TimeDelta)
	if World:IsWeatherSunny() == false then
		World:SetWeather(wSunny)
	end

	for _, CurrentArena in pairs(Arenas) do
		CurrentArena:KeepPlayersInBounds()
	end

	if GetNumberInQueue() > 1 and QueueWaiting == false then
		QueueWaiting = true
		BroadcastToQueue(cChatColor.LightPurple .. "Other players have joined the queue, waiting for more...")		
		World:ScheduleTask(300, function()
			if GetNumberInQueue() <= 1 then
				BroadcastToQueue(cChatColor.LightPurple .. "A player has left the queue, waiting for more players...")
				QueueWaiting = false
				return false
			end
			if DumpQueueToArena() == false then		
				BroadcastToQueue(cChatColor.LightPurple .. "No arenas are avaliable, waiting...")
				QueueWaiting = false
			else
				BroadcastToQueue(cChatColor.LightPurple .. "You have been matched!")
				QueueWaiting = false
			end
		end
		)
	end
end

function OnPlayerMoving(Player, OldPos, NewPos)
	if IsPlayerInSpectate(Player) == true then
		local SArena = ""		
		for _, k in pairs(PlayersInSpectate) do
			if k.Name == Player:GetName() then
				SArena = k.Arena
			end
		end
		local SpecPos = Vector3d(GetArenaByName(SArena):GetSpecCoords())
		if distance(NewPos, SpecPos) > SpectateMoveRadius then
			Player:TeleportToCoords(SpecPos.x, SpecPos.y + 1, SpecPos.z)
			Player:SendMessageInfo(cChatColor.Rose .. "You have wandered off too far!")
		end
	end	

	for _, k in pairs(Arenas) do
		if k.BoundingBox:IsInside(NewPos) == true and
		IsPlayerInArena(Player) == false and
		DoesPlayerHavePermissionToEdit(Player) == false and
		k:GetWorld() == Player:GetWorld():GetName() then
			Player:SendMessageWarning(cChatColor.Red .. "You cannot enter arenas!")
			return true
		end
	end
	return false
end

-- If Player is in survival, do not let him place blocks
function OnPlayerPlaceBlock(Player, X, Y, Z)
	for _, k in pairs(Arenas) do
		if k.BoundingBox:IsInside(Vector3d(X, Y, Z)) == true and
		AutoProtectArenaBlocks == true and
		DoesPlayerHavePermissionToEdit(Player) == false and
		k:GetWorld() == Player:GetWorld():GetName() then
			Player:SendMessageWarning(cChatColor.Red .. "You do not have permission to edit arenas!")
			return true
		end
	end	

	if Player:GetGameMode() == gmSurvival and
	IsPlayerInArena(Player) == true then
		return true
	else
		return false
	end
end

function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, Action)
	if IsPlayerInSpectate(Player) == true then
		return true
	end		

	if DoesPlayerHavePermissionToEdit(Player) == false then
		return false
	end	

	if PlayerSelection[Player:GetName()] == nil then
		PlayerSelection[Player:GetName()] = {}
	end

	if Player:IsCrouched() == true and
	Player:GetInventory():GetEquippedItem().m_ItemType == E_ITEM_GOLD_PICKAXE then
		PlayerSelection[Player:GetName()]["spec"] = Vector3i(BlockX, BlockY, BlockZ)
		Player:SendMessageInfo("Selected spectator position: " .. BlockX .. ", " .. BlockY .. ", " .. BlockZ)
		return true
	elseif Player:GetInventory():GetEquippedItem().m_ItemType == E_ITEM_GOLD_PICKAXE then
		PlayerSelection[Player:GetName()]["select1"] = Vector3i(BlockX, BlockY, BlockZ)
		Player:SendMessageInfo("Selected first position: " .. BlockX .. ", " .. BlockY .. ", " .. BlockZ)
		return true
	end
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, Action)
	if IsPlayerInSpectate(Player) == true then
		return true
	end		

	if DoesPlayerHavePermissionToEdit(Player) == false then
		return false
	end	

	if BlockFace == BLOCK_FACE_NONE then
		return true	
	end

	if PlayerSelection[Player:GetName()] == nil then
		PlayerSelection[Player:GetName()] = {}
	end

	if Player:IsCrouched() == true and
	Player:GetInventory():GetEquippedItem().m_ItemType == E_ITEM_GOLD_PICKAXE then
		PlayerSelection[Player:GetName()]["spec"] = Vector3i(BlockX, BlockY, BlockZ)
		Player:SendMessageInfo("Selected spectator position: " .. BlockX .. ", " .. BlockY .. ", " .. BlockZ)
		return true
	elseif Player:GetInventory():GetEquippedItem().m_ItemType == E_ITEM_GOLD_PICKAXE then
		PlayerSelection[Player:GetName()]["select2"] = Vector3i(BlockX, BlockY, BlockZ)
		Player:SendMessageInfo("Selected second position: " .. BlockX .. ", " .. BlockY .. ", " .. BlockZ)
		return true
	end
end

function OnTakeDamage(Entity, TDI)
	if PeacefulMode == true then
		if Entity:IsPlayer() == true then
			if TDI.Attacker ~= nil then
				if TDI.Attacker:IsPlayer() == true then
					if IsPlayerInArena(Entity) == true then
						return false
					else
						return true
					end
				end
			end
		end
	end

	if Entity:IsPlayer() == true then
		if IsPlayerInSpectate(Entity) == true then
			TDI.FinalDamage = 0
			return true
		end
	end	

	if TDI.Attacker ~= nil then
		if TDI.Attacker:IsPlayer() == true then
			if IsPlayerInSpectate(TDI.Attacker) == true then
				TDI.FinalDamage = 0
				return true
			end
		end
	end

	if Entity:IsPlayer() == true and TDI.Attacker ~= nil then
		if TDI.Attacker:IsPlayer() == true then
			if IsPlayerInArena(Entity) == true and IsPlayerInArena(TDI.Attacker) == false then
				TDI.Attacker:SendMessageWarn("You cannot interfere with arena battles!")
				return true
			end
		end
	end
	return false
end

function OnKilling(Victim, Killer)
	if Victim:IsPlayer() == true then
		if IsPlayerInArena(Victim) == true then
			RemovePlayer(Victim)
		elseif IsPlayerInQueue(Victim) == true then
			for n, k in pairs(PlayerQueue) do
				if k.Name == Victim:GetName() then
					table.remove(PlayerQueue, n)
					Victim:SendMessageInfo(cChatColor.DarkPurple .. "You've been removed from the queue!")
				end
			end
		end
	end
end

function OnExecuteCommand(Player, Command)
	if Player ~= nil then	
		if IsPlayerInArena(Player) == true then
			Player:SendMessageWarning(cChatColor.Red .. "You may not use commands during combat!")		
			LOG("Explanation: Player " .. Player:GetName() .. " is not allowed to execute commands while in an arena.")
			return true
		end
	end
end

function OnPlayerDestroyed(Player)
	for _, k in pairs(Arenas) do
		for n, l in pairs(k.Players) do
			if Player:GetName() == l.Name then
				table.remove(k.Players, n)
				LOG("Player " .. Player:GetName() .. " has logged out during combat!, inventory items were lost!")
				Player:GetInventory():Clear()
				return true
			end
		end
	end

	for _, k in pairs(PlayersInSpectate) do
		if Player:GetName() == k.Name then
			table.remove(PlayersInSpectate, _)
			LOG("Player " .. Player:GetName() .. " has logged out in spectate mode!")
			return true
		end
	end
	PlayerSelection[Player:GetName()] = nil
end

function OnPlayerSpawned(Player)
	for _, k in pairs(Arenas) do
		if k.BoundingBox:IsInside(Player:GetPosition()) == true and
		k:GetWorld() == Player:GetWorld():GetName() then
			Player:MoveToWorld(cRoot:Get():GetDefaultWorld():GetName(), false)

			Player:TeleportToCoords(cRoot:Get():GetDefaultWorld():GetSpawnX(), 
				cRoot:Get():GetDefaultWorld():GetSpawnY(), 
				cRoot:Get():GetDefaultWorld():GetSpawnZ())

			Player:SendMessageWarning(cChatColor.Red .. "You cannot relog in an arena!")
		end
		if distance(k:GetSpecCoords(), Player:GetPosition()) <= SpectateMoveRadius then
			Player:MoveToWorld(cRoot:Get():GetDefaultWorld():GetName(), false)

			Player:TeleportToCoords(cRoot:Get():GetDefaultWorld():GetSpawnX(), 
				cRoot:Get():GetDefaultWorld():GetSpawnY(), 
				cRoot:Get():GetDefaultWorld():GetSpawnZ())

			if Player:GetGameMode() == 0 then
				Player:SetCanFly(false)
			end

			Player:SendMessageWarning(cChatColor.Rose .. "You cannot relog in spectate mode!")
		end
	end
end

function OnExploding(World, ExplosionSize, CanCauseFire, X, Y, Z, Source, SourceData)
	for _, k in pairs(Arenas) do
		if k.BoundingBox:IsInside(Vector3d(X, Y, Z)) == true and
		AutoProtectArenaBlocks == true and
		k:GetWorld() == World:GetName() then
			return true
		end
	end
end
