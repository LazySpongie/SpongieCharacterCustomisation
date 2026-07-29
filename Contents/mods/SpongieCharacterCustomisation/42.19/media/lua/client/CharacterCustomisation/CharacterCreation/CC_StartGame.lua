---@diagnostic disable: duplicate-set-field
require("CharacterCustomisation/CharacterCreation/CC_UpdateCharacterPreview")


-- removing customisation items on game start to see if it fixes the crashing
-- customisation items are readded after the player loads
local oldOnOptionMouseDown = CharacterCreationMain.onOptionMouseDown
function CharacterCreationMain:onOptionMouseDown(button, x, y)
	
	if button.internal == "NEXT" then
		self:spn_remove_items()
	end

	oldOnOptionMouseDown(self, button, x, y)
end