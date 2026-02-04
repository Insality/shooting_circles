local decore = require("decore.decore")
local druid = require("druid.druid")

---@class entity
---@field druid_widget component.druid_widget|nil

---@class entity.druid_widget: entity
---@field druid_widget component.druid_widget|nil

---@class component.druid_widget
---@field widget_id string?
---@field widget_class druid.widget
---@field widget druid.widget?
---@field command_on_add any[]|nil
decore.register_component("druid_widget", {
	widget_class = nil, -- Path to the Druid widget class
	widget_id = "gui_compoment_id",
	widget = nil,
	command_on_add = nil,
})


---@class system.druid_widget: system
---@field entities entity.druid_widget[]
local M = {}


function M.create()
	return decore.system(M, "druid_widget", { "game_object", "druid_widget" })
end


---@param entity entity.druid_widget
function M:onAdd(entity)
	local widget_class = entity.druid_widget.widget_class
	local gui_url = msg.url(nil, entity.game_object.root, entity.druid_widget.widget_id)
	entity.druid_widget.widget = druid.get_widget(widget_class, gui_url, entity)

	local command_on_add = entity.druid_widget.command_on_add
	if entity.druid_widget.widget and command_on_add then
		self:execute(entity, command_on_add[1], unpack(command_on_add, 2))
	end

end


---@param entity entity.druid_widget
---@param function_name string
---@param ... any
function M:execute(entity, function_name, ...)
	local widget_function = entity.druid_widget.widget[function_name]
	if not widget_function then
		return
	end

	widget_function(entity.druid_widget.widget, ...)
end


return M
