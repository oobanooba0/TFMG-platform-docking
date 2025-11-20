local flib_table = require("__flib__/table")
local math2d = require("__core__/lualib/math2d")

local dock_parts_filter = {"TFMG-docking-port","TFMG-docking-belt"}
local dock_belts_filter = {"TFMG-docking-belt"}
local max_dock_size = 1000

local offsets = {
  [defines.direction.north] = { x = 0, y = -1 },
  [defines.direction.east] = { x = 1, y = 0 },
  [defines.direction.south] = { x = 0, y = 1 },
  [defines.direction.west] = { x = -1, y = 0 },
}

local splitter_offsets = {
  [defines.direction.north] = { x = -0.5, y = 0 },
  [defines.direction.east] = { x = 0, y = 0.5 },
  [defines.direction.south] = { x = 0.5, y = 0 },
  [defines.direction.west] = { x = 0, y = -0.5 },
}

local opposite = {--just get me the opposite direction lmfao
  [defines.direction.north] = defines.direction.south,
  [defines.direction.east] = defines.direction.west,
  [defines.direction.south] = defines.direction.north,
  [defines.direction.west] = defines.direction.east,
  ["north"] = "south",
  ["east"] = "west",
  ["south"] = "north",
  ["west"] = "east",
}

local direction_str = {
  [defines.direction.north] = "north",
  [defines.direction.east] = "east",
  [defines.direction.south] = "south",
  [defines.direction.west] = "west",
  }

local belt_types = {
  "linked-belt",
  "loader",
  "loader-1x1",
  "splitter",
  "transport-belt",
  "underground-belt",
}

local docking = {}
--docking belt manager

  local function snap_dock_belt_direction(docking_part)
    if docking_part.linked_belt_neighbour then 
      docking_part.disconnect_linked_belts()
    end
    local surface = docking_part.surface
    local direction = docking_part.direction
    if docking_part.linked_belt_type == "output" then direction = opposite[direction] end--flip direction when the belt is an output, because reasons
    local search_coordinate = math2d.position.subtract(docking_part.position,offsets[direction])
    local belt = surface.find_entities_filtered{position = search_coordinate, type = belt_types, limit = 1}[1]
    if not belt then return end
    local belt_direction = belt.direction
    if direction == belt_direction then
      docking_part.linked_belt_type = "input"
    elseif direction == opposite[belt_direction] then
      docking_part.linked_belt_type = "output"
    end
    --TFMG.block(docking_part)
  end

  local function find_dock_normal_belt(belt)
    local surface = belt.surface
    do--search infront
      local search_coordinate = math2d.position.add(belt.position,offsets[belt.direction])
      docking_part = surface.find_entities_filtered{position = search_coordinate, name = dock_belts_filter, limit = 1}
      if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
    end
    do--and behind of the belt
      local search_coordinate = math2d.position.subtract(belt.position,offsets[belt.direction])
      docking_part = surface.find_entities_filtered{position = search_coordinate, name = dock_belts_filter, limit = 1}
      if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
    end
  end

  local function find_dock_underground(belt)
    local surface = belt.surface
    if  belt.belt_to_ground_type == "input" then
      docking_part = surface.find_entities_filtered{position = math2d.position.subtract(belt.position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
    else
      docking_part = surface.find_entities_filtered{position = math2d.position.add(belt.position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
    end
    if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
  end
  
  local function find_dock_splitter(belt)
    local surface = belt.surface --this was probably not an amazingly clean way to do it, but its functional
    do
      local position = math2d.position.add(belt.position,splitter_offsets[belt.direction])
      do--search infront
        docking_part = surface.find_entities_filtered{position = math2d.position.add(position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
        if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
      end
      do--and behind of the belt
        docking_part = surface.find_entities_filtered{position = math2d.position.subtract(position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
        if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
      end
    end
    do
      local position = math2d.position.subtract(belt.position,splitter_offsets[belt.direction])
      do--search infront
        docking_part = surface.find_entities_filtered{position = math2d.position.add(position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
        if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
      end
      do--and behind of the belt
        docking_part = surface.find_entities_filtered{position = math2d.position.subtract(position,offsets[belt.direction]), name = dock_belts_filter, limit = 1}
        if docking_part[1] then snap_dock_belt_direction(docking_part[1]) end
      end
    end
  end

  local function find_dock_belt(belt) --when placing belts, we search for a docking connector to snap.
    if not belt.valid then return end
    if belt.type == "transport-belt" or belt.type == "loader" or belt.type == "loader-1x1" or belt.type == "linked_belt" then
      find_dock_normal_belt(belt)
    end
    if belt.type == "underground-belt" then
      find_dock_underground(belt)
    elseif belt.type == "splitter" then
      find_dock_splitter(belt)
    end
    
  end


--local functions
  local function search_shift(axis,position,i,shift) --shifts a cordinate for iterative searches
    local search_coordinate = table.deepcopy(position)
      if i == 1 then
        search_coordinate[axis] = position[axis] + shift --apply our shift
      else
        search_coordinate[axis] = position[axis] - shift
      end
  return search_coordinate end

  local function iterate_children(axis,position,surface,dock_storage)
    for i = 1,2 do
      for shift = 1,max_dock_size do --while true works, but just in case I make a mistake, i dont want this to go on forever.
        local search_coordinate = search_shift(axis,position,i,shift)
        local docking_part = surface.find_entities_filtered{position = search_coordinate, name = dock_parts_filter, limit = 1}

        if not docking_part[1] then break end --if the next shift doesnt have a connector on it, we break the loop.

        if docking_part[1].name == "TFMG-docking-port" then --conflict check, if we find another docking port while iterating, we disconnect all our docks to prevent ambiguous behaviour.
          game.print("parental conflict detected, unlinking docking belts")
          game.print(dock_storage.dock)
          game.print(docking_part[1])
          dock_storage.children = {positive = {},negative = {}}
        return end

        if i == 1 then--add our children to the storage table
          table.insert(dock_storage.children["positive"],docking_part[1])
        else
          table.insert(dock_storage.children["negative"],docking_part[1])
        end
      end
    end
  end

  local function seperate_children(dock_storage) --disconnect all the linked belts
    if dock_storage.children then
      for _,connector in pairs(dock_storage.children.positive) do
        if connector.valid then connector.disconnect_linked_belts() end
      end
      for _,connector in pairs(dock_storage.children.negative) do
        if connector.valid then connector.disconnect_linked_belts() end
      end
    end
    dock_storage.children = {positive = {},negative = {}}
  end

  local function make_children(dock)--this should update what linked belts are connected to the docking port
    local direction = dock.direction
    local position = dock.position
    local surface = dock.surface
    local dock_storage = storage.docking_ports[dock.unit_number]
    if not dock_storage then return end
    seperate_children(dock_storage)
    
    if direction == 4 or direction == 12 then --we need to know what axis to check.
      iterate_children("y",position,surface,dock_storage)
    else
      iterate_children("x",position,surface,dock_storage)
    end
    --TFMG.block(storage.docking_ports[dock.unit_number])
  end

  local function find_parent(axis,position,surface)--find a docking port by iterating through adjacent dock entities.
    for i = 1,2 do
      for shift = 1,(max_dock_size*2) do --double the max dock size, since we could be starting from the outer edge of a dock
        local search_coordinate = search_shift(axis,position,i,shift)
        local docking_part = surface.find_entities_filtered{position = search_coordinate, name = dock_parts_filter, limit = 1}

        if not docking_part[1] then break end --if the next shift doesnt have a connector on it, we break the loop.
        if docking_part[1].name == "TFMG-docking-port" then --conflict check, if we find another docking port while iterating, we disconnect all our docks to prevent ambiguous behaviour.
        return docking_part[1] end
      end
    end
  end

  local function make_parent(connector)
    local direction = connector.direction
    local position = connector.position
    local surface = connector.surface
    local dock
    if direction == 4 or direction == 12 then --we need to know what axis to check.
      dock = find_parent("y",position,surface)
    else
      dock = find_parent("x",position,surface)
    end
    if not dock then return end
    make_children(dock)
  end

--create destroy events

  local function on_docking_port_created(event)
    local dock = event.entity
    local _reg_number, unit_number, _type = script.register_on_object_destroyed(dock)
    storage.docking_ports[unit_number] = {dock = dock, linked = false}
    dock.rotatable = false --for now, imma prevent rotating a placed dock, just cause theres no real sense in it being possible.
    make_children(dock)
  end

  local function on_docking_port_destroyed(unit_number)
    storage.docking_ports[unit_number] = nil
  end

  local function on_docking_belt_created(event)
    local connector = event.entity
    connector.rotatable = false
    make_parent(connector)
    snap_dock_belt_direction(connector)
  end


--dock location management

  local function register_dock_to_location(docking_port,space_location)
    local location_name = space_location.name
    --TFMG.block(location_name)
    local direction = direction_str[docking_port.direction]
    local port_id = docking_port.unit_number
    --TFMG.block(storage.docks[direction][location_name])
    storage.docks[direction][location_name][port_id] = docking_port
    --store what space location the dock is in the docking_port storage, so we can find where to look when we want to unregister it

    storage.docking_ports[port_id].location = location_name
    TFMG.block(storage.docking_ports[port_id])
  end

  local function unregister_dock_from_last_location(docking_port,last_visited_space_location,space_location_name)
    local location_name
    if last_visited_space_location then 
      location_name = last_visited_space_location.name
    else
      location_name = space_location_name
    end
    if not location_name then return end
    local direction = direction_str[docking_port.direction]
    TFMG.block(direction)
    local port_id = docking_port.unit_number
    storage.docks[direction][location_name][port_id] = nil
    --use our stored location to


    storage.docking_ports[port_id].location = nil
  end

-- link management

  local function marriage(alice,bob)--link a pair of entities ()
    if alice.linked_belt_type == bob.linked_belt_type then return end --we cant connect if theyre the same type
    alice.connect_linked_belts(bob)
  end

  local function divorce(dock_storage)
    if dock_storage.children then
      for _,connector in pairs(dock_storage.children.positive) do
        if connector.valid then connector.disconnect_linked_belts() end
      end
      for _,connector in pairs(dock_storage.children.negative) do
        if connector.valid then connector.disconnect_linked_belts() end
      end
    end


    --deal with our registers

    local partner_storage = storage.docking_ports[dock_storage.linked]

    if dock_storage.space_location then
      register_dock_to_location(dock_storage.dock,dock_storage.space_location)
    end

    if partner_storage then
      if partner_storage.space_location then
        register_dock_to_location(partner_storage.dock,partner_storage.space_location)
      end
      partner_storage.linked = false
    end
    dock_storage.linked = false

    

  end

  local function establish_link(id_1,id_2) --establish a link between two docking ports by id.
    local port_1 = storage.docking_ports[id_1]
    if not port_1 then return end
    local port_2 = storage.docking_ports[id_2]
    if not port_2 then return end

    for shift,alice in pairs(port_1.children.positive) do --link positive side
      if not alice.valid then return end
      local bob = port_2.children.positive[shift]
      if not bob then break end
      if not bob.valid then return end
      marriage(alice,bob)
    end

    for shift,alice in pairs(port_1.children.negative) do --link negative side
      if not alice.valid then return end
      local bob = port_2.children.negative[shift]
      if not bob then break end
      if not bob.valid then return end
      marriage(alice,bob)
    end
    --save who we're linked to
    port_1.linked = id_2
    port_2.linked = id_1

    --now we remove our docks from the docking candidates
    unregister_dock_from_last_location(port_1.dock,nil,port_1.location)
    unregister_dock_from_last_location(port_2.dock,nil,port_2.location)
  end

  local function find_connectable(dock,direction,location)
    local candidates = storage.docks[opposite[direction]][location]

    for _,candidate in pairs(candidates) do --we iterate through the docking candidates, check conditions. first one that meets conditions, we can link, then break the loop. easy as.
      if candidate.surface ~= dock.surface then
        establish_link(dock.unit_number,candidate.unit_number)
        TFMG.block(candidate)
      break end
    end
  end



  local function update_platform_docks(event)
    local platform = event.platform
    local surface = platform.surface
    local space_location = platform.space_location
    local last_visited_space_location = platform.last_visited_space_location

    local platform_docks = surface.find_entities_filtered{name = "TFMG-docking-port"}

    if space_location then
      for _,docking_port in pairs(platform_docks) do
        register_dock_to_location(docking_port,space_location)
      end
    elseif last_visited_space_location then
      for _,docking_port in pairs(platform_docks) do
        unregister_dock_from_last_location(docking_port,last_visited_space_location)
        local docking_storage = storage.docking_ports[docking_port.unit_number]
        divorce(docking_storage)
      end
    end
  end



--callable functions
  function docking.handle_build_event(event)
    if event.entity.name == "TFMG-docking-port" then
      on_docking_port_created(event)
    elseif event.entity.name == "TFMG-docking-belt" then
      on_docking_belt_created(event)
    else
      find_dock_belt(event.entity)
    end
    --TFMG.block(event)
  end

  function docking.handle_rotate_event(event)
    find_dock_belt(event.entity)
  end

  function docking.handle_destroy_event(event)
    local unit_number = event.useful_id
    local dock_data = storage.docking_ports[unit_number]
    if dock_data then on_docking_port_destroyed(unit_number) return end --only if we have an appropriate entry we should run this script. just in case
  end

  function docking.space_platform_changed_state(event)
    update_platform_docks(event)
  end
  
  function docking.on_tick(event)--we're gonna take the normal approch of checking a finite number of docking ports per tick
    for name,location in pairs(storage.docks.north) do
      storage.dock_k.north[name] = flib_table.for_n_of(
      location, storage.dock_k.north[name], 1,
      function(v)
        find_connectable(v,"north",name)
      end
    )
    end
    for name,location in pairs(storage.docks.east) do
      storage.dock_k.east[name] = flib_table.for_n_of(
      location, storage.dock_k.east[name], 1,
      function(v)
        find_connectable(v,"east",name)
      end
    )
    end
  end

return docking