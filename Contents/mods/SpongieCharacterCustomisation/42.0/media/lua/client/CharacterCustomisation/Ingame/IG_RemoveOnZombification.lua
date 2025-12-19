
	-- ---------------------------
	-- -- REMOVE FACE FROM ZOMBIE
	-- ---------------------------
--	When a player dies we need to check if they were infected so that their zombie doesnt have a mismatched face texture
local function removeOnZombification(player)
	if player:getBodyDamage():IsInfected() == false then return end
	
	local FaceManager = require("CharacterCustomisation/FaceManager")
	FaceManager.RemoveItemsWithTag(player, "RemoveOnZombification")
	player:resetModelNextFrame()
	triggerEvent("OnClothingUpdated", player)
end

Events.OnPlayerDeath.Add(removeOnZombification)