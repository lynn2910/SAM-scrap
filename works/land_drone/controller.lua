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

-- ========================#> Program API <#========================
-- here is the computer main api to allow the computer to fullfill it's purpose



-- ========================#> Computer functions <#========================
-- functions that will make use of Program API and allow the computer to work

-- run on computer start. get the linked component and set their initial state
local function on_start()
    out(true)
    print("started")
end

local function on_fail(err)
    out(false)
    print("failed : " .. string.match(err, "(.-)\n"))
end

-- do a cleanup of things
local function on_stop()
    out(false)  -- set the computer as off
    print("stopped")
end


-- run every ticks (or x ticks if server parameters are changed)
local function on_tick(dt)
    if total_ticks % 40 ~= 0 then return end
    print(dt)
end

-- ========================#> run loop <#========================

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