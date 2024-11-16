local decore = require("decore.decore")
local panthera = require("panthera.panthera")

---@class world
---@field command_panthera command.panthera

---@class command.panthera
---@field panthera system.panthera
local M = {}


---@return command.panthera
function M.create(panthera_decore)
	return setmetatable({ panthera = panthera_decore }, { __index = M })
end


---@param entity entity
---@param animation_state panthera.animation.state
---@param animation_id string
function M:play_state(entity, animation_state, animation_id)
	if not decore.is_alive(self.panthera, entity) then
		return
	end

	panthera.play(animation_state, animation_id)
end


---@param entity entity
---@param animation_id string
---@param speed number|nil
---@param is_loop boolean|nil
function M:play(entity, animation_id, speed, is_loop)
	local p = entity.panthera
	assert(p, "Entity doesn't have panthera component")

	if not decore.is_alive(self.panthera, entity) then
		return
	end

	panthera.play(p.animation_state, animation_id, {
		is_loop = is_loop or false,
		speed = speed or 1,
		callback = function(animation_path)
			for index = 1, #p.detached_animations do
				if p.detached_animations[index] == p.animation_state then
					table.remove(p.detached_animations, index)
					break
				end
			end
		end
	})
end


---@param entity entity
---@param animation_id string
---@param progress number
function M:set_progress(entity, animation_id, progress)
	local p = entity.panthera
	assert(p, "Entity doesn't have panthera component")

	if not decore.is_alive(self.panthera, entity) then
		return
	end

	local time = panthera.get_duration(p.animation_state, animation_id)
	panthera.set_time(p.animation_state, animation_id, time * progress)
end


return M
