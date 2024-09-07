local Cache = {
	players = {},
	bodies = {},
	counts = { players = 0, bodies = 0 }
}

function Cache:add(entity)
	if entity.object.type == "character" then
		if self.players[entity.object.id] ~= nil then
		    self.players[entity.object.id].object = entity.object
		else
			self.players[entity.object.id] = entity
			self.counts.players = self.counts.players + 1
		end
	elseif entity.object.type == "body" then
		if self.bodies[entity.object.id] ~= nil then
    		self.bodies[entity.object.id].object = entity.object
    	else
    	    self.bodies[entity.object.id] = entity
			self.counts.bodies = self.counts.bodies + 1
    	end
	end
end

function Cache:update(targets)
	local seen = {}
	-- add targets
	for _, target in pairs(targets) do
		local entity = create_entity(target)
		-- update useful informations
		entity.mass = get_mass_from_force(entity.object.force, entity.object.distance)

	    Cache:add(entity)
	end

	-- Cache cleaner
	for id, player in pairs(self.players) do
		if not seen[id] then
			if player.not_seen > 200 then -- 5s
				self.players[id] = nil
				self.counts.players = self.counts.players - 1
			else
				self.players[id].not_seen = player.not_seen + 1
			end
		end
	end
	for id, body in pairs(self.bodies) do
		if not seen[id] then
			if body.not_seen > 200 then -- 5s
				self.bodies[id] = nil
				self.counts.bodies = self.counts.bodies - 1
			else
				self.bodies[id].not_seen = body.not_seen + 1
			end
		end
	end
end

function create_entity(infos)
	return {
		-- force depends on mass and distance
		object = {id=infos[1], hangle = math.deg(infos[2]), vangle = math.deg(infos[3]), distance = infos[4], force = infos[5], type = infos[6]},
		dir_vector = sm.vec3.new(0, 0, 0),
		not_seen = 0,
		mass = 0,
		radar_positions = {}
	}
end

function get_mass_from_force(signal_force, distance)
	return signal_force / distance
end