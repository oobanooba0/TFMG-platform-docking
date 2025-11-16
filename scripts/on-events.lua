--local functions

local function setup_storage()--make sure all important storage tables are ready.
  if not storage.docking then --all storage related to docking will go in here
    storage.docking = {}
  end
  if not storage.docking_ports then
    storage.docking_ports = {} --this should contain a full list of all existing docking ports, and useful information about them.
  end
end

local build_event_filter = {--what entities the on build events should check for.
  {
  	filter = "name",
  	name = "TFMG-docking-port",
  	mode = "or"
  },
  {
  	filter = "name",
  	name = "TFMG-docking-belt",
  	mode = "or"
  },
  {
    filter = "transport-belt-connectable",
    mode = "or"
  },
}


--init functions

script.on_init(function()
  setup_storage()
end)

script.on_configuration_changed(function()
  setup_storage()
end)

--build events


script.on_event(
  defines.events.on_built_entity,
  function(event)
    docking.handle_build_event(event)
  end,build_event_filter
)
script.on_event(
  defines.events.on_robot_built_entity,
  function(event)
    docking.handle_build_event(event)
  end,build_event_filter
)
script.on_event(
  defines.events.on_space_platform_built_entity,
  function(event)
    docking.handle_build_event(event)
  end,build_event_filter
)
script.on_event(
  defines.events.on_entity_cloned,
  function(event)
    docking.handle_build_event(event)
  end,build_event_filter
)
script.on_event(
	defines.events.on_object_destroyed,
	function(event)
		docking.handle_destroy_event(event)
	end
)
script.on_event(
  defines.events.on_player_rotated_entity,
  function(event)
    docking.handle_rotate_event(event)
  end
)
script.on_event(
  defines.events.on_player_flipped_entity,
  function(event)
    docking.handle_rotate_event(event)
  end
)
--on tick
script.on_event(
  defines.events.on_tick,--Its HaNlDeR sHoUldNt InCluDe PeRfOrMaNce HeAvY CoDe. You cant tell me what to do.
  function(event)
    docking.on_tick(event)
  end
)
