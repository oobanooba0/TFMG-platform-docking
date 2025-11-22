
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

local connector_buildability_rules = {
  {
    area = {{-0.4, -0.4}, {0.4, 0.4}},
    required_tiles = {layers = {ground_tile = true}},
    colliding_tiles = {layers = {empty_space = true}},
    remove_on_collision = true,
  },
  {
    area = {{-1, -50}, {1, -0.6}},
    required_tiles = {layers = {empty_space = true}},
    remove_on_collision = true,
  },
}

local place_visualisation = {
    filename = "__core__/graphics/cursor-boxes-32x32.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    scale = 0.5,
    x = 3*64
  }

--docking port
  local docking_port = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
  docking_port.name = "TFMG-docking-port"
  docking_port.minable = {mining_time = 0.1, result = "TFMG-docking-port"}
  docking_port.tile_buildability_rules = connector_buildability_rules
  docking_port.placeable_position_visualization = place_visualisation
  
  data:extend({
    docking_port,--docking port entity
    {--docking port item
    type = "item",
    name = "TFMG-docking-port",
    icon = "__base__/graphics/icons/wooden-chest.png",
    subgroup = "space-related",
    order = "k-a",
    inventory_move_sound = item_sounds.wood_inventory_move,
    pick_sound = item_sounds.wood_inventory_pickup,
    drop_sound = item_sounds.wood_inventory_move,
    place_result = "TFMG-docking-port",
    stack_size = 50,
    hidden = false,
  },
  {--docking belt item
    type = "item",
    name = "TFMG-docking-belt",
    icon = "__base__/graphics/icons/linked-belt.png",
    hidden = false,
    subgroup = "space-related",
    order = "k-b",
    inventory_move_sound = item_sounds.mechanical_inventory_move,
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    place_result = "TFMG-docking-belt",
    stack_size = 50
  },
  {--docking belt
    type = "linked-belt",
    name = "TFMG-docking-belt",
    icon = "__base__/graphics/icons/linked-belt.png",
    flags = {"placeable-neutral", "player-creation"},
    hidden = true,
    minable = {mining_time = 0.1, result = "TFMG-docking-belt"},
    max_health = 160,
    corpse = "underground-belt-remnants",
    dying_explosion = "underground-belt-explosion",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound = data.raw["underground-belt"]["underground-belt"].working_sound,
    resistances = data.raw["underground-belt"]["underground-belt"].resistances,
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    surface_conditions = {{property = "gravity",min = 0,max = 0}},
    --tile_buildability_rules = connector_buildability_rules, --somethings off with this.
    placeable_position_visualization = place_visualisation,
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
    allow_side_loading = false
  },
  {
    type = "item",
    name = "TFMG-docking-pipe",
    icon = "__base__/graphics/icons/pipe-to-ground.png",
    subgroup = "space-related",
    order = "k-c",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = "TFMG-docking-pipe",
    stack_size = 50,
    random_tint_color = item_tints.iron_rust
  },
  {
    type = "pipe-to-ground",
    name = "TFMG-docking-pipe",
    icon = "__base__/graphics/icons/pipe-to-ground.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "TFMG-docking-pipe"},
    max_health = 150,
    corpse = "pipe-to-ground-remnants",
    dying_explosion = "pipe-to-ground-explosion",
    --factoriopedia_simulation = simulations.factoriopedia_pipe_to_ground,
    icon_draw_specification = {scale = 0.5},
    resistances =
    {
      {
        type = "fire",
        percent = 80
      },
      {
        type = "impact",
        percent = 40
      }

    },
    fast_replaceable_group = "docking-pipes",
    collision_box = {{-0.29, -0.29}, {0.29, 0.2}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    surface_conditions = {{property = "gravity",min = 0,max = 0}},
    damaged_trigger_effect = hit_effects.entity(),
    fluid_box =
    {
      volume = 100,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { 
          connection_type = "normal",
          direction = defines.direction.north, 
          position = {0, 0} 
        },
        {
          connection_type = "linked",
          direction = defines.direction.south,
          position = {0, 0},
          linked_connection_id = 1,
        }
      },
      hide_connection_info = true
    },
    impact_category = "metal",
    working_sound = sounds.pipe,
    open_sound = sounds.metal_small_open,
    close_sound = sounds.metal_small_close,
    pictures =
    {
      north =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        scale = 0.5
      },
      south =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-down.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        scale = 0.5
      },
      west =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-left.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        scale = 0.5
      },
      east =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/pipe-to-ground-right.png",
        priority = "extra-high",
        width = 128,
        height = 128,
        scale = 0.5
      }
    },
    visualization =
    {
      north =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/visualization.png",
        priority = "extra-high",
        x = 64,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      south =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/visualization.png",
        priority = "extra-high",
        x = 192,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      west =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/visualization.png",
        priority = "extra-high",
        x = 256,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      east =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/visualization.png",
        priority = "extra-high",
        x = 128,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
    },
    disabled_visualization =
    {
      north =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/disabled-visualization.png",
        priority = "extra-high",
        x = 64,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      south =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/disabled-visualization.png",
        priority = "extra-high",
        x = 192,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      west =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/disabled-visualization.png",
        priority = "extra-high",
        x = 256,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
      east =
      {
        filename = "__base__/graphics/entity/pipe-to-ground/disabled-visualization.png",
        priority = "extra-high",
        x = 128,
        size = 64,
        scale = 0.5,
        flags = {"icon"}
      },
    },
  },
})