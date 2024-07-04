local ecs = require("decore.ecs")
local decore = require("decore.decore")

---@class entity
---@field camera_command component.camera_command|nil

---@class entity.camera_command: entity
---@field camera_command component.camera_command

---@class component.camera_command
---@field borders vector4|nil @Borders of camera visible area vmath.vector4(left, right, top, bottom)
---@field follow_to_name string|nil @Name of entity to follow
---@field position_x number|nil @Position x in pixels
---@field position_y number|nil @Position y in pixels
---@field size_x number|nil @Size x in pixels
---@field size_y number|nil @Size y in pixels
---@field animate_time number|nil @If true will animate the transform over time
---@field offset_x number|nil @Offset x in pixels for camera
---@field offset_y number|nil @Offset y in pixels for camera
---@field offset_size number|nil @Offset zoom for camera
---@field temporary boolean|nil @If true the next camera command will reset the camera to the previous state
---@field shake component.camera_command.shake|nil @Shake camera

---@class component.camera_command.shake
---@field power number @Power of shake
---@field time number @Time of shake

---@class system.camera_command: system
---@field entities entity.camera_command[]
---@field camera system.camera|nil @Current camera system
---@field previous_camera_state table<string, any>|nil @Previous camera state
local M = {}

---@static
---@return system.camera_command
function M.create_system(camera_system)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("camera_command", "window_event", "transform_event")
	system.id = "camera_command"

	system.camera = camera_system
	system.previous_camera_state = nil

	return system
end


---@param entity entity.camera_command
function M:onAdd(entity)
	if not self.camera or not self.camera.camera then
		return
	end

	local window_event = entity.window_event
	if window_event then
		if window_event.is_resized then
			self.camera:update_camera_position(self.camera.camera)
			self.camera:update_camera_zoom(self.camera.camera)
		end
	end

	local transform_event = entity.transform_event
	if transform_event then
		if transform_event.is_position_changed then
			self.camera:update_camera_position(self.camera.camera, transform_event.animate_time, transform_event.easing)
		end
		if transform_event.is_size_changed then
			self.camera:update_camera_zoom(self.camera.camera, transform_event.animate_time, transform_event.easing)
		end
	end

	local command = entity.camera_command
	if self.camera and command then
		self:process_command(command)
		self.world:removeEntity(entity)
	end
end


---@param command component.camera_command
function M:process_command(command)
	local camera = self.camera.camera --[[@as entity.camera]]
	if not camera then
		return
	end

	if command.shake then
		--self.camera:shake(command.shake.power, command.shake.time)
		self.camera.shake_power = math.max(self.camera.shake_power, command.shake.power)
		self.camera.shake_time = math.max(self.camera.shake_time, command.shake.time)
	end

	---Set camera borders, can be false
	if command.borders ~= nil then
		self.borders = command.borders
	end

	if command.temporary then
		self.previous_camera_state = {
			position_x = camera.transform.position_x,
			position_y = camera.transform.position_y,
			size_x = camera.transform.size_x,
			size_y = camera.transform.size_y,
			animate_time = command.animate_time
		}
	end

	local state = self.previous_camera_state
	if not command.temporary and state then
		--self:move_to(state.position_x, state.position_y, state.size_x, state.size_y, state.animate_time)
		self.previous_camera_state = nil
	end

	if command.follow_to_name and command.follow_to_name ~= "" then
		local follow_entity = decore.get_entities_with_name(self.world, command.follow_to_name)[1] --[[@as entity.transform]]
		if follow_entity then
			self:move_to_entity(self.camera.camera, follow_entity)
		end
	end
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

	---@type component.transform_command
	local transform_command = {
		entity = entity,
		position_x = position_x,
		position_y = position_y,
		size_x = size_x,
		size_y = size_y,
		animate_time = animate_time,
		easing = go.EASING_OUTSINE
	}
	print("transform_command", transform_command)
	self.world:addEntity({ transform_command = transform_command })
end



return M
