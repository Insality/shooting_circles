-- Global module for pass GUI binding events from GUI to the game logic

local M = {}

M.CROSS_CONTEXT_DATA = {}


---@param data any
---@return any @data
function M.set(data)
	local object = msg.url()
	object.fragment = nil

	M.CROSS_CONTEXT_DATA[object.socket] = M.CROSS_CONTEXT_DATA[object.socket] or {}
	M.CROSS_CONTEXT_DATA[object.socket][object.path] = data

	return data
end


---@param object_url string|userdata|url @root object
---@return table<string, event>|nil
function M.get(object_url)
	object_url = msg.url(object_url --[[@as string]])

	local socket_events = M.CROSS_CONTEXT_DATA[object_url.socket]
	if not socket_events then
		return nil
	end

	return socket_events[object_url.path]
end


return M
