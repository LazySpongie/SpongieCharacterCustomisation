--[[
	Based on Improved Hair Menu by duckduckquak

	This is the actual menu element.

	By being a separate UI element it can be reused for faces and body details.
]]

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local header_height = FONT_HGT_SMALL + 14

local function predicateAvatarIsSelectable(avatar)
	return avatar and avatar.selectable == true
end

local base = ISPanelJoypad
BodyDetailMenuPanel = base:derive("BodyDetailMenuPanel")


local SpnCharCustomMath = require("CharacterCustomisation/BodyDetailWindow/Math")

--ICONS
local texture_locked = getTexture("media/textures/Item_Padlock.png")
local texture_vision = getTexture("media/textures/CC_Vision.png")
local icon_size = 32
local icon_padding = 2


function BodyDetailMenuPanel:render()
	base.render(self)

	local fnt_height = getTextManager():MeasureFont(self.font);

	local y_off = fnt_height/2
	local x_off = self.pageRightButton:getRight()

	x_off = x_off + 10
	self:drawText(self.pageCurrent .. "/" .. self:getNumberOfPages(), x_off, y_off, 0.9, 0.9, 0.9, 0.9, UIFont.Small)

	x_off = self.width/2

	if self.showMenuName then
		self:drawTextCentre(getText(self.label), x_off, y_off-3, 1, 1, 1, 0.9, UIFont.Medium)
	end

	--RENDER THE ICONS AND BORDERS
	--doing this here is scuffed but doing it in the avatars themselves causes them to render below the character 
	for i, avatar in ipairs(self.avatarList) do
		if avatar:isVisible() and avatar.visualItem then
			local x_pos = avatar.x
			local y_pos = avatar.y + icon_padding

			--customisable icon
			if avatar.visualItem.icon ~= "" then
				x_pos = x_pos + icon_padding
				local tex = avatar.visualItem.icon
				self:drawTextureScaled(tex, x_pos, y_pos, icon_size, icon_size, 1, 1, 1, 1)
			end

			if avatar.visualItem.visionModifier then
				x_pos = avatar.x + icon_padding + icon_size + icon_padding
				self:drawTextureScaled(texture_vision, x_pos, y_pos, icon_size, icon_size, 1, 1, 1, 1)
			end

			--locked icon
			if avatar.visualItem.locked then
				x_pos = avatar:getWidth() - icon_size - icon_padding
				self:drawTextureScaled(texture_locked, x_pos, y_pos, icon_size, icon_size, 0.5, 1, 1, 1)
			end
			--regular border
			self:drawRectBorder(avatar.x, avatar.y, avatar.width, avatar.height, 1, 0.3, 0.3, 0.3) 

			--selected green border
			if self.selectedOptions[avatar.visualItem.name] then self:drawRectBorder(avatar.x, avatar.y, avatar.width, avatar.height, 1,0,1,0) end
			
			--hovered white border
			if avatar.cursor == true then
				if self.selectedOptions[avatar.visualItem.name] then
					self:drawRectBorder(avatar.x+1, avatar.y+1, avatar.width-2, avatar.height-2, 0.5,1,1,1)
				else
					self:drawRectBorder(avatar.x, avatar.y, avatar.width, avatar.height, 0.5,1,1,1)
				end
			end

		end
	end

end

function BodyDetailMenuPanel:new(x, y, size_x, size_y, rows, cols, gap)
	size_x = size_x or 96
	size_y = size_y or 96
	rows   = rows or 2
	cols   = cols or 4
	gap    = gap or 3

	local o = base.new(self, x, y, (size_x * cols) + (gap * (cols+3)) , (size_y * rows) + (gap * (rows+3)) + header_height)
	o.gridSizeX = size_x
	o.gridSizeY = size_y
	o.gridRows   = rows
	o.gridCols   = cols
	o.pageSize = (rows * cols)
	o.gap = gap
	o.label = ""
	o.avatarList = {}
	o.options = {} -- itemData stored here, DICTIONARY
	o.pageCurrent = 1
	o.onSelect = nil -- Callback
	o.showMenuName = true
	o.isFacePanel = false	--sets the current panel to only have one selected option at a time
	o.lockedOptionsVisible = false
	o.joypadCursor = 1
	o.tooltipEnabled = false
	o.selectedOptions = {} -- selected body details, DICTIONARY
	o.selectedBodylocations = {} -- body locations that are already selected. only used for items with isMultiItem set to false
	return o
end

function BodyDetailMenuPanel:initialise()
	local fnt_height = getTextManager():MeasureFont(self.font);

	self.offset_x = 0
	self.offset_y = fnt_height/2

	self.pageLeftButton = ISButton:new(5, self.offset_y, 15, 15, "", self, self.onChangePageButton)
	self.pageLeftButton.internal = "PREV"
	self.pageLeftButton:initialise()
	self.pageLeftButton:instantiate()
	self.pageLeftButton:setImage(getTexture("media/ui/ArrowLeft.png"))
	self:addChild(self.pageLeftButton)
	
	self.pageRightButton = ISButton:new(self.pageLeftButton:getRight() + 5, self.offset_y, 15, 15, "", self, self.onChangePageButton)
	self.pageRightButton.internal = "NEXT"
	self.pageRightButton:initialise()
	self.pageRightButton:instantiate()
	self.pageRightButton:setImage(getTexture("media/ui/ArrowRight.png"))
	self:addChild(self.pageRightButton)

	--[[ NOTE:
		Here we create the page, there is only one page of avatars to reduce
		the number of 3d models.
		
		By loading the items onto these avatars when switching pages we 
		can save some resources.
	 ]]

	self.offset_x = 0 + (self.gap * 2)
	self.offset_y = self.offset_y + 20 + (self.gap * 2)
	for h=1,self.gridRows do
		for v=1,self.gridCols do
			local idx = ((h-1)*self.gridCols) + v
			
			local x = (self.offset_x + ((v-1) * self.gridSizeX)) + (self.gap*(v-1))
			local y = (self.offset_y + ((h-1) * self.gridSizeY)) + (self.gap*(h-1))
			local bodyDetailAvatar = BodyDetailAvatar:new(x, y, self.gridSizeX, self.gridSizeY)
			bodyDetailAvatar:initialise()
			bodyDetailAvatar:instantiate()
			bodyDetailAvatar:setVisible(true)
			bodyDetailAvatar.panelIndex = idx
			bodyDetailAvatar.onSelect = function(bodyDetailAvatar)
				self:onAvatarSelect(bodyDetailAvatar)
			end

			bodyDetailAvatar.onMouseMove = function(avatar, x, y)
				BodyDetailAvatar.onMouseMove(avatar, x, y)
				--[[ NOTE:XXX:
					There used to be a `containsPoint` check here. it only worked on the main menu or in-game depending on who called `containsPoint`
					but `onMouseMove` only gets called if the mouse is inside the element anyway so it already fulfilled the purpose of the check.
				 ]]

				--[[ XXX:
					It seems like it's not possible to make dragging not change the tooltip. I think the onMouseMove functions
					aren't being called correctly leading to weird behaviour.
					
					ISUI3DModel has this comment in the onMouseMoveOutside function
					"This shouldn't happen, but the way setCapture() works is broken."
					
					So I don't think this one is on me.
				 ]]

				self:setCursor(avatar.panelIndex)
			end

			-- NOTE: If this avatar is the cursor then it should set let the panel know when it loses focus.
			bodyDetailAvatar.onMouseMoveOutside = function(avatar, x, y)
				BodyDetailAvatar.onMouseMoveOutside(avatar, x, y)
				if self.joypadFocus then return end
				if self.joypadCursor == avatar.panelIndex then
					self:setCursor(nil)
				end
			end

			self:addChild(bodyDetailAvatar)
			self.avatarList[idx] = bodyDetailAvatar
		end
	end
	
	
	self.offset_y = self.offset_y + (self.gridRows * self.gridSizeY) + (self.gap * (self.gridRows-1))
	
	self.backgroundColor = {r=0,g=0,b=0,a=0}
end

--when clicking an option in the menu
function BodyDetailMenuPanel:onAvatarSelect(bodyDetailAvatar)
	-- if type(bodyDetailAvatar.visualItem) == "number" then bodyDetailAvatar.visualItem = self.options[bodyDetailAvatar.visualItem] end
	if not bodyDetailAvatar.visualItem then print("BodyDetailMenuPanel:onAvatarSelect(): options shouldn't be nil") return end
	self:setSelected(bodyDetailAvatar.visualItem)
	if self.onSelect then self.onSelect(bodyDetailAvatar.visualItem) end
end


-- #######################
-- # Getters and Setters #
-- #######################

--when an option is clicked we select or deselect it
function BodyDetailMenuPanel:setSelected(visualItem)
	if self.isFacePanel then
		self:setSelectedOption(visualItem.name)
	else
		if self.selectedOptions[visualItem.name] == nil then
			self:setSelectedOption(visualItem.name)
		else
			self:removeSelectedOption(visualItem.name)
		end
	end
end

--sets the list of options available
function BodyDetailMenuPanel:setOptions(list)
	self.options = {}
	self.options = list

	self:refreshOptions()
end
function BodyDetailMenuPanel:refreshOptions()
	self.options = self:filterCurrentOptions(self.options)

	self.optionCount = self:getOptionCount() --caching this because its used to calculate the pages
	self:showPage(1)
	self:refreshSelectedOptions()
end
function BodyDetailMenuPanel:filterCurrentOptions(list)
	local newlist = {}
	for k,v in pairs(list) do
		if (not v.locked) or self.lockedOptionsVisible then
			newlist[k] = v
		end
	end
	return newlist
end
function BodyDetailMenuPanel:getOptionCount()
	local count = 0
	if self.options then
		for k,v in pairs(self.options) do
			count = count +1
		end
	end
	return count
end
function BodyDetailMenuPanel:getOptions()
	return self.options
end
function BodyDetailMenuPanel:getOptionList()
	local list = {}
	for name,v in pairs(self.options) do
		table.insert(list, name)
	end
	return list
end
function BodyDetailMenuPanel:getOptionListAlphabetical()
	local list = {}
	for name, v in pairs(self.options) do
		table.insert(list, {name = name, sort = v.sort})
	end
	--sort the list alphabetically
	table.sort(list, function(a,b)
		local a_name = a.sort .. a.name
		local b_name = b.sort .. b.name
		-- if a == "DefaultFace" then return true end
		-- if b == "DefaultFace" then return false end
		return a_name < b_name
	end)

	local newlist = {}
	for k,v in pairs(list) do
		table.insert(newlist, v.name)
	end

	return newlist
end


function BodyDetailMenuPanel:setSelectedOption(name)
	local visualItem = self.options[name]
	if visualItem == nil then return end
	
	--if a detail uses an exclusive bodylocation then we need to keep track of which ones are already selected
	if not visualItem.isMultiItem then
		if self.selectedBodylocations[visualItem.bodylocation] then
			self:removeSelectedOption(self.selectedBodylocations[visualItem.bodylocation].name)
		end
		self.selectedBodylocations[visualItem.bodylocation] = visualItem
	end
	
	if self.isFacePanel then
		self:clearSelectedOptions()
	end
	self.selectedOptions[name] = true
end
function BodyDetailMenuPanel:removeSelectedOption(name)
	local visualItem = self.options[name]
	if visualItem and not visualItem.isMultiItem then
		self.selectedBodylocations[visualItem.bodylocation] = nil
	end
	self.selectedOptions[name] = nil
end
function BodyDetailMenuPanel:clearSelectedOptions()
	self.selectedOptions = {}
	self.selectedBodylocations = {}
end
function BodyDetailMenuPanel:setSelectedOptions(names)
	self:clearSelectedOptions()
	for i, name in pairs(names) do
		self:setSelectedOption(name)
	end
end
function BodyDetailMenuPanel:getSelectedOptionCount()
	local count = 0
	if self.selectedOptions then
		for k,v in pairs(self.selectedOptions) do
			count = count +1
		end
	end
	return count
end
function BodyDetailMenuPanel:getSelectedOptions() 	--used for body detail menu
	local list = {}
	if self.isFacePanel or not self.selectedOptions then return list end
	for name,v in pairs(self.selectedOptions) do
		table.insert(list, self.options[name])
	end
	return list
end
function BodyDetailMenuPanel:getSelectedOption() 	--used for the face menu
	if not self.isFacePanel or not self.selectedOptions then return nil end
	for name,v in pairs(self.selectedOptions) do
		return self.options[name]
	end
end
function BodyDetailMenuPanel:getSelectedOptionList() --returns a list instead of a dictionary
	if not self.selectedOptions then return nil end
	local list = {}
	for name,v in pairs(self.selectedOptions) do
		table.insert(list, name)
	end
	return list
end

--when the option list changes we need to remove any selected options that no longer exist
function BodyDetailMenuPanel:refreshSelectedOptions()
	if self.isFacePanel and self.selectedOptions then
		local name
		for k,v in pairs(self.selectedOptions) do
			name = k
		end
		if self.options[name] == nil then
			self:setSelectedOption("DefaultFace")
		end
	elseif self.selectedOptions then
		
		local newSelectedOptions = {}
		
		for name, v in pairs(self.selectedOptions) do
			if self.options[name] then
				table.insert(newSelectedOptions, name)
			end
		end
		self:setSelectedOptions(newSelectedOptions)
	end
end


-- ###########
-- # Avatars #
-- ###########

function BodyDetailMenuPanel:setDesc(desc)
	for i=1,#self.avatarList do
		self.avatarList[i]:setDesc(desc)
	end
end
function BodyDetailMenuPanel:applyVisual()
	local selectedFace = self:getSelectedOption()
	for i=1,#self.avatarList do
		self.avatarList[i]:applyVisual(selectedFace)	--we send selectedFace so that the face avatars can hide the currently selected face
		--selectedFace in the body detail menu will always be nil
	end
end
function BodyDetailMenuPanel:setViewSettings()
	for i=1,#self.avatarList do
		self.avatarList[i]:setViewSettings()
	end
end


-- #########
-- # Pages #
-- #########

function BodyDetailMenuPanel:onChangePageButton(button,x,y)
	if button.internal == "NEXT" then
		self:changePage(1)
	elseif button.internal == "PREV" then
		self:changePage(-1)
	end
end

function BodyDetailMenuPanel:getNumberOfPages()
	return math.ceil(self.optionCount / self.pageSize)
end

function BodyDetailMenuPanel:getCurrentPageSize()
	-- HACK: Only the last page has less than pageSize elements
	if self:getNumberOfPages() ~= self.pageCurrent then
		return self.pageSize
	else
		return self.optionCount % self.pageSize
	end
end

function BodyDetailMenuPanel:changePage(step)
	self:showPage(SpnCharCustomMath.math.wrap(self.pageCurrent + step, 1, self:getNumberOfPages()))
end
function BodyDetailMenuPanel:showPage(page_number)
	if page_number == 0 then return end	--there was a bug where you could change the page to 0 if there was only 1 page of items

	self.pageCurrent = page_number
	local optionList = self:getOptionListAlphabetical()
	
	for i=1,self.pageSize do
		local option = optionList[((page_number-1) * self.pageSize) + i]
		if self.options[option] then
			self.avatarList[i].selectable = true
			self.avatarList[i]:setVisualItem(self.options[option])
			self.avatarList[i]:setViewSettings()
			-- self.avatarList[i]:applyVisual()
			self.avatarList[i]:setVisible(true)
			self.avatarList[i].tooltipEnabled = self.tooltipEnabled
		else
			self.avatarList[i].selectable = false
			self.avatarList[i]:setVisible(false)
		end
	end
	if self.joypadFocus then
		self:makeCursorValid()
	else
		self:setCursor(nil)
	end

	--i dont know why i need to do this here but if i dont then it causes a visual bug 
	--where the currently selected option appears on every avatar when switching pages
	self:applyVisual()
end


-- ##########
-- # Cursor #
-- ##########

function BodyDetailMenuPanel:getValidCursor(index)
	-- NOTE: index 1 will always be valid as the page wouldn't exist if there wasn't at least 1 element.
	local cursor = SpnCharCustomMath.math.clamp(index, 1, self.pageSize)
	if not self.avatarList[cursor].selectable == true then 
		for i=0,self.pageSize do
			local new_cursor = SpnCharCustomMath.math.wrap(cursor - i, 1, self.pageSize) -- NOTE: Move downwards as avatars are seqential.
			if self.avatarList[new_cursor].selectable == true then 
				cursor = new_cursor
				break
			end
		end
	end
	return cursor
end

function BodyDetailMenuPanel:setCursor(index)
	if self.joypadCursor then
		-- NOTE: Clear old cursor. this should avoid a double cursor as long as everyone uses this function.
		self.avatarList[self.joypadCursor]:setCursor(false)
	end

	if not index then
		self.joypadCursor = nil
		return
	end

	self.joypadCursor = self:getValidCursor(index)
	self.avatarList[self.joypadCursor]:setCursor(true)
end

function BodyDetailMenuPanel:makeCursorValid()
	self:setCursor(self:getValidCursor(self.joypadCursor))
end


--##################
--Controller Support
--##################

--[[ NOTE:
	We never actually get the joypad focus onto this element.
	Similar to how vanilla handles this (see `ISPanelJoypad`) we forward events from the panel to the element.
 ]]

function BodyDetailMenuPanel:ensureCursor()
	if not self.joypadCursor then
		self:setCursor(1)
	end
end

function BodyDetailMenuPanel:stepCursor(direction)
	self:ensureCursor()

	local direction = SpnCharCustomMath.math.sign(direction)

	-- NOTE: `stepCursor` is only called by joypad events we don't need any flags for joypad usage
	if direction ~= 0 then
		if self.joypadCursor + direction > self:getCurrentPageSize() then
			self:changePage(1)
			self:setCursor(1)
			return
		elseif self.joypadCursor + direction < 1 then
			self:changePage(-1)
			self:setCursor(self.pageSize)
			return
		end
	end

	self:setCursor(self.joypadCursor + direction)
end

-- Determines if the next joypad press should move outside the menu
function BodyDetailMenuPanel:isNextDownOutside()
	if not self.joypadCursor then
		return true
	end
	return not predicateAvatarIsSelectable(self.avatarList[self.joypadCursor + self.gridCols])
end

-- Determines if the next joypad press should move outside the menu
function BodyDetailMenuPanel:isNextUpOutside()
	if not self.joypadCursor then
		return true
	end
	return not predicateAvatarIsSelectable(self.avatarList[self.joypadCursor - self.gridCols])
end

function BodyDetailMenuPanel:setJoypadFocused(focused, joypadData)
	-- XXX: This function has to at least exist as vanilla calls it on any element that doesn't directly recieve focus
	self.joypadFocus = focused
	if focused then
		self:setCursor(1)
	else
		self:setCursor(nil)
	end
end

function BodyDetailMenuPanel:onJoypadDown(button, joypadData)
	if button == Joypad.RBumper then self:changePage(1) end
	if button == Joypad.LBumper then self:changePage(-1) end
	if button == Joypad.AButton then
		self:ensureCursor()
		if self.avatarList[self.joypadCursor] then self.avatarList[self.joypadCursor]:select() end
	end
	if button == Joypad.XButton then
		if self.stubbleTickBox then self.stubbleTickBox:forceClick() end
	end
	if button == Joypad.YButton then
		if self.hairColorBtn then self.hairColorBtn:forceClick() end
	end
end

function BodyDetailMenuPanel:onJoypadDirLeft(joypadData)  self:stepCursor(-1) end
function BodyDetailMenuPanel:onJoypadDirRight(joypadData) self:stepCursor(1)  end

function BodyDetailMenuPanel:onJoypadDirDown(joypadData)
	self:ensureCursor()
	local i = self.joypadCursor + self.gridCols
	if predicateAvatarIsSelectable(self.avatarList[i]) then
		self:setCursor(i)
	end
end

function BodyDetailMenuPanel:onJoypadDirUp(joypadData)
	self:ensureCursor()
	local i = self.joypadCursor - self.gridCols
	if predicateAvatarIsSelectable(self.avatarList[i]) then
		self:setCursor(i)
	end
end