local FM_Presets = {}

--This file includes presets for avatar camera data as well as icons


-- ------------------------------------
-- -- CAMERA PRESETS
-- ------------------------------------
--These are presets of the camera settings you can have your body detail use in the menu
--You can make your own settings as long as they follow this format
--See Example.lua
FM_Presets.CameraPresets = {
	default = {
		direction = IsoDirections.S,
		zoom = 10,
		yoffset = -0.7,
		xoffset = 0,
	},
	defaultback = {
		direction = IsoDirections.N,
		zoom = 10,
		yoffset = -0.7,
		xoffset = 0,
	},
	face = {
		direction = IsoDirections.S,
		zoom = 20,
		yoffset = -0.89,
		xoffset = 0,
	},
	faceclose = {
		direction = IsoDirections.S,
		zoom = 22,
		yoffset = -0.875,
		xoffset = 0,
	},
	eyes = {
		direction = IsoDirections.S,
		zoom = 22,
		yoffset = -0.9,
		xoffset = 0,
	},
	facelower = {
		direction = IsoDirections.S,
		zoom = 22,
		yoffset = -0.85,
		xoffset = 0,
	},
	neck = {
		direction = IsoDirections.S,
		zoom = 22,
		yoffset = -0.8,
		xoffset = 0,
	},
	torso = {
		direction = IsoDirections.S,
		zoom = 18,
		yoffset = -0.65,
		xoffset = 0,
	},
	torsoback = {
		direction = IsoDirections.N,
		zoom = 18,
		yoffset = -0.65,
		xoffset = 0,
	},
	armleft = {
		direction = IsoDirections.NW,
		zoom = 18,
		yoffset = -0.6,
		xoffset = 0,
	},
	armright = {
		direction = IsoDirections.NE,
		zoom = 18,
		yoffset = -0.6,
		xoffset = 0,
	},
	chest = {
		direction = IsoDirections.S,
		zoom = 17,
		yoffset = -0.75,
		xoffset = 0,
	},
	chestclose = {
		direction = IsoDirections.S,
		zoom = 19,
		yoffset = -0.77,
		xoffset = 0,
	},
	chestback = {
		direction = IsoDirections.N,
		zoom = 17,
		yoffset = -0.75,
		xoffset = 0,
	},
	lowerbody = {
		direction = IsoDirections.S,
		zoom = 16,
		yoffset = -0.45,
		xoffset = 0,
	},
	lowerbodyback = {
		direction = IsoDirections.N,
		zoom = 16,
		yoffset = -0.45,
		xoffset = 0,
	},
	legs = {
		direction = IsoDirections.S,
		zoom = 13,
		yoffset = -0.3,
		xoffset = 0,
	},
	legsback = {
		direction = IsoDirections.N,
		zoom = 13,
		yoffset = -0.3,
		xoffset = 0,
	},
}


-- ------------------------------------
-- -- ICON PRESETS
-- ------------------------------------
FM_Presets.IconPresets = {
	default = "media/textures/CC_Base.png",
	face = "media/textures/CC_Face.png",
	freckles = "media/textures/CC_Freckles.png",
	scars = "media/textures/CC_Scars.png",
	burn = "media/textures/CC_Burn.png",
	missingeye = "media/textures/CC_Shot.png",
	bandagebrown = "media/textures/CC_Bandage.png",
	bandagewhite = "media/textures/CC_Bandage2.png",
	
	brow = "media/textures/CC_Face_Brow.png",
	eyes = "media/textures/CC_Face_Eyes.png",
	nose = "media/textures/CC_Face_Nose.png",
	mouth = "media/textures/CC_Face_Mouth.png",

	joke = "media/textures/Item_Glasses_Novelty_Groucho.png",
	halloween = "media/textures/Item_Jackolantern.png",
	winter = "media/textures/Item_SnowGlobe.png",
	santa = "media/textures/Item_HatSantaRed.png",

	spiffo = "media/textures/Item_SpiffoXL.png",
	bug = "media/textures/Item_Plumpabug.png",

	sparkles = "media/textures/Item_Sparkles_Rainbow.png",
	crystal = "media/textures/Item_Crystal.png",
}








return FM_Presets