---Download Defold annotations from here: https://github.com/astrochili/defold-annotations/releases/

---@class log
---@field get_logger fun(name: string, force_debug_level: string|nil): logger

---@class logger
---@field trace fun(logger: logger, message: string, context:any)
---@field debug fun(logger: logger, message: string, context:any)
---@field info fun(logger: logger, message: string, context:any)
---@field warn fun(logger: logger, message: string, context:any)
---@field error fun(logger: logger, message: string, context:any)

---@class entities
---@field on_action_window boolean
