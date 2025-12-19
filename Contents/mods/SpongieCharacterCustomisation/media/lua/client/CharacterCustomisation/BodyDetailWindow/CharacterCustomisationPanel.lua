--[[
	This is the actual menu element.

	By being a separate UI element it can be implemented in both the character creation menu and in-game hair options.
]]

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
-- local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
-- local header_height = FONT_HGT_SMALL + 14
-- local BUTTON_HGT = FONT_HGT_SMALL + 15

local icons = {
	iso_On = getTexture("media/textures/UI_Iso_On.png"),
	iso_Off = getTexture("media/textures/UI_Iso_Off.png"),

	zoom_Out = getTexture("media/textures/UI_Zoom_Out.png"),
	zoom_In = getTexture("media/textures/UI_Zoom_In.png"),
	
	hair_On = getTexture("media/textures/UI_Hair_On.png"),
	hair_Off = getTexture("media/textures/UI_Hair_Off.png"),
	
	muscle_On = getTexture("media/textures/UI_Muscle_On.png"),
	muscle_Off = getTexture("media/textures/UI_Muscle_Off.png"),
}

local base = ISPanelJoypad
CharacterCustomisationPanel = base:derive("CharacterCustomisationPanel")

function CharacterCustomisationPanel:new()
	local o = base.new(self, 0, 0, 0, 0)
	o.desc = nil
	o.char = nil
	o.previewDesc = nil
	o.isIngame = false
	return o
end

-- function CharacterCustomisationPanel:render()
-- 	base.render(self)
	
-- 	-- local height = getTextManager():MeasureFont(self.font);

-- 	-- self:drawText(getText("UI_characreation_charapanel"), 75, height/2, 1, 1, 1, 1, UIFont.Title)
-- end

function CharacterCustomisationPanel:initialise()
	-- we create a dummy survivor for the previews
---@diagnostic disable-next-line: param-type-mismatch
	self.previewDesc = SurvivorFactory:CreateSurvivor()
	self.previewDesc:setForename("Preview")
	self.previewDesc:setSurname("McPreviewPants")
	
	local screen_width = getCore():getScreenWidth()
	local screen_height = getCore():getScreenHeight()

	-- local width_modifier = screen_width / 1920
	-- local height_modifier = screen_height / 1080
	
	--cap the menu sizes at 1080p because it breaks ultra widescreen
	local width_modifier = math.min(screen_width / 1920, 1)
	local height_modifier = math.min(screen_height / 1080, 1)

	local avatar_size = 150 * height_modifier
	local tickbox_size = 32
	local tickbox_padding = 12

	local comboHgt = FONT_HGT_SMALL + 3 * 2

	local avatarPanel_header = comboHgt*2
	local avatarPanel_width = 300 * width_modifier
	local avatarPanel_height = (600 + comboHgt) * height_modifier

	local avatarPanel_aspectratio = avatarPanel_width/avatarPanel_height

	local offset_x = 0
	local offset_y = 0

	--preview avatar
	self.avatarPanel = ISUI3DModel:new(offset_x, offset_y + avatarPanel_header, avatarPanel_width, avatarPanel_height)
	self.avatarPanel.backgroundColor = {r=0, g=0, b=0, a=0}
	self.avatarPanel.borderColor = {r=1, g=1, b=1, a=0}
	self:addChild(self.avatarPanel)
	self.avatarPanel:setDirection(IsoDirections.S)
	self.avatarPanel:setState("idle")
	self.avatarPanel:setIsometric(false)
	self.avatarPanel:setDoRandomExtAnimations(false)
	

	--TICKBOXES
	offset_x = 0 + tickbox_padding
	offset_y = 0 + tickbox_padding

	
	--muscle tickbox
	self.muscleButton = ISButtonImage:new(offset_x, offset_y, tickbox_size, tickbox_size, icons.muscle_On, icons.muscle_Off, self, self.BodyDetailSelected)
	self.muscleButton:initialise()
	self.muscleButton:instantiate()
	self:addChild(self.muscleButton)
	self.muscleButton.tooltip = getText("Tooltip_Muscle")


	offset_x = offset_x + tickbox_padding + tickbox_size

	--body hair tickbox
	self.hairButton = ISButtonImage:new(offset_x, offset_y, tickbox_size, tickbox_size, icons.hair_On, icons.hair_Off, self)
	self.hairButton:initialise()
	self.hairButton:instantiate()
	self:addChild(self.hairButton)
	self.hairButton.tooltip = getText("Tooltip_BodyHairGrowth")
	

	--VIEW BUTTONS

	offset_x = self.avatarPanel:getRight() - tickbox_padding - (tickbox_size/2)
	offset_y = self.avatarPanel:getBottom() - tickbox_padding

	--iso button
	self.isoButton = ISButtonImage:new(offset_x, offset_y, tickbox_size, tickbox_size, icons.iso_On, icons.iso_Off, self, self.setIso)
	self.isoButton:initialise()
	self.isoButton:instantiate()
	self:addChild(self.isoButton)
	-- self.isoButton.tooltip = getText("Tooltip_Isometric")


	--zoom buttons
	offset_y = offset_y - tickbox_padding - tickbox_size

	self.zoomOutButton = ISButton:new(offset_x, offset_y, tickbox_size, tickbox_size, "", self, self.onZoomButton)
	self.zoomOutButton.internal = "OUT"
	self.zoomOutButton:initialise()
	self.zoomOutButton:instantiate()
	self.zoomOutButton:setImage(icons.zoom_Out)
	self:addChild(self.zoomOutButton)

	offset_y = offset_y - tickbox_padding - tickbox_size

	self.zoomInButton = ISButton:new(offset_x, offset_y, tickbox_size, tickbox_size, "", self, self.onZoomButton)
	self.zoomInButton.internal = "IN"
	self.zoomInButton:initialise()
	self.zoomInButton:instantiate()
	self.zoomInButton:setImage(icons.zoom_In)
	self:addChild(self.zoomInButton)

	self.zoomLevel = 0
	self:setAvatarZoom()


	--MENUS 

	--face menu

	offset_x = self.avatarPanel:getRight()
	offset_y = 0
	
	self.faceMenu = BodyDetailMenuPanel:new(offset_x, offset_y, avatar_size, avatar_size, 2, 6, 3)
	self:addChild(self.faceMenu)
	self.faceMenu.onSelect = function(info)
		
		self:BodyDetailSelected()	-- an option has been pressed so we update the character body details
		
	end
	self.faceMenu:initialise()
	self.faceMenu.label = getText("UI_characreation_face")
	self.faceMenu.tooltipEnabled = true
	self.faceMenu.isFacePanel = true
	
	offset_y = self.faceMenu:getBottom()
	
	--body detail menu
	self.bodyDetailMenu = BodyDetailMenuPanel:new(offset_x, offset_y, avatar_size, avatar_size, 2, 6, 3)
	self:addChild(self.bodyDetailMenu)
	self.bodyDetailMenu.onSelect = function(info)
		
		self:BodyDetailSelected()	-- an option has been pressed so we update the character body details
		
	end
	self.bodyDetailMenu:initialise()
	self.bodyDetailMenu.label = getText("UI_characreation_bodydetail")
	self.bodyDetailMenu.tooltipEnabled = true
	self.bodyDetailMenu.isExclusive = false
	
	
	self:setHeight(self.bodyDetailMenu:getHeight() + self.faceMenu:getHeight())

	self.avatarPanel:setHeight(self:getHeight() - avatarPanel_header)
	self.avatarPanel:setWidth(self.avatarPanel:getHeight() * avatarPanel_aspectratio)

	local offset_x = self.avatarPanel:getRight()
	self.faceMenu:setX(offset_x)
	self.bodyDetailMenu:setX(offset_x)

	self:setWidth(self.bodyDetailMenu:getWidth() + self.avatarPanel:getWidth())
	
	-- we make this a function because the ingame menu needs to replace it with a save and cancel button
	self:createCloseButton()

	self.backgroundColor = {r=0,g=0,b=0,a=1}


	--set visuals
	self:setAvatarDescs()

end
function CharacterCustomisationPanel:createCloseButton()
	-- Close button
	local hgt = FONT_HGT_SMALL*2
	local btnpadding = hgt/4
	local yoffset = self.bodyDetailMenu:getBottom() + btnpadding

	local btnwidth = self:getWidth() - (btnpadding*2)

	--move this to the middle of the menu?
	self.saveButton = ISButton:new(btnpadding, yoffset, btnwidth,hgt, getText("UI_Close"), self, self.close)
	self.saveButton:initialise()
	self.saveButton:instantiate()
	self:addChild(self.saveButton)
	
	self:setHeight(self:getHeight() + btnpadding + hgt + btnpadding)
end


--toggle iso
function CharacterCustomisationPanel:setIso(button,x,y)
	local isSelected = self.isoButton.internal == "ON"

	if isSelected then
		self.isoButton.internal = "OFF" 
		self.isoButton:setImage(icons.iso_Off)
	else 
		self.isoButton.internal = "ON" 
		self.isoButton:setImage(icons.iso_On)
	end

	self.avatarPanel:setIsometric(not isSelected)	--invert the selection
end


local ZoomSettings = {
	maxZoom = 18,
	maxY = -0.875,

	minZoom = 0,
	minY = -0.5,

	zoomlevels = 4,
}
local zoom_step = (ZoomSettings.maxZoom - ZoomSettings.minZoom)/ZoomSettings.zoomlevels
local y_step = (ZoomSettings.maxY - ZoomSettings.minY)/ZoomSettings.zoomlevels

function CharacterCustomisationPanel:onZoomButton(button,x,y)
	local oldZoomLevel = self.zoomLevel

	if button.internal == "IN" and self.zoomLevel ~= ZoomSettings.zoomlevels then
		self.zoomLevel = self.zoomLevel + 1
	elseif button.internal == "OUT"  and self.zoomLevel ~= 0 then 
		self.zoomLevel = self.zoomLevel - 1
	end

	if oldZoomLevel == self.zoomLevel then return end
	self:setAvatarZoom()
end
function CharacterCustomisationPanel:setAvatarZoom()
	local newZoom = ZoomSettings.minZoom + (zoom_step*self.zoomLevel)
	local newY = ZoomSettings.minY + (y_step*self.zoomLevel)

	self.avatarPanel:setYOffset(newY)
	self.avatarPanel:setZoom(newZoom)
end


function CharacterCustomisationPanel:syncDescVisuals()
	local previewVisual = self.previewDesc:getHumanVisual()
	
	local visual = nil
	local isFemale = false
	if self.desc then
		visual = self.desc:getHumanVisual()
		isFemale = self.desc:isFemale()
	elseif self.char then
		visual = self.char:getHumanVisual()
		isFemale = self.char:isFemale()
	else
		return
	end
	
	self.previewDesc:setFemale(isFemale)
	previewVisual:setSkinTextureIndex(visual:getSkinTextureIndex())
	previewVisual:setBeardModel(visual:getBeardModel())
	previewVisual:setBeardColor(visual:getBeardColor())
	previewVisual:setHairModel(visual:getHairModel())
	previewVisual:setHairColor(visual:getHairColor())
end
function CharacterCustomisationPanel:setPreviewBodyDetails(wornCustomisationItems)
	local wornItems = self.previewDesc:getWornItems()
	
	wornItems:clear()
	
	--BODY DETAILS
	for i = 1, #wornCustomisationItems, 1 do
		local v = wornCustomisationItems[i]
		self.previewDesc:setWornItem(v:getBodyLocation(), v)
	end
	
	--we need to apply the new preview visual to the avatars
	self:setAvatarDescs()
end

--here we prepare the preview visual before we send it to the avatars
function CharacterCustomisationPanel:setAvatarDescs()
	--we set the main avatar panel first so that it shows all of the customisation
	if self.avatarPanel then
		self.avatarPanel:setSurvivorDesc(self.previewDesc)
	end

	--Here we need to make sure that the preview avatars only show the items that they need to preview
	--face should show in the previews

	--get the face
	local faceLocation = "Face"
	local face = self.faceMenu:getSelectedOption()
	if face and face.bodylocation then
		faceLocation = face.bodylocation
	end
	local face = self.previewDesc:getWornItem(faceLocation)
	--remove all other items
	self.previewDesc:getWornItems():clear()
	--readd the face
	if face then self.previewDesc:setWornItem(faceLocation, face) end
	
	--we need to refresh the customisation on the preview avatars
	self:applyVisual()
end

--here we send the preview visuals to all of the avatars
function CharacterCustomisationPanel:applyVisual()
	if self.faceMenu then
		self.faceMenu:setDesc(self.previewDesc)
		self.faceMenu:applyVisual()
	end
	if self.bodyDetailMenu then
		self.bodyDetailMenu:setDesc(self.previewDesc)
		self.bodyDetailMenu:applyVisual()
	end
end

function CharacterCustomisationPanel:refreshOptions()
	if self.bodyDetailMenu then 
		self.bodyDetailMenu:refreshOptions()
	end
	if self.faceMenu then 
		self.bodyDetailMenu:refreshOptions()
	end
end
function CharacterCustomisationPanel:setSelectedBodyDetails(names)
	if not self.bodyDetailMenu then return end
	self.bodyDetailMenu:setSelectedOptions(names)
end
function CharacterCustomisationPanel:clearSelectedBodyDetails()
	if not self.bodyDetailMenu then return end
	self.bodyDetailMenu:setSelectedOptions({})
end
function CharacterCustomisationPanel:setSelectedFace(name)
	if not self.faceMenu then return end
	self.faceMenu:setSelectedOption(name)
end
function CharacterCustomisationPanel:setFaceOptions(list)
	if not self.faceMenu then return end
	self.faceMenu:setOptions(list)
end
function CharacterCustomisationPanel:setBodyDetailOptions(list)
	if not self.bodyDetailMenu then return end
	self.bodyDetailMenu:setOptions(list)
end
function CharacterCustomisationPanel:setDesc(desc)
	self.desc = desc
	self.char = nil
end
function CharacterCustomisationPanel:setChar(desc)
	self.desc = nil
	self.char = desc
end

function CharacterCustomisationPanel:BodyDetailSelected()
	if self.onBodyDetailSelected then self.onBodyDetailSelected() end
end


--toggle iso
function CharacterCustomisationPanel:setLockedOptionsVisible(visible)
	self.faceMenu.lockedOptionsVisible = visible
	self.bodyDetailMenu.lockedOptionsVisible = visible
	self:refreshOptions()
end


-- ##########
-- # Cursor #
-- ##########

function CharacterCustomisationPanel:onMouseUp(x,y)
	base.onMouseUp(self,x,y)
	if not (0 < x and 0 < y and x < self:getWidth() and y < self:getHeight()) then self:close() end
end

function CharacterCustomisationPanel:close()
	if self.onClose then self.onClose() end
end
function CharacterCustomisationPanel:closeSave()
	self:close()
	if self.onCloseSave then self.onCloseSave() end
end
function CharacterCustomisationPanel:closeCancel()
	self:close()
	if self.onCloseCancel then self.onCloseCancel() end
end





-- ##############
-- # CONTROLLER #
-- ##############

function CharacterCustomisationPanel:setJoypadFocused(focused, joypadData)
	--self.bodyDetailMenu:setJoypadFocused(focused, joypadData)
end
