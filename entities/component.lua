-- Used to register a component to an entity
-- Usage
--[[
go.property("delay", 0.5)

local component = require("decore.component")

function init(self)
	component.set("remove_with_delay", self.delay)
end
--]]

local HASH_SET_COMPONENT = hash("set_component")
local HASH_PROPERTY = hash("components_to_register")

local M = {}


---@param component_id evolved.id
---@param component_data any?
function M.set(component_id, component_data)
	local entity_count = go.get("#entity", HASH_PROPERTY)
	go.set("#entity", HASH_PROPERTY, entity_count + 1)
	msg.post(".", HASH_SET_COMPONENT, { id = component_id, data = component_data })
end


return M
