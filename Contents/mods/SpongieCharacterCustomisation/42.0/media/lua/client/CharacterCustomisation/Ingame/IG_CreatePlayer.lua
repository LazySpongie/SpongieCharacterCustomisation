-- require("CharacterCustomisation/FaceManager")
local FaceManager = require("CharacterCustomisation/FaceManager")
-- require("CharacterCustomisation/BodyDetailWindow/CharacterCustomisationPanel_INGAME")

local modversion = 2

	-- -----------------------------------------
	-- -- SET UP MOD DATA ON CHARACTER CREATION
	-- -----------------------------------------
--When the character is spawned in from chara creation we set up their mod data to store their selected customisation
local function onNewGame(player)
	local modData = player:getModData()
	modData.SPNCharCustom = {}
	
	local data = modData.SPNCharCustom
	
	--in case the mod gets updated in the future
	data.version = modversion
	
	local clientData = require("CharacterCustomisation/CharacterCreation/StoredCharacterData")	--data we stored during character creation
	data.face = clientData.face
	data.bodyDetails = clientData.bodyDetails
	data.bodyHair = clientData.bodyHair
	data.stubbleHead = clientData.stubbleHead
	data.stubbleBeard = clientData.stubbleBeard
	data.muscleVisuals = clientData.muscleVisuals
	data.bodyHairGrowthEnabled = clientData.bodyHairGrowth

    data.GrowTimer = {
		stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24,
		stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24,
		bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24,
	}
	
	-- print("NEW CHARACTER HAS BEEN SET UP WITH CHARACTER CUSTOMISATION DATA")
end

local function convertData(player, data)
	if data.version == 1 then
		--convert stubble growth from days to hours
		local growTimer = data.GrowTimer
		growTimer.stubbleHead = growTimer.stubbleHead *24
		growTimer.stubbleBeard = growTimer.stubbleBeard *24
		growTimer.bodyHair = growTimer.bodyHair *24

		data.version = modversion
		print("Spongie's Character Customisation: Player " .. player:getFullName() .. " mod data converted from version 1 to " .. tostring(modversion))
	end
end

--adjust players moddata just in case the server settings were changed 
local function checkData(player, data)
	local sandbox = SandboxVars.SPNCharCustom

	--enable or disable muscle visuals
	if sandbox.MuscleVisuals ~= 3 then
		data.muscleVisuals = sandbox.MuscleVisuals == 1
 	end
	--enable or disable body hair growth
	if sandbox.BodyHairGrowthEnabled ~= 3 then
		data.bodyHairGrowthEnabled = sandbox.BodyHairGrowthEnabled == 1
	end

	if data.version ~= modversion then
		convertData(player, data)
	end

	--cap body hair growth
	local growTimer = data.GrowTimer
	local math_min = math.min
	growTimer.stubbleHead = math_min(growTimer.stubbleHead, sandbox.StubbleHeadGrowth *24)
	growTimer.stubbleBeard = math_min(growTimer.stubbleBeard, sandbox.StubbleBeardGrowth *24)
	growTimer.bodyHair = math_min(growTimer.bodyHair, sandbox.BodyHairGrowth *24)

end

	-- -----------------------------------------------
	-- -- SET UP CUSTOMISATION FOR OLD CHARACTERS
	-- -----------------------------------------------
--When a player loads into the game with a char from before the mod was added then we set default customisation and then open the customisation window
local function onCreatePlayer(playerNum, player)
	local modData = player:getModData()
	if modData.SPNCharCustom then
		checkData(player, modData.SPNCharCustom)
	else
		-- print("CHARACTER DOES NOT HAVE CHARACTER CUSTOMISATION DATA")
		modData.SPNCharCustom = {}
		
		local data = modData.SPNCharCustom
		
		--set the default values
		data.version = modversion
		data.face = {name = "DefaultFace", id = "DefaultFace", texture = 0}
		data.bodyDetails = {}
		data.bodyHair = false
		data.stubbleHead = false
		data.stubbleBeard = false
		data.muscleVisuals = SandboxVars.SPNCharCustom.MuscleVisuals ~= 2	--if muscles are not force disabled then we set it to true
		data.bodyHairGrowthEnabled = SandboxVars.SPNCharCustom.BodyHairGrowthEnabled ~= 2
	
		data.GrowTimer = {
			stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24,
			stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24,
			bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24,
		}
		
		--we need to replace the vanilla chest hair and stubble
		local visual = player:getHumanVisual()
	
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
		

		FaceManager.SetPlayerMuscle(player)
		if FaceManager.AddItemsFromData(player) then
			sendVisual(player)
			player:resetModelNextFrame()
			-- triggerEvent("OnClothingUpdated", player)
		end
	
		local CharCustomWindow = CharacterCustomisationPanel_Ingame:new()
		CharCustomWindow:initialise()
		CharCustomWindow:addToUIManager()
	
		CharCustomWindow:setX( (getCore():getScreenWidth()/2) - (CharCustomWindow:getWidth()/2) )
		CharCustomWindow:setY( (getCore():getScreenHeight()/2) - (CharCustomWindow:getHeight()/2) )
	
		--pause the game so the player doesnt get jumped by zombies
		if UIManager.getSpeedControls() then
			UIManager.getSpeedControls():SetCurrentGameSpeed(0)
			UIManager.setShowPausedMessage(false)
		end
		
		CharCustomWindow:OpenMenu(player)
	
	end
end


	-- -----------------------
	-- -- SUBSCRIBE TO EVENTS
	-- -----------------------
Events.OnNewGame.Add(onNewGame)
Events.OnCreatePlayer.Add(onCreatePlayer)