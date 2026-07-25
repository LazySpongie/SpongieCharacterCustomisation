
function ISWashYourself:complete()
	local visual = self.character:getHumanVisual()
	local waterUsed = 0
	for i=1,BloodBodyPartType.MAX:index() do
		local part = BloodBodyPartType.FromIndex(i-1)
		if self:washPart(visual, part) then
			waterUsed = waterUsed + 1
			-- using soap provides a modest happiness boost
			if self.soaps then
				self.character:getStats():remove(CharacterStat.UNHAPPINESS, 2);
			end
			if waterUsed >= self.sink:getFluidAmount() then
				break
			end
		end
	end

	-- remove makeup
	if SandboxVars.SPNCharCustom.WashMakeup then
		self:removeAllMakeup()
	end
	
	sendHumanVisual(self.character);

	if instanceof(self.sink, "IsoWorldInventoryObject") then
		self.sink:useFluid(waterUsed)
	else
		if self.sink:useFluid(waterUsed) > 0 then
			self.sink:transmitModData()
		end
	end	

	-- have to add this so that blood on faces is updated
	-- triggerEvent("OnClothingUpdated", self.character)
	
	local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")
	FaceManager_Server.SyncBlood(self.character)

	return true
end

