
	-- ---------------------------------------------------------------------------
	-- -- WHEN A PLAYER CREATES A NEW CHARACTER OR JOINS AS AN EXISTING CHARACTER
	-- ---------------------------------------------------------------------------

local function isSP()
	return not isClient() and not isServer()
end


	-- -----------------------------------------
	-- -- SET UP MOD DATA AFTER CHARACTER CREATION
	-- -----------------------------------------
-- When the character spawns from character creation we send their customisation to the server so it can be saved in mod data
local OnNewCharacterTimer
local function OnNewCharacter()
	OnNewCharacterTimer = OnNewCharacterTimer - 1
	if OnNewCharacterTimer > 0 then return end
	Events.OnPlayerUpdate.Remove(OnNewCharacter)

	print("SPNCC : OnNewCharacter")

	local clientData = require("CharacterCustomisation/CharacterCreation/StoredCharacterData")	--data we stored during character creation
	if isSP() then
		local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")
		FaceManager_Server.SetCustomisationNewCharacter(getPlayer(), clientData)
	else
		sendClientCommand(getPlayer(), "SPNCC", "SetCustomisationNewCharacter", { data = clientData})
	end
end
local function onNewGame(player)
	OnNewCharacterTimer = 200
	Events.OnPlayerUpdate.Add(OnNewCharacter)
end

	-- -----------------------------------------------
	-- -- EXISTING CHARACTERS LOADING INTO THE GAME
	-- -----------------------------------------------
-- When a player loads into the game with a char from before the mod was added then open the customisation window
local OnPlayerJoinTimer
local function OnPlayerJoin()
	OnPlayerJoinTimer = OnPlayerJoinTimer - 1
	if OnPlayerJoinTimer > 0 then return end
	Events.OnPlayerUpdate.Remove(OnPlayerJoin)

	print("SPNCC : OnPlayerJoin")

	local player = getPlayer()

	--singleplayer / multiplayer
	if not isClient() and not isServer() then 
		local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")
		FaceManager_Server.OnPlayerJoin(player)
	else
		sendClientCommand(player, "SPNCC", "OnPlayerJoin", { })
	end
end

local function onCreatePlayer(playerNum, player)
	OnPlayerJoinTimer = 202
	Events.OnPlayerUpdate.Add(OnPlayerJoin)
end

	-- -----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- -----------------------
-- both functions need to be delayed to wait for client commands to be available in mp
Events.OnNewGame.Add(onNewGame)
Events.OnCreatePlayer.Add(onCreatePlayer)
