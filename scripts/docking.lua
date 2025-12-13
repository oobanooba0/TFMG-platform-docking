local flib_table = require("__flib__/table")
local math2d = require("__core__/lualib/math2d")

local dock_parts_filter = {"TFMG-docking-port","TFMG-docking-belt","TFMG-docking-pipe"}
local dock_belts_filter = {"TFMG-docking-belt"}
local dock_pipes_filter = {"TFMG-docking-pipe"}
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

local direction_string = {
  [defines.direction.north] = "north",
  [defines.direction.east] = "east",
  [defines.direction.south] = "south",
  [defines.direction.west] = "west",
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
    link.refresh_dock_data(dock.unit_number) --finally lets refesh the docks data
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

  local function create_collider(event) --creates a collider entity
    local entity = event.entity
    local surface = entity.surface
    local unit_number = entity.unit_number
    local direction = entity.direction
    if entity.name == "TFMG-docking-belt" then --if docking belt we should check if we must flip it.
      belt_type = entity.linked_belt_type
      if belt_type then
        game.print(belt_type)
        if belt_type == "output" then
            direction = opposite[direction]
            game.print("flip")
        end
      end
    end
    script.register_on_object_destroyed(entity)
    local collider = surface.create_entity{
      name = "TFMG-dock-collider",
      position = entity.position,
      direction = direction,
    }
    storage.colliders[unit_number] = collider
  end

  local function on_docking_port_created(event)
    local dock = event.entity
    local _reg_number, unit_number, _type = script.register_on_object_destroyed(dock)
    storage.docking_ports[unit_number] = {
      dock = dock, --docking port luaentity
      linked = nil, --id of linked docking port
      space_location = nil, --name of location dock is orbiting, or was last at.
      children = {--table of all the children owned by this dock
        positive = {},
        negative = {},
      },
      direction = direction_string[dock.direction],
      docking_signal = nil,
      zero_dock = true,
    }
    dock.rotatable = false --for now, imma prevent rotating a placed dock, just cause theres no real sense in it being possible.
    make_children(dock)
    create_collider(event)
  end

  local function on_docking_port_destroyed(unit_number)
    link.clear_dock_data(unit_number)
  end

  local function on_docking_belt_created(event)
    local connector = event.entity
    connector.rotatable = false
    make_parent(connector)
    snap_dock_belt_direction(connector)
    create_collider(event)
  end

  local function on_docking_pipe_created(event)
    local connector = event.entity
    connector.rotatable = false
    make_parent(connector)
    create_collider(event)
  end



--callable functions
  function docking.handle_build_event(event)
    if event.entity.name == "TFMG-docking-port" then
      on_docking_port_created(event)
    elseif event.entity.name == "TFMG-docking-belt" then
      on_docking_belt_created(event)
    elseif event.entity.name == "TFMG-docking-pipe" then
      on_docking_pipe_created(event)
    else
      find_dock_belt(event.entity)
    end

  end

  function docking.handle_rotate_event(event)
    find_dock_belt(event.entity)
  end

  function docking.handle_destroy_event(event)
    local unit_number = event.useful_id
    local dock_data = storage.docking_ports[unit_number]
    if dock_data then on_docking_port_destroyed(unit_number) end --only if we have an appropriate entry we should run this script. just in case

    local collider = storage.colliders[unit_number]
    if collider then
      collider.destroy()
      storage.colliders[unit_number] = nil
    end
  end

return docking