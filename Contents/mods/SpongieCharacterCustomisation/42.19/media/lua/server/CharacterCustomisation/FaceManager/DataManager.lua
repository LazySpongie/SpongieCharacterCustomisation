
if isClient() then return end

local FaceManager_Server = require("CharacterCustomisation/FaceManager/Main")


	-- -------------------------------------
	-- -- MANAGE DATA
	-- -------------------------------------

function FaceManager_Server.SetDataValue(player, key, value, sendData)
	local data = player:getModData().SPNCharCustom
	data[key] = value
	if sendData and isServer() then sendServerCommand(player, "SPNCC", "SetPlayerModDataValues", {values = {[key] = value}}) end
end

function FaceManager_Server.CreatePlayerData(player)
	local moddata = player:getModData()
	moddata.SPNCharCustom = FaceManager_Server.CreateDefaultPlayerData()
	
	return moddata.SPNCharCustom
end

function FaceManager_Server.CreateDefaultPlayerData()
	local data = {}

	data.version = FaceManager_Server.modversion
	data.hasCustomised = false
	data.face = {name = "DefaultFace", id = "DefaultFace", texture = 0}
	data.bodyDetails = {}
	data.bodyHair = false
	data.stubbleHead = false
	data.stubbleBeard = false
	data.muscleVisuals = SandboxVars.SPNCharCustom.MuscleVisuals ~= 2	--if muscles are not force disabled then we set it to true
	data.bodyHairGrowthEnabled = SandboxVars.SPNCharCustom.BodyHairGrowthEnabled ~= 2

	data.GrowTimer = FaceManager_Server.CreateGrowTimer()

	return data
end

function FaceManager_Server.CreateGrowTimer()
	return {
		stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24,
		stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24,
		bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24,
	}
end

function FaceManager_Server.ConvertData(player, data)
	-- if data.version == 1 then
	-- 	-- convert body hair growth days to hours
	-- 	-- print("Player " .. player:getFullName() .. " SPNCharCustom moddata converted from version 1 to " .. tostring(FaceManager_Server.modversion))
	-- end
end

--adjust players moddata just in case the server settings were changed 
function FaceManager_Server.CheckData(player, data)
	local sandbox = SandboxVars.SPNCharCustom

	--enable or disable muscle visuals
	if sandbox.MuscleVisuals ~= 3 then
		data.muscleVisuals = sandbox.MuscleVisuals == 1
 	end
	--enable or disable body hair growth
	if sandbox.BodyHairGrowthEnabled ~= 3 then
		data.bodyHairGrowthEnabled = sandbox.BodyHairGrowthEnabled == 1
	end

	if data.version ~= FaceManager_Server.modversion then
		FaceManager_Server.ConvertData(player, data)
	end

	--bandaid fix for corrupted mod data that happens to some people for some reason
	data.GrowTimer = data.GrowTimer or FaceManager_Server.CreateGrowTimer()

	--cap body hair growth
	local growTimer = data.GrowTimer
	local math_min = math.min
	growTimer.stubbleHead = math_min(growTimer.stubbleHead, sandbox.StubbleHeadGrowth *24)
	growTimer.stubbleBeard = math_min(growTimer.stubbleBeard, sandbox.StubbleBeardGrowth *24)
	growTimer.bodyHair = math_min(growTimer.bodyHair, sandbox.BodyHairGrowth *24)

end
