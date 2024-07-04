local ecs = require("decore.ecs")

local death_command = require("systems.death.death_command")

---@class entity

---@class system.death: system
local M = {}


---@static
---@return system.death, system.death_command
function M.create_system()
	local system = setmetatable(ecs.system(), { __index = M })
	
	return system, death_command.create_system(system)
end


return M
