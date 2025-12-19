
local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")

local function doBodyHair(player, data)
	if data.bodyHair or not data.bodyHairGrowthEnabled or data.GrowTimer.bodyHair == 0 then return false end
	
	data.GrowTimer.bodyHair = data.GrowTimer.bodyHair - 1
	
	print("PRINTING BODY GROWTH: " .. tostring(data.GrowTimer.bodyHair))

	if data.GrowTimer.bodyHair <= 0 then
		FaceManager_Server.AddPlayerBodyHair(player)
		data.GrowTimer.bodyHair = SandboxVars.SPNCharCustom.BodyHairGrowth *24
	end
end
local function doHeadStubble(player, data)
	if data.stubbleHead or not data.bodyHairGrowthEnabled or data.GrowTimer.stubbleHead == 0 then return false end

	data.GrowTimer.stubbleHead = data.GrowTimer.stubbleHead - 1

	-- print("PRINTING HEAD STUBBLE GROWTH: " .. tostring(data.GrowTimer.stubbleHead))

	if data.GrowTimer.stubbleHead <= 0 then
		FaceManager_Server.AddPlayerStubble(player, false)
		data.GrowTimer.stubbleHead = SandboxVars.SPNCharCustom.StubbleHeadGrowth *24
	end
end
local function doBeardStubble(player, data)
	if player:isFemale() or data.stubbleBeard or not data.bodyHairGrowthEnabled or data.GrowTimer.stubbleBeard == 0 then return false end

	data.GrowTimer.stubbleBeard = data.GrowTimer.stubbleBeard - 1
	
	-- print("PRINTING BEARD STUBBLE GROWTH: " .. tostring(data.GrowTimer.stubbleBeard))

	if data.GrowTimer.stubbleBeard <= 0 then
		FaceManager_Server.AddPlayerStubble(player, true)
		data.GrowTimer.stubbleBeard = SandboxVars.SPNCharCustom.StubbleBeardGrowth *24
	end
end


local function GrowPlayerBodyHair(player)
	if player:isDead() then return end

	local data = player:getModData().SPNCharCustom
	if not data then
		print(player:getUsername() .. " does not have data")
		return
	end

	doBodyHair(player, data)
	doHeadStubble(player, data)
	doBeardStubble(player, data)
end

--here we grow the body hair each day
local function EveryHours()
	if isClient() then return end
	
	-- singleplayer
	if not isServer() then
		GrowPlayerBodyHair(getPlayer())
		return
	end

	-- multiplayer
	local players = getOnlinePlayers()
	if players:isEmpty() then return end
	for i = 0, players:size()-1 do
		GrowPlayerBodyHair(players:get(i))
	end
end

Events.EveryHours.Add(EveryHours)