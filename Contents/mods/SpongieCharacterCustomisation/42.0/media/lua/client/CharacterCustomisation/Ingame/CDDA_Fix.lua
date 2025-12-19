
local FaceManager = require("CharacterCustomisation/FaceManager")

local originalAddPlayer = CDDA.AddPlayer
---@diagnostic disable-next-line: duplicate-set-field
function CDDA.AddPlayer(playerNum, player)
     originalAddPlayer(playerNum, player)

     FaceManager.AddItemsFromData(player)
     FaceManager.SetPlayerMuscle(player, player:getPerkLevel(Perks.Strength))
     
     triggerEvent("OnClothingUpdated", player)
end

-- cdda removes all clothing so we need to add it from player data