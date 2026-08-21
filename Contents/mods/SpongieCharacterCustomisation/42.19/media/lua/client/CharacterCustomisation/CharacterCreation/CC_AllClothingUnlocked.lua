
local ignoredBodylocations = {
    ["SPNCC:Blank"] = true,
    ["SPNCC:BodyDetail"] = true,
    ["SPNCC:BodyDetail2"] = true,
    ["SPNCC:BodyHair"] = true,
    ["SPNCC:Face"] = true,
    ["SPNCC:Face_Model"] = true,
    ["SPNCC:Muscle"] = true,
    ["SPNCC:StubbleBeard"] = true,
    ["SPNCC:StubbleHead"] = true,
}


local old_createClothingComboDebug = CharacterCreationMain.createClothingComboDebug
function CharacterCreationMain:createClothingComboDebug(bodyLocation)
    print("createClothingComboDebug : " .. bodyLocation)
    if ignoredBodylocations[bodyLocation] then return end
	old_createClothingComboDebug(self, bodyLocation)
end