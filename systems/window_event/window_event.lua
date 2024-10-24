local events = require("event.events")
local decore = require("decore.decore")


---@class event.window_event
---@field is_focus_gained boolean
---@field is_focus_lost boolean
---@field is_resized boolean

---@class system.window_event: system
local M = {}


---@static
---@return system.window_event
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.id = "window_event"

	return system
end


function M:onAddToWorld()
	events.subscribe("window_event", self.on_window_event, self)
end


function M:onRemoveFromWorld()
	events.unsubscribe("window_event", self.on_window_event, self)
end


function M:on_window_event(event)
	---@type event.window_event
	local window_event = {
		is_focus_gained = event == window.WINDOW_EVENT_FOCUS_GAINED,
		is_focus_lost = event == window.WINDOW_EVENT_FOCUS_LOST,
		is_resized = event == window.WINDOW_EVENT_RESIZED,
	}
	self.world.queue:push("window_event", window_event)
end


function M:postWrap()
	for index = #self.entities, 1, -1 do
		self.world:removeEntity(self.entities[index])
	end
end


return M
