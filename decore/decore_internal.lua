local TYPE_STRING = "string"

local M = {}

---Logger interface
---@class decore.logger
---@field trace fun(logger: decore.logger, message: string, data: any|nil)
---@field debug fun(logger: decore.logger, message: string, data: any|nil)
---@field info fun(logger: decore.logger, message: string, data: any|nil)
---@field warn fun(logger: decore.logger, message: string, data: any|nil)
---@field error fun(logger: decore.logger, message: string, data: any|nil)

--- Use empty function to save a bit of memory
local EMPTY_FUNCTION = function(_, message, context) end

---@type decore.logger
M.empty_logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}

---@type decore.logger
M.logger = {
	trace = function(_, msg) print("TRACE: " .. msg) end,
	debug = function(_, msg, data) pprint("DEBUG: " .. msg, data) end,
	info = function(_, msg, data) pprint("INFO: " .. msg, data) end,
	warn = function(_, msg, data) pprint("WARN: " .. msg, data) end,
	error = function(_, msg, data) pprint("ERROR: " .. msg, data) end
}


---Split string by separator
---@param s string
---@param sep string
function M.split(s, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


---Create a copy of lua table
---@param orig table The table to copy
---@return table
function M.deepcopy(orig)
	local copy = orig

	if type(orig) == "table" then
		-- It's faster than copying or JSON serialization
		copy = sys.deserialize(sys.serialize(orig))
	end

	return copy
end


--- Merge one table into another recursively
---@param t1 table
---@param t2 any
function M.merge_tables(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			M.merge_tables(t1[k], v)
		else
			t1[k] = v
		end
	end
end


---Load JSON file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param json_path string
---@return table|nil
function M.load_json(json_path)
	local resource, is_error = sys.load_resource(json_path)
	if is_error or not resource then
		return nil
	end

	return json.decode(resource)
end


---@param config_or_path table|string
---@return table|nil
function M.load_config(config_or_path)
	if type(config_or_path) == TYPE_STRING then
		local entities_path = config_or_path --[[@as string]]
		local entities_data = M.load_json(entities_path)
		if not entities_data then
			M.logger:error("Can't load config at path", config_or_path)
			return nil
		end

		return entities_data
	end

	return config_or_path --[[@as table]]
end


---Remove the value from the array table by value
---@param t table
---@param v any
---@return boolean @true if value was removed
function M.remove_by_value(t, v)
	for index = 1, #t do
		if t[index] == v then
			table.remove(t, index)
			return true
		end
	end

	return false
end


return M
