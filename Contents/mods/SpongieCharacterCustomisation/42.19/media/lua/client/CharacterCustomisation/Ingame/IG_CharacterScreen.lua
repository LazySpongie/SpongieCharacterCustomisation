
local shaveAction = require("TimedActions/IS_ShaveStubble")
local bodyHairAction = require("TimedActions/IS_ShaveBodyHair")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6


local CUSTOMISATION_UPDATE_FRAME_COUNT = 120


local function predicateRazor(item)
	if item:isBroken() then return false end
	return item:hasTag(ItemTag.RAZOR)
end
local function predicateAppearanceChanger(item)
	return item:hasTag(SPNCC.ItemTag.AppearanceChanger)
end
local function predicateAppearanceUnlocker(item)
	return item:hasTag(SPNCC.ItemTag.AppearanceUnlocker)
end

	-- ----------------------
	-- -- CONTEXT MENU
	-- ----------------------
function ISCharacterScreen:shaveMenu(button)
	self.ShaveContext = ISContextMenu.get(self.char:getPlayerNum(), button:getAbsoluteX(), button:getAbsoluteY() + button:getHeight())
    self:addShaveContext()
end
function ISCharacterScreen:addShaveContext()
	local player = self.char
	local playerInv = player:getInventory()
	local hasRazor = playerInv:containsEvalRecurse(predicateRazor)

    if self.hasStubbleBeard then
        local beardOption = self.ShaveContext:addOption(getText("UI_shave_stubble_beard"), self, ISCharacterScreen.onShaveStubble, true)
        if not hasRazor then
            self:addTooltip(beardOption, getText("Tooltip_RequireRazor"))
        end
    end
    if self.hasStubbleHead then
        local headOption = self.ShaveContext:addOption(getText("UI_shave_stubble_head"), self, ISCharacterScreen.onShaveStubble, false)
        if not hasRazor then
            self:addTooltip(headOption, getText("Tooltip_RequireRazor"))
        end
    end
    if self.hasBodyHair then
        local bodyOption = self.ShaveContext:addOption(getText("UI_shave_stubble_body"), self, ISCharacterScreen.onShaveBodyHair)
        if not hasRazor then
            self:addTooltip(bodyOption, getText("Tooltip_RequireRazor"))
        end
    end

    --DEBUGGING
    if self.playerHasAppearanceChanger then
        if not self.hasBodyHair then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_body"), self, ISCharacterScreen.DebugAddBodyHair)
        end
        if not self.hasStubbleBeard and not self.char:isFemale() then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_beard"), self, ISCharacterScreen.DebugAddBeardStubble)
        end
        if not self.hasStubbleHead then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_head"), self, ISCharacterScreen.DebugAddHeadStubble)
        end
    end
	
end
function ISCharacterScreen:DebugAddBeardStubble()
	print("DebugAddBeardStubble")
	sendClientCommand(getPlayer(), "SPNCC", "AddPlayerStubble", { isBeard = true })
	self.char:resetModel()
	triggerEvent("OnClothingUpdated", self.char)

end
function ISCharacterScreen:DebugAddHeadStubble()
	print("DebugAddHeadStubble")
	sendClientCommand(getPlayer(), "SPNCC", "AddPlayerStubble", { isBeard = false })
	self.char:resetModel()
	triggerEvent("OnClothingUpdated", self.char)
end
function ISCharacterScreen:DebugAddBodyHair()
	print("DebugAddBodyHair")
	sendClientCommand(getPlayer(), "SPNCC", "AddPlayerBodyHair", { })
	self.char:resetModel()
	triggerEvent("OnClothingUpdated", self.char)
end

	-- ------------------------
	-- -- PERFORM SHAVE ACTIONS
	-- ------------------------
function ISCharacterScreen:onShaveStubble(isBeard)
	local player = self.char
	local playerInv = player:getInventory()
	if player:getClothingItem_Head() ~= nil then
		ISTimedActionQueue.add(ISUnequipAction:new(player, player:getClothingItem_Head(), 50));
	end
	local razor = playerInv:getFirstEvalRecurse(predicateRazor)
	ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), razor, true)
	ISTimedActionQueue.add(shaveAction:new(player, isBeard, razor, 300))
end
function ISCharacterScreen:onShaveBodyHair()
	local player = self.char
	local playerInv = player:getInventory()
	if player:getClothingItem_Torso() ~= nil then
		ISTimedActionQueue.add(ISUnequipAction:new(player, player:getClothingItem_Torso(), 50));
	end
	if player:getClothingItem_Legs() ~= nil then
		ISTimedActionQueue.add(ISUnequipAction:new(player, player:getClothingItem_Legs(), 50));
	end
	local razor = playerInv:getFirstEvalRecurse(predicateRazor)
	ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), razor, true)
	ISTimedActionQueue.add(bodyHairAction:new(player, razor, 300))
end

	-- ----------------------
	-- -- OPEN CUSTOMISE MENU
	-- ----------------------
function ISCharacterScreen:customisationMenu(button)
	-- if self.CharCustomWindow then return end

	local FaceManager_Shared = require("CharacterCustomisation/FaceManager_Shared")
	self.CharCustomWindow = FaceManager_Shared.OpenCharacterCustomisationWindow(self.char, false)

	if not self.CharCustomWindow then return end

    self.CharCustomWindow.onClose = function()
        self.customisationButton.enable = true
		self.CharCustomWindow = nil
    end

    self.customisationButton.enable = false

	--hide or unhide the face/detail panels
	local allowChange = SandboxVars.SPNCharCustom.AllowCustomisationChange
	local allowFaceChange = 		(allowChange == 1) or (allowChange == 2)
	local allowBodyDetailsChange = 	(allowChange == 1) or (allowChange == 3)

	self.CharCustomWindow.faceMenu:setVisible(allowFaceChange or self.playerHasAppearanceChanger)
	self.CharCustomWindow.bodyDetailMenu:setVisible(allowBodyDetailsChange or self.playerHasAppearanceChanger)
	self.CharCustomWindow:setLockedOptionsVisible(self.playerHasAppearanceUnlocker)
	
end

	-- ----------------------
	-- -- CREATE BUTTONS
	-- ----------------------
local originalCreate = ISCharacterScreen.create
---@diagnostic disable-next-line: duplicate-set-field
function ISCharacterScreen.create(self)
    originalCreate(self)

	local btnWid = 70

	self.shaveButton = ISButton:new(0,0, btnWid, BUTTON_HGT, getText("UI_characreation_shave"), self, ISCharacterScreen.shaveMenu);
	self.shaveButton:initialise();
	self.shaveButton:instantiate();
	self.shaveButton.borderColor = {r=1, g=1, b=1, a=0.1};
	self.shaveButton:setVisible(false);
	self:addChild(self.shaveButton);
	
	self.customisationButton = ISButton:new(0,0,  btnWid, BUTTON_HGT, getText("IGUI_PlayerStats_Change"), self, ISCharacterScreen.customisationMenu)
	self.customisationButton:initialise()
	self.customisationButton:instantiate()
	self.customisationButton.borderColor = {r=1, g=1, b=1, a=0.1}
	self.customisationButton:setVisible(false)
	self:addChild(self.customisationButton)

end

	-- --------------------------------------------
	-- -- SET VISIBILITY AND POSITION OF BUTTONS
	-- --------------------------------------------
local originalRender = ISCharacterScreen.render
---@diagnostic disable-next-line: duplicate-set-field
function ISCharacterScreen.render(self)
    originalRender(self)
	
	self.customisationRefreshTimer = self.customisationRefreshTimer or CUSTOMISATION_UPDATE_FRAME_COUNT
	self.customisationRefreshTimer = self.customisationRefreshTimer +1

	--we dont want to check the players inventory every frame so we delay it by a few seconds
	--we start the timer at 120 so it always refreshes when the menu is first opened
	if self.customisationRefreshTimer >= CUSTOMISATION_UPDATE_FRAME_COUNT then
		self.customisationRefreshTimer = 0

		self.playerChoiceEnabled = (SandboxVars.SPNCharCustom.BodyHairGrowthEnabled == 3) or (SandboxVars.SPNCharCustom.MuscleVisuals == 3)
		self.customisationChangeEnabled = SandboxVars.SPNCharCustom.AllowCustomisationChange ~= 4

		self.playerHasAppearanceChanger = self:SetPlayerHasAppearanceChanger()
		self.playerHasAppearanceUnlocker = self:SetPlayerHasAppearanceUnlocker()
		self.playerCanChangeAppearance = self:SetPlayerCanChangeAppearance()
		-- self.hasBodyHair = self:GetBodyHair()
		-- self.hasStubbleHead = self:GetStubbleHead()
		-- self.hasStubbleBeard = self:GetStubbleBeard()
		local data = self.char:getModData().SPNCharCustom
		if data then
			self.hasBodyHair = data.bodyHair
			self.hasStubbleHead = data.stubbleHead
			self.hasStubbleBeard = data.stubbleBeard
		end
	end

    local finalY = self.char:isFemale() and self.hairButton:getY() or self.beardButton:getY()

	finalY = finalY + ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)  --undo the aligning of the button with text

    finalY = finalY + BUTTON_HGT + UI_BORDER_SPACING

	self:drawTextRight(getText("UI_ChestHair"), self.xOffset + 30, finalY, 1,1,1,1, UIFont.Small)
	self.shaveButton:setVisible(true)
	self.shaveButton:setX(self.hairButton:getX())
	self.shaveButton:setY(finalY - ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)) --aligns button with text

	self.shaveButton.enable = self.hasBodyHair or self.hasStubbleHead or self.hasStubbleBeard or self.playerHasAppearanceChanger
	self.shaveButton.tooltip = nil

	if self.shaveButton.enable == false then
	   self.shaveButton.tooltip = getText("Tooltip_NoBodyHair");
	end

    finalY = finalY + BUTTON_HGT + UI_BORDER_SPACING

    if self.playerCanChangeAppearance then
        self:drawTextRight(getText("UI_characreation_appearance"), self.xOffset + 30, finalY, 1,1,1,1, UIFont.Small)
        self.customisationButton:setVisible(true)
        self.customisationButton.enable = true
	else
		self.customisationButton:setVisible(false)
        self.customisationButton.enable = false
    end

	if self.CharCustomWindow then self.customisationButton.enable = false end

	self.customisationButton:setX(self.hairButton:getX())
	self.customisationButton:setY(finalY - ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)) --aligns button with text
	self.customisationButton.tooltip = nil

    finalY = finalY + BUTTON_HGT + UI_BORDER_SPACING

	--move literature button down to make room
	--have to nil check because reorganised info screen removes the lit button for some reason
	if self.literatureButton then
		self.literatureButton:setY(finalY)
	end
end

--check if the player has any body hair so we can disable the shave button
function ISCharacterScreen:GetBodyHair()
	return self.char:getWornItem(SPNCC.ItemBodyLocation.BodyHair) ~= nil
end
function ISCharacterScreen:GetStubbleHead()
	return self.char:getWornItem(SPNCC.ItemBodyLocation.StubbleHead) ~= nil
end
function ISCharacterScreen:GetStubbleBeard()
	return self.char:getWornItem(SPNCC.ItemBodyLocation.StubbleBeard) ~= nil
end
function ISCharacterScreen:SetPlayerCanChangeAppearance()
	return self.playerHasAppearanceChanger or self.customisationChangeEnabled or self.playerChoiceEnabled
end
function ISCharacterScreen:SetPlayerHasAppearanceChanger()
	return isDebugEnabled() or (isClient() and isAdmin()) or self.char:getInventory():containsEvalRecurse(predicateAppearanceChanger)
end
function ISCharacterScreen:SetPlayerHasAppearanceUnlocker()
	return isDebugEnabled() or (isClient() and isAdmin()) or self.char:getInventory():containsEvalRecurse(predicateAppearanceUnlocker)
end
