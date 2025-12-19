require("NPCs/BodyLocations")

local TATTOOS_ENABLED = getActivatedMods():contains("\\Ellie'sTattooParlor")
local TRANSMOG_ENABLED = getActivatedMods():contains("\\TransmogDE")

if TATTOOS_ENABLED then
	-- need to force this to load after ellies tattoos so the rendering order is correct
	require("NPCs/ETPBodyLocations")
end

local group = BodyLocations.getGroup("Human")
local locations = group:getAllLocations()


local function addLocation(name)
	group:getOrCreateLocation(name)
	group:moveLocationToIndex(name, 0)
end


--descending order (muscle is lower than face and bodydetail)
--muscle is lower than face to avoid visual issues if a mod adds full body textures
--Face_Model is highest to avoid floating textures
addLocation(SPNCC.ItemBodyLocation.Face_Model)
addLocation(SPNCC.ItemBodyLocation.BodyDetail2)
addLocation(SPNCC.ItemBodyLocation.StubbleHead)
addLocation(SPNCC.ItemBodyLocation.StubbleBeard)
addLocation(SPNCC.ItemBodyLocation.BodyHair)
addLocation(SPNCC.ItemBodyLocation.BodyDetail)
addLocation(SPNCC.ItemBodyLocation.Face)
addLocation(SPNCC.ItemBodyLocation.Muscle)
addLocation(SPNCC.ItemBodyLocation.Blank)



group:setMultiItem(SPNCC.ItemBodyLocation.BodyDetail, true)
group:setMultiItem(SPNCC.ItemBodyLocation.BodyDetail2, true)

-- if TRANSMOG_ENABLED then
-- 	require("TransmogDE")
-- 	TransmogDE.addBodyLocationToIgnore("Face_Model")
-- 	TransmogDE.addBodyLocationToIgnore("StubbleHead")
-- 	TransmogDE.addBodyLocationToIgnore("StubbleBeard")
-- 	TransmogDE.addBodyLocationToIgnore("BodyDetail")
-- 	TransmogDE.addBodyLocationToIgnore("BodyDetail2")
-- 	TransmogDE.addBodyLocationToIgnore("BodyHair")
-- 	TransmogDE.addBodyLocationToIgnore("Muscle")
-- 	TransmogDE.addBodyLocationToIgnore("Face")
-- end