
local SPNCC_Commands = {}
local Commands = {}

	-------------------------------------
	-- COMMANDS
	-------------------------------------

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

function Commands.SetPlayerModData(args)
	local player = getPlayer()
	player:getModData().SPNCharCustom = args.data
	player:resetModel()
	triggerEvent("OnClothingUpdated", player)
end

function Commands.SetPlayerModDataValues(args)
	local player = getPlayer()
	local data = player:getModData().SPNCharCustom
    for k, v in pairs(args.values) do
        data[k] = v
    end
	player:resetModel()
	triggerEvent("OnClothingUpdated", player)
end

function Commands.OpenCharacterCustomisationWindow(args)
	FaceManager_Shared.OpenCharacterCustomisationWindow(getPlayer(), true)
end

function Commands.OnClothingUpdated(args)
	FaceManager_Shared.OnClothingUpdated(getPlayer())
end
function Commands.SyncBloodReturn(args)
	FaceManager_Shared.SyncBloodReturn(getPlayer())
end

	-------------------------------------
	-- SETUP
	-------------------------------------
local function onServerCommand(module, command, args)
	if module == "SPNCC" and Commands[command] then
		print(command)
		Commands[command](args)
	end
end

Events.OnServerCommand.Add(onServerCommand)
