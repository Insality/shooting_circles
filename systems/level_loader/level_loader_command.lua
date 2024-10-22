local ecs = require("decore.ecs")

---@class world
---@field level_loader_command system.level_loader_command

---@class system.level_loader_command: system
---@field level_loader system.level_loader
local M = {}


---@static
---@return system.level_loader_command
function M.create_system(level_loader)
	local system = setmetatable(ecs.system(), { __index = M })
	system.level_loader = level_loader
	system.id = "level_loader_command"

	return system
end


function M:onAddToWorld()
	self.world.level_loader_command = self
end


function M:onRemoveFromWorld()
	self.world.level_loader_command = nil
end


---@param world_id string
---@param pack_id string|nil
---@param offset_x number|nil
---@param offset_y number|nil
---@param slot_id string|nil
function M:load_world(world_id, pack_id, offset_x, offset_y, slot_id)
	self.level_loader:load_world(world_id, pack_id, offset_x, offset_y, slot_id)
end


return M
