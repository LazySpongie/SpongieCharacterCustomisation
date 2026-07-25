
	-- ----------------------------------------------------------------------
	-- -- SYNC BODY BLOOD ONTO FACE AND MUSCLES
	-- ----------------------------------------------------------------------

-- Check a player each tick to see if their face/muscle needs to have its blood visuals updated to match the body

if isClient() then return end



local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")

local math_ceil = math.ceil


-- amount of ticks a player will have between checks
local MaxDelay = 200
local Delay = MaxDelay
local Timer = 1
local CurrentPlayerIndex = 0
local LastPlayerCount = 0



-- Check if a player has a customisation item that needs blood syncing
local function CheckBlood(player)
	local item = FaceManager_Shared.GetFirstWornItemWithTag(player, SPNCC.ItemTag.CanHaveBlood)
	if not item then return end
	
	-- check if blood needs syncing
	if not FaceManager_Server.CompareItemBlood(item:getVisual(), player:getVisual()) then return end
	
    FaceManager_Server.SyncBlood(player)
end


-- Check a player each tick to see if their face/muscle needs blood syncing
local function CheckPlayers(tick)

	Timer = Timer - 1
	if Timer > 0 then return end

    local playerToCheck
	if not isServer() then
        Delay = MaxDelay
		playerToCheck = getPlayer()
    else
        local players = getOnlinePlayers()
        local size = players:size()
        if not size == 0 then
            -- recalculate tick delay based on playercount
            if LastPlayerCount ~= size then
                LastPlayerCount = size
                
                -- round up
                Delay = math_ceil(MaxDelay/LastPlayerCount)
            end


            if CurrentPlayerIndex > size-1 then CurrentPlayerIndex = 0 end
            
            playerToCheck = players:get(CurrentPlayerIndex)
            -- may need to check if player is dead

            CurrentPlayerIndex = CurrentPlayerIndex + 1
        end
	end

    CheckBlood(playerToCheck)

    Timer = Delay
    print(tick)
end

Events.OnTick.Add(CheckPlayers)
