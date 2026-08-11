
if isClient() then return end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
local SPNCC_Data = require("CharacterCustomisation/SPNCC_Data")

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")



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


function FaceManager_Server.SetCustomisation(player, clientData)
	local data = player:getModData().SPNCharCustom

	data.hasCustomised = true
	data.face = clientData.face
	data.bodyDetails = clientData.bodyDetails
	data.muscleVisuals = clientData.muscleVisuals
	data.bodyHairGrowthEnabled = clientData.bodyHairGrowth
	
	FaceManager_Server.RefreshCustomisation(player)

	if isServer() then
		sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = player:getModData().SPNCharCustom})
	end
end

function  FaceManager_Server.RefreshCustomisation(player)
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

function FaceManager_Server.SetCustomisationNewCharacter(player, clientData)
	local data = FaceManager_Server.CreatePlayerData(player)
	if not clientData then 
		FaceManager_Server.CreatePlayerData(player)
		FaceManager_Server.SetPlayerMuscle(player)
		FaceManager_Server.RefreshCustomisation(player)
		if isServer() then
			sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
			sendServerCommand(player, "SPNCC", "OpenCharacterCustomisationWindow", {})
		else
			FaceManager_Shared.OpenCharacterCustomisationWindow(player, true)
		end
		return
	end

	data.hasCustomised = true
	data.face = clientData.face
	data.bodyDetails = clientData.bodyDetails
	data.bodyHair = clientData.bodyHair
	data.stubbleHead = clientData.stubbleHead
	data.stubbleBeard = clientData.stubbleBeard
	data.muscleVisuals = clientData.muscleVisuals
	data.bodyHairGrowthEnabled = clientData.bodyHairGrowth

	FaceManager_Server.RefreshCustomisation(player)

	if isServer() then
		sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
	end
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
