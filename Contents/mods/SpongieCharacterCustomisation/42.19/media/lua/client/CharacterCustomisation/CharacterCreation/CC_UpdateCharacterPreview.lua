
local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
local SPNCC_Data = require("CharacterCustomisation/SPNCC_Data")

local function spn_getClientData()
	local ok, data = pcall(require, "CharacterCustomisation/CharacterCreation/StoredCharacterData")
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

CharacterCreationMain.wornCustomisationItems = {}

	-- ---------------------------------
	-- -- ADD BODY DETAILS TO CHARACTER
	-- ---------------------------------
--refreshes the preview character by removing the previous body details and then adding the selected ones
function CharacterCreationMain:spn_update_character_customisation()
	if not MainScreen.instance or not MainScreen.instance.desc then
		return
	end
	self:spn_remove_items()
	
	--this isnt optimised but deleting and respawning the items is just easier
	self:spn_update_face()
	self:spn_update_body_details()
	self:spn_update_body_hair()
	self:spn_update_body_muscle()
	self:spn_equip_customisation_items()
	self:spn_store_character_data()
	
	self:spn_set_preview_bodydetails(self.wornCustomisationItems)
	
    self:setAvatarFromUI()
	
end

function CharacterCreationMain:spn_remove_items()
    local desc = MainScreen.instance.desc
	local wornItems = desc:getWornItems()
	
	--grab every customisation item equipped by the preview and remove them
	for i, v in ipairs(self.wornCustomisationItems) do
		wornItems:remove(v)
	end
	self.wornCustomisationItems = {}
end

	--FACE
function CharacterCreationMain:spn_update_face()
	local face = nil
	if self.characterCustomisationPanel and self.characterCustomisationPanel.faceMenu then
		face = self.characterCustomisationPanel.faceMenu:getSelectedOption()
	end

	if not face or face.name == "DefaultFace" then
		return
	end

	if not face.id or face.id == "" or face.id == "DefaultFace" then
		return
	end

	local item = FaceManager_Shared.CreateItem(face.id, face.texture or 0)
	table.insert(self.wornCustomisationItems, item)
end

	--BODY DETAILS
function CharacterCreationMain:spn_update_body_details()
	if not self.characterCustomisationPanel or not self.characterCustomisationPanel.bodyDetailMenu then
		return
	end

	local selectedBodyDetails = self.characterCustomisationPanel.bodyDetailMenu:getSelectedOptions()
	if selectedBodyDetails == nil then return end

	for _, bodydetail in pairs(selectedBodyDetails) do
		if bodydetail and bodydetail.id then
			local item = FaceManager_Shared.CreateItem(bodydetail.id, bodydetail.texture or 0)
			table.insert(self.wornCustomisationItems, item)
		end
	end
end

	--BODY HAIR AND STUBBLE
function CharacterCreationMain:spn_update_body_hair()
	if not self.hairStubbleTickBox then return end
	
    local desc = MainScreen.instance.desc
	local bodyHairOptions = self.bodyHairOptions

	bodyHairOptions.stubbleHead = self.hairStubbleTickBox:isSelected(1)
	bodyHairOptions.stubbleBeard = self.beardStubbleTickBox:isSelected(1)
	bodyHairOptions.bodyHair = self.chestHairTickBox:isSelected(1)
	
	local function addBodyHair(itemName)
		local item = FaceManager_Shared.CreateItem(itemName, desc:getHumanVisual():getSkinTextureIndex())
		table.insert(self.wornCustomisationItems, item)
	end
	if bodyHairOptions.stubbleHead then
		addBodyHair(SPNCC_Data.StubbleHead)
	end
	if bodyHairOptions.stubbleBeard then
		addBodyHair(SPNCC_Data.StubbleBeard)
	end
	if bodyHairOptions.bodyHair then
		local name = desc:isFemale() and SPNCC_Data.BodyHair[2] or SPNCC_Data.BodyHair[1]
		addBodyHair(name)
	end
end
	--BODY MUSCLE
function CharacterCreationMain:spn_update_body_muscle()
	local sandbox = SandboxVars and SandboxVars.SPNCharCustom
	if sandbox and sandbox.MuscleVisuals == 2 then
		return
	end

	local enabled = false
	if self.characterCustomisationPanel and self.characterCustomisationPanel.muscleButton then
		enabled = self.characterCustomisationPanel.muscleButton:isSelected()
	end

	if not enabled then
		return
	end

	local desc = MainScreen.instance.desc
	local muscleLevel = self:spn_getMuscleLevel()
	if muscleLevel <= 0 then return end

	local id = desc:isFemale() and SPNCC_Data.Muscle[2] or SPNCC_Data.Muscle[1]

	local textureOffset = 0
	if muscleLevel == 2 then
		textureOffset = 5
	end
	local texture = desc:getHumanVisual():getSkinTextureIndex() + textureOffset

	local item = FaceManager_Shared.CreateItem(id, texture)
	table.insert(self.wornCustomisationItems, item)
end

-- the players strength level is always displayed in the trait selection menu so we grab its value from the list
function CharacterCreationMain:spn_getMuscleLevel()
	if CharacterCreationProfession.instance.listboxXpBoost == nil then return 0 end
	for i,v in pairs(CharacterCreationProfession.instance.listboxXpBoost.items) do
		if v.text == PerkFactory.getPerkName(Perks.Strength) then
			return FaceManager_Shared.GetMuscleLevel(v.item.level)
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
	local clientData = spn_getClientData()
	if not clientData then
		return
	end

	clientData.bodyHair = self.bodyHairOptions and self.bodyHairOptions.bodyHair == true
	clientData.stubbleHead = self.bodyHairOptions and self.bodyHairOptions.stubbleHead == true
	clientData.stubbleBeard = self.bodyHairOptions and self.bodyHairOptions.stubbleBeard == true

	if self.characterCustomisationPanel and self.characterCustomisationPanel.faceMenu and self.characterCustomisationPanel.bodyDetailMenu then
		clientData.face = { name = "DefaultFace", id = "DefaultFace", texture = 0 }

		local face = self.characterCustomisationPanel.faceMenu:getSelectedOption()
		if face then
			clientData.face = { name = face.name, id = face.id, texture = face.texture }
		end

		local bodyDetails = {}
		local selectedBodyDetails = self.characterCustomisationPanel.bodyDetailMenu:getSelectedOptions()
		if selectedBodyDetails then
			for _, v in pairs(selectedBodyDetails) do
				table.insert(bodyDetails, { name = v.name, id = v.id, texture = v.texture })
			end
		end
		clientData.bodyDetails = bodyDetails

		clientData.muscleVisuals = self.characterCustomisationPanel.muscleButton:isSelected()
		clientData.bodyHairGrowth = self.characterCustomisationPanel.hairButton:isSelected()
		return
	end

	clientData.face = clientData.face or { name = "DefaultFace", id = "DefaultFace", texture = 0 }
	clientData.bodyDetails = clientData.bodyDetails or {}
	if clientData.muscleVisuals == nil then
		clientData.muscleVisuals = true
	end
	if clientData.bodyHairGrowth == nil then
		clientData.bodyHairGrowth = true
	end
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
