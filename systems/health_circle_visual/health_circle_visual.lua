local ecs = require("decore.ecs")

local health_circle_visual_command = require("systems.health_circle_visual.health_circle_visual_command")

---@class entity
---@field health_circle_visual component.health_circle_visual|nil

---@class entity.health_circle_visual: entity
---@field health_circle_visual component.health_circle_visual

---@class component.health_circle_visual

---@class system.health_circle_visual: system
---@field entities entity.health_circle_visual[]
local M = {}


---@static
---@return system.health_circle_visual, system.health_circle_visual_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("health_circle_visual")

	return system, health_circle_visual_command.create_system(system)
end


return M
