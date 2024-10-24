local decore = require("decore.decore")
local panthera = require("panthera.panthera")

---@class world
---@field panthera_command system.panthera_command

---@class system.panthera_command: system_command
---@field panthera system.panthera
local M = {}

---@static
---@return system.panthera_command
function M.create_system(panthera)
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.id = "panthera_command"
	system.panthera = panthera

	return system
end

---@private
function M:onAddToWorld()
	self.world.panthera_command = self
end


---@private
function M:onRemoveFromWorld()
	self.world.panthera_command = nil
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
