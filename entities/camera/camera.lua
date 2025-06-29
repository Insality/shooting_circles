local evolved = require("evolved")
local components = require("components")

return evolved.builder()
	:name("camera")
	:prefab()
	:set(components.transform)
	:set(components.camera)
	:spawn()
