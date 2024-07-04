local ecs = require("decore.ecs")

local transform_command = require("systems.transform.transform_command")
local transform_event = require("systems.transform.transform_event")

---@class entity
---@field transform component.transform|nil

---@class entity.transform: entity
---@field transform component.transform

---@class entity.transform_command: entity
---@field transform component.transform

---@class component.transform
---@field position_x number
---@field position_y number
---@field position_z number
---@field size_x number
---@field size_y number
---@field size_z number
---@field scale_x number
---@field scale_y number
---@field scale_z number
---@field rotation number

---@class system.transform: system
---@field entities entity.transform[]
local M = {}

---@static
---@return system.transform, system.transform_command, system.transform_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("transform")
	system.id = "transform"

	return system, transform_command.create_system(system), transform_event.create_system()
end


---@static
---Return node borders relative to the current node parent
---@param entity entity
---@return number, number, number, number @left, right, top, bottom
function M.get_transform_borders(entity)
	local t = entity.transform --[[@as component.transform]]

	local left = t.position_x - t.size_x * 0.5
	local right = t.position_x + t.size_x * 0.5
	local top = t.position_y + t.size_y * 0.5
	local bottom = t.position_y - t.size_y * 0.5

	return left, right, top, bottom
end


---@static
---Check if two entities are overlapping
---@param entity1 entity
---@param entity2 entity
---@return boolean
function M.is_overlap(entity1, entity2)
	local left1, right1, top1, bottom1 = M.get_transform_borders(entity1)
	local left2, right2, top2, bottom2 = M.get_transform_borders(entity2)

	return left1 < right2 and right1 > left2 and top1 > bottom2 and bottom1 < top2
end


return M
