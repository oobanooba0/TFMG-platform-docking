local ui = {}

  function ui.on_gui_opened(event)
    if not event.entity or event.entity.name ~= "TFMG-docking-port" then return end
    local gui_storage = storage.player_ui[event.player_index]
    gui_storage.entity = event.entity

    TFMG.block(gui_storage)
  end

  function ui.on_gui_closed(event)
    if not event.entity or event.entity.name ~= "TFMG-docking-port" then return end
    local gui_storage = storage.player_ui[event.player_index]
    gui_storage = {}
    TFMG.block(gui_storage)
  end

return ui