local FM_Data = require("CharacterCustomisation/FM_Data")
require("CharacterCustomisation/CharacterCreation/CC_UpdateCharacterPreview")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local BUTTON_HGT = FONT_HGT_SMALL + 6

--When the gender or skintone is changed we need to re-fill all the windows and then update the character with new customisation items
function CharacterCreationMain:refreshCustomisationWindow()
	--tell the menus to show or hide locked options
	self.characterCustomisationPanel:setLockedOptionsVisible(isDebugEnabled() or (isClient() and isAdmin()))
	-- self.characterCustomisationPanel:refreshOptions()

	self:spn_populate_customisation_window()
	
    self:spn_update_character_customisation()
end

-- Fill all combo boxes
function CharacterCreationMain:spn_populate_customisation_window()
	local desc = MainScreen.instance.desc
	
	local list = FM_Data.GetFacesForCharacter(desc)
	self.characterCustomisationPanel:setFaceOptions(list)
	
	local list = FM_Data.GetBodyDetailsForCharacter(desc)
	self.characterCustomisationPanel:setBodyDetailOptions(list)
end

function CharacterCreationMain:createCharacterCustomisationWindow()
	local comboHgt = FONT_HGT_SMALL + 3 * 2
	
	--create the character customisation window
	self.characterCustomisationPanel = CharacterCustomisationPanel:new()
	
	self.characterCustomisationPanel.onBodyDetailSelected = function(info)
		-- a body detail has been clicked so we need to refresh the body detail visuals
		self:spn_update_character_customisation()
	end
	self.characterCustomisationPanel:initialise()
	
	self.characterCustomisationPanel:setDesc(MainScreen.instance.desc)
	
	
	self.characterCustomisationPanel.onClose = function()
		CharacterCreationMain.instance:removeChild(self.characterCustomisationPanel)
		self.characterCustomisationPanel:setCapture(false)
		self.customisationButton.expanded = false
		--self.customisationButton.attachedMenu:setJoypadFocused(false, nil)
	end
	
	local function showMenu(target)
		self.customisationButton.expanded = true
		--target.customisationButton.attachedMenu:setJoypadFocused(true, nil)


		--hide the muscle tickbox if player choice is disabled
		self.characterCustomisationPanel.muscleButton:setVisible(SandboxVars.SPNCharCustom.MuscleVisuals == 3)

		--hide the body hair tickbox if player choice is disabled
		self.characterCustomisationPanel.hairButton:setVisible(SandboxVars.SPNCharCustom.BodyHairGrowthEnabled == 3)

		self.characterCustomisationPanel:syncDescVisuals()
		self.characterCustomisationPanel:setAvatarDescs()
		self.characterCustomisationPanel:setPreviewBodyDetails(self.wornCustomisationItems)
		
		self:removeChild(self.characterCustomisationPanel)
		self:addChild(self.characterCustomisationPanel)

		local width = CharacterCreationMain.instance:getWidth()
		local height = CharacterCreationMain.instance:getHeight()
		self.characterCustomisationPanel:setX( (width/2) - (self.characterCustomisationPanel:getWidth()/2) )
		self.characterCustomisationPanel:setY( (height/2) - (self.characterCustomisationPanel:getHeight()/2) )

		self.characterCustomisationPanel:setCapture(true)
	end

	local customisationButtonWidth = self.voiceDemoButton:getWidth() * 0.6
	
    self.offsetX = self.voiceDemoButton.x + (self.voiceDemoButton:getWidth()/2) - (customisationButtonWidth/2)
    self.offsetY = self.skinColorButton.y

	--create the button that will open the menu
	self.customisationButton = ISButton:new(self.offsetX, self.offsetY, customisationButtonWidth, BUTTON_HGT, getText("UI_characreation_charapanel"), self, showMenu)
	self.customisationButton:initialise()
	self.customisationButton:instantiate()
	self.customisationButton.isButton = nil -- NOTE: We don't want this button to be picked up by the vanilla joypad functions
	self.customisationButton.expanded = false
	self.customisationButton.attachedMenu = self.characterCustomisationPanel
	-- local setJoypadFocused = self.customisationButton.setJoypadFocused
	-- self.customisationButton.setJoypadFocused = function(self, focused, joypadData)
	-- 	-- XXX: Do we close the dialog if the button loses focus?
	-- 	-- self.focused = focused
	-- 	-- if self.expanded then
	-- 	-- 	self.attachedMenu:setJoypadFocused(focused, joypadData)
	-- 	-- else
	-- 	-- 	self.attachedMenu:setJoypadFocused(false, joypadData)
	-- 	-- end
	-- 	-- setJoypadFocused(self, focused, joypadData)
	-- end
	self.characterPanel:addChild(self.customisationButton)

end


	-- ----------------------
	-- -- ADD BUTTONS TO MENU
	-- ----------------------
local originalCharacterCreationMainCreate = CharacterCreationMain.create
---@diagnostic disable-next-line: duplicate-set-field
function CharacterCreationMain.create(self)
    originalCharacterCreationMainCreate(self)
	
	--Create char custom window
	self:createCharacterCustomisationWindow()
	
	--Fill menus with options
	self:spn_populate_customisation_window()
	
	self:spn_randomise_face()
	-- self:spn_randomise_details()
	self:spn_update_character_customisation()
end


-- Set customisation when the char creation menu is opened
local originalCharacterCreationMainSetVisible = CharacterCreationMain.setVisible
---@diagnostic disable-next-line: duplicate-set-field
function CharacterCreationMain:setVisible(bVisible, joypadData)
	originalCharacterCreationMainSetVisible(self, bVisible, joypadData)

	if bVisible and MainScreen.instance.desc then

		--set visible muscles when sandbox settings are changed
		self.characterCustomisationPanel.muscleButton:setSelected(SandboxVars.SPNCharCustom.MuscleVisuals ~= 2)
		self.characterCustomisationPanel.hairButton:setSelected(SandboxVars.SPNCharCustom.BodyHairGrowthEnabled ~= 2)

		self:refreshCustomisationWindow()
	end
end