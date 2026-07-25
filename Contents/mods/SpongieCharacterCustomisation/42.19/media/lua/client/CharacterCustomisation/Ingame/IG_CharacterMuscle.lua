
--	when a players strength skill changes we set their muscle
local function onLevelPerk(player, perk, level)
	if perk:getType() ~= Perks.Strength:getType() then return end

	sendClientCommand(player, "SPNCC", "SetPlayerMuscle", { })
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.LevelPerk.Add(onLevelPerk)
