---@class world
---@field game_gui command.game_gui

---@class command.game_gui
---@field game_gui system.game_gui
local M = {}


---@param game_gui system.game_gui
---@return command.game_gui
function M.create(game_gui)
	return setmetatable({ game_gui = game_gui }, { __index = M })
end


---@param text string
function M:set_level_text(text)
	for _, entity in ipairs(self.game_gui.entities) do
		local component = entity.druid_widget.widget --[[@as widget.game_gui]]
		component:set_text(text)
	end
end


function M:level_complete()
	for _, entity in ipairs(self.game_gui.entities) do
		local component = entity.druid_widget.widget --[[@as widget.game_gui]]
		component:level_completed()
	end
end


return M
