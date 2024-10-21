local ecs = require("decore.ecs")

---@class entity
---@field TEMPLATE component.TEMPLATE|nil

---@class entity.TEMPLATE: entity
---@field TEMPLATE component.TEMPLATE

---@class component.TEMPLATE

---@class system.TEMPLATE: system
---@field entities entity.TEMPLATE[]
local M = {}


---@static
---@return system.TEMPLATE
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAll("TEMPLATE")
	system.id = "TEMPLATE"

	return system
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
