--[[
	Derivative of the character creation window but with functions for handling customisation ingame
]]

require("CharacterCustomisation/BodyDetailWindow/CharacterCustomisationPanel")
local base = CharacterCustomisationPanel
CharacterCustomisationPanel_Ingame = base:derive("CharacterCustomisationPanel_Ingame")

local FaceManager = require("CharacterCustomisation/FaceManager")
local FM_Data = require("CharacterCustomisation/FM_Data")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function CharacterCustomisationPanel_Ingame:new()
	local o = base.new(self)
	o.lockedOptionsVisible = false
	o.faceMenuVisible = true
	o.bodyDetailMenuVisible = true
	o.isIngame = true
	o.canClose = false
	o.previewItems = {}
	o.oldItems = {}
	o.otherItems = {}
	return o
end

--initialise the menu when it is opened
function CharacterCustomisationPanel_Ingame:OpenMenu(player)

    self.backgroundColor = {r=0,g=0,b=0,a=0.8}


	self.faceMenu:setVisible(self.faceMenuVisible)
	self.bodyDetailMenu:setVisible(self.bodyDetailMenuVisible)


	--hide the muscle tickbox if player choice is disabled
	self.muscleButton:setVisible(SandboxVars.SPNCharCustom.MuscleVisuals == 3)

	--hide the body hair tickbox if player choice is disabled
	self.hairButton:setVisible(SandboxVars.SPNCharCustom.BodyHairGrowthEnabled == 3)

	--tell the menus whether to show or hide locked options
	self:setLockedOptionsVisible(self.lockedOptionsVisible)

	self:setChar(player)
	self:syncDescVisuals()
	self:FillCustomisationWindow()
	self:SetPlayerCustomisationFromData()
end

function CharacterCustomisationPanel_Ingame:render()
	base.render(self)
	
	--we display text telling the player that changing face or details is disabled in sandbox settings
	local offset_x = self.faceMenu:getX() + (self.faceMenu:getWidth()/2)

	if not self.faceMenu:isVisible() then
		local offset_y = self.faceMenu:getY() + (self.faceMenu:getHeight()/2)
	
		self:drawTextCentre(getText("UI_characreation_facedisabled"), offset_x, offset_y, 1, 1, 1, 0.5, UIFont.Medium)
	end
	if not self.bodyDetailMenu:isVisible() then
		local offset_y = self.bodyDetailMenu:getY() + (self.bodyDetailMenu:getHeight()/2)
	
		self:drawTextCentre(getText("UI_characreation_detailsdisabled"), offset_x, offset_y, 1, 1, 1, 0.5, UIFont.Medium)
	end

end


--replace close buttons with save and cancel
function CharacterCustomisationPanel_Ingame:createCloseButton()
	-- Close button
	local hgt = FONT_HGT_SMALL*2
	local btnpadding = hgt/4
	local yoffset = self.avatarPanel:getBottom() + btnpadding

	local btnwidth = self:getWidth()/8
	-- local btnpadding = btnwidth/4

	self.saveButton = ISButton:new(self:getWidth()-btnwidth-btnpadding, yoffset, btnwidth,hgt, getText("UI_characreation_BuildSave"), self, self.closeSave)
	self.saveButton:initialise()
	self.saveButton:instantiate()
	self.saveButton:enableAcceptColor()
	self:addChild(self.saveButton)

	
	self.cancelButton = ISButton:new(0+btnpadding, yoffset, btnwidth,hgt, getText("UI_Cancel"), self, self.closeCancel)
	self.cancelButton:initialise()
	self.cancelButton:instantiate()
	self.cancelButton:enableCancelColor()
	self:addChild(self.cancelButton)
	
	self:setHeight(self:getHeight() + btnpadding + hgt + btnpadding)
end

--when this menu is closed we reset everything and then call the function assigned to self.onClose
function CharacterCustomisationPanel_Ingame:closeSave()
	self:close()
	--when we close the menu we apply the customisation to the player
	self:UpdatePlayerCustomisation()

	if self.onCloseSave then self.onCloseSave() end
end
function CharacterCustomisationPanel_Ingame:closeCancel()
	self:close()
	if self.onCloseCancel then self.onCloseCancel() end
end
function CharacterCustomisationPanel_Ingame:close()
    self:setVisible(false)
    self:removeFromUIManager()
    if UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
		UIManager.setShowPausedMessage(false)
    end
	if self.onClose then self.onClose() end
end


-- close menu when clicking outside of it (disabled)
function CharacterCustomisationPanel_Ingame:onMouseUp(x,y)
	if not self.canClose then return end
	
	if not (0 < x and 0 < y and x < self:getWidth() and y < self:getHeight()) then self:closeCancel() end
end

--when the player clicks an option in the menu we update the preview
function CharacterCustomisationPanel_Ingame:BodyDetailSelected()
	self:UpdatePreviewCustomisation()
end

--create temporary customisation items and then add them to the preview
function CharacterCustomisationPanel_Ingame:UpdatePreviewCustomisation()
	self.previewItems = {}
	
	local face = self.faceMenu:getSelectedOption()

	if face ~= nil and face.name ~= "DefaultFace" then
		local item = FaceManager.CreateItem(face.id, face.texture)
		table.insert(self.previewItems, item)
	end
	local selectedBodyDetails = self.bodyDetailMenu:getSelectedOptions()
	if selectedBodyDetails ~= nil then
		for i, v in pairs(selectedBodyDetails) do
			local item = FaceManager.CreateItem(v.id, v.texture)
			table.insert(self.previewItems, item)
		end
	end
	if self.otherPreviewItems ~= nil then
		for i, item in pairs(self.otherPreviewItems) do
			table.insert(self.previewItems, item)
		end
	end
	if self.muscleButton:isSelected() and self.musclePreviewItem then
		table.insert(self.previewItems, self.musclePreviewItem)
	end

	--send the worn customisation items to the preview avatars
	self:setPreviewBodyDetails(self.previewItems)
end

--create and equip all the customisation to the player
function CharacterCustomisationPanel_Ingame:UpdatePlayerCustomisation()
	local wornItems = self.char:getWornItems()
	
	--remove all the old customisation
	for i = 1, #self.oldItems, 1 do
		wornItems:remove(self.oldItems[i])
		self.char:getInventory():Remove(self.oldItems[i])
	end
	self.oldItems = {}
	
	--add the new items to the player
	self:doFace()
	self:doBodyDetails()

	self.data.bodyHairGrowthEnabled = self.hairButton:isSelected()

	self.data.muscleVisuals = self.muscleButton:isSelected()

	FaceManager.SetPlayerMuscle(self.char)
	
	self.char:resetModelNextFrame()
	triggerEvent("OnClothingUpdated", self.char)
end

function CharacterCustomisationPanel_Ingame:doFace()
	local face = self.faceMenu:getSelectedOption()
	if face == nil then
		FaceManager.SetPlayerFace(self.char, "DefaultFace")
		return
	end
	FaceManager.SetPlayerFace(self.char, face.name, face.id, face.texture)
end
function CharacterCustomisationPanel_Ingame:doBodyDetails()
	self.data.bodyDetails = {}

	local selectedBodyDetails = self.bodyDetailMenu:getSelectedOptions()
	if selectedBodyDetails == nil then return end
	for i, v in pairs(selectedBodyDetails) do
		local item = FaceManager.AddPlayerBodyDetail(self.char, v.name, v.id, v.texture, true)
	end
end

--when the menu is opened we read the players mod data to set the selected customisation options
function CharacterCustomisationPanel_Ingame:SetPlayerCustomisationFromData()
	self.data = self.char:getModData().SPNCharCustom
	self.skintone = self.char:getHumanVisual():getSkinTextureIndex()

	--GET EQUIPPED CUSTOMISATION ITEMS
	self:GetPlayerCustomisationItems()

	--SELECT OPTIONS
	local list = {}
	for i = 1, #self.data.bodyDetails, 1 do
		table.insert(list, self.data.bodyDetails[i].name)
	end
	self.bodyDetailMenu:setSelectedOptions(list)
	self.faceMenu:setSelectedOption(self.data.face.name)
	
	self.muscleButton:setSelected(self.data.muscleVisuals)
	self.hairButton:setSelected(self.data.bodyHairGrowthEnabled)
	
	self.otherPreviewItems = {}
	if self.otherItems ~= nil then
		for i, v in pairs(self.otherItems) do
			local item = FaceManager.CreateItem(v:getType(), v:getVisual():getBaseTexture())
			table.insert(self.otherPreviewItems, item)
		end
	end
	if self.muscleItem then
		self.musclePreviewItem = FaceManager.CreateItem(self.muscleItem:getType(), self.muscleItem:getVisual():getBaseTexture())
	else
		self.musclePreviewItem = self:CreatePreviewMuscleItem()
	end
	self:UpdatePreviewCustomisation()
end

--we get the actual items from the inventory so that they can be removed when we apply the new customisation
--we also grab the muscle and body hair to copy them
function CharacterCustomisationPanel_Ingame:GetPlayerCustomisationItems()
	self.oldItems = {}
	self.otherItems = {}

	--FACE
	local item = FaceManager.GetWornItemWithTag(self.char, "Face")
	table.insert(self.oldItems, item)

	--BODY DETAILS
	local list = FaceManager.GetWornItemsWithTag(self.char, "BodyDetail")
	for i = 1, #list, 1 do
		table.insert(self.oldItems, list[i])
	end

	--MUSCLE
	local item = FaceManager.GetWornItem(self.char, "Muscle")
	-- table.insert(self.otherItems, item)
	self.muscleItem = item

	--STUBBLE HEAD
	local item = FaceManager.GetWornItem(self.char, "StubbleHead")
	table.insert(self.otherItems, item)

	--STUBBLE BEARD
	local item = FaceManager.GetWornItem(self.char, "StubbleBeard")
	table.insert(self.otherItems, item)

	--BODY HAIR
	local item = FaceManager.GetWornItem(self.char, "BodyHair")
	table.insert(self.otherItems, item)
end

--i'd rather not have to do this but people will probably get confused if muscles don't change in the menu
function CharacterCustomisationPanel_Ingame:CreatePreviewMuscleItem()
	
	local muscleLevel = FaceManager.GetMuscleLevel(self.char:getPerkLevel(Perks.Strength))
	
	if muscleLevel <= 0 then return nil end

	local id = self.char:isFemale() and FM_Data.Muscle[2] or FM_Data.Muscle[1]
	
	local textureOffset = 0
	if muscleLevel == 2 then textureOffset = 5 end
	local texture = self.char:getHumanVisual():getSkinTextureIndex() + textureOffset
	
	local item = FaceManager.CreateItem(id, texture)

	return item
end


function CharacterCustomisationPanel_Ingame:FillCustomisationWindow()
	self:setFaceOptions(FM_Data.GetFacesForCharacter(self.char))
	self:setBodyDetailOptions(FM_Data.GetBodyDetailsForCharacter(self.char))
end
