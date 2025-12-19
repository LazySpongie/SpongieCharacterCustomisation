
if true then return end	-- this is so the example code doesnt run


--[[ 	
		This file will explain all of the parameters you can set when adding customisation to the mod


		Items are sorted alphabetically by their internal name and not their actual display name. 
		If you want to group certain options together you can add a "sort" parameter

]]


	

--You will need to require these at the start of your file
local FM_Data = require("CharacterCustomisation/FM_Data")
local FM_Presets = require("CharacterCustomisation/FM_Presets")


	-- ------------------------
	-- -- 	Face Options
	-- ------------------------
											--Optional means that you can remove the line and it will automatically use a default value instead

local face = {
	name = "TestFace",						--Unique Name (will overwrite duplicates)

	id = "Base.Face_Test_1",				--Item Name
	
	display = "TestFace",					--Optional, by default the name will be used for the ui but you can overwrite it with this

	textures = 		{						--Choose which texture index to use on the clothing item for each skintone (set to -1 to make it not available for that skintone)
												--Optional, if this table doesn't exist it will just use the skintone as the texture index
		0,									--Skintone 1
		1,									--Skintone 2
		2,									--Skintone 3
		3,									--Skintone 4
		4,									--Skintone 5
					},
	textureOffset = 5,						--Optional, adds an offset when using the skintone as a texture index. Used for packing multiple sets of textures into one item
	
	randomExcluded = true,					--Optional, prevents this option from being picked when pressing the randomise button in character creation

	category = "Admin",						--Optional, allows server admins to hide customisation options that have a certain category

	icon = FM_Presets.IconPresets.freckles,	--Optional, choose what texture is used for the icon in the menu
												--You can set your own texture path here or use a preset one
												--Texture should be 32x32 or it will have scaling artifacts

	sort = "z"								--Optional, string used when sorting the menu lists alphabetically
												--used to group items together
												--defaults to "b"
												--"a" is exclusively for the default face
}



	-- ------------------------
	-- -- 	Body Detail Options
	-- ------------------------
											--Optional means that you can remove the line and it will automatically use a default value instead
local bodyDetail = {
	name = "test",							--Unique Name (will overwrite duplicates)

	id = "Base.Detail_test",				--Item Name
	
	display = "TestFace",					--Optional, by default the name will be used for the ui but you can overwrite it with this

	male = false,	 						--Available for male characters (removing this line defaults to true)

	female = false,	 						--Available for female characters (removing this line defaults to true)

	visionModifier = true,					--Optional, displays an icon in the menu indicating that this option affects the players vision modifer (b42 exclusive)

	textures = 		{						--Choose which clothing item texture index to use for each skintone (set to -1 to make it not available)
												--You can use this to add a different texture for certain skintones without needing to add duplicate textures to the item
												--You can also use this to pack multiple similar textures like freckles into just one clothing item (See the Details pack for an example)
		0,									--Skintone 1
		0,									--Skintone 2
		2,									--Skintone 3
		-1,									--Skintone 4
		5,									--Skintone 5
					},
	textureOffset = 5,						--Optional, adds an offset when using the skintone as a texture index. Used for packing multiple options into one item

	view = FM_Presets.face,					--The camera settings for the preview avatar, see FM_Presets.lua

	randomExcluded = true,					--Optional, prevents this option from being picked when pressing the randomise button in character creation

	category = "Joke",						--Optional, allows server admins to hide customisation options that have a certain category

	icon = FM_Presets.IconPresets.shot,		--Optional, choose what texture is used for the icon in the menu. See FM_Presets.lua
												--You can use your own texture path here or use a preset one
												--Texture should be 32x32 or it will have scaling artifacts

	sort = "z"								--Optional, string used when sorting the menu lists alphabetically
												--defaults to "b" for body items like freckles and moles
												--used to group items together, ie I dont want accessories like bandages to appear before stuff like freckles
}


	-- ------------------------
	-- -- 	Examples
	-- ------------------------

local face2 = {
	name = "TestFace2",						--Most face entries will just look like this
	id = "Base.Face_Test_2",
}

local bodyDetail2 = {
	name = "test",
	id = "Base.Detail_GunshotFace",
	male = false,
	textures = 		{
		0,									--If you add only one texture index here then it will be used for all skintones
						},
	view = FM_Presets.torsoback,
	randomExcluded = true,
	category = "Halloween",
	icon = "media/textures/Item_Jackolantern.png",
}

--These are the functions you use to add your options into the mod
FM_Data.AddMaleFaceData(face)
FM_Data.AddFemaleFaceData(face2)
FM_Data.AddBodyDetailData(bodyDetail)
FM_Data.AddBodyDetailData(bodyDetail2)

