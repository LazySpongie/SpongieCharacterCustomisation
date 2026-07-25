
local function isSP()
	return not isClient() and not isServer()
end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")

local function CheckBlood(player)

	-- print("SPNCC : CheckBlood")

	local item = FaceManager_Shared.GetFirstWornItemWithTag(player, SPNCC.ItemTag.CanHaveBlood)
	if not item then return end
	
	-- check if blood needs syncing
	if not FaceManager_Shared.CompareItemBlood(item:getVisual(), player:getVisual()) then return end
	
    FaceManager_Server.SyncBlood(player)
end

local Delay = 1
local Timer = Delay
local playerIndex = 0

-- Check a player each tick to see if their face/muscle needs blood syncing
local function SyncBlood()
	if isClient() then return end

	Timer = Timer - 1
	if Timer > 0 then return end
    Timer = Delay

    local playerToCheck
	if not isServer() then
		playerToCheck = getPlayer()
    else
        local players = getOnlinePlayers()
        if not players:isEmpty() then
            if playerIndex > players:size()-1 then playerIndex = 0 end
            
            -- for i = 0, players:size()-1 do
            --     playerToCheck = players:get(i)
            -- end

            playerToCheck = players:get(playerIndex)
            
            -- may need to check if player is dead

            playerIndex = playerIndex + 1
        end
	end

    CheckBlood(playerToCheck)
end

Events.OnTick.Add(SyncBlood)
