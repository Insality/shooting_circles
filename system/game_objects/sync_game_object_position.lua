local evolved = require("evolved")
local components = require("components")

local M = {}

local go_setter = go_position_setter.new()

function M.register_components()
	---@class components
	---@field root_url evolved.id
	---@field no_sync_game_object evolved.id

	components.no_sync_game_object = evolved.builder():name("no_sync_game_object"):tag():spawn()

	components.root_url = evolved.builder():name("root_url"):require(components.position, components.quat):on_set(function(entity, fragment, component)
		if evolved.has(entity, components.physics) or evolved.has(entity, components.no_sync_game_object) then
			return
		end

		local position = evolved.get(entity, components.position)
		local quat = evolved.get(entity, components.quat)
		go_setter:add(component, position, quat)
	end):on_remove(function(entity, fragment, component)
		if evolved.has(entity, components.physics) then
			return
		end

		-- Since this go_setter is faster than other options, will use the position as vector3 field only
		go_setter:remove(component)
		go.delete(component)
	end):spawn()
end


function M.create_system()
	return evolved.builder()
		:name("sync_position")
		:set(components.system)
		:prologue(M.sync_position)
		:spawn()
end


function M.sync_position()
	go_setter:update()
end


return M
