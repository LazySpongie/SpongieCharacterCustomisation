
local FaceManager = require("CharacterCustomisation/FaceManager")
local FM_Data = require("CharacterCustomisation/FM_Data")

CharacterCreationMain.wornCustomisationItems = {}

local ihm_enabled = getActivatedMods():contains("improvedhairmenu")

	-- ---------------------------------
	-- -- ADD BODY DETAILS TO CHARACTER
	-- ---------------------------------
--refreshes the preview character by removing the previous body details and then adding the selected ones
function CharacterCreationMain:spn_update_character_customisation()
    local desc = MainScreen.instance.desc
	local wornItems = desc:getWornItems()
	
	--grab every customisation item equipped by the preview and remove them
	for i, v in ipairs(self.wornCustomisationItems) do
		wornItems:remove(v)
	end
	self.wornCustomisationItems = {}	--wipe the table so new items can be added
	
	--this isnt optimised but deleting and respawning the items is just easier
	self:spn_update_face()
	self:spn_update_body_details()
	self:spn_update_body_hair()
	self:spn_update_body_muscle()
	self:spn_equip_customisation_items()
	self:spn_store_character_data()
	
	self:spn_set_preview_bodydetails(self.wornCustomisationItems)
	
    CharacterCreationHeader.instance:setAvatarFromUI()
	
	--update improved hair menu
	if ihm_enabled then
		self:ihm_update_preview_model(desc)
	end
	
end
	--FACE
function CharacterCreationMain:spn_update_face()
	local face = self.characterCustomisationPanel.faceMenu:getSelectedOption()
	if face == nil then return end
	if face.name == "DefaultFace" then return end
	local item = FaceManager.CreateItem(face.id, face.texture)
	table.insert(self.wornCustomisationItems, item)
end
	--BODY DETAILS
function CharacterCreationMain:spn_update_body_details()
	local selectedBodyDetails = self.characterCustomisationPanel.bodyDetailMenu:getSelectedOptions()
	if selectedBodyDetails == nil then return end
	for i, bodydetail in pairs(selectedBodyDetails) do
		local item = FaceManager.CreateItem(bodydetail.id, bodydetail.texture)
		table.insert(self.wornCustomisationItems, item)
	end
end
	--BODY HAIR AND STUBBLE
function CharacterCreationMain:spn_update_body_hair()
    local desc = MainScreen.instance.desc
	local bodyHairOptions = CharacterCreationMain.instance.bodyHairOptions
	
	local function addBodyHair(itemName)
		local item = FaceManager.CreateItem(itemName, desc:getHumanVisual():getSkinTextureIndex())
		table.insert(self.wornCustomisationItems, item)
	end
	if bodyHairOptions.stubbleHead then
		addBodyHair(FM_Data.StubbleHead)
	end
	if bodyHairOptions.stubbleBeard then
		addBodyHair(FM_Data.StubbleBeard)
	end
	if bodyHairOptions.bodyHair then
		local name = desc:isFemale() and FM_Data.BodyHair[2] or FM_Data.BodyHair[1]
		addBodyHair(name)
	end
end
	--BODY MUSCLE
function CharacterCreationMain:spn_update_body_muscle()
	if SandboxVars.SPNCharCustom.MuscleVisuals == 2 or not self.characterCustomisationPanel.muscleButton:isSelected() then return end
    local desc = MainScreen.instance.desc
	
	local muscleLevel = self:spn_getMuscleLevel()
	
	if muscleLevel <= 0 then return end

	local id = desc:isFemale() and FM_Data.Muscle[2] or FM_Data.Muscle[1]
	
	local textureOffset = 0
	if muscleLevel == 2 then textureOffset = 5 end
	local texture = desc:getHumanVisual():getSkinTextureIndex() + textureOffset
	
	local item = FaceManager.CreateItem(id, texture)

	table.insert(self.wornCustomisationItems, item)
end
-- the players strength level is always displayed in the trait selection menu so we grab its value from the list
function CharacterCreationMain:spn_getMuscleLevel()
	if CharacterCreationProfession.instance.listboxXpBoost == nil then return 0 end
	for i,v in pairs(CharacterCreationProfession.instance.listboxXpBoost.items) do
		if v.text == PerkFactory.getPerkName(Perks.Strength) then
			return FaceManager.GetMuscleLevel(v.item.level)
		end
	end
	return 0
end
	--EQUIP ITEMS
function CharacterCreationMain:spn_equip_customisation_items()
    local desc = MainScreen.instance.desc
	if self.wornCustomisationItems == nil then return end
	for i, v in pairs(self.wornCustomisationItems) do
		desc:setWornItem(v:getBodyLocation(), v)
	end
end

--STORE CHARACTER DATA
--we store this in the client so that the customisation choices can be saved into the players mod data on startup
function CharacterCreationMain:spn_store_character_data()
	local clientData = require("CharacterCustomisation/CharacterCreation/StoredCharacterData")

	clientData.face = {name = "DefaultFace", id = "DefaultFace"}
	local face = self.characterCustomisationPanel.faceMenu:getSelectedOption()
	if face then
		clientData.face = {name = face.name, id = face.id, texture = face.texture}
	end
	local bodyDetails = {}
	local selectedBodyDetails = self.characterCustomisationPanel.bodyDetailMenu:getSelectedOptions()
	if selectedBodyDetails then
		for i,v in pairs(selectedBodyDetails) do
			local item = {name = v.name, id = v.id, texture = v.texture}
			table.insert(bodyDetails, item)
		end
	end
	clientData.bodyDetails = bodyDetails

	clientData.bodyHair = self.bodyHairOptions.bodyHair

	clientData.stubbleHead = self.bodyHairOptions.stubbleHead

	clientData.stubbleBeard = self.bodyHairOptions.stubbleBeard
	
	clientData.muscleVisuals = self.characterCustomisationPanel.muscleButton:isSelected()
	
	clientData.bodyHairGrowth = self.characterCustomisationPanel.hairButton:isSelected()
end


	-- ---------------------------------
	-- -- BODY DETAIL PREVIEW AVATAR
	-- ---------------------------------
-- updates preview in customisation window
function CharacterCreationMain:spn_set_preview_bodydetails(bodyDetails)
	if self.characterCustomisationPanel then 
		self.characterCustomisationPanel:setPreviewBodyDetails(bodyDetails)
	end
end
