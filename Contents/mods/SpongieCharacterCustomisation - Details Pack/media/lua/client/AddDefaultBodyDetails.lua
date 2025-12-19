local FM_Data = require("CharacterCustomisation/FM_Data")
local FM_Presets = require("CharacterCustomisation/FM_Presets")
local camera = FM_Presets.CameraPresets
local icons = FM_Presets.IconPresets
	-- ----------------------
	-- -- 	BODY DETAILS
	-- ----------------------


local BodyDetails = {
	---------------------------------------------------------
	--		Freckles
	---------------------------------------------------------
	{	name = "Freckles1", id = "Base.Detail_Freckles", display = "FrecklesFace",
		textures = 		{
			0,
			0,
			0,
			1,
			1,
							},
		view = camera.faceclose, icon = icons.freckles,
	},
	--------------------------
	{	name = "Freckles2", id = "Base.Detail_Freckles", display = "FrecklesFace",
		textures = 		{
			2,
			2,
			2,
			3,
			3,
							},
		view = camera.faceclose, icon = icons.freckles,
	},
	--------------------------
	{	name = "Freckles3",
		id = "Base.Detail_Freckles",
		display = "FrecklesFace",
		textures = 		{
			4,
			4,
			4,
			5,
			5,
							},
		view = camera.faceclose, icon = icons.freckles,
	},
	--------------------------
	{	name = "FrecklesBody1", id = "Base.Detail_Freckles", display = "FrecklesBody",
		textures = 		{
			6,
			6,
			6,
			7,
			7,
							},
		view = camera.chestclose, icon = icons.freckles,
	},
	---------------------------------------------------------
	--		Moles
	---------------------------------------------------------
	{	name = "Moles1", id = "Base.Detail_Moles", display = "MolesFace",
		textures = {	0	},
		view = camera.facelower, icon = icons.freckles,
	},
	--------------------------
	{	name = "Moles2", id = "Base.Detail_Moles", display = "MolesFace",
		textures = {	1	},
		view = camera.facelower, icon = icons.freckles,
	},
	--------------------------
	{	name = "Moles3", id = "Base.Detail_Moles", display = "MolesFace",
		textures = {	2	},
		view = camera.facelower, icon = icons.freckles,
	},
	---------------------------------------------------------
	--		Scars Face
	---------------------------------------------------------
	{	name = "ScarFace1_L", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	0	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarFace1_R", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	1	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace2", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	2	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace3_L", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	3	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarFace3_R", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	4	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace4_L", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	5	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarFace4_R", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	6	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace5_L", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	7	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarFace5_R", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	8	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace6_L", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	9	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarFace6_R", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	10	},
		view = camera.faceclose, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace7", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	11	},
		view = camera.facelower, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarFace8", id = "Base.Detail_Scar_Face", display = "ScarFace", sort = "c1",
		textures = {	12	},
		view = camera.facelower, icon = icons.scars, category = "Scars",
	},
	---------------------------------------------------------
	--		Scars Chest
	---------------------------------------------------------
	{	name = "ScarBodyChest1", id = "Base.Detail_Scar_Body_Chest", display = "ScarBody", sort = "c2",
		textures = {	0	},
		view = camera.torso, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarBodyChest2", id = "Base.Detail_Scar_Body_Chest", display = "ScarBody", sort = "c2",
		textures = {	1	},
		view = camera.torso, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarBodyChest3", id = "Base.Detail_Scar_Body_Chest", display = "ScarBody", sort = "c2",
		textures = {	2	},
		view = camera.torso, icon = icons.scars, category = "Scars",
	},
	---------------------------------------------------------
	--		Scars Stomach
	---------------------------------------------------------
	{	name = "ScarBodyStomach1", id = "Base.Detail_Scar_Body_Stomach", display = "ScarBody", sort = "c3",
		textures = {	0	},
		view = camera.torso, icon = icons.scars, category = "Scars",
	},
	--------------------------
	{	name = "ScarBodyStomach2", id = "Base.Detail_Scar_Body_Stomach", display = "ScarBody", sort = "c3",
		textures = {	1	},
		view = camera.torso, icon = icons.scars, category = "Scars",
	},
	---------------------------------------------------------
	--		Scars Other
	---------------------------------------------------------
	{	name = "ScarBodyOther1_L", id = "Base.Detail_Scar_Body_Other", display = "ScarBody", sort = "c4",
		textures = {	0	},
		view = camera.armleft, icon = icons.scars, category = "Scars",
	},
	{	name = "ScarBodyOther1_R", id = "Base.Detail_Scar_Body_Other", display = "ScarBody", sort = "c4",
		textures = {	1	},
		view = camera.armright, icon = icons.scars, category = "Scars",
	},
	---------------------------------------------------------
	--		Burns
	---------------------------------------------------------
	{	name = "BurnFace1_L", id = "Base.Detail_Burn", display = "BurnFace", sort = "d1",
		textures = {	0	},
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true,
	},
	{	name = "BurnFace1_R", id = "Base.Detail_Burn", display = "BurnFace", sort = "d1",
		textures = {	1	},
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true,
	},
	--------------------------
	{	name = "BurnFace2_L", id = "Base.Detail_Burn", display = "BurnFace", sort = "d1",
		textures = {	2	},
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true,
	},
	{	name = "BurnFace2_R", id = "Base.Detail_Burn", display = "BurnFace", sort = "d1",
		textures = {	3	},
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true,
	},
	--------------------------
	{	name = "BurnFace3_L_Male", id = "Base.Detail_MissingEye", display = "BurnFace", sort = "d1",
		textures = {	4	}, female = false,
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true, visionModifier = true,
	},
	{	name = "BurnFace3_R_Male", id = "Base.Detail_MissingEye", display = "BurnFace", sort = "d1",
		textures = {	5	}, female = false,
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true, visionModifier = true,
	},
	--------------------------
	{	name = "BurnFace3_L_Female", id = "Base.Detail_MissingEye", display = "BurnFace", sort = "d1",
		textures = {	6	}, male = false,
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true, visionModifier = true,
	},
	{	name = "BurnFace3_R_Female", id = "Base.Detail_MissingEye", display = "BurnFace", sort = "d1",
		textures = {	7	}, male = false,
		view = camera.faceclose, icon = icons.burn, category = "Burns", randomExcluded = true, visionModifier = true,
	},
	---------------------------------------------------------
	--		Missing Eyes
	---------------------------------------------------------
	{	name = "EyeMissing1_L", id = "Base.Detail_MissingEye", display = "MissingEye", sort = "d1",
		textures = {	0	},
		view = camera.faceclose, icon = icons.missingeye, category = "MissingEye", randomExcluded = true, visionModifier = true,
	},
	{	name = "EyeMissing1_R", id = "Base.Detail_MissingEye", display = "MissingEye", sort = "d1",
		textures = {	1	},
		view = camera.faceclose, icon = icons.missingeye, category = "MissingEye", randomExcluded = true, visionModifier = true,
	},
	--------------------------
	{	name = "EyeMissing2_L", id = "Base.Detail_MissingEye", display = "MissingEye", sort = "d1",
		textures = {	2	},
		view = camera.faceclose, icon = icons.missingeye, category = "MissingEye", randomExcluded = true, visionModifier = true,
	},
	{	name = "EyeMissing2_R", id = "Base.Detail_MissingEye", display = "MissingEye", sort = "d1",
		textures = {	3	},
		view = camera.faceclose, icon = icons.missingeye, category = "MissingEye", randomExcluded = true, visionModifier = true,
	},
}

for i, v in ipairs(BodyDetails) do
	FM_Data.AddBodyDetailData(v)
end
