require 'NPCs/BodyLocations'

if getActivatedMods():contains("Ellie'sTattooParlor") then
	-- need to force this to load after ellies tattoos so the rendering order is correct
	require("NPCs/ETPBodyLocations")
end

local group = BodyLocations.getGroup("Human")
local locations = group:getAllLocations()

local function AddNewPlayerDetailBodyLocation(name)
	local myBodyLocation = group:getOrCreateLocation(name);
	locations:remove(myBodyLocation)
	locations:add(0, myBodyLocation)
end

--descending order (Face is lower than stubble and bodydetail)
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



if getActivatedMods():contains("TransmogDE") then
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