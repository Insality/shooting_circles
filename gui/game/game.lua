local panthera = require("panthera.panthera")

local animation = require("gui.game.game_panthera")
local animation_button = require("gui.ui_button.ui_button_panthera")

---@class gui.game: druid.widget
---@field druid druid.instance
---@field root node
---@field text_timer druid.text
---@field text_current_level druid.text
local M = {}


function M:init()
	self.current_timer = 0
	self.is_running = false

	self.text_timer = self.druid:new_text("text_timer")
	self.text_current_level = self.druid:new_text("text_current_level")

	self.button_left = self.druid:new_button("button_left/root")
		:set_key_trigger("key_left")
		:set_style(nil)

	self.button_right = self.druid:new_button("button_right/root")
		:set_key_trigger("key_right")
		:set_style(nil)

	self.button_left_animation = panthera.create_gui(animation_button, "button_left", self:get_nodes())
	self.button_left.on_click:subscribe(function()
		panthera.play(self.button_left_animation, "click")
	end)

	self.button_right_animation = panthera.create_gui(animation_button, "button_right", self:get_nodes())
	self.button_right.on_click:subscribe(function()
		panthera.play(self.button_right_animation, "click")
	end)

	self.animation = panthera.create_gui(animation)
end


function M:set_text(text)
	self.is_running = true
	self.current_timer = 0
	self.text_current_level:set_text(text)

	panthera.play(self.animation, "level_start", {
		is_skip_init = true
	})
end


function M:level_completed()
	self.is_running = false

	panthera.play(self.animation, "level_completed")
end


function M:update(dt)
	if self.is_running then
		self.current_timer = self.current_timer + dt
		self.text_timer:set_text(string.format("%.1f", self.current_timer))
	end
end


return M
