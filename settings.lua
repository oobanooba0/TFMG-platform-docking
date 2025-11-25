data:extend({
  {
    type = "int-setting",
    name = "TFMG-dock-preview-size-x",
    setting_type = "runtime-per-user",
    minimum_value = 1,--Rip bozo if they set it to 1.
    maximum_vale = 5000,
    default_value = 512,
  },
  {
    type = "int-setting",
    name = "TFMG-dock-preview-size-y",
    setting_type = "runtime-per-user",
    minimum_value = 1,--Rip bozo if they set it to 1.
    maximum_vale = 5000,
    default_value = 512,
  },
  {
    type = "double-setting",
    name = "TFMG-dock-preview-zoom",
    setting_type = "runtime-per-user",
    minimum_value = 0.01,
    maximum_value = 10,
    default_value = 1,
  },
})