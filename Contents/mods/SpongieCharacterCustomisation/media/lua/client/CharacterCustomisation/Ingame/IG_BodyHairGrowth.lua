
local FaceManager = require("CharacterCustomisation/FaceManager")


local function doBodyHair(player, data)
	if data.bodyHair or not data.bodyHairGrowthEnabled or data.GrowTimer.bodyHair == 0 then return false end
	
	data.GrowTimer.bodyHair = data.GrowTimer.bodyHair - 1
	
	print("PRINTING BODY GROWTH: " .. tostring(data.GrowTimer.bodyHair))

	if data.GrowTimer.bodyHair <= 0 then
		FaceManager.AddPlayerBodyHair(player)
		data.GrowTimer.bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24
		return true
	end
	return false
end
local function doHeadStubble(player, data)
	if data.stubbleHead or not data.bodyHairGrowthEnabled or data.GrowTimer.stubbleHead == 0 then return false end

	data.GrowTimer.stubbleHead = data.GrowTimer.stubbleHead - 1
	
	print("PRINTING HEAD STUBBLE GROWTH: " .. tostring(data.GrowTimer.stubbleHead))

	if data.GrowTimer.stubbleHead <= 0 then
		FaceManager.AddPlayerStubble(player, false)
		data.GrowTimer.stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24
		return true
	end
	return false
end
local function doBeardStubble(player, data)
	if player:isFemale() or data.stubbleBeard or not data.bodyHairGrowthEnabled or data.GrowTimer.stubbleBeard == 0 then return false end

	data.GrowTimer.stubbleBeard = data.GrowTimer.stubbleBeard - 1
	
	print("PRINTING BEARD STUBBLE GROWTH: " .. tostring(data.GrowTimer.stubbleBeard))

	if data.GrowTimer.stubbleBeard <= 0 then
		FaceManager.AddPlayerStubble(player, true)
		data.GrowTimer.stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24
		return true
	end
	return false
end


--here we grow the body hair each day
function FaceManager.GrowBodyHair()
	local player = getPlayer()
	local data = player:getModData().SPNCharCustom
		
	local hairHasChanged = false
	
	if doBodyHair(player, data) then hairHasChanged = true end
	
	if doHeadStubble(player, data) then hairHasChanged = true end
	
	if doBeardStubble(player, data) then hairHasChanged = true end
	
	if hairHasChanged then
		triggerEvent("OnClothingUpdated", player)
	end
end



Events.EveryHours.Add(FaceManager.GrowBodyHair)