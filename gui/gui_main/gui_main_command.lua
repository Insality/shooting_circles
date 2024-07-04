local ecs = require("decore.ecs")

---@class entity
---@field gui_main_command component.gui_main_command|nil

---@class entity.gui_main_command: entity
---@field gui_main_command component.gui_main_command

---@class component.gui_main_command
---@field text string|nil
---@field level_complete boolean|nil

---@class system.gui_main_command: system
---@field entities entity.gui_main_command[]
---@field gui_main system.gui_main
local M = {}


---@static
---@return system.gui_main_command
function M.create_system(gui_main)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("gui_main_command")
	system.gui_main = gui_main

	return system
end


---@param entity entity.gui_main_command
function M:onAdd(entity)
	local command = entity.gui_main_command
	if command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.gui_main_command
function M:process_command(command)
	if command.text then
		for _, entity in ipairs(self.gui_main.entities) do
			entity.gui_main.bindings.show_text:trigger(command.text)
		end
	end

	if command.level_complete then
		for _, entity in ipairs(self.gui_main.entities) do
			entity.gui_main.bindings.level_completed:trigger()
		end
	end
end


return M
