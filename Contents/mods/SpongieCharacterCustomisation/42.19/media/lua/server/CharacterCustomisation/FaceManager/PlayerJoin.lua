
	-- ----------------------------------------------------------------------
	-- -- METHODS FOR THE SERVER TO MANAGE DATA AND CUSTOMISATION ITEMS
	-- ----------------------------------------------------------------------
	
if isClient() then return end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")

function FaceManager_Server.OnPlayerJoin(player)
	local modData = player:getModData()

	local data = modData.SPNCharCustom or FaceManager_Server.CreatePlayerData(player)
	local hasCustomised = not data.hasCustomised
	
	if hasCustomised then
		-- print("SPNCC : CONNECTING PLAYER ALREADY HAS CUSTOMISATION")
		FaceManager_Server.CheckData(player, data)
		-- FaceManager_Server.RefreshCustomisation(player)
	else
		-- print("SPNCC : CONNECTING PLAYER DOES NOT HAVE CUSTOMISATION")

		-- replace vanilla chest hair and stubble
		local visual = player:getHumanVisual()
		if visual then

			--chest hair
			if visual:getBodyHairIndex() == 0 then
				visual:setBodyHairIndex(-1)
				data.bodyHair = true
			end
			
			--head stubble
			if visual:hasBodyVisualFromItemType("Base.F_Hair_Stubble") or visual:hasBodyVisualFromItemType("Base.M_Hair_Stubble") then
				visual:removeBodyVisualFromItemType("Base.F_Hair_Stubble")
				visual:removeBodyVisualFromItemType("Base.M_Hair_Stubble")
				data.stubbleHead = true
			end
			
			--beard stubble
			if visual:hasBodyVisualFromItemType("Base.M_Beard_Stubble") then
				visual:removeBodyVisualFromItemType("Base.M_Beard_Stubble")
				data.stubbleBeard = true
			end
			
			sendVisual(player)
		end
	end

	FaceManager_Server.RefreshCustomisation(player)
	
	if isServer() then
		sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
		if hasCustomised then
			sendServerCommand(player, "SPNCC", "OpenCharacterCustomisationWindow", {})
		end
	elseif hasCustomised then
		FaceManager_Shared.OpenCharacterCustomisationWindow(player, true)
	end
end
