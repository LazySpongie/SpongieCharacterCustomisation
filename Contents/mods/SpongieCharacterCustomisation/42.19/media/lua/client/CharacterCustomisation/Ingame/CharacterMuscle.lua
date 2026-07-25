
	-- ---------------------------------------------------------------------------
	-- -- WHEN THE STRENGTH SKILL CHANGES TELL THE SERVER TO UPDATE MUSCLES
	-- ---------------------------------------------------------------------------

local function onLevelPerk(player, perk, level)
	if perk:getType() ~= Perks.Strength:getType() then return end
	
	sendClientCommand(player, "SPNCC", "SetPlayerMuscle", { })
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.LevelPerk.Add(onLevelPerk)
