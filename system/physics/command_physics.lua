---@class world
---@field command_physics command.physics

---@class command.physics
---@field physics system.physics
local M = {}


---@param physics system.physics
---@return command.physics
function M.create(physics)
	return setmetatable({ physics = physics }, { __index = M })
end


---@param entity entity
---@param force_x number|nil
---@param force_y number|nil
function M:add_force(entity, force_x, force_y)
	assert(entity.physics, "entity must have physics component")
	---@cast entity entity.physics

	self.physics:add_force(entity, force_x, force_y)
end


return M
