
require("TimedActions/ISBaseTimedAction")

IS_ShaveBodyHair = ISBaseTimedAction:derive("IS_ShaveBodyHair")

function IS_ShaveBodyHair:isValid()
	return self.character:getInventory():contains(self.item)
end

function IS_ShaveBodyHair:update()
	if self.item then
		self.item:setJobDelta(self:getJobDelta())
	end
end

function IS_ShaveBodyHair:start()
	self:setActionAnim(CharacterActionAnims.Shave)
	self:setOverrideHandModels(self.item:getStaticModel() or "DisposableRazor", nil)

	if self.item then
		self.item:setJobType(getText("UI_characreation_shave"))
		self.item:setJobDelta(0.0)
	end
	self.sound = self.character:playSound("ShaveRazor")
end

function IS_ShaveBodyHair:stop()
	self:stopSound()
	if self.item then
		self.item:setJobDelta(0.0)
	end
    ISBaseTimedAction.stop(self)
end

function IS_ShaveBodyHair:perform()
	self:stopSound()
	if self.item then
		self.item:setJobDelta(0.0)
	end

	-- triggerEvent("OnClothingUpdated", self.character)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function IS_ShaveBodyHair:complete()
	local FaceManager_Server = require("CharacterCustomisation/FaceManager_Server")
	FaceManager_Server.RemovePlayerBodyHair(self.character, true)
	FaceManager_Server.SyncRemoveCustomisation(self.character)
	FaceManager_Server.OnClothingUpdated(self.character)
	
	sendServerCommand(self.character, "SPNCC", "OnClothingUpdated", {})
	return true
end


function IS_ShaveBodyHair:getDuration()
	if self.character:isTimedActionInstant() then
		return 1
	end

	return 50
end

function IS_ShaveBodyHair:stopSound()
	if self.sound and self.character:getEmitter():isPlaying(self.sound) then
		self.character:stopOrTriggerSound(self.sound);
	end
end

function IS_ShaveBodyHair:new(character, item)
	local o = ISBaseTimedAction.new(self, character);

	-- local o = {}
	-- setmetatable(o, self)
	-- self.__index = self
	-- o.character = character;
	o.item = item;
	o.maxTime = o:getDuration();
	return o;
end


return IS_ShaveBodyHair
