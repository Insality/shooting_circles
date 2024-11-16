---@class physics.collision.object
---@field id hash @Id of the object
---@field group hash @Group of the object
---@field position vector3|nil @Position of the object
---@field relative_velocity vector3|nil @Relative velocity of the object
---@field mass number|nil @Mass of the object
---@field normal vector3|nil @Normal of the object

---@class physics.collision.contact_point_event
---@field a physics.collision.object
---@field b physics.collision.object
---@field applied_impulse number @Applied impulse
---@field distance number @Distance

---@class physics.collision.collision_event
---@field a physics.collision.object
---@field b physics.collision.object

---@class physics.collision.ray_cast_response
---@field requst_id number @Request id
---@field group hash @Group of the object
---@field position vector3 @Position of the object
---@field normal vector3 @Normal of the object
---@field fraction number @Fraction of the object

---@class physics.collision.ray_cast_missed
---@field requst_id number @Request id

---@class physics.collision.trigger_event
---@field a physics.collision.object
---@field b physics.collision.object
---@field enter boolean @True if the trigger interaction is entering, false if it is exiting
