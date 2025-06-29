local evolved = require("evolved")
local components = require("components")

local M = {}


function M.register_components()
	---@class components
	---@field camera evolved.id
	---@field camera_dirty evolved.id

	components.camera_dirty = evolved.builder():name("camera_dirty"):tag():spawn()
	components.camera = evolved.builder():name("camera"):require(components.camera_dirty):tag():spawn()
end


function M.create_system()
	local group = evolved.builder()
		:name("camera")
		:set(components.system)
		:spawn()

	evolved.builder()
		:name("camera.dirty_by_pos")
		:group(group)
		:include(components.camera, components.position_dirty)
		:execute(M.set_dirty)
		:spawn()

	evolved.builder()
		:name("camera.dirty_by_size")
		:group(group)
		:include(components.camera, components.size_dirty)
		:execute(M.set_dirty)
		:spawn()

	evolved.builder()
		:name("camera.refresh")
		:group(group)
		:include(components.camera_dirty)
		:execute(M.refresh_camera)
		:spawn()

	return group
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.set_dirty(chunk, entity_list, entity_count)
	for index = 1, entity_count do
		evolved.set(entity_list[index], components.camera_dirty, true)
	end
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.refresh_camera(chunk, entity_list, entity_count)
	local root_url, position, size_x, size_y = chunk:components(components.root_url, components.position, components.size_x, components.size_y)
	local scale_x, scale_y = chunk:components(components.scale_x, components.scale_y)
	for index = 1, entity_count do
		M:update_camera_position(root_url[index], position[index])
		M:update_camera_zoom(root_url[index], size_x[index], size_y[index], scale_x[index], scale_y[index])
	end
end



local TEMP_VECTOR = vmath.vector3()
---Move camera to the entity position
---@param root_url hash
---@param position vector3
---@param animate_time number|nil
---@param easing userdata|nil
function M:update_camera_position(root_url, position, animate_time, easing)
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
function M:update_camera_zoom(root_url, size_x, size_y, scale_x, scale_y, animate_time, easing)
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


return M
