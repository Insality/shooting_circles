local evolved = require("evolved")
local fragments = require("fragments")

return evolved.builder()
	:prefab()
	:name("level1")
	:set(fragments.collectionfactory_url, "/levels#level1")
	:spawn()
