
	-- -----------------------------------------
	-- -- SET UP MOD DATA AFTER CHARACTER CREATION
	-- -----------------------------------------
-- When the character spawns from character creation we send their customisation to the server so it can be saved in mod data
local OnNewCharacterTimer
local function OnNewCharacter()
	OnNewCharacterTimer = OnNewCharacterTimer - 1
	if OnNewCharacterTimer > 0 then return end
	Events.OnPlayerUpdate.Remove(OnNewCharacter)
	local clientData = require("CharacterCustomisation/CharacterCreation/StoredCharacterData")	--data we stored during character creation
	sendClientCommand(getPlayer(), "SPNCC", "SetCustomisationNewCharacter", { data = clientData})
end
local function onNewGame(player)
	OnNewCharacterTimer = 3
	Events.OnPlayerUpdate.Add(OnNewCharacter)
end

	-- -----------------------------------------------
	-- -- OPEN CHARACTER CUSTOMISATION FOR OLD CHARACTERS
	-- -----------------------------------------------
-- When a player loads into the game with a char from before the mod was added then open the customisation window
local OnPlayerJoinTimer
local function OnPlayerJoin()
	OnPlayerJoinTimer = OnPlayerJoinTimer - 1
	if OnPlayerJoinTimer > 0 then return end
	Events.OnPlayerUpdate.Remove(OnPlayerJoin)

	local player = getPlayer()
	sendClientCommand(player, "SPNCC", "OnPlayerJoin", { })

	--singleplayer only
	if isClient() or isServer() then return end
	local data = player:getModData().SPNCharCustom
	if data and data.hasCustomised then return end
	local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
	FaceManager_Shared.OpenCharacterCustomisationWindow(player, true)
end

local function onCreatePlayer(playerNum, player)
	print("onCreatePlayer")
	OnPlayerJoinTimer = 6
	Events.OnPlayerUpdate.Add(OnPlayerJoin)
end

	-- -----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- -----------------------
Events.OnNewGame.Add(onNewGame)
Events.OnCreatePlayer.Add(onCreatePlayer)
