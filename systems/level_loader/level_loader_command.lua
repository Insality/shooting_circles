local ecs = require("decore.ecs")

---@class entity
---@field level_loader_command component.level_loader_command|nil

---@class entity.level_loader_command: entity
---@field level_loader_command component.level_loader_command

---@class component.level_loader_command
---@field world_id string
---@field pack_id string|nil
---@field slot_id string|nil @If exists, will keep only one world with this slot_id, previous worlds will be removed
---@field offset_x number|nil
---@field offset_y number|nil

---@class system.level_loader_command: system
---@field entities entity.level_loader_command[]
---@field level_loader system.level_loader
local M = {}


---@static
---@return system.level_loader_command
function M.create_system(level_loader)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("level_loader_command")
	system.level_loader = level_loader
	system.id = "level_loader_command"

	return system
end


---@param entity entity.level_loader_command
function M:onAdd(entity)
	local command = entity.level_loader_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.level_loader_command
function M:process_command(command)
	self.level_loader:load_world(command.world_id, command.pack_id, command.offset_x, command.offset_y, command.slot_id)
end


return M
