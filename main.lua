NAME = "sarisse"
CODE_ID = "12a67-9"
VERSION = "0.0.1.23.6"

local total_ticks = 0

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
    out(true)   -- set the computer as on

    Radar:register()
    Targetter:register({ turret = true })

    print("Started")
    print(NAME .. " (" .. CODE_ID .. ") v" .. VERSION .. ")")
end

local function on_fail(err)
    out(false)
    print("failed : " .. string.match(err, "(.-)\n"))
end

local function on_stop()
    out(false)
    print("stopped")
end

local function on_tick(dt)
    Radar:update({ rotate = true })
    Cache:update(Radar:getTargets())
    Targetter:update()

    -- debug
    if total_ticks == 1 or total_ticks % (40 * 5) == 0 then -- each 5s
        print("DEV REPORT " .. (total_ticks / (40 * 5)))
        print(Cache.counts.players, "players")
        print(Cache.counts.bodies, "bodies")
        print(#Radar:getTargets(), "targets")

        if Targetter.target ~= nil then
            print("Locked on " .. Targetter.target.object.id .. " m" .. math.floor(Targetter.target.mass))
        end
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