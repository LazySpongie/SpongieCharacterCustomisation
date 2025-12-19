---@diagnostic disable: duplicate-set-field

CharacterCreationMain.bodyHairOptions = {
	stubbleHead = false,
	stubbleBeard = false,
	bodyHair = false,
}

	-- ---------------------------------
	-- -- REPLACE STUBBLE AND CHEST HAIR
	-- ---------------------------------
-- Vanilla stubble causes layering issues with character customisation so we replace them with clothing items
function CharacterCreationMain.onBeardStubbleSelected(self, index, selected)
	self.bodyHairOptions.stubbleBeard = selected
	self:spn_update_character_customisation()
end
function CharacterCreationMain.onShavedHairSelected(self, index, selected)
	self.bodyHairOptions.stubbleHead = selected
	self:spn_update_character_customisation()
end
function CharacterCreationMain.onChestHairSelected(self, index, selected)
	self.bodyHairOptions.bodyHair = selected
	self:spn_update_character_customisation()
end

-- replace searches for stubble body visuals to check the selected bodyhair table
function CharacterCreationMain.syncUIWithTorso(self)
	local desc = MainScreen.instance.desc
	if not desc then return end
	self.skinColor = desc:getHumanVisual():getSkinTextureIndex() + 1
	if desc:isFemale() then self.bodyHairOptions.stubbleBeard = false end
	self.chestHairTickBox:setSelected(1, self.bodyHairOptions.bodyHair)
	self.beardStubbleTickBox:setSelected(1, self.bodyHairOptions.stubbleBeard)
	self.hairStubbleTickBox:setSelected(1, self.bodyHairOptions.stubbleHead)
end

--set body hair button visible for female characters
local vanilla_disableBtn = CharacterCreationMain.disableBtn
function CharacterCreationMain.disableBtn(self)
    vanilla_disableBtn(self)
	
	if not self.chestHairLbl then return end
	self.chestHairLbl:setVisible(true)
	self.chestHairTickBox:setVisible(true)
end
