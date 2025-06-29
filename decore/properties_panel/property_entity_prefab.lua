local color = require("druid.color")

---@class widget.property_entity_prefab: druid.widget
---@field root node
---@field container druid.container
---@field text_name druid.text
---@field button druid.button
---@field text_button druid.text
local M = {}

function M:init()
	self.root = self:get_node("root")
	self.text_name = self.druid:new_text("text_name")
		:set_text_adjust("scale_then_trim", 0.3)

	self.selected = self:get_node("selected")
	gui.set_alpha(self.selected, 0)

	self.button = self.druid:new_button("button", self.on_click)
	self.text_button = self.druid:new_text("text_button")

	self.drag = self.druid:new_drag("drag")
	self.drag.style.DRAG_DEADZONE = 0
	self.drag.hover.on_mouse_hover:subscribe(self._on_drag_hover, self)
	self.drag.on_drag_start:subscribe(self.animation_on_drag_start, self)
	self.drag.on_drag_end:subscribe(self.animation_on_drag_end, self)

	self.container = self.druid:new_container(self.root)
	self.container:add_container("text_name", nil, function(_, size)
		self.text_button:set_size(size)
	end)
	self.container:add_container("E_Anchor")

	self.on_drag_start = self.drag.on_drag_start
	self.on_drag_end = self.drag.on_drag_end
	self.on_drag_hover = self.drag.hover.on_mouse_hover
end


function M:on_click()
	gui.set_alpha(self.selected, 1)
	gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
end


function M:_on_drag_hover(_, is_hover)
	--if is_hover then
	--	panthera.play(self.animation, "on_hover", {
	--		is_loop = true,
	--	})
	--else
	--	panthera.play(self.animation, "default")
	--end
end


function M:animation_on_drag_start()
	--panthera.play(self.animation_state, "on_drag_start", {
	--	is_skip_init = true,
	--})
end


function M:animation_on_drag_end()
	--panthera.play(self.animation_state, "on_drag_end", {
	--	is_skip_init = true,
	--})
end


---@param text string
---@return widget.property_entity_prefab
function M:set_text_property(text)
	self.text_name:set_text(text)
	return self
end


---@param text string
---@return widget.property_entity_prefab
function M:set_text_button(text)
	self.text_button:set_text(text)
	return self
end


function M:set_color(color_value)
	color.set_color(self:get_node("button"), color_value)
end


return M
