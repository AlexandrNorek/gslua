local model = ui.reference("VISUALS", "Colored models", "Local Player")
client.set_event_callback("net_update_end", function()
    local scoped = entity.get_prop(entity.get_local_player(), "m_bIsScoped")
    if scoped ~= 0 then
        ui.set(model, false)
    else
        ui.set(model, true)
    end
end)