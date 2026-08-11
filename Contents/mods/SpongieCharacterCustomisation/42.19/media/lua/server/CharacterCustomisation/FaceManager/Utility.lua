
	-- ----------------------------------------------------------------------
	-- -- METHODS FOR THE SERVER TO MANAGE DATA AND CUSTOMISATION ITEMS
	-- ----------------------------------------------------------------------
	
if isClient() then return end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")


	-- -----------------------------------------
	-- -- UTILITY
	-- -----------------------------------------
function FaceManager_Server.AddItem(player, id, texture)
	local item = FaceManager_Shared.CreateItem(id, texture)
	if not item then return end

	FaceManager_Server.SyncBloodOnNewItem(player, item)

	player:getInventory():AddItem(item)
	sendAddItemToContainer(player:getInventory(), item)

	player:setWornItem(item:getBodyLocation(), item)
    sendClothing(player, item:getBodyLocation(), item)

	return item
end
function FaceManager_Server.RemoveItem(player, item)
	-- if not item then return end

	-- this doesnt work when the bodylocation is set to multi item
	-- player:removeWornItem(item)
	
	-- this works but doesnt send a syncpacket in mp so it needs a workaround to sync
	player:getWornItems():remove(item)

	player:getInventory():Remove(item)
	sendRemoveItemFromContainer(player:getInventory(), item)
end

function FaceManager_Server.OnClothingUpdated(player)
	if isServer() then
		sendServerCommand(player, "SPNCC", "OnClothingUpdated", {})
	else
		FaceManager_Shared.OnClothingUpdated(player)
	end
end

function FaceManager_Server.SyncRemoveCustomisation(player)
	if not isServer() then return end

	-- IsoPlayer:removeWornItem does not work with multi item bodylocations so they have to be removed from wornitems manually
	-- Unfortunately the SyncClothing packets are sent in IsoPlayer:removeWornItem so we need to add a blank item to force sync in mp

	-- print("MULTIPLAYER ONLY setting blank item")
	local blank = player:getWornItem(SPNCC.ItemBodyLocation.Blank)
	if not blank then 
		blank = FaceManager_Server.AddItem(player, "Base.SPNCharCustom_Blank", 0)
	end
	player:removeWornItem(blank)
	player:setWornItem(SPNCC.ItemBodyLocation.Blank, blank)
end

function FaceManager_Server.RemoveItems(player, items)
	if not items then return end
	for i, item in pairs(items) do
		FaceManager_Server.RemoveItem(player, item)
	end
	FaceManager_Server.SyncRemoveCustomisation(player)
end
function FaceManager_Server.RemoveItemsWithTag(player, tag)
	local items = FaceManager_Shared.GetInventoryItemsWithTag(player, tag);
	FaceManager_Server.RemoveItems(player, items)
end
function FaceManager_Server.RemoveWornItemsWithTag(player, tag)
	local items = FaceManager_Shared.GetWornItemsWithTag(player, tag);
	FaceManager_Server.RemoveItems(player, items)
end
function FaceManager_Server.RemoveItemAtBodyLocation(player, location)
	local item = player:getWornItem(location)
	FaceManager_Server.RemoveItem(player, item)
end
