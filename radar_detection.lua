local total_ticks = 0
local second = 40

local radar;
local targetted;

local cache = {players = {},bodies = {},}
local time_before_clearing_entity = second * 5

local function cache_add_entity(id, hangle, vangle, distance, force, type)
    if type == "character" then
        cache.players[id] = {
            object = {id=id, hangle = hangle, vangle = vangle, distance = distance, force = force},
            vectors = {
                direction = nil,
                not_seen_ticks = 0
            }
        }
    else
        cache.bodies[id] = {
            object = {id=id, hangle = hangle, vangle = vangle, distance = distance, force = force},
            vectors = {
                direction = nil,
                not_seen_ticks = 0
            }
        }
    end
end

local function cache_remove_entity(id, type)
    if type == "character" then
        cache.players[id] = nil
    else
        cache.bodies[id] = nil
    end
end

local function cache_get_entity(id, type)
    if type == "character" then
        return cache.players[id]
    else
        return cache.bodies[id]
    end
end

local function cache_update_entity(id, hangle, vangle, distance, force, type)
    if type == "character" then
        cache.players[id].object = {id=id, hangle = hangle, vangle = vangle, distance = distance, force = force}
        cache.players[id].vectors.not_seen_ticks = 0
    else
        cache.bodies[id].object = {id=id, hangle = hangle, vangle = vangle, distance = distance, force = force}
        cache.bodies[id].vectors.not_seen_ticks = 0
    end
end


-- Updates the radar angle each tick to detect all targets around the radar
local function update_radar_angle()
    -- The radar angle should be either 0° or 180° (pi)
    if radar.getAngle() ~= math.pi then
        radar.setAngle(math.pi)
    else
        radar.setAngle(0)
    end
end

-- Laser controller

-- data = {
--    getVelocity(),
--    setVelocity(num),
--    getStrength(),
--    setStrength(num),
--    getAngle(),
--    setAngle(num | nil),
--    isActive(),
--    setActive(num | bool)
-- }

-- local motor = getMotors()[1]
-- if motor == nil then return end
-- motor.setVelocity(10)
-- motor.setStrength(10)
-- motor.setActive(true)

local motor_deg_rotation = 0
local function update_laser_motors()
    local motor = getMotors()[1]

    motor_deg_rotation = motor_deg_rotation + 10;
    motor.setAngle(math.rad(motor_deg_rotation))
end


local real_print = print
local function print(...)
    if DEBUG_PRINT_ALLOWED then
        real_print(...)
    elseif DEBUG_PRINT_ALLOWED == nil then
        DEBUG_PRINT_ALLOWED = pcall(real_print, nil)
        print(...)
    end
end

local function on_start()
    out(true)

    radar = getComponent("radar");
    radar.setHFov(math.pi)
    radar.setVFov(math.pi)

    local motor = getMotors()[1]

    motor.setVelocity(1000)
    motor.setStrength(1000)
    motor.setActive(true)


    print("started")
end

local function on_fail(err)
    out(false)
    print("failed : " .. string.match(err, "(.-)\n"))
end

local function on_stop()
    out(false)
    print("stopped")
end

-- iterate over all bodies and players stored in cache and update their vectors
local function update_cache(seen_now)
    for id, body in pairs(cache.players) do
        if not seen_now[id] then
            if body.vectors.not_seen_ticks >= time_before_clearing_entity then
                cache_remove_entity(id, "character")
            else
                body.vectors.not_seen_ticks = body.vectors.not_seen_ticks + 1
            end
        end
    end
    for id, body in pairs(cache.bodies) do
        if not seen_now[id] then
            if body.vectors.not_seen_ticks >= time_before_clearing_entity then
                cache_remove_entity(id, "body")
            else
                body.vectors.not_seen_ticks = body.vectors.not_seen_ticks + 1
            end
        end
    end
end

local function on_tick(dt)
    update_radar_angle()

    local seen_now = {}
    local targets = radar.getTargets()
    -- iterate over all targets
    for _, target in pairs(targets) do
        -- Register or update target
        if cache_get_entity(target[1], target[6]) == nil then
            cache_add_entity(unpack(target))
        else
            cache_update_entity(unpack(target))
        end

        -- add the ID to the seen_now
        seen_now[target[1]] = true
    end

    -- TODO target fixe
    if targetted == nil and #targets > 0 and cache_get_entity(targets[1][1], "body") then
        targetted = cache.bodies[targets[1][1]].object.id
    end


    -- Then, update the cache
    update_cache(seen_now)

    -- Update laser
    update_laser_motors()


    -- print infos on cache
    if total_ticks % (second * 2) == 0 then
        print(#cache.players, "players")
        print(#cache.bodies, "bodies")
        print(#targets, "targets")
        print("targetted", targetted)
    end
end

function callback_loop()
    if _endtick then
        on_stop()
    else
        total_ticks = total_ticks + 1
        on_tick(getDeltaTimeTps())
    end
end

function callback_error(err)
    if on_fail(err) then
        reboot()
    end
end

on_start()