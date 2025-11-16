local docking = {}

--local functions

local function on_docking_port_created(entity)

end

local function on_docking_port_destroyed(entity)

end

--callable functions

function docking.handle_build_event(event)
  TFMG.block(event)
end

function docking.handle_destroy_event(event)

end

return docking