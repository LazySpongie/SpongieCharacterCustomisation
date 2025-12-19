local FaceManager = require("CharacterCustomisation/FaceManager")
local FM_Data = require("CharacterCustomisation/FM_Data")

--Sets whether players with missing eye customisation have a vision penalty

--you can insert your own customisation into this table
FM_Data.MissingEyes = {}

function FaceManager.SetMissingEyeVisionPenalty()
    if FM_Data.MissingEyes == nil then return end
    
    local MissingEyeVisionModifier = SandboxVars.SPNCharCustom.MissingEyeVisionModifier
    
    for i,v in pairs(FM_Data.MissingEyes) do
        ScriptManager.instance:getItem(v):DoParam("VisionModifier = " .. MissingEyeVisionModifier)
    end
end


local function OnInitGlobalModData()
    FaceManager.SetMissingEyeVisionPenalty()
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
