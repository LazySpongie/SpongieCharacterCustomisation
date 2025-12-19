
	-- ----------------------------------------------------------------------
	-- -- Methods for the server to add and remove customisation items
	-- ----------------------------------------------------------------------


local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
local SPNCC_Data = require("CharacterCustomisation/SPNCC_Data")

local FaceManager_Server = {}

FaceManager_Server.modversion = 2

	-- -------------------------------------
	-- -- MANAGE CUSTOMISATION ITEMS IN-GAME
	-- -------------------------------------
function FaceManager_Server.SetPlayerFace(player, name, id, texture, sendData)
	FaceManager_Server.RemovePlayerFace(player, false)
	if name == "DefaultFace" or id == "" then return nil end

	local item = FaceManager_Server.AddItem(player, id, texture)

	FaceManager_Server.SetDataValue(player, "face", {name = name, id = id, texture = texture}, sendData)
	return item
end
function FaceManager_Server.RemovePlayerFace(player, sendData)
	FaceManager_Server.RemoveWornItemsWithTag(player, SPNCC.ItemTag.Face)
	FaceManager_Server.SetDataValue(player, "face", {name = "DefaultFace", id = "", texture = 0}, sendData)
end

function FaceManager_Server.AddPlayerBodyDetail(player, name, id, texture, setData)

	local item = FaceManager_Server.AddItem(player, id, texture)

	if setData then table.insert(player:getModData().SPNCharCustom.bodyDetails, {name = name, id = id, texture = texture}) end
	return item
end
function FaceManager_Server.SetPlayerBodyDetails(player, details, sendData)
	FaceManager_Server.ClearPlayerBodyDetails(player, false)
	if #details > 0 then 
		for i, v in ipairs(details) do
			FaceManager_Server.AddPlayerBodyDetail(player, v.name, v.id, v.texture, false)
		end
	end
	FaceManager_Server.SetDataValue(player, "bodyDetails", details, sendData)
end

function FaceManager_Server.ClearPlayerBodyDetails(player, sendData)
	FaceManager_Server.RemoveWornItemsWithTag(player, SPNCC.ItemTag.BodyDetail)
	FaceManager_Server.SetDataValue(player, "bodyDetails", {}, sendData)
end

function FaceManager_Server.AddPlayerStubble(player, isBeard, sendData)
	FaceManager_Server.SetPlayerStubble(player, isBeard, false, sendData)
end

function FaceManager_Server.RemovePlayerStubble(player, isBeard, sendData)
	FaceManager_Server.SetPlayerStubble(player, isBeard, true, sendData)
end
function FaceManager_Server.SetPlayerStubble(player, isBeard, isRemove, sendData)
	local id = ""
	local bodylocation
	local key = ""
	if isBeard then
		id = SPNCC_Data.StubbleBeard
		bodylocation = SPNCC.ItemBodyLocation.StubbleBeard
		key = "stubbleBeard"
	else
		id = SPNCC_Data.StubbleHead
		bodylocation = SPNCC.ItemBodyLocation.StubbleHead
		key = "stubbleHead"
	end

	FaceManager_Server.SetDataValue(player, key, not isRemove, sendData)

	if isRemove then
		FaceManager_Server.RemoveItemAtBodyLocation(player, bodylocation)
	else
		FaceManager_Server.AddItem(player, id, player:getHumanVisual():getSkinTextureIndex())
	end
end

function FaceManager_Server.AddPlayerBodyHair(player, sendData)
	local id = player:isFemale() and SPNCC_Data.BodyHair[2] or SPNCC_Data.BodyHair[1]

	FaceManager_Server.AddItem(player, id, player:getHumanVisual():getSkinTextureIndex())

	FaceManager_Server.SetDataValue(player, "bodyHair", true, sendData)
end
function FaceManager_Server.RemovePlayerBodyHair(player, sendData)
	FaceManager_Server.RemoveItemAtBodyLocation(player, SPNCC.ItemBodyLocation.BodyHair)
	FaceManager_Server.SetDataValue(player, "bodyHair", false, sendData)
end

function FaceManager_Server.SetPlayerMuscle(player)
	local data = player:getModData().SPNCharCustom
	if data == nil then return end

	FaceManager_Server.RemovePlayerMuscle(player)

	local level = player:getPerkLevel(Perks.Strength)

	local muscleLevel = FaceManager_Shared.GetMuscleLevel(level)
	
	if muscleLevel ~= 0 and data.muscleVisuals then
		FaceManager_Server.AddPlayerMuscle(player, muscleLevel)
	end

end

function FaceManager_Server.AddPlayerMuscle(player, muscleLevel)
	if muscleLevel <= 0 then return nil end

	local id = player:isFemale() and SPNCC_Data.Muscle[2] or SPNCC_Data.Muscle[1]

	--get offset
	local textureOffset = 0
	if muscleLevel == 2 then textureOffset = 5 end
	local texture = player:getHumanVisual():getSkinTextureIndex() + textureOffset

	FaceManager_Server.AddItem(player, id, texture)
end

function FaceManager_Server.RemovePlayerMuscle(player)
	FaceManager_Server.RemoveItemAtBodyLocation(player, SPNCC.ItemBodyLocation.Muscle)
end

function FaceManager_Server.SyncBlood(player)
	local itemsWithBlood = FaceManager_Shared.GetWornItemsWithTag(player, SPNCC.ItemTag.CanHaveBlood)
	if #itemsWithBlood == 0 then return end
	

	local playerVisual = player:getVisual()

	-- this isnt optimised but no matter what i do it just doesnt work in multiplayer
	for i, item in ipairs(itemsWithBlood) do
		FaceManager_Shared.AddBloodAndDirtToItem(item:getVisual(), playerVisual)
		item:synchWithVisual()
		-- item:setBloodLevel(0)
		-- item:setDirtyness(0)
		-- item:syncItemFields()
	end
	FaceManager_Server.OnClothingUpdated(player)
end


	-- -------------------------------------
	-- -- MANAGE DATA
	-- -------------------------------------

function FaceManager_Server.SetDataValue(player, key, value, sendData)
	local data = player:getModData().SPNCharCustom
	data[key] = value
	if sendData then sendServerCommand(player, "SPNCC", "SetPlayerModDataValues", {values = {[key] = value}}) end
end

function FaceManager_Server.CreatePlayerData(player)
	local moddata = player:getModData()
	moddata.SPNCharCustom = {}
	local data = moddata.SPNCharCustom

	data.version = FaceManager_Server.modversion
	data.hasCustomised = false
	data.face = {name = "DefaultFace", id = "DefaultFace", texture = 0}
	data.bodyDetails = {}
	data.bodyHair = false
	data.stubbleHead = false
	data.stubbleBeard = false
	data.muscleVisuals = SandboxVars.SPNCharCustom.MuscleVisuals ~= 2	--if muscles are not force disabled then we set it to true
	data.bodyHairGrowthEnabled = SandboxVars.SPNCharCustom.BodyHairGrowthEnabled ~= 2

	data.GrowTimer = {
		stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24,
		stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24,
		bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24,
	}

	return data
end

function FaceManager_Server.SetCustomisation(player, clientData)
	local data = player:getModData().SPNCharCustom

	data.hasCustomised = true
	data.face = clientData.face
	data.bodyDetails = clientData.bodyDetails
	data.muscleVisuals = clientData.muscleVisuals
	data.bodyHairGrowthEnabled = clientData.bodyHairGrowth
	
	FaceManager_Server.RefreshCustomisation(player)

	sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = player:getModData().SPNCharCustom})
end
function FaceManager_Server.SetCustomisationNewCharacter(player, clientData)
	local data = FaceManager_Server.CreatePlayerData(player)

	data.hasCustomised = true
	data.face = clientData.face
	data.bodyDetails = clientData.bodyDetails
	data.bodyHair = clientData.bodyHair
	data.stubbleHead = clientData.stubbleHead
	data.stubbleBeard = clientData.stubbleBeard
	data.muscleVisuals = clientData.muscleVisuals
	data.bodyHairGrowthEnabled = clientData.bodyHairGrowth

    data.GrowTimer = {
		stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24,
		stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24,
		bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24,
	}

	FaceManager_Server.RefreshCustomisation(player)

	sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
end

function FaceManager_Server.RefreshCustomisation(player)
	local data = player:getModData().SPNCharCustom

	FaceManager_Server.SetPlayerMuscle(player)

	FaceManager_Server.SetPlayerFace(player, data.face.name, data.face.id, data.face.texture, false)

	FaceManager_Server.SetPlayerBodyDetails(player, data.bodyDetails, false)

	FaceManager_Server.RemoveItemAtBodyLocation(player, SPNCC.ItemBodyLocation.BodyHair)
	FaceManager_Server.RemoveItemAtBodyLocation(player, SPNCC.ItemBodyLocation.StubbleBeard)
	FaceManager_Server.RemoveItemAtBodyLocation(player, SPNCC.ItemBodyLocation.StubbleHead)

	if data.stubbleBeard then
		FaceManager_Server.AddPlayerStubble(player, true, false)
	end
	if data.stubbleHead then
		FaceManager_Server.AddPlayerStubble(player, false, false)
	end
	if data.bodyHair then
		FaceManager_Server.AddPlayerBodyHair(player, false)
	end

	FaceManager_Server.SyncRemoveCustomisation(player)
	
	FaceManager_Server.OnClothingUpdated(player)
end

function FaceManager_Server.OnPlayerJoin(player)
	local data = player:getModData().SPNCharCustom
	local isNewCharacter = (data == nil) or (not data.hasCustomised) 
	
	if not isNewCharacter then
		print("Existing character")
		FaceManager_Server.CheckData(player, data)
		-- FaceManager_Server.RefreshCustomisation(player)
	else
		print("New character")
		data = FaceManager_Server.CreatePlayerData(player)
		
		--we need to replace the vanilla chest hair and stubble
		local visual = player:getHumanVisual()
		if visual then

			--chest hair
			if visual:getBodyHairIndex() == 0 then
				visual:setBodyHairIndex(-1)
				data.bodyHair = true
			end
			
			--head stubble
			if visual:hasBodyVisualFromItemType("Base.F_Hair_Stubble") or visual:hasBodyVisualFromItemType("Base.M_Hair_Stubble") then
				visual:removeBodyVisualFromItemType("Base.F_Hair_Stubble")
				visual:removeBodyVisualFromItemType("Base.M_Hair_Stubble")
				data.stubbleHead = true
			end
			
			--beard stubble
			if visual:hasBodyVisualFromItemType("Base.M_Beard_Stubble") then
				visual:removeBodyVisualFromItemType("Base.M_Beard_Stubble")
				data.stubbleBeard = true
			end
			
			sendVisual(player)
		end
	end

	FaceManager_Server.SetPlayerMuscle(player)
	FaceManager_Server.RefreshCustomisation(player)
	
	-- Only runs in multiplayer
	sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
	if isNewCharacter then
		sendServerCommand(player, "SPNCC", "OpenCharacterCustomisationWindow", {})
	end
end

function FaceManager_Server.ConvertData(player, data)
	if data.version == 1 then
		--convert stubble growth from days to hours
		local growTimer = data.GrowTimer
		growTimer.stubbleHead = growTimer.stubbleHead *24
		growTimer.stubbleBeard = growTimer.stubbleBeard *24
		growTimer.bodyHair = growTimer.bodyHair *24

		data.version = FaceManager_Server.modversion
		print("Player " .. player:getFullName() .. " SPNCharCustom moddata converted from version 1 to " .. tostring(FaceManager_Server.modversion))
	end
end

--adjust players moddata just in case the server settings were changed 
function FaceManager_Server.CheckData(player, data)
	local sandbox = SandboxVars.SPNCharCustom

	--enable or disable muscle visuals
	if sandbox.MuscleVisuals ~= 3 then
		data.muscleVisuals = sandbox.MuscleVisuals == 1
 	end
	--enable or disable body hair growth
	if sandbox.BodyHairGrowthEnabled ~= 3 then
		data.bodyHairGrowthEnabled = sandbox.BodyHairGrowthEnabled == 1
	end

	if data.version ~= FaceManager_Server.modversion then
		FaceManager_Server.ConvertData(player, data)
	end

	--cap body hair growth
	local growTimer = data.GrowTimer
	local math_min = math.min
	growTimer.stubbleHead = math_min(growTimer.stubbleHead, sandbox.StubbleHeadGrowth *24)
	growTimer.stubbleBeard = math_min(growTimer.stubbleBeard, sandbox.StubbleBeardGrowth *24)
	growTimer.bodyHair = math_min(growTimer.bodyHair, sandbox.BodyHairGrowth *24)

end





	-- -----------------------------------------
	-- -- UTILITY
	-- -----------------------------------------
function FaceManager_Server.AddItem(player, id, texture)
	local item = FaceManager_Shared.CreateItem(id, texture)
	if not item then return end

	FaceManager_Shared.SyncBloodOnNewItem(player, item)

	player:getInventory():AddItem(item)
	sendAddItemToContainer(player:getInventory(), item)

	player:setWornItem(item:getBodyLocation(), item)
    sendClothing(player, item:getBodyLocation(), item)

	return item
end
function FaceManager_Server.RemoveItem(player, item)
	if not item then return end

	-- this doesnt work when the bodylocation is set to multi item
	-- player:removeWornItem(item)
	
	-- this works but doesnt send a syncpacket in mp so it needs a workaround to sync
	player:getWornItems():remove(item)

	player:getInventory():Remove(item)
	sendRemoveItemFromContainer(player:getInventory(), item)
end

function FaceManager_Server.OnClothingUpdated(player)
	triggerEvent("OnClothingUpdated", player)
	player:resetModel()
	sendServerCommand(player, "SPNCC", "OnClothingUpdated", {})
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


return FaceManager_Server