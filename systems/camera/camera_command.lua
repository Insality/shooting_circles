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


---@param power number
---@param time number
function M:shake(power, time)
	self.camera.shake_power = power
	self.camera.shake_time = time
end


function M:world_to_screen(x, y)
	return self.camera.world_to_screen(x, y)
end


function M:screen_to_world(x, y)
	return self.camera.screen_to_world(x, y)
end


return M
