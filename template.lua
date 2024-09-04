--[[                                --> Scrap Mechanic Computer <--
    Author: https://github.com/lil-evil/
    Licence: GNU Genercal Public Licence v3
    Description: *to define*
    Needed connection: 
        - *to define*

    Connections layout: 
        - *to define*

    Mods needed: 
        - SComputers [Fork] (https://steamcommunity.com/sharedfiles/filedetails/?id=2949350596)

    Mods optional:
        - better API (https://steamcommunity.com/sharedfiles/filedetails/?id=3177944610) : for a stable and faster lua engine

    Comentaries:
        None

]]

-- ========================#> Essentials functions <#========================
-- here goes the function that will be used for the whole program to use. including debug and utilities functions

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
    out(true)   -- set the computer as on
    print("started")
end

-- do a cleanup of critical things, and maybe report the error. on return true, the computer can restart
local function on_fail(err)
    out(false) -- set the computer as off (even if it's normally failed)
    print("failed : " .. string.match(err, "(.-)\n"))  -- only get the error string, without the trace back
end

-- do a cleanup of things
local function on_stop()
    out(false)  -- set the computer as off
    print("stopped")
end


-- run every ticks (or x ticks if server parameters are changed)
local function on_tick(dt)

end

-- ========================#> run loop <#========================

function callback_loop() --a new entry point to the program
    if _endtick then
        on_stop()
    else
        total_ticks = total_ticks + 1
        on_tick(getDeltaTimeTps())
    end
end

function callback_error(err) --native SComputers error handler
    if on_fail(err) then
        reboot()
    end
end

on_start()