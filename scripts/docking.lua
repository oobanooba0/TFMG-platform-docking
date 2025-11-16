local docking = {}

--local functions

local function on_docking_port_created(entity)

end

local function on_docking_port_destroyed(entity)

end

local function on_docking_belt_created(entity)

end
--callable functions

function docking.handle_build_event(event)
  TFMG.block(event)
  if event.entity.name == "docking-port" then
    on_docking_port_created()
  elseif event.entity.name == "docking-belt" then
    on_docking_belt_created()
  end
end

function docking.handle_destroy_event(event)

end

return docking