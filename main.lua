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

    print("started")
end

local function hello()
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
    print("tick " .. total_ticks)
    Radar:update()
    Cache:update(Radar:getTargets())

    -- debug
    if total_ticks == 0 or total_ticks % (40 * 2) == 0 then -- each 2s
        print(#Cache.players, "players")
        print(#Cache.bodies, "bodies")
        print(#Radar:getTargets(), "targets")
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