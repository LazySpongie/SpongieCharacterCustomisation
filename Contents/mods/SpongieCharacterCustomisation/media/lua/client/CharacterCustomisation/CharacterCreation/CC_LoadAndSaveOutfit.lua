
-- Main
CharacterCreationMain.spn_character_customisation_saved = "spncharcustom_saved_outfits.txt";


local OUTFIT_CHARACTER_CUSTOMISATION_FILE_VERSION = 1;

function CharacterCreationMain.readCharacterCustomisationSaveFile()
    local retVal = {};
    local saveFile = getFileReader(CharacterCreationMain.spn_character_customisation_saved, true);
    local version = 0;
    local line = saveFile:readLine();
    while line ~= nil do
        if luautils.stringStarts(line, "VERSION=") then
---@diagnostic disable-next-line: cast-local-type, undefined-field
            version = tonumber(string.split(line, "=")[2])
        elseif version == OUTFIT_CHARACTER_CUSTOMISATION_FILE_VERSION then
            local s = luautils.split(line, ":");
            retVal[s[1]] = s[2];
        end
        line = saveFile:readLine();
    end
    saveFile:close();

    return retVal;
end

function CharacterCreationMain.writeCharacterCustomisationSaveFile(options)
    local saveFile = getFileWriter(CharacterCreationMain.spn_character_customisation_saved, true, false); -- overwrite
    saveFile:write("VERSION="..tostring(OUTFIT_CHARACTER_CUSTOMISATION_FILE_VERSION).."\n")
    for key,val in pairs(options) do
        saveFile:write(key..":"..val.."\n");
    end
    saveFile:close();
end

local originalMainLoadOutfit = CharacterCreationMain.loadOutfit;
---@diagnostic disable-next-line: duplicate-set-field
function CharacterCreationMain:loadOutfit(box)
	originalMainLoadOutfit(self, box)
	
    local name = box.options[box.selected]
    if name == nil then return end
	

	-- reset selections before we try to load data
	self.characterCustomisationPanel:setSelectedFace("DefaultFace")
	self.characterCustomisationPanel:clearSelectedBodyDetails()

    local saved_builds = CharacterCreationMain.readCharacterCustomisationSaveFile();
    local build = saved_builds[name]
	
	--if the save doesnt have character customisation save data then we need to clear the body details
    if build then
		local items = luautils.split(build, ";");
		for i,v in pairs(items) do
			local location = luautils.split(v, "=");
			local options = nil;
			if location[2] then
				options = luautils.split(location[2], "|");
			end
			if location[1] == "face" then
				--SET FACE SELECTION HERE!!
				self.characterCustomisationPanel:setSelectedFace(options[1])
			elseif location[1] == "bodyhair" then
				--SET BODY HAIR SELECTIONS HERE
				local chestHair = tonumber(options[1]) == 1
				self.chestHairTickBox:setSelected(1, chestHair);
				self:onChestHairSelected(1, chestHair);
			elseif location[1] == "bodydetails" then
				--SET BODY DETAILS SELECTIONS HERE
				if options ~= nil then
					local list = {}
					for i,v in pairs(options) do
						table.insert(list, v)
					end
					self.characterCustomisationPanel:setSelectedBodyDetails(list)
				end
			end
		end
	end
	
	self:spn_update_character_customisation()
end

local originalMainSaveBuildStep2 = CharacterCreationMain.saveBuildStep2;
---@diagnostic disable-next-line: duplicate-set-field
function CharacterCreationMain.saveBuildStep2(self, button, joypadData, param2)
    originalMainSaveBuildStep2(self, button, joypadData, param2)
	
    local savename = button.parent.entry:getText()
    if savename == '' then return end

    local builds = CharacterCreationMain.readCharacterCustomisationSaveFile()
	local savestring = ""
	-------------------------------------------------------------------
		-- SAVE FACE
	savestring = savestring .. "face=" .. self.characterCustomisationPanel.faceMenu:getSelectedOption().name .. ";"
	-------------------------------------------------------------------
		-- SAVE CHEST HAIR		 vanilla doesnt save it for female chars
	savestring = savestring .. "bodyhair=" .. (self.chestHairTickBox:isSelected(1) and "1" or "2") .. ";"
	-------------------------------------------------------------------
		-- SAVE BODY DETAILS
	savestring = savestring .. "bodydetails="
	local first = true
	for i, name in pairs(self.characterCustomisationPanel.bodyDetailMenu:getSelectedOptionList()) do
		if first then
			first = false
			savestring = savestring .. name
		else
			savestring = savestring .. "|" .. name
		end
	end
	savestring = savestring .. ";"
	-------------------------------------------------------------------
		-- FINISHED WRITING SAVE
	-------------------------------------------------------------------
    builds[savename] = savestring
    CharacterCreationMain.writeCharacterCustomisationSaveFile(builds)
end

local originalMainDeleteBuildStep2 = CharacterCreationMain.deleteBuildStep2;
---@diagnostic disable-next-line: duplicate-set-field
function CharacterCreationMain.deleteBuildStep2(self, button, joypadData)
    originalMainDeleteBuildStep2(self, button, joypadData)
	
    local delBuild = self.savedBuilds.options[self.savedBuilds.selected]
    --if delBuild == '' then return end
	
    local builds = CharacterCreationMain.readCharacterCustomisationSaveFile()
	builds[delBuild] = nil
	
	CharacterCreationMain.writeCharacterCustomisationSaveFile(builds)
end
