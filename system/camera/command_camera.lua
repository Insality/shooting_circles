---@class world
---@field command_camera command.camera

---@class command.camera
---@field camera system.camera @Current camera system
local M = {}


---@return command.camera
function M.create(camera_system)
	return setmetatable({ camera = camera_system }, { __index = M })
end


---@param power number
---@param time number
function M:shake(power, time)
	self.camera.shake_power = power
	self.camera.shake_time = time
end


function M:world_to_screen(x, y)
	return self.camera:world_to_screen(x, y)
end


function M:screen_to_world(x, y)
	return self.camera:screen_to_world(x, y)
end


return M
