local decore = require("decore.decore")

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
---@return system.on_key_released
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("on_key_released")
	system.id = "on_key_released"

	system.hash_to_string = {}

	return system
end


function M:postWrap()
	self.world.queue:process("input_event", self.process_input_event, self)
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


---@param input_event event.input_event
function M:process_input_event(input_event)
	local entities = self.entities
	for index = 1, #entities do
		local entity = entities[index]
		self:apply_input(entity, input_event.action_id, input_event)
	end
end


---@param entity entity.on_key_released
function M:apply_input(entity, action_id, action)
	local command_data = entity.on_key_released.key_to_command
	local key_id = self.hash_to_string[action_id]
	if command_data[key_id] and action.released then
		decore.call_command(self.world, command_data[key_id])
	end
end


return M
