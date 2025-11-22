local ui = {}

--utlity functions
  ui.find_parent_frame = function(element) --find the uppermost frame which this element is in.
    local frame = element
    while frame do
      if frame.tags["TFMG_dock_ui"] then return frame end
      frame = frame.parent
    end
  return nil end

--dock ui sub frame functions

  function ui.main_title_bar(main_frame,caption) --adds the main title bar
    local title_bar = main_frame.add{type = "flow"}
    title_bar.drag_target = main_frame
    title_bar.add{
      type = "label",
      style = "frame_title",
      caption = caption,
      ignored_by_interaction = true
    }

    local empty = title_bar.add {
      type = "empty-widget",
      style = "draggable_space",
      ignored_by_interaction = true,
    }

    empty.style.height = 24
    empty.style.horizontally_stretchable = true
    title_bar.add {
      type = "sprite-button",
      name = "TFMG_dock_ui_x_button",
      style = "frame_action_button",
      sprite = "utility/close",
      tooltip = { "gui.close-instruction" },
    }
  end

  function ui.circuit_control_panel(frame)--add a signal picker
    local control_panel = frame.add{
      type = "flow",
      direction = "horizontal",
      style = "player_input_horizontal_flow",
    }
    control_panel.add{
      type = "label",
      caption = "signal",
    }
    control_panel.add{--little info icon to hover over
      type = "sprite",
      sprite = "info",
      tooltip = "dock-signal description"
    }
    control_panel.add{ --signal picker thingy
      type = "choose-elem-button",
      name = "dock_signal",
      elem_type = "signal",
    }
  end

  function ui.connected_dock_preview(frame)
    local view_panel = frame.add{
      type = "frame",
      style = "inside_deep_frame",
      direction = "vertical"
    }
    view_panel.style.horizontally_stretchable = true
    view_panel.style.vertically_stretchable = true
    view_panel.style.minimal_width = 512
    view_panel.style.minimal_height = 512
    view_panel.style.horizontal_align = "center"
    view_panel.style.vertical_align = "center"

  return view_panel end

  function ui.set_view_panel_camera(view_panel,dock_storage) --set dock camera

    if dock_storage.linked then --if we have a currently linked entity.
      local linked_entity = storage.docking_ports[dock_storage.linked].dock

      local camera = view_panel.add{
        type = "camera",
        position = {0,0}
      }
      camera.style.horizontally_stretchable = true
      camera.style.vertically_stretchable = true
      camera.entity = linked_entity
      camera.zoom = 1
      camera.visible = true

    else --show no dock connected
      view_panel.add{
        type = "label",
        caption = "no dock connected"
      }
    end

  end

--create dock ui primary
  function ui.create_main_frame(event) --primary dock ui creator function
  local player = game.get_player(event.player_index) --get our useful information
  local dock_storage = storage.docking_ports[event.entity.unit_number]

  local main_frame = player.gui.screen.add{
    type = "frame",
    name = "dock_gui",
    direction = "vertical",
    tags = {TFMG_dock_ui = true}
  }
  player.opened = main_frame
  main_frame.style.vertically_stretchable = true
  main_frame.style.horizontally_stretchable = true
  main_frame.auto_center = true

  
  ui.main_title_bar(main_frame,"docking ui title")
  ui.circuit_control_panel(main_frame)
  local view_panel = ui.connected_dock_preview(main_frame)
  ui.set_view_panel_camera(view_panel,dock_storage)

  return main_frame end

--on event functions
  function ui.on_gui_opened(event)
    --conditions to create ui, basically player must exist, you must be clicking on a docking port
    if not event.entity or event.entity.name ~= "TFMG-docking-port" then return end
    if not game.get_player(event.player_index) then return end

    main_frame = ui.create_main_frame(event) --actually create the ui

  end

  function ui.on_gui_click(event)
    if event.element and event.element.name == "TFMG_dock_ui_x_button" then
      ui.find_parent_frame(event.element).destroy()
    end

  end

  function ui.on_gui_closed(event)
    
    if event.element and event.element.tags["TFMG_dock_ui"] then
    event.element.destroy()
    end

  end

return ui