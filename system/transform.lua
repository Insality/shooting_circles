local evolved = require("evolved")
local components = require("components")

local M = {}

function M.register_components()
	---@class components
	---@field position evolved.id
	---@field scale evolved.id
	---@field scale_x evolved.id
	---@field scale_y evolved.id
	---@field scale_z evolved.id
	---@field quat evolved.id
	---@field size_x evolved.id
	---@field size_y evolved.id
	---@field size_z evolved.id
	---@field size evolved.id
	---@field transform evolved.id
	---@field position_dirty evolved.id
	---@field scale_dirty evolved.id
	---@field quat_dirty evolved.id
	---@field size_dirty evolved.id

	-- For go_setter use vmath.vector3
	components.position = evolved.builder():name("position"):default(vmath.vector3(0, 0, 0)):duplicate(function(value)
		return vmath.vector3(value)
	end):spawn()
	components.position_dirty = evolved.builder():name("position_dirty"):tag():spawn()

	components.scale_x = evolved.builder():name("scale_x"):default(1):spawn()
	components.scale_y = evolved.builder():name("scale_y"):default(1):spawn()
	components.scale_z = evolved.builder():name("scale_z"):default(1):spawn()
	components.scale = evolved.builder():name("scale"):tag():require(components.scale_x, components.scale_y, components.scale_z):spawn()
	components.scale_dirty = evolved.builder():name("scale_dirty"):tag():spawn()

	-- For go_setter use vmath.quat
	components.quat = evolved.builder():name("quat"):default(vmath.quat(0, 0, 0, 1)):duplicate(function(value)
		return vmath.quat(value)
	end):spawn()
	components.quat_dirty = evolved.builder():name("rotation_dirty"):tag():spawn()

	components.size_x = evolved.builder():name("size_x"):default(1):spawn()
	components.size_y = evolved.builder():name("size_y"):default(1):spawn()
	components.size_z = evolved.builder():name("size_z"):default(1):spawn()
	components.size = evolved.builder():name("size"):tag():require(components.size_x, components.size_y, components.size_z):spawn()
	components.size_dirty = evolved.builder():name("size_dirty"):tag():spawn()

	-- Tag to spawn all transform components
	components.transform = evolved.builder():name("transform"):tag():require(components.position, components.scale, components.quat, components.size):spawn()
end

return M
