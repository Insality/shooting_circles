local decore = require("decore.decore")

---@class entity
---@field movement_controller component.movement_controller|nil

---@class entity.movement_controller: entity
---@field movement_controller component.movement_controller
---@field physics component.physics

---@class component.movement_controller
---@field speed number
---@field movement_x number @Runtime
---@field movement_y number @Runtime
decore.register_component("movement_controller", {
	speed = 1,
	movement_x = 0,
	movement_y = 0,
})

---@class system.movement_controller: system
---@field entities entity.movement_controller[]
local M = {}

local ACTION_ID_TO_SIDE = {
	[hash("key_w")] = { y = 1 },
	[hash("key_s")] = { y = -1 },
	[hash("key_a")] = { x = -1 },
	[hash("key_d")] = { x = 1 },
	[hash("key_up")] = { y = 1 },
	[hash("key_down")] = { y = -1 },
	[hash("key_left")] = { x = -1 },
	[hash("key_right")] = { x = 1 },
}

---@static
---@return system.movement_controller
function M.create_system()
	local system = setmetatable(decore.ecs.processingSystem(), { __index = M })
	system.filter = decore.ecs.requireAll("movement_controller", "physics")
	system.id = "movement_controller"

	return system
end

function M:postWrap()
	self.world.event_bus:process("input_event", self.process_input_event, self)
end


---@param input_event event.input_event
function M:process_input_event(input_event)
	local action_id = input_event.action_id
	local side = ACTION_ID_TO_SIDE[action_id]
	if side then
		for _, e in ipairs(self.entities) do
			self:apply_input_event(e, input_event)
		end
	end
end


---@param entity entity.movement_controller
---@param input_event event.input_event
function M:apply_input_event(entity, input_event)
	local action_id = input_event.action_id
	local action = input_event
	local movement_controller = entity.movement_controller

	local side = ACTION_ID_TO_SIDE[action_id]
	if action.pressed then
		if side.x then
			movement_controller.movement_x = side.x
		end
		if side.y then
			movement_controller.movement_y = side.y
		end
	end
	if action.released then
		if side.x then
			movement_controller.movement_x = 0
		end
		if side.y then
			movement_controller.movement_y = 0
		end
	end
end


function M:process(entity, dt)
	local movement_controller = entity.movement_controller

	local speed = movement_controller.speed
	local movement_x = movement_controller.movement_x
	local movement_y = movement_controller.movement_y

	if movement_x ~= 0 or movement_y ~= 0 then
		local force_x = movement_x * speed * dt * 60
		local force_y = movement_y * speed * dt * 60
		self.world.physics_command:add_force(entity, force_x, force_y)
	end
end


return M
