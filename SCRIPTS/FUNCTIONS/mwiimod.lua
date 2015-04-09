-- MultiWii command speech LUA scriptzorz!!!
-- Plays audio for the various stick positions used in the multiwii / baseflight / cleanflight / etc. firmwares
-- By Zap Andersson, Sweden
-- Crazy Tweets: http://twitter.com/MasterZap
-- Crazy Videos: http://youtube.com/user/ZapAndersson/videos

local t_next = 0    -- Earliest time allowed for next run.

-- Previous position of these sticks:
local thr_last = 0
local rud_last = 0
local ail_last = 0
local ele_last = 0

-- Current arming state
local state_armed = false

-- ------------------------------------------------------------------------------
-- Here you define the stick positions, and what sound to play
-- Each item in the list has the following values:
--     thr       = throttle position (-1 = LOW, 0 = CENTER, 1 = HIGH)
--     rud       = rudder position   (-1 = LOW, 0 = CENTER, 1 = HIGH)
--     ele       = elevator position (-1 = LOW, 0 = CENTER, 1 = HIGH)
--     ail       = aileron position  (-1 = LOW, 0 = CENTER, 1 = HIGH)
--     arm       = true if the setting arms, false if it disarms, 
--                 nil if it doesn't affect arming at all
--     need_arm  = true if this only works while armed, falst if only while disarmed, 
--                 nil if it works in either mode
-- ------------------------------------------------------------------------------

local modelist = {
    { thr = -1, rud =  1, ele =  0, ail =  0,  arm=true,  need_arm = nil,   sound="dgrarmed.wav" }, -- Arming
    { thr = -1, rud = -1, ele =  0, ail =  0,  arm=false, need_arm = nil,   sound="disarmed.wav" }, -- Disarming
    { thr = -1, rud = -1, ele =  0, ail = -1,  arm=nil,   need_arm = false, sound="profile1.wav" }, -- Load Profile 1
    { thr = -1, rud = -1, ele =  1, ail =  0,  arm=nil,   need_arm = false, sound="profile2.wav" }, -- Load Profile 2
    { thr = -1, rud = -1, ele =  0, ail =  1,  arm=nil,   need_arm = false, sound="profile3.wav" }, -- Load Profile 3
    { thr = -1, rud = -1, ele = -1, ail =  0,  arm=nil,   need_arm = false, sound="gyro.wav" },     -- Gyro Calibration
    { thr =  1, rud = -1, ele = -1, ail =  0,  arm=nil,   need_arm = false, sound="acceller.wav" }, -- Accelerometer Calibration
    { thr = -1, rud =  1, ele = -1, ail =  0,  arm=nil,   need_arm = false, sound="compass.wav" },  -- Compass Calibration
}


-- Helper functions
-- Returns -1, 0 or 1 at the LOW, CENTER and HIGH extremes, nil for any inbetween values

local function getInput( source )
    local val = getValue(source)

    if val < -950 then  return -1 end
    if val >  950 then  return  1 end
    if val > -50 and val < 50 then 	return 0 end
    return nil
end

-- Main function.... does stuff... :)

local function run_mwiiCommands()
    local t = getTime()

    -- Use timer to fix overrun
    
    if t > t_next then
        t_next = t + 50 -- recheck at about 2 Hz.
    
        local ele = getInput(MIXSRC_Ele)
        local rud = getInput(MIXSRC_Rud)
        local thr = getInput(MIXSRC_Thr)
        local ail = getInput(MIXSRC_Ail)

        -- Skip if any of them are out of scope
        if ele ~= nil and rud ~= nil and thr ~= nil and ail ~= nil then
            if ele ~= ele_last or rud ~= rud_last or thr ~= thr_last or  ail ~= ail_last then
                -- Remember position
                ele_last = ele
                rud_last = rud
                thr_last = thr
                ail_last = ail

                for i = 1, #modelist do
                    if modelist[i].ele == ele and modelist[i].thr == thr and modelist[i].rud == rud and modelist[i].ail == ail and (modelist[i].need_arm == state_armed or modelist[i].need_arm == nil) then
                        if modelist[i].arm ~= nil then
                            state_armed = modelist[i].arm
                        end					
                        playFile("/SOUNDS/en/" .. modelist[i].sound)
                    end
                end
            end
        end		
    end
end

return { run=run_mwiiCommands } -- no background or initialization needed.
