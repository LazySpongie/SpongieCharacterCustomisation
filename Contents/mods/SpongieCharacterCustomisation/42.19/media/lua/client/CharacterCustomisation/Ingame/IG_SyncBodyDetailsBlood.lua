
	-- ----------------------
	-- -- SYNC BLOOD
	-- ----------------------
--Blood renders beneath clothing so we need to grab every equipped customisation that supports blood and then copy the body's blood onto them
--this works because clothing still render blood visuals on body parts that they dont have protection for

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

-- local BloodWasJustSynced = false
local function SyncBloodOnClothingUpdated(player)

	-- need to avoid an infinite loop
	-- if BloodWasJustSynced then
	-- 	BloodWasJustSynced = false
	-- 	return
	-- end

	local item = FaceManager_Shared.GetFirstWornItemWithTag(player, SPNCC.ItemTag.CanHaveBlood)
	if not item then return end
	
	if not FaceManager_Shared.CompareItemBlood(item:getVisual(), player:getVisual()) then return end
		
	sendClientCommand(player, "SPNCC", "SyncBlood", { })

	-- BloodWasJustSynced = true
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.OnClothingUpdated.Add(SyncBloodOnClothingUpdated)
