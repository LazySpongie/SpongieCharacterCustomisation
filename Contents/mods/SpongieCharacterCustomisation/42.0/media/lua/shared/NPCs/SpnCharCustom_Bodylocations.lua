require("NPCs/BodyLocations")

local TATTOOS_ENABLED = getActivatedMods():contains("\\Ellie'sTattooParlor")
local TRANSMOG_ENABLED = getActivatedMods():contains("\\TransmogDE")

if TATTOOS_ENABLED then
	-- need to force this to load after ellies tattoos so the rendering order is correct
	require("NPCs/ETPBodyLocations")
end

local group = BodyLocations.getGroup("Human")
local locations = group:getAllLocations()


local function AddNewPlayerDetailBodyLocation(name)
	local bodyLocation = BodyLocation.new(group, name)
	locations:add(0, bodyLocation)
end

--descending order (muscle is lower than face and bodydetail)
--muscle is lower than face to avoid visual issues if a mod adds full body textures
--Face_Model is highest to avoid floating textures
AddNewPlayerDetailBodyLocation("Face_Model")
AddNewPlayerDetailBodyLocation("BodyDetail2")
AddNewPlayerDetailBodyLocation("StubbleHead")
AddNewPlayerDetailBodyLocation("StubbleBeard")
AddNewPlayerDetailBodyLocation("BodyHair")
AddNewPlayerDetailBodyLocation("BodyDetail")

AddNewPlayerDetailBodyLocation("Mouth")	--im not using these but im adding them for mod support
AddNewPlayerDetailBodyLocation("Nose")
AddNewPlayerDetailBodyLocation("Brow")
AddNewPlayerDetailBodyLocation("Eyes")

AddNewPlayerDetailBodyLocation("Face")
AddNewPlayerDetailBodyLocation("Muscle")

group:setMultiItem("BodyDetail", true)
group:setMultiItem("BodyDetail2", true)


if TRANSMOG_ENABLED then
	require("TransmogDE")
	TransmogDE.addBodyLocationToIgnore("Face_Model")
	TransmogDE.addBodyLocationToIgnore("StubbleHead")
	TransmogDE.addBodyLocationToIgnore("StubbleBeard")
	TransmogDE.addBodyLocationToIgnore("BodyDetail")
	TransmogDE.addBodyLocationToIgnore("BodyDetail2")
	TransmogDE.addBodyLocationToIgnore("BodyHair")
	TransmogDE.addBodyLocationToIgnore("Muscle")
	TransmogDE.addBodyLocationToIgnore("Mouth")
	TransmogDE.addBodyLocationToIgnore("Nose")
	TransmogDE.addBodyLocationToIgnore("Brow")
	TransmogDE.addBodyLocationToIgnore("Eyes")
	TransmogDE.addBodyLocationToIgnore("Face")
end