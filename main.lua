NAME = "sarisse"
CODE_ID = "12a67-9"
VERSION = "0.0.2"

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
    HoloDisplay:register()

    print("Started")
    print(NAME .. " (" .. CODE_ID .. ") v" .. VERSION .. ")")
end

local function on_fail(err)
    out(false)
    print("failed : " .. string.match(err, "(.-)\n"))
end

local function on_stop()
    if HoloDisplay.holo ~= nil then
        HoloDisplay.holo.clear()
        HoloDisplay.holo.flush()
    end

    out(false)
    print("stopped")
end

local function on_tick(dt)
    Radar:update()
    HoloDisplay:update(Radar:getTargets())

    if total_ticks % (40 * 2) == 0 then
        print("DEV REPORT")
        print("radar count = " .. Radar.target_count)
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