--[[

    Documentation: https://github.com/igorkll/SComputers_docs/blob/main/SComputers/Components/gps.md

]]



local Radar = {
	radar = {},
    -- The angle in degrees, from 0° to 360°, and loop back when overflowing
    angle = 0,
    -- The FOV of the camera on the vertical and horizontal axis
    fov = { h = math.pi, v = math.pi },
    rotation_speed = 10,
}

function Radar:getTargets()
	return self.radar.getTargets()
end

function Radar:register()
	self.radar = getComponent("radar")
	self:update({ rotate = false, update_system = true })
end

function Radar:update(opt)
    -- Update the andle and loop back when overflowing
    if opt ~= nil then
        if opt.update_system then
    	    if radar.getHFov() ~= self.fov.h then radar.setHFov(self.fov.h) end
            if radar.getVFov() ~= self.fov.v then radar.setVFov(self.fov.v) end
        end

        if opt.rotate then
            self.angle = self.angle + self.rotation_speed
			if self.angle > 360 then self.angle = self.angle - 360 end
		end
    end

	radar.setAngle(math.rad(self.angle))
end