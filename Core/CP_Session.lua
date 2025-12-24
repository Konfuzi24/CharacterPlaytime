CP_sessions = CP_sessions or {}

-- TRACKING OF SESSION TIME -------------------------------------------------------------
local current_date= time()  --get current unix time
local session_time = 0  --start timer at 0 seconds

-- delay function using coroutines
local function delay(tick)
    local th = coroutine.running()
    C_Timer.After(tick, function() coroutine.resume(th) end)
    coroutine.yield()
end

-- function to track the session time. "step" defines the time interval in seconds
local function CountTime(step)
    while(true) do
        delay(step); -- every second
        if not UnitIsAFK("player") then --only count if the player is not AFK
            session_time = session_time + step
            print(session_time)
            CP_sessions[GetCharname()] = {
                name = GetCharname(),
                date = current_date,
                session_time = session_time
            }
            Character_PlaytimeDB[GetCharname()].time=Character_PlaytimeDB[GetCharname()].time + step
        end

    end
end

-- CALL FUNCTION AS COROUTINE
coroutine.wrap(function() CountTime(5) end)()

-----------------------------------------------------------------------------------------