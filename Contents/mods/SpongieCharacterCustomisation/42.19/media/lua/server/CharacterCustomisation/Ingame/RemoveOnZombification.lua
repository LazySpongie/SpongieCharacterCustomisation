

	-- ---------------------------
	-- -- REMOVE FACE FROM ZOMBIE
	-- ---------------------------
--	When a player dies we need to check if they were infected so that their zombie doesnt have a mismatched face texture

if isClient() then return end

local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")

local function removeOnZombification(character)
	if instanceof(character, "IsoPlayer") and not instanceof(character, "IsoAnimal") then 
		-- print("SPNCC : PLAYER DEATH")
		if character:getBodyDamage():IsInfected() == false then return end
		-- print("SPNCC : PLAYER WAS INFECTED")
		FaceManager_Server.RemoveItemsWithTag(character, SPNCC.ItemTag.RemoveOnZombification)
	end
end

Events.OnCharacterDeath.Add(removeOnZombification)
