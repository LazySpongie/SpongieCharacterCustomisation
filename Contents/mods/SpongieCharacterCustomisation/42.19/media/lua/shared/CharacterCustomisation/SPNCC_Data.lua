
	-- ----------------------------------------------------------------------
	-- -- here we store all the data related to character customisation items
	-- ----------------------------------------------------------------------

local SPNCC_Presets = require("CharacterCustomisation/SPNCC_Presets")

local SPNCC_Data = {}
SPNCC_Data.MaleFaces = {}
SPNCC_Data.FemaleFaces = {}
SPNCC_Data.BodyDetails = {}
SPNCC_Data.Muscle = {
    "Base.M_Muscle",	--male
    "Base.F_Muscle",	--female
}
SPNCC_Data.BodyHair = {
	"Base.M_Hair_Body",	--male
	"Base.F_Hair_Body",	--female
}
SPNCC_Data.StubbleHead = "Base.M_Hair_Stubble"
SPNCC_Data.StubbleBeard = "Base.M_Beard_Stubble"

SPNCC_Data.MissingEyes = {}

	-- ---------------------------------
	-- -- TABLE MANAGEMENT
	-- ---------------------------------
function SPNCC_Data.AddMaleFaceData(entry)
    SPNCC_Data.MaleFaces[entry.name] = entry
end
function SPNCC_Data.AddFemaleFaceData(entry)
    SPNCC_Data.FemaleFaces[entry.name] = entry
end
function SPNCC_Data.AddBodyDetailData(entry)
    SPNCC_Data.BodyDetails[entry.name] = entry
end
function SPNCC_Data.RemoveMaleFaceData(name)
	SPNCC_Data.MaleFaces[name] = nil
end
function SPNCC_Data.RemoveFemaleFaceData(name)
	SPNCC_Data.FemaleFaces[name] = nil
end
function SPNCC_Data.RemoveBodyDetailData(name)
	SPNCC_Data.BodyDetails[name] = nil
end

-- ------------------------------------
-- -- CHARACTER CREATION MENU
-- ------------------------------------
function SPNCC_Data.GetFacesForCharacter(desc)
    
    local isFemale = desc:isFemale()
    local lockedCategories = SPNCC_Data.GetLockedCategories()
    
    local listToSearch = isFemale and SPNCC_Data.FemaleFaces or SPNCC_Data.MaleFaces
    local list = {}
    
    list["DefaultFace"] = {
                id = "",
                name = "DefaultFace",
                display = isFemale and getText("IGUI_Face_Kate") or getText("IGUI_Face_Bob"),
                sort = "a",
                texture = 0,
                bodylocation = SPNCC.ItemBodyLocation.Face,
                visionModifier = false,
                isMultiItem = false,
                randomExcluded = false,
                direction = SPNCC_Presets.CameraPresets.face.direction,
                locked = false,
                icon = getTexture(SPNCC_Presets.IconPresets.face),
                zoom = SPNCC_Presets.CameraPresets.face.zoom,
                yoffset = SPNCC_Presets.CameraPresets.face.yoffset,
                xoffset = SPNCC_Presets.CameraPresets.face.xoffset,
    }
    for i, v in pairs(listToSearch) do
        local availableForSkintone = true
        local texture = SPNCC_Data.GetTextureIndex(desc, v)
        if texture < 0 then availableForSkintone = false end

        if availableForSkintone then
            local tempname = v.display or v.name
            local display = getText("IGUI_Face_" .. tempname)

            local randomExcluded = false
            if v.randomExcluded then randomExcluded = v.randomExcluded end
            
            local view = SPNCC_Presets.CameraPresets.face
            if v.view then view = v.view end

            local bodylocation = SPNCC.ItemBodyLocation.Face
            local item = ScriptManager.instance:getItem(v.id)
            if item then
                bodylocation = item:getBodyLocation()
            end

            local visionModifier = false
            if v.visionModifier and (SandboxVars.SPNCharCustom.MissingEyeVisionModifier ~= 1.0) then visionModifier = true end

            local locked = false
            if v.category and lockedCategories[string.lower(v.category)] then locked = true end

            local icon = getTexture(SPNCC_Presets.IconPresets.face)
            if v.icon then icon = getTexture(v.icon) end
            
            local sort = v.sort or "b"
            sort = (sort == "a") and "b" or sort --make sure it doesnt conflict with default face

            list[v.name] = {
                id = v.id,
                name = v.name,
                display = display,
                sort = sort,
                texture = texture,
                bodylocation = bodylocation,
                visionModifier = visionModifier,
                isMultiItem = false,
                randomExcluded = randomExcluded,
                direction = view.direction,
                locked = locked,
                icon = icon,
                zoom = view.zoom,
                yoffset = view.yoffset,
                xoffset = view.xoffset,
            }
        end
    end
    return list
end
function SPNCC_Data.GetBodyDetailsForCharacter(desc)
    
    local BodyLocationsGroup = BodyLocations.getGroup("Human")
    local lockedCategories = SPNCC_Data.GetLockedCategories()

    local list = {}
    
    for i, v in pairs(SPNCC_Data.BodyDetails) do
        local female = true
        if v.female ~= nil then female = v.female end
        local male = true
        if v.male ~= nil then male = v.male end

        local isFemale = desc:isFemale()
        local isMale = not isFemale
        local availableForBody = (isFemale and female) or (isMale and male)

        local availableForSkintone = true
        local texture = SPNCC_Data.GetTextureIndex(desc, v)
        if texture < 0 then availableForSkintone = false end
        
        if availableForSkintone and availableForBody then
            local tempname = v.display or v.name
            local display = getText("IGUI_Detail_" .. tempname)

            local randomExcluded = false
            if v.randomExcluded then randomExcluded = v.randomExcluded end
            
            local view = SPNCC_Presets.CameraPresets.face
            if v.view then view = v.view end


            local bodylocation = SPNCC.ItemBodyLocation.BodyDetail
            local item = ScriptManager.instance:getItem(v.id)
            if item then
                bodylocation = item:getBodyLocation()
            end

            local visionModifier = false
            if v.visionModifier and (SandboxVars.SPNCharCustom.MissingEyeVisionModifier ~= 1.0) then visionModifier = true end

            local isMultiItem = BodyLocationsGroup:isMultiItem(bodylocation)

            local locked = false
            if v.category and lockedCategories[string.lower(v.category)] then locked = true end

            local icon = getTexture(SPNCC_Presets.IconPresets.default)
            if v.icon then icon = getTexture(v.icon) end
            
            local sort = v.sort or "b"
            
            list[v.name] = {
                id = v.id,
                name = v.name,
                display = display,
                sort = sort,
                texture = texture,
                bodylocation = bodylocation,
                visionModifier = visionModifier,
                isMultiItem = isMultiItem,
                randomExcluded = randomExcluded,
                direction = view.direction,
                locked = locked,
                icon = icon,
                zoom = view.zoom,
                yoffset = view.yoffset,
                xoffset = view.xoffset,
            }
        end
    end
    return list
end
function SPNCC_Data.GetTextureIndex(desc, v)
    local skinTone = desc:getHumanVisual():getSkinTextureIndex() + 1;
    local useDefaultTexture = false
    local texture = 0
    if v.textures ~= nil then

        if #v.textures == 1 then            --if there is only one texture index then we use that for all skintones
            texture = v.textures[1]
            
        elseif #v.textures < 5 then         --the mod author has made a typo and added less than 5 texture indexes
            print("ERROR: Customisation option " .. v.name .. " has " .. tostring(#v.textures) .. " texture indexes assigned. Using skintone as texture index")
            useDefaultTexture = true
            
        else                                --use the texture index assigned to the skintone
            texture = v.textures[skinTone]
        end
    
    else                                    --if no custom texture indexes have been assigned then we use the skintone
        useDefaultTexture = true
    end

    if useDefaultTexture then
        --optionally add an offset to the texture index to simplify packing multiple body details into a single item
        local textureOffset = 0
        if v.textureOffset ~= nil and v.textureOffset >= 0 then textureOffset = v.textureOffset end

        texture = skinTone - 1 + textureOffset
    end
    
    return texture
end
function SPNCC_Data.GetLockedCategories()
    local lockedString = string.lower(SandboxVars.SPNCharCustom.AdminLockedCustomisation)
    if lockedString == "" or lockedString == nil then return {} end

    local splitString = luautils.split(lockedString, ",")

    local lockedCategories = {}
    for i = 1, #splitString do
        lockedCategories[splitString[i]] = true
    end

    return lockedCategories
end


-- function FM_Data.GetBodyDetailsFromCache(desc)
--     local isFemale = desc:isFemale()

--     local skinTone = desc:getHumanVisual():getSkinTextureIndex() + 1
--     local gender = isFemale and "Female" or "Male"

--     FM_Data.Cache.BodyDetails[gender][skinTone] = FM_Data.Cache.BodyDetails[gender][skinTone] or FM_Data.GetBodyDetailsForCharacter(desc)

--     return FM_Data.Cache.BodyDetails[gender][skinTone]
-- end



return SPNCC_Data
