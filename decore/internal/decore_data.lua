local M = {}

---@type table<string, table<string, entity>> @Key: pack_id, Value: <prefab_id, entity>
M.entities = {}
M.entities_order = {}

---@type table<string, table<string, any>> @Key: pack_id, Value: <component_id, component>
M.components = {
	["decore"] = {
		id = "",
		prefab_id = false,
		pack_id = false,
		parent_prefab_id = false,
	}
}
M.components_order = { "decore" }

---@type table<string, table<string, decore.world.instance>> @Key: pack_id, Value: <world_id, world>
M.worlds = {}
M.worlds_order = {}

return M
