local evolved = require("evolved")
local components = require("components")


local M = {}


function M.register_components()
	---@class components
	---@field damage_number evolved.id
	---@field damage_number_started evolved.id

	components.damage_number = evolved.builder():default(1):name("damage_number"):spawn()
	components.damage_number_started = evolved.builder():name("damage_number_started"):tag():spawn()
end


function M.create_system()
	return evolved.builder()
		:set(components.system)
		:name("damage_number")
		:include(components.damage_number, components.root_url)
		:exclude(components.damage_number_started)
		:execute(M.update)
		:spawn()
end


---@param chunk evolved.chunk
---@param entity_list evolved.entity[]
---@param entity_count number
function M.update(chunk, entity_list, entity_count)
	local root_url, damage_number = chunk:components(components.root_url, components.damage_number)
	for index = 1, entity_count do
		local object = root_url[index]

		M.animate_damage_number(entity_list[index], object, damage_number[index])
		evolved.set(entity_list[index], components.damage_number_started)
	end

	--evolved.batch_set(entity_list, components.damage_number_started)
end


function M.animate_damage_number(entity, object, damage)
	local time_1 = 0.4
	local time_2 = 0.7
	local offset_x = math.random(-100, 100)
	local offset_y = math.random(20, 80)
	local height = math.random(50, 100)

	-- Set damage text
	local label_url = msg.url(object)
	label_url.fragment = hash("label")
	label.set_text(label_url, tostring(damage))

	local root = object
	local current_pos = go.get_position(root)

	-- Animate X position
	go.set(root, "position.x", current_pos.x + offset_x)
	go.animate(root, "position.x", go.PLAYBACK_ONCE_FORWARD, current_pos.x + offset_x + offset_x/2, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "position.x", go.PLAYBACK_ONCE_FORWARD, current_pos.x + offset_x, go.EASING_INSINE, time_2, 0)
	end)

	-- Animate Y position
	go.set(root, "position.y", current_pos.y + offset_y)
	go.animate(root, "position.y", go.PLAYBACK_ONCE_FORWARD, current_pos.y + height + offset_y, go.EASING_OUTSINE, time_1 + time_2)

	-- Animate Z position for depth sorting
	local z = current_pos.z
	go.set(root, "position.z", z)
	go.animate(root, "position.z", go.PLAYBACK_ONCE_FORWARD, z - 1, go.EASING_LINEAR, time_1 + time_2)

	-- Animate scale X
	local scale_x = 1.2 + math.random() * 0.2
	go.animate(root, "scale.x", go.PLAYBACK_ONCE_FORWARD, scale_x, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "scale.x", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTEXPO, time_2, 0)
	end)

	-- Animate scale Y
	local scale_y = 1.2 + math.random() * 0.2
	go.animate(root, "scale.y", go.PLAYBACK_ONCE_FORWARD, scale_y, go.EASING_OUTSINE, time_1, 0, function()
		go.animate(root, "scale.y", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTEXPO, time_2, 0)
	end)

	-- Animate alpha fade out
	go.animate(label_url, "color.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTSINE, time_2 + time_1)
	go.animate(label_url, "outline.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_OUTSINE, time_2 + time_1)
end


return M
