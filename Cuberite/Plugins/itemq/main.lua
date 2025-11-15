PLUGIN = nil

function Initialize(Plugin)
	PLUGIN = Plugin
	Plugin:SetName("MenuPlugin")
	Plugin:SetVersion(1)

	cPluginManager:BindCommand("/menu", "menu", OnCommand, " - Open the custom menu")
	LOG("MenuPlugin initialized!")
	return true
end

function OnDisable()
	LOG("MenuPlugin disabled")
end

function OnCommand(Split, Player)
	OpenMenu(Player)
	return true
end

function OpenMenu(Player)
	-- Create a chest-like inventory window (27 slots)
	local Window = cInventoryWindow("Custom Menu", 27)

	-- Fill first row with diamonds
	for i = 0, 8 do
		Window:SetSlot(i, cItem(E_ITEM_DIAMOND, 1))
	end

	-- Hook when a slot is changed
	function Window:OnSlotChanged(SlotNum)
		local Slot = self:GetSlot(SlotNum)
		if Slot and Slot.m_ItemType == E_ITEM_DIAMOND then
			Player:SendMessage(cChatColor.LightPurple .. "You clicked a diamond!")
			Player:GetWorld():GetServer():ExecuteCommand("say " .. Player:GetName() .. " clicked a diamond!")
		end
	end

	Player:SendWindow(Window)
end
