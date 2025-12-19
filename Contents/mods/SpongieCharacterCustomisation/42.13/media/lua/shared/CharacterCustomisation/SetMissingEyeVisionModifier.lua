local SPNCC_Data = require("CharacterCustomisation/SPNCC_Data")

--Sets whether players with missing eye customisation have a vision penalty

local function SetMissingEyeVisionPenalty()
    if SPNCC_Data.MissingEyes == nil then return end
    
    local MissingEyeVisionModifier = SandboxVars.SPNCharCustom.MissingEyeVisionModifier
    
    for i,v in pairs(SPNCC_Data.MissingEyes) do
        ScriptManager.instance:getItem(v):DoParam("VisionModifier = " .. MissingEyeVisionModifier)
    end
end


local function OnInitGlobalModData()
    SetMissingEyeVisionPenalty()
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
