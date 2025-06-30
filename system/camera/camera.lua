local events = require("event.events")
local evolved = require("evolved")
local fragments = require("fragments")

local M = {}


function M.register_fragments()
	---@class fragments
	---@field camera evolved.id
	---@field camera_dirty evolved.id

	fragments.camera_dirty = evolved.builder():name("camera_dirty"):tag():spawn()
	fragments.camera = evolved.builder():name("camera"):require(fragments.camera_dirty):tag():spawn()
end


function M.create_system()
	M.get_camera_query = evolved.builder()
		:include(fragments.camera, fragments.root_url)
		:spawn()

	local group = evolved.builder()
		:name("camera")
		:include(fragments.camera)
		:set(fragments.system)
		:spawn()

	evolved.builder()
		:name("camera.dirty_by_pos")
		:group(group)
		:include(fragments.camera, fragments.position_dirty)
		:execute(M.set_dirty)
		:spawn()

	evolved.builder()
		:name("camera.dirty_by_size")
		:group(group)
		:include(fragments.camera, fragments.size_dirty)
		:execute(M.set_dirty)
		:spawn()

	evolved.builder()
		:name("camera.refresh")
		:group(group)
		:include(fragments.camera_dirty)
		:execute(M.refresh_camera)
		:spawn()

	do -- Resize subscription
		local query = evolved.builder()
			:include(fragments.camera, fragments.size_x, fragments.size_y)
			:spawn()

		events.subscribe("window_event", function(window_event)
			if window_event ~= window.WINDOW_EVENT_RESIZED then
				return
			end

			for chunk, entity_list, entity_count in evolved.execute(query) do
				M.refresh_camera(chunk, entity_list, entity_count)
			end
		end)
	end

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.set_dirty(chunk, entity_list, entity_count)
	for index = 1, entity_count do
		evolved.set(entity_list[index], fragments.camera_dirty, true)
	end
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.refresh_camera(chunk, entity_list, entity_count)
	local root_url, position, size_x, size_y = chunk:components(fragments.root_url, fragments.position, fragments.size_x, fragments.size_y)
	local scale_x, scale_y = chunk:components(fragments.scale_x, fragments.scale_y)
	for index = 1, entity_count do
		M.update_camera_position(root_url[index], position[index])
		M.update_camera_zoom(root_url[index], size_x[index], size_y[index], scale_x[index], scale_y[index])
	end
end


---Move camera to the entity position
---@param root_url hash
---@param position vector3
---@param animate_time number|nil
---@param easing userdata|nil
function M.update_camera_position(root_url, position, animate_time, easing)
	if animate_time then
		easing = easing or go.EASING_OUTSINE
		go.animate(root_url, "position", go.PLAYBACK_ONCE_FORWARD, position, easing, animate_time)
	else
		go.set_position(position, root_url)
	end
end


---Update camera zoom, so that camera fits the entity size
---@param root_url hash
---@param size_x number
---@param size_y number
---@param scale_x number
---@param scale_y number
---@param animate_time number|nil
---@param easing userdata|nil
function M.update_camera_zoom(root_url, size_x, size_y, scale_x, scale_y, animate_time, easing)
	local camera_url = msg.url(nil, root_url, "camera")
	local _, _, width, height = defos.get_view_size()
	local camera_size_x = size_x * scale_x
	local camera_size_y = size_y * scale_y

	local camera_scale_x = width / camera_size_x
	local camera_scale_y = height / camera_size_y
	local zoom = math.min(camera_scale_x, camera_scale_y)

	if animate_time then
		easing = easing or go.EASING_OUTSINE
		go.animate(camera_url, "orthographic_zoom", go.PLAYBACK_ONCE_FORWARD, zoom, easing, animate_time)
	else
		go.set(camera_url, "orthographic_zoom", zoom)
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


local function get_camera_url()
	for chunk, entity_list, entity_count in evolved.execute(M.get_camera_query) do
		local root_url = chunk:components(fragments.root_url)
		for index = 1, entity_count do
			local url = msg.url(root_url[index])
			url.fragment = hash("camera")
			return url
		end
	end
end


---Convert from screen to world coordinates
---@param screen_x number Screen x
---@param screen_y number Screen y
---@return number, number
function M.screen_to_world(screen_x, screen_y)
	local width, height = window.get_size()
	local camera_url = get_camera_url()
	local projection = go.get(camera_url, "projection")
	local view = go.get(camera_url, "view")

	local x, y, _ = screen_to_world(screen_x, screen_y, 0, width, height, projection, view)
	return x, y
end


---Convert from world to screen coordinates
---@param world_x number World x
---@param world_y number World y
---@return number, number
function M.world_to_screen(world_x, world_y)
	local width, height = window.get_size()
	local camera_url = get_camera_url()
	local projection = go.get(camera_url, "projection")
	local view = go.get(camera_url, "view")

	local x, y, _ = world_to_screen(world_x, world_y, 0, width, height, projection, view)
	return x, y
end



return M
