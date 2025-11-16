
local item_sounds = require("__base__.prototypes.item_sounds")
local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
--belt animation set

local basic_belt_animation_set =
{
  animation_set =
  {
    filename = "__base__/graphics/entity/transport-belt/transport-belt.png",
    priority = "extra-high",
    size = 128,
    scale = 0.5,
    frame_count = 16,
    direction_count = 20
  },
}
--docking port
  local docking_port = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  docking_port.name = "docking-port"
  docking_port.minable = {mining_time = 0.1, result = "docking-port"},
data:extend({
    docking_port,--docking port entity
    {--docking port item
    type = "item",
    name = "docking-port",
    icon = "__base__/graphics/icons/wooden-chest.png",
    subgroup = "space-related",
    order = "k-a",
    inventory_move_sound = item_sounds.wood_inventory_move,
    pick_sound = item_sounds.wood_inventory_pickup,
    drop_sound = item_sounds.wood_inventory_move,
    place_result = "docking-port",
    stack_size = 50,
    hidden = false,
  },
  {--docking belt item
    type = "item",
    name = "docking-belt",
    icon = "__base__/graphics/icons/linked-belt.png",
    hidden = false,
    subgroup = "space-related",
    order = "k-b",
    inventory_move_sound = item_sounds.mechanical_inventory_move,
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    place_result = "docking-belt",
    stack_size = 50
  },
  {--docking belt
    type = "linked-belt",
    name = "docking-belt",
    icon = "__base__/graphics/icons/linked-belt.png",
    flags = {"placeable-neutral", "player-creation"},
    hidden = true,
    minable = {mining_time = 0.1, result = "docking-belt"},
    max_health = 160,
    corpse = "underground-belt-remnants",
    dying_explosion = "underground-belt-explosion",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound = data.raw["underground-belt"]["underground-belt"].working_sound,
    resistances = data.raw["underground-belt"]["underground-belt"].resistances,
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    damaged_trigger_effect = hit_effects.entity(),
    animation_speed_coefficient = 32,
    belt_animation_set = basic_belt_animation_set,
    fast_replaceable_group = "docking-belts",
    speed = 0.03125,
    structure_render_layer = "object",
    structure =
    {
      direction_in =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/linked-belt/linked-belt-structure.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          y = 192,
          scale = 0.5
        }
      },
      direction_out =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/linked-belt/linked-belt-structure.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          scale = 0.5
        }
      },
      direction_in_side_loading =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/linked-belt/linked-belt-structure.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          y = 192*3,
          scale = 0.5
        }
      },
      direction_out_side_loading =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/linked-belt/linked-belt-structure.png",
          priority = "extra-high",
          width = 192,
          height = 192,
          y = 192*2,
          scale = 0.5
        }
      },
      back_patch = data.raw["underground-belt"]["underground-belt"].structure.back_patch,
      front_patch = data.raw["underground-belt"]["underground-belt"].structure.front_patch,
    },
    -- clone/blueprint connection work only if both input and output have them and they are contained in the same blueprint/clone
    allow_clone_connection = true,
    allow_blueprint_connection = true,
    allow_side_loading = false
  },
})
