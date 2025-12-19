---@diagnostic disable: duplicate-set-field
require("CharacterCustomisation/CharacterCreation/CC_UpdateCharacterPreview")

local oldOnRandomCharacter = CharacterCreationMain.onRandomCharacter
function CharacterCreationMain:onRandomCharacter()
	oldOnRandomCharacter(self)

	CharacterCreationMain.instance:spn_populate_customisation_window()
	CharacterCreationMain.instance:spn_randomise_face()
	CharacterCreationMain.instance:spn_randomise_details()
	CharacterCreationMain.instance:spn_update_character_customisation()
	
end

function CharacterCreationMain:spn_randomise_face()

	--randomise face
	local faceMenu = self.characterCustomisationPanel.faceMenu
	local faceList = faceMenu:getOptionList()
	local faceCount = #faceList
	local randomFace = 0
	--loop until we find a face that can be randomly selected
	while true do
		randomFace = faceList[ZombRand(faceCount) + 1]
		if faceMenu.options[randomFace].randomExcluded ~= true then
			faceMenu:setSelectedOption(randomFace)
			break
		end
	end
	
end

function CharacterCreationMain:spn_randomise_details()

	--randomise body details
	local bodyDetailMenu = self.characterCustomisationPanel.bodyDetailMenu
	local detailList = bodyDetailMenu:getOptionList()
	local detailCount = #detailList
	--need to make a dictionary of options we want to select to avoid duplicates
	local dict = {}
	local minRolls = 0
	local maxRolls = math.min(detailCount, 3)
	for i = 1, ZombRand(minRolls, maxRolls) do
		
		--loop until we find an unselected option
		while true do
			local index = ZombRand(0, detailCount + 1)

			if index > 0 then
				if dict[index] == nil and bodyDetailMenu.options[detailList[index]].randomExcluded ~= true then
					--we rolled a new option so we break the loop
					dict[index] = true
					break
				end
				--we havent rolled a new option so we loop again
			else
				--if we get no body detail we break the loop
				break
			end
		end
		
	end
	--convert the dictionary into a list of indexes we can use
	local list = {}
	for i,v in pairs(dict) do
		table.insert(list, detailList[i])
	end
	bodyDetailMenu:setSelectedOptions(list)

end