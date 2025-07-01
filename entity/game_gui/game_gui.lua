local shooter_hud = require("widget.shooter_hud.shooter_hud")

---@class widget.game_gui: druid.widget
local M = {}


function M:init()
	self.shooter_hud = self.druid:new_widget(shooter_hud, "shooter_hud")
	self.shooter_hud:set_shoot_count(10)
	self.shooter_hud:set_patrons(6)
end


function M:play_hit()
	self.shooter_hud:play_hit()
end


function M:set_shoot_count(count)
	self.shooter_hud:set_shoot_count(count)
end


return M
