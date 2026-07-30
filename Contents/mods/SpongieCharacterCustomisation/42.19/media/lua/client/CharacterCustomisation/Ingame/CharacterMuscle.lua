
	-- ---------------------------------------------------------------------------
	-- -- WHEN THE STRENGTH SKILL CHANGES TELL THE SERVER TO UPDATE MUSCLES
	-- ---------------------------------------------------------------------------

local function onLevelPerk(player, perk, level)
	if perk:getType() ~= Perks.Strength:getType() then return end
	
	if not isClient() and not isServer() then
		local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")
		FaceManager_Server.SetPlayerMuscle(getPlayer())
	else
		sendClientCommand(player, "SPNCC", "SetPlayerMuscle", { })
	end
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.LevelPerk.Add(onLevelPerk)
