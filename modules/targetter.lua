local Turret = {
    status = 0,
    hmotor = {},
    vmotor = {},

    hangle = 0,
    vangle = 0,
    h_constrain = {math.rad(0), math.rad(0)},
    v_constrain = {math.rad(0), math.rad(0)},

    rotation_strength = 10,
    rotation_velocity = 10,

    min_mass_accepted = 10,
    old_diff_hangle = 0
}

function Turret:set_vangle(angle)
    self.vangle = angle
    self.vmotor.setAngle(math.rad(angle))
end

function Turret:set_hangle(angle)
    self.hangle = angle
    self.hmotor.setAngle(math.rad(angle))
end

function Turret:move_hangle(step)
    self:set_hangle(self.hangle + step)
end

function Turret:move_vangle(step)
    self:set_vangle(self.vangle + step)
end

function Turret:register()
    local motors = getComponents("motor")
    self.hmotor = motors[1]

    if self.hmotor == nil then
        print("horizontal_motor not found")
        return
    end

    self.hmotor.setAngle(self.hangle)
    self.hmotor.setStrength(self.rotation_strength)
    self.hmotor.setVelocity(self.rotation_velocity)
    self.hmotor.setActive(true)

    self.vmotor = motors[2]

    if self.vmotor == nil then
        print("vertical_motor not found")
        return
    end

    self.vmotor.setAngle(self.vangle)
    self.vmotor.setStrength(self.rotation_strength)
    self.vmotor.setVelocity(self.rotation_velocity)
    self.vmotor.setActive(true)
end

local Targetter = {
    lock = false,
    target = nil
}

function Targetter:register(opt)
    if opt ~= nil and opt.turret then
        Turret:register()
    end

    print("Targetter initiated")
end


function Targetter:update()
    if Cache.counts.bodies <= 0 then return end

    -- for now, take the bigger!
    local bigger_target_id, biggest_mass;

    for id, target in pairs(Cache.bodies) do
        if target.mass >= Turret.min_mass_accepted and target.mass > (biggest_mass or 0) then
            bigger_target_id = id
            biggest_mass = target.mass
        end
    end

    local changed = false;
    if bigger_target_id ~= nil and (self.target == nil or bigger_target_id ~= self.target.object.id) then
        print("New target")
        print("ID      ", bigger_target_id)
        print("Mass    ", biggest_mass)
        print("Distance", Cache.bodies[bigger_target_id].object.distance)
        self.target = Cache.bodies[bigger_target_id]
        self.lock = true
        changed = true
    elseif self.target ~= nil then
        -- update target
        self.target = Cache.bodies[self.target.object.id]
        change = true
    end

    -- Update the laser motors every update
    if changed or (self.target ~= nil and self.target.object.hangle ~= Turret.hangle) then Targetter:updateMotor() end
end


function Targetter:updateMotor()
    if not self.lock or self.target == nil then return end

    -- Update horizontal motor
    local diff_angle_sum = 0 --Turret.hangle - self.target.object.hangle
    local i = 0
    local positions = Radar:getTargetHAngles(self.target.object.id);
    
    if #positions == 0 then return end

    for _, hangle in ipairs(positions) do
        i = i + 1
        diff_angle_sum = diff_angle_sum + (Turret.hangle - hangle)
    end

    local diff_angle = diff_angle_sum / i;

    -- if i == 0 or if the diff_angle is infinite, well, something went really wrong.
    if math.abs(diff_angle) == math.huge or i == 0 then return end


    if diff_angle > 180 then diff_angle = diff_angle - 360 end
    if diff_angle < -180 then diff_angle = diff_angle + 360 end

    -- Define a smaller step size (e.g., 5 degrees)
    -- local step_size = math.max(5 - math.abs(diff_angle) * 0.01, 0.1)
    local step_size = 100 * math.exp(-math.abs(diff_angle) / 50) - 2.7323722447292558


    -- Move the turret by the step size towards the target
    if diff_angle > 0 then
        diff_angle = math.min(diff_angle, step_size)
    else
        diff_angle = math.max(diff_angle, -step_size)
    end

    if math.abs(diff_angle) > 0.1 then
        Turret:move_hangle(math.max(diff_angle, -step_size))
    end
end

-- local motor = getMotors()[1]
-- if motor == nil then return end
-- motor.setVelocity(10)
-- motor.setStrength(10)
-- motor.setActive(true)

--[[

data = {
getVelocity(),
setVelocity(num),
getStrength(),
setStrength(num),
getAngle(),
setAngle(num | nil),
isActive(),
setActive(num | bool)
}

]]