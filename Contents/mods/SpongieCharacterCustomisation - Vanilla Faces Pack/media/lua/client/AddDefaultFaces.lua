local FM_Data = require("CharacterCustomisation/FM_Data")
-- local FM_Presets = require("CharacterCustomisation/FM_Presets")

	-- ----------------------
	-- -- 	MALE FACES
	-- ----------------------
local MaleFaces = {
	--------------------------
	{	name = "Frank",
		id = "Base.Face_Frank",
	},
	--------------------------
	{	name = "James",
		id = "Base.Face_James",
	},
	--------------------------
	{	name = "Chris",
		id = "Base.Face_Chris",
	},
	--------------------------
	{	name = "Hank",
		id = "Base.Face_Hank",
	},
}
	-- ----------------------
	-- -- 	FEMALE FACES
	-- ----------------------
local FemaleFaces = {
	--------------------------
	{	name = "CaseyJo",
		id = "Base.Face_CaseyJo",
	},
	--------------------------
	{	name = "Janine",
		id = "Base.Face_Janine",
	},
	--------------------------
	{	name = "Maryanne",
		id = "Base.Face_Maryanne",
	},
	--------------------------
	{	name = "Vicky",
		id = "Base.Face_Vicky",
	},
}
for i, v in ipairs(MaleFaces) do
	FM_Data.AddMaleFaceData(v)
end
for i, v in ipairs(FemaleFaces) do
	FM_Data.AddFemaleFaceData(v)
end