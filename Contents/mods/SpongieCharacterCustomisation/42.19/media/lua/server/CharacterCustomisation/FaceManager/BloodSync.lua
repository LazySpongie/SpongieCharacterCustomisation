
if isClient() then return end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")

	-- -------------------------------------
	-- -- Blood Syncing
	-- -------------------------------------


function FaceManager_Server.SyncBlood(player)
	-- print("SPNCC : FaceManager_Server SyncBlood")
	local itemsWithBlood = FaceManager_Shared.GetWornItemsWithTag(player, SPNCC.ItemTag.CanHaveBlood)
	if #itemsWithBlood == 0 then return end
	
	for i, item in ipairs(itemsWithBlood) do
		-- print(item)
		FaceManager_Server.SyncBloodOnItem(player, item)
	end

	if isServer() then
		sendServerCommand(player, "SPNCC", "OnClothingUpdated", {})
	else
		FaceManager_Shared.OnClothingUpdated(player)
	end
end

function FaceManager_Server.SyncBloodOnItem(player, item)
	FaceManager_Server.AddBloodAndDirtToItem(item:getVisual(), player:getVisual())
	-- slight desync for other players
	item:synchWithVisual()
	syncItemFields(player, item)
	item:syncItemFields()
	sendItemStats(item)
end

function FaceManager_Server.SyncBloodOnNewItem(player, item)
	if not item:hasTag(SPNCC.ItemTag.CanHaveBlood) then return false end
	FaceManager_Server.SyncBloodOnItem(player, item)
end

function FaceManager_Server.CompareBodyPartBlood(item1, item2, part)
	local blood = item1:getBlood(part) ~= item2:getBlood(part)
	local dirt = item1:getDirt(part) ~= item2:getDirt(part)
	return blood or dirt
end

function FaceManager_Server.AddBloodAndDirtToBodyPart(item1, item2, part)
	item1:setBlood(part, item2:getBlood(part))
	item1:setDirt(part, item2:getDirt(part))
end

function FaceManager_Server.AddBloodAndDirtToItem(item1, item2)
	for i=1,BloodBodyPartType.MAX:index() do
		local part = BloodBodyPartType.FromIndex(i-1)
		FaceManager_Server.AddBloodAndDirtToBodyPart(item1, item2, part)
	end
end

function FaceManager_Server.CompareItemBlood(item1, item2)
	local conditionChanged = false
	for i=1,BloodBodyPartType.MAX:index() do
		local part = BloodBodyPartType.FromIndex(i-1)
		if FaceManager_Server.CompareBodyPartBlood(item1, item2, part) then conditionChanged = true end
	end
	return conditionChanged
end

