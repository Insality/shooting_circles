local ecs = require("decore.ecs")
local panthera = require("panthera.panthera")

---@class entity
---@field panthera_command component.panthera_command|nil

---@class entity.panthera_command: entity
---@field panthera_command component.panthera_command

---@class component.panthera_command
---@field entity entity
---@field animation_id string|nil
---@field speed number|nil
---@field is_loop boolean|nil
---@field detached boolean|nil
---@field progress number|nil

---@class system.panthera_command: system
---@field entities entity.panthera_command[]
---@field panthera system.panthera
local M = {}

---@static
---@return system.panthera_command
function M.create_system(panthera)
	local system = setmetatable(ecs.system(), { __index = M })
	system.filter = ecs.requireAny("panthera_command", "window_event")
	system.id = "panthera_command"

	system.panthera = panthera

	return system
end


---@param entity entity.panthera_command
function M:onAdd(entity)
	local command = entity.panthera_command
	if command and self.panthera.indices[command.entity] then
		self:process_command(command)
	end

	local window_event = entity.window_event
	if window_event then
		if window_event.is_focus_gained then
			panthera.reload_animation()
		end
	end

	self.world:removeEntity(entity)
end


---@param command component.panthera_command
function M:process_command(command)
	local entity = command.entity --[[@as entity.panthera]]
	local p = entity.panthera

	if command.animation_id then
		local animation_state = p.animation_state
		if command.detached then
			animation_state = panthera.clone_state(p.animation_state)
		end

		if not command.progress then
			if command.detached then
				table.insert(p.detached_animations, animation_state)
			end

			panthera.play(animation_state, command.animation_id, {
				is_loop = command.is_loop or false,
				speed = command.speed or 1,
				callback = function(animation_path)
					if p.default_animation and p.default_animation ~= "" then
						panthera.play(p.animation_state, p.default_animation, {
							is_loop = p.is_loop or false,
							speed = p.speed or 1
						})
					end
					if command.detached then
						for index = 1, #p.detached_animations do
							if p.detached_animations[index] == animation_state then
								table.remove(p.detached_animations, index)
								break
							end
						end
					end
				end
			})
		else
			if animation_state then
				local progress = command.progress
				local time = panthera.get_duration(animation_state, command.animation_id)
				panthera.set_time(animation_state, command.animation_id, time * progress)
			end
		end
	end
end


return M
