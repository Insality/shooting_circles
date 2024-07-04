local ecs = require("decore.ecs")

local game_object_command = require("systems.game_object.game_object_command")

---@class entity
---@field hidden boolean|nil
---@field game_object component.game_object|nil

---@class entity.game_object: entity
---@field game_object component.game_object
---@field transform component.transform
---@field hidden boolean|nil

---@class component.game_object
---@field factory_url string
---@field root string|hash|url
---@field object table<string|hash, string|hash>
---@field is_slice9 boolean|nil
---@field remove_delay number|nil

---@class system.game_object: system
local M = {}

local TEMP_VECTOR = vmath.vector3()
local ROOT_URL = hash("/root")


---@static
---@return system.game_object, system.game_object_command
function M.create_system()
	---@type system.game_object
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("game_object", "transform", ecs.rejectAll("hidden"))
	system.id = "game_object"

	return system, game_object_command.create_system(system)
end


---@param entity entity.game_object
function M:onAdd(entity)
	local object = self:create_object(entity)
	local root = object[ROOT_URL]

	entity.game_object.root = root
	entity.game_object.object = object

	if entity.game_object.is_slice9 then
		TEMP_VECTOR.x = entity.transform.size_x
		TEMP_VECTOR.y = entity.transform.size_y
		TEMP_VECTOR.z = 0
		local sprite_url = msg.url(nil, root, "sprite")
		go.set(sprite_url, "size", TEMP_VECTOR)

		-- Set scale to initial 1
		TEMP_VECTOR.x = 1
		TEMP_VECTOR.y = 1
		TEMP_VECTOR.z = 1
		go.set(root, "scale", TEMP_VECTOR)
	else
		TEMP_VECTOR.x = entity.transform.scale_x
		TEMP_VECTOR.y = entity.transform.scale_y
		TEMP_VECTOR.z = entity.transform.scale_x -- X to keep uniform for physics
		go.set(root, "scale", TEMP_VECTOR)
	end

	go.set(root, "euler.z", entity.transform.rotation)
end


---@param entity entity.game_object
function M:onRemove(entity)
	local remove_delay = entity.game_object.remove_delay

	if not remove_delay then
		for _, object in pairs(entity.game_object.object) do
			go.delete(object)
		end
	else
		timer.delay(remove_delay, false, function()
			for _, object in pairs(entity.game_object.object) do
				go.delete(object)
			end
		end)
	end
end


---@param entity entity.game_object
---@return table<string|hash, string|hash>
function M:create_object(entity)
	TEMP_VECTOR.x = entity.transform.position_x
	TEMP_VECTOR.y = entity.transform.position_y
	TEMP_VECTOR.z = self:get_position_z(entity.transform)

	return collectionfactory.create(entity.game_object.factory_url, TEMP_VECTOR, nil, nil, entity.transform.scale_x)
end


---@param t component.transform
---@return number
function M:get_position_z(t)
	return -t.position_y / 10000 + t.position_x / 100000 + t.position_z / 10
end


return M
