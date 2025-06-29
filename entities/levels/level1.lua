local evolved = require("evolved")
local components = require("components")

return evolved.builder()
	:prefab()
	:name("level1")
	:set(components.collectionfactory_url, "/levels#level1")
	:spawn()
