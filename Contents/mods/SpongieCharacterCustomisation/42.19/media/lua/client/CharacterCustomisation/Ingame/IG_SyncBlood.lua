
-- 	-- ----------------------
-- 	-- -- SYNC BLOOD
-- 	-- ----------------------
-- --Blood renders beneath clothing so we need to grab every equipped customisation that supports blood and then copy the body's blood onto them
-- --this works because clothing still renders blood on all body parts

-- local function isSP()
-- 	return not isClient() and not isServer()
-- end

-- local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

-- local ignoreUpdate = false
-- local function SyncBloodOnClothingUpdated(player)
-- 	if ignoreUpdate then ignoreUpdate = false return end

-- 	print("SPNCC : OnClothingUpdated")

-- 	local item = FaceManager_Shared.GetFirstWornItemWithTag(player, SPNCC.ItemTag.CanHaveBlood)
-- 	if not item then return end
	
-- 	-- check if the blood is different to avoid an infinite loop
-- 	if not FaceManager_Shared.CompareItemBlood(item:getVisual(), player:getVisual()) then return end
	
-- 	if isSP() then 
-- 		print("SPNCC : SyncBlood Singleplayer")
-- 		local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")
-- 		FaceManager_Server.SyncBlood(player)
-- 	else
-- 		sendClientCommand(player, "SPNCC", "SyncBlood", { })
-- 	end

-- end


-- 	-- ----------------------
-- 	-- -- SUBSCRIBE TO EVENTS
-- 	-- ----------------------
-- -- Events.OnClothingUpdated.Add(SyncBloodOnClothingUpdated)
