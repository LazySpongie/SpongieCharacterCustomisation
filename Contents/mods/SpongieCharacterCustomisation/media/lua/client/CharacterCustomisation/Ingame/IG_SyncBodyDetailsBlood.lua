local FaceManager = require("CharacterCustomisation/FaceManager")
	-- ----------------------
	-- -- SYNC BLOOD
	-- ----------------------
--Blood renders beneath clothing so we need to grab every equipped customisation that supports blood and then copy the body's blood onto them
--this works because clothing still render blood visuals on body parts that they dont have protection for

local function AddBloodAndDirtToBodyPart(item1, item2, part)
	local conditionChanged = false
	-- blood
	local item1Blood = item1:getBlood(part)
	local item2Blood = item2:getBlood(part)
	if item1Blood ~= item2Blood then
		item1:setBlood(part, item2Blood)
		conditionChanged = true
	end
	-- dirt
	local item1Dirt = item1:getDirt(part)
	local item2Dirt = item2:getDirt(part)
	if item1Dirt ~= item2Dirt then
		item1:setDirt(part, item2Dirt)
		conditionChanged = true
	end
	return conditionChanged
end
local function AddBloodAndDirt(item1, item2)
	local conditionChanged = false
	for i=1,BloodBodyPartType.MAX:index() do
		local part = BloodBodyPartType.FromIndex(i-1)
		if AddBloodAndDirtToBodyPart(item1, item2, part) == true then conditionChanged = true end
	end
	return conditionChanged
end

function FaceManager.SyncBloodOnNewItem(player, item)
	if not item:hasTag("CanHaveBlood") then return false end

	return AddBloodAndDirt(item:getVisual(), player:getVisual())
end

local BloodWasJustSynced = false
function FaceManager.SyncBloodOnClothingUpdated(player)
	-- need to avoid an infinite loop
	if BloodWasJustSynced then
		BloodWasJustSynced = false
		return
	end

	local itemsWithBlood = FaceManager.GetWornItemsWithTag(player, "CanHaveBlood")
	if #itemsWithBlood == 0 then return end
	
	--because we are editing clothing we need to call OnClothingUpdated but we need to avoid an infinite loop
    local conditionChanged = false
	
	-- copy body blood to first item in list
	local playerVisual = player:getVisual()
	local item1Visual = itemsWithBlood[1]:getVisual()

	if AddBloodAndDirt(item1Visual, playerVisual) == true then conditionChanged = true end
	
    if (conditionChanged) then

		for i, item in ipairs(itemsWithBlood) do
			if i ~= 1 then
				local visual = item:getVisual()
				visual:copyBlood(item1Visual)
				visual:copyDirt(item1Visual)
			end
			--we dont want to cause weird issues if another mod tries to use the dirtyness of equipped clothing for something
			item:setBloodLevel(0)
			item:setDirtyness(0)
			
		end

		BloodWasJustSynced = true

		-- i still dont know what this does but its related to mp
		sendClothing(player)
		
        -- player:resetModelNextFrame()
		triggerEvent("OnClothingUpdated", player)
    end
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.OnClothingUpdated.Add(FaceManager.SyncBloodOnClothingUpdated)
