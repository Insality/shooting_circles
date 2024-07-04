local ecs = require("decore.ecs")

---@class entity
---@field on_spawn_command component.on_spawn_command|nil

---@class entity.on_spawn_command: entity
---@field on_spawn_command component.on_spawn_command

---@class component.on_spawn_command
---@field command string

---@class system.on_spawn_command: system
---@field entities entity.on_spawn_command[]
local M = {}


---@static
---@return system.on_spawn_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("on_spawn_command")

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
		self.world:addEntity(data)
	end
end


return M
