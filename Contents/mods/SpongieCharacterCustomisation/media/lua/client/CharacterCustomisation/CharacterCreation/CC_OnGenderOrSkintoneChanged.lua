---@diagnostic disable: duplicate-set-field
require("CharacterCustomisation/CharacterCreation/CC_UpdateCharacterPreview")

	-- -------------------------------------------------
	-- -- RESET LISTS WHEN SKINTONE OR GENDER IS CHANGED
	-- -------------------------------------------------
local originalHeaderOnGenderSelected = CharacterCreationHeader.onGenderSelected
function CharacterCreationHeader.onGenderSelected(self, combo)
    originalHeaderOnGenderSelected(self, combo);
	
	CharacterCreationMain.instance:refreshCustomisationWindow()
end

local originalonSkinColorPicked = CharacterCreationMain.onSkinColorPicked
function CharacterCreationMain.onSkinColorPicked(self, color, mouseUp)
    originalonSkinColorPicked(self, color, mouseUp);
	
	self:refreshCustomisationWindow()
end
