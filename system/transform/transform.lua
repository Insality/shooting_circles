local evolved = require("evolved")
local fragments = require("fragments")

local M = {}

function M.register_fragments()
	---@class fragments
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
	fragments.position = evolved.builder():name("position"):default(vmath.vector3(0, 0, 0)):duplicate(function(value)
		return vmath.vector3(value)
	end):spawn()
	fragments.position_dirty = evolved.builder():name("position_dirty"):tag():spawn()

	fragments.scale_x = evolved.builder():name("scale_x"):default(1):spawn()
	fragments.scale_y = evolved.builder():name("scale_y"):default(1):spawn()
	fragments.scale_z = evolved.builder():name("scale_z"):default(1):spawn()
	fragments.scale = evolved.builder():name("scale"):tag():require(fragments.scale_x, fragments.scale_y, fragments.scale_z):spawn()
	fragments.scale_dirty = evolved.builder():name("scale_dirty"):tag():spawn()

	-- For go_setter use vmath.quat
	fragments.quat = evolved.builder():name("quat"):default(vmath.quat(0, 0, 0, 1)):duplicate(function(value)
		return vmath.quat(value)
	end):spawn()
	fragments.quat_dirty = evolved.builder():name("rotation_dirty"):tag():spawn()

	fragments.size_x = evolved.builder():name("size_x"):default(1):spawn()
	fragments.size_y = evolved.builder():name("size_y"):default(1):spawn()
	fragments.size_z = evolved.builder():name("size_z"):default(1):spawn()
	fragments.size = evolved.builder():name("size"):tag():require(fragments.size_x, fragments.size_y, fragments.size_z):spawn()
	fragments.size_dirty = evolved.builder():name("size_dirty"):tag():spawn()

	-- Tag to spawn all transform components
	fragments.transform = evolved.builder():name("transform"):tag():require(fragments.position, fragments.scale, fragments.quat, fragments.size):spawn()
end

return M
