---@class world
---@field camera system.camera.command

---@class system.camera.command
---@field camera system.camera @Current camera system
local M = {}


---@param camera_system system.camera
---@return system.camera.command
function M.create(camera_system)
	return setmetatable({ camera = camera_system }, { __index = M })
end


---@param entity entity
---@param time number?
function M:move_to_entity(entity, time)
	time = time or 0.3
	self.camera:move_to(entity.transform.position_x, entity.transform.position_y, time, go.EASING_OUTSINE)
end


function M:get_zoom()
	return self.camera:get_zoom()
end


---@param position_x number
---@param position_y number
---@param time number
---@param easing userdata|nil
function M:set_offset_position(position_x, position_y, time, easing)
	easing = easing or go.EASING_OUTSINE
	self.camera:set_offset_position(self.camera.camera, position_x, position_y, time, easing)
end


---@param zoom number
---@param time number
---@param easing userdata|nil
function M:set_offset_zoom(zoom, time, easing)
	easing = easing or go.EASING_OUTSINE
	self.camera:set_offset_zoom(self.camera.camera, zoom, time, easing)
end


---@param zoom number
---@param time number
---@param easing userdata|nil
function M:zoom_to(zoom, time, easing)
	local camera = self.camera.camera
	if not camera then
		return
	end
	easing = easing or go.EASING_OUTSINE
	self.camera:scale_to(zoom, zoom, time, easing)
end


---@param power number
---@param time number
function M:shake(power, time)
	self.camera.shake_power = power or 8
	self.camera.shake_time = time or 0.4
end


---@param x number
---@param y number
---@return number, number
function M:world_to_screen(x, y)
	return self.camera:world_to_screen(x, y)
end


---@param x number
---@param y number
---@return number, number
function M:screen_to_world(x, y)
	return self.camera:screen_to_world(x, y)
end


---@return entity.camera
function M:get_current_camera()
	return self.camera.camera
end


return M
