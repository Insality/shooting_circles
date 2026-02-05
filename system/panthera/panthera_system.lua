local decore = require("decore.decore")
local panthera = require("panthera.panthera")

local panthera_command = require("system.panthera.panthera_command")

---@class entity
---@field panthera component.panthera|nil

---@class entity.panthera: entity
---@field panthera component.panthera
---@field game_object component.game_object
---@field transform component.transform

---@class component.panthera
---@field animation_path string|table
---@field animation_state panthera.animation|nil
---@field default_animation string
---@field speed number|nil
---@field is_loop boolean|nil
---@field play_on_start boolean|nil
---@field play_on_remove string|nil Play animation on entity remove
decore.register_component("panthera", {
	default_animation = "default",
})

---@class system.panthera: system
---@field entities entity.panthera[]
local M = {}


---@return system.panthera
function M.create()
	local system = decore.system(M, "panthera")
	system.filter = decore.ecs.requireAll("panthera", "game_object", decore.ecs.rejectAll("hidden"))

	return system
end


---@private
function M:postWrap()
	self.world.event_bus:process("window_event", self.process_window_event, self)
end


function M:onAddToWorld()
	self.world.panthera = panthera_command.create(self)
end


---@param entity entity.panthera
function M:onAdd(entity)
	local p = entity.panthera

	local animation_state
	if entity.game_object.object then
		animation_state = panthera.create_go(p.animation_path, nil, entity.game_object.object)
	else
		animation_state = panthera.create_go(p.animation_path, nil, { ["/"]  = entity.game_object.root })
	end

	if animation_state then
		p.animation_state = animation_state
		p.animation_path = animation_state.animation_path

		-- TODO: This one should be in update?
		if p.play_on_start then
			timer.delay(0.1, false, function()
			panthera.play(p.animation_state, p.default_animation, {
					is_loop = p.is_loop or false,
					speed = p.speed or 1
				})
			end)
		end
	end
end


---@param entity entity.panthera
function M:onRemove(entity)
	local p = entity.panthera
	panthera.stop(p.animation_state)

	if p.play_on_remove then
		panthera.play(p.animation_state, p.play_on_remove)
	end
end


---@private
---@param window_events constant[]
function M:process_window_event(window_events)
	for i = 1, #window_events do
		local window_event = window_events[i]
		if window_event == window.WINDOW_EVENT_FOCUS_GAINED then
			panthera.reload_animation()
		end
	end
end


return M
