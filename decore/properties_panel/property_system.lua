local evolved = require("evolved")
local color = require("druid.color")
local helper = require("druid.helper")

---@class widget.property_system: druid.widget
---@field root node
---@field text_name druid.text
local M = {}

local HASH_SIZE_X = hash("size.x")
local COLOR_HUGE = color.hex2vector4("#D59E9E")
local COLOR_LOW = color.hex2vector4("#8ED59E")

local COLOR_TEXT_LIGHT = color.hex2vector4("#212428")
local COLOR_TEXT_DARK = color.hex2vector4("#76797D")

function M:init()
	self.root = self:get_node("root")

	self.text_name = self.druid:new_text("text_name")
		:set_text_adjust("scale_then_trim", 0.3)

	self.text_memory_update = self.druid:new_text("text_memory_update")
	self.text_memory_update_fps = self.druid:new_text("text_memory_update_fps")

	self.node_update = self:get_node("node_update")
	self.node_update_fps = self:get_node("node_update_fps")

	self.system_last_time = 0
	self.update_limit = 1024
	self.update_time_limit = 3

	self.button_inspect = self.druid:new_button("button_inspect")

	self.container = self.druid:new_container(self.root)
	self.container:add_container("text_name")
	self.container:add_container("E_Anchor")
end


function M:on_remove()
	if self.system_old_prologue then
		evolved.set(self.system, evolved.PROLOGUE, self.system_old_prologue)
	end
	if self.system_old_epilogue then
		evolved.set(self.system, evolved.EPILOGUE, self.system_old_epilogue)
	end
end


function M:set_text(text)
	self.text_name:set_text(text)
	return self
end


function M:set_text_function(text_function)
	self.text_function = text_function
	local text = text_function()
	if text then
		self.text_name:set_text(text)
	end
	return self
end


---@param system evolved.id
function M:set_system(system)
	self.system = system
	self.system_old_prologue = evolved.get(system, evolved.PROLOGUE)
	self.system_old_epilogue = evolved.get(system, evolved.EPILOGUE)

	self.system_memory_samples_update = {}
	self.system_memory_samples_update_fps = {}

	self.system_last_time = 0
	self.memory_update_per_second = 0

	local memory = nil
	local time = nil

	evolved.set(system, evolved.PROLOGUE, function(...)
		if self.system_old_prologue then
			self.system_old_prologue(...)
		end

		memory = collectgarbage("count")
		time = socket.gettime()
	end)

	evolved.set(system, evolved.EPILOGUE, function(...)
		local memory_after = collectgarbage("count")
		local diff = memory_after - memory
		if diff > 0 then
			table.insert(self.system_memory_samples_update, diff)
		end

		local diff_time = socket.gettime() - time
		table.insert(self.system_memory_samples_update_fps, diff_time)

		if self.system_old_epilogue then
			self.system_old_epilogue(...)
		end
	end)

	self:update(0)
end


function M:update(dt)
	if not self.system then
		return
	end

	if self.text_function then
		local text = self.text_function()
		if text then
			self.text_name:set_text(text)
		end
	end

	self.system_last_time = self.system_last_time - dt
	if self.system_last_time <= 0 then
		self.system_last_time = 1

		local update_memory = 0
		for _, v in ipairs(self.system_memory_samples_update) do
			update_memory = update_memory + v
		end
		-- Update UI
		local text_update = math.ceil(update_memory) .. " KB/s"
		if update_memory > 1024 then
			text_update = string.format("%.2f", update_memory / 1024) .. " MB/s"
		end

		self.text_memory_update:set_text(text_update)

		local update_perc = helper.clamp(update_memory / self.update_limit, 0, 1)

		gui.set(self.node_update, HASH_SIZE_X, update_perc * 80)
		gui.set_color(self.node_update, color.lerp(update_perc, COLOR_LOW, COLOR_HUGE))
		gui.set_color(self.text_memory_update.node, color.lerp(update_perc, COLOR_TEXT_DARK, COLOR_TEXT_LIGHT))

		self.system_memory_samples_update = {}

		do -- Frame time update
			-- Total time for all executions
			local update_time = 0
			for _, v in ipairs(self.system_memory_samples_update_fps) do
				update_time = update_time + v
			end
			update_time = update_time / math.max(#self.system_memory_samples_update_fps, 1)
			update_time = update_time * 1000

			self.text_memory_update_fps:set_text( string.format("%.1f", update_time) .. " ms")

			local update_time_perc = helper.clamp(update_time / self.update_time_limit, 0, 1)

			gui.set(self.node_update_fps, HASH_SIZE_X, update_time_perc * 80)
			gui.set_color(self.node_update_fps, color.lerp(update_time_perc, COLOR_LOW, COLOR_HUGE))
			gui.set_color(self.text_memory_update_fps.node, color.lerp(update_time_perc, COLOR_TEXT_DARK, COLOR_TEXT_LIGHT))

			self.system_memory_samples_update_fps = {}
		end
	end
end


return M
