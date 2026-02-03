local decore = require("decore.decore")

---@class entity
---@field movement_controller component.movement_controller|nil

---@class entity.movement_controller: entity
---@field movement_controller component.movement_controller

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
---@field input_keys table
local M = {}

local ACTION_ID_TO_SIDE = {
	[hash("key_w")] = { y = 1, id = "up" },
	[hash("key_s")] = { y = -1, id = "down" },
	[hash("key_a")] = { x = -1, id = "left" },
	[hash("key_d")] = { x = 1, id = "right" },
	[hash("key_up")] = { y = 1, id = "up" },
	[hash("key_down")] = { y = -1, id = "down" },
	[hash("key_left")] = { x = -1, id = "left" },
	[hash("key_right")] = { x = 1, id = "right" },
}

---@static
---@return system.movement_controller
function M.create()
	local system = decore.system(M, "movement_controller", { "movement_controller", "transform" })
	system.input_keys = {}
	return system
end


function M:postWrap()
	self.world.event_bus:process("input_event", self.process_input_events, self)
end


---@param input_events system.input.event[]
function M:process_input_events(input_events)
	for _, input_event in ipairs(input_events) do
		local action_id = input_event.action_id
		local side = ACTION_ID_TO_SIDE[action_id]
		if not side then
			return
		end

		for index = 1, #self.entities do
			self:apply_input_event(self.entities[index], input_event)
		end
	end
end


---@param entity entity.movement_controller
---@param input_event system.input.event
function M:apply_input_event(entity, input_event)
	local action_id = input_event.action_id
	local action = input_event
	local movement_controller = entity.movement_controller

	local side = ACTION_ID_TO_SIDE[action_id]
	if action.pressed and side then
		self.input_keys[side.id] = true
	end
	if action.released and side then
		self.input_keys[side.id] = nil
	end

	do -- direction_x
		movement_controller.movement_x = 0
		if self.input_keys["left"] then
			movement_controller.movement_x = movement_controller.movement_x - 1
		end
		if self.input_keys["right"] then
			movement_controller.movement_x = movement_controller.movement_x + 1
		end
	end

	do -- direction_y
		movement_controller.movement_y = 0
		if self.input_keys["up"] then
			movement_controller.movement_y = movement_controller.movement_y + 1
		end
		if self.input_keys["down"] then
			movement_controller.movement_y = movement_controller.movement_y - 1
		end
	end
end


---@param dt number
function M:update(dt)
	for index = 1, #self.entities do
		local entity = self.entities[index]
		local movement_controller = entity.movement_controller

		local speed = movement_controller.speed
		local movement_x = movement_controller.movement_x
		local movement_y = movement_controller.movement_y

		if movement_x ~= 0 or movement_y ~= 0 then
			local force_x = movement_x * speed * dt * 60
			local force_y = movement_y * speed * dt * 60
			self.world.command_physics:add_force(entity, force_x, force_y)
		end
	end
end


return M
