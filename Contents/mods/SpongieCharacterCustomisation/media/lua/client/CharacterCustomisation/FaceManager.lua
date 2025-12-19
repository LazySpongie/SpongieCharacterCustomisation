
	-- ----------------------------------------------------------------------
	-- -- functions for adding and removing customisation items ingame
	-- ----------------------------------------------------------------------

local FM_Data = require("CharacterCustomisation/FM_Data")

local FaceManager = {}

	-- -------------------------------------
	-- -- MANAGE CUSTOMISATION ITEMS IN-GAME
	-- -------------------------------------
function FaceManager.SetPlayerFace(player, name, id, texture)
	FaceManager.RemovePlayerFace(player)
	if name == "DefaultFace" or id == "" then return nil end

	local item = FaceManager.AddItem(player, id, texture)

	player:getModData().SPNCharCustom.face = {name = name, id = id, texture = texture}
	return item
end
function FaceManager.RemovePlayerFace(player)
	local item = FaceManager.GetWornItemWithTag(player, "Face")
	FaceManager.RemoveItem(player, item)
	player:getModData().SPNCharCustom.face = {name = "DefaultFace", id = "", texture = 0}
end

function FaceManager.AddPlayerBodyDetail(player, name, id, texture, setData)

	local item = FaceManager.AddItem(player, id, texture)

	if setData then table.insert(player:getModData().SPNCharCustom.bodyDetails, {name = name, id = id, texture = texture}) end
	return item
end
function FaceManager.ClearPlayerBodyDetails(player)
	FaceManager.RemoveWornItemsWithTag(player, "BodyDetail")
	player:getModData().SPNCharCustom.bodyDetails = {}
end

function FaceManager.AddPlayerStubble(player, isBeard)
	local id = ""
	if isBeard then
		id = FM_Data.StubbleBeard
		player:getModData().SPNCharCustom.stubbleBeard = true
	else
		id = FM_Data.StubbleHead
		player:getModData().SPNCharCustom.stubbleHead = true
	end

	local item = FaceManager.AddItem(player, id, player:getHumanVisual():getSkinTextureIndex())
	return item
end
function FaceManager.RemovePlayerStubble(player, isBeard)
	local bodylocation
	if isBeard then
		bodylocation = "StubbleBeard"
		player:getModData().SPNCharCustom.stubbleBeard = false
	else
		bodylocation = "StubbleHead"
		player:getModData().SPNCharCustom.stubbleHead = false
	end
	local item = player:getWornItem(bodylocation)
	FaceManager.RemoveItem(player, item)
end
function FaceManager.AddPlayerBodyHair(player)
	local id = player:isFemale() and FM_Data.BodyHair[2] or FM_Data.BodyHair[1]

	local item = FaceManager.AddItem(player, id, player:getHumanVisual():getSkinTextureIndex())

	player:getModData().SPNCharCustom.bodyHair = true
	return item
end
function FaceManager.RemovePlayerBodyHair(player)
	local item = player:getWornItem("BodyHair")
	FaceManager.RemoveItem(player, item)
	player:getModData().SPNCharCustom.bodyHair = false
end
function FaceManager.AddPlayerMuscle(player, muscleLevel)
	if muscleLevel <= 0 then return nil end

	local id = player:isFemale() and FM_Data.Muscle[2] or FM_Data.Muscle[1]

	--get offset
	local textureOffset = 0
	if muscleLevel == 2 then textureOffset = 5 end
	local texture = player:getHumanVisual():getSkinTextureIndex() + textureOffset

	local item = FaceManager.AddItem(player, id, texture)
	return item
end
function FaceManager.RemovePlayerMuscle(player)
	local item = player:getWornItem("Muscle")
	FaceManager.RemoveItem(player, item)
end



	-- -----------------------------------------
	-- -- UTILITY
	-- -----------------------------------------
function FaceManager.CreateItem(type, texture)

	local item = InventoryItemFactory.CreateItem(type) --b41
	-- local item = instanceItem(type) --b42

	FaceManager.SetItemTexture(item, texture)
	return item
end
function FaceManager.SetItemTexture(item, texture)
	if item == nil then return end
	if item:getVisual() == nil then return end
	item:getVisual():setBaseTexture(texture)
	item:getVisual():setTextureChoice(texture)
end
function FaceManager.AddItem(player, id, texture)
	local item = FaceManager.CreateItem(id, texture)
	if not item then return end

	FaceManager.SyncBloodOnNewItem(player, item)

	player:getInventory():AddItem(item)
	-- sendAddItemToContainer(player:getInventory(), item) --b42

	player:setWornItem(item:getBodyLocation(), item)
    sendClothing(player, item:getBodyLocation(), item)
	
	return item
end

function FaceManager.AddItemsFromData(player)
	local hasAddedItem = false
	local data = player:getModData().SPNCharCustom
	if data.face.id ~= "DefaultFace" then
		hasAddedItem = true
		FaceManager.SetPlayerFace(player, data.face.name, data.face.id, data.face.texture)
	end
	if data.bodyDetails ~= nil then
		hasAddedItem = true
		for i, v in pairs(data.bodyDetails) do
			FaceManager.AddPlayerBodyDetail(player, v.name, v.id, v.texture, false)
		end
	end
	if data.stubbleBeard then
		hasAddedItem = true
		FaceManager.AddPlayerStubble(player, true)
	end
	if data.stubbleHead then
		hasAddedItem = true
		FaceManager.AddPlayerStubble(player, false)
	end
	if data.bodyHair then
		hasAddedItem = true
		FaceManager.AddPlayerBodyHair(player)
	end
	return hasAddedItem
end

function FaceManager.RemoveItem(player, item)
	if not item then return end
	player:removeWornItem(item)
	player:getInventory():Remove(item)
	-- sendRemoveItemFromContainer(player:getInventory(), item) --b42
end
function FaceManager.RemoveItems(player, items)
	if not items then return end
	for i, item in ipairs(items) do
		FaceManager.RemoveItem(player, item)
	end
end
function FaceManager.RemoveItemsWithTag(player, tag)
	local items = FaceManager.GetInventoryItemsWithTag(player, tag);
	FaceManager.RemoveItems(player, items)
end
function FaceManager.RemoveWornItemsWithTag(player, tag)
	local items = FaceManager.GetWornItemsWithTag(player, tag);
	FaceManager.RemoveItems(player, items)
end

	-- -----------------------------------------
	-- -- GETTERS
	-- -----------------------------------------
function FaceManager.GetWornPlayerFace(player)
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag("Face") then return item end
    end
    return nil
end
function FaceManager.GetWornItemsWithTag(player, tag)
	local items = {}
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(tag) then table.insert(items, item) end
    end
	return items
end
function FaceManager.GetWornItem(player, bodylocation)
    return player:getWornItem(bodylocation)
end
function FaceManager.GetWornItemWithTag(player, tag)
    for i=0, player:getWornItems():size()-1 do
        local item = player:getWornItems():getItemByIndex(i)
        if item:hasTag(tag) then return item end
    end
	return nil
end
function FaceManager.GetInventoryItemsWithTag(player, tag)
	local items = {}
	player:getInventory():getAllTagEval(tag, function(item) table.insert(items, item) end)
	return items
end


return FaceManager