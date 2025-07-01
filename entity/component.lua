-- Used to register a component to an entity
-- Usage
--[[
go.property("delay", 0.5)

local component = require("decore.component")
local fragments = require("fragments")

function init(self)
	component.set(fragments.remove_with_delay, self.delay)
end
--]]

local HASH_SET_FRAGMENT = hash("set_fragment")
local HASH_PROPERTY = hash("fragments_to_register")

local M = {}


---@param fragment_id evolved.id
---@param fragment_data any?
function M.set(fragment_id, fragment_data)
	local entity_count = go.get("#entity", HASH_PROPERTY)
	go.set("#entity", HASH_PROPERTY, entity_count + 1)
	msg.post(".", HASH_SET_FRAGMENT, { id = fragment_id, data = fragment_data })
end


return M
