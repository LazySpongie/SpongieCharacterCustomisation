
local FaceManager = require("CharacterCustomisation/FaceManager")

local shaveAction = require("TimedActions/IS_ShaveStubble")
local bodyHairAction = require("TimedActions/IS_ShaveBodyHair")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6


local function predicateRazor(item)
	if item:isBroken() then return false end
	return item:hasTag("Razor") or item:getType() == "Razor"
end
local function predicateAppearanceChanger(item)
	return item:hasTag("AppearanceChanger") or item:getType() == "AppearanceChanger"
end
local function predicateAppearanceUnlocker(item)
	return item:hasTag("AppearanceUnlocker") or item:getType() == "AppearanceUnlocker"
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
    local data = self.data
	local playerInv = player:getInventory()
	local hasRazor = playerInv:containsEvalRecurse(predicateRazor)

    if data.stubbleBeard then
        local beardOption = self.ShaveContext:addOption(getText("UI_shave_stubble_beard"), self, ISCharacterScreen.onShaveStubble, player, true)
        if not hasRazor then
            self:addTooltip(beardOption, getText("Tooltip_RequireRazor"))
        end
    end
    if data.stubbleHead then
        local headOption = self.ShaveContext:addOption(getText("UI_shave_stubble_head"), self, ISCharacterScreen.onShaveStubble, player, false)
        if not hasRazor then
            self:addTooltip(headOption, getText("Tooltip_RequireRazor"))
        end
    end
    if data.bodyHair then
        local bodyOption = self.ShaveContext:addOption(getText("UI_shave_stubble_body"), self, ISCharacterScreen.onShaveBodyHair, player)
        if not hasRazor then
            self:addTooltip(bodyOption, getText("Tooltip_RequireRazor"))
        end
    end

    --DEBUGGING
    if self.playerHasAppearanceChanger then
        if not data.bodyHair then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_body"), self, ISCharacterScreen.DebugAddBodyHair, player)
        end
        if not data.stubbleBeard and not player:isFemale() then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_beard"), self, ISCharacterScreen.DebugAddBeardStubble, player)
        end
        if not data.stubbleHead then
            self.ShaveContext:addOptionOnTop(getText("UI_debug_add_stubble_head"), self, ISCharacterScreen.DebugAddHeadStubble, player)
        end
    end
	
end
function ISCharacterScreen:DebugAddBeardStubble(player)
    FaceManager.AddPlayerStubble(player, true)
	player:getModData().SPNCharCustom.GrowTimer.stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24
	triggerEvent("OnClothingUpdated", player)
end
function ISCharacterScreen:DebugAddHeadStubble(player)
    FaceManager.AddPlayerStubble(player, false)
	player:getModData().SPNCharCustom.GrowTimer.stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24
	triggerEvent("OnClothingUpdated", player)
end
function ISCharacterScreen:DebugAddBodyHair(player)
    FaceManager.AddPlayerBodyHair(player)
	player:getModData().SPNCharCustom.GrowTimer.bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24
	triggerEvent("OnClothingUpdated", player)
end


	-- ------------------------
	-- -- PERFORM SHAVE ACTIONS
	-- ------------------------
function ISCharacterScreen:onShaveStubble(player, isBeard)
	local playerInv = player:getInventory()
	if player:getClothingItem_Head() ~= nil then
		ISTimedActionQueue.add(ISUnequipAction:new(player, player:getClothingItem_Head(), 50));
	end
	local razor = playerInv:getFirstEvalRecurse(predicateRazor)
	ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), razor, true)
	ISTimedActionQueue.add(shaveAction:new(player, isBeard, razor, 300))
end
function ISCharacterScreen:onShaveBodyHair(player)
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

	local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
	local comboHgt = FONT_HGT_SMALL + 3 * 2
	self.CharCustomWindow = CharacterCustomisationPanel_Ingame:new()
	self.CharCustomWindow:initialise()
    self.CharCustomWindow:addToUIManager()
	self.CharCustomWindow:setX( (getCore():getScreenWidth()/2) - (self.CharCustomWindow:getWidth()/2) )
	self.CharCustomWindow:setY( (getCore():getScreenHeight()/2) - (self.CharCustomWindow:getHeight()/2) )
    -- if UIManager.getSpeedControls() then
    --     UIManager.getSpeedControls():SetCurrentGameSpeed(0)
	-- 	UIManager.setShowPausedMessage(false);
    -- end
    --self.CharCustomWindow.canClose = true

    self.customisationButton.enable = false

    self.CharCustomWindow.onClose = function()
        self.customisationButton.enable = true
		self.CharCustomWindow = nil
    end

	--hide or unhide the face/detail panels
	local allowCustomisationChangeSandbox = SandboxVars.SPNCharCustom.AllowCustomisationChange
	local allowFaceChange = 		(allowCustomisationChangeSandbox == 1) or (allowCustomisationChangeSandbox == 2)
	local allowBodyDetailsChange = 	(allowCustomisationChangeSandbox == 1) or (allowCustomisationChangeSandbox == 3)

	self.CharCustomWindow.faceMenuVisible = allowFaceChange or self.playerHasAppearanceChanger
	self.CharCustomWindow.bodyDetailMenuVisible = allowBodyDetailsChange or self.playerHasAppearanceChanger
	
	self.CharCustomWindow.lockedOptionsVisible = self.playerHasAppearanceUnlocker
	
	self.CharCustomWindow:OpenMenu(self.char)
	
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


	-- self.testButton = ISButton:new(0,0,  btnWid, BUTTON_HGT, "Badass!", self, ISCharacterScreen.testVocalButton)
	-- self.testButton:initialise()
	-- self.testButton:instantiate()
	-- self.testButton.borderColor = {r=1, g=1, b=1, a=0.1}
	-- self.testButton:setVisible(false)
	-- self:addChild(self.testButton)


end

	-- --------------------------------------------
	-- -- SET VISIBILITY AND POSITION OF BUTTONS
	-- --------------------------------------------
local originalRender = ISCharacterScreen.render
---@diagnostic disable-next-line: duplicate-set-field
function ISCharacterScreen.render(self)
    originalRender(self)

	self.data = self.data or self.char:getModData().SPNCharCustom
	if not self.data then return end
	
	self.customisationRefreshTimer = self.customisationRefreshTimer or 120
	self.customisationRefreshTimer = self.customisationRefreshTimer +1

	--we dont want to check the players inventory every frame so we delay it by a few seconds
	--we start the timer at 120 so it always refreshes when the menu is first opened
	if self.customisationRefreshTimer >= 120 then
		self.customisationRefreshTimer = 0

		-- --caching these
		self.playerChoiceEnabled = (SandboxVars.SPNCharCustom.BodyHairGrowthEnabled == 3) or (SandboxVars.SPNCharCustom.MuscleVisuals == 3)
		self.customisationChangeEnabled = SandboxVars.SPNCharCustom.AllowCustomisationChange ~= 4

		self.playerHasAppearanceChanger = self:SetPlayerHasAppearanceChanger()
		self.playerHasAppearanceUnlocker = self:SetPlayerHasAppearanceUnlocker()
		self.playerCanChangeAppearance = self:SetPlayerCanChangeAppearance()
		self.playerHasBodyHair = self:SetPlayerHasBodyHair()
	end

    local finalY = self.char:isFemale() and self.hairButton:getY() or self.beardButton:getY()

	finalY = finalY + ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)  --undo the aligning of the button with text

    finalY = finalY + BUTTON_HGT + UI_BORDER_SPACING

	self:drawTextRight(getText("UI_ChestHair"), self.xOffset + 30, finalY, 1,1,1,1, UIFont.Small)
	self.shaveButton:setVisible(true)
	self.shaveButton:setX(self.hairButton:getX())
	self.shaveButton:setY(finalY - ((BUTTON_HGT - FONT_HGT_SMALL)/ 2)) --aligns button with text

	self.shaveButton.enable = self.playerHasBodyHair
	self.shaveButton.tooltip = nil

    if self.playerHasAppearanceChanger then self.shaveButton.enable = true end

	-- self.shaveButton.enable = self.playerHasAppearanceChanger or self.playerHasBodyHair

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
    finalY = finalY + BUTTON_HGT + UI_BORDER_SPACING

	--move literature button down to make room
	--have to nil check because reorganised info screen removes the lit button for some reason
	if self.literatureButton then
		self.literatureButton:setY(finalY)
	end
end

--check if the player has any body hair so we can disable the shave button
function ISCharacterScreen:SetPlayerHasBodyHair()
	local data = self.data
	return data.bodyHair or data.stubbleHead or data.stubbleBeard
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
