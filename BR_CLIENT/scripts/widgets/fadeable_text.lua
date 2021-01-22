local Widget = require "widgets/widget"
local Text = require "widgets/text"

local function UnpackColour(clr)
	return clr[1] or 1, clr[2] or 1, clr[3] or 1, clr[4] or 1
end

local FadeableText = Class(Text, function(self, font, size, text, colour)
    Text._ctor(self, font, size, text, colour)

    -- self:SetString(text)
    colour = colour or {1, 1, 1, 1}
	
    self.current_colour = colour
    self.target_colour = colour
	self.timepassed = 0
	self.time = 0
end)

function FadeableText:EndFade(runfn)
	self:StopUpdating()
	
	--Set all values to final values
	self.current_colour = self.target_colour
	self:SetColour(UnpackColour(self.target_colour))
	
	self.time = nil

	if self.callback and runfn then
		self.callback(self.inst)
	end
end

function FadeableText:FadeTo(start, stop, time, fn)
	self:StopUpdating()
	
	self.callback = fn
	self.current_colour = start
	self.target_colour = stop

	self.time = time
	self.timepassed = 0
	
	self:StartUpdating()
end

function FadeableText:OnUpdate(dt)
    self.timepassed = self.timepassed + dt
	
	local t = self.timepassed/self.time
	if t > 1 then
		t = 1
	end
	
	local trgt = {}
	
	for i = 1, 4 do 
		table.insert(trgt, Lerp(self.current_colour[i], self.target_colour[i], t))
	end
	
	self:SetColour(UnpackColour(trgt))
	
	if self.timepassed >= self.time then
		self:EndFade(true)
	end
end

return FadeableText
