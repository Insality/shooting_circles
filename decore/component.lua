local HASH_SET_COMPONENT = hash("set_component")
local HASH_PROPERTY = hash("components_to_register")

local M = {}

function M.init(component_id, component_data)
	local entity_count = go.get("#entity", HASH_PROPERTY)
	go.set("#entity", HASH_PROPERTY, entity_count + 1)

	msg.post(".", HASH_SET_COMPONENT, {
		id = component_id,
		data = component_data
	})
end

return M