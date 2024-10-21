local ecs = require("decore.ecs")

---@class world
---@field camera_command system.camera_command

---@class system.camera_command: system
---@field camera system.camera|nil @Current camera system
---@field previous_camera_state table<string, any>|nil @Previous camera state
local M = {}

---@static
---@return system.camera_command
function M.create_system(camera_system)
	local system = setmetatable(ecs.system(), { __index = M })
	system.id = "camera_command"
	system.camera = camera_system

	return system
end


---@private
function M:onAddToWorld()
	self.world.camera_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.camera_command = nil
end


function M:postWrap()
	self.world.queue:process("window_event", self.process_window_event, self)
	self.world.queue:process("transform_event", self.process_transform_event, self)
end


---@param window_event event.window_event
function M:process_window_event(window_event)
	if window_event.is_resized then
		self.camera:update_camera_position(self.camera.camera)
		self.camera:update_camera_zoom(self.camera.camera)
	end
end


---@param transform_event event.transform_event
function M:process_transform_event(transform_event)
	if transform_event.is_position_changed then
		self.camera:update_camera_position(self.camera.camera, transform_event.animate_time, transform_event.easing)
	end
	if transform_event.is_size_changed then
		self.camera:update_camera_zoom(self.camera.camera, transform_event.animate_time, transform_event.easing)
	end
end


---@param power number
---@param time number
function M:shake(power, time)
	self.camera.shake_power = power
	self.camera.shake_time = time
end


function M:set_borders(borders)
	self.borders = borders
end


function M:reset_borders()
	self.borders = nil
end


---@param entity_camera entity.camera
---@param entity_follow entity.transform
function M:move_to_entity(entity_camera, entity_follow)
	local t = entity_camera.transform

	entity_camera.camera.position_x = t.position_x
	entity_camera.camera.position_y = t.position_y

	self:move_to(t.position_x, t.position_y, nil, nil, 0)
end


---@param position_x number|nil
---@param position_y number|nil
---@param size_x number|nil
---@param size_y number|nil
---@param animate_time number|nil
function M:move_to(position_x, position_y, size_x, size_y, animate_time)
	local entity = self.camera.camera
	if not entity then
		return
	end

	if position_x ~= nil then
		position_x = position_x + (entity.camera.offset_x or 0)
	end
	if position_y ~= nil then
		position_y = position_y + (entity.camera.offset_y or 0)
	end
	if size_x ~= nil then
		size_x = size_x + (entity.camera.offset_size or 0)
	end
	if size_y ~= nil then
		size_y = size_y + (entity.camera.offset_size or 0)
	end

	self.world.transform_command:set_position(entity, position_x, position_y, nil)
	self.world.transform_command:set_size(entity, size_x, size_y, nil)
	self.world.transform_command:set_animate_time(entity, animate_time, go.EASING_OUTSINE)
end


return M
