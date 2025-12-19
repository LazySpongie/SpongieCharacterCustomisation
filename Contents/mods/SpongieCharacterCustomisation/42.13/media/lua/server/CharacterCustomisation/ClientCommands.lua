
local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")

local Commands = {}


	-- -------------------------------------
	-- -- COMMANDS
	-- -------------------------------------

function Commands.SetCustomisation(player, args)
	FaceManager_Server.SetCustomisation(player, args.data)
end

function Commands.SetCustomisationNewCharacter(player, args)
	FaceManager_Server.SetCustomisationNewCharacter(player, args.data)
end

function Commands.AddPlayerStubble(player, args)
	FaceManager_Server.AddPlayerStubble(player, args.isBeard, true)
end

function Commands.AddPlayerBodyHair(player, args)
	FaceManager_Server.AddPlayerBodyHair(player, true)
end

function Commands.SetPlayerMuscle(player, args)
	FaceManager_Server.SetPlayerMuscle(player)
	FaceManager_Server.SyncRemoveCustomisation(player)
	FaceManager_Server.OnClothingUpdated(player)
end

function Commands.RefreshCustomisation(player, args)
	FaceManager_Server.RefreshCustomisation(player)
end

function Commands.RequestPlayerModData(player, args)
	sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = player:getModData().SPNCharCustom})
end

function Commands.OnPlayerJoin(player, args)
	FaceManager_Server.OnPlayerJoin(player)
end

function Commands.SyncBlood(player, args)
	FaceManager_Server.SyncBlood(player)
end



	-- -------------------------------------
	-- -- SETUP
	-- -------------------------------------
local function OnClientCommand(module, command, player, args)
	if module == "SPNCC" and Commands[command] then
		print(command)
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)
