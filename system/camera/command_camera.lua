---@class world
---@field command_camera system.camera.command

---@class system.camera.command
---@field camera system.camera @Current camera system
local M = {}


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


---@param power number
---@param time number
function M:shake(power, time)
	self.camera.shake_power = power or 8
	self.camera.shake_time = time or 0.4
end


function M:world_to_screen(x, y)
	return self.camera:world_to_screen(x, y)
end


function M:screen_to_world(x, y)
	return self.camera:screen_to_world(x, y)
end


---@return entity.camera
function M:get_current_camera()
	return self.camera.camera
end


return M
