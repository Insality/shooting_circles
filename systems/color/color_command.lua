local ecs = require("decore.ecs")

---@class entity
---@field color_command component.color_command|nil

---@class entity.color_command: entity
---@field color_command component.color_command

---@class component.color_command
---@field entity entity
---@field color vector4

---@class system.color_command: system
---@field entities entity.color_command[]
---@field color system.color
local M = {}


---@static
---@param color system.color
---@return system.color_command
function M.create_system(color)
	local system = ecs.system()
	system.filter = ecs.requireAny("color_command")
	system.color = color
	system.id = "color_command"

	return setmetatable(system, { __index = M })
end


---@param entity entity.color_command
function M:onAdd(entity)
	local command = entity.color_command
	if command then
		self:process_command(command)
	end

	self.world:removeEntity(entity)
end


---@param command component.color_command
function M:process_command(command)
	local entity = command.entity
	local color = command.color
	if entity and color then
		entity.color.color = color
		entity.color_command = nil

		---@type component.color_event
		local color_event = {
			entity = entity,
			color = color,
		}
		self.world:addEntity({ color_event = color_event })
	end
end


return M
