local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

local go_setter = go_position_setter.new()

function M.register_fragments()
	---@class fragments
	---@field root_url evolved.id
	---@field no_sync_game_object evolved.id

	fragments.no_sync_game_object = evolved.builder():name("no_sync_game_object"):tag():spawn()

	fragments.root_url = evolved.builder()
		:name("root_url")
		:require(fragments.position, fragments.quat)
		:on_set(function(entity, fragment, component)
			if evolved.has(entity, fragments.physics) or evolved.has(entity, fragments.no_sync_game_object) then
				return
			end

			local position = evolved.get(entity, fragments.position)
			local quat = evolved.get(entity, fragments.quat)
			go_setter:add(component, position, quat)

			end)
		:on_remove(function(entity, fragment, component)
			if evolved.has(entity, fragments.physics) then
				return
			end

			-- Since this go_setter is faster than other options, will use the position as vector3 field only
			go_setter:remove(component)
			go.delete(component)
		end)
		:spawn()
end


function M.create_system()
	return evolved.builder()
		:name("sync_position")
		:set(fragments.system)
		:prologue(M.sync_position)
		:spawn()
end


function M.sync_position()
	go_setter:update()
end


return M
