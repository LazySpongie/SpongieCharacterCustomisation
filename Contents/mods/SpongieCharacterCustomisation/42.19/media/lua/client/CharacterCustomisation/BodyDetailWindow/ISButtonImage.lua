require("ISUI/ISButton")

local base = ISButton
ISButtonImage = base:derive("ISButtonImage")

function ISButtonImage:new(x, y, width, height, image_On, image_Off, target, onclick)
    local o = base:new(x, y, width, height, "", target, onclick)
    setmetatable(o, self)
    self.__index = self

	o.selected = false
	o.image_On = image_On
	o.image_Off = image_Off
    o.useSelectedColor = true
    o.selectedColors = {
        [true] = {r = 1, g = 1, b = 1, a = 1},
        [false] = {r = 1, g = 1, b = 1, a = 0.5},
    }
	return o
end
function ISButtonImage:initialise()
	base.initialise(self)

	self:setImage()
end

function ISButtonImage:onMouseUp(x, y)

    if not self:getIsVisible() then
        return
    end
    local process = false
    if self.pressed == true then
        process = true
    end
    self.pressed = false
    if self.enable and (process or self.allowMouseUpProcessing) then
        getSoundManager():playUISound(self.sounds.activate)

		self:setSelected(not self.selected)

        if self.onclick == nil then return end
        self.onclick(self.target, self, self.onClickArgs[1], self.onClickArgs[2], self.onClickArgs[3], self.onClickArgs[4])
    end
end


function ISButtonImage:setImage()
	self.image = self.selected and self.image_On or self.image_Off
end

function ISButtonImage:isSelected()
	return self.selected
end
function ISButtonImage:setSelected(bool)
	self.selected = bool
	self:setImage()

    local color = self.selectedColors[self.selected]
    if not self.useSelectedColor then color = {r = 1, g = 1, b = 1, a = 1} end

    self:setTextureRGBA(color.r, color.g, color.b, color.a)
end