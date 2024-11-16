---@class decore.event_bus
---@field events table<string, table> The current list of events
---@field stash table<string, table> The list of events to be processed after :stash_to_events() is called
---@field merge_callbacks table<string, fun(events: any[], new_event: any):boolean> The merge policy for events. If the merge policy returns true, the events are merged and not will be added as new event
local M = {}


---Creates a new event bus.
---@return decore.event_bus
function M.create()
	local instance = {
		events = {},
		stash = {},
		merge_callbacks = {},
	}

	return setmetatable(instance, { __index = M })
end


---Pushes an event onto the queue, triggering it and processing the queue of callbacks.
---@param event_name string The name of the event to push onto the queue.
---@param data any The data to pass to the event and its associated callbacks.
function M:trigger(event_name, data)
	self.stash[event_name] = self.stash[event_name] or {}

	local merge_callback = self.merge_callbacks[event_name]
	if merge_callback then
		local is_merged = merge_callback(self.stash[event_name], data)
		if not is_merged then
			table.insert(self.stash[event_name], data or true)
		end
	else
		table.insert(self.stash[event_name], data or true)
	end
end


---Processes a specified event, executing the callback function with the provided context.
---@param event_name string The name of the event to process.
---@param callback fun(...) The callback function to execute.
---@param context any|nil The context in which to execute the callback.
function M:process(event_name, callback, context)
	local event_data = self.events[event_name]
	if not event_data then
		return
	end

	if context then
		for i = 1, #event_data do
			callback(context, event_data[i])
		end
	else
		for i = 1, #event_data do
			callback(event_data[i])
		end
	end
end


---You can set the merge policy for an event. This is useful when you want to merge events of the same type.
---@param event_name string The name of the event to set the merge policy for.
---@param merge_callback (fun(events, new_event):boolean)|nil The callback function to merge the events. Return true if the events were merged, false otherwise.
function M:set_merge_policy(event_name, merge_callback)
	self.merge_callbacks[event_name] = merge_callback
end


function M:clear_events()
	self.events = {}
end


function M:stash_to_events()
	self.events = self.stash
	self.stash = {}
end


function M:get_events(event_name)
	return self.events[event_name]
end


function M:get_stash(event_name)
	return self.stash[event_name]
end


local global_queue = M.create()
return global_queue
