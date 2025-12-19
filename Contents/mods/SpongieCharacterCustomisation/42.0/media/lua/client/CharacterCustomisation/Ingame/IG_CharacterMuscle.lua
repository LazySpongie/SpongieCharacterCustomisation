
local FaceManager = require("CharacterCustomisation/FaceManager")
-- local FM_Data = require("CharacterCustomisation/FM_Data")

	-- ----------------------
	-- -- PLAYER MUSCLE
	-- ----------------------
function FaceManager.SetPlayerMuscle(player, level)
	local data = player:getModData().SPNCharCustom

	FaceManager.RemovePlayerMuscle(player)
	if not data.muscleVisuals then return end

	level = level or player:getPerkLevel(Perks.Strength)

	local muscleLevel = FaceManager.GetMuscleLevel(level)
	
	if muscleLevel ~= 0 then
		FaceManager.AddPlayerMuscle(player, muscleLevel)
	end
	
	-- player:resetModelNextFrame()
	-- triggerEvent("OnClothingUpdated", player)
end

function FaceManager.GetMuscleLevel(level)
	if level == nil then return 0 end
	if level <= 5 then return 	0 end
	if level <= 8 then return 	1 end
	if level <= 10 then return 	2 end
	return 0
end

--	when a players strength skill changes we set their muscle
local function onLevelPerk(player, perk, level)
	if perk:getType() ~= Perks.Strength:getType() then return end
	if player:getModData().SPNCharCustom == nil then return end --this function also runs when creating a character after dying

	FaceManager.SetPlayerMuscle(player, level)
	
	player:resetModelNextFrame()
	triggerEvent("OnClothingUpdated", player)
end

	-- ----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- ----------------------
Events.LevelPerk.Add(onLevelPerk)
