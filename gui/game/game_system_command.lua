local ecs = require("decore.ecs")

---@class world
---@field gui_main_command system.gui_main_command

---@class system.gui_main_command: system
---@field gui_main system.gui_main
local M = {}


---@static
---@return system.gui_main_command
function M.create_system(gui_main)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("gui_main_command")
	system.id = "gui_main_command"
	system.gui_main = gui_main

	return system
end


---@private
function M:onAddToWorld()
	self.world.gui_main_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.gui_main_command = nil
end


function M:set_text(text)
	for _, entity in ipairs(self.gui_main.entities) do
		entity.gui_main.bindings.show_text:trigger(text)
	end
end


function M:level_complete()
	for _, entity in ipairs(self.gui_main.entities) do
		entity.gui_main.bindings.level_completed:trigger()
	end
end


return M
