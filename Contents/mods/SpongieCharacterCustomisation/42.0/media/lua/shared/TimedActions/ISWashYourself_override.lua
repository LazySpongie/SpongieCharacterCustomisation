
---@diagnostic disable-next-line: duplicate-set-field
function ISWashYourself:complete()
	local visual = self.character:getHumanVisual()
	local waterUsed = 0
	for i=1,BloodBodyPartType.MAX:index() do
		local part = BloodBodyPartType.FromIndex(i-1)
		if self:washPart(visual, part) then
			waterUsed = waterUsed + 1
			-- using soap provides a modest happiness boost
			if self.soaps then
				self.character:getBodyDamage():setUnhappynessLevel(self.character:getBodyDamage():getUnhappynessLevel() - 2);
			end
			if waterUsed >= self.sink:getFluidAmount() then
				break
			end
		end
	end

	triggerEvent("OnClothingUpdated", self.character) --had to uncomment this to sync customisation

	-- remove makeup
	if SandboxVars.SPNCharCustom.WashMakeup then
		self:removeAllMakeup()
	end
	
	--sendVisual(self.character);
	sendHumanVisual(self.character);

	if instanceof(self.sink, "IsoWorldInventoryObject") then
		self.sink:useFluid(waterUsed)
	else
		if self.sink:useFluid(waterUsed) > 0 then
			self.sink:transmitModData()
		end
	end

	return true
end

