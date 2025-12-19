--[[
	Based on Improved Hair Menu by duckduckquak

	This is a UI element that previews a customisation change
]]
require("CharacterCustomisation/BodyDetailWindow/ExtendedUI3DModel")
BodyDetailAvatar = ISUI3DModelExt:derive("BodyDetailAvatar")

local FaceManager = require("CharacterCustomisation/FaceManager")

function BodyDetailAvatar:new(x, y, width, height)
	local o = ISUI3DModelExt.new(self, x, y, width, height)
	o.visualItem = {name = "UNINITIALIZED", id = "UNINITIALIZED", texture = 0, selected = false, icon = nil,
					locked = false, direction = IsoDirections.S, zoom = 0, yoffset = 0, xoffset = 0}
	o.desc = nil
	o.cursor = false
	o.tooltipEnabled = false
	return o
end

function BodyDetailAvatar:instantiate()
	ISUI3DModelExt.instantiate(self)
	self:setState("idle")
	self:setIsometric(false)
	self:setViewSettings()
end
-- function BodyDetailAvatar:render()
-- 	ISUI3DModelExt.render(self)

-- end

function BodyDetailAvatar:setDesc(desc)
	self.desc = desc
end
function BodyDetailAvatar:setVisualItem(args)
	self.visualItem = args
end

function BodyDetailAvatar:applyVisual(selectedFace)
	--[[ XXX:
		Because visuals are a table reference, any changes we make to the preview avatar here will affect all other avatars.
		To work around this we need to make the changes we need, set the visual to the preview avatar, and then revert the changes we made

		This works because passing the visual to the 3d avatar makes a copy of the visual because of java stuff that i dont understand.
		Essentially when we call setSurvivorDesc() we are pushing the current visuals onto the preview avatar instead of passing a reference to them.
	 ]]
	if not self.visualItem.display then return end
	
	local visual = self.desc
	local wornItems = visual:getWornItems()
	local item = nil

	--if the avatar is for a face then we need to removes the equipped face
	local face
	if selectedFace and selectedFace.bodylocation then
		face = visual:getWornItem(selectedFace.bodylocation)
		wornItems:remove(face)
	end
	
	-- ADD THE ITEM TO THE PREVIEW
	if self.visualItem and self.visualItem.id ~= "" then
		item = instanceItem(self.visualItem.id)
		if item ~= nil then
			FaceManager.SetItemTexture(item, self.visualItem.texture)
			visual:setWornItem(item:getBodyLocation(), item)
		end
	end
	
	-- COPIES THE VISUAL TO THE AVATAR
	self:setSurvivorDesc(self.desc)

	--NOW WE RESET THE PREVIEW BACK TO DEFAULT!!!!!

	wornItems:remove(item)
	
	--need to have the original face added back as well
	if selectedFace and selectedFace.bodylocation then
		visual:setWornItem(selectedFace.bodylocation, face)
	end
end

function BodyDetailAvatar:setViewSettings()
	self:setDirection(self.visualItem.direction)
	self:setZoom(self.visualItem.zoom)
	self:setYOffset(self.visualItem.yoffset)
	self:setXOffset(self.visualItem.xoffset)
	
end

function BodyDetailAvatar:setCursor(state)
	self.cursor = state
	if not self.tooltipEnabled then return end
	if state == true then
		self:showTooltip()
	else
		self:hideTooltip()
	end
end

function BodyDetailAvatar:showTooltip()
	if not self.tooltipUI then
		self.tooltipUI = ISToolTip:new()
		self.tooltipUI:setOwner(self)
		self.tooltipUI:setVisible(false)
		self.tooltipUI:setAlwaysOnTop(true)
		self.tooltipUI.maxLineWidth = 300
	end
	if not self.tooltipUI:getIsVisible() then
		self.tooltipUI:addToUIManager()
		self.tooltipUI:setVisible(true)
	end
	self.tooltipUI.description = self.visualItem.display
	self.tooltipUI:setDesiredPosition(self:getAbsoluteX() + self:getWidth(), self:getAbsoluteY())
end

function BodyDetailAvatar:hideTooltip()
	if self.tooltipUI and self.tooltipUI:getIsVisible() then
		self.tooltipUI:setVisible(false)
		self.tooltipUI:removeFromUIManager()
	end
end
