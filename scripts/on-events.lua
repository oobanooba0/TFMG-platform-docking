--local functions

local function setup_storage()--make sure all important storage tables are ready.
  if not storage.docking_ports then
    storage.docking_ports = {} --this should contain a full list of all existing docking ports, and useful information about them.
  end

  if not storage.docks then --this will be the table containing all my dock ids as they move around and such
    storage.docks = {}
  end
  --setup each directional dock table.
  if not storage.docks.north then storage.docks.north = {} end
  if not storage.docks.east then storage.docks.east = {} end
  if not storage.docks.south then storage.docks.south = {} end
  if not storage.docks.west then storage.docks.west = {} end
  local space_locations = prototypes.space_location
  for direction, table in pairs(storage.docks) do --create a subtable for each space location in the game.
    for _, location in pairs(space_locations) do
      if not table[location.name] then table[location.name] = {} end
    end
  end
  --repeat but for the flib from k thingy
  if not storage.dock_k then --this will be the table containing all my dock ids as they move around and such
    storage.dock_k = {}
  end
  --setup each directional dock table.
  if not storage.dock_k.north then storage.dock_k.north = {} end
  if not storage.dock_k.east then storage.dock_k.east = {} end

  for direction, table in pairs(storage.dock_k) do --create a subtable for each space location in the game.
    for _, location in pairs(space_locations) do
      if not table[location.name] then table[location.name] = {} end
    end
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

script.on_event(
  defines.events.on_space_platform_changed_state,
  function(event)
    docking.space_platform_changed_state(event)
  end
)
--on tick
script.on_event(
  defines.events.on_tick,--Its HaNlDeR sHoUldNt InCluDe PeRfOrMaNce HeAvY CoDe. You cant tell me what to do.
  function(event)
    docking.on_tick(event)
  end
)
