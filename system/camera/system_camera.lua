local decore = require("decore.decore")

local command_camera = require("system.camera.command_camera")

local TEMP_VECTOR = vmath.vector3()
local HASH_SIZE_X = hash("size.x")
local HASH_SIZE_Y = hash("size.y")
local HASH_SPRITE = hash("sprite")

---@class entity
---@field camera component.camera|nil

---@class entity.camera: entity
---@field camera component.camera
---@field transform component.transform

---Add this component to camera entity, it will manage the camera visible size and position
---@class component.camera
---@field camera_url url
---@field follow_entity entity.transform|nil
---@field position_x number|nil
---@field position_y number|nil
---@field size_x number|nil
---@field size_y number|nil
---@field offset_x number|nil
---@field offset_y number|nil
---@field offset_size number|nil
---@field zoom number|nil
decore.register_component("camera", {
	camera_url = "",
})

---@class system.camera.event
---@field entity entity.camera

---@class system.camera: system
---@field entities (entity.camera)[]
---@field camera entity.camera|nil @Current camera entity
---@field camera_borders vector4|nil @Borders of camera visible area vmath.vector4(left, right, top, bottom). Camera will not move outside of these borders
---@field shake_power number|nil
---@field shake_time number|nil
---@field shake_max_time number|nil
---@field zoom number
local M = {}

M.DEFAULT_SIZE = math.min(sys.get_config_int("display.width"), sys.get_config_int("display.height"))

---@return system.camera
function M.create_system()
	local system = decore.system(M, "camera", "camera")

	system.interval = 0.03
	system.camera = nil
	system.camera_borders = nil
	system.zoom = 1
	system.shake_power = 0
	system.shake_time = 0
	system.shake_max_time = 0

	return system
end


function M:onAddToWorld()
	self.world.command_camera = command_camera.create(self)
end


function M:postWrap()
	self.world.event_bus:process("window_event", self.process_window_event, self)
	self.world.event_bus:process("transform_event", self.process_transform_event, self)
end


---@param window_event system.window_event.event
function M:process_window_event(window_event)
	if not self.camera then
		return
	end

	if window_event == window.WINDOW_EVENT_RESIZED then
		self:update_camera_position(self.camera)
		self:update_camera_zoom(self.camera)
	end
end


---@param event system.transform.event
function M:process_transform_event(event)
	if event.entity ~= self.camera then
		return
	end

	if event.is_position_changed then
		self:update_camera_position(self.camera, event.animate_time, event.easing)
	end

	if event.is_scale_changed or event.is_size_changed then
		self:update_camera_zoom(self.camera, event.animate_time, event.easing)
	end
end


---@param entity entity.camera
function M:onAdd(entity)
	msg.post("@render:", "use_camera_projection")
	self.camera = entity
	self.is_camera_changed = true

	local camera_url = msg.url(entity.game_object.root)
	camera_url.fragment = hash("camera")
	entity.camera.camera_url = camera_url

	--camera.acquire_focus(entity.camera.camera_url)

	self:update_camera_position(self.camera)
	self:update_camera_zoom(self.camera)
end


---@param entity entity.camera
function M:onRemove(entity)
	if self.camera == entity then
		--camera.release_focus(entity.camera.camera_url)
		self.camera = nil
	end
end


function M:update(dt)
	if self.is_camera_changed then
		self.world.event_bus:trigger("camera_event", self.camera)
		self.is_camera_changed = false
	end

	if self.shake_time > 0 then
		self.shake_max_time = math.max(self.shake_max_time, self.shake_time)

		self.shake_time = self.shake_time - dt
		if self.shake_time <= 0 then
			self.shake_max_time = 0
			self.shake_power = 0
			self:shake(0)
		else
			local power = self.shake_power * (self.shake_time / self.shake_max_time)
			self:shake(power)
		end
	end
end


---Move camera to the specified position
---@param position_x number
---@param position_y number
---@param animate_time number|nil
---@param easing userdata|nil
function M:move_to(position_x, position_y, animate_time, easing)
	local entity = self.camera
	if entity then
		self.world.command_transform:set_position(entity, position_x, position_y)
		if animate_time then
			self.world.command_transform:set_animate_time(entity, animate_time, easing)
		end
	end
end


---Move camera to the specified size
---@param size_x number
---@param size_y number
---@param animate_time number|nil
---@param easing userdata|nil
function M:size_to(size_x, size_y, animate_time, easing)
	local entity = self.camera
	if entity then
		self.world.command_transform:set_size(entity, size_x, size_y)
		if animate_time then
			self.world.command_transform:set_animate_time(entity, animate_time, easing)
		end
	end
end


---Move camera to the entity position
---@param entity entity.camera
---@param animate_time number|nil
---@param easing userdata|nil
function M:update_camera_position(entity, animate_time, easing)
	TEMP_VECTOR.x = entity.transform.position_x
	TEMP_VECTOR.y = entity.transform.position_y
	TEMP_VECTOR.z = entity.transform.position_z

	-- Apply borders
	local borders = self.camera_borders
	if borders then
		local size_x = entity.transform.size_x / 2
		local size_y = entity.transform.size_y / 2
		if TEMP_VECTOR.x - size_x < borders.x then
			TEMP_VECTOR.x = borders.x + size_x
		end
		if TEMP_VECTOR.x + size_x > borders.y then
			TEMP_VECTOR.x = borders.y - size_x
		end
		if TEMP_VECTOR.y + size_y > borders.z then
			TEMP_VECTOR.y = borders.z - size_y
		end
		if TEMP_VECTOR.y - size_y < borders.w then
			TEMP_VECTOR.y = borders.w + size_y
		end
	end

	if animate_time then
		easing = easing or go.EASING_OUTSINE
		go.animate(entity.game_object.root, "position", go.PLAYBACK_ONCE_FORWARD, TEMP_VECTOR, easing, animate_time)
	else
		go.set_position(TEMP_VECTOR, entity.game_object.root)
	end
end


---Update camera zoom, so that camera fits the entity size
---@param entity entity.camera
---@param animate_time number|nil
---@param easing userdata|nil
function M:update_camera_zoom(entity, animate_time, easing)
	local _, _, width, height = defos.get_view_size()
	local camera_size_x = entity.transform.size_x * entity.transform.scale_x
	local camera_size_y = entity.transform.size_y * entity.transform.scale_y

	local scale_x = width / camera_size_x
	local scale_y = height / camera_size_y
	self.zoom = math.min(scale_x, scale_y)
	--self.zoom = math.max(scale_x, scale_y)
	entity.camera.zoom = self.zoom

	if animate_time then
		easing = easing or go.EASING_OUTSINE
		go.animate(entity.camera.camera_url, "orthographic_zoom", go.PLAYBACK_ONCE_FORWARD, self.zoom, easing, animate_time)
	else
		go.set(entity.camera.camera_url, "orthographic_zoom", self.zoom)
	end
end


---Convert from screen to world coordinates
---@param sx number Screen x
---@param sy number Screen y
---@param sz number Screen z
---@param window_width number Width of the window (use defos.get_view_size())
---@param window_height number Height of the window (use defos.get_view_size())
---@param projection matrix4 Camera/render projection (use go.get("#camera", "projection"))
---@param view vector4 Camera/render view (use go.get("#camera", "view"))
---@return number World x
---@return number World y
---@return number World z
local function screen_to_world(sx, sy, sz, window_width, window_height, projection, view)
	local inv = vmath.inv(projection * view)
	sx = (2 * sx / window_width) - 1
	sy = (2 * sy / window_height) - 1
	sz = (2 * sz) - 1
	local wx = sx * inv.m00 + sy * inv.m01 + sz * inv.m02 + inv.m03
	local wy = sx * inv.m10 + sy * inv.m11 + sz * inv.m12 + inv.m13
	local wz = sx * inv.m20 + sy * inv.m21 + sz * inv.m22 + inv.m23
	return wx, wy, wz
end


---Convert from world to screen coordinates
---@param wx number World x
---@param wy number World y
---@param wz number World z
---@param window_width number Width of the window (use defos.get_view_size())
---@param window_height number Height of the window (use defos.get_view_size())
---@param projection matrix4 Camera/render projection (use go.get("#camera", "projection"))
---@param view vector4 Camera/render view (use go.get("#camera", "view"))
---@return number Screen x
---@return number Screen y
---@return number Screen z
local function world_to_screen(wx, wy, wz, window_width, window_height, projection, view)
	local p = vmath.matrix4() * vmath.vector4(wx, wy, wz, 1)
	p = projection * view * p
	p = p / p.w
	local sx = ((p.x + 1) / 2) * window_width
	local sy = ((p.y + 1) / 2) * window_height
	local sz = ((p.z + 1) / 2)
	return sx, sy, sz
end


---Convert from screen to world coordinates
---@param screen_x number Screen x
---@param screen_y number Screen y
---@return number, number
function M:screen_to_world(screen_x, screen_y)
	if not self.camera then
		return screen_x, screen_y
	end

	local width, height = window.get_size()
	local projection = go.get(self.camera.camera.camera_url, "projection")
	local view = go.get(self.camera.camera.camera_url, "view")

	local x, y, _ = screen_to_world(screen_x, screen_y, 0, width, height, projection, view)
	return x, y
end


---Convert from world to screen coordinates
---@param world_x number World x
---@param world_y number World y
---@return number, number
function M:world_to_screen(world_x, world_y)
	if not self.camera then
		return world_x, world_y
	end

	local width, height = window.get_size()
	local projection = go.get(self.camera.camera.camera_url, "projection")
	local view = go.get(self.camera.camera.camera_url, "view")

	local x, y, _ = world_to_screen(world_x, world_y, 0, width, height, projection, view)
	return x, y
end


function M:shake(power)
	if not self.camera then
		return
	end

	local obj_url = self.camera.game_object.root

	local power_sqr = power * power
	local dx = math.random(-power_sqr, power_sqr)
	local dy = math.random(-power_sqr, power_sqr)
	local x = self.camera.transform.position_x + dx
	local y = self.camera.transform.position_y + dy
	TEMP_VECTOR.x = x
	TEMP_VECTOR.y = y
	TEMP_VECTOR.z = self.camera.transform.position_z
	--go.set_position(TEMP_VECTOR, obj_url)

	go.animate(obj_url, "position", go.PLAYBACK_ONCE_FORWARD,TEMP_VECTOR, go.EASING_OUTSINE, 0.03)
end


return M
