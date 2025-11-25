local docking_belt = data.raw["linked-belt"]["TFMG-docking-belt"]

local fastest_belt_speed = 0.03125 --15 items per second
local fastest_belt_animation_set = {--yellow belt set
    filename = "__base__/graphics/entity/transport-belt/transport-belt.png",
    priority = "extra-high",
    size = 128,
    scale = 0.5,
    frame_count = 16,
    direction_count = 20
  }
local fastest_belt_animation_speed_coefficient = 32 --yellow belt speed coof

for _,belt in pairs(data.raw["transport-belt"]) do--easy iterate through every belt in the game, find the highest speed value, use that
  if belt.speed > fastest_belt_speed and not belt.hidden then
    fastest_belt_speed = belt.speed
    fastest_belt_animation_set = belt.belt_animation_set
    fastest_belt_animation_speed_coefficient = belt.animation_speed_coefficient
  end
end

docking_belt.speed = fastest_belt_speed
docking_belt.belt_animation_set = fastest_belt_animation_set
docking_belt.animation_speed_coefficient = fastest_belt_animation_speed_coefficient

