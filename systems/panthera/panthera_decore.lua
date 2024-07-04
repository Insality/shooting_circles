local ecs = require("decore.ecs")
local panthera = require("panthera.panthera")

local panthera_command = require("systems.panthera.panthera_command")

---@class entity
---@field panthera component.panthera|nil

---@class entity.panthera: entity
---@field panthera component.panthera
---@field game_object component.game_object
---@field transform component.transform

---@class component.panthera
---@field animation_path string
---@field animation_state panthera.animation.state|nil
---@field default_animation string
---@field speed number
---@field is_loop boolean|nil
---@field play_on_start boolean|nil
---@field detached_animations panthera.animation.state[]

---@class system.panthera: system
---@field entities entity.panthera[]
local M = {}

---@static
---@return system.panthera, system.panthera_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("panthera", "game_object", ecs.rejectAll("hidden"))
	system.id = "panthera"

	return system, panthera_command.create_system(system)
end


---@param entity entity.panthera
function M:onAdd(entity)
	local p = entity.panthera
	p.detached_animations = {}

	local get_node = M.get_node_fn(nil, entity.game_object.object)
	local animation_state = panthera.create_go(p.animation_path, get_node)

	if animation_state then
		p.animation_state = animation_state

		-- TODO: This one should be in update
		if p.play_on_start then
			panthera.play(p.animation_state, p.default_animation, {
				is_loop = p.is_loop or false,
				speed = p.speed or 1
			})
		end
	end
end


---@param entity entity.panthera
function M:onRemove(entity)
	local p = entity.panthera
	if panthera.is_playing(p.animation_state) then
		panthera.stop(p.animation_state)
	end

	p.animation_state = nil

	for index = 1, #p.detached_animations do
		local state = p.detached_animations[index]
		if panthera.is_playing(state) then
			panthera.stop(state)
		end
	end
end


---@param template string|nil
---@param nodes table<string|hash, string|hash>|nil
---@return function(node_id: string): hash|url
function M.get_node_fn(template, nodes)
	return function(node_id)
		if template then
			node_id = template .. "/" .. node_id
		end

		local split_index = string.find(node_id, "#")
		if split_index then
			local object_id = string.sub(node_id, 1, split_index - 1)
			local fragment_id = string.sub(node_id, split_index + 1)

			---@type string|hash
			local object_path = hash("/" .. object_id)
			if nodes then
				object_path = nodes[object_path]
			end

			return msg.url(nil, object_path, fragment_id)
		end

		local object_path = hash("/" .. node_id)
		if nodes then
			object_path = nodes[object_path]
		end

		return object_path
	end
end


return M
