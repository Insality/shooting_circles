---@return entity.debug
return {
	debug = {},
	on_key_released = {
		key_to_command = {
			key_p = { "debug_command", "toggle_profiler", true },
			key_m = { "debug_command", "toggle_memory_record", true },
			key_r = { "debug_command", "restart", true }
		}
	}
}