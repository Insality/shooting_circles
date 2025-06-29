local evolved = require("evolved")
local components = require("components")

---@class components
---@field root_url evolved.id

local M = {}

local go_setter = go_position_setter.new()

function M.register_components()
	components.root_url = evolved.builder():name("root_url"):require(components.position, components.quat):on_set(function(entity, fragment, component)
		local position = evolved.get(entity, components.position)
		local quat = evolved.get(entity, components.quat)
		go_setter:add(component, position, quat)
	end):on_remove(function(entity, fragment, component)
		-- Since this go_setter is faster than other options, will use the position as vector3 field only
		go_setter:remove(component)
		go.delete(component)
	end):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("sync_position")
		:set(components.system)
		:include(components.single_update)
		:execute(M.sync_position)
		:spawn()
end


function M.sync_position()
	go_setter:update()
end


return M
