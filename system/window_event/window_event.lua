local events = require("event.events")
local decore = require("decore.decore")

---window.WINDOW_EVENT_FOCUS_GAINED | window.WINDOW_EVENT_FOCUS_LOST | window.WINDOW_EVENT_RESIZED
---@class event.window_event

---@class system.window_event: system
local M = {}


---@return system.window_event
function M.create_system()
	return decore.system(M, "window_event")
end


function M:onAddToWorld()
	window.set_listener(function(_, window_event)
		events.trigger("decore.window_event", window_event)
	end)

	events.subscribe("decore.window_event", self.on_window_event, self)
end


function M:onRemoveFromWorld()
	events.unsubscribe("decore.window_event", self.on_window_event, self)
end


function M:on_window_event(event)
	self.world.event_bus:trigger("window_event", event)
end


return M
