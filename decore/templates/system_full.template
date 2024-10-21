local ecs = require("decore.ecs")

local system_command = require("systems.TEMPLATE.TEMPLATE_command")
local system_event = require("systems.TEMPLATE.TEMPLATE_event")

---@class entity
---@field TEMPLATE component.TEMPLATE|nil

---@class entity.TEMPLATE: entity
---@field TEMPLATE component.TEMPLATE

---@class component.TEMPLATE

---@class system.TEMPLATE: system
---@field entities entity.TEMPLATE[]
local M = {}


---@static
---@return system.TEMPLATE, system.TEMPLATE_command, system.TEMPLATE_event
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("TEMPLATE")
	system.id = "TEMPLATE"

	return system, system_command.create_system(system), system_event.create_system()
end


---@param entity entity.TEMPLATE
function M:onAdd(entity)
end


---@param entity entity.TEMPLATE
function M:onRemove(entity)
end


---@param dt number
function M:update(dt)
end


return M
