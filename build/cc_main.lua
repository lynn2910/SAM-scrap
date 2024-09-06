local Cache = {
	players = {},
	bodies = {}
}

function Cache:add(entity)
	if entity.object.type == "character" then
		if self.players[entity.object.id] ~= nil then
		    self.players[entity.object.id].object = entity.object
		else
			self.players[entity.object.id] = entity
		end
	elseif entity.object.type == "body" then
		if self.bodies[entity.object.id] ~= nil then
    		self.bodies[entity.object.id].object = entity.object
    	else
    	    self.bodies[entity.object.id] = entity
    	end
	end
end

function Cache:update(targets)
	local seen = {}
	-- add targets
	for target in targets do
	    Cache:add(create_entity(target))
	end

	-- Cache cleaner
	for id, player in pairs(self.players) do
		if not seen[id] then
			if player.not_seen > 200 then -- 5s
				self.players[id] = nil
			else
				self.players[id].not_seen = player.not_seen + 1
			end
		end
	end
	for id, body in pairs(self.bodies) do
		if not seen[id] then
			if body.not_seen > 200 then -- 5s
				self.bodies[id] = nil
			else
				self.bodies[id].not_seen = body.not_seen + 1
			end
		end
	end
end

function create_entity(infos)
	return {
		-- force depends on mass and distance
		object = {id=infos[1], hangle = infos[2], vangle = infos[3], distance = infos[4], force = infos[5], type = infos[6]},
		dir_vector = sm.vec3.new(0, 0, 0),
		not_seen = 0
	}
end
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
print("Hello world")