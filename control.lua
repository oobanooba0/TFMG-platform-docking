util = require("util") --util functions are useful
require("scripts.TFMG") --a few of my utility/debug functions.
TFMG = require("scripts.TFMG")
require("scripts.docking") --handles the assembly of docking port multiblocks.
docking = require("scripts.docking") 
require("scripts.link") --handles linking docking ports.
link = require("scripts.link")
require("scripts.ui") --handles the gui
ui = require("scripts.ui")

require("scripts.on-events")--registers all init events and build/rotate/destroy events.

