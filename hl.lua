local vel = {}
local last_onground_speed = 0
local old_onground_speed = 0
local speed = 0
local fade_time = 0
local last_flags = 0

function testflag(set, flag)
    return set % (2*flag) >= flag
end
client.set_event_callback("paint", function()
    if not entity.get_local_player() or entity.is_alive(entity.get_local_player()) then
        return
    end
    local screensize = {client.screen_size}
    local vel[1] = entity.get_prop(entity.get_local_player(), "m_vecVelocity[0]")
	local vel[2] = entity.get_prop(entity.get_local_player(), "m_vecVelocity[1]")
    local vel[3] = math.sqrt(vel[1] * vel[1] + vel[2] * vel[2])
    local finalvel = math.min(9999, vel[3]) + 0.2
    finalvel = math.floor(finalvel)
    local flags = Entity:GetPropInt( "m_fFlags" )

    if testflag(flags, 1) and not testflag(last_flags, 1) then
        old_onground_speed = last_onground_speed
        last_onground_speed = finalvel
        fade_time = 1
    end
    last_flags = flags

    if fade_time > globals.frametime() then
        fade_time = fade_time - globals.frametime()
    end
    local speed_delta = last_onground_speed - old_onground_speed

    renderer.draw_text(screensize[1] / 2, screensize[2] / 1.25, 255, 255, 255, 220, "c+", 0, speed)

    local r = 255
    local g = 255
    local b = 255
    
    if speed_delta > 0 and fade_time > 0.5 then
        r = 30
        g = 220
        b = 30
    end
    
    if speed_delta < 0 and fade_time > 0.5 then
        r = 220
        g = 30
        b = 30
    end
    renderer.draw_text(screensize[1] / 2, screensize[2] / 1.22, r, g, b, 220, "c+", 0, speed)
end)