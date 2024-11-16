local decore = require("decore.decore")
local panthera = require("panthera.panthera")

local panthera_command = require("systems.panthera.panthera_command")

---@class entity
---@field panthera component.panthera|nil

---@class entity.panthera: entity
---@field panthera component.panthera
---@field game_object component.game_object
---@field transform component.transform

---@class component.panthera
---@field animation_path string
---@field animation_state panthera.animation.state|nil
---@field default_animation string
---@field speed number
---@field is_loop boolean|nil
---@field play_on_start boolean|nil
---@field detached_animations panthera.animation.state[]
decore.register_component("panthera", {
	animation_path = "",
})

---@class system.panthera: system
---@field entities entity.panthera[]
local M = {}

---@static
---@return system.panthera, system.panthera_command
function M.create_system()
	local system = setmetatable(decore.ecs.system(), { __index = M })
	system.filter = decore.ecs.requireAll("panthera", "game_object", decore.ecs.rejectAll("hidden"))
	system.id = "panthera"

	return system, panthera_command.create_system(system)
end


---@private
function M:postWrap()
	self.world.event_bus:process("window_event", self.process_window_event, self)
end


---@param entity entity.panthera
function M:onAdd(entity)
	local p = entity.panthera
	p.detached_animations = {}

	local animation_state = panthera.create_go(p.animation_path, nil, entity.game_object.object)

	if animation_state then
		p.animation_state = animation_state

		-- TODO: This one should be in update
		if p.play_on_start then
			panthera.play(p.animation_state, p.default_animation, {
				is_loop = p.is_loop or false,
				speed = p.speed or 1
			})
		end
	end
end


---@param entity entity.panthera
function M:onRemove(entity)
	local p = entity.panthera
	if panthera.is_playing(p.animation_state) then
		panthera.stop(p.animation_state)
	end

	p.animation_state = nil

	for index = 1, #p.detached_animations do
		local state = p.detached_animations[index]
		if panthera.is_playing(state) then
			panthera.stop(state)
		end
	end
end


---@private
---@param window_event event.window_event
function M:process_window_event(window_event)
	if window_event == window.WINDOW_EVENT_FOCUS_GAINED then
		panthera.reload_animation()
	end
end


return M
