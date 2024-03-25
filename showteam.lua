local window = {
    x = 5,
    y = 5,
    w = 100,
    dragable = false
}
local function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end
local function intersect(x, y, w, h)
    local mpos = { ui.mouse_position() }
    return mpos[1] >= x and mpos[1] <= x + w and mpos[2] >= y and mpos[2] <= y + h
end
local function drawteam(x, y, ent)
    local name = entity.get_player_name(ent)
    local health = entity.get_prop(ent, "m_iHealth")
    local epos = { entity.get_origin(ent) }
    local lpos = { entity.get_origin(entity.get_local_player()) }
    local dist = math.floor((distance(epos[1], epos[2], lpos[1], lpos[2]) / 39) * 10) / 10
    local length = renderer.measure_text("", name) * 1.2 + 2
    renderer.rectangle(x, y, length, 15, 20, 20, 20, 200)
    local ncolors = { 255, 255, 255 }
    local hcolors = { 255, 255, 255 }
    local dcolors = { 255, 255, 255 }
    if health < 1 then
        ncolors = { 255, 10, 10 }
        hcolors = {20, 20, 20}
    elseif health <= 25 then
        hcolors = {252, 40, 3}
    elseif health > 25 and health <= 50 then
        hcolors = {252, 140, 3}
    elseif health > 50 and health <= 80 then
        hcolors = {252, 198, 3}
    elseif health > 80 and health <= 92 then
        hcolors = {215, 252, 3}
    elseif health > 92 and health <= 99 then
        hcolors = {190, 252, 3}
    elseif health > 99 then
        hcolors = {148, 252, 3}
    end
    renderer.text(x + 2, y, ncolors[1], ncolors[2], ncolors[3], 255, "", 0, name)
    if health > 0 then
        length = length + renderer.measure_text("", health) * 1.2
        renderer.rectangle(x + renderer.measure_text("", name) * 1.2 + 2, y, renderer.measure_text("", health) * 1.2, 15, 20, 20, 20, 200)
        renderer.text(x - 2 + length, y, hcolors[1], hcolors[2], hcolors[3], 255, "r", 0, health)

        length = length + renderer.measure_text("", tostring(dist) .. "m") * 1.2
        renderer.rectangle(x + renderer.measure_text("", health) * 1.2 + renderer.measure_text("", name) * 1.2 + 4, y, renderer.measure_text("", tostring(dist) .. "m")*1.2, 15, 20, 20, 20, 200)
        renderer.text(x + length, y, dcolors[1], dcolors[2], dcolors[3], 255, "r", 0, dist .. "m")
    end
    return length
end
client.set_event_callback("paint", function()
    if not entity.is_alive(entity.get_local_player()) then return end
    local baseposition = 40
    local spacebetween = 17
    local players = entity.get_all("CCSPlayer")
    local lteam = entity.get_prop(entity.get_local_player(), "m_iTeamNum")
    local mpos = { ui.mouse_position() }
    local m1 = client.key_state(0x01)
    if ui.is_menu_open() then
        if window.dragable and not m1 then
            window.dragable = false
        end
        if window.dragable and m1 then
            window.x = mpos[1] - window.drag_x
            window.y = mpos[2] - window.drag_y
        end
        if intersect(window.x, window.y, window.w, 180) and m1 then
            window.dragable = true
            window.drag_x = mpos[1] - window.x
            window.drag_y = mpos[2] - window.y
        end
    end
    for i = 1, #players do
        if entity.get_prop(players[i], "m_iTeamNum") == lteam and players[i] ~= entity.get_local_player() then
            local idk = drawteam(window.x, window.y + baseposition, players[i])
            baseposition = baseposition + spacebetween
            if idk > window.w then
                window.w = idk
            end
        end
    end
end)