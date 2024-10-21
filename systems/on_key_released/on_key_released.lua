local ecs = require("decore.ecs")

local on_key_released_command = require("systems.on_key_released.on_key_released_command")

---@class entity
---@field on_key_released component.on_key_released|nil

---@class entity.on_key_released: entity
---@field on_key_released component.on_key_released

---@class component.on_key_released
---@field key_to_command_json string @JSON string table<key_id, table<component_id: component_data>>. Will override key_to_command if exists
---@field key_to_command table<string, table<string, table>> @ table<key_id, table<component_id: component_data>>.

---@class system.on_key_released: system
---@field entities entity.on_key_released[]
---@field hash_to_string table<hash, string>
local M = {}


---@static
---@return system.on_key_released, system.on_key_released_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("on_key_released")
	system.id = "on_key_released"

	system.hash_to_string = {}

	return system, on_key_released_command.create_system(system)
end


---@param entity entity.on_key_released
function M:onAdd(entity)
	local on_key_released = entity.on_key_released

	if on_key_released.key_to_command_json then
		local data = json.decode(on_key_released.key_to_command_json)
		on_key_released.key_to_command = data
	end

	if on_key_released.key_to_command then
		for key_id, key_data in pairs(on_key_released.key_to_command) do
			local hash_id = hash(key_id)
			if not self.hash_to_string[hash_id] then
				self.hash_to_string[hash_id] = key_id
			end
		end
	end
end


---@param entity entity.on_key_released
function M:apply_input(entity, action_id, action)
	local command_data = entity.on_key_released.key_to_command
	local key_id = self.hash_to_string[action_id]
	if command_data[key_id] and action.released then
		local command_data = command_data[key_id]
		local command = command_data[1]
		local func = command_data[2]
		local args = {}
		for i = 3, #command_data do
			table.insert(args, command_data[i])
		end

		if not self.world[command] then
			print("Command not found: " .. command)
			return
		end
		if not self.world[command][func] then
			print("Function not found: " .. func)
			return
		end

		self.world[command][func](self.world[command], command, unpack(args))
	end
end


return M
