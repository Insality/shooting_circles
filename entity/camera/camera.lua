local evolved = require("evolved")
local fragments = require("fragments")

return evolved.builder()
	:name("camera")
	:prefab()
	:set(fragments.transform)
	:set(fragments.camera)
	:spawn()
