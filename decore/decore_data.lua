local M = {}

---@type table<string, table<string, entity>>
M.entities = {}
M.entities_order = {}

---@type table<string, table<string, any>>
M.components = {}
M.components_order = {}

---@type table<string, table<string, decore.world.instance>>
M.worlds = {}
M.worlds_order = {}

return M
