---@class world
---@field command_game_gui command.game_gui

---@class command.game_gui
---@field game_gui system.game_gui
local M = {}


---@param game_gui system.game_gui
---@return command.game_gui
function M.create(game_gui)
	return setmetatable({ game_gui = game_gui }, { __index = M })
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
