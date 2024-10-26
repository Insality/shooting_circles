local decore = require("decore.decore")

---@class entity
---@field on_spawn_command component.on_spawn_command|nil

---@class entity.on_spawn_command: entity
---@field on_spawn_command component.on_spawn_command
decore.register_component("on_spawn_command")

---@class component.on_spawn_command
---@field command string @Json of string[], ["game_gui_command", "set_text", "hello"]

---@class system.on_spawn_command: system
---@field entities entity.on_spawn_command[]
local M = {}


---@static
---@return system.on_spawn_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAny("on_spawn_command")
	system.id = "on_spawn_command"

	return system
end


---@param entity entity.on_spawn_command
function M:onAdd(entity)
	local command = entity.on_spawn_command
	if command then
		self:process_command(command)
	end
end


---@param command component.on_spawn_command
function M:process_command(command)
	if command.command then
		local data = json.decode(command.command)
		decore.call_command(self.world, data)
	end
end


return M
