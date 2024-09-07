local Radar = {
    radar = {},

    targets = {},
    last_change = 0,
    target_count = 0,
    
    angle = 0,
    fovs = { h = 10, v = 180 }
}

function Radar:register()
    self.radar = getComponent("radar")

    print("Radar initiated")
end

-- Update the hardware
function Radar:updateComponent()
    self.radar.setAngle(math.rad(self.angle))

    self.radar.setHFov(math.rad(self.fovs.h))
    self.radar.setVFov(math.rad(self.fovs.v))
end

function Radar:update()
    local changed = false
    local now = os.time()

    for _, target in pairs(self.radar.getTargets()) do
        local entity = create_entity(target)

        if self.targets[entity.id] == nil then
            self.targets[entity.id] = entity
            self.target_count = self.target_count + 1
            changed = true
        end

        self.targets[entity.id].radar_angle = self.angle
        self.targets[entity.id].seen = 0
    end

    for id, entity in pairs(self.targets) do
        if entity.seen ~= now then
            entity.seen = entity.seen + 1
        end

        if entity.seen >= (40 * 5) then
            self.targets[id] = nil
            self.target_count = self.target_count - 1
        end
    end

    -- clear

    if changed then last_change = now end

    -- Rotate radar
    self.angle = self.angle + 9
    if self.angle > 360 then self.angle = self.angle - 360 end

    Radar:updateComponent()
end

function Radar:getTargets()
    return self.targets
end

function create_entity(infos)
	return {
        id=infos[1],
        radar_angle = 0,
		-- force depends on mass and distance
		object = {hangle = math.deg(infos[2]), vangle = math.deg(infos[3]), distance = infos[4], force = infos[5], type = infos[6]},
		not_seen = 0,
		mass = 0
	}
end