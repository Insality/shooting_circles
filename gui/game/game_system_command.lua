local ecs = require("decore.ecs")

---@class world
---@field game_gui_command system.game_gui_command

---@class system.game_gui_command: system_command
---@field game_gui system.game_gui
local M = {}


---@static
---@return system.game_gui_command
function M.create_system(game_gui)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("game_gui_command")
	system.id = "game_gui_command"
	system.game_gui = game_gui

	return system
end


---@private
function M:onAddToWorld()
	self.world.game_gui_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.game_gui_command = nil
end


function M:set_text(text)
	for _, entity in ipairs(self.game_gui.entities) do
		local component = entity.game_gui.component
		component:set_text(text)
	end
end


function M:level_complete()
	for _, entity in ipairs(self.game_gui.entities) do
		local component = entity.game_gui.component
		component:level_completed()
	end
end


return M
