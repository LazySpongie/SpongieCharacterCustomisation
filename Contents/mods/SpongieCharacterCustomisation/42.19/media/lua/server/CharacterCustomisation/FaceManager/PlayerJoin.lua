
	-- ----------------------------------------------------------------------
	-- -- METHODS FOR THE SERVER TO MANAGE DATA AND CUSTOMISATION ITEMS
	-- ----------------------------------------------------------------------
	
if isClient() then return end

local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")

function FaceManager_Server.OnPlayerJoin(player)
	local data = player:getModData().SPNCharCustom
	local isNewCharacter = (not data) or (not data.hasCustomised) 
	
	if not isNewCharacter then
		-- print("SPNCC : CONNECTING PLAYER ALREADY HAS CUSTOMISATION")
		FaceManager_Server.CheckData(player, data)
		-- FaceManager_Server.RefreshCustomisation(player)
	else
		-- print("SPNCC : CONNECTING PLAYER DOES NOT HAVE CUSTOMISATION")
		data = FaceManager_Server.CreatePlayerData(player)
		
		--we need to replace the vanilla chest hair and stubble
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

	FaceManager_Server.SetPlayerMuscle(player)
	FaceManager_Server.RefreshCustomisation(player)
	
	-- Only runs in multiplayer
	if isServer() then
		sendServerCommand(player, "SPNCC", "SetPlayerModData", {data = data})
		if isNewCharacter then
			sendServerCommand(player, "SPNCC", "OpenCharacterCustomisationWindow", {})
		end
	elseif isNewCharacter then
		FaceManager_Shared.OpenCharacterCustomisationWindow(player, true)
	end
end
