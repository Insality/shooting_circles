local ecs = require("decore.ecs")

---@class entity
---@field TEMPLATE_command component.TEMPLATE_command|nil

---@class entity.TEMPLATE_command: entity
---@field TEMPLATE_command component.TEMPLATE_command

---@class component.TEMPLATE_command

---@class system.TEMPLATE_command: system
---@field entities entity.TEMPLATE_command[]
---@field TEMPLATE system.TEMPLATE
local M = {}


---@static
---@return system.TEMPLATE_command
function M.create_system(TEMPLATE)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("TEMPLATE_command")
	system.TEMPLATE = TEMPLATE
	system.id = "TEMPLATE_command"

	return system
end


---@param entity entity.TEMPLATE_command
function M:onAdd(entity)
	local command = entity.TEMPLATE_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.TEMPLATE_command
function M:process_command(command)
end


return M
