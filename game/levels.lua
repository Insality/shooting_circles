local decore = require("decore.decore")

local M = {}

M.LEVELS = {
	{ url = "/levels#level_barrage", index = 1, text = "Barrage" },
	{ url = "/levels#level_sniper",  index = 2, text = "Sniper" },
	{ url = "/levels#level_rocket",  index = 3, text = "Rocket" },
	{ url = "/levels#level_arcade",  index = 4, text = "Arcade" },
	{ url = "/levels#level_minigun", index = 5, text = "Minigun" },
}

M.state = {
	current_level_index = 2,
	prev_level_entity = nil,
}


---@private
---@param direction number
---@return number
function M.add_index(direction)
	local index = M.state.current_level_index + direction
	if index < 1 then
		index = #M.LEVELS
	end
	if index > #M.LEVELS then
		index = 1
	end

	return index
end


---@param world world
---@param level_index number
function M.spawn(world, level_index)
	if M.state.prev_level_entity then
		world:removeEntity(M.state.prev_level_entity)
		M.state.prev_level_entity = nil
	end

	local level = M.LEVELS[level_index]
	local entity_load_scene = decore.create({
		transform = {},
		game_object = {
			factory_url = level.url
		}
	})

	world:addEntity(entity_load_scene)
	world.game_gui:set_level_text(level.text)

	M.state.prev_level_entity = entity_load_scene
	M.state.current_level_index = level_index
end


---@param world world
---@param direction number
---@return number
function M.spawn_next(world, direction)
	local index = M.add_index(direction)
	M.spawn(world, index)
	return index
end


return M
