# Defold Reference API

## Box2D documentation
Functions for interacting with Box2D.

```lua
-- Functions
b2d.get_body(url) -- Get the Box2D body from a collision object
b2d.get_world() -- Get the Box2D world from the current collection
```

## Box2D b2Body documentation
Functions for interacting with Box2D bodies.

```lua
-- Functions
b2d.body.apply_angular_impulse(body, impulse) -- Apply an angular impulse.
b2d.body.apply_force(body, force, point) -- Apply a force at a world point. If the force is no...
b2d.body.apply_force_to_center(body, force) -- Apply a force to the center of mass. This wakes up the body.
b2d.body.apply_linear_impulse(body, impulse, point) -- Apply an impulse at a point. This immediately modi...
b2d.body.apply_torque(body, torque) -- Apply a torque. This affects the angular velocity...
b2d.body.enable_sleep(body, enable) -- You can disable sleeping on this body. If you disable sleeping, the body will be woken.
b2d.body.get_angle(body) -- Get the angle in radians.
b2d.body.get_angular_damping(body) -- Get the angular damping of the body.
b2d.body.get_angular_velocity(body) -- Get the angular velocity.
b2d.body.get_gravity_scale(body) -- Get the gravity scale of the body.
b2d.body.get_linear_damping(body) -- Get the linear damping of the body.
b2d.body.get_linear_velocity(body) -- Get the linear velocity of the center of mass.
b2d.body.get_linear_velocity_from_local_point(body, local_point) -- Get the world velocity of a local point.
b2d.body.get_linear_velocity_from_world_point(body, world_point) -- Get the world linear velocity of a world point attached to this body.
b2d.body.get_local_center_of_mass(body) -- Get the local position of the center of mass.
b2d.body.get_local_point(body, world_point) -- Gets a local point relative to the body's origin given a world point.
b2d.body.get_local_vector(body, world_vector) -- Gets a local vector given a world vector.
b2d.body.get_mass(body) -- Get the total mass of the body.
b2d.body.get_position(body) -- Get the world body origin position.
b2d.body.get_rotational_inertia(body) -- Get the rotational inertia of the body about the local origin.
b2d.body.get_type(body) -- Get the type of this body.
b2d.body.get_world(body) -- Get the parent world of this body.
b2d.body.get_world_center_of_mass(body) -- Get the world position of the center of mass.
b2d.body.get_world_point(body, local_vector) -- Get the world coordinates of a point given the local coordinates.
b2d.body.get_world_vector(body, local_vector) -- Get the world coordinates of a vector given the local coordinates.
b2d.body.is_active(body) -- Get the active state of the body.
b2d.body.is_awake(body) -- Get the sleeping state of this body.
b2d.body.is_bullet(body) -- Is this body in bullet mode
b2d.body.is_fixed_rotation(body) -- Does this body have fixed rotation?
b2d.body.is_sleeping_enabled(body) -- Is this body allowed to sleep
b2d.body.reset_mass_data(body) -- This resets the mass properties to the sum of the ...
b2d.body.set_active(body, enable) -- Set the active state of the body
b2d.body.set_angular_damping(body, damping) -- Set the angular damping of the body.
b2d.body.set_angular_velocity(body, omega) -- Set the angular velocity.
b2d.body.set_awake(body, enable) -- Set the sleep state of the body. A sleeping body has very low CPU cost.
b2d.body.set_bullet(body, enable) -- Should this body be treated like a bullet for continuous collision detection?
b2d.body.set_fixed_rotation(body, enable) -- Set this body to have fixed rotation. This causes the mass to be reset.
b2d.body.set_gravity_scale(body, scale) -- Set the gravity scale of the body.
b2d.body.set_linear_damping(body, damping) -- Set the linear damping of the body.
b2d.body.set_linear_velocity(body, velocity) -- Set the linear velocity of the center of mass.
b2d.body.set_transform(body, position, angle) -- Set the position of the body's origin and rotation
b2d.body.set_type(body, type) -- Set the type of this body. This may alter the mass and velocity.

-- Constants
b2d.body.B2_DYNAMIC_BODY -- Dynamic body
b2d.body.B2_KINEMATIC_BODY -- Kinematic body
b2d.body.B2_STATIC_BODY -- Static (immovable) body
```

## Buffer API documentation
Functions for manipulating buffers and streams

```lua
-- Functions
buffer.copy_buffer(dst, dstoffset, src, srcoffset, count) -- copies one buffer to another
buffer.copy_stream(dst, dstoffset, src, srcoffset, count) -- copies data from one stream to another
buffer.create(element_count, declaration) -- creates a new buffer
buffer.get_bytes(buffer, stream_name) -- gets data from a stream
buffer.get_metadata(buf, metadata_name) -- retrieve a metadata entry from a buffer
buffer.get_stream(buffer, stream_name) -- gets a stream from a buffer
buffer.set_metadata(buf, metadata_name, values, value_type) -- set a metadata entry on a buffer

-- Constants
buffer.VALUE_TYPE_FLOAT32 -- float32
buffer.VALUE_TYPE_INT16 -- int16
buffer.VALUE_TYPE_INT32 -- int32
buffer.VALUE_TYPE_INT64 -- int64
buffer.VALUE_TYPE_INT8 -- int8
buffer.VALUE_TYPE_UINT16 -- uint16
buffer.VALUE_TYPE_UINT32 -- uint32
buffer.VALUE_TYPE_UINT64 -- uint64
buffer.VALUE_TYPE_UINT8 -- uint8
```

### Examples

How to copy elements (e.g. vertices) from one buffer to another
```lua
-- copy entire buffer
buffer.copy_buffer(dstbuffer, 0, srcbuffer, 0, #srcbuffer)

-- copy last 10 elements to the front of another buffer
buffer.copy_buffer(dstbuffer, 0, srcbuffer, #srcbuffer - 10, 10)
```

How to update a texture of a sprite:
```lua
-- copy entire stream
local srcstream = buffer.get_stream(srcbuffer, hash("xyz"))
local dststream = buffer.get_stream(dstbuffer, hash("xyz"))
buffer.copy_stream(dststream, 0, srcstream, 0, #srcstream)
```

How to create and initialize a buffer
```lua
function init(self)
  local size = 128
  self.image = buffer.create( size * size, { {name=hash("rgb"), type=buffer.VALUE_TYPE_UINT8, count=3 } })
  self.imagestream = buffer.get_stream(self.image, hash("rgb"))

  for y=0,self.height-1 do
     for x=0,self.width-1 do
         local index = y * self.width * 3 + x * 3 + 1
         self.imagestream[index + 0] = self.r
         self.imagestream[index + 1] = self.g
         self.imagestream[index + 2] = self.b
     end
  end
```

How to get a metadata entry from a buffer
```lua
-- retrieve a metadata entry named "somefloats" and its nomeric type
local values, type = buffer.get_metadata(buf, hash("somefloats"))
if metadata then print(#metadata.." values in 'somefloats'") end
```

How to set a metadata entry on a buffer
```lua
-- create a new metadata entry with three floats
buffer.set_metadata(buf, hash("somefloats"), {1.5, 3.2, 7.9}, buffer.VALUE_TYPE_FLOAT32)
-- ...
-- update to a new set of values
buffer.set_metadata(buf, hash("somefloats"), {-2.5, 10.0, 32.2}, buffer.VALUE_TYPE_FLOAT32)
```


## Built-ins API documentation
Built-in scripting functions.

```lua
-- Functions
hash(s) -- hashes a string
hash_to_hex(h) -- get hex representation of a hash value as a string
pprint(v) -- pretty printing
```

### Examples

To compare a message_id in an on-message callback function:
```lua
function on_message(self, message_id, message, sender)
    if message_id == hash("my_message") then
        -- Act on the message here
    end
end
```

Example for hash_to_hex(h):
```lua
local h = hash("my_hash")
local hexstr = hash_to_hex(h)
print(hexstr) --> a2bc06d97f580aab
```

Pretty printing a Lua table with a nested table:
```lua
local t2 = { 1, 2, 3, 4 }
local t = { key = "value", key2 = 1234, key3 = t2 }
pprint(t)
```

Resulting in the following output (note that the key order in non array
Lua tables is undefined):
```lua
{
  key3 = {
    1 = 1,
    2 = 2,
    3 = 3,
    4 = 4,
  }
  key2 = 1234,
  key = value,
}
```


## Camera API documentation
Camera functions, messages and constants.

```lua
-- Functions
camera.get_aspect_ratio(camera) -- get aspect ratio
camera.get_cameras() -- get all camera URLs
camera.get_enabled(camera) -- get enabled
camera.get_far_z(camera) -- get far z
camera.get_fov(camera) -- get field of view
camera.get_near_z(camera) -- get near z
camera.get_orthographic_zoom(camera) -- get orthographic zoom
camera.get_projection(camera) -- get projection matrix
camera.get_view(camera) -- get view matrix
camera.set_aspect_ratio(camera, aspect_ratio) -- set aspect ratio
camera.set_far_z(camera, far_z) -- set far z
camera.set_fov(camera, fov) -- set field of view
camera.set_near_z(camera, near_z) -- set near z
camera.set_orthographic_zoom(camera, orthographic_zoom) -- set orthographic zoom
```

### Component messages
- `set_camera` - {aspect_ratio, fov, near_z, far_z, orthographic_projection, orthographic_zoom}, sets camera properties

### Component properties
- `aspect_ratio` (float) - camera aspect ratio
- `far_z` (float) - camera far_z
- `fov` (float) - camera fov
- `near_z` (float) - camera near_z
- `orthographic_zoom` (float) - camera orthographic_zoom
- `projection` (float) - camera projection
- `view` (float) - camera view

### Examples

Example for camera.get_cameras():
```lua
for k,v in pairs(camera.get_cameras()) do
    render.set_camera(v)
    render.draw(...)
    render.set_camera()
end
```


## Collection factory API documentation
Functions for controlling collection factory components which are
used to dynamically spawn collections into the runtime.

```lua
-- Functions
collectionfactory.create(url, [position], [rotation], [properties], [scale]) -- Spawn a new instance of a collection into the existing collection.
collectionfactory.get_status([url]) -- Get collection factory status
collectionfactory.load([url], [complete_function]) -- Load resources of a collection factory prototype.
collectionfactory.set_prototype([url], [prototype]) -- changes the prototype for the collection factory
collectionfactory.unload([url]) -- Unload resources previously loaded using collectionfactory.load

-- Constants
collectionfactory.STATUS_LOADED -- loaded
collectionfactory.STATUS_LOADING -- loading
collectionfactory.STATUS_UNLOADED -- unloaded
```

### Examples

How to spawn a collection of game objects:
```lua
function init(self)
  -- Spawn a small group of enemies.
  local pos = vmath.vector3(100, 12.5, 0)
  local rot = vmath.quat_rotation_z(math.pi / 2)
  local scale = 0.5
  local props = {}
  props[hash("/enemy_leader")] = { health = 1000.0 }
  props[hash("/enemy_1")] = { health = 200.0 }
  props[hash("/enemy_2")] = { health = 400.0, color = hash("green") }

  local self.enemy_ids = collectionfactory.create("#enemyfactory", pos, rot, props, scale)
  -- enemy_ids now map to the spawned instance ids:
  --
  -- pprint(self.enemy_ids)
  --
  -- DEBUG:SCRIPT:
  -- {
  --   hash: [/enemy_leader] = hash: [/collection0/enemy_leader],
  --   hash: [/enemy_1] = hash: [/collection0/enemy_1],
  --   hash: [/enemy_2] = hash: [/collection0/enemy_2]
  -- }

  -- Send "attack" message to the leader. First look up its instance id.
  local leader_id = self.enemy_ids[hash("/enemy_leader")]
  msg.post(leader_id, "attack")
end
```

How to delete a spawned collection:
```lua
go.delete(self.enemy_ids)
```

How to load resources of a collection factory prototype.
```lua
collectionfactory.load("#factory", function(self, url, result) end)
```

How to unload the previous prototypes resources, and then spawn a new collection
```lua
collectionfactory.unload("#factory") -- unload the previous resources
collectionfactory.set_prototype("#factory", "/main/levels/level1.collectionc")
local ids = collectionfactory.create("#factory", go.get_world_position(), vmath.quat())
```

How to unload resources of a collection factory prototype loaded with collectionfactory.load
```lua
collectionfactory.unload("#factory")
```


## Collection proxy API documentation
Messages for controlling and interacting with collection proxies
which are used to dynamically load collections into the runtime.

```lua
-- Functions
collectionproxy.get_resources(collectionproxy) -- return an indexed table of all the resources of a collection proxy
collectionproxy.missing_resources(collectionproxy) -- return an array of missing resources for a collection proxy
collectionproxy.set_collection([url], [prototype]) -- changes the collection for a collection proxy.

-- Constants
collectionproxy.RESULT_ALREADY_LOADED -- collection proxy is already loaded
collectionproxy.RESULT_LOADING -- collection proxy is loading now
collectionproxy.RESULT_NOT_EXCLUDED -- collection proxy isn't excluded
```

### Component messages
- `async_load` - tells a collection proxy to start asynchronous loading of the referenced collection
- `disable` - tells a collection proxy to disable the referenced collection
- `enable` - tells a collection proxy to enable the referenced collection
- `final` - tells a collection proxy to finalize the referenced collection
- `init` - tells a collection proxy to initialize the loaded collection
- `load` - tells a collection proxy to start loading the referenced collection
- `proxy_loaded` - reports that a collection proxy has loaded its referenced collection
- `proxy_unloaded` - reports that a collection proxy has unloaded its referenced collection
- `set_time_step` - {factor, mode}, sets the time-step for update
- `unload` - tells a collection proxy to start unloading the referenced collection

### Examples

Example for collectionproxy.get_resources(collectionproxy):
```lua
local function print_resources(self, cproxy)
    local resources = collectionproxy.get_resources(cproxy)
    for _, v in ipairs(resources) do
        print("Resource: " .. v)
    end
end
```

Example for collectionproxy.missing_resources(collectionproxy):
```lua
function init(self)
end

local function callback(self, id, response)
    local expected = self.resources[id]
    if response ~= nil and response.status == 200 then
        print("Successfully downloaded resource: " .. expected)
        resource.store_resource(response.response)
    else
        print("Failed to download resource: " .. expected)
        -- error handling
    end
end

local function download_resources(self, cproxy)
    self.resources = {}
    local resources = collectionproxy.missing_resources(cproxy)
    for _, v in ipairs(resources) do
        print("Downloading resource: " .. v)

        local uri = "http://example.defold.com/" .. v
        local id = http.request(uri, "GET", callback)
        self.resources[id] = v
    end
end
```

The example assume the script belongs to an instance with collection-proxy-component with id "proxy".
```lua
local ok, error = collectionproxy.set_collection("/go#collectionproxy", "/LU/3.collectionc")
 if ok then
     print("The collection has been changed to /LU/3.collectionc")
 else
     print("Error changing collection to /LU/3.collectionc ", error)
 end
 msg.post("/go#collectionproxy", "load")
 msg.post("/go#collectionproxy", "init")
 msg.post("/go#collectionproxy", "enable")
```


## Collision object physics API documentation
Collision object physics API documentation

```lua
-- Functions
physics.create_joint(joint_type, collisionobject_a, joint_id, position_a, collisionobject_b, position_b, [properties]) -- create a physics joint
physics.destroy_joint(collisionobject, joint_id) -- destroy a physics joint
physics.get_gravity() -- get the gravity for collection
physics.get_group(url) -- returns the group of a collision object
physics.get_joint_properties(collisionobject, joint_id) -- get properties for a joint
physics.get_joint_reaction_force(collisionobject, joint_id) -- get the reaction force for a joint
physics.get_joint_reaction_torque(collisionobject, joint_id) -- get the reaction torque for a joint
physics.get_maskbit(url, group) -- checks the presense of a group in the mask (maskbit) of a collision object
physics.get_shape(url, shape) -- get collision shape info
physics.raycast(from, to, groups, [options]) -- requests a ray cast to be performed
physics.raycast_async(from, to, groups, [request_id]) -- requests a ray cast to be performed
physics.set_event_listener(callback) -- sets a physics world event listener. If a function is set, physics messages will no longer be sent to on_message.
physics.set_gravity(gravity) -- set the gravity for collection
physics.set_group(url, group) -- change the group of a collision object
physics.set_hflip(url, flip) -- flip the geometry horizontally for a collision object
physics.set_joint_properties(collisionobject, joint_id, properties) -- set properties for a joint
physics.set_maskbit(url, group, maskbit) -- updates the mask of a collision object
physics.set_shape(url, shape, table) -- set collision shape data
physics.set_vflip(url, flip) -- flip the geometry vertically for a collision object
physics.update_mass(collisionobject, mass) -- updates the mass of a dynamic 2D collision object in the physics world.
physics.wakeup(url) -- explicitly wakeup a collision object

-- Constants
physics.JOINT_TYPE_FIXED -- fixed joint type
physics.JOINT_TYPE_HINGE -- hinge joint type
physics.JOINT_TYPE_SLIDER -- slider joint type
physics.JOINT_TYPE_SPRING -- spring joint type
physics.JOINT_TYPE_WELD -- weld joint type
physics.JOINT_TYPE_WHEEL -- wheel joint type
physics.SHAPE_TYPE_BOX
physics.SHAPE_TYPE_CAPSULE
physics.SHAPE_TYPE_HULL
physics.SHAPE_TYPE_SPHERE
```

### Component messages
- `apply_force` - {force, position}, applies a force on a collision object
- `collision_event` - {a, b}, reports a collision between two collision objects in cases where a listener is specified.
- `collision_response` - {other_id, other_position, other_group, own_group}, reports a collision between two collision objects
- `contact_point_event` - {applied_impulse, distance, a, b}, reports a contact point between two collision objects in cases where a listener is specified.
- `contact_point_response` - {position, normal, relative_velocity, distance, applied_impulse, life_time, mass, other_mass, other_id, other_position, other_group, own_group}, reports a contact point between two collision objects
- `ray_cast_missed` - {request_id}, reports a ray cast miss
- `ray_cast_response` - {fraction, position, normal, id, group, request_id}, reports a ray cast hit
- `trigger_event` - {enter, a, b}, reports interaction (enter/exit) between a trigger collision object and another collision object
- `trigger_response` - {other_id, enter, other_group, own_group}, reports interaction (enter/exit) between a trigger collision object and another collision object

### Component properties
- `angular_damping` (number) - collision object angular damping
- `angular_velocity` (vector3) - collision object angular velocity
- `linear_damping` (number) - collision object linear damping
- `linear_velocity` (vector3) - collision object linear velocity
- `mass` (number) - collision object mass

### Examples

Example for physics.get_gravity():
```lua
function init(self)
    local gravity = physics.get_gravity()
    -- Inverse gravity!
    gravity = -gravity
    physics.set_gravity(gravity)
end
```

How to perform a ray cast synchronously:
```lua
function init(self)
    self.groups = {hash("world"), hash("enemy")}
end

function update(self, dt)
    -- request ray cast
    local result = physics.raycast(from, to, self.groups, {all=true})
    if result ~= nil then
        -- act on the hit (see 'ray_cast_response')
        for _,result in ipairs(results) do
            handle_result(result)
        end
    end
end
```

How to perform a ray cast asynchronously:
```lua
function init(self)
    self.my_groups = {hash("my_group1"), hash("my_group2")}
end

function update(self, dt)
    -- request ray cast
    physics.raycast_async(my_start, my_end, self.my_groups)
end

function on_message(self, message_id, message, sender)
    -- check for the response
    if message_id == hash("ray_cast_response") then
        -- act on the hit
    elseif message_id == hash("ray_cast_missed") then
        -- act on the miss
    end
end
```

Example for physics.set_event_listener(callback):
```lua
local function physics_world_listener(self, events)
  for _,event in ipairs(events):
      local event_type = event['type']
      if event_type == hash("contact_point_event") then
          pprint(event)
          -- {
          --  distance = 2.1490633487701,
          --  applied_impulse = 0
          --  a = { --[[0x113f7c6c0]]
          --    group = hash: [box],
          --    id = hash: [/box]
          --    mass = 0,
          --    normal = vmath.vector3(0.379, 0.925, -0),
          --    position = vmath.vector3(517.337, 235.068, 0),
          --    instance_position = vmath.vector3(480, 144, 0),
          --    relative_velocity = vmath.vector3(-0, -0, -0),
          --  },
          --  b = { --[[0x113f7c840]]
          --    group = hash: [circle],
          --    id = hash: [/circle]
          --    mass = 0,
          --    normal = vmath.vector3(-0.379, -0.925, 0),
          --    position = vmath.vector3(517.337, 235.068, 0),
          --    instance_position = vmath.vector3(-0.0021, 0, -0.0022),
          --    relative_velocity = vmath.vector3(0, 0, 0),
          --  },
          -- }
      elseif event == hash("collision_event") then
          pprint(event)
          -- {
          --  a = {
          --          group = hash: [default],
          --          position = vmath.vector3(183, 666, 0),
          --          id = hash: [/go1]
          --      },
          --  b = {
          --          group = hash: [default],
          --          position = vmath.vector3(185, 704.05865478516, 0),
          --          id = hash: [/go2]
          --      }
          -- }
      elseif event ==  hash("trigger_event") then
          pprint(event)
          -- {
          --  enter = true,
          --  b = {
          --      group = hash: [default],
          --      id = hash: [/go2]
          --  },
          --  a = {
          --      group = hash: [default],
          --      id = hash: [/go1]
          --  }
          -- },
      elseif event ==  hash("ray_cast_response") then
          pprint(event)
          --{
          --  group = hash: [default],
          --  request_id = 0,
          --  position = vmath.vector3(249.92222595215, 249.92222595215, 0),
          --  fraction = 0.68759721517563,
          --  normal = vmath.vector3(0, 1, 0),
          --  id = hash: [/go]
          -- }
      elseif event ==  hash("ray_cast_missed") then
          pprint(event)
          -- {
          --  request_id = 0
          --},
      end
end

function init(self)
    physics.set_event_listener(physics_world_listener)
end
```

Example for physics.set_gravity(gravity):
```lua
function init(self)
    -- Set "upside down" gravity for this collection.
    physics.set_gravity(vmath.vector3(0, 10.0, 0))
end
```

Example for physics.set_hflip(url, flip):
```lua
function init(self)
    self.fliph = true -- set on some condition
    physics.set_hflip("#collisionobject", self.fliph)
end
```

Example for physics.set_vflip(url, flip):
```lua
function init(self)
    self.flipv = true -- set on some condition
    physics.set_vflip("#collisionobject", self.flipv)
end
```

Example for physics.update_mass(collisionobject, mass):
```lua
 physics.update_mass("#collisionobject", 14)
```


## Crash API documentation
Native crash logging functions and constants.

```lua
-- Functions
crash.get_backtrace(handle) -- read backtrace recorded in a loaded crash dump
crash.get_extra_data(handle) -- read text blob recorded in a crash dump
crash.get_modules(handle) -- get all loaded modules from when the crash occured
crash.get_signum(handle) -- read signal number from a crash report
crash.get_sys_field(handle, index) -- reads a system field from a loaded crash dump
crash.get_user_field(handle, index) -- reads user field from a loaded crash dump
crash.load_previous() -- loads a previously written crash dump
crash.release(handle) -- releases a previously loaded crash dump
crash.set_file_path(path) -- sets the file location for crash dumps
crash.set_user_field(index, value) -- stores user-defined string value
crash.write_dump() -- writes crash dump

-- Constants
crash.SYSFIELD_ANDROID_BUILD_FINGERPRINT -- android build fingerprint
crash.SYSFIELD_DEVICE_LANGUAGE -- system device language as reported by sys.get_sys_info
crash.SYSFIELD_DEVICE_MODEL -- device model as reported by sys.get_sys_info
crash.SYSFIELD_ENGINE_HASH -- engine version as hash
crash.SYSFIELD_ENGINE_VERSION -- engine version as release number
crash.SYSFIELD_LANGUAGE -- system language as reported by sys.get_sys_info
crash.SYSFIELD_MANUFACTURER -- device manufacturer as reported by sys.get_sys_info
crash.SYSFIELD_MAX -- The max number of sysfields.
crash.SYSFIELD_SYSTEM_NAME -- system name as reported by sys.get_sys_info
crash.SYSFIELD_SYSTEM_VERSION -- system version as reported by sys.get_sys_info
crash.SYSFIELD_TERRITORY -- system territory as reported by sys.get_sys_info
crash.USERFIELD_MAX -- The max number of user fields.
crash.USERFIELD_SIZE -- The max size of a single user field.
```

## Editor scripting documentation
Editor scripting documentation

```lua
-- Functions
editor.bob([options], [...commands]) -- run bob the builder program
editor.browse(url) -- open a URL in the default browser or a registered application
editor.bundle.assoc(table, key, value) -- immutably set a key to value in a table
editor.bundle.assoc_in(table, keys, value) -- immutably set a value to a nested path in a table
editor.bundle.check_box(config, set_config, key, text, [rest_props]) -- helper function for creating a check box component
editor.bundle.check_boxes_grid_row(config, set_config) -- create a grid row for the common boolean settings
editor.bundle.command(label, id, fn, [rest]) -- create bundle command definition
editor.bundle.common_variant_grid_row(config, set_config) -- create a grid row for the common variant setting
editor.bundle.config(requested_dialog, prefs_key, dialog_component, [errors_fn]) -- get bundle config, optionally showing a dialog to edit the config
editor.bundle.config_schema(variant_schema, [properties]) -- helper function for constructing prefs schema for new bundle dialogs
editor.bundle.create(config, output_directory, extra_bob_opts) -- create bob bundle
editor.bundle.desktop_variant_grid_row(config, set_config) -- create a grid row for the desktop variant setting
editor.bundle.dialog(heading, config, hint, error, rows) -- helper function for creating a bundle dialog component
editor.bundle.external_file_field(config, set_config, key, [error], [rest_props]) -- helper function for creating an external file field component
editor.bundle.grid_row(text, content) -- return a 2-element array that represents a single grid row in a bundle dialog
editor.bundle.make_to_string_lookup(table) -- make stringifier function that first performs the label lookup in a provided table
editor.bundle.output_directory(requested_dialog, output_subdir) -- get bundle output directory, optionally showing a directory selection dialog
editor.bundle.select_box(config, set_config, key, options, to_string, [rest_props]) -- helper function for creating a select box component
editor.bundle.set_element_check_box(config, set_config, key, element, text, [error]) -- helper function for creating a check box for an enum value of set config key
editor.bundle.texture_compression_grid_row(config, set_config) -- create a grid row for the texture compression setting
editor.can_get(node, property) -- check if you can get this property so <code>editor.get()</code> won't throw an error
editor.can_set(node, property) -- check if <code>"set"</code> action with this property won't throw an error
editor.create_directory(resource_path) -- create a directory if it does not exist, and all non-existent parent directories.
editor.delete_directory(resource_path) -- delete a directory if it exists, and all existent child directories and files.
editor.execute(command, [...], [options]) -- execute a shell command.
editor.external_file_attributes(path) -- query information about file system path
editor.get(node, property) -- get a value of a node property inside the editor.
editor.open_external_file(path) -- open a file in a registered application
editor.prefs.get(key) -- get preference value
editor.prefs.is_set(key) -- check if preference value is explicitly set
editor.prefs.schema.array(opts) -- array schema
editor.prefs.schema.boolean([opts]) -- boolean schema
editor.prefs.schema.enum(opts) -- enum value schema
editor.prefs.schema.integer([opts]) -- integer schema
editor.prefs.schema.keyword([opts]) -- keyword schema
editor.prefs.schema.number([opts]) -- floating-point number schema
editor.prefs.schema.object(opts) -- heterogeneous object schema
editor.prefs.schema.object_of(opts) -- homogeneous object schema
editor.prefs.schema.set(opts) -- set schema
editor.prefs.schema.string([opts]) -- string schema
editor.prefs.schema.tuple(opts) -- tuple schema
editor.prefs.set(key, value) -- set preference value
editor.resource_attributes(resource_path) -- query information about a project resource
editor.save() -- persist any unsaved changes to disk
editor.transact(txs) -- change the editor state in a single, undoable transaction
editor.tx.set(node, property, value) -- create a set transaction step.
editor.ui.button(props) -- button with a label and/or an icon
editor.ui.check_box(props) -- check box with a label
editor.ui.component(fn) -- convert a function to a UI component.
editor.ui.dialog(props) -- dialog component, a top-level window component that can't be used as a child of other components
editor.ui.dialog_button(props) -- dialog button shown in the footer of a dialog
editor.ui.external_file_field(props) -- input component for selecting files from the file system
editor.ui.grid(props) -- layout container that places its children in a 2D grid
editor.ui.heading(props) -- a text heading
editor.ui.horizontal(props) -- layout container that places its children in a horizontal row one after another
editor.ui.icon(props) -- an icon from a predefined set
editor.ui.integer_field(props) -- integer input component based on a text field, reports changes on commit (<code>Enter</code> or focus loss)
editor.ui.label(props) -- label intended for use with input components
editor.ui.number_field(props) -- number input component based on a text field, reports changes on commit (<code>Enter</code> or focus loss)
editor.ui.open_resource(resource_path) -- open a resource, either in the editor or in a third-party app
editor.ui.paragraph(props) -- a paragraph of text
editor.ui.resource_field(props) -- input component for selecting project resources
editor.ui.scroll(props) -- layout container that optionally shows scroll bars if child contents overflow the assigned bounds
editor.ui.select_box(props) -- dropdown select box with an array of options
editor.ui.separator(props) -- thin line for visual content separation, by default horizontal and aligned to center
editor.ui.show_dialog(dialog) -- show a modal dialog and await a result
editor.ui.show_external_directory_dialog([opts]) -- show a modal OS directory selection dialog and await a result
editor.ui.show_external_file_dialog([opts]) -- show a modal OS file selection dialog and await a result
editor.ui.show_resource_dialog([opts]) -- show a modal resource selection dialog and await a result
editor.ui.string_field(props) -- string input component based on a text field, reports changes on commit (<code>Enter</code> or focus loss)
editor.ui.use_memo(compute, [...]) -- a hook that caches the result of a computation between re-renders.
editor.ui.use_state(init, [...]) -- a hook that adds local state to the component.
editor.ui.vertical(props) -- layout container that places its children in a vertical column one after another
http.request(url, [opts]) -- perform an HTTP request
http.server.external_file_response(path, [status], [headers]) -- create HTTP response that will stream the content of a file defined by the path
http.server.json_response(value, [status], [headers]) -- create HTTP response with a JSON value
http.server.resource_response(resource_path, [status], [headers]) -- create HTTP response that will stream the content of a resource defined by the resource path
http.server.response([status], [headers], [body]) -- create HTTP response
http.server.route(path, [method], [as], handler) -- create route definition for the editor's HTTP server
json.decode(json, [options]) -- decode JSON string to Lua value
json.encode(value) -- encode Lua value to JSON string
pprint(value) -- pretty-print a Lua value
zip.pack(output_path, [opts], entries) -- create a ZIP archive

-- Constants
editor.bundle.abort_message -- error message the signifies bundle abort that is not an error
editor.bundle.common_variant_schema -- prefs schema for common bundle variants
editor.bundle.desktop_variant_schema -- prefs schema for desktop bundle variants
editor.editor_sha1 -- a string, SHA1 of Defold editor
editor.engine_sha1 -- a string, SHA1 of Defold engine
editor.platform -- editor platform id.
editor.prefs.SCOPE.GLOBAL -- <code>"global"</code>
editor.prefs.SCOPE.PROJECT -- <code>"project"</code>
editor.ui.ALIGNMENT.BOTTOM -- <code>"bottom"</code>
editor.ui.ALIGNMENT.BOTTOM_LEFT -- <code>"bottom-left"</code>
editor.ui.ALIGNMENT.BOTTOM_RIGHT -- <code>"bottom-right"</code>
editor.ui.ALIGNMENT.CENTER -- <code>"center"</code>
editor.ui.ALIGNMENT.LEFT -- <code>"left"</code>
editor.ui.ALIGNMENT.RIGHT -- <code>"right"</code>
editor.ui.ALIGNMENT.TOP -- <code>"top"</code>
editor.ui.ALIGNMENT.TOP_LEFT -- <code>"top-left"</code>
editor.ui.ALIGNMENT.TOP_RIGHT -- <code>"top-right"</code>
editor.ui.COLOR.ERROR -- <code>"error"</code>
editor.ui.COLOR.HINT -- <code>"hint"</code>
editor.ui.COLOR.OVERRIDE -- <code>"override"</code>
editor.ui.COLOR.TEXT -- <code>"text"</code>
editor.ui.COLOR.WARNING -- <code>"warning"</code>
editor.ui.HEADING_STYLE.DIALOG -- <code>"dialog"</code>
editor.ui.HEADING_STYLE.FORM -- <code>"form"</code>
editor.ui.HEADING_STYLE.H1 -- <code>"h1"</code>
editor.ui.HEADING_STYLE.H2 -- <code>"h2"</code>
editor.ui.HEADING_STYLE.H3 -- <code>"h3"</code>
editor.ui.HEADING_STYLE.H4 -- <code>"h4"</code>
editor.ui.HEADING_STYLE.H5 -- <code>"h5"</code>
editor.ui.HEADING_STYLE.H6 -- <code>"h6"</code>
editor.ui.ICON.CLEAR -- <code>"clear"</code>
editor.ui.ICON.MINUS -- <code>"minus"</code>
editor.ui.ICON.OPEN_RESOURCE -- <code>"open-resource"</code>
editor.ui.ICON.PLUS -- <code>"plus"</code>
editor.ui.ISSUE_SEVERITY.ERROR -- <code>"error"</code>
editor.ui.ISSUE_SEVERITY.WARNING -- <code>"warning"</code>
editor.ui.ORIENTATION.HORIZONTAL -- <code>"horizontal"</code>
editor.ui.ORIENTATION.VERTICAL -- <code>"vertical"</code>
editor.ui.PADDING.LARGE -- <code>"large"</code>
editor.ui.PADDING.MEDIUM -- <code>"medium"</code>
editor.ui.PADDING.NONE -- <code>"none"</code>
editor.ui.PADDING.SMALL -- <code>"small"</code>
editor.ui.SPACING.LARGE -- <code>"large"</code>
editor.ui.SPACING.MEDIUM -- <code>"medium"</code>
editor.ui.SPACING.NONE -- <code>"none"</code>
editor.ui.SPACING.SMALL -- <code>"small"</code>
editor.ui.TEXT_ALIGNMENT.CENTER -- <code>"center"</code>
editor.ui.TEXT_ALIGNMENT.JUSTIFY -- <code>"justify"</code>
editor.ui.TEXT_ALIGNMENT.LEFT -- <code>"left"</code>
editor.ui.TEXT_ALIGNMENT.RIGHT -- <code>"right"</code>
editor.version -- a string, version name of Defold
http.server.local_url -- editor's HTTP server local url
http.server.port -- editor's HTTP server port
http.server.url -- editor's HTTP server url
zip.METHOD.DEFLATED -- <code>"deflated"</code> compression method
zip.METHOD.STORED -- <code>"stored"</code> compression method, i.e. no compression
```

### Examples

Print help in the console:
```lua
editor.bob({help = true})
```

Bundle the game for the host platform:
```lua
local opts = {
    archive = true,
    platform = editor.platform
}
editor.bob(opts, "distclean", "resolve", "build", "bundle")
```

Using snake_cased and repeated options:
```lua
local opts = {
    archive = true,
    platform = editor.platform,
    build_server = "https://build.my-company.com",
    settings = {"test.ini", "headless.ini"}
}
editor.bob(opts, "distclean", "resolve", "build")
```

Example for editor.create_directory(resource_path):
```lua
editor.create_directory("/assets/gen")
```

Example for editor.delete_directory(resource_path):
```lua
editor.delete_directory("/assets/gen")
```

Make a directory with spaces in it:
```lua
editor.execute("mkdir", "new dir")
```

Read the git status:
```lua
local status = editor.execute("git", "status", "--porcelain", {
  reload_resources = false,
  out = "capture"
})
```

local function increment(n)
    return n + 1
end

local function make_listener(set_count)
    return function()
        set_count(increment)
    end
end

local counter_button = editor.ui.component(function(props)
    local count, set_count = editor.ui.use_state(props.count)
    local on_pressed = editor.ui.use_memo(make_listener, set_count)
    return editor.ui.text_button {
        text = tostring(count),
        on_pressed = on_pressed
    }
end)

local function increment(n)
  return n + 1
end

local counter_button = editor.ui.component(function(props)
  local count, set_count = editor.ui.use_state(props.count)
  return editor.ui.text_button {
    text = tostring(count),
    on_pressed = function()
      set_count(increment)
    end
  }
end)

Receive JSON and respond with JSON:
```lua
http.server.route(
  "/json", "POST", "json",
  function(request)
    pprint(request.body)
    return 200
  end
)
```

Extract parts of the path:
```lua
http.server.route(
  "/users/{user}/orders",
  function(request)
    print(request.user)
  end
)
```

Simple file server:
```lua
http.server.route(
  "/files/{*file}",
  function(request)
    local attrs = editor.external_file_attributes(request.file)
    if attrs.is_file then
      return http.server.external_file_response(request.file)
    elseif attrs.is_directory then
      return 400
    else
      return 404
    end
  end
)
```

Archive a file and a folder:
```lua
zip.pack("build.zip", {"build", "game.project"})
```

Change the location of the files within the archive:
```lua
zip.pack("build.zip", {
  {"build/wasm-web", "."},
  {"configs/prod.json", "config.json"}
})
```

Create archive without compression (much faster to create the archive, bigger archive file size, allows mmap access):
```lua
zip.pack("build.zip", {method = zip.METHOD.STORED}, {
  "build",
  "resources"
})
```

Don't compress one of the folders:
```lua
zip.pack("build.zip", {
  {"assets", method = zip.METHOD.STORED},
  "build/wasm-web"
})
```

Include files from outside the project:
```lua
zip.pack("build.zip", {
  "build",
  {"../secrets/auth-key.txt", "auth-key.txt"}
})
```


## Engine runtime documentation
Engine runtime documentation

```lua
```

### Macros
- `--config=`, override game property
- `--verify-graphics-calls=`, disables OpenGL error checking
- `DM_LOG_PORT`, sets the logging port
- `DM_QUIT_ON_ESC`, enables quit on escape key
- `DM_SAVE_HOME`, override the save directory
- `DM_SERVICE_PORT`, set the engine service port
- `launch_project`, launch with a specific project

## Factory API documentation
Functions for controlling factory components which are used to
dynamically spawn game objects into the runtime.

```lua
-- Functions
factory.create(url, [position], [rotation], [properties], [scale]) -- make a factory create a new game object
factory.get_status([url]) -- Get factory status
factory.load([url], [complete_function]) -- Load resources of a factory prototype.
factory.set_prototype([url], [prototype]) -- changes the prototype for the factory
factory.unload([url]) -- Unload resources previously loaded using factory.load

-- Constants
factory.STATUS_LOADED -- loaded
factory.STATUS_LOADING -- loading
factory.STATUS_UNLOADED -- unloaded
```

### Examples

How to create a new game object:
```lua
function init(self)
    -- create a new game object and provide property values
    self.my_created_object = factory.create("#factory", nil, nil, {my_value = 1})
    -- communicate with the object
    msg.post(self.my_created_object, "hello")
end
```

And then let the new game object have a script attached:
```lua
go.property("my_value", 0)

function init(self)
    -- do something with self.my_value which is now one
end
```

How to load resources of a factory prototype.
```lua
factory.load("#factory", function(self, url, result) end)
```

How to unload the previous prototypes resources, and then spawn a new game object
```lua
factory.unload("#factory") -- unload the previous resources
factory.set_prototype("#factory", "/main/levels/enemyA.goc")
local id = factory.create("#factory", go.get_world_position(), vmath.quat())
```

How to unload resources of a factory prototype loaded with factory.load
```lua
factory.unload("#factory")
```


## Game object API documentation
Functions, core hooks, messages and constants for manipulation of
game objects. The "go" namespace is accessible from game object script
files.

```lua
-- Functions
final(self) -- called when a script component is finalized
fixed_update(self, dt) -- called at fixed intervals to update the script component
go.animate(url, property, playback, to, easing, duration, [delay], [complete_function]) -- animates a named property of the specified game object or component
go.cancel_animations(url, [property]) -- cancels all or specified property animations of the game object or component
go.delete([id], [recursive]) -- delete one or more game object instances
go.exists(url) -- check if the specified game object exists
go.get(url, property, [options]) -- gets a named property of the specified game object or component
go.get_id([path]) -- gets the id of an instance
go.get_parent([id]) -- get the parent for a specific game object instance
go.get_position([id]) -- gets the position of a game object instance
go.get_rotation([id]) -- gets the rotation of the game object instance
go.get_scale([id]) -- gets the 3D scale factor of the game object instance
go.get_scale_uniform([id]) -- gets the uniform scale factor of the game object instance
go.get_world_position([id]) -- gets the game object instance world position
go.get_world_rotation([id]) -- gets the game object instance world rotation
go.get_world_scale([id]) -- gets the game object instance world 3D scale factor
go.get_world_scale_uniform([id]) -- gets the uniform game object instance world scale factor
go.get_world_transform([id]) -- gets the game object instance world transform matrix
go.property(name, value) -- define a property for the script
go.set(url, property, value, [options]) -- sets a named property of the specified game object or component, or a material constant
go.set_parent([id], [parent_id], [keep_world_transform]) -- sets the parent for a specific game object instance
go.set_position(position, [id]) -- sets the position of the game object instance
go.set_rotation(rotation, [id]) -- sets the rotation of the game object instance
go.set_scale(scale, [id]) -- sets the scale factor of the game object instance
go.world_to_local_position(position, url) -- convert position to game object's coordinate space
go.world_to_local_transform(transformation, url) -- convert transformation matrix to game object's coordinate space
init(self) -- called when a script component is initialized
on_input(self, action_id, action) -- called when user input is received
on_message(self, message_id, message, sender) -- called when a message has been sent to the script component
on_reload(self) -- called when the script component is reloaded
update(self, dt) -- called every frame to update the script component

-- Constants
go.EASING_INBACK -- in-back
go.EASING_INBOUNCE -- in-bounce
go.EASING_INCIRC -- in-circlic
go.EASING_INCUBIC -- in-cubic
go.EASING_INELASTIC -- in-elastic
go.EASING_INEXPO -- in-exponential
go.EASING_INOUTBACK -- in-out-back
go.EASING_INOUTBOUNCE -- in-out-bounce
go.EASING_INOUTCIRC -- in-out-circlic
go.EASING_INOUTCUBIC -- in-out-cubic
go.EASING_INOUTELASTIC -- in-out-elastic
go.EASING_INOUTEXPO -- in-out-exponential
go.EASING_INOUTQUAD -- in-out-quadratic
go.EASING_INOUTQUART -- in-out-quartic
go.EASING_INOUTQUINT -- in-out-quintic
go.EASING_INOUTSINE -- in-out-sine
go.EASING_INQUAD -- in-quadratic
go.EASING_INQUART -- in-quartic
go.EASING_INQUINT -- in-quintic
go.EASING_INSINE -- in-sine
go.EASING_LINEAR -- linear interpolation
go.EASING_OUTBACK -- out-back
go.EASING_OUTBOUNCE -- out-bounce
go.EASING_OUTCIRC -- out-circlic
go.EASING_OUTCUBIC -- out-cubic
go.EASING_OUTELASTIC -- out-elastic
go.EASING_OUTEXPO -- out-exponential
go.EASING_OUTINBACK -- out-in-back
go.EASING_OUTINBOUNCE -- out-in-bounce
go.EASING_OUTINCIRC -- out-in-circlic
go.EASING_OUTINCUBIC -- out-in-cubic
go.EASING_OUTINELASTIC -- out-in-elastic
go.EASING_OUTINEXPO -- out-in-exponential
go.EASING_OUTINQUAD -- out-in-quadratic
go.EASING_OUTINQUART -- out-in-quartic
go.EASING_OUTINQUINT -- out-in-quintic
go.EASING_OUTINSINE -- out-in-sine
go.EASING_OUTQUAD -- out-quadratic
go.EASING_OUTQUART -- out-quartic
go.EASING_OUTQUINT -- out-quintic
go.EASING_OUTSINE -- out-sine
go.PLAYBACK_LOOP_BACKWARD -- loop backward
go.PLAYBACK_LOOP_FORWARD -- loop forward
go.PLAYBACK_LOOP_PINGPONG -- ping pong loop
go.PLAYBACK_NONE -- no playback
go.PLAYBACK_ONCE_BACKWARD -- once backward
go.PLAYBACK_ONCE_FORWARD -- once forward
go.PLAYBACK_ONCE_PINGPONG -- once ping pong
```

### Component messages
- `acquire_input_focus` - acquires the user input focus
- `disable` - disables the receiving component
- `enable` - enables the receiving component
- `release_input_focus` - releases the user input focus
- `set_parent` - {parent_id, keep_world_transform}, sets the parent of the receiving instance

### Component properties
- `euler` (vector3) - game object euler rotation
- `position` (vector3) - game object position
- `rotation` (quaternion) - game object rotation
- `scale` (number) - game object scale

### Examples

Example for final(self):
```lua
function final(self)
    -- report finalization
    msg.post("my_friend_instance", "im_dead", {my_stats = self.some_value})
end
```

Animate the position of a game object to x = 10 during 1 second, then y = 20 during 1 second:
```lua
local function x_done(self, url, property)
    go.animate(go.get_id(), "position.y", go.PLAYBACK_ONCE_FORWARD, 20, go.EASING_LINEAR, 1)
end

function init(self)
    go.animate(go.get_id(), "position.x", go.PLAYBACK_ONCE_FORWARD, 10, go.EASING_LINEAR, 1, 0, x_done)
end
```

Animate the y position of a game object using a crazy custom easing curve:
```lua
local values = { 0, 0, 0, 0, 0, 0, 0, 0,
                 1, 1, 1, 1, 1, 1, 1, 1,
                 0, 0, 0, 0, 0, 0, 0, 0,
                 1, 1, 1, 1, 1, 1, 1, 1,
                 0, 0, 0, 0, 0, 0, 0, 0,
                 1, 1, 1, 1, 1, 1, 1, 1,
                 0, 0, 0, 0, 0, 0, 0, 0,
                 1, 1, 1, 1, 1, 1, 1, 1 }
local vec = vmath.vector(values)
go.animate("go", "position.y", go.PLAYBACK_LOOP_PINGPONG, 100, vec, 2.0)
```

Cancel the animation of the position of a game object:
```lua
go.cancel_animations(go.get_id(), "position")
```

Cancel all property animations of the current game object:
```lua
go.cancel_animations(".")
```

Cancel all property animations of the sprite component of the current game object:
```lua
go.cancel_animations("#sprite")
```

This example demonstrates how to delete game objects
```lua
-- Delete the script game object
go.delete()
-- Delete a game object with the id "my_game_object".
local id = go.get_id("my_game_object") -- retrieve the id of the game object to be deleted
go.delete(id)
-- Delete a list of game objects.
local ids = { hash("/my_object_1"), hash("/my_object_2"), hash("/my_object_3") }
go.delete(ids)
```

This example demonstrates how to delete a game objects and their children (child to parent order)
```lua
-- Delete the script game object and it's children
go.delete(true)
-- Delete a game object with the id "my_game_object" and it's children.
local id = go.get_id("my_game_object") -- retrieve the id of the game object to be deleted
go.delete(id, true)
-- Delete a list of game objects and their children.
local ids = { hash("/my_object_1"), hash("/my_object_2"), hash("/my_object_3") }
go.delete(ids, true)
```

Check if game object "my_game_object" exists
```lua
go.exists("/my_game_object")
```

Get a named property
```lua
function init(self)
    -- get the resource of a certain gui font
    local font_hash = go.get("#gui", "fonts", {key = "system_font_BIG"})
end
```

For the instance with path /my_sub_collection/my_instance, the following calls are equivalent:
```lua
local id = go.get_id() -- no path, defaults to the instance containing the calling script
print(id) --> hash: [/my_sub_collection/my_instance]

local id = go.get_id("/my_sub_collection/my_instance") -- absolute path
print(id) --> hash: [/my_sub_collection/my_instance]

local id = go.get_id("my_instance") -- relative path
print(id) --> hash: [/my_sub_collection/my_instance]
```

Get parent of the instance containing the calling script:
```lua
local parent_id = go.get_parent()
```

Get parent of the instance with id "x":
```lua
local parent_id = go.get_parent("x")
```

Get the position of the game object instance the script is attached to:
```lua
local p = go.get_position()
```

Get the position of another game object instance "my_gameobject":
```lua
local pos = go.get_position("my_gameobject")
```

Get the rotation of the game object instance the script is attached to:
```lua
local r = go.get_rotation()
```

Get the rotation of another game object instance with id "x":
```lua
local r = go.get_rotation("x")
```

Get the scale of the game object instance the script is attached to:
```lua
local s = go.get_scale()
```

Get the scale of another game object instance with id "x":
```lua
local s = go.get_scale("x")
```

Get the scale of the game object instance the script is attached to:
```lua
local s = go.get_scale_uniform()
```

Get the uniform scale of another game object instance with id "x":
```lua
local s = go.get_scale_uniform("x")
```

Get the world position of the game object instance the script is attached to:
```lua
local p = go.get_world_position()
```

Get the world position of another game object instance with id "x":
```lua
local p = go.get_world_position("x")
```

Get the world rotation of the game object instance the script is attached to:
```lua
local r = go.get_world_rotation()
```

Get the world rotation of another game object instance with id "x":
```lua
local r = go.get_world_rotation("x")
```

Get the world 3D scale of the game object instance the script is attached to:
```lua
local s = go.get_world_scale()
```

Get the world scale of another game object instance "x":
```lua
local s = go.get_world_scale("x")
```

Get the world scale of the game object instance the script is attached to:
```lua
local s = go.get_world_scale_uniform()
```

Get the world scale of another game object instance with id "x":
```lua
local s = go.get_world_scale_uniform("x")
```

Get the world transform of the game object instance the script is attached to:
```lua
local m = go.get_world_transform()
```

Get the world transform of another game object instance with id "x":
```lua
local m = go.get_world_transform("x")
```

This example demonstrates how to define a property called "health" in a script.
The health is decreased whenever someone sends a message called "take_damage" to the script.
```lua
go.property("health", 100)

function init(self)
    -- prints 100 to the output
    print(self.health)
end

function on_message(self, message_id, message, sender)
    if message_id == hash("take_damage") then
        self.health = self.health - message.damage
        print("Ouch! My health is now: " .. self.health)
    end
end
```

Set a named property
```lua
go.property("big_font", resource.font())

function init(self)
    go.set("#gui", "fonts", self.big_font, {key = "system_font_BIG"})
end
```

Attach myself to another instance "my_parent":
```lua
go.set_parent(go.get_id(),go.get_id("my_parent"))
```

Attach an instance "my_instance" to another instance "my_parent":
```lua
go.set_parent(go.get_id("my_instance"),go.get_id("my_parent"))
```

Detach an instance "my_instance" from its parent (if any):
```lua
go.set_parent(go.get_id("my_instance"))
```

Set the position of the game object instance the script is attached to:
```lua
local p = ...
go.set_position(p)
```

Set the position of another game object instance with id "x":
```lua
local p = ...
go.set_position(p, "x")
```

Set the rotation of the game object instance the script is attached to:
```lua
local r = ...
go.set_rotation(r)
```

Set the rotation of another game object instance with id "x":
```lua
local r = ...
go.set_rotation(r, "x")
```

Set the scale of the game object instance the script is attached to:
```lua
local s = vmath.vector3(2.0, 1.0, 1.0)
go.set_scale(s)
```

Set the scale of another game object instance with id "x":
```lua
local s = 1.2
go.set_scale(s, "x")
```

Convert position of "test" game object into coordinate space of "child" object.
```lua
  local test_pos = go.get_world_position("/test")
  local child_pos = go.get_world_position("/child")
  local new_position = go.world_to_local_position(test_pos, "/child")
```

Convert transformation of "test" game object into coordinate space of "child" object.
```lua
   local test_transform = go.get_world_transform("/test")
   local child_transform = go.get_world_transform("/child")
   local result_transform = go.world_to_local_transform(test_transform, "/child")
```

Example for init(self):
```lua
function init(self)
    -- set up useful data
    self.my_value = 1
end
```

This example demonstrates how a game object instance can be moved as a response to user input.
```lua
function init(self)
    -- acquire input focus
    msg.post(".", "acquire_input_focus")
    -- maximum speed the instance can be moved
    self.max_speed = 2
    -- velocity of the instance, initially zero
    self.velocity = vmath.vector3()
end

function update(self, dt)
    -- move the instance
    go.set_position(go.get_position() + dt * self.velocity)
end

function on_input(self, action_id, action)
    -- check for movement input
    if action_id == hash("right") then
        if action.released then -- reset velocity if input was released
            self.velocity = vmath.vector3()
        else -- update velocity
            self.velocity = vmath.vector3(action.value * self.max_speed, 0, 0)
        end
    end
end
```

This example demonstrates how a game object instance, called "a", can communicate with another instance, called "b". It
is assumed that both script components of the instances has id "script".
Script of instance "a":
```lua
function init(self)
    -- let b know about some important data
    msg.post("b#script", "my_data", {important_value = 1})
end
```

Script of instance "b":
```lua
function init(self)
    -- store the url of instance "a" for later use, by specifying nil as socket we
    -- automatically use our own socket
    self.a_url = msg.url(nil, go.get_id("a"), "script")
end

function on_message(self, message_id, message, sender)
    -- check message and sender
    if message_id == hash("my_data") and sender == self.a_url then
        -- use the data in some way
        self.important_value = message.important_value
    end
end
```

This example demonstrates how to tweak the speed of a game object instance that is moved on user input.
```lua
function init(self)
    -- acquire input focus
    msg.post(".", "acquire_input_focus")
    -- maximum speed the instance can be moved, this value is tweaked in the on_reload function below
    self.max_speed = 2
    -- velocity of the instance, initially zero
    self.velocity = vmath.vector3()
end

function update(self, dt)
    -- move the instance
    go.set_position(go.get_position() + dt * self.velocity)
end

function on_input(self, action_id, action)
    -- check for movement input
    if action_id == hash("right") then
        if action.released then -- reset velocity if input was released
            self.velocity = vmath.vector3()
        else -- update velocity
            self.velocity = vmath.vector3(action.value * self.max_speed, 0, 0)
        end
    end
end

function on_reload(self)
    -- edit this value and reload the script component
    self.max_speed = 100
end
```

This example demonstrates how to move a game object instance through the script component:
```lua
function init(self)
    -- set initial velocity to be 1 along world x-axis
    self.my_velocity = vmath.vector3(1, 0, 0)
end

function update(self, dt)
    -- move the game object instance
    go.set_position(go.get_position() + dt * self.my_velocity)
end
```


## Graphics API documentation
Graphics functions and constants.

```lua
-- Constants
graphics.BLEND_FACTOR_CONSTANT_ALPHA
graphics.BLEND_FACTOR_CONSTANT_COLOR
graphics.BLEND_FACTOR_DST_ALPHA
graphics.BLEND_FACTOR_DST_COLOR
graphics.BLEND_FACTOR_ONE
graphics.BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA
graphics.BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR
graphics.BLEND_FACTOR_ONE_MINUS_DST_ALPHA
graphics.BLEND_FACTOR_ONE_MINUS_DST_COLOR
graphics.BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
graphics.BLEND_FACTOR_ONE_MINUS_SRC_COLOR
graphics.BLEND_FACTOR_SRC_ALPHA
graphics.BLEND_FACTOR_SRC_ALPHA_SATURATE
graphics.BLEND_FACTOR_SRC_COLOR
graphics.BLEND_FACTOR_ZERO
graphics.BUFFER_TYPE_COLOR0_BIT
graphics.BUFFER_TYPE_COLOR1_BIT -- May be nil if multitarget rendering isn't supporte...
graphics.BUFFER_TYPE_COLOR2_BIT -- May be nil if multitarget rendering isn't supporte...
graphics.BUFFER_TYPE_COLOR3_BIT -- May be nil if multitarget rendering isn't supporte...
graphics.BUFFER_TYPE_DEPTH_BIT
graphics.BUFFER_TYPE_STENCIL_BIT
graphics.COMPARE_FUNC_ALWAYS
graphics.COMPARE_FUNC_EQUAL
graphics.COMPARE_FUNC_GEQUAL
graphics.COMPARE_FUNC_GREATER
graphics.COMPARE_FUNC_LEQUAL
graphics.COMPARE_FUNC_LESS
graphics.COMPARE_FUNC_NEVER
graphics.COMPARE_FUNC_NOTEQUAL
graphics.COMPRESSION_TYPE_BASIS_ETC1S
graphics.COMPRESSION_TYPE_BASIS_UASTC
graphics.COMPRESSION_TYPE_DEFAULT
graphics.COMPRESSION_TYPE_WEBP
graphics.COMPRESSION_TYPE_WEBP_LOSSY
graphics.FACE_TYPE_BACK
graphics.FACE_TYPE_FRONT
graphics.FACE_TYPE_FRONT_AND_BACK
graphics.STATE_ALPHA_TEST
graphics.STATE_ALPHA_TEST_SUPPORTED
graphics.STATE_BLEND
graphics.STATE_CULL_FACE
graphics.STATE_DEPTH_TEST
graphics.STATE_POLYGON_OFFSET_FILL
graphics.STATE_SCISSOR_TEST
graphics.STATE_STENCIL_TEST
graphics.STENCIL_OP_DECR
graphics.STENCIL_OP_DECR_WRAP
graphics.STENCIL_OP_INCR
graphics.STENCIL_OP_INCR_WRAP
graphics.STENCIL_OP_INVERT
graphics.STENCIL_OP_KEEP
graphics.STENCIL_OP_REPLACE
graphics.STENCIL_OP_ZERO
graphics.TEXTURE_FILTER_DEFAULT
graphics.TEXTURE_FILTER_LINEAR
graphics.TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR
graphics.TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST
graphics.TEXTURE_FILTER_NEAREST
graphics.TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR
graphics.TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST
graphics.TEXTURE_FORMAT_BGRA8U -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_DEPTH
graphics.TEXTURE_FORMAT_LUMINANCE -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_LUMINANCE_ALPHA -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_R16F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_R32F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_R32UI -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_R_BC4 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_R_ETC2 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RG16F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RG32F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RG_BC5 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RG_ETC2 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB16F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB32F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB_16BPP -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB_BC1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB_ETC1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB_PVRTC_2BPPV1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGB_PVRTC_4BPPV1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA16F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA32F -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA32UI -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_16BPP -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_ASTC_4x4 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_BC3 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_BC7 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_ETC2 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_PVRTC_2BPPV1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_RGBA_PVRTC_4BPPV1 -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_FORMAT_STENCIL
graphics.TEXTURE_TYPE_2D
graphics.TEXTURE_TYPE_2D_ARRAY
graphics.TEXTURE_TYPE_3D -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_TYPE_CUBE_MAP
graphics.TEXTURE_TYPE_IMAGE_2D
graphics.TEXTURE_TYPE_IMAGE_3D -- May be nil if the graphics driver doesn't support ...
graphics.TEXTURE_USAGE_FLAG_COLOR
graphics.TEXTURE_USAGE_FLAG_INPUT
graphics.TEXTURE_USAGE_FLAG_MEMORYLESS
graphics.TEXTURE_USAGE_FLAG_SAMPLE
graphics.TEXTURE_USAGE_FLAG_STORAGE
graphics.TEXTURE_WRAP_CLAMP_TO_BORDER
graphics.TEXTURE_WRAP_CLAMP_TO_EDGE
graphics.TEXTURE_WRAP_MIRRORED_REPEAT
graphics.TEXTURE_WRAP_REPEAT
```

## GUI API documentation
GUI core hooks, functions, messages, properties and constants for
creation and manipulation of GUI nodes. The "gui" namespace is
accessible only from gui scripts.

```lua
-- Functions
final(self) -- called when a gui component is finalized
gui.animate(node, property, to, easing, duration, [delay], [complete_function], [playback]) -- animates a node property
gui.cancel_animation(node, property) -- cancels an ongoing animation
gui.cancel_flipbook(node) -- cancel a node flipbook animation
gui.clone(node) -- clone a node
gui.clone_tree(node) -- clone a node including its children
gui.delete_node(node) -- deletes a node
gui.delete_texture(texture) -- delete texture
gui.get(node, property, [options]) -- gets the named property of a specified gui node
gui.get_adjust_mode(node) -- gets the node adjust mode
gui.get_alpha(node) -- gets the node alpha
gui.get_blend_mode(node) -- gets the node blend mode
gui.get_clipping_inverted(node) -- gets node clipping inverted state
gui.get_clipping_mode(node) -- gets the node clipping mode
gui.get_clipping_visible(node) -- gets node clipping visibility state
gui.get_color(node) -- gets the node color
gui.get_euler(node) -- gets the node rotation
gui.get_fill_angle(node) -- gets the angle for the filled pie sector
gui.get_flipbook(node) -- gets the node flipbook animation
gui.get_flipbook_cursor(node) -- gets the normalized cursor of the animation on a node with flipbook animation
gui.get_flipbook_playback_rate(node) -- gets the playback rate of the flipbook animation on a node
gui.get_font(node) -- gets the node font
gui.get_font_resource(font_name) -- gets the node font resource
gui.get_height() -- gets the scene height
gui.get_id(node) -- gets the id of the specified node
gui.get_index(node) -- gets the index of the specified node
gui.get_inherit_alpha(node) -- gets the node inherit alpha state
gui.get_inner_radius(node) -- gets the pie inner radius
gui.get_layer(node) -- gets the node layer
gui.get_layout() -- gets the scene current layout
gui.get_leading(node) -- gets the leading of the text node
gui.get_line_break(node) -- get line-break mode
gui.get_material(node) -- gets the assigned node material
gui.get_node(id) -- gets the node with the specified id
gui.get_outer_bounds(node) -- gets the pie outer bounds mode
gui.get_outline(node) -- gets the node outline color
gui.get_parent(node) -- gets the parent of the specified node
gui.get_particlefx(node) -- Gets a particle fx
gui.get_perimeter_vertices(node) -- gets the number of generated vertices around the perimeter
gui.get_pivot(node) -- gets the pivot of a node
gui.get_position(node) -- gets the node position
gui.get_rotation(node) -- gets the node rotation
gui.get_scale(node) -- gets the node scale
gui.get_screen_position(node) -- gets the node screen position
gui.get_shadow(node) -- gets the node shadow color
gui.get_size(node) -- gets the node size
gui.get_size_mode(node) -- gets the node size mode
gui.get_slice9(node) -- get the slice9 values for the node
gui.get_text(node) -- gets the node text
gui.get_texture(node) -- gets node texture
gui.get_tracking(node) -- gets the tracking of the text node
gui.get_tree(node) -- get a node including its children
gui.get_type(node) -- gets the node type
gui.get_visible(node) -- returns if a node is visible or not
gui.get_width() -- gets the scene width
gui.get_xanchor(node) -- gets the x-anchor of a node
gui.get_yanchor(node) -- gets the y-anchor of a node
gui.hide_keyboard() -- hides on-display keyboard if available
gui.is_enabled(node, [recursive]) -- returns if a node is enabled or not
gui.move_above(node, reference) -- moves the first node above the second
gui.move_below(node, reference) -- moves the first node below the second
gui.new_box_node(pos, size) -- creates a new box node
gui.new_particlefx_node(pos, particlefx) -- creates a new particle fx node
gui.new_pie_node(pos, size) -- creates a new pie node
gui.new_text_node(pos, text) -- creates a new text node
gui.new_texture(texture_id, width, height, type, buffer, flip) -- create new texture
gui.pick_node(node, x, y) -- determines if the node is pickable by the supplied coordinates
gui.play_flipbook(node, animation, [complete_function], [play_properties]) -- play node flipbook animation
gui.play_particlefx(node, [emitter_state_function]) -- Plays a particle fx
gui.reset_keyboard() -- resets on-display keyboard if available
gui.reset_material(node) -- resets the node material
gui.reset_nodes() -- resets all nodes to initial state
gui.screen_to_local(node, screen_position) -- convert screen position to the local node position
gui.set(node, property, value, [options]) -- sets the named property of a specified gui node
gui.set_adjust_mode(node, adjust_mode) -- sets node adjust mode
gui.set_alpha(node, alpha) -- sets the node alpha
gui.set_blend_mode(node, blend_mode) -- sets node blend mode
gui.set_clipping_inverted(node, inverted) -- sets node clipping inversion
gui.set_clipping_mode(node, clipping_mode) -- sets node clipping mode state
gui.set_clipping_visible(node, visible) -- sets node clipping visibility
gui.set_color(node, color) -- sets the node color
gui.set_enabled(node, enabled) -- enables/disables a node
gui.set_euler(node, rotation) -- sets the node rotation
gui.set_fill_angle(node, angle) -- sets the angle for the filled pie sector
gui.set_flipbook_cursor(node, cursor) -- sets the normalized cursor of the animation on a node with flipbook animation
gui.set_flipbook_playback_rate(node, playback_rate) -- sets the playback rate of the flipbook animation on a node
gui.set_font(node, font) -- sets the node font
gui.set_id(node, id) -- sets the id of the specified node
gui.set_inherit_alpha(node, inherit_alpha) -- sets the node inherit alpha state
gui.set_inner_radius(node, radius) -- sets the pie inner radius
gui.set_layer(node, layer) -- sets the node layer
gui.set_leading(node, leading) -- sets the leading of the text node
gui.set_line_break(node, line_break) -- set line-break mode
gui.set_material(node, material) -- sets the node material
gui.set_outer_bounds(node, bounds_mode) -- sets the pie node outer bounds mode
gui.set_outline(node, color) -- sets the node outline color
gui.set_parent(node, [parent], [keep_scene_transform]) -- sets the parent of the node
gui.set_particlefx(node, particlefx) -- Sets a particle fx
gui.set_perimeter_vertices(node, vertices) -- sets the number of generated vertices around the perimeter
gui.set_pivot(node, pivot) -- sets the pivot of a node
gui.set_position(node, position) -- sets the node position
gui.set_render_order(order) -- sets the render ordering for the current GUI scene
gui.set_rotation(node, rotation) -- sets the node rotation
gui.set_scale(node, scale) -- sets the node scale
gui.set_screen_position(node, screen_position) -- sets screen position to the node
gui.set_shadow(node, color) -- sets the node shadow color
gui.set_size(node, size) -- sets the node size
gui.set_size_mode(node, size_mode) -- sets node size mode
gui.set_slice9(node, values) -- set the slice9 configuration for the node
gui.set_text(node, text) -- sets the node text
gui.set_texture(node, texture) -- sets the node texture
gui.set_texture_data(texture, width, height, type, buffer, flip) -- set the buffer data for a texture
gui.set_tracking(node, tracking) -- sets the tracking of the text node
gui.set_visible(node, visible) -- set visibility for a node
gui.set_xanchor(node, anchor) -- sets the x-anchor of a node
gui.set_yanchor(node, anchor) -- sets the y-anchor of a node
gui.show_keyboard(type, autoclose) -- shows the on-display keyboard if available <span class="icon-ios"></span> <span class="icon-android"></span>
gui.stop_particlefx(node, [options]) -- Stops a particle fx
init(self) -- called when a gui component is initialized
on_input(self, action_id, action) -- called when user input is received
on_message(self, message_id, message) -- called when a message has been sent to the gui component
on_reload(self) -- called when the gui script is reloaded
update(self, dt) -- called every frame to update the gui component

-- Constants
gui.ADJUST_FIT -- fit adjust mode
gui.ADJUST_STRETCH -- stretch adjust mode
gui.ADJUST_ZOOM -- zoom adjust mode
gui.ANCHOR_BOTTOM -- bottom y-anchor
gui.ANCHOR_LEFT -- left x-anchor
gui.ANCHOR_NONE -- no anchor
gui.ANCHOR_RIGHT -- right x-anchor
gui.ANCHOR_TOP -- top y-anchor
gui.BLEND_ADD -- additive blending
gui.BLEND_ADD_ALPHA -- additive alpha blending
gui.BLEND_ALPHA -- alpha blending
gui.BLEND_MULT -- multiply blending
gui.BLEND_SCREEN -- screen blending
gui.CLIPPING_MODE_NONE -- clipping mode none
gui.CLIPPING_MODE_STENCIL -- clipping mode stencil
gui.EASING_INBACK -- in-back
gui.EASING_INBOUNCE -- in-bounce
gui.EASING_INCIRC -- in-circlic
gui.EASING_INCUBIC -- in-cubic
gui.EASING_INELASTIC -- in-elastic
gui.EASING_INEXPO -- in-exponential
gui.EASING_INOUTBACK -- in-out-back
gui.EASING_INOUTBOUNCE -- in-out-bounce
gui.EASING_INOUTCIRC -- in-out-circlic
gui.EASING_INOUTCUBIC -- in-out-cubic
gui.EASING_INOUTELASTIC -- in-out-elastic
gui.EASING_INOUTEXPO -- in-out-exponential
gui.EASING_INOUTQUAD -- in-out-quadratic
gui.EASING_INOUTQUART -- in-out-quartic
gui.EASING_INOUTQUINT -- in-out-quintic
gui.EASING_INOUTSINE -- in-out-sine
gui.EASING_INQUAD -- in-quadratic
gui.EASING_INQUART -- in-quartic
gui.EASING_INQUINT -- in-quintic
gui.EASING_INSINE -- in-sine
gui.EASING_LINEAR -- linear interpolation
gui.EASING_OUTBACK -- out-back
gui.EASING_OUTBOUNCE -- out-bounce
gui.EASING_OUTCIRC -- out-circlic
gui.EASING_OUTCUBIC -- out-cubic
gui.EASING_OUTELASTIC -- out-elastic
gui.EASING_OUTEXPO -- out-exponential
gui.EASING_OUTINBACK -- out-in-back
gui.EASING_OUTINBOUNCE -- out-in-bounce
gui.EASING_OUTINCIRC -- out-in-circlic
gui.EASING_OUTINCUBIC -- out-in-cubic
gui.EASING_OUTINELASTIC -- out-in-elastic
gui.EASING_OUTINEXPO -- out-in-exponential
gui.EASING_OUTINQUAD -- out-in-quadratic
gui.EASING_OUTINQUART -- out-in-quartic
gui.EASING_OUTINQUINT -- out-in-quintic
gui.EASING_OUTINSINE -- out-in-sine
gui.EASING_OUTQUAD -- out-quadratic
gui.EASING_OUTQUART -- out-quartic
gui.EASING_OUTQUINT -- out-quintic
gui.EASING_OUTSINE -- out-sine
gui.KEYBOARD_TYPE_DEFAULT -- default keyboard
gui.KEYBOARD_TYPE_EMAIL -- email keyboard
gui.KEYBOARD_TYPE_NUMBER_PAD -- number input keyboard
gui.KEYBOARD_TYPE_PASSWORD -- password keyboard
gui.PIEBOUNDS_ELLIPSE -- elliptical pie node bounds
gui.PIEBOUNDS_RECTANGLE -- rectangular pie node bounds
gui.PIVOT_CENTER -- center pivot
gui.PIVOT_E -- east pivot
gui.PIVOT_N -- north pivot
gui.PIVOT_NE -- north-east pivot
gui.PIVOT_NW -- north-west pivot
gui.PIVOT_S -- south pivot
gui.PIVOT_SE -- south-east pivot
gui.PIVOT_SW -- south-west pivot
gui.PIVOT_W -- west pivot
gui.PLAYBACK_LOOP_BACKWARD -- loop backward
gui.PLAYBACK_LOOP_FORWARD -- loop forward
gui.PLAYBACK_LOOP_PINGPONG -- ping pong loop
gui.PLAYBACK_ONCE_BACKWARD -- once backward
gui.PLAYBACK_ONCE_FORWARD -- once forward
gui.PLAYBACK_ONCE_PINGPONG -- once forward and then backward
gui.PROP_COLOR -- color property
gui.PROP_EULER -- euler property
gui.PROP_FILL_ANGLE -- fill_angle property
gui.PROP_INNER_RADIUS -- inner_radius property
gui.PROP_LEADING -- leading property
gui.PROP_OUTLINE -- outline color property
gui.PROP_POSITION -- position property
gui.PROP_ROTATION -- rotation property
gui.PROP_SCALE -- scale property
gui.PROP_SHADOW -- shadow color property
gui.PROP_SIZE -- size property
gui.PROP_SLICE9 -- slice9 property
gui.PROP_TRACKING -- tracking property
gui.RESULT_DATA_ERROR -- data error
gui.RESULT_OUT_OF_RESOURCES -- out of resource
gui.RESULT_TEXTURE_ALREADY_EXISTS -- texture already exists
gui.SIZE_MODE_AUTO -- automatic size mode
gui.SIZE_MODE_MANUAL -- manual size mode
gui.TYPE_BOX -- box type
gui.TYPE_CUSTOM -- custom type
gui.TYPE_PARTICLEFX -- particlefx type
gui.TYPE_PIE -- pie type
gui.TYPE_TEXT -- text type
```

### Component messages
- `layout_changed` - {id, previous_id}, reports a layout change

### Component properties
- `fonts` (hash) - gui fonts
- `material` (hash) - gui material
- `materials` (hash) - gui materials
- `textures` (hash) - gui textures

### Examples

Example for final(self):
```lua
function final(self)
    -- report finalization
    msg.post("my_friend_instance", "im_dead", {my_stats = self.some_value})
end
```

How to start a simple color animation, where the node fades in to white during 0.5 seconds:
```lua
gui.set_color(node, vmath.vector4(0, 0, 0, 0)) -- node is fully transparent
gui.animate(node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 1), gui.EASING_INOUTQUAD, 0.5) -- start animation
```

How to start a sequenced animation where the node fades in to white during 0.5 seconds, stays visible for 2 seconds and then fades out:
```lua
local function on_animation_done(self, node)
    -- fade out node, but wait 2 seconds before the animation starts
    gui.animate(node, gui.PROP_COLOR, vmath.vector4(0, 0, 0, 0), gui.EASING_OUTQUAD, 0.5, 2.0)
end

function init(self)
    -- fetch the node we want to animate
    local my_node = gui.get_node("my_node")
    -- node is initially set to fully transparent
    gui.set_color(my_node, vmath.vector4(0, 0, 0, 0))
    -- animate the node immediately and call on_animation_done when the animation has completed
    gui.animate(my_node, gui.PROP_COLOR, vmath.vector4(1, 1, 1, 1), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
end
```

How to animate a node's y position using a crazy custom easing curve:
```lua
function init(self)
    local values = { 0, 0, 0, 0, 0, 0, 0, 0,
                     1, 1, 1, 1, 1, 1, 1, 1,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     1, 1, 1, 1, 1, 1, 1, 1,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     1, 1, 1, 1, 1, 1, 1, 1,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     1, 1, 1, 1, 1, 1, 1, 1 }
    local vec = vmath.vector(values)
    local node = gui.get_node("box")
    gui.animate(node, "position.y", 100, vec, 4.0, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
end
```

Start an animation of the position property of a node, then cancel parts of
the animation:
```lua
local node = gui.get_node("my_node")
-- animate to new position
local pos = vmath.vector3(100, 100, 0)
gui.animate(node, "position", pos, go.EASING_LINEAR, 2)
...
-- cancel animation of the x component.
gui.cancel_animation(node, "position.x")
```

Example for gui.cancel_flipbook(node):
```lua
local node = gui.get_node("anim_node")
gui.cancel_flipbook(node)
```

Delete a particular node and any child nodes it might have:
```lua
local node = gui.get_node("my_node")
gui.delete_node(node)
```

Example for gui.delete_texture(texture):
```lua
function init(self)
     -- Create a texture.
     if gui.new_texture("temp_tx", 10, 10, "rgb", string.rep('\0', 10 * 10 * 3)) then
         -- Do something with the texture.
         ...

         -- Delete the texture
         gui.delete_texture("temp_tx")
     end
end
```

Get properties on existing nodes:
```lua
local node = gui.get_node("my_box_node")
local node_position = gui.get(node, "position")
```

Get the text metrics for a text
```lua
function init(self)
  local node = gui.get_node("name")
  local font_name = gui.get_font(node)
  local font = gui.get_font_resource(font_name)
  local metrics = resource.get_text_metrics(font, "The quick brown fox\n jumps over the lazy dog")
end
```

Gets the id of a node:
```lua
local node = gui.get_node("my_node")

local id = gui.get_id(node)
print(id) --> hash: [my_node]
```

Compare the index order of two sibling nodes:
```lua
local node1 = gui.get_node("my_node_1")
local node2 = gui.get_node("my_node_2")

if gui.get_index(node1) < gui.get_index(node2) then
    -- node1 is drawn below node2
else
    -- node2 is drawn below node1
end
```

Getting the material for a node, and assign it to another node:
```lua
local node1 = gui.get_node("my_node")
local node2 = gui.get_node("other_node")
local node1_material = gui.get_material(node1)
gui.set_material(node2, node1_material)
```

Gets a node by id and change its color:
```lua
local node = gui.get_node("my_node")
local red = vmath.vector4(1.0, 0.0, 0.0, 1.0)
gui.set_color(node, red)
```

How to create a texture and apply it to a new box node:
```lua
function init(self)
     local w = 200
     local h = 300

     -- A nice orange. String with the RGB values.
     local orange = string.char(0xff) .. string.char(0x80) .. string.char(0x10)

     -- Create the texture. Repeat the color string for each pixel.
     local ok, reason = gui.new_texture("orange_tx", w, h, "rgb", string.rep(orange, w * h))
     if ok then
         -- Create a box node and apply the texture to it.
         local n = gui.new_box_node(vmath.vector3(200, 200, 0), vmath.vector3(w, h, 0))
         gui.set_texture(n, "orange_tx")
     else
         -- Could not create texture for some reason...
         if reason == gui.RESULT_TEXTURE_ALREADY_EXISTS then
             ...
         else
             ...
         end
     end
end
```

Set the texture of a node to a flipbook animation from an atlas:
```lua
local function anim_callback(self, node)
    -- Take action after animation has played.
end

function init(self)
    -- Create a new node and set the texture to a flipbook animation
    local node = gui.get_node("button_node")
    gui.set_texture(node, "gui_sprites")
    gui.play_flipbook(node, "animated_button")
end
```

Set the texture of a node to an image from an atlas:
```lua
-- Create a new node and set the texture to a "button.png" from atlas
local node = gui.get_node("button_node")
gui.set_texture(node, "gui_sprites")
gui.play_flipbook(node, "button")
```

How to play a particle fx when a gui node is created.
The callback receives the gui node, the hash of the id
of the emitter, and the new state of the emitter as particlefx.EMITTER_STATE_.
```lua
local function emitter_state_change(self, node, emitter, state)
  if emitter == hash("exhaust") and state == particlefx.EMITTER_STATE_POSTSPAWN then
    -- exhaust is done spawning particles...
  end
end

function init(self)
    gui.play_particlefx(gui.get_node("particlefx"), emitter_state_change)
end
```

Resetting the material for a node:
```lua
local node = gui.get_node("my_node")
gui.reset_material(node)
```

Updates the position property on an existing node:
```lua
local node = gui.get_node("my_box_node")
local node_position = gui.get(node, "position")
gui.set(node, "position.x", node_position.x + 128)
```

Updates the rotation property on an existing node:
```lua
local node = gui.get_node("my_box_node")
gui.set(node, "rotation", vmath.quat_rotation_z(math.rad(45)))
-- this is equivalent to:
gui.set(node, "euler.z", 45)
-- or using the entire vector:
gui.set(node, "euler", vmath.vector3(0,0,45))
-- or using the set_rotation
gui.set_rotation(node, vmath.vector3(0,0,45))
```

Sets various material constants for a node:
```lua
local node = gui.get_node("my_box_node")
gui.set(node, "tint", vmath.vector4(1,0,0,1))
-- matrix4 is also supported
gui.set(node, "light_matrix", vmath.matrix4())
-- update a constant in an array at position 4. the array is specified in the shader as:
-- uniform vec4 tint_array[4]; // lua is 1 based, shader is 0 based
gui.set(node, "tint_array", vmath.vector4(1,0,0,1), { index = 4 })
-- update a matrix constant in an array at position 4. the array is specified in the shader as:
-- uniform mat4 light_matrix_array[4];
gui.set(node, "light_matrix_array", vmath.matrix4(), { index = 4 })
-- update a sub-element in a constant
gui.set(node, "tint.x", 1)
-- update a sub-element in an array constant at position 4
gui.set(node, "tint_array.x", 1, {index = 4})
```

Create a new node and set its id:
```lua
local pos = vmath.vector3(100, 100, 0)
local size = vmath.vector3(100, 100, 0)
local node = gui.new_box_node(pos, size)
gui.set_id(node, "my_new_node")
```

Assign an existing material to a node:
```lua
local node = gui.get_node("my_node")
gui.set_material(node, "my_material")
```

To set a texture (or animation) from an atlas:
```lua
local node = gui.get_node("box_node")
gui.set_texture(node, "my_atlas")
gui.play_flipbook(node, "image")
```

Set a dynamically created texture to a node. Note that there is only
one texture image in this case so gui.set_texture() is
sufficient.
```lua
local w = 200
local h = 300
-- A nice orange. String with the RGB values.
local orange = string.char(0xff) .. string.char(0x80) .. string.char(0x10)
-- Create the texture. Repeat the color string for each pixel.
if gui.new_texture("orange_tx", w, h, "rgb", string.rep(orange, w * h)) then
    local node = gui.get_node("box_node")
    gui.set_texture(node, "orange_tx")
end
```

Example for gui.set_texture_data(texture, width, height, type, buffer, flip):
```lua
function init(self)
     local w = 200
     local h = 300

     -- Create a dynamic texture, all white.
     if gui.new_texture("dynamic_tx", w, h, "rgb", string.rep(string.char(0xff), w * h * 3)) then
         -- Create a box node and apply the texture to it.
         local n = gui.new_box_node(vmath.vector3(200, 200, 0), vmath.vector3(w, h, 0))
         gui.set_texture(n, "dynamic_tx")

         ...

         -- Change the data in the texture to a nice orange.
         local orange = string.char(0xff) .. string.char(0x80) .. string.char(0x10)
         if gui.set_texture_data("dynamic_tx", w, h, "rgb", string.rep(orange, w * h)) then
             -- Go on and to more stuff
             ...
         end
     else
         -- Something went wrong
         ...
     end
end
```

Example for init(self):
```lua
function init(self)
    -- set up useful data
    self.my_value = 1
end
```

Example for on_input(self, action_id, action):
```lua
function on_input(self, action_id, action)
    -- check for input
    if action_id == hash("my_action") then
        -- take appropritate action
        self.my_value = action.value
    end
    -- consume input
    return true
end
```

Example for on_reload(self):
```lua
function on_reload(self)
    -- restore some color (or similar)
    gui.set_color(gui.get_node("my_node"), self.my_original_color)
end
```

This example demonstrates how to update a text node that displays game score in a counting fashion.
It is assumed that the gui component receives messages from the game when a new score is to be shown.
```lua
function init(self)
    -- fetch the score text node for later use (assumes it is called "score")
    self.score_node = gui.get_node("score")
    -- keep track of the current score counted up so far
    self.current_score = 0
    -- keep track of the target score we should count up to
    self.target_score = 0
    -- how fast we will update the score, in score/second
    self.score_update_speed = 1
end

function update(self, dt)
    -- check if target score is more than current score
    if self.current_score < self.target_score
        -- increment current score according to the speed
        self.current_score = self.current_score + dt * self.score_update_speed
        -- check if we went past the target score, clamp current score in that case
        if self.current_score > self.target_score then
            self.current_score = self.target_score
        end
        -- update the score text node
        gui.set_text(self.score_node, "" .. math.floor(self.current_score))
    end
end

function on_message(self, message_id, message, sender)
    -- check the message
    if message_id == hash("set_score") then
        self.target_score = message.score
    end
end
```


## HTML5 API documentation
HTML5 platform specific functions.
<span class="icon-html5"></span> The following functions are only available on HTML5 builds, the <code>html5.*</code> Lua namespace will not be available on other platforms.

```lua
-- Functions
html5.run(code) -- run JavaScript code, in the browser, from Lua
html5.set_interaction_listener(callback) -- set a JavaScript interaction listener callback from lua
```

### Examples

Example for html5.run(code):
```lua
local res = html5.run("10 + 20") -- returns the string "30"
print(res)
local res_num = tonumber(res) -- convert to number
print(res_num - 20) -- prints 10
```

Example for html5.set_interaction_listener(callback):
```lua
local function on_interaction(self)
    print("on_interaction called")
    html5.set_interaction_listener(nil)
end

function init(self)
    html5.set_interaction_listener(on_interaction)
end
```


## HTTP API documentation
Functions for performing HTTP and HTTPS requests.

```lua
-- Functions
http.request(url, method, callback, [headers], [post_data], [options]) -- perform a HTTP/HTTPS request
```

### Examples

Basic HTTP-GET request. The callback receives a table with the response
in the fields status, the response (the data) and headers (a table).
```lua
local function http_result(self, _, response)
    if response.bytes_total ~= nil then
        update_my_progress_bar(self, response.bytes_received / response.bytes_total)
    else
        print(response.status)
        print(response.response)
        pprint(response.headers)
    end
end

function init(self)
    http.request("http://www.google.com", "GET", http_result, nil, nil, { report_progress = true })
end
```


## Image API documentation
Functions for creating image objects.

```lua
-- Functions
image.load(buffer, [options]) -- load image from buffer
image.load_buffer(buffer, [options]) -- load image from a string into a buffer object

-- Constants
image.TYPE_LUMINANCE -- luminance image type
image.TYPE_LUMINANCE_ALPHA -- luminance image type
image.TYPE_RGB -- RGB image type
image.TYPE_RGBA -- RGBA image type
```

### Examples

How to load an image from an URL and create a GUI texture from it:
```lua
local imgurl = "http://www.site.com/image.png"
http.request(imgurl, "GET", function(self, id, response)
        local img = image.load(response.response)
        local tx = gui.new_texture("image_node", img.width, img.height, img.type, img.buffer)
    end)
```

Load an image from an URL as a buffer and create a texture resource from it:
```lua
local imgurl = "http://www.site.com/image.png"
http.request(imgurl, "GET", function(self, id, response)
        local img = image.load_buffer(response.response, { flip_vertically = true })
        local tparams = {
            width  = img.width,
            height = img.height,
            type   = graphics.TEXTURE_TYPE_2D,
            format = graphics.TEXTURE_FORMAT_RGBA }

        local my_texture_id = resource.create_texture("/my_custom_texture.texturec", tparams, img.buffer)
        -- Apply the texture to a model
        go.set("/go1#model", "texture0", my_texture_id)
    end)
```


## JSON API documentation
Manipulation of JSON data strings.

```lua
-- Functions
json.decode(json, [options]) -- decode JSON from a string to a lua-table
json.encode(tbl, [options]) -- encode a lua table to a JSON string

-- Constants
json.null -- null
```

### Examples

Converting a string containing JSON data into a Lua table:
```lua
function init(self)
    local jsonstring = '{"persons":[{"name":"John Doe"},{"name":"Darth Vader"}]}'
    local data = json.decode(jsonstring)
    pprint(data)
end
```

Results in the following printout:
```lua
{
  persons = {
    1 = {
      name = John Doe,
    }
    2 = {
      name = Darth Vader,
    }
  }
}
```

Convert a lua table to a JSON string:
```lua
function init(self)
     local tbl = {
          persons = {
               { name = "John Doe"},
               { name = "Darth Vader"}
          }
     }
     local jsonstring = json.encode(tbl)
     pprint(jsonstring)
end
```

Results in the following printout:
```lua
{"persons":[{"name":"John Doe"},{"name":"Darth Vader"}]}
```


## Label API documentation
Label API documentation

```lua
-- Functions
label.get_text(url) -- gets the text for a label
label.set_text(url, text) -- set the text for a label
```

### Component properties
- `color` (vector4) - label color
- `font` (hash) - label font
- `leading` (number) - label leading
- `line_break` (bool) - label line break
- `material` (hash) - label material
- `outline` (vector4) - label outline
- `scale` (number | vector3) - label scale
- `shadow` (vector4) - label shadow
- `size` (vector3) - label size
- `tracking` (number) - label tracking

### Examples

Example for label.get_text(url):
```lua
function init(self)
    local text = label.get_text("#label")
    print(text)
end
```

Example for label.set_text(url, text):
```lua
function init(self)
    label.set_text("#label", "Hello World!")
end
```


## LiveUpdate API documentation
Functions and constants to access resources.

```lua
-- Functions
liveupdate.add_mount(name, uri, priority, callback) -- Add resource mount
liveupdate.get_current_manifest() -- return a reference to the Manifest that is currently loaded
liveupdate.get_mounts() -- Get current mounts
liveupdate.is_using_liveupdate_data() -- is any liveupdate data mounted and currently in use
liveupdate.remove_mount(name) -- Remove resource mount
liveupdate.store_archive(path, callback, [options]) -- register and store a live update zip file
liveupdate.store_manifest(manifest_buffer, callback) -- create, verify, and store a manifest to device
liveupdate.store_resource(manifest_reference, data, hexdigest, callback) -- add a resource to the data archive and runtime index

-- Constants
liveupdate.LIVEUPDATE_BUNDLED_RESOURCE_MISMATCH -- LIVEUPDATE_BUNDLED_RESOURCE_MISMATCH
liveupdate.LIVEUPDATE_ENGINE_VERSION_MISMATCH -- LIVEUPDATE_ENGINE_VERSION_MISMATCH
liveupdate.LIVEUPDATE_FORMAT_ERROR -- LIVEUPDATE_FORMAT_ERROR
liveupdate.LIVEUPDATE_INVAL -- LIVEUPDATE_INVAL
liveupdate.LIVEUPDATE_INVALID_HEADER -- LIVEUPDATE_INVALID_HEADER
liveupdate.LIVEUPDATE_INVALID_RESOURCE -- LIVEUPDATE_INVALID_RESOURCE
liveupdate.LIVEUPDATE_IO_ERROR -- LIVEUPDATE_IO_ERROR
liveupdate.LIVEUPDATE_MEM_ERROR -- LIVEUPDATE_MEM_ERROR
liveupdate.LIVEUPDATE_OK -- LIVEUPDATE_OK
liveupdate.LIVEUPDATE_SCHEME_MISMATCH -- LIVEUPDATE_SCHEME_MISMATCH
liveupdate.LIVEUPDATE_SIGNATURE_MISMATCH -- LIVEUPDATE_SIGNATURE_MISMATCH
liveupdate.LIVEUPDATE_UNKNOWN -- LIVEUPDATE_UNKNOWN
liveupdate.LIVEUPDATE_VERSION_MISMATCH -- LIVEUPDATE_VERSION_MISMATCH
```

### Examples

Add multiple mounts. Higher priority takes precedence.
```lua
liveupdate.add_mount("common", "zip:/path/to/common_stuff.zip", 10, function (result) end) -- base pack
liveupdate.add_mount("levelpack_1", "zip:/path/to/levels_1_to_20.zip", 20, function (result) end) -- level pack
liveupdate.add_mount("season_pack_1", "zip:/path/to/easter_pack_1.zip", 30, function (result) end) -- season pack, overriding content in the other packs
```

Output the current resource mounts
```lua
pprint("MOUNTS", liveupdate.get_mounts())
```

Give an output like:
```lua
DEBUG:SCRIPT: MOUNTS,
{ --[[0x119667bf0]]
  1 = { --[[0x119667c50]]
    name = "liveupdate",
    uri = "zip:/device/path/to/acchives/liveupdate.zip",
    priority = 5
  },
  2 = { --[[0x119667d50]]
    name = "_base",
    uri = "archive:build/default/game.dmanifest",
    priority = -10
  }
}
```

Add multiple mounts. Higher priority takes precedence.
```lua
liveupdate.remove_mount("season_pack_1")
```

How to download an archive with HTTP and store it on device.
```lua
local LIVEUPDATE_URL = <a file server url>

-- This can be anything, but you should keep the platform bundles apart
local ZIP_FILENAME = 'defold.resourcepack.zip'

local APP_SAVE_DIR = "LiveUpdateDemo"

function init(self)
    self.proxy = "levels#level1"

    print("INIT: is_using_liveupdate_data:", liveupdate.is_using_liveupdate_data())
    -- let's download the archive
    msg.post("#", "attempt_download_archive")
end

-- helper function to store headers from the http request (e.g. the ETag)
local function store_http_response_headers(name, data)
    local path = sys.get_save_file(APP_SAVE_DIR, name)
    sys.save(path, data)
end

local function load_http_response_headers(name)
    local path = sys.get_save_file(APP_SAVE_DIR, name)
    return sys.load(path)
end

-- returns headers that can potentially generate a 304
-- without redownloading the file again
local function get_http_request_headers(name)
    local data = load_http_response_headers(name)
    local headers = {}
    for k, v in pairs(data) do
        if string.lower(k) == 'etag' then
            headers['If-None-Match'] = v
        elseif string.lower(k) == 'last-modified' then
            headers['If-Modified-Since'] = v
        end
    end
    return headers
end

local function store_archive_cb(self, path, status)
    if status == true then
        print("Successfully stored live update archive!", path)
        sys.reboot()
    else
        print("Failed to store live update archive, ", path)
        -- remove the path
    end
end

function on_message(self, message_id, message, sender)
    if message_id == hash("attempt_download_archive") then

        -- by supplying the ETag, we don't have to redownload the file again
        -- if we already have downloaded it.
        local headers = get_http_request_headers(ZIP_FILENAME .. '.json')
        if not liveupdate.is_using_liveupdate_data() then
            headers = {} -- live update data has been purged, and we need do a fresh download
        end

        local path = sys.get_save_file(APP_SAVE_DIR, ZIP_FILENAME)
        local options = {
            path = path,        -- a temporary file on disc. will be removed upon successful liveupdate storage
            ignore_cache = true -- we don't want to store a (potentially large) duplicate in our http cache
        }

        local url = LIVEUPDATE_URL .. ZIP_FILENAME
        print("Downloading", url)
        http.request(url, "GET", function(self, id, response)
            if response.status == 304 then
                print(string.format("%d: Archive zip file up-to-date", response.status))
            elseif response.status == 200 and response.error == nil then
                -- register the path to the live update system
                liveupdate.store_archive(response.path, store_archive_cb)
                -- at this point, the "path" has been moved internally to a different location

                -- save the ETag for the next run
                store_http_response_headers(ZIP_FILENAME .. '.json', response.headers)
            else
                print("Error when downloading", url, "to", path, ":", response.status, response.error)
            end

            -- If we got a 200, we would call store_archive_cb() then reboot
            -- Second time, if we get here, it should be after a 304, and then
            -- we can load the missing resources from the liveupdate archive
            if liveupdate.is_using_liveupdate_data() then
                msg.post(self.proxy, "load")
            end
        end,
        headers, nil, options)
```

How to download a manifest with HTTP and store it on device.
```lua
local function store_manifest_cb(self, status)
  if status == liveupdate.LIVEUPDATE_OK then
    pprint("Successfully stored manifest. This manifest will be loaded instead of the bundled manifest the next time the engine starts.")
  else
    pprint("Failed to store manifest")
  end
end

local function download_and_store_manifest(self)
  http.request(MANIFEST_URL, "GET", function(self, id, response)
      if response.status == 200 then
        liveupdate.store_manifest(response.response, store_manifest_cb)
      end
    end)
end
```

Example for liveupdate.store_resource(manifest_reference, data, hexdigest, callback):
```lua
function init(self)
    self.manifest = liveupdate.get_current_manifest()
end

local function callback_store_resource(self, hexdigest, status)
     if status == true then
          print("Successfully stored resource: " .. hexdigest)
     else
          print("Failed to store resource: " .. hexdigest)
     end
end

local function load_resources(self, target)
     local resources = collectionproxy.missing_resources(target)
     for _, resource_hash in ipairs(resources) do
          local baseurl = "http://example.defold.com:8000/"
          http.request(baseurl .. resource_hash, "GET", function(self, id, response)
               if response.status == 200 then
                    liveupdate.store_resource(self.manifest, response.response, resource_hash, callback_store_resource)
               else
                    print("Failed to download resource: " .. resource_hash)
               end
          end)
     end
end
```


## Messaging API documentation
Functions for passing messages and constructing URL objects.

```lua
-- Functions
msg.post(receiver, message_id, [message]) -- posts a message to a receiving URL
msg.url() -- creates a new URL
msg.url(urlstring) -- creates a new URL from a string
msg.url([socket], [path], [fragment]) -- creates a new URL from separate arguments
```

### Examples

Send "enable" to the sprite "my_sprite" in "my_gameobject":
```lua
msg.post("my_gameobject#my_sprite", "enable")
```

Send a "my_message" to an url with some additional data:
```lua
local params = {my_parameter = "my_value"}
msg.post(my_url, "my_message", params)
```

Create a new URL which will address the current script:
```lua
local my_url = msg.url()
print(my_url) --> url: [current_collection:/my_instance#my_component]
```

Example for msg.url(urlstring):
```lua
local my_url = msg.url("#my_component")
print(my_url) --> url: [current_collection:/my_instance#my_component]

local my_url = msg.url("my_collection:/my_sub_collection/my_instance#my_component")
print(my_url) --> url: [my_collection:/my_sub_collection/my_instance#my_component]

local my_url = msg.url("my_socket:")
print(my_url) --> url: [my_collection:]
```

Example for msg.url([socket], [path], [fragment]):
```lua
local my_socket = "main" -- specify by valid name
local my_path = hash("/my_collection/my_gameobject") -- specify as string or hash
local my_fragment = "component" -- specify as string or hash
local my_url = msg.url(my_socket, my_path, my_fragment)

print(my_url) --> url: [main:/my_collection/my_gameobject#component]
print(my_url.socket) --> 786443 (internal numeric value)
print(my_url.path) --> hash: [/my_collection/my_gameobject]
print(my_url.fragment) --> hash: [component]
```


## Model API documentation
Model API documentation

```lua
-- Functions
model.cancel(url) -- cancel all animation on a model
model.get_go(url, bone_id) -- retrieve the game object corresponding to a model skeleton bone
model.get_mesh_enabled(url, mesh_id) -- get the enabled state of a mesh
model.play_anim(url, anim_id, playback, [play_properties], [complete_function]) -- play an animation on a model
model.set_mesh_enabled(url, mesh_id, enabled) -- enable or disable a mesh
```

### Component messages
- `model_animation_done` - {animation_id, playback}, reports the completion of a Model animation

### Component properties
- `animation` (hash) - model animation
- `cursor` (number) - model cursor
- `material` (hash) - model material
- `playback_rate` (number) - model playback_rate
- `textureN` (hash) - model textureN where N is 0-7

### Examples

The following examples assumes that the model component has id "model".
How to parent the game object of the calling script to the "right_hand" bone of the model in a player game object:
```lua
function init(self)
    local parent = model.get_go("player#model", "right_hand")
    msg.post(".", "set_parent", {parent_id = parent})
end
```

Example for model.get_mesh_enabled(url, mesh_id):
```lua
function init(self)
    if model.get_mesh_enabled("#model", "Sword") then
       -- set properties specific for the sword
       self.weapon_properties = game.data.weapons["Sword"]
    end
end
```

The following examples assumes that the model has id "model".
How to play the "jump" animation followed by the "run" animation:
```lua
local function anim_done(self, message_id, message, sender)
  if message_id == hash("model_animation_done") then
    if message.animation_id == hash("jump") then
      -- open animation done, chain with "run"
      local properties = { blend_duration = 0.2 }
      model.play_anim(url, "run", go.PLAYBACK_LOOP_FORWARD, properties, anim_done)
    end
  end
end

function init(self)
    local url = msg.url("#model")
    local play_properties = { blend_duration = 0.1 }
    -- first blend during 0.1 sec into the jump, then during 0.2 s into the run animation
    model.play_anim(url, "jump", go.PLAYBACK_ONCE_FORWARD, play_properties, anim_done)
end
```

Example for model.set_mesh_enabled(url, mesh_id, enabled):
```lua
function init(self)
    model.set_mesh_enabled("#model", "Sword", false) -- hide the sword
    model.set_mesh_enabled("#model", "Axe", true)    -- show the axe
end
```


## Particle effects API documentation
Functions for controlling particle effect component playback and
shader constants.

```lua
-- Functions
particlefx.play(url, [emitter_state_function]) -- start playing a particle FX
particlefx.reset_constant(url, emitter, constant) -- reset a shader constant for a particle FX component emitter
particlefx.set_constant(url, emitter, constant, value) -- set a shader constant for a particle FX component emitter
particlefx.stop(url, [options]) -- stop playing a particle fx

-- Constants
particlefx.EMITTER_STATE_POSTSPAWN -- postspawn state
particlefx.EMITTER_STATE_PRESPAWN -- prespawn state
particlefx.EMITTER_STATE_SLEEPING -- sleeping state
particlefx.EMITTER_STATE_SPAWNING -- spawning state
```

### Examples

How to play a particle fx when a game object is created.
The callback receives the hash of the path to the particlefx, the hash of the id
of the emitter, and the new state of the emitter as particlefx.EMITTER_STATE_.
```lua
local function emitter_state_change(self, id, emitter, state)
  if emitter == hash("exhaust") and state == particlefx.EMITTER_STATE_POSTSPAWN then
    -- exhaust is done spawning particles...
  end
end

function init(self)
    particlefx.play("#particlefx", emitter_state_change)
end
```

The following examples assumes that the particle FX has id "particlefx", it
contains an emitter with the id "emitter" and that the default-material in builtins is used, which defines the constant "tint".
If you assign a custom material to the sprite, you can reset the constants defined there in the same manner.
How to reset the tinting of particles from an emitter:
```lua
function init(self)
    particlefx.reset_constant("#particlefx", "emitter", "tint")
end
```

The following examples assumes that the particle FX has id "particlefx", it
contains an emitter with the id "emitter" and that the default-material in builtins is used, which defines the constant "tint".
If you assign a custom material to the sprite, you can reset the constants defined there in the same manner.
How to tint particles from an emitter red:
```lua
function init(self)
    particlefx.set_constant("#particlefx", "emitter", "tint", vmath.vector4(1, 0, 0, 1))
end
```

How to stop a particle fx when a game object is deleted and immediately also clear
any spawned particles:
```lua
function final(self)
    particlefx.stop("#particlefx", { clear = true })
end
```


## Profiler API documentation
Functions for getting profiling data in runtime.
More detailed <a href="https://www.defold.com/manuals/profiling/">profiling</a> and <a href="http://www.defold.com/manuals/debugging/">debugging</a> information available in the manuals.

```lua
-- Functions
profiler.dump_frame() -- logs the current frame to the console
profiler.enable_ui(enabled) -- enables or disables the on-screen profiler ui
profiler.get_cpu_usage() -- get current CPU usage for app reported by OS
profiler.get_memory_usage() -- get current memory usage for app reported by OS
profiler.log_text(text) -- send a text to the connected profiler
profiler.recorded_frame_count() -- get the number of recorded frames in the on-screen profiler ui
profiler.scope_begin(name) -- start a profile scope
profiler.scope_end() -- end the current profile scope
profiler.set_ui_mode(mode) -- sets the the on-screen profiler ui mode
profiler.set_ui_view_mode(mode) -- sets the the on-screen profiler ui view mode
profiler.set_ui_vsync_wait_visible(visible) -- Shows or hides the vsync wait time in the on-screen profiler ui
profiler.view_recorded_frame(frame_index) -- displays a previously recorded frame in the on-screen profiler ui

-- Constants
profiler.MODE_PAUSE -- pause on current frame
profiler.MODE_RECORD -- start recording
profiler.MODE_RUN -- continously show latest frame
profiler.MODE_SHOW_PEAK_FRAME -- pause at peak frame
profiler.VIEW_MODE_FULL -- show full profiler ui
profiler.VIEW_MODE_MINIMIZED -- show mimimal profiler ui
```

### Examples

Example for profiler.dump_frame():
```lua
profiler.dump_frame()
```

Example for profiler.enable_ui(enabled):
```lua
-- Show the profiler UI
profiler.enable_ui(true)
```

Get memory usage before and after loading a collection:
```lua
print(profiler.get_memory_usage())
msg.post("#collectionproxy", "load")
...
print(profiler.get_memory_usage()) -- will report a higher number than the initial call
```

Example for profiler.log_text(text):
```lua
profiler.log_text("Event: " .. name)
```

Example for profiler.recorded_frame_count():
```lua
-- Show the last recorded frame
local recorded_frame_count = profiler.recorded_frame_count()
profiler.view_recorded_frame(recorded_frame_count)
```

Example for profiler.scope_begin(name):
```lua
-- Go back one frame
profiler.scope_begin("test_function")
  test_function()
profiler.scope_end()
```

Example for profiler.set_ui_mode(mode):
```lua
function start_recording()
     profiler.set_ui_mode(profiler.MODE_RECORD)
end

function stop_recording()
     profiler.set_ui_mode(profiler.MODE_PAUSE)
end
```

Example for profiler.set_ui_view_mode(mode):
```lua
-- Minimize the profiler view
profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
```

Example for profiler.set_ui_vsync_wait_visible(visible):
```lua
-- Exclude frame wait time form the profiler ui
profiler.set_ui_vsync_wait_visible(false)
```

Example for profiler.view_recorded_frame(frame_index):
```lua
-- Go back one frame
profiler.view_recorded_frame({distance = -1})
```


## Rendering API documentation
Rendering functions, messages and constants. The "render" namespace is
accessible only from render scripts.
The rendering API was originally built on top of OpenGL ES 2.0, and it uses a subset of the
OpenGL computer graphics rendering API for rendering 2D and 3D computer
graphics. Our current target is OpenGLES 3.0 with fallbacks to 2.0 on some platforms.
<span class="icon-attention"></span> It is possible to create materials and write shaders that
require features not in OpenGL ES 2.0, but those will not work cross platform.

```lua
-- Functions
render.clear(buffers) -- clears the active render target
render.constant_buffer() -- create a new constant buffer.
render.delete_render_target(render_target) -- deletes a render target
render.disable_material() -- disables the currently enabled material
render.disable_state(state) -- disables a render state
render.disable_texture(binding) -- disables a texture on the render state
render.dispatch_compute(x, y, z, [options]) -- dispatches the currently enabled compute program
render.draw(predicate, [options]) -- draws all objects matching a predicate
render.draw_debug3d([options]) -- draws all 3d debug graphics
render.enable_material(material_id) -- enables a material
render.enable_state(state) -- enables a render state
render.enable_texture(binding, handle_or_name, [buffer_type]) -- sets a texture to the render state
render.get_height() -- gets the window height, as specified for the project
render.get_render_target_height(render_target, buffer_type) -- retrieve a buffer height from a render target
render.get_render_target_width(render_target, buffer_type) -- retrieve the buffer width from a render target
render.get_width() -- gets the window width, as specified for the project
render.get_window_height() -- gets the actual window height
render.get_window_width() -- gets the actual window width
render.predicate(tags) -- creates a new render predicate
render.render_target(name, parameters) -- creates a new render target
render.set_blend_func(source_factor, destination_factor) -- sets the blending function
render.set_camera(camera, [options]) -- sets the current render camera to be used for rendering
render.set_color_mask(red, green, blue, alpha) -- sets the color mask
render.set_compute(compute) -- set the current compute program
render.set_cull_face(face_type) -- sets the cull face
render.set_depth_func(func) -- sets the depth test function
render.set_depth_mask(depth) -- sets the depth mask
render.set_listener(callback) -- set render's event listener
render.set_polygon_offset(factor, units) -- sets the polygon offset
render.set_projection(matrix) -- sets the projection matrix
render.set_render_target(render_target, [options]) -- sets a render target
render.set_render_target_size(render_target, width, height) -- sets the render target size
render.set_stencil_func(func, ref, mask) -- sets the stencil test function
render.set_stencil_mask(mask) -- sets the stencil mask
render.set_stencil_op(sfail, dpfail, dppass) -- sets the stencil operator
render.set_view(matrix) -- sets the view matrix
render.set_viewport(x, y, width, height) -- sets the render viewport

-- Constants
render.FRUSTUM_PLANES_ALL
render.FRUSTUM_PLANES_SIDES
render.RENDER_TARGET_DEFAULT
```

### Component messages
- `clear_color` - {color}, set clear color
- `draw_debug_text` - {position, text, color}, draw a text on the screen
- `draw_line` - {start_point, end_point, color}, draw a line on the screen
- `resize` - {height, width}, resizes the window
- `window_resized` - {height, width}, reports a window size change

### Examples

Clear the color buffer and the depth buffer.
```lua
render.clear({[graphics.BUFFER_TYPE_COLOR0_BIT] = vmath.vector4(0, 0, 0, 0), [graphics.BUFFER_TYPE_DEPTH_BIT] = 1})
```

Set a "tint" constant in a constant buffer in the render script:
```lua
local constants = render.constant_buffer()
constants.tint = vmath.vector4(1, 1, 1, 1)
```

Then use the constant buffer when drawing a predicate:
```lua
render.draw(self.my_pred, {constants = constants})
```

The constant buffer also supports array values by specifying constants in a table:
```lua
local constants = render.constant_buffer()
constants.light_colors    = {}
constants.light_colors[1] = vmath.vector4(1, 0, 0, 1)
constants.light_colors[2] = vmath.vector4(0, 1, 0, 1)
constants.light_colors[3] = vmath.vector4(0, 0, 1, 1)
```

You can also create the table by passing the vectors directly when creating the table:
```lua
local constants = render.constant_buffer()
constants.light_colors    = {
     vmath.vector4(1, 0, 0, 1)
     vmath.vector4(0, 1, 0, 1)
     vmath.vector4(0, 0, 1, 1)
}

-- Add more constant to the array
constants.light_colors[4] = vmath.vector4(1, 1, 1, 1)
```

How to delete a render target:
```lua
 render.delete_render_target(self.my_render_target)
```

Enable material named "glow", then draw my_pred with it.
```lua
render.enable_material("glow")
render.draw(self.my_pred)
render.disable_material()
```

Disable face culling when drawing the tile predicate:
```lua
render.disable_state(graphics.STATE_CULL_FACE)
render.draw(self.tile_pred)
```

Example for render.disable_texture(binding):
```lua
function update(self, dt)
    render.enable_texture(0, self.my_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
    -- draw a predicate with the render target available as texture 0 in the predicate
    -- material shader.
    render.draw(self.my_pred)
    -- done, disable the texture
    render.disable_texture(0)
end
```

Example for render.dispatch_compute(x, y, z, [options]):
```lua
function init(self)
    local color_params = { format = graphics.TEXTURE_FORMAT_RGBA,
                           width = render.get_window_width(),
                           height = render.get_window_height()}
    self.scene_rt = render.render_target({[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params})
end

function update(self, dt)
    render.set_compute("bloom")
    render.enable_texture(0, self.backing_texture)
    render.enable_texture(1, self.scene_rt)
    render.dispatch_compute(128, 128, 1)
    render.set_compute()
end
```

Dispatch a compute program with a constant buffer:
```lua
local constants = render.constant_buffer()
constants.tint = vmath.vector4(1, 1, 1, 1)
render.dispatch_compute(32, 32, 32, {constants = constants})
```

Example for render.draw(predicate, [options]):
```lua
function init(self)
    -- define a predicate matching anything with material tag "my_tag"
    self.my_pred = render.predicate({hash("my_tag")})
end

function update(self, dt)
    -- draw everything in the my_pred predicate
    render.draw(self.my_pred)
end
```

Draw predicate with constants:
```lua
local constants = render.constant_buffer()
constants.tint = vmath.vector4(1, 1, 1, 1)
render.draw(self.my_pred, {constants = constants})
```

Draw with predicate and frustum culling (without near+far planes):
```lua
local frustum = self.proj * self.view
render.draw(self.my_pred, {frustum = frustum})
```

Draw with predicate and frustum culling (with near+far planes):
```lua
local frustum = self.proj * self.view
render.draw(self.my_pred, {frustum = frustum, frustum_planes = render.FRUSTUM_PLANES_ALL})
```

Example for render.draw_debug3d([options]):
```lua
function update(self, dt)
    -- draw debug visualization
    render.draw_debug3d()
end
```

Enable material named "glow", then draw my_pred with it.
```lua
render.enable_material("glow")
render.draw(self.my_pred)
render.disable_material()
```

Enable stencil test when drawing the gui predicate, then disable it:
```lua
render.enable_state(graphics.STATE_STENCIL_TEST)
render.draw(self.gui_pred)
render.disable_state(graphics.STATE_STENCIL_TEST)
```

Example for render.enable_texture(binding, handle_or_name, [buffer_type]):
```lua
function update(self, dt)
    -- enable target so all drawing is done to it
    render.set_render_target(self.my_render_target)

    -- draw a predicate to the render target
    render.draw(self.my_pred)

    -- disable target
    render.set_render_target(render.RENDER_TARGET_DEFAULT)

    render.enable_texture(0, self.my_render_target, graphics.BUFFER_TYPE_COLOR0_BIT)
    -- draw a predicate with the render target available as texture 0 in the predicate
    -- material shader.
    render.draw(self.my_pred)
end
```

```lua
function update(self, dt)
    -- enable render target by resource id
    render.set_render_target('my_rt_resource')
    render.draw(self.my_pred)
    render.set_render_target(render.RENDER_TARGET_DEFAULT)

    render.enable_texture(0, 'my_rt_resource', graphics.BUFFER_TYPE_COLOR0_BIT)
    -- draw a predicate with the render target available as texture 0 in the predicate
    -- material shader.
    render.draw(self.my_pred)
end
```

```lua
function update(self, dt)
    -- bind a texture to the texture unit 0
    render.enable_texture(0, self.my_texture_handle)
    -- bind the same texture to a named sampler
    render.enable_texture("my_texture_sampler", self.my_texture_handle)
end
```

Get the height of the window
```lua
local h = render.get_height()
```

Example for render.get_render_target_height(render_target, buffer_type):
```lua
-- get the height of the render target color buffer
local h = render.get_render_target_height(self.target_right, graphics.BUFFER_TYPE_COLOR0_BIT)
-- get the height of a render target resource
local w = render.get_render_target_height('my_rt_resource', graphics.BUFFER_TYPE_COLOR0_BIT)
```

Example for render.get_render_target_width(render_target, buffer_type):
```lua
-- get the width of the render target color buffer
local w = render.get_render_target_width(self.target_right, graphics.BUFFER_TYPE_COLOR0_BIT)
-- get the width of a render target resource
local w = render.get_render_target_width('my_rt_resource', graphics.BUFFER_TYPE_COLOR0_BIT)
```

Get the width of the window.
```lua
local w = render.get_width()
```

Get the actual height of the window
```lua
local h = render.get_window_height()
```

Get the actual width of the window
```lua
local w = render.get_window_width()
```

Create a new render predicate containing all visual objects that
have a material with material tags "opaque" AND "smoke".
```lua
local p = render.predicate({hash("opaque"), hash("smoke")})
```

How to create a new render target and draw to it:
```lua
function init(self)
    -- render target buffer parameters
    local color_params = { format = graphics.TEXTURE_FORMAT_RGBA,
                           width = render.get_window_width(),
                           height = render.get_window_height(),
                           min_filter = graphics.TEXTURE_FILTER_LINEAR,
                           mag_filter = graphics.TEXTURE_FILTER_LINEAR,
                           u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
                           v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE }
    local depth_params = { format = graphics.TEXTURE_FORMAT_DEPTH,
                           width = render.get_window_width(),
                           height = render.get_window_height(),
                           u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
                           v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE }
    self.my_render_target = render.render_target({[graphics.BUFFER_TYPE_COLOR0_BIT] = color_params, [graphics.BUFFER_TYPE_DEPTH_BIT] = depth_params })
end

function update(self, dt)
    -- enable target so all drawing is done to it
    render.set_render_target(self.my_render_target)

    -- draw a predicate to the render target
    render.draw(self.my_pred)
end
```

How to create a render target with multiple outputs:
```lua
function init(self)
    -- render target buffer parameters
    local color_params_rgba = { format = graphics.TEXTURE_FORMAT_RGBA,
                                width = render.get_window_width(),
                                height = render.get_window_height(),
                                min_filter = graphics.TEXTURE_FILTER_LINEAR,
                                mag_filter = graphics.TEXTURE_FILTER_LINEAR,
                                u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
                                v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE }
    local color_params_float = { format = graphics.TEXTURE_FORMAT_RG32F,
                           width = render.get_window_width(),
                           height = render.get_window_height(),
                           min_filter = graphics.TEXTURE_FILTER_LINEAR,
                           mag_filter = graphics.TEXTURE_FILTER_LINEAR,
                           u_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE,
                           v_wrap = graphics.TEXTURE_WRAP_CLAMP_TO_EDGE }


    -- Create a render target with three color attachments
    -- Note: No depth buffer is attached here
    self.my_render_target = render.render_target({
           [graphics.BUFFER_TYPE_COLOR0_BIT] = color_params_rgba,
           [graphics.BUFFER_TYPE_COLOR1_BIT] = color_params_rgba,
           [graphics.BUFFER_TYPE_COLOR2_BIT] = color_params_float, })
end

function update(self, dt)
    -- enable target so all drawing is done to it
    render.enable_render_target(self.my_render_target)

    -- draw a predicate to the render target
    render.draw(self.my_pred)
end
```

Set the blend func to the most common one:
```lua
render.set_blend_func(graphics.BLEND_FACTOR_SRC_ALPHA, graphics.BLEND_FACTOR_ONE_MINUS_SRC_ALPHA)
```

Set the current camera to be used for rendering
```lua
render.set_camera("main:/my_go#camera")
render.draw(self.my_pred)
render.set_camera(nil)
```

Use the camera frustum for frustum culling together with a specific frustum plane option for the draw command
```lua
-- The camera frustum will take precedence over the frustum plane option in render.draw
render.set_camera("main:/my_go#camera", { use_frustum = true })
-- However, we can still customize the frustum planes regardless of the camera option!
render.draw(self.my_pred, { frustum_planes = render.FRUSTUM_PLANES_ALL })
render.set_camera()
```

Example for render.set_color_mask(red, green, blue, alpha):
```lua
-- alpha cannot be written to frame buffer
render.set_color_mask(true, true, true, false)
```

Enable compute program named "fractals", then dispatch it.
```lua
render.set_compute("fractals")
render.enable_texture(0, self.backing_texture)
render.dispatch_compute(128, 128, 1)
render.set_compute()
```

How to enable polygon culling and set front face culling:
```lua
render.enable_state(graphics.STATE_CULL_FACE)
render.set_cull_face(graphics.FACE_TYPE_FRONT)
```

Enable depth test and set the depth test function to "not equal".
```lua
render.enable_state(graphics.STATE_DEPTH_TEST)
render.set_depth_func(graphics.COMPARE_FUNC_NOTEQUAL)
```

How to turn off writing to the depth buffer:
```lua
render.set_depth_mask(false)
```

Set listener and handle render context events.
```lua
--- custom.render_script
function init(self)
   render.set_listener(function(self, event_type)
       if event_type == render.CONTEXT_EVENT_CONTEXT_LOST then
           --- Some stuff when rendering context is lost
       elseif event_type == render.CONTEXT_EVENT_CONTEXT_RESTORED then
           --- Start reload resources, reload game, etc.
       end
   end)
end
```

Example for render.set_polygon_offset(factor, units):
```lua
render.enable_state(graphics.STATE_POLYGON_OFFSET_FILL)
render.set_polygon_offset(1.0, 1.0)
```

How to set the projection to orthographic with world origo at lower left,
width and height as set in project settings and depth (z) between -1 and 1:
```lua
render.set_projection(vmath.matrix4_orthographic(0, render.get_width(), 0, render.get_height(), -1, 1))
```

How to set a render target and draw to it and then switch back to the default render target
The render target defines the depth/stencil buffers as transient, when set_render_target is called the next time the buffers may be invalidated and allow for optimisations depending on driver support
```lua
function update(self, dt)
    -- set render target so all drawing is done to it
    render.set_render_target(self.my_render_target, { transient = { graphics.BUFFER_TYPE_DEPTH_BIT, graphics.BUFFER_TYPE_STENCIL_BIT } } )

    -- draw a predicate to the render target
    render.draw(self.my_pred)

    -- set default render target. This also invalidates the depth and stencil buffers of the current target (self.my_render_target)
    --  which can be an optimisation on some hardware
    render.set_render_target(render.RENDER_TARGET_DEFAULT)

end
```

```lua
function update(self, dt)
    -- set render target by a render target resource identifier
    render.set_render_target('my_rt_resource')

    -- draw a predicate to the render target
    render.draw(self.my_pred)

    -- reset the render target to the default backbuffer
    render.set_render_target(render.RENDER_TARGET_DEFAULT)

end
```

Resize render targets to the current window size:
```lua
render.set_render_target_size(self.my_render_target, render.get_window_width(), render.get_window_height())
render.set_render_target_size('my_rt_resource', render.get_window_width(), render.get_window_height())
```

Example for render.set_stencil_func(func, ref, mask):
```lua
-- let only 0's pass the stencil test
render.set_stencil_func(graphics.COMPARE_FUNC_EQUAL, 0, 1)
```

Example for render.set_stencil_mask(mask):
```lua
-- set the stencil mask to all 1:s
render.set_stencil_mask(0xff)
```

Set the stencil function to never pass and operator to always draw 1's
on test fail.
```lua
render.set_stencil_func(graphics.COMPARE_FUNC_NEVER, 1, 0xFF)
-- always draw 1's on test fail
render.set_stencil_op(graphics.STENCIL_OP_REPLACE, graphics.STENCIL_OP_KEEP, graphics.STENCIL_OP_KEEP)
```

How to set the view and projection matrices according to
the values supplied by a camera.
```lua
function init(self)
  self.view = vmath.matrix4()
  self.projection = vmath.matrix4()
end

function update(self, dt)
  -- set the view to the stored view value
  render.set_view(self.view)
  -- now we can draw with this view
end

function on_message(self, message_id, message)
  if message_id == hash("set_view_projection") then
     -- camera view and projection arrives here.
     self.view = message.view
     self.projection = message.projection
  end
end
```

Example for render.set_viewport(x, y, width, height):
```lua
-- Set the viewport to the window dimensions.
render.set_viewport(0, 0, render.get_window_width(), render.get_window_height())
```


## Resource API documentation
Functions and constants to access resources.

```lua
-- Functions
resource.atlas([path]) -- reference to atlas resource
resource.buffer([path]) -- reference to buffer resource
resource.create_atlas(path, table) -- create an atlas resource
resource.create_buffer(path, [table]) -- create a buffer resource
resource.create_sound_data(path, [options]) -- Creates a sound data resource (.oggc/.wavc)
resource.create_texture(path, table, buffer) -- create a texture
resource.create_texture_async(path, table, buffer) -- create a texture async
resource.font([path]) -- reference to font resource
resource.get_atlas(path) -- Get atlas data
resource.get_buffer(path) -- get resource buffer
resource.get_render_target_info(path) -- get render target info
resource.get_text_metrics(url, text, [options]) -- gets the text metrics for a font
resource.get_texture_info(path) -- get texture info
resource.load(path) -- load a resource
resource.material([path]) -- reference to material resource
resource.release(path) -- release a resource
resource.render_target([path]) -- reference to render target resource
resource.set(path, buffer) -- Set a resource
resource.set_atlas(path, table) -- set atlas data
resource.set_buffer(path, buffer, [table]) -- set resource buffer
resource.set_sound(path, buffer) -- Update internal sound resource
resource.set_texture(path, table, buffer) -- set a texture
resource.texture([path]) -- reference to texture resource
resource.tile_source([path]) -- reference to tile source resource
```

### Examples

Load an atlas and set it to a sprite:
```lua
go.property("my_atlas", resource.atlas("/atlas.atlas"))
function init(self)
  go.set("#sprite", "image", self.my_atlas)
end
```

Load an atlas and set it to a gui:
```lua
go.property("my_atlas", resource.atlas("/atlas.atlas"))
function init(self)
  go.set("#gui", "textures", self.my_atlas, {key = "my_atlas"})
end
```

Set a unique buffer it to a sprite:
```lua
go.property("my_buffer", resource.buffer("/cube.buffer"))
function init(self)
  go.set("#mesh", "vertices", self.my_buffer)
end
```

Create a backing texture and an atlas
```lua
function init(self)
    -- create an empty texture
    local tparams = {
        width          = 128,
        height         = 128,
        type           = graphics.TEXTURE_TYPE_2D,
        format         = graphics.TEXTURE_FORMAT_RGBA,
    }
    local my_texture_id = resource.create_texture("/my_texture.texturec", tparams)

    -- optionally use resource.set_texture to upload data to texture

    -- create an atlas with one animation and one square geometry
    -- note that the function doesn't support hashes for the texture,
    -- you need to use a string for the texture path here aswell
    local aparams = {
        texture = "/my_texture.texturec",
        animations = {
            {
                id          = "my_animation",
                width       = 128,
                height      = 128,
                frame_start = 1,
                frame_end   = 2,
            }
        },
        geometries = {
            {
                id = 'idle0',
                width = 128,
                height = 128,
                pivot_x = 64,
                pivot_y = 64,
                vertices  = {
                    0,   0,
                    0,   128,
                    128, 128,
                    128, 0
                },
                uvs = {
                    0,   0,
                    0,   128,
                    128, 128,
                    128, 0
                },
                indices = {0,1,2,0,2,3}
            }
        }
    }
    local my_atlas_id = resource.create_atlas("/my_atlas.texturesetc", aparams)

    -- assign the atlas to the 'sprite' component on the same go
    go.set("#sprite", "image", my_atlas_id)
end
```

Create a buffer resource from existing resource
```lua
function init(self)
    local res = resource.get_buffer("/my_buffer_path.bufferc")
    -- create a cloned buffer resource from another resource buffer
    local buf = reource.create_buffer("/my_cloned_buffer.bufferc", { buffer = res })
    -- assign cloned buffer to a mesh component
    go.set("/go#mesh", "vertices", buf)
end
```

Example for resource.create_sound_data(path, [options]):
```lua
function init(self)
    -- create a new sound resource, given the initial chunk of the file
    local relative_path = "/a/unique/resource/name.oggc"
    local hash = resource.create_sound_data(relative_path, { data = data, filesize = filesize, partial = true })
    go.set("#music", "sound", hash) -- override the previous sound resource
    sound.play("#music") -- start the playing
end
```

How to create a 32x32x32 floating point 3D texture that can be used to generate volumetric data in a compute shader
```lua
function init(self)
    local t_volume = resource.create_texture("/my_backing_texture.texturec", {
        type   = graphics.TEXTURE_TYPE_IMAGE_3D,
        width  = 32,
        height = 32,
        depth  = 32,
        format = resource.TEXTURE_FORMAT_RGBA32F,
        flags  = resource.TEXTURE_USAGE_FLAG_STORAGE + resource.TEXTURE_USAGE_FLAG_SAMPLE,
    })

    -- pass the backing texture to the render script
    msg.post("@render:", "add_textures", { t_volume })
end
```

Create a texture resource asyncronously without a callback
```lua
function init(self)
    -- Create a texture resource async
    local tparams = {
        width          = 128,
        height         = 128,
        type           = graphics.TEXTURE_TYPE_2D,
        format         = graphics.TEXTURE_FORMAT_RGBA,
    }

    -- Create a new buffer with 4 components
    local tbuffer = buffer.create(tparams.width * tparams.height, { {name=hash("rgba"), type=buffer.VALUE_TYPE_UINT8, count=4} } )
    local tstream = buffer.get_stream(tbuffer, hash("rgba"))

    -- Fill the buffer stream with some float values
    for y=1,tparams.width do
        for x=1,tparams.height do
            local index = (y-1) * 128 * 4 + (x-1) * 4 + 1
            tstream[index + 0] = 255
            tstream[index + 1] = 0
            tstream[index + 2] = 255
            tstream[index + 3] = 255
        end
    end
    -- create the texture
    local tpath, request_id = resource.create_texture_async("/my_texture.texturec", tparams, tbuffer)
    -- at this point you can use the resource as-is, but note that the texture will be a blank 1x1 texture
    -- that will be removed once the new texture has been updated
    go.set("#model", "texture0", tpath)
end
```

Load a font and set it to a label:
```lua
go.property("my_font", resource.font("/font.font"))
function init(self)
  go.set("#label", "font", self.my_font)
end
```

Load a font and set it to a gui:
```lua
go.property("my_font", resource.font("/font.font"))
function init(self)
  go.set("#gui", "fonts", self.my_font, {key = "my_font"})
end
```

How to get the data from a buffer
```lua
function init(self)

    local res_path = go.get("#mesh", "vertices")
    local buf = resource.get_buffer(res_path)
    local stream_positions = buffer.get_stream(buf, "position")

    for i=1,#stream_positions do
        print(i, stream_positions[i])
    end
end
```

Get a texture attachment from a render target and set it on a model component
```lua
function init(self)
    local info = resource.get_render_target_info("/my_render_target.render_targetc")
    local attachment = info.attachments[1].texture
    -- you can also get texture info from the 'texture' field, since it's a resource hash
    local texture_info = resource.get_texture_info(attachment)
    go.set("#model", "texture0", attachment)
end
```

Example for resource.get_text_metrics(url, text, [options]):
```lua
function init(self)
    local font = go.get("#label", "font")
    local metrics = resource.get_text_metrics(font, "The quick brown fox\n jumps over the lazy dog")
    pprint(metrics)
end
```

Get the meta data from an atlas resource
```lua
function init(self)
    local my_atlas_info   = resource.get_atlas("/my_atlas.a.texturesetc")
    local my_texture_info = resource.get_texture_info(my_atlas_info.texture)

    -- my_texture_info now contains the information about the texture that is backing the atlas
end
```

Example for resource.load(path):
```lua
-- read custom resource data into buffer
local buffer = resource.load("/resources/datafile")
```

In order for the engine to include custom resources in the build process, you need
to specify them in the "game.project" settings file:
```lua
[project]
title = My project
version = 0.1
custom_resources = resources/,assets/level_data.json
```

Load a material and set it to a sprite:
```lua
go.property("my_material", resource.material("/material.material"))
function init(self)
  go.set("#sprite", "material", self.my_material)
end
```

Load a material resource and update a named material with the resource:
```lua
go.property("my_material", resource.material("/material.material"))
function init(self)
  go.set("#gui", "materials", self.my_material, {key = "my_material"})
end
```

Set a render target color attachment as a model texture:
```lua
go.property("my_render_target", resource.render_target("/rt.render_target"))
function init(self)
  local rt_info = resource.get_render_target_info(self.my_render_target)
  go.set("#model", "texture0", rt_info.attachments[1].texture)
end
```

Assuming the folder "/res" is added to the project custom resources:
```lua
-- load a texture resource and set it on a sprite
local buffer = resource.load("/res/new.texturec")
resource.set(go.get("#sprite", "texture0"), buffer)
```

Sets atlas data for a 256x256 texture with a single animation being rendered as a quad
```lua
function init(self)
    local params = {
        texture = "/main/my_256x256_texture.texturec",
        animations = {
            {
                id          = "my_animation",
                width       = 256,
                height      = 256,
                frame_start = 1,
                frame_end   = 2,
            }
        },
        geometries = {
            {
                vertices = {
                    0,   0,
                    0,   256,
                    256, 256,
                    256, 0
                },
                uvs = {
                    0, 0,
                    0, 256,
                    256, 256,
                    256, 0
                },
                indices = { 0,1,2,0,2,3 }
            }
        }
    }
    resource.set_atlas("/main/test.a.texturesetc", params)
end
```

How to set the data from a buffer
```lua
local function fill_stream(stream, verts)
    for key, value in ipairs(verts) do
        stream[key] = verts[key]
    end
end

function init(self)

    local res_path = go.get("#mesh", "vertices")

    local positions = {
         1, -1, 0,
         1,  1, 0,
         -1, -1, 0
    }

    local num_verts = #positions / 3

    -- create a new buffer
    local buf = buffer.create(num_verts, {
        { name = hash("position"), type=buffer.VALUE_TYPE_FLOAT32, count = 3 }
    })

    local buf = resource.get_buffer(res_path)
    local stream_positions = buffer.get_stream(buf, "position")

    fill_stream(stream_positions, positions)

    resource.set_buffer(res_path, buf)
end
```

Update an existing 3D texture from a lua buffer
```lua
function init(self)
    -- create a buffer that can hold the data of a 8x8x8 texture
    local tbuffer = buffer.create(8 * 8 * 8, { {name=hash("rgba"), type=buffer.VALUE_TYPE_FLOAT32, count=4} } )
    local tstream = buffer.get_stream(tbuffer, hash("rgba"))
```lua
-- populate the buffer with some data
local index = 1
for z=1,8 do
    for y=1,8 do
        for x=1,8 do
            tstream[index + 0] = x
            tstream[index + 1] = y
            tstream[index + 2] = z
            tstream[index + 3] = 1.0
            index = index + 4
        end
    end
end

local t_args = {
    type   = graphics.TEXTURE_TYPE_IMAGE_3D,
    width  = 8,
    height = 8,
    depth  = 8,
    format = resource.TEXTURE_FORMAT_RGBA32F
}

-- This expects that the texture resource "/my_3d_texture.texturec" already exists
-- and is a 3D texture resource. To create a dynamic 3D texture resource
-- use the "resource.create_texture" function.
resource.set_texture("/my_3d_texture.texturec", t_args, tbuffer)
```

end

Load a texture and set it to a model:
```lua
go.property("my_texture", resource.texture("/texture.png"))
function init(self)
  go.set("#model", "texture0", self.my_texture)
end
```

Load tile source and set it to a tile map:
```lua
go.property("my_tile_source", resource.tile_source("/tilesource.tilesource"))
function init(self)
  go.set("#tilemap", "tile_source", self.my_tile_source)
end
```


## Sound API documentation
Sound API documentation

```lua
-- Functions
sound.get_group_gain(group) -- get mixer group gain
sound.get_group_name(group) -- get mixer group name string
sound.get_groups() -- get all mixer group names
sound.get_peak(group, window) -- get peak gain value from mixer group
sound.get_rms(group, window) -- get RMS value from mixer group
sound.is_music_playing() -- check if background music is playing
sound.is_phone_call_active() -- check if a phone call is active
sound.pause(url, pause) -- pause a playing a sound(s)
sound.play(url, [play_properties], [complete_function]) -- plays a sound
sound.set_gain(url, [gain]) -- set sound gain
sound.set_group_gain(group, gain) -- set mixer group gain
sound.set_pan(url, [pan]) -- set sound pan
sound.stop(url, [stop_properties]) -- stop a playing a sound(s)
```

### Component messages
- `play_sound` - {[delay], [gain], [play_id]}, plays a sound
- `set_gain` - {[gain]}, set sound gain
- `sound_done` - {[play_id]}, reports when a sound has finished playing
- `sound_stopped` - {[play_id]}, reports when a sound has been manually stopped
- `stop_sound` - stop a playing a sound(s)

### Component properties
- `gain` (number) - sound gain
- `pan` (number) - sound pan
- `sound` (hash) - sound data
- `speed` (number) - sound speed

### Examples

Get the mixer group gain for the "soundfx" and convert to dB:
```lua
local gain = sound.get_group_gain("soundfx")
local gain_db = 20 * log(gain)
```

Get the mixer group string names so we can show them as labels on a dev mixer overlay:
```lua
local groups = sound.get_groups()
for _,group in ipairs(groups) do
    local name = sound.get_group_name(group)
    msg.post("/mixer_overlay#gui", "set_mixer_label", { group = group, label = name})
end
```

Get the mixer groups, set all gains to 0 except for "master" and "soundfx"
where gain is set to 1:
```lua
local groups = sound.get_groups()
for _,group in ipairs(groups) do
    if group == hash("master") or group == hash("soundfx") then
        sound.set_group_gain(group, 1)
    else
        sound.set_group_gain(group, 0)
    end
end
```

Get the peak gain from the "master" group and convert to dB for displaying:
```lua
local left_p, right_p = sound.get_peak("master", 0.1)
left_p_db = 20 * log(left_p)
right_p_db = 20 * log(right_p)
```

Get the RMS from the "master" group where a mono -1.94 dB sinewave is playing:
```lua
local rms = sound.get_rms("master", 0.1) -- throw away right channel.
print(rms) --> 0.56555819511414
```

If music is playing, mute "master":
```lua
if sound.is_music_playing() then
    -- mute "master"
    sound.set_group_gain("master", 0)
end
```

Test if a phone call is on-going:
```lua
if sound.is_phone_call_active() then
    -- do something sensible.
end
```

Assuming the script belongs to an instance with a sound-component with id "sound", this will make the component pause all playing voices:
```lua
sound.pause("#sound", true)
```

Assuming the script belongs to an instance with a sound-component with id "sound", this will make the component play its sound after 1 second:
```lua
sound.play("#sound", { delay = 1, gain = 0.5, pan = -1.0 } )
```

Using the callback argument, you can chain several sounds together:
```lua
local function sound_done(self, message_id, message, sender)
  -- play 'boom' sound fx when the countdown has completed
  if message_id == hash("sound_done") and message.play_id == self.countdown_id then
    sound.play("#boom", nil, sound_done)
  end
end

function init(self)
  self.countdown_id = sound.play("#countdown", nil, sound_done)
end
```

Assuming the script belongs to an instance with a sound-component with id "sound", this will set the gain to 0.5
```lua
sound.set_gain("#sound", 0.5)
```

Set mixer group gain on the "soundfx" group to -4 dB:
```lua
local gain_db = -4
local gain = 10^gain_db/20 -- 0.63095734448019
sound.set_group_gain("soundfx", gain)
```

Assuming the script belongs to an instance with a sound-component with id "sound", this will set the gain to 0.5
```lua
sound.set_pan("#sound", 0.5) -- pan to the right
```

Assuming the script belongs to an instance with a sound-component with id "sound", this will make the component stop all playing voices:
```lua
sound.stop("#sound")
local id = sound.play("#sound")
sound.stop("#sound", {play_id = id})
```


## Sprite API documentation
Sprite API documentation

```lua
-- Functions
sprite.play_flipbook(url, id, [complete_function], [play_properties]) -- Play an animation on a sprite component
sprite.set_hflip(url, flip) -- set horizontal flipping on a sprite's animations
sprite.set_vflip(url, flip) -- set vertical flipping on a sprite's animations
```

### Component messages
- `animation_done` - {current_tile, id}, reports that an animation has completed
- `play_animation` - {id}, play a sprite animation

### Component properties
- `animation` (hash) - sprite animation
- `cursor` (number) - sprite cursor
- `frame_count` (hash) - sprite frame_count
- `image` (hash) - sprite image
- `material` (hash) - sprite material
- `playback_rate` (number) - sprite playback_rate
- `scale` (vector3) - sprite scale
- `size` (vector3) - sprite size
- `slice` (vector4) - sprite slice

### Examples

The following examples assumes that the model has id "sprite".
How to play the "jump" animation followed by the "run" animation:
```lua
local function anim_done(self, message_id, message, sender)
  if message_id == hash("animation_done") then
    if message.id == hash("jump") then
      -- jump animation done, chain with "run"
      sprite.play_flipbook(url, "run")
    end
  end
end
```

```lua
function init(self)
  local url = msg.url("#sprite")
  sprite.play_flipbook(url, "jump", anim_done)
end
```

How to flip a sprite so it faces the horizontal movement:
```lua
function update(self, dt)
  -- calculate self.velocity somehow
  sprite.set_hflip("#sprite", self.velocity.x < 0)
end
```

It is assumed that the sprite component has id "sprite" and that the original animations faces right.

How to flip a sprite in a game which negates gravity as a game mechanic:
```lua
function update(self, dt)
  -- calculate self.up_side_down somehow, then:
  sprite.set_vflip("#sprite", self.up_side_down)
end
```

It is assumed that the sprite component has id "sprite" and that the original animations are up-right.


## System API documentation
Functions and messages for using system resources, controlling the engine,
error handling and debugging.

```lua
-- Functions
sys.deserialize(buffer) -- deserializes buffer into a lua table
sys.exists(path) -- check if a path exists
sys.exit(code) -- exits application
sys.get_application_info(app_string) -- get application information
sys.get_application_path() -- gets the application path
sys.get_config_int(key, [default_value]) -- get integer config value with optional default value
sys.get_config_number(key, [default_value]) -- get number config value with optional default value
sys.get_config_string(key, [default_value]) -- get string config value with optional default value
sys.get_connectivity() -- get current network connectivity status
sys.get_engine_info() -- get engine information
sys.get_host_path(filename) -- create a path to the host device for unit testing
sys.get_ifaddrs() -- enumerate network interfaces
sys.get_save_file(application_id, file_name) -- gets the save-file path
sys.get_sys_info([options]) -- get system information
sys.load(filename) -- loads a lua table from a file on disk
sys.load_buffer(path) -- loads a buffer from a resource or disk path
sys.load_buffer_async(path, status_callback) -- loads a buffer from a resource or disk path asynchronously
sys.load_resource(filename) -- loads resource from game data
sys.open_url(url, [attributes]) -- open url in default application
sys.reboot([arg1], [arg2], [arg3], [arg4], [arg5], [arg6]) -- reboot engine with arguments
sys.save(filename, table) -- saves a lua table to a file stored on disk
sys.serialize(table) -- serializes a lua table to a buffer and returns it
sys.set_connectivity_host(host) -- set host to check for network connectivity against
sys.set_error_handler(error_handler) -- set the error handler
sys.set_update_frequency(frequency) -- set update frequency
sys.set_vsync_swap_interval(swap_interval) -- set vsync swap interval

-- Constants
sys.NETWORK_CONNECTED -- network connected through other, non cellular, connection
sys.NETWORK_CONNECTED_CELLULAR -- network connected through mobile cellular
sys.NETWORK_DISCONNECTED -- no network connection found
sys.REQUEST_STATUS_ERROR_IO_ERROR -- an asyncronous request is unable to read the resource
sys.REQUEST_STATUS_ERROR_NOT_FOUND -- an asyncronous request is unable to locate the resource
sys.REQUEST_STATUS_FINISHED -- an asyncronous request has finished successfully
```

### Component messages
- `exit` - {code}, exits application
- `reboot` - {arg1, arg2, arg3, arg4, arg5, arg6}, reboot engine with arguments
- `resume_rendering` - resume rendering
- `set_update_frequency` - {frequency}, set update frequency
- `set_vsync` - {swap_interval}, set vsync swap interval
- `start_record` - {file_name, frame_period, fps}, starts video recording
- `stop_record` - stop current video recording
- `toggle_physics_debug` - shows/hides the on-screen physics visual debugging
- `toggle_profile` - shows/hides the on-screen profiler

### Examples

Deserialize a lua table that was previously serialized:
```lua
local buffer = sys.serialize(my_table)
local table = sys.deserialize(buffer)
```

Load data but return nil if path didn't exist
```lua
if not sys.exists(path) then
    return nil
end
return sys.load(path) -- returns {} if it failed
```

This examples demonstrates how to exit the application when some kind of quit messages is received (maybe from gui or similar):
```lua
function on_message(self, message_id, message, sender)
    if message_id == hash("quit") then
        sys.exit(0)
    end
end
```

Check if twitter is installed:
```lua
sysinfo = sys.get_sys_info()
twitter = {}

if sysinfo.system_name == "Android" then
  twitter = sys.get_application_info("com.twitter.android")
elseif sysinfo.system_name == "iPhone OS" then
  twitter = sys.get_application_info("twitter:")
end

if twitter.installed then
  -- twitter is installed!
end
```

 Info.plist for the iOS app needs to list the schemes that are queried:
```lua
...
LSApplicationQueriesSchemes

   twitter

...
```

Find a path where we can store data (the example path is on the macOS platform):
```lua
-- macOS: /Applications/my_game.app
local application_path = sys.get_application_path()
print(application_path) --> /Applications/my_game.app

-- Windows: C:\Program Files\my_game\my_game.exe
print(application_path) --> C:\Program Files\my_game

-- Linux: /home/foobar/my_game/my_game
print(application_path) --> /home/foobar/my_game

-- Android package name: com.foobar.my_game
print(application_path) --> /data/user/0/com.foobar.my_game

-- iOS: my_game.app
print(application_path) --> /var/containers/Bundle/Applications/123456AB-78CD-90DE-12345678ABCD/my_game.app

-- HTML5: http://www.foobar.com/my_game/
print(application_path) --> http://www.foobar.com/my_game
```

Get user config value
```lua
local speed = sys.get_config_int("my_game.speed", 20) -- with default value
```

```lua
local testmode = sys.get_config_int("my_game.testmode") -- without default value
if testmode ~= nil then
    -- do stuff
end
```

Get user config value
```lua
local speed = sys.get_config_number("my_game.speed", 20.0)
```

Get user config value
```lua
local text = sys.get_config_string("my_game.text", "default text"))
```

Start the engine with a bootstrap config override and add a custom config value
```lua
$ dmengine --config=bootstrap.main_collection=/mytest.collectionc --config=mygame.testmode=1
```

Read the custom config value from the command line
```lua
local testmode = sys.get_config_int("mygame.testmode")
```

Check if we are connected through a cellular connection
```lua
if (sys.NETWORK_CONNECTED_CELLULAR == sys.get_connectivity()) then
  print("Connected via cellular, avoid downloading big files!")
end
```

How to retrieve engine information:
```lua
-- Update version text label so our testers know what version we're running
local engine_info = sys.get_engine_info()
local version_str = "Defold " .. engine_info.version .. "\n" .. engine_info.version_sha1
gui.set_text(gui.get_node("version"), version_str)
```

Save data on the host
```lua
local host_path = sys.get_host_path("logs/test.txt")
sys.save(host_path, mytable)
```

Load data from the host
```lua
local host_path = sys.get_host_path("logs/test.txt")
local table = sys.load(host_path)
```

How to get the IP address of interface "en0":
```lua
ifaddrs = sys.get_ifaddrs()
for _,interface in ipairs(ifaddrs) do
  if interface.name == "en0" then
    local ip = interface.address
  end
end
```

Find a path where we can store data (the example path is on the macOS platform):
```lua
local my_file_path = sys.get_save_file("my_game", "my_file")
print(my_file_path) --> /Users/my_users/Library/Application Support/my_game/my_file
```

How to get system information:
```lua
local info = sys.get_sys_info()
if info.system_name == "HTML5" then
  -- We are running in a browser.
end
```

Load data that was previously saved, e.g. an earlier game session:
```lua
local my_file_path = sys.get_save_file("my_game", "my_file")
local my_table = sys.load(my_file_path)
if not next(my_table) then
  -- empty table
end
```

Load binary data from a custom project resource:
```lua
local my_buffer = sys.load_buffer("/assets/my_level_data.bin")
local data_str = buffer.get_bytes(my_buffer, "data")
local has_my_header = string.sub(data_str,1,6) == "D3F0LD"
```

Load binary data from non-custom resource files on disk:
```lua
local asset_1 = sys.load_buffer("folder_next_to_binary/my_level_asset.txt")
local asset_2 = sys.load_buffer("/my/absolute/path")
```

Load binary data from a custom project resource and update a texture resource:
```lua
function my_callback(self, request_id, result)
  if result.status == resource.REQUEST_STATUS_FINISHED then
     resource.set_texture("/my_texture", { ... }, result.buf)
  end
end

local my_request = sys.load_buffer_async("/assets/my_level_data.bin", my_callback)
```

Load binary data from non-custom resource files on disk:
```lua
function my_callback(self, request_id, result)
  if result.status ~= sys.REQUEST_STATUS_FINISHED then
    -- uh oh! File could not be found, do something graceful
  elseif request_id == self.first_asset then
    -- result.buffer contains data from my_level_asset.bin
  elif request_id == self.second_asset then
    -- result.buffer contains data from 'my_level.bin'
  end
end

function init(self)
  self.first_asset = hash("folder_next_to_binary/my_level_asset.bin")
  self.second_asset = hash("/some_absolute_path/my_level.bin")
  self.first_request = sys.load_buffer_async(self.first_asset, my_callback)
  self.second_request = sys.load_buffer_async(self.second_asset, my_callback)
end
```

Example for sys.load_resource(filename):
```lua
-- Load level data into a string
local data, error = sys.load_resource("/assets/level_data.json")
-- Decode json string to a Lua table
if data then
  local data_table = json.decode(data)
  pprint(data_table)
else
  print(error)
end
```

Open an URL:
```lua
local success = sys.open_url("http://www.defold.com", {target = "_blank"})
if not success then
  -- could not open the url...
end
```

How to reboot engine with a specific bootstrap collection.
```lua
local arg1 = '--config=bootstrap.main_collection=/my.collectionc'
local arg2 = 'build/game.projectc'
sys.reboot(arg1, arg2)
```

Save data:
```lua
local my_table = {}
table.insert(my_table, "my_value")
local my_file_path = sys.get_save_file("my_game", "my_file")
if not sys.save(my_file_path, my_table) then
  -- Alert user that the data could not be saved
end
```

Serialize table:
```lua
local my_table = {}
table.insert(my_table, "my_value")
local buffer = sys.serialize(my_table)
```

Example for sys.set_connectivity_host(host):
```lua
sys.set_connectivity_host("www.google.com")
```

Install error handler that just prints the errors
```lua
local function my_error_handler(source, message, traceback)
  print(source)    --> lua
  print(message)   --> main/my.script:10: attempt to perform arithmetic on a string value
  print(traceback) --> stack traceback:
                   -->         main/test.script:10: in function 'boom'
                   -->         main/test.script:15: in function
end

local function boom()
  return 10 + "string"
end

function init(self)
  sys.set_error_handler(my_error_handler)
  boom()
end
```

Setting the update frequency to 60 frames per second
```lua
sys.set_update_frequency(60)
```

Setting the swap intervall to swap every v-blank
```lua
sys.set_vsync_swap_interval(1)
```


## Tilemap API documentation
Functions and messages used to manipulate tile map components.

```lua
-- Functions
tilemap.get_bounds(url) -- get the bounds of a tile map
tilemap.get_tile(url, layer, x, y) -- get a tile from a tile map
tilemap.get_tile_info(url, layer, x, y) -- get full information for a tile from a tile map
tilemap.get_tiles(url, layer) -- get all the tiles from a layer in a tilemap
tilemap.set_tile(url, layer, x, y, tile, [transform_bitmask]) -- set a tile in a tile map
tilemap.set_visible(url, layer, visible) -- set the visibility of a layer

-- Constants
tilemap.H_FLIP -- flip tile horizontally
tilemap.ROTATE_180 -- rotate tile 180 degrees clockwise
tilemap.ROTATE_270 -- rotate tile 270 degrees clockwise
tilemap.ROTATE_90 -- rotate tile 90 degrees clockwise
tilemap.V_FLIP -- flip tile vertically
```

### Component properties
- `material` (hash) - tile map material
- `tile_source` (hash) - tile source

### Examples

Example for tilemap.get_bounds(url):
```lua
-- get the level bounds.
local x, y, w, h = tilemap.get_bounds("/level#tilemap")
```

Example for tilemap.get_tile(url, layer, x, y):
```lua
-- get the tile under the player.
local tileno = tilemap.get_tile("/level#tilemap", "foreground", self.player_x, self.player_y)
```

Example for tilemap.get_tile_info(url, layer, x, y):
```lua
-- get the tile under the player.
local tile_info = tilemap.get_tile_info("/level#tilemap", "foreground", self.player_x, self.player_y)
pprint(tile_info)
-- {
--    index = 0,
--    h_flip = false,
--    v_flip = true,
--    rotate_90 = false
-- }
```

Example for tilemap.get_tiles(url, layer):
```lua
local left, bottom, columns_count, rows_count = tilemap.get_bounds("#tilemap")
local tiles = tilemap.get_tiles("#tilemap", "layer")
local tile, count = 0, 0
for row_index = bottom, bottom + rows_count - 1 do
    for column_index = left, left + columns_count - 1 do
        tile = tiles[row_index][column_index]
        count = count + 1
    end
end
```

Example for tilemap.set_tile(url, layer, x, y, tile, [transform_bitmask]):
```lua
-- Clear the tile under the player.
tilemap.set_tile("/level#tilemap", "foreground", self.player_x, self.player_y, 0)

-- Set tile with different combination of flip and rotation
tilemap.set_tile("#tilemap", "layer1", x, y, 0, tilemap.H_FLIP + tilemap.V_FLIP + tilemap.ROTATE_90)
tilemap.set_tile("#tilemap", "layer1", x, y, 0, tilemap.H_FLIP + tilemap.ROTATE_270)
tilemap.set_tile("#tilemap", "layer1", x, y, 0, tilemap.V_FLIP + tilemap.H_FLIP)
tilemap.set_tile("#tilemap", "layer1", x, y, 0, tilemap.ROTATE_180)
```

Example for tilemap.set_visible(url, layer, visible):
```lua
-- Disable rendering of the layer
tilemap.set_visible("/level#tilemap", "foreground", false)
```


## Timer API documentation
Timers allow you to set a delay and a callback to be called when the timer completes.
The timers created with this API are updated with the collection timer where they
are created. If you pause or speed up the collection (using <code>set_time_step</code>) it will
also affect the new timer.

```lua
-- Functions
timer.cancel(handle) -- cancel a timer
timer.delay(delay, repeating, callback) -- create a timer
timer.get_info(handle) -- get information about timer
timer.trigger(handle) -- trigger a callback

-- Constants
timer.INVALID_TIMER_HANDLE -- Indicates an invalid timer handle
```

### Examples

Example for timer.cancel(handle):
```lua
self.handle = timer.delay(1, true, function() print("print every second") end)
...
local result = timer.cancel(self.handle)
if not result then
   print("the timer is already cancelled")
end
```

A simple one-shot timer
```lua
timer.delay(1, false, function() print("print in one second") end)
```

Repetitive timer which canceled after 10 calls
```lua
local function call_every_second(self, handle, time_elapsed)
  self.counter = self.counter + 1
  print("Call #", self.counter)
  if self.counter == 10 then
    timer.cancel(handle) -- cancel timer after 10 calls
  end
end

self.counter = 0
timer.delay(1, true, call_every_second)
```

Example for timer.get_info(handle):
```lua
self.handle = timer.delay(1, true, function() print("print every second") end)
...
local result = timer.get_info(self.handle)
if not result then
   print("the timer is already cancelled or complete")
else
   pprint(result) -- delay, time_remaining, repeating
end
```

Example for timer.trigger(handle):
```lua
self.handle = timer.delay(1, true, function() print("print every second or manually by timer.trigger") end)
...
local result = timer.trigger(self.handle)
if not result then
   print("the timer is already cancelled or complete")
end
```


## Types API documentation
Functions for checking Defold userdata types.

```lua
-- Functions
types.is_hash(var) -- Check if passed type is hash.
types.is_matrix4(var) -- Check if passed type is matrix4.
types.is_quat(var) -- Check if passed type is quaternion.
types.is_url(var) -- Check if passed type is URL.
types.is_vector(var) -- Check if passed type is vector.
types.is_vector3(var) -- Check if passed type is vector3.
types.is_vector4(var) -- Check if passed type is vector4.
```

## Vector math API documentation
Functions for mathematical operations on vectors, matrices and quaternions.
<ul>
<li>The vector types (<code>vmath.vector3</code> and <code>vmath.vector4</code>) supports addition and subtraction
  with vectors of the same type. Vectors can be negated and multiplied (scaled) or divided by numbers.</li>
<li>The quaternion type (<code>vmath.quat</code>) supports multiplication with other quaternions.</li>
<li>The matrix type (<code>vmath.matrix4</code>) can be multiplied with numbers, other matrices
  and <code>vmath.vector4</code> values.</li>
<li>All types performs equality comparison by each component value.</li>
</ul>
The following components are available for the various types:
<dl>
<dt>vector3</dt>
<dd><code>x</code>, <code>y</code> and <code>z</code>. Example: <code>v.y</code></dd>
<dt>vector4</dt>
<dd><code>x</code>, <code>y</code>, <code>z</code>, and <code>w</code>. Example: <code>v.w</code></dd>
<dt>quaternion</dt>
<dd><code>x</code>, <code>y</code>, <code>z</code>, and <code>w</code>. Example: <code>q.w</code></dd>
<dt>matrix4</dt>
<dd><code>m00</code> to <code>m33</code> where the first number is the row (starting from 0) and the second
number is the column. Columns can be accessed with <code>c0</code> to <code>c3</code>, returning a <code>vector4</code>.
Example: <code>m.m21</code> which is equal to <code>m.c1.z</code></dd>
<dt>vector</dt>
<dd>indexed by number 1 to the vector length. Example: <code>v[3]</code></dd>
</dl>

```lua
-- Functions
vmath.clamp(value, min, max) -- clamp input value in range [min, max] and return clamped value
vmath.conj(q1) -- calculates the conjugate of a quaternion
vmath.cross(v1, v2) -- calculates the cross-product of two vectors
vmath.dot(v1, v2) -- calculates the dot-product of two vectors
vmath.euler_to_quat(x, y, z) -- converts euler angles into a quaternion
vmath.inv(m1) -- calculates the inverse matrix.
vmath.length(v) -- calculates the length of a vector or quaternion
vmath.length_sqr(v) -- calculates the squared length of a vector or quaternion
vmath.lerp(t, v1, v2) -- lerps between two vectors
vmath.lerp(t, q1, q2) -- lerps between two quaternions
vmath.lerp(t, n1, n2) -- lerps between two numbers
vmath.matrix4() -- creates a new identity matrix
vmath.matrix4(m1) -- creates a new matrix from another existing matrix
vmath.matrix4_axis_angle(v, angle) -- creates a matrix from an axis and an angle
vmath.matrix4_compose(translation, rotation, scale) -- creates a new matrix4 from translation, rotation and scale
vmath.matrix4_frustum(left, right, bottom, top, near, far) -- creates a frustum matrix
vmath.matrix4_look_at(eye, look_at, up) -- creates a look-at view matrix
vmath.matrix4_orthographic(left, right, bottom, top, near, far) -- creates an orthographic projection matrix
vmath.matrix4_perspective(fov, aspect, near, far) -- creates a perspective projection matrix
vmath.matrix4_quat(q) -- creates a matrix from a quaternion
vmath.matrix4_rotation_x(angle) -- creates a matrix from rotation around x-axis
vmath.matrix4_rotation_y(angle) -- creates a matrix from rotation around y-axis
vmath.matrix4_rotation_z(angle) -- creates a matrix from rotation around z-axis
vmath.matrix4_scale(scale) -- creates a new matrix4 from scale vector
vmath.matrix4_scale(scale) -- creates a new matrix4 from uniform scale
vmath.matrix4_scale(scale_x, scale_y, scale_z) -- creates a new matrix4 from three scale components
vmath.matrix4_translation(position) -- creates a translation matrix from a position vector
vmath.mul_per_elem(v1, v2) -- performs an element wise multiplication of two vectors
vmath.normalize(v1) -- normalizes a vector
vmath.ortho_inv(m1) -- calculates the inverse of an ortho-normal matrix.
vmath.project(v1, v2) -- projects a vector onto another vector
vmath.quat() -- creates a new identity quaternion
vmath.quat(q1) -- creates a new quaternion from another existing quaternion
vmath.quat(x, y, z, w) -- creates a new quaternion from its coordinates
vmath.quat_axis_angle(v, angle) -- creates a quaternion to rotate around a unit vector
vmath.quat_basis(x, y, z) -- creates a quaternion from three base unit vectors
vmath.quat_from_to(v1, v2) -- creates a quaternion to rotate between two unit vectors
vmath.quat_matrix4(matrix) -- creates a new quaternion from matrix4
vmath.quat_rotation_x(angle) -- creates a quaternion from rotation around x-axis
vmath.quat_rotation_y(angle) -- creates a quaternion from rotation around y-axis
vmath.quat_rotation_z(angle) -- creates a quaternion from rotation around z-axis
vmath.quat_to_euler(q) -- converts a quaternion into euler angles
vmath.rotate(q, v1) -- rotates a vector by a quaternion
vmath.slerp(t, v1, v2) -- slerps between two vectors
vmath.slerp(t, q1, q2) -- slerps between two quaternions
vmath.vector(t) -- create a new vector from a table of values
vmath.vector3() -- creates a new zero vector
vmath.vector3(n) -- creates a new vector from scalar value
vmath.vector3(v1) -- creates a new vector from another existing vector
vmath.vector3(x, y, z) -- creates a new vector from its coordinates
vmath.vector4() -- creates a new zero vector
vmath.vector4(n) -- creates a new vector from scalar value
vmath.vector4(v1) -- creates a new vector from another existing vector
vmath.vector4(x, y, z, w) -- creates a new vector from its coordinates
```

### Examples

Example for vmath.clamp(value, min, max):
```lua
local value1 = 56
print(vmath.clamp(value1, 89, 134)) -> 89
local v2 = vmath.vector3(190, 190, -10)
print(vmath.clamp(v2, -50, 150)) -> vmath.vector3(150, 150, -10)
local v3 = vmath.vector4(30, -30, 45, 1)
print(vmath.clamp(v3, 0, 20)) -> vmath.vector4(20, 0, 20, 1)

local min_v = vmath.vector4(0, -10, -10, 1)
print(vmath.clamp(v3, min_v, 20)) -> vmath.vector4(20, -10, 20, 1)
```

Example for vmath.conj(q1):
```lua
local quat = vmath.quat(1, 2, 3, 4)
print(vmath.conj(quat)) --> vmath.quat(-1, -2, -3, 4)
```

Example for vmath.cross(v1, v2):
```lua
local vec1 = vmath.vector3(1, 0, 0)
local vec2 = vmath.vector3(0, 1, 0)
print(vmath.cross(vec1, vec2)) --> vmath.vector3(0, 0, 1)
local vec3 = vmath.vector3(-1, 0, 0)
print(vmath.cross(vec1, vec3)) --> vmath.vector3(0, -0, 0)
```

Example for vmath.dot(v1, v2):
```lua
if vmath.dot(vector1, vector2) == 0 then
    -- The two vectors are perpendicular (at right-angles to each other)
    ...
end
```

Example for vmath.euler_to_quat(x, y, z):
```lua
local q = vmath.euler_to_quat(0, 45, 90)
print(q) --> vmath.quat(0.27059805393219, 0.27059805393219, 0.65328145027161, 0.65328145027161)

local v = vmath.vector3(0, 0, 90)
print(vmath.euler_to_quat(v)) --> vmath.quat(0, 0, 0.70710676908493, 0.70710676908493)
```

Example for vmath.inv(m1):
```lua
local mat1 = vmath.matrix4_rotation_z(3.141592653)
local mat2 = vmath.inv(mat1)
-- M * inv(M) = identity matrix
print(mat1 * mat2) --> vmath.matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
```

Example for vmath.length(v):
```lua
if vmath.length(self.velocity) < max_velocity then
    -- The speed (velocity vector) is below max.

    -- TODO: max_velocity can be expressed as squared
    -- so we can compare with length_sqr() instead.
    ...
end
```

Example for vmath.length_sqr(v):
```lua
if vmath.length_sqr(vector1) < vmath.length_sqr(vector2) then
    -- Vector 1 has less magnitude than vector 2
    ...
end
```

Example for vmath.lerp(t, v1, v2):
```lua
function init(self)
    self.t = 0
end

function update(self, dt)
    self.t = self.t + dt
    if self.t <= 1 then
        local startpos = vmath.vector3(0, 600, 0)
        local endpos = vmath.vector3(600, 0, 0)
        local pos = vmath.lerp(self.t, startpos, endpos)
        go.set_position(pos, "go")
    end
end
```

Example for vmath.lerp(t, q1, q2):
```lua
function init(self)
    self.t = 0
end

function update(self, dt)
    self.t = self.t + dt
    if self.t <= 1 then
        local startrot = vmath.quat_rotation_z(0)
        local endrot = vmath.quat_rotation_z(3.141592653)
        local rot = vmath.lerp(self.t, startrot, endrot)
        go.set_rotation(rot, "go")
    end
end
```

Example for vmath.lerp(t, n1, n2):
```lua
function init(self)
    self.t = 0
end

function update(self, dt)
    self.t = self.t + dt
    if self.t <= 1 then
        local startx = 0
        local endx = 600
        local x = vmath.lerp(self.t, startx, endx)
        go.set_position(vmath.vector3(x, 100, 0), "go")
    end
end
```

Example for vmath.matrix4():
```lua
local mat = vmath.matrix4()
print(mat) --> vmath.matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
-- get column 0:
print(mat.c0) --> vmath.vector4(1, 0, 0, 0)
-- get the value in row 3 and column 2:
print(mat.m32) --> 0
```

Example for vmath.matrix4(m1):
```lua
local mat1 = vmath.matrix4_rotation_x(3.141592653)
local mat2 = vmath.matrix4(mat1)
if mat1 == mat2 then
    -- yes, they are equal
    print(mat2) --> vmath.matrix4(1, 0, 0, 0, 0, -1, 8.7422776573476e-08, 0, 0, -8.7422776573476e-08, -1, 0, 0, 0, 0, 1)
end
```

Example for vmath.matrix4_axis_angle(v, angle):
```lua
local vec = vmath.vector4(1, 1, 0, 0)
local axis = vmath.vector3(0, 0, 1) -- z-axis
local mat = vmath.matrix4_axis_angle(axis, 3.141592653)
print(mat * vec) --> vmath.vector4(-0.99999994039536, -1.0000001192093, 0, 0)
```

Example for vmath.matrix4_compose(translation, rotation, scale):
```lua
local translation = vmath.vector3(103, -95, 14)
local quat = vmath.quat(1, 2, 3, 4)
local scale = vmath.vector3(1, 0.5, 0.5)
local result = vmath.matrix4_compose(translation, quat, scale)
print(result) --> vmath.matrix4(-25, -10, 11, 103, 28, -9.5, 2, -95, -10, 10, -4.5, 14, 0, 0, 0, 1)
```

Example for vmath.matrix4_frustum(left, right, bottom, top, near, far):
```lua
-- Construct a projection frustum with a vertical and horizontal
-- FOV of 45 degrees. Useful for rendering a square view.
local proj = vmath.matrix4_frustum(-1, 1, -1, 1, 1, 1000)
render.set_projection(proj)
```

Example for vmath.matrix4_look_at(eye, look_at, up):
```lua
-- Set up a perspective camera at z 100 with 45 degrees (pi/2) FOV
-- Aspect ratio 4:3
local eye = vmath.vector3(0, 0, 100)
local look_at = vmath.vector3(0, 0, 0)
local up = vmath.vector3(0, 1, 0)
local view = vmath.matrix4_look_at(eye, look_at, up)
render.set_view(view)
local proj = vmath.matrix4_perspective(3.141592/2, 4/3, 1, 1000)
render.set_projection(proj)
```

Example for vmath.matrix4_orthographic(left, right, bottom, top, near, far):
```lua
-- Set up an orthographic projection based on the width and height
-- of the game window.
local w = render.get_width()
local h = render.get_height()
local proj = vmath.matrix4_orthographic(- w / 2, w / 2, -h / 2, h / 2, -1000, 1000)
render.set_projection(proj)
```

Example for vmath.matrix4_perspective(fov, aspect, near, far):
```lua
-- Set up a perspective camera at z 100 with 45 degrees (pi/2) FOV
-- Aspect ratio 4:3
local eye = vmath.vector3(0, 0, 100)
local look_at = vmath.vector3(0, 0, 0)
local up = vmath.vector3(0, 1, 0)
local view = vmath.matrix4_look_at(eye, look_at, up)
render.set_view(view)
local proj = vmath.matrix4_perspective(3.141592/2, 4/3, 1, 1000)
render.set_projection(proj)
```

Example for vmath.matrix4_quat(q):
```lua
local vec = vmath.vector4(1, 1, 0, 0)
local quat = vmath.quat_rotation_z(3.141592653)
local mat = vmath.matrix4_quat(quat)
print(mat * vec) --> vmath.matrix4_frustum(-1, 1, -1, 1, 1, 1000)
```

Example for vmath.matrix4_rotation_x(angle):
```lua
local vec = vmath.vector4(1, 1, 0, 0)
local mat = vmath.matrix4_rotation_x(3.141592653)
print(mat * vec) --> vmath.vector4(1, -1, -8.7422776573476e-08, 0)
```

Example for vmath.matrix4_rotation_y(angle):
```lua
local vec = vmath.vector4(1, 1, 0, 0)
local mat = vmath.matrix4_rotation_y(3.141592653)
print(mat * vec) --> vmath.vector4(-1, 1, 8.7422776573476e-08, 0)
```

Example for vmath.matrix4_rotation_z(angle):
```lua
local vec = vmath.vector4(1, 1, 0, 0)
local mat = vmath.matrix4_rotation_z(3.141592653)
print(mat * vec) --> vmath.vector4(-0.99999994039536, -1.0000001192093, 0, 0)
```

Example for vmath.matrix4_scale(scale):
```lua
local scale = vmath.vector3(1, 0.5, 0.5)
local result = vmath.matrix4_scale(scale)
print(result) --> vmath.matrix4(1, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1)
```

Example for vmath.matrix4_scale(scale):
```lua
local result = vmath.matrix4_scale(0.5)
print(result) --> vmath.matrix4(0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1)
```

Example for vmath.matrix4_scale(scale_x, scale_y, scale_z):
```lua
local result = vmath.matrix4_scale(1, 0.5, 0.5)
print(result) --> vmath.matrix4(1, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 1)
```

Example for vmath.matrix4_translation(position):
```lua
-- Set camera view from custom view and translation matrices
local mat_trans = vmath.matrix4_translation(vmath.vector3(0, 10, 100))
local mat_view  = vmath.matrix4_rotation_y(-3.141592/4)
render.set_view(mat_view * mat_trans)
```

Example for vmath.mul_per_elem(v1, v2):
```lua
local blend_color = vmath.mul_per_elem(color1, color2)
```

Example for vmath.normalize(v1):
```lua
local vec = vmath.vector3(1, 2, 3)
local norm_vec = vmath.normalize(vec)
print(norm_vec) --> vmath.vector3(0.26726123690605, 0.5345224738121, 0.80178368091583)
print(vmath.length(norm_vec)) --> 0.99999994039536
```

Example for vmath.ortho_inv(m1):
```lua
local mat1 = vmath.matrix4_rotation_z(3.141592653)
local mat2 = vmath.ortho_inv(mat1)
-- M * inv(M) = identity matrix
print(mat1 * mat2) --> vmath.matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
```

Example for vmath.project(v1, v2):
```lua
local v1 = vmath.vector3(1, 1, 0)
local v2 = vmath.vector3(2, 0, 0)
print(vmath.project(v1, v2)) --> 0.5
```

Example for vmath.quat():
```lua
local quat = vmath.quat()
print(quat) --> vmath.quat(0, 0, 0, 1)
print(quat.w) --> 1
```

Example for vmath.quat(q1):
```lua
local quat1 = vmath.quat(1, 2, 3, 4)
local quat2 = vmath.quat(quat1)
if quat1 == quat2 then
    -- yes, they are equal
    print(quat2) --> vmath.quat(1, 2, 3, 4)
end
```

Example for vmath.quat(x, y, z, w):
```lua
local quat = vmath.quat(1, 2, 3, 4)
print(quat) --> vmath.quat(1, 2, 3, 4)
```

Example for vmath.quat_axis_angle(v, angle):
```lua
local axis = vmath.vector3(1, 0, 0)
local rot = vmath.quat_axis_angle(axis, 3.141592653)
local vec = vmath.vector3(1, 1, 0)
print(vmath.rotate(rot, vec)) --> vmath.vector3(1, -1, -8.7422776573476e-08)
```

Example for vmath.quat_basis(x, y, z):
```lua
-- Axis rotated 90 degrees around z.
local rot_x = vmath.vector3(0, -1, 0)
local rot_y = vmath.vector3(1, 0, 0)
local z = vmath.vector3(0, 0, 1)
local rot1 = vmath.quat_basis(rot_x, rot_y, z)
local rot2 = vmath.quat_from_to(vmath.vector3(0, 1, 0), vmath.vector3(1, 0, 0))
if rot1 == rot2 then
    -- These quaternions are equal!
    print(rot2) --> vmath.quat(0, 0, -0.70710676908493, 0.70710676908493)
end
```

Example for vmath.quat_from_to(v1, v2):
```lua
local v1 = vmath.vector3(1, 0, 0)
local v2 = vmath.vector3(0, 1, 0)
local rot = vmath.quat_from_to(v1, v2)
print(vmath.rotate(rot, v1)) --> vmath.vector3(0, 0.99999994039536, 0)
```

Example for vmath.quat_rotation_x(angle):
```lua
local rot = vmath.quat_rotation_x(3.141592653)
local vec = vmath.vector3(1, 1, 0)
print(vmath.rotate(rot, vec)) --> vmath.vector3(1, -1, -8.7422776573476e-08)
```

Example for vmath.quat_rotation_y(angle):
```lua
local rot = vmath.quat_rotation_y(3.141592653)
local vec = vmath.vector3(1, 1, 0)
print(vmath.rotate(rot, vec)) --> vmath.vector3(-1, 1, 8.7422776573476e-08)
```

Example for vmath.quat_rotation_z(angle):
```lua
local rot = vmath.quat_rotation_z(3.141592653)
local vec = vmath.vector3(1, 1, 0)
print(vmath.rotate(rot, vec)) --> vmath.vector3(-0.99999988079071, -1, 0)
```

Example for vmath.quat_to_euler(q):
```lua
local q = vmath.quat_rotation_z(math.rad(90))
print(vmath.quat_to_euler(q)) --> 0 0 90

local q2 = vmath.quat_rotation_y(math.rad(45)) * vmath.quat_rotation_z(math.rad(90))
local v = vmath.vector3(vmath.quat_to_euler(q2))
print(v) --> vmath.vector3(0, 45, 90)
```

Example for vmath.rotate(q, v1):
```lua
local vec = vmath.vector3(1, 1, 0)
local rot = vmath.quat_rotation_z(3.141592563)
print(vmath.rotate(rot, vec)) --> vmath.vector3(-1.0000002384186, -0.99999988079071, 0)
```

Example for vmath.slerp(t, v1, v2):
```lua
function init(self)
    self.t = 0
end

function update(self, dt)
    self.t = self.t + dt
    if self.t <= 1 then
        local startpos = vmath.vector3(0, 600, 0)
        local endpos = vmath.vector3(600, 0, 0)
        local pos = vmath.slerp(self.t, startpos, endpos)
        go.set_position(pos, "go")
    end
end
```

Example for vmath.slerp(t, q1, q2):
```lua
function init(self)
    self.t = 0
end

function update(self, dt)
    self.t = self.t + dt
    if self.t <= 1 then
        local startrot = vmath.quat_rotation_z(0)
        local endrot = vmath.quat_rotation_z(3.141592653)
        local rot = vmath.slerp(self.t, startrot, endrot)
        go.set_rotation(rot, "go")
    end
end
```

How to create a vector with custom data to be used for animation easing:
```lua
local values = { 0, 0.5, 0 }
local vec = vmath.vector(values)
print(vec) --> vmath.vector (size: 3)
print(vec[2]) --> 0.5
```

Example for vmath.vector3():
```lua
local vec = vmath.vector3()
pprint(vec) --> vmath.vector3(0, 0, 0)
print(vec.x) --> 0
```

Example for vmath.vector3(n):
```lua
local vec = vmath.vector3(1.0)
print(vec) --> vmath.vector3(1, 1, 1)
print(vec.x) --> 1
```

Example for vmath.vector3(v1):
```lua
local vec1 = vmath.vector3(1.0)
local vec2 = vmath.vector3(vec1)
if vec1 == vec2 then
    -- yes, they are equal
    print(vec2) --> vmath.vector3(1, 1, 1)
end
```

Example for vmath.vector3(x, y, z):
```lua
local vec = vmath.vector3(1.0, 2.0, 3.0)
print(vec) --> vmath.vector3(1, 2, 3)
print(-vec) --> vmath.vector3(-1, -2, -3)
print(vec * 2) --> vmath.vector3(2, 4, 6)
print(vec + vmath.vector3(2.0)) --> vmath.vector3(3, 4, 5)
print(vec - vmath.vector3(2.0)) --> vmath.vector3(-1, 0, 1)
```

Example for vmath.vector4():
```lua
local vec = vmath.vector4()
print(vec) --> vmath.vector4(0, 0, 0, 0)
print(vec.w) --> 0
```

Example for vmath.vector4(n):
```lua
local vec = vmath.vector4(1.0)
print(vec) --> vmath.vector4(1, 1, 1, 1)
print(vec.w) --> 1
```

Example for vmath.vector4(v1):
```lua
local vect1 = vmath.vector4(1.0)
local vect2 = vmath.vector4(vec1)
if vec1 == vec2 then
    -- yes, they are equal
    print(vec2) --> vmath.vector4(1, 1, 1, 1)
end
```

Example for vmath.vector4(x, y, z, w):
```lua
local vec = vmath.vector4(1.0, 2.0, 3.0, 4.0)
print(vec) --> vmath.vector4(1, 2, 3, 4)
print(-vec) --> vmath.vector4(-1, -2, -3, -4)
print(vec * 2) --> vmath.vector4(2, 4, 6, 8)
print(vec + vmath.vector4(2.0)) --> vmath.vector4(3, 4, 5, 6)
print(vec - vmath.vector4(2.0)) --> vmath.vector4(-1, 0, 1, 2)
```


## Window API documentation
Functions and constants to access the window, window event listeners
and screen dimming.

```lua
-- Functions
window.get_dim_mode() -- get the mode for screen dimming
window.get_display_scale() -- get the display scale
window.get_mouse_lock() -- get the cursor lock state
window.get_size() -- get the window size
window.set_dim_mode(mode) -- set the mode for screen dimming
window.set_listener(callback) -- sets a window event listener
window.set_mouse_lock(flag) -- set the locking state for current mouse cursor
window.set_position(x, y) -- set the position of the window
window.set_size(width, height) -- set the size of the window
window.set_title(title) -- set the title of the window

-- Constants
window.DIMMING_OFF -- dimming mode off
window.DIMMING_ON -- dimming mode on
window.DIMMING_UNKNOWN -- dimming mode unknown
window.WINDOW_EVENT_DEICONIFIED -- deiconified window event
window.WINDOW_EVENT_FOCUS_GAINED -- focus gained window event
window.WINDOW_EVENT_FOCUS_LOST -- focus lost window event
window.WINDOW_EVENT_ICONFIED -- iconify window event
window.WINDOW_EVENT_RESIZED -- resized window event
```

### Examples

Example for window.set_listener(callback):
```lua
function window_callback(self, event, data)
    if event == window.WINDOW_EVENT_FOCUS_LOST then
        print("window.WINDOW_EVENT_FOCUS_LOST")
    elseif event == window.WINDOW_EVENT_FOCUS_GAINED then
        print("window.WINDOW_EVENT_FOCUS_GAINED")
    elseif event == window.WINDOW_EVENT_ICONFIED then
        print("window.WINDOW_EVENT_ICONFIED")
    elseif event == window.WINDOW_EVENT_DEICONIFIED then
        print("window.WINDOW_EVENT_DEICONIFIED")
    elseif event == window.WINDOW_EVENT_RESIZED then
        print("Window resized: ", data.width, data.height)
    end
end

function init(self)
    window.set_listener(window_callback)
end
```


## Zlib compression API documentation
Functions for compression and decompression of string buffers.

```lua
-- Functions
zlib.deflate(buf) -- Deflate (compress) a buffer
zlib.inflate(buf) -- Inflate (decompress) a buffer
```

### Examples

Example for zlib.deflate(buf):
```lua
local data = "This is a string with uncompressed data."
local compressed_data = zlib.deflate(data)
local s = ""
for c in string.gmatch(compressed_data, ".") do
    s = s .. '\\' .. string.byte(c)
end
print(s) --> \120\94\11\201\200\44\86\0\162\68\133\226\146\162 ...
```

Example for zlib.inflate(buf):
```lua
local data = "\120\94\11\201\200\44\86\0\162\68\133\226\146\162\204\188\116\133\242\204\146\12\133\210\188\228\252\220\130\162\212\226\226\212\20\133\148\196\146\68\61\0\44\67\14\201"
local uncompressed_data = zlib.inflate(data)
print(uncompressed_data) --> This is a string with uncompressed data.
```


## Lua base standard library
Documentation for the Lua base standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
assert(v, [message]) -- asserts that condition is not nil and not false
collectgarbage([opt], [arg]) -- collects garbage
dofile([filename]) -- executes a Lua file
error(message, [level]) -- raises an error message
getfenv([f]) -- returns the current environment table
getmetatable(object) -- returns the metatable for the object
ipairs(t) -- iterates over a numerically keyed table
load(func, [chunkname]) -- loads a chunk by calling a function repeatedly
loadfile([filename]) -- loads a Lua file and parses it
loadstring(string, [chunkname]) -- compiles a string of Lua code
module(name, [...]) -- creates a Lua module
next(table, [index]) -- returns next key / value pair in a table
pairs(t) -- traverse all items in a table
pcall(f, arg1, ...) -- calls a function in protected mode
print(...) -- prints its arguments
rawequal(v1, v2) -- compares two values for equality without invoking metamethods
rawget(table, index) -- gets the value of a table item without invoking metamethods
rawset(table, index, value) -- sets the value of a table item without invoking metamethods
require(modname) -- loads a module
select(index, ...) -- returns items in a list
setfenv(f, table) -- sets a function's environment
setmetatable(table, metatable) -- sets the metatable for a table
tonumber(e, [base]) -- converts a string (of the given base) to a number
tostring(e) -- converts its argument to a string
type(v) -- returns the type of a variable
unpack(list, [i], [j]) -- unpacks a table into individual items
xpcall(f, err) -- calls a function with a custom error handler

-- Constants
_G -- global variable that holds the global environment
_VERSION -- global variable containing the running Lua version
```

## Bitwise operations API documentation
<a href="http://bitop.luajit.org/api.html">Lua BitOp</a> is a C extension module for Lua 5.1/5.2 which adds bitwise operations on numbers.
Lua BitOp is Copyright &copy; 2008-2012 Mike Pall.
Lua BitOp is free software, released under the MIT license (same license as the Lua core).
Lua BitOp is compatible with the built-in bitwise operations in LuaJIT 2.0 and is used
on platforms where Defold runs without LuaJIT.
For clarity the examples assume the definition of a helper function <code>printx()</code>.
This prints its argument as an unsigned 32 bit hexadecimal number on all platforms:
<div class="codehilite"><pre><span></span><code><span class="kr">function</span> <span class="nf">printx</span><span class="p">(</span><span class="n">x</span><span class="p">)</span>
  <span class="nb">print</span><span class="p">(</span><span class="s2">&quot;0x&quot;</span><span class="o">..</span><span class="n">bit</span><span class="p">.</span><span class="n">tohex</span><span class="p">(</span><span class="n">x</span><span class="p">))</span>
<span class="kr">end</span>
</code></pre></div>

```lua
-- Functions
bit.arshift(x, n) -- bitwise arithmetic right-shift
bit.band(x1, [x2...]) -- bitwise and
bit.bnot(x) -- bitwise not
bit.bor(x1, [x2...]) -- bitwise or
bit.bswap(x) -- bitwise swap
bit.bxor(x1, [x2...]) -- bitwise xor
bit.lshift(x, n) -- bitwise logical left-shift
bit.rol(x, n) -- bitwise left rotation
bit.ror(x, n) -- bitwise right rotation
bit.rshift(x, n) -- bitwise logical right-shift
bit.tobit(x) -- normalize number to the numeric range for bit operations
bit.tohex(x, n) -- convert number to a hex string
```

### Examples

Example for bit.arshift(x, n):
```lua
print(bit.arshift(256, 8))           --> 1
print(bit.arshift(-256, 8))          --> -1
printx(bit.arshift(0x87654321, 12))  --> 0xfff87654
```

Example for bit.band(x1, [x2...]):
```lua
printx(bit.band(0x12345678, 0xff))        --> 0x00000078
```

Example for bit.bnot(x):
```lua
print(bit.bnot(0))            --> -1
printx(bit.bnot(0))           --> 0xffffffff
print(bit.bnot(-1))           --> 0
print(bit.bnot(0xffffffff))   --> 0
printx(bit.bnot(0x12345678))  --> 0xedcba987
```

Example for bit.bor(x1, [x2...]):
```lua
print(bit.bor(1, 2, 4, 8))                --> 15
```

Example for bit.bswap(x):
```lua
printx(bit.bswap(0x12345678)) --> 0x78563412
printx(bit.bswap(0x78563412)) --> 0x12345678
```

Example for bit.bxor(x1, [x2...]):
```lua
printx(bit.bxor(0xa5a5f0f0, 0xaa55ff00))  --> 0x0ff00ff0
```

Example for bit.lshift(x, n):
```lua
print(bit.lshift(1, 0))              --> 1
print(bit.lshift(1, 8))              --> 256
print(bit.lshift(1, 40))             --> 256
printx(bit.lshift(0x87654321, 12))   --> 0x54321000
```

Example for bit.rol(x, n):
```lua
printx(bit.rol(0x12345678, 12))   --> 0x45678123
```

Example for bit.ror(x, n):
```lua
printx(bit.ror(0x12345678, 12))   --> 0x67812345
```

Example for bit.rshift(x, n):
```lua
print(bit.rshift(256, 8))            --> 1
print(bit.rshift(-256, 8))           --> 16777215
printx(bit.rshift(0x87654321, 12))   --> 0x00087654
```

Example for bit.tobit(x):
```lua
print(0xffffffff)                --> 4294967295 (*)
print(bit.tobit(0xffffffff))     --> -1
printx(bit.tobit(0xffffffff))    --> 0xffffffff
print(bit.tobit(0xffffffff + 1)) --> 0
print(bit.tobit(2^40 + 1234))    --> 1234
```

(*) See the treatment of hex literals for an explanation why the printed numbers in the first two lines differ (if your Lua installation uses a double number type).

Example for bit.tohex(x, n):
```lua
print(bit.tohex(1))              --> 00000001
print(bit.tohex(-1))             --> ffffffff
print(bit.tohex(0xffffffff))     --> ffffffff
print(bit.tohex(-1, -8))         --> FFFFFFFF
print(bit.tohex(0x21, 4))        --> 0021
print(bit.tohex(0x87654321, 4))  --> 4321
```


## Lua coroutine standard library
Documentation for the Lua coroutine standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
coroutine.create(f) -- creates a new coroutine thread
coroutine.resume(co, [val1], [...]) -- start or resume a thread
coroutine.running() -- returns the running coroutine
coroutine.status(co) -- returns the status of a thread
coroutine.wrap(f) -- creates a thread and returns a function to resume it
coroutine.yield(...) -- yields execution of thread back to the caller
```

## Lua debug standard library
Documentation for the Lua debug standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
debug.debug() -- enters interactive debugging
debug.getfenv(o) -- returns the environment of an object
debug.gethook([thread]) -- returns the current hook settings
debug.getinfo([thread], function, [what]) -- returns a table with information about a function
debug.getlocal([thread], level, local) -- returns name and value of a local variable
debug.getmetatable(object) -- returns the metatable of the given object
debug.getregistry() -- returns the registry table
debug.getupvalue(func, up) -- returns the name and value of an upvalue
debug.setfenv(object, table) -- sets the environment of an object
debug.sethook([thread], hook, mask, [count]) -- sets a debug hook function
debug.setlocal([thread], level, local, value) -- sets the value of the local variable
debug.setmetatable(object, table) -- sets the metatable for an object
debug.setupvalue(func, up, value) -- sets an upvalue for a function
debug.traceback([thread], [message], [level]) -- returns a string with a traceback of the stack call
```

## Lua io standard library
Documentation for the Lua io standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
file:close() -- closes a file
file:flush() -- flushes outstanding data to disk
file:lines() -- returns an iterator function for reading the file line-by-line
file:read(...) -- reads the file according to the specified formats
file:seek([whence], [offset]) -- sets and gets the current file position
file:setvbuf(mode, [size]) -- sets the buffering mode for an output file
file:write(...) -- writes to a file
io.close([file]) -- closes a file
io.flush() -- flushes outstanding data to disk for the default output file
io.input([file]) -- opens filename for input in text mode
io.lines([filename]) -- returns an iterator function for reading a named file line-by-line
io.open(filename, [mode]) -- opens a file
io.output([file]) -- opens a file for output
io.popen(prog, [mode]) -- creates a pipe and executes a command
io.read(...) -- reads from the default input file
io.tmpfile() -- returns a handle to a temporary file
io.type(obj) -- returns type of file handle
io.write(...) -- writes to the default output file
```

## LuaSocket API documentation
<a href="https://github.com/diegonehab/luasocket">LuaSocket</a> is a Lua extension library that provides
support for the TCP and UDP transport layers. Defold provides the "socket" namespace in
runtime, which contain the core C functionality. Additional LuaSocket support modules for
SMTP, HTTP, FTP etc are not part of the core included, but can be easily added to a project
and used.
Note the included helper module "socket.lua" in "builtins/scripts/socket.lua". Require this
module to add some additional functions and shortcuts to the namespace:
<div class="codehilite"><pre><span></span><code><span class="nb">require</span> <span class="s2">&quot;builtins.scripts.socket&quot;</span>
</code></pre></div>

LuaSocket is Copyright &copy; 2004-2007 Diego Nehab. All rights reserved.
LuaSocket is free software, released under the MIT license (same license as the Lua core).

```lua
-- Functions
client:close() -- closes a client TCP object
client:dirty() -- checks the read buffer status
client:getfd() -- gets the socket descriptor
client:getoption(option) -- gets options for the socket
client:getpeername() -- gets information about a client's peer
client:getsockname() -- gets the local address information from client
client:getstats() -- gets accounting information on the socket
client:receive([pattern], [prefix]) -- receives data from a client socket
client:send(data, [i], [j]) -- sends data through client socket
client:setfd(handle) -- sets the socket descriptor
client:setoption(option, [value]) -- sets options for the socket
client:setstats(received, sent, age) -- resets accounting information on the socket
client:settimeout(value, [mode]) -- set the timeout values for the socket
client:shutdown(mode) -- shut down socket
connected:close() -- closes the UDP socket
connected:getoption(option) -- gets options for the UDP socket
connected:getpeername() -- gets information about the UDP socket peer
connected:getsockname() -- gets the local address information associated to the socket
connected:receive([size]) -- receives a datagram from the UDP socket
connected:send(datagram) -- sends a datagram through the connected UDP socket
connected:setoption(option, [value]) -- sets options for the UDP socket
connected:setpeername("*") -- remove the peer of the connected UDP socket
connected:settimeout(value) -- sets the timeout value for the UDP socket
master:bind(address, port) -- binds a master object to address and port on the local host
master:close() -- closes a master TCP object
master:connect(address, port) -- connects a master object to a remote host
master:dirty() -- checks the read buffer status
master:getfd() -- gets the socket descriptor
master:getsockname() -- gets the local address information from master
master:getstats() -- gets accounting information on the socket
master:listen(backlog) -- makes the master socket listen for connections
master:setfd(handle) -- sets the socket descriptor
master:setstats(received, sent, age) -- resets accounting information on the socket
master:settimeout(value, [mode]) -- set the timeout values for the socket
server:accept() -- waits for a remote connection on the server object
server:close() -- closes a server TCP object
server:dirty() -- checks the read buffer status
server:getfd() -- gets the socket descriptor
server:getoption(option) -- gets options for the socket
server:getsockname() -- gets the local address information from server
server:getstats() -- gets accounting information on the socket
server:setfd(handle) -- sets the socket descriptor
server:setoption(option, [value]) -- sets options for the socket
server:setstats(received, sent, age) -- resets accounting information on the socket
server:settimeout(value, [mode]) -- set the timeout values for the socket
socket.connect(address, port, [locaddr], [locport], [family]) -- creates a new connected TCP client object
socket.dns.getaddrinfo(address) -- resolve to IPv4 or IPv6 address
socket.dns.gethostname() -- gets the machine host name
socket.dns.getnameinfo(address) -- resolve to hostname (IPv4 or IPv6)
socket.dns.tohostname(address) -- resolve to host name (IPv4)
socket.dns.toip(address) -- resolve to IPv4 address
socket.gettime() -- gets seconds since system epoch
socket.newtry(finalizer) -- creates a new try function
socket.protect(func) -- converts a function that throws exceptions into a safe function
socket.select(recvt, sendt, [timeout]) -- waits for a number of sockets to change status
socket.skip(d, [ret1], [ret2], [retN]) -- drops a number of arguments and returns the remaining
socket.sleep(time) -- sleeps for a number of seconds
socket.tcp() -- creates a new IPv4 TCP master object
socket.tcp6() -- creates a new IPv6 TCP master object
socket.udp() -- creates a new IPv4 UDP object
socket.udp6() -- creates a new IPv6 UDP object
unconnected:close() -- closes the UDP socket
unconnected:getoption(option) -- gets options for the UDP socket
unconnected:getsockname() -- gets the local address information associated to the socket
unconnected:receive([size]) -- receives a datagram from the UDP socket
unconnected:receivefrom([size]) -- receives a datagram from the UDP socket
unconnected:sendto(datagram, ip, port) -- sends a datagram through the UDP socket to the specified IP address and port number
unconnected:setoption(option, [value]) -- sets options for the UDP socket
unconnected:setpeername(address, port) -- set the peer of the unconnected UDP socket
unconnected:setsockname(address, port) -- binds the UDP socket to a local address
unconnected:settimeout(value) -- sets the timeout value for the UDP socket

-- Constants
socket._SETSIZE -- max numbers of sockets the select function can handle
socket._VERSION -- the current LuaSocket version
```

### Examples

How to use the gettime() function to measure running time:
```lua
t = socket.gettime()
-- do stuff
print(socket.gettime() - t .. " seconds elapsed")
```

Perform operations on an open socket c:
```lua
-- create a try function that closes 'c' on error
local try = socket.newtry(function() c:close() end)
-- do everything reassured c will be closed
try(c:send("hello there?\r\n"))
local answer = try(c:receive())
...
try(c:send("good bye\r\n"))
c:close()
```

Example for socket.protect(func):
```lua
local dostuff = socket.protect(function()
    local try = socket.newtry()
    local c = try(socket.connect("myserver.com", 80))
    try = socket.newtry(function() c:close() end)
    try(c:send("hello?\r\n"))
    local answer = try(c:receive())
    c:close()
end)

local n, error = dostuff()
```

Instead of doing the following with dummy variables:
```lua
-- get the status code and separator from SMTP server reply
local dummy1, dummy2, code, sep = string.find(line, "^(%d%d%d)(.?)")
```

You can skip a number of variables:
```lua
-- get the status code and separator from SMTP server reply
local code, sep = socket.skip(2, string.find(line, "^(%d%d%d)(.?)"))
```


## Lua math standard library
Documentation for the Lua math standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
math.abs(x) -- absolute value
math.acos(x) -- arc cosine
math.asin(x) -- arc sine
math.atan(x) -- arc tangent
math.atan2(y, x) -- arc tangent of v1/v2
math.ceil(x) -- next higher integer value
math.cos(x) -- cosine
math.cosh(x) -- hyperbolic cosine
math.deg(x) -- convert from radians to degrees
math.exp(x) -- raises e to a power
math.floor(x) -- next smaller integer value
math.fmod(x, y) -- the modulus (remainder) of doing: v1 / v2
math.frexp(x) -- break number into mantissa and exponent
math.ldexp(m, e) -- compute m* 2^n
math.log(x) -- natural log
math.log10(x) -- log to the base 10
math.max(x, ...) -- the highest of one or more numbers
math.min(x, ...) -- the lowest of one or more numbers
math.modf(x) -- returns the integral and fractional part of its argument
math.pow(x, y) -- raise a number to a power
math.rad(x) -- convert degrees to radians
math.random([m], [n]) -- generate a random number
math.randomseed(x) -- seeds the random number generator
math.sin(x) -- sine
math.sinh(x) -- hyperbolic sine
math.sqrt(x) -- square root
math.tan(x) -- tangent
math.tanh(x) -- hyperbolic tangent

-- Constants
math.huge -- a huge value
math.pi -- the value of pi
```

## Lua os standard library
Documentation for the Lua os standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
os.clock() -- amount of elapsed/CPU time used (depending on OS)
os.date([format], [time]) -- formats a date/time string
os.difftime(t2, t1) -- calculates a time difference in seconds
os.execute([command]) -- executes an operating system command
os.exit([code]) -- attempts to terminate the process
os.getenv(varname) -- returns an operating system environment variable
os.remove(filename) -- deletes a file
os.rename(oldname, newname) -- renames a file
os.setlocale(locale, [category]) -- sets the current locale to the supplied locale
os.time([table]) -- returns the current time or calculates the time in seconds from a table
os.tmpname() -- returns a name for a temporary file
```

## Lua package standard library
Documentation for the Lua package standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
package.cpath() -- search path used for loading DLLs using the <code>require</code> function
package.loaded() -- table of loaded packages
package.loaders() -- table of package loaders
package.loadlib(libname, funcname) -- loads a dynamic link library (DLL)
package.path() -- search path used for loading Lua code using the <code>require</code> function
package.preload() -- a table of special function loaders
package.seeall(module) -- sets a metatable for the module so it can see global variables
```

## Lua string standard library
Documentation for the Lua string standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.
<h3>Patterns</h3>
<em>Character Class:</em>
A character class is used to represent a set of characters.
The following combinations are allowed in describing a character class:
<dl>
<dt>x</dt>
<dd>(where x is not one of the <em>magic characters</em> <code>^$()%.[]*+-?</code>)
  represents the character <em>x</em> itself.</dd>
<dt><code>.</code></dt>
<dd>(a dot) represents all characters.</dd>
<dt><code>%a</code></dt>
<dd>represents all letters.</dd>
<dt><code>%c</code></dt>
<dd>represents all control characters.</dd>
<dt><code>%d</code></dt>
<dd>represents all digits.</dd>
<dt><code>%l</code></dt>
<dd>represents all lowercase letters.</dd>
<dt><code>%p</code></dt>
<dd>represents all punctuation characters.</dd>
<dt><code>%s</code></dt>
<dd>represents all space characters.</dd>
<dt><code>%u</code></dt>
<dd>represents all uppercase letters.</dd>
<dt><code>%w</code></dt>
<dd>represents all alphanumeric characters.</dd>
<dt><code>%x</code></dt>
<dd>represents all hexadecimal digits.</dd>
<dt><code>%z</code></dt>
<dd>represents the character with representation 0.</dd>
<dt><code>%x</code></dt>
<dd>(where x is any non-alphanumeric character) represents the character x.
  This is the standard way to escape the magic characters.
  Any punctuation character (even the non magic) can be preceded by a '%'
  when used to represent itself in a pattern.</dd>
<dt><code>[set]</code></dt>
<dd>represents the class which is the union of all characters in set.
  A range of characters can be specified by separating the end characters
  of the range with a '-'.
  All classes <code>%</code><em>x</em> described above can also be used as components in set.
  All other characters in set represent themselves.
  For example, <code>[%w_]</code> (or <code>[_%w]</code>) represents all alphanumeric characters
  plus the underscore, <code>[0-7]</code> represents the octal digits,
  and <code>[0-7%l%-]</code> represents the octal digits plus the lowercase letters
  plus the '-' character.</dd>
</dl>
The interaction between ranges and classes is not defined.
  Therefore, patterns like <code>[%a-z]</code> or <code>[a-%%]</code> have no meaning.
<dl>
<dt><code>[^set]</code></dt>
<dd>represents the complement of set,
  where set is interpreted as above.</dd>
</dl>
For all classes represented by single letters (<code>%a</code>, <code>%c</code>, etc.),
the corresponding uppercase letter represents the complement of the class.
For instance, <code>%S</code> represents all non-space characters.
The definitions of letter, space, and other character groups
depend on the current locale. In particular, the class <code>[a-z]</code> may not be
equivalent to <code>%l</code>.
<em>Pattern Item:</em>
A pattern item can be
<ul>
<li>
a single character class, which matches any single character in the class;
</li>
<li>
a single character class followed by '*',
  which matches 0 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence;
</li>
<li>
a single character class followed by '+',
  which matches 1 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence;
</li>
<li>
a single character class followed by '-',
  which also matches 0 or more repetitions of characters in the class.
  Unlike '*', these repetition items will always match the <em>shortest</em>
  possible sequence;
</li>
<li>
a single character class followed by '?',
  which matches 0 or 1 occurrence of a character in the class;
</li>
<li>
<code>%n</code>, for n between 1 and 9; such item matches a substring equal to the
  n-th captured string (see below);
</li>
<li>
<code>%bxy</code>, where x and y are two distinct characters;
  such item matches strings that start with x, end with y,
  and where the x and y are <em>balanced</em>.
  This means that, if one reads the string from left to right,
  counting +1 for an x and -1 for a y,
  the ending y is the first y where the count reaches 0.
  For instance, the item <code>%b()</code> matches expressions with balanced parentheses.
</li>
</ul>
<em>Pattern:</em>
A pattern is a sequence of pattern items.
A '^' at the beginning of a pattern anchors the match at the
beginning of the subject string.
A '$' at the end of a pattern anchors the match at the
end of the subject string.
At other positions, '^' and '$' have no special meaning and represent themselves.
<em>Captures:</em>
A pattern can contain sub-patterns enclosed in parentheses;
they describe captures.
When a match succeeds, the substrings of the subject string
that match captures are stored (<em>captured</em>) for future use.
Captures are numbered according to their left parentheses.
For instance, in the pattern <code>"(a*(.)%w(%s*))"</code>,
the part of the string matching <code>"a*(.)%w(%s*)"</code> is
stored as the first capture (and therefore has number 1);
the character matching "." is captured with number 2,
and the part matching "%s*" has number 3.
As a special case, the empty capture <code>()</code> captures
the current string position (a number).
For instance, if we apply the pattern <code>"()aa()"</code> on the
string <code>"flaaap"</code>, there will be two captures: 3 and 5.
A pattern cannot contain embedded zeros.  Use <code>%z</code> instead.

```lua
-- Functions
string.byte(s, [i], [j]) -- converts a character into its ASCII (decimal) equivalent
string.char(...) -- converts ASCII codes into their equivalent characters
string.dump(function) -- converts a function into binary
string.find(s, pattern, [init], [plain]) -- searches a string for a pattern
string.format(formatstring, ...) -- formats a string
string.gmatch(s, pattern) -- iterate over a string
string.gsub(s, pattern, repl, [n]) -- substitute strings inside another string
string.len(s) -- return the length of a string
string.lower(s) -- converts a string to lower-case
string.match(s, pattern, [init]) -- searches a string for a pattern
string.rep(s, n) -- returns repeated copies of a string
string.reverse(s) -- reverses the order of characters in a string
string.sub(s, i, [j]) -- returns a substring of a string
string.upper(s) -- converts a string to upper-case
```

## Lua table standard library
Documentation for the Lua table standard library.
From <a href="https://www.lua.org/manual/5.1/">Lua 5.1 Reference Manual</a>
by Roberto Ierusalimschy, Luiz Henrique de Figueiredo, Waldemar Celes.
Copyright &copy; 2006-2012 Lua.org, PUC-Rio.
Freely available under the terms of the <a href="https://www.lua.org/license.html">Lua license</a>.

```lua
-- Functions
table.concat(table, [sep], [i], [j]) -- concatenates table items together into a string
table.insert(table, [pos], value) -- inserts a new item into a numerically-keyed table
table.maxn(table) -- returns the highest numeric key in the table
table.remove(table, [pos]) -- removes an item from a numerically-keyed table
table.sort(table, [comp]) -- Sorts a table
```

## adinfo (extension)
> The extension needs to be added to the game.project file manually as dependency.

Provides functionality to get the advertising id and tracking status. Supported on iOS and Android. [icon:ios] [icon:android]

```lua
-- Functions
adinfo.get() -- Get a table with advertising information. [icon:attention] function returns nil if values do not ready
```

### Examples

Example for adinfo.get():
```lua
function init(self)
    adinfo.get(function(self, info)
      print(info.ad_ident, info.ad_tracking_enabled)
    end)
end
```


## admob (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with [Google AdMob APIs](https://developers.google.com/admob)

```lua
-- Functions
admob.initialize()
admob.set_callback(callback) -- Sets a callback function for receiving events from the SDK. Call `admob.set_callback(nil)` to remove callback
admob.set_privacy_settings(bool) -- Sets user privacy preferences (must be called before `admob.initialize()`). Original docs [Android](https://developers.google.com/admob/android/ccpa), [iOS](https://developers.google.com/admob/ios/ccpa)
admob.request_idfa() -- Display the App Tracking Transparency authorization request for accessing the IDFA. Original docs [iOS](https://developers.google.com/admob/ios/ios14#request)
admob.show_ad_inspector() -- Show Ad Inspector. This is an in-app overlay that enables authorized devices to perform realtime analysis of test ad requests directly within a mobile app. Ad Inspector only launces on [test devices](https://support.google.com/admob/answer/9691433). Original docs [Android](https://developers.google.com/admob/android/ad-inspector), [iOS](https://developers.google.com/admob/ios/ad-inspector)
admob.load_appopen(ad_unit_id) -- Starts loading an AppOpen Ad, can only be called after `admob.MSG_INITIALIZATION` event Original docs [Android](https://developers.google.com/admob/android/app-open), [iOS](https://developers.google.com/admob/ios/app-open)
admob.show_appopen() -- Shows loaded AppOpen Ad, can only be called after `admob.EVENT_LOADED` Original docs [Android](https://developers.google.com/admob/android/app-open), [iOS](https://developers.google.com/admob/ios/app-open)
admob.is_appopen_loaded() -- Checks if AppOpen Ad is loaded and ready to show Original docs [Android](https://developers.google.com/admob/android/app-open), [iOS](https://developers.google.com/admob/ios/app-open)
admob.load_interstitial(ad_unit_id) -- Starts loading an Interstitial Ad, can only be called after `admob.MSG_INITIALIZATION` event Original docs [Android](https://developers.google.com/admob/android/interstitial-fullscreen), [iOS](https://developers.google.com/admob/ios/interstitial)
admob.show_interstitial() -- Shows loaded Interstitial Ad, can only be called after `admob.EVENT_LOADED` Original docs [Android](https://developers.google.com/admob/android/interstitial-fullscreen), [iOS](https://developers.google.com/admob/ios/interstitial)
admob.is_interstitial_loaded() -- Checks if Interstitial Ad is loaded and ready to show Original docs [Android](https://developers.google.com/admob/android/interstitial-fullscreen), [iOS](https://developers.google.com/admob/ios/interstitial)
admob.load_rewarded(ad_unit_id) -- Starts loading a Rewarded Ad, can only be called after `admob.MSG_INITIALIZATION` event Original docs [Android](https://developers.google.com/admob/android/rewarded-fullscreen), [iOS](https://developers.google.com/admob/ios/rewarded-ads)
admob.show_rewarded() -- Shows loaded Rewarded Ad, can only be called after `admob.EVENT_LOADED` Original docs [Android](https://developers.google.com/admob/android/rewarded-fullscreen), [iOS](https://developers.google.com/admob/ios/rewarded-ads)
admob.is_rewarded_loaded() -- Checks if Rewarded Ad is loaded and ready to show Original docs [Android](https://developers.google.com/admob/android/rewarded-fullscreen), [iOS](https://developers.google.com/admob/ios/rewarded-ads)
admob.load_rewarded_interstitial(ad_unit_id) -- Starts loading a Rewarded Interstitial Ad, can only be called after `admob.MSG_INITIALIZATION` event Original docs [Android](https://developers.google.com/admob/android/rewarded-interstitial#load_an_ad), [iOS](https://developers.google.com/admob/ios/rewarded-interstitial#load_an_ad)
admob.show_rewarded_interstitial() -- Shows loaded Rewarded Interstitial Ad, can only be called after `admob.EVENT_LOADED` Original docs [Android](https://developers.google.com/admob/android/rewarded-interstitial#show_the_ad), [iOS](https://developers.google.com/admob/ios/rewarded-interstitial#display_the_ad_and_handle_the_reward_event)
admob.is_rewarded_interstitial_loaded() -- Checks if Rewarded Interstitial Ad is loaded and ready to show Original docs [Android](https://developers.google.com/admob/android/rewarded-interstitial), [iOS](https://developers.google.com/admob/ios/rewarded-interstitial)
admob.load_banner(ad_unit_id, size) -- Starts loading a Banner Ad, can only be called after `admob.MSG_INITIALIZATION` event Original docs [Android](https://developers.google.com/admob/android/banner), [iOS](https://developers.google.com/admob/ios/banner)
admob.show_banner(position) -- Shows loaded Banner Ad, can only be called after `admob.EVENT_LOADED` Original docs [Android](https://developers.google.com/admob/android/banner), [iOS](https://developers.google.com/admob/ios/banner)
admob.set_max_ad_content_rating(max_ad_rating) -- Sets a maximum ad content rating. AdMob ads returned for your app will have a content rating at or below that level. Original docs [Android](https://developers.google.com/admob/android/targeting#ad_content_filtering), [iOS](https://developers.google.com/admob/ios/targeting#ad_content_filtering)
admob.hide_banner() -- Temporarily hides Banner Ad, banner can be shown again using `admob.show_banner()` Original docs [Android](https://developers.google.com/admob/android/banner), [iOS](https://developers.google.com/admob/ios/banner)
admob.is_banner_loaded() -- Checks if Banner Ad is loaded and ready to show Original docs [Android](https://developers.google.com/admob/android/banner), [iOS](https://developers.google.com/admob/ios/banner)
admob.destroy_banner() -- Hides and unloads Banner Ad (needs to call `admob.load_banner()` later to show Banner Ad) Original docs [Android](https://developers.google.com/admob/android/banner), [iOS](https://developers.google.com/admob/ios/banner)

-- Constants
admob.MSG_INITIALIZATION
admob.MSG_INTERSTITIAL
admob.MSG_REWARDED
admob.MSG_BANNER
admob.MSG_IDFA
admob.MSG_REWARDED_INTERSTITIAL
admob.MSG_APPOPEN
admob.EVENT_CLOSED
admob.EVENT_FAILED_TO_SHOW
admob.EVENT_OPENING
admob.EVENT_FAILED_TO_LOAD
admob.EVENT_LOADED
admob.EVENT_NOT_LOADED
admob.EVENT_EARNED_REWARD
admob.EVENT_COMPLETE
admob.EVENT_CLICKED
admob.EVENT_DESTROYED
admob.EVENT_JSON_ERROR
admob.EVENT_IMPRESSION_RECORDED
admob.EVENT_STATUS_AUTHORIZED
admob.EVENT_STATUS_DENIED
admob.EVENT_STATUS_NOT_DETERMINED
admob.EVENT_STATUS_RESTRICTED
admob.EVENT_NOT_SUPPORTED
admob.SIZE_ADAPTIVE_BANNER
admob.SIZE_BANNER
admob.SIZE_FLUID
admob.SIZE_FULL_BANNER
admob.SIZE_LARGE_BANNER
admob.SIZE_LEADEARBOARD
admob.SIZE_MEDIUM_RECTANGLE
admob.SIZE_SEARH
admob.SIZE_SKYSCRAPER
admob.SIZE_SMART_BANNER
admob.POS_NONE
admob.POS_TOP_LEFT
admob.POS_TOP_CENTER
admob.POS_TOP_RIGHT
admob.POS_BOTTOM_LEFT
admob.POS_BOTTOM_CENTER
admob.POS_BOTTOM_RIGHT
admob.POS_CENTER
admob.MAX_AD_CONTENT_RATING_G
admob.MAX_AD_CONTENT_RATING_PG
admob.MAX_AD_CONTENT_RATING_T
admob.MAX_AD_CONTENT_RATING_MA
```

### Examples

Example for admob.set_callback(callback):
```lua
local function admob_callback(self, message_id, message)
    pprint(message_id, message)
    if message_id == admob.MSG_INITIALIZATION then
       if message.event == admob.EVENT_COMPLETE then
           print("EVENT_COMPLETE: Initialization complete")
       elseif message.event == admob.EVENT_JSON_ERROR then
           print("EVENT_JSON_ERROR: Internal NE json error "..message.error)
       end
   elseif message_id == admob.MSG_IDFA then
       if message.event == admob.EVENT_STATUS_AUTHORIZED then
           print("EVENT_STATUS_AUTHORIZED: ATTrackingManagerAuthorizationStatusAuthorized")
       elseif message.event == admob.EVENT_STATUS_DENIED then
           print("EVENT_STATUS_DENIED: ATTrackingManagerAuthorizationStatusDenied")
       elseif message.event == admob.EVENT_STATUS_NOT_DETERMINED then
           print("EVENT_STATUS_NOT_DETERMINED: ATTrackingManagerAuthorizationStatusNotDetermined")
       elseif message.event == admob.EVENT_STATUS_RESTRICTED then
           print("EVENT_STATUS_RESTRICTED: ATTrackingManagerAuthorizationStatusRestricted")
       elseif message.event == admob.EVENT_NOT_SUPPORTED then
           print("EVENT_NOT_SUPPORTED: IDFA request not supported on this platform or OS version")
       end
   elseif message_id == admob.MSG_INTERSTITIAL then
       if message.event == admob.EVENT_CLOSED then
           print("EVENT_CLOSED: Interstitial AD closed")
       elseif message.event == admob.EVENT_FAILED_TO_SHOW then
           print("EVENT_FAILED_TO_SHOW: Interstitial AD failed to show\nCode: "..message.code.."\nError: "..message.error)
       elseif message.event == admob.EVENT_OPENING then
           print("EVENT_OPENING: Interstitial AD is opening")
       elseif message.event == admob.EVENT_FAILED_TO_LOAD then
           print("EVENT_FAILED_TO_LOAD: Interstitial AD failed to load\nCode: "..message.code.."\nError: "..message.error)
       elseif message.event == admob.EVENT_LOADED then
           print("EVENT_LOADED: Interstitial AD loaded")
       elseif message.event == admob.EVENT_NOT_LOADED then
           print("EVENT_NOT_LOADED: can't call show_interstitial() before EVENT_LOADED\nError: "..message.error)
       elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
           print("EVENT_IMPRESSION_RECORDED: Interstitial did record impression")
       elseif message.event == admob.EVENT_JSON_ERROR then
           print("EVENT_JSON_ERROR: Internal NE json error: "..message.error)
       end
   elseif message_id == admob.MSG_REWARDED then
       if message.event == admob.EVENT_CLOSED then
           print("EVENT_CLOSED: Rewarded AD closed")
       elseif message.event == admob.EVENT_FAILED_TO_SHOW then
           print("EVENT_FAILED_TO_SHOW: Rewarded AD failed to show\nCode: "..message.code.."\nError: "..message.error)
       elseif message.event == admob.EVENT_OPENING then
           print("EVENT_OPENING: Rewarded AD is opening")
       elseif message.event == admob.EVENT_FAILED_TO_LOAD then
           print("EVENT_FAILED_TO_LOAD: Rewarded AD failed to load\nCode: "..message.code.."\nError: "..message.error)
       elseif message.event == admob.EVENT_LOADED then
           print("EVENT_LOADED: Rewarded AD loaded")
       elseif message.event == admob.EVENT_NOT_LOADED then
           print("EVENT_NOT_LOADED: can't call show_rewarded() before EVENT_LOADED\nError: "..message.error)
       elseif message.event == admob.EVENT_EARNED_REWARD then
           print("EVENT_EARNED_REWARD: Reward: " .. tostring(message.amount) .. " " .. tostring(message.type))
       elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
           print("EVENT_IMPRESSION_RECORDED: Rewarded did record impression")
       elseif message.event == admob.EVENT_JSON_ERROR then
           print("EVENT_JSON_ERROR: Internal NE json error: "..message.error)
       end
   elseif message_id == admob.MSG_BANNER then
       if message.event == admob.EVENT_LOADED then
           print("EVENT_LOADED: Banner AD loaded. Height: "..message.height.."px Width: "..message.width.."px")
       elseif message.event == admob.EVENT_OPENING then
           print("EVENT_OPENING: Banner AD is opening")
       elseif message.event == admob.EVENT_FAILED_TO_LOAD then
           print("EVENT_FAILED_TO_LOAD: Banner AD failed to load\nCode: "..message.code.."\nError: "..message.error)
       elseif message.event == admob.EVENT_CLICKED then
           print("EVENT_CLICKED: Banner AD loaded")
       elseif message.event == admob.EVENT_CLOSED then
           print("EVENT_CLOSED: Banner AD closed")
       elseif message.event == admob.EVENT_DESTROYED then
           print("EVENT_DESTROYED: Banner AD destroyed")
       elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
           print("EVENT_IMPRESSION_RECORDED: Banner did record impression")
       elseif message.event == admob.EVENT_JSON_ERROR then
           print("EVENT_JSON_ERROR: Internal NE json error: "..message.error)
       end
   end
end

function init(self)
    if admob then
        admob.set_callback(admob_callback)
        admob.initialize()
    end
end
```

Example for admob.show_appopen():
```lua
if admob and admob.is_appopen_loaded() then
    admob.show_appopen()
end
```

Example for admob.show_interstitial():
```lua
if admob and admob.is_interstitial_loaded() then
    admob.show_interstitial()
end
```

Example for admob.show_rewarded():
```lua
if admob and admob.is_rewarded_loaded() then
    admob.show_rewarded()
end
```

Example for admob.show_rewarded_interstitial():
```lua
if admob and admob.is_rewarded_interstitial_loaded() then
    admob.show_rewarded_interstitial()
end
```

Example for admob.show_banner(position):
```lua
if admob and admob.is_banner_loaded() then
    admob.show_banner(admob.POS_TOP_CENTER)
end
```

Example for admob.set_max_ad_content_rating(max_ad_rating):
```lua
  admob.set_max_ad_content_rating(admob.MAX_AD_CONTENT_RATING_PG)
```


## adpf (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with the Android Device Performance Framework

```lua
-- Functions
adpf.hint.initialize(target_fps_nanos) -- Initialise performance hints
adpf.hint.update_target_fps(target_fps_nanos) -- Update the target fps
adpf.thermal.initialize(available) -- Initialise thermal
adpf.thermal.get_headroom(forecast_seconds) -- Provides an estimate of how much thermal headroom the device currently has before hitting severe throttling.
adpf.thermal.get_status() -- Get the current thermal status of the device

-- Constants
adpf.THERMAL_STATUS_CRITICAL -- Platform has done everything to reduce power.
adpf.THERMAL_STATUS_EMERGENCY -- Key components in platform are shutting down due to thermal condition.
adpf.THERMAL_STATUS_LIGHT -- Light throttling where UX is not impacted.
adpf.THERMAL_STATUS_MODERATE -- Moderate throttling where UX is not largely impacted.
adpf.THERMAL_STATUS_NONE -- Not under throttling.
adpf.THERMAL_STATUS_SEVERE -- Severe throttling where UX is largely impacted.
adpf.THERMAL_STATUS_SHUTDOWN -- Need shutdown immediately
```

## camera (extension)
> The extension needs to be added to the game.project file manually as dependency.

Provides functionality to capture images using the camera. Supported on macOS, iOS and Android. [icon:ios] [icon:android]

```lua
-- Functions
camera.start_capture() -- Start camera capture using the specified camera (front/back) and capture quality. This may trigger a camera usage permission popup. When the popup has been dismissed the callback will be invoked with camera start status.
camera.stop_capture() -- Stops a previously started capture session.
camera.get_info() -- Gets the info from the current capture session.
camera.get_frame() -- Get captured frame.

-- Constants
camera.CAMERA_TYPE_FRONT -- Constant for the front camera.
camera.CAMERA_TYPE_BACK -- Constant for the back camera.
camera.CAPTURE_QUALITY_HIGH -- High quality capture session.
camera.CAPTURE_QUALITY_MEDIUM -- Medium quality capture session.
camera.CAPTURE_QUALITY_LOW -- Low quality capture session.
camera.CAMERA_STARTED -- The capture session has started.
camera.CAMERA_STOPPED -- The capture session has stopped.
camera.CAMERA_NOT_PERMITTED -- The user did not give permission to start the capture session.
camera.CAMERA_ERROR -- Something went wrong when starting the capture session.
```

### Examples

Example for camera.start_capture():
```lua
camera.start_capture(camera.CAMERA_TYPE_BACK, camera.CAPTURE_QUALITY_HIGH, function(self, message)
    if message == camera.CAMERA_STARTED then
        -- do stuff
    end
end)
```

Example for camera.stop_capture():
```lua
camera.stop_capture()
```

Example for camera.get_info():
```lua
local info = camera.get_info()
print("width", info.width)
print("height", info.height)
```

Example for camera.get_frame():
```lua
self.cameraframe = camera.get_frame()
```


## crazygames (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with the CrazyGames SDK APIs

```lua
-- Functions
crazygames.gameplay_start() -- The gameplayStart() function has to be called whenever the player starts playing or resumes playing after a break (menu/loading/achievement screen, game paused, etc.)
crazygames.gameplay_stop() -- The gameplayStop() function has to be called on every game break (entering a menu, switching level, pausing the game, ...) don't forget to call gameplayStart() when the gameplay resumes
crazygames.loading_start() -- The loadingStart() function has to be called whenever you start loading your game.
crazygames.loading_stop() -- The loadingStop() function has to be called when the loading is complete and eventually the gameplay starts.
crazygames.show_rewarded_ad(callback) -- Show a rewarded ad.
crazygames.show_midgame_ad(callback) -- Show a midgame ad.
crazygames.is_ad_blocked(callback) -- Detect if the user has an adblocker.
crazygames.request_banner(div, width, height) -- Request a banner. The container will be resized to the specified width.
crazygames.request_responsive_banner(div) -- The responsive banners feature will request ads that fit into your container, without the need to specify or select a size beforehand.
crazygames.clear_banner(div) -- Clear a banner. Will also hide it.
crazygames.clear_all_banners() -- Clear all banners.
crazygames.invite_link(params) -- Create a link to your game to invite others to join a multiplayer game.
crazygames.show_invite_button(params) -- Display a button in the game footer, that opens a popup containing an invite link.
crazygames.hide_invite_button() -- Hide the invite button when it is no longer necessary.
crazygames.get_invite_param(key) -- Get an invite link parameters.
crazygames.is_instant_multiplayer() -- For multiplayer games, if is_instant_multiplayer() returns true, you should instantly create a new room/lobby for the user.
crazygames.clear_data() -- Remove all data items from the local storage.
crazygames.get_item(key) -- Get a data item from the local storage.
crazygames.remove_item(key) -- Remove a data item from the local storage.
crazygames.set_item(key, value) -- Add a data item to the local storage.
crazygames.is_user_account_available() -- Before using any user account features, you should always ensure that the user account system is available.
crazygames.get_user(callback) -- Retrieve the user currently logged in CrazyGames. If the user is not logged in CrazyGames, the returned user will be null. Will call the provided callback with the logged in user account.
crazygames.get_user_token(callback) -- The user token is in JWT format and contains the userId of the player that is currently logged in to CrazyGames, as well as other useful information. You should send it to your server when required, and verify/decode it there to extract the userId. Will call the provided callback with the token.
crazygames.get_xsolla_user_token(callback) -- Generates a custom Xsolla token that you use with the Xsolla SDK. Will call the provided callback with the token.
crazygames.show_auth_prompt(callback) -- By calling this method, the log in or register popup will be displayed on CrazyGames. The user can log in their existing account, or create a new account. Will call the provided callback on log in.
crazygames.set_auth_listener(callback) -- You can register a user auth listener that is triggered when the player logs in to CrazyGames. A log out doesn't trigger the auth listener, since the entire page is refreshed when the player logs out.
crazygames.remove_auth_listener() -- Remove any previously set auth listener.
crazygames.show_account_link_prompt() -- Show an account linking prompt to link a CrazyGames account to the in-game account.
```

## crypt (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with various hash and encode/decode algorithms

```lua
-- Functions
crypt.hash_sha1(buffer)
crypt.hash_sha256(buffer)
crypt.hash_sha512(buffer)
crypt.hash_md5(buffer)
crypt.encode_base64(input)
crypt.decode_base64(input)
crypt.encrypt_xtea(source, key)
crypt.decrypt_xtea(source, key)
```

## facebook (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Facebook APIs

```lua
-- Functions
facebook.login_with_permissions(permissions, audience, callback)
facebook.login_with_tracking_preference(login_tracking, permissions, crypto_nonce, callback)
facebook.logout() -- Logout from Facebook
facebook.set_default_audience()
facebook.get_current_authentication_token()
facebook.get_current_profile() -- iOS ONLY. Get the users [FBSDKProfile.currentProfile](https://developers.facebook.com/docs/facebook-login/limited-login/ios/). [Reading From Profile Helper Class](https://developers.facebook.com/docs/facebook-login/limited-login/permissions/profile-helper)
facebook.init() -- Initialize Facebook SDK (if facebook.autoinit is 0 in game.project)
facebook.access_token()
facebook.permissions()
facebook.post_event(event, value, params)
facebook.enable_event_usage()
facebook.disable_event_usage()
facebook.enable_advertiser_tracking() -- Enable advertiser tracking This function will set AdvertiserTrackingEnabled (the 'ATE' flag) to true on iOS, to inform Audience Network to use the data to deliver personalized ads for users on iOS 14 and above.
facebook.disable_advertiser_tracking() -- Disable advertiser tracking This function will set AdvertiserTrackingEnabled (the 'ATE' flag) to false on iOS, to inform Audience Network not to use the data to deliver personalized ads for users on iOS 14 and above.
facebook.show_dialog(dialog, param, callback)
facebook.get_version() -- Get the version of the Facebook SDK used by the extension.
facebook.deferred_deep_link(callback)

-- Constants
facebook.STATE_OPEN -- The Facebook login session is open
facebook.STATE_CLOSED_LOGIN_FAILED -- The Facebook login session has closed because login failed
facebook.GAMEREQUEST_ACTIONTYPE_NONE -- Game request action type "none" for "apprequests" dialog
facebook.GAMEREQUEST_ACTIONTYPE_SEND -- Game request action type "send" for "apprequests" dialog
facebook.GAMEREQUEST_ACTIONTYPE_ASKFOR -- Game request action type "askfor" for "apprequests" dialog
facebook.GAMEREQUEST_ACTIONTYPE_TURN -- Game request action type "turn" for "apprequests" dialog
facebook.GAMEREQUEST_FILTER_NONE -- Game request filter type "none" for "apprequests" dialog
facebook.GAMEREQUEST_FILTER_APPUSERS -- Game request filter type "app_users" for "apprequests" dialog
facebook.GAMEREQUEST_FILTER_APPNONUSERS -- Game request filter type "app_non_users" for "apprequests" dialog
facebook.EVENT_ACHIEVED_LEVEL -- Log this event when the user has achieved a level
facebook.EVENT_ADDED_PAYMENT_INFO -- Log this event when the user has entered their payment info
facebook.EVENT_ADDED_TO_CART -- Log this event when the user has added an item to their cart The value_to_sum passed to facebook.post_event should be the item's price.
facebook.EVENT_ADDED_TO_WISHLIST -- Log this event when the user has added an item to their wish list The value_to_sum passed to facebook.post_event should be the item's price.
facebook.EVENT_COMPLETED_REGISTRATION -- Log this event when a user has completed registration with the app
facebook.EVENT_COMPLETED_TUTORIAL -- Log this event when the user has completed a tutorial in the app
facebook.EVENT_INITIATED_CHECKOUT -- Log this event when the user has entered the checkout process The value_to_sum passed to facebook.post_event should be the total price in the cart.
facebook.EVENT_PURCHASED -- Log this event when the user has completed a purchase. The value_to_sum passed to facebook.post_event should be the numeric rating.
facebook.EVENT_RATED -- Log this event when the user has rated an item in the app
facebook.EVENT_SEARCHED -- Log this event when a user has performed a search within the app
facebook.EVENT_SPENT_CREDITS -- Log this event when the user has spent app credits The value_to_sum passed to facebook.post_event should be the number of credits spent.
facebook.EVENT_TIME_BETWEEN_SESSIONS -- Log this event when measuring the time between user sessions
facebook.EVENT_UNLOCKED_ACHIEVEMENT -- Log this event when the user has unlocked an achievement in the app
facebook.EVENT_VIEWED_CONTENT -- Log this event when a user has viewed a form of content in the app
facebook.PARAM_CONTENT_ID
facebook.PARAM_CONTENT_TYPE
facebook.PARAM_CURRENCY
facebook.PARAM_DESCRIPTION
facebook.PARAM_LEVEL -- Parameter key used to specify the level achieved
facebook.PARAM_MAX_RATING_VALUE
facebook.PARAM_NUM_ITEMS
facebook.PARAM_PAYMENT_INFO_AVAILABLE
facebook.PARAM_REGISTRATION_METHOD
facebook.PARAM_SEARCH_STRING
facebook.PARAM_SOURCE_APPLICATION -- Parameter key used to specify source application package
facebook.PARAM_SUCCESS
facebook.AUDIENCE_NONE -- Publish permission to reach no audience
facebook.AUDIENCE_ONLYME -- Publish permission to reach only me (private to current user)
facebook.AUDIENCE_FRIENDS -- Publish permission to reach user friends
facebook.AUDIENCE_EVERYONE -- Publish permission to reach everyone
facebook.LOGIN_TRACKING_LIMITED -- Login tracking Limited
facebook.LOGIN_TRACKING_ENABLED -- Login tracking enabled
```

### Examples

Log in to Facebook with a set of publish permissions
```lua
local permissions = {"publish_actions"}
facebook.login_with_permissions(permissions, facebook.AUDIENCE_FRIENDS, function(self, data)
    if (data.status == facebook.STATE_OPEN and data.error == nil) then
        print("Successfully logged into Facebook")
        pprint(facebook.permissions())
    else
        print("Failed to get permissions (" .. data.status .. ")")
        pprint(data)
    end
end)
```

Log in to Facebook with a set of read permissions
```lua
local permissions = {"public_profile", "email", "user_friends"}
facebook.login_with_read_permissions(permissions, facebook.AUDIENCE_EVERYONE, function(self, data)
    if (data.status == facebook.STATE_OPEN and data.error == nil) then
        print("Successfully logged into Facebook")
        pprint(facebook.permissions())
    else
        print("Failed to get permissions (" .. data.status .. ")")
        pprint(data)
    end
end)
```

Log in to Facebook with a set of publish permissions
```lua
local permissions = {"publish_actions"}
facebook.login_with_permissions(permissions, facebook.AUDIENCE_FRIENDS, function(self, data)
    if (data.status == facebook.STATE_OPEN and data.error == nil) then
        print("Successfully logged into Facebook")
        pprint(facebook.permissions())
    else
        print("Failed to get permissions (" .. data.status .. ")")
        pprint(data)
    end
end)
```

Log in to Facebook with a set of read permissions
```lua
local permissions = {"public_profile", "email", "user_friends"}
facebook.login_with_tracking_preference(facebook.LOGIN_TRACKING_LIMITED, permissions, "customcryptononce", function(self, data)
    if (data.status == facebook.STATE_OPEN and data.error == nil) then
        print("Successfully logged into Facebook")
        pprint(facebook.permissions())
    else
        print("Failed to get permissions (" .. data.status .. ")")
        pprint(data)
    end
end)
```

Get the current access token, then use it to perform a graph API request.
```lua
local function get_name_callback(self, id, response)
    -- do something with the response
end
function init(self)
    -- assuming we are already logged in.
    local token = facebook.access_token()
    if token then
        local url = "https://graph.facebook.com/me/?access_token=".. token
        http.request(url, "GET", get_name_callback)
    end
end
```

Check the currently granted permissions for a particular permission
```lua
for _,permission in ipairs(facebook.permissions()) do
    if permission == "user_likes" then
        -- "user_likes" granted...
        break
    end
end
```

Post a spent credits event to Facebook Analytics
```lua
params = {[facebook.PARAM_LEVEL] = 30, [facebook.PARAM_NUM_ITEMS] = 2}
facebook.post_event(facebook.EVENT_SPENT_CREDITS, 25, params)
```

Show a dialog allowing the user to share a post to their timeline
```lua
local function fb_share(self, result, error)
    if error then
        -- something did not go right...
    else
        -- do something sensible
    end
end
function init(self)
    -- assuming we have logged in with publish permissions
    local param = { link = "http://www.mygame.com",picture="http://www.mygame.com/image.jpg" }
    facebook.show_dialog("feed", param, fb_share)
end
```

Show a dialog allowing the user to share a post to their timeline
```lua
local function deferred_deep_link_callback(self, result, error)
  if error then
    print(error.error)
  else
    pprint(result)
  end
end

function init(self)
  facebook.deferred_deep_link(deferred_deep_link_callback)
end
```


## firebase (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Firebase

```lua
-- Functions
firebase.initialize(options) -- Initialise Firebase
firebase.get_installation_auth_token() -- Get the Firebase Installation auth token
firebase.set_callback(callback) -- Sets a callback function for receiving events from the SDK. Call `firebase.set_callback(nil)` to remove callback
firebase.get_installation_id() -- Get the Firebase Installation id

-- Constants
firebase.MSG_ERROR
firebase.MSG_INITIALIZED
firebase.MSG_INSTALLATION_AUTH_TOKEN
firebase.MSG_INSTALLATION_ID
```

## firebase (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Firebase

```lua
-- Functions
firebase.analytics.initialize() -- Initialise analytics
firebase.analytics.set_callback(callback) -- Sets a callback function for receiving events from the SDK. Call `firebase.analytics.set_callback(nil)` to remove callback
firebase.analytics.log(name) -- Log an event without parameters.
firebase.analytics.log_string(name, PARAMeter_name, PARAMeter_value) -- Log an event with one string parameter.
firebase.analytics.log_int(name, PARAMeter_name, PARAMeter_value) -- Log an event with one integer parameter.
firebase.analytics.log_number(name, PARAMeter_name, PARAMeter_value) -- Log an event with one float parameter.
firebase.analytics.log_table(name, parameters_table) -- Log an event with table parameters.
firebase.analytics.set_default_event_params(default_params) -- Log an event with table parameters.
firebase.analytics.set_user_id(user_id) -- Sets the user ID property.
firebase.analytics.set_user_property(name, property) -- Set a user property to the given value.
firebase.analytics.reset() -- Clears all data for this app from the device and resets the app instance id.
firebase.analytics.get_id() -- Get the instance ID from the service. Returned in callback with MSG_INSTANCE_ID message_id.
firebase.analytics.set_enabled(key) -- Sets whether analytics collection is enabled for this app on this device.

-- Constants
firebase.MSG_ERROR -- Event generated when an error occurred.
firebase.MSG_INSTANCE_ID -- Event generated when instance_id ready after `firebase.analytics.get_id()` call
firebase.EVENT_ADIMPRESSION -- Predefined event
firebase.EVENT_ADDPAYMENTINFO -- Predefined event
firebase.EVENT_ADDSHIPPINGINFO -- Predefined event
firebase.EVENT_ADDTOCART -- Predefined event
firebase.EVENT_ADDTOWISHLIST -- Predefined event
firebase.EVENT_APPOPEN -- Predefined event
firebase.EVENT_BEGINCHECKOUT -- Predefined event
firebase.EVENT_CAMPAIGNDETAILS -- Predefined event
firebase.EVENT_EARNVIRTUALCURRENCY -- Predefined event
firebase.EVENT_GENERATELEAD -- Predefined event
firebase.EVENT_JOINGROUP -- Predefined event
firebase.EVENT_LEVELEND -- Predefined event
firebase.EVENT_LEVELSTART -- Predefined event
firebase.EVENT_LEVELUP -- Predefined event
firebase.EVENT_LOGIN -- Predefined event
firebase.EVENT_POSTSCORE -- Predefined event
firebase.EVENT_PURCHASE -- Predefined event
firebase.EVENT_REFUND -- Predefined event
firebase.EVENT_REMOVEFROMCART -- Predefined event
firebase.EVENT_SCREENVIEW -- Predefined event
firebase.EVENT_SEARCH -- Predefined event
firebase.EVENT_SELECTCONTENT -- Predefined event
firebase.EVENT_SELECTITEM -- Predefined event
firebase.EVENT_SELECTPROMOTION -- Predefined event
firebase.EVENT_SHARE -- Predefined event
firebase.EVENT_SIGNUP -- Predefined event
firebase.EVENT_SPENDVIRTUALCURRENCY -- Predefined event
firebase.EVENT_TUTORIALBEGIN -- Predefined event
firebase.EVENT_TUTORIALCOMPLETE -- Predefined event
firebase.EVENT_UNLOCKACHIEVEMENT -- Predefined event
firebase.EVENT_VIEWCART -- Predefined event
firebase.EVENT_VIEWITEM -- Predefined event
firebase.EVENT_VIEWITEMLIST -- Predefined event
firebase.EVENT_VIEWPROMOTION -- Predefined event
firebase.EVENT_VIEWSEARCHRESULTS -- Predefined event
firebase.PARAM_ADFORMAT -- Predefined parameter
firebase.PARAM_ADNETWORKCLICKID -- Predefined parameter
firebase.PARAM_ADPLATFORM -- Predefined parameter
firebase.PARAM_ADSOURCE -- Predefined parameter
firebase.PARAM_ADUNITNAME -- Predefined parameter
firebase.PARAM_AFFILIATION -- Predefined parameter
firebase.PARAM_CP1 -- Predefined parameter
firebase.PARAM_CAMPAIGN -- Predefined parameter
firebase.PARAM_CAMPAIGNID -- Predefined parameter
firebase.PARAM_CHARACTER -- Predefined parameter
firebase.PARAM_CONTENT -- Predefined parameter
firebase.PARAM_CONTENTTYPE -- Predefined parameter
firebase.PARAM_COUPON -- Predefined parameter
firebase.PARAM_CREATIVEFORMAT -- Predefined parameter
firebase.PARAM_CREATIVENAME -- Predefined parameter
firebase.PARAM_CREATIVESLOT -- Predefined parameter
firebase.PARAM_CURRENCY -- Predefined parameter
firebase.PARAM_DESTINATION -- Predefined parameter
firebase.PARAM_DISCOUNT -- Predefined parameter
firebase.PARAM_ENDDATE -- Predefined parameter
firebase.PARAM_EXTENDSESSION -- Predefined parameter
firebase.PARAM_FLIGHTNUMBER -- Predefined parameter
firebase.PARAM_GROUPID -- Predefined parameter
firebase.PARAM_INDEX -- Predefined parameter
firebase.PARAM_ITEMBRAND -- Predefined parameter
firebase.PARAM_ITEMCATEGORY -- Predefined parameter
firebase.PARAM_ITEMCATEGORY2 -- Predefined parameter
firebase.PARAM_ITEMCATEGORY3 -- Predefined parameter
firebase.PARAM_ITEMCATEGORY4 -- Predefined parameter
firebase.PARAM_ITEMCATEGORY5 -- Predefined parameter
firebase.PARAM_ITEMID -- Predefined parameter
firebase.PARAM_ITEMLISTID -- Predefined parameter
firebase.PARAM_ITEMLISTNAME -- Predefined parameter
firebase.PARAM_ITEMNAME -- Predefined parameter
firebase.PARAM_ITEMVARIANT -- Predefined parameter
firebase.PARAM_ITEMS -- Predefined parameter
firebase.PARAM_LEVEL -- Predefined parameter
firebase.PARAM_LEVELNAME -- Predefined parameter
firebase.PARAM_LOCATION -- Predefined parameter
firebase.PARAM_LOCATIONID -- Predefined parameter
firebase.PARAM_MARKETINGTACTIC -- Predefined parameter
firebase.PARAM_MEDIUM -- Predefined parameter
firebase.PARAM_METHOD -- Predefined parameter
firebase.PARAM_NUMBEROFNIGHTS -- Predefined parameter
firebase.PARAM_NUMBEROFPASSENGERS -- Predefined parameter
firebase.PARAM_NUMBEROFROOMS -- Predefined parameter
firebase.PARAM_ORIGIN -- Predefined parameter
firebase.PARAM_PAYMENTTYPE -- Predefined parameter
firebase.PARAM_PRICE -- Predefined parameter
firebase.PARAM_PROMOTIONID -- Predefined parameter
firebase.PARAM_PROMOTIONNAME -- Predefined parameter
firebase.PARAM_QUANTITY -- Predefined parameter
firebase.PARAM_SCORE -- Predefined parameter
firebase.PARAM_SCREENCLASS -- Predefined parameter
firebase.PARAM_SCREENNAME -- Predefined parameter
firebase.PARAM_SEARCHTERM -- Predefined parameter
firebase.PARAM_SHIPPING -- Predefined parameter
firebase.PARAM_SHIPPINGTIER -- Predefined parameter
firebase.PARAM_SOURCE -- Predefined parameter
firebase.PARAM_SOURCEPLATFORM -- Predefined parameter
firebase.PARAM_STARTDATE -- Predefined parameter
firebase.PARAM_SUCCESS -- Predefined parameter
firebase.PARAM_TAX -- Predefined parameter
firebase.PARAM_TERM -- Predefined parameter
firebase.PARAM_TRANSACTIONID -- Predefined parameter
firebase.PARAM_TRAVELCLASS -- Predefined parameter
firebase.PARAM_VALUE -- Predefined parameter
firebase.PARAM_VIRTUALCURRENCYNAME -- Predefined parameter
firebase.PROP_ALLOWADPERSONALIZATIONSIGNALS -- Predefined property
firebase.PROP_SIGNUPMETHOD -- Predefined property
```

## firebase (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Firebase

```lua
-- Functions
firebase.remoteconfig.initialize() -- Initialise Firebase Remote Config. Generates MSG_INITIALIZED or MSG_ERROR
firebase.remoteconfig.set_callback(callback) -- Sets a callback function for receiving events from the SDK. Call `firebase.set_callback(nil)` to remove callback
firebase.remoteconfig.fetch() -- Fetches config data from the server. Generates MSG_FETCHED or MSG_ERROR
firebase.remoteconfig.activate() -- Asynchronously activates the most recently fetched configs, so that the fetched key value pairs take effect. Generates MSG_ACTIVATED or MSG_ERROR
firebase.remoteconfig.fetch_and_activate() -- Asynchronously fetches and then activates the fetched configs. Generates MSG_FETCHED and MSG_ACTIVATED or MSG_ERROR
firebase.remoteconfig.get_boolean(key) -- Returns the value associated with a key, converted to a bool.
firebase.remoteconfig.get_data(key) -- Returns the value associated with a key, as a vector of raw byte-data.
firebase.remoteconfig.get_number(key) -- Returns the value associated with a key, converted to a double.
firebase.remoteconfig.get_string(key) -- Returns the value associated with a key, converted to a string.
firebase.remoteconfig.get_keys() -- Gets the set of all keys.
firebase.remoteconfig.set_defaults(defaults) -- Sets the default values.
firebase.remoteconfig.set_minimum_fetch_interval(minimum_fetch_interval) -- Sets the minimum fetch interval.
firebase.remoteconfig.set_timeout(minimum_fetch_interval) -- Sets the timeout that specifies how long the client should wait for a connection to the Firebase Remote Config servers

-- Constants
firebase.MSG_INITIALIZED -- Event generated when remote config has been initialized and is ready for use
firebase.MSG_ERROR -- Event generated when an error occurred.
firebase.MSG_DEFAULTS_SET -- Event generated when the default values have been set
firebase.MSG_FETCHED -- Event generated when the remote config has been fetched
firebase.MSG_ACTIVATED -- Event generated when the remote config has been activated
firebase.MSG_SETTINGS_UPDATED -- Event generated when remote config settings have been updated
```

## fontgen (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions to generate glyphs for fonts at runtime.

```lua
-- Functions
fontgen.load_font(fontc_path, ttf_path, options, complete_function) -- Creates a mapping between a .fontc file and a .ttf file. Increases the ref count for both resources.
fontgen.unload_font(fontc_path_hash) -- Removes the generator mapping between the .fontc and .ttf file. Decreases the ref count for both resources. Does not remove the previously generated glyphs!
fontgen.add_glyphs(fontc_path_hash, text, callback) -- Asynchronoously sdds glyphs to the .fontc resource.
fontgen.remove_glyphs(fontc_path_hash, text) -- Removes glyphs from the .fontc resource
```

## instantapp (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with InstantApp APIs

```lua
-- Functions
instantapp.show_install_prompt() -- Shows a dialog that allows the user to install the current instant app.
instantapp.is_instant_app() -- Checks if application loaded as instant experience.
instantapp.get_cookie_max_size() -- Gets the maximum size in bytes of the cookie data an instant app can store on the device.
instantapp.get_cookie() -- Load byte array from cookies that were saved in instant application.
instantapp.set_cookie(bytes) -- Save byte array in cookies to be able get access to this data in installable application.
```

## gpgs (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Google Play Game Services (GPGS) APIs

```lua
-- Functions
gpgs.is_supported() -- Check if Google Play Services are available & ready on the device.
gpgs.login() -- Login to GPGS using a button.
gpgs.silent_login()
gpgs.get_display_name() -- Get the current GPGS player display name.
gpgs.get_id() -- Get the current GPGS player id.
gpgs.get_server_auth_code()
gpgs.is_logged_in() -- Check if a user is logged in currently.
gpgs.set_callback(callback) -- Set callback for receiving messages from GPGS.
gpgs.snapshot_display_saves(popupTitle, allowAddButton, allowDelete, maxNumberOfSavedGamesToShow) -- Provides a default saved games selection user interface.
gpgs.snapshot_open(saveName, createIfNotFound, conflictPolicy) -- Opens a snapshot with the given `saveName`. If `createIfNotFound` is set to `true`, the specified snapshot will be created if it does not already exist.
gpgs.snapshot_commit_and_close(metadata) -- Save the currently opened save on the server and close it.
gpgs.snapshot_get_data() -- Returns the currently opened snapshot data.
gpgs.snapshot_set_data(data) -- Sets the data for the currently opened snapshot.
gpgs.snapshot_is_opened() -- Check if a snapshot was opened.
gpgs.snapshot_get_max_image_size() -- Returns the maximum data size per snapshot cover image in bytes.
gpgs.snapshot_get_max_save_size() -- Returns the maximum data size per snapshot in bytes.
gpgs.snapshot_get_conflicting_data() -- Returns the conflicting snapshot data.
gpgs.snapshot_resolve_conflict(conflictId, snapshotId) -- Resolves a conflict using the data from the provided snapshot.
gpgs.leaderboard_submit_score(leaderboardId, score) -- Submit a score to a leaderboard for the currently signed-in player.
gpgs.leaderboard_get_top_scores(leaderboardId, time_span, collection, max_results) -- Asynchronously gets the top page of scores for a leaderboard.
gpgs.leaderboard_get_player_centered_scores(leaderboardId, time_span, collection, max_results) -- Asynchronously gets a player-centered page of scores for a leaderboard.
gpgs.leaderboard_show(leaderboardId, time_span, collection) -- Show a leaderboard for a game specified by a leaderboardId.
gpgs.leaderboard_list() -- Show the list of leaderboards.
gpgs.leaderboard_get_player_score(leaderboardId, time_span, collection) -- Asynchronously gets a player-centered page of scores for a leaderboard.
gpgs.achievement_reveal(achievementId) -- Reveals a hidden achievement to the current player.
gpgs.achievement_unlock(achievementId) -- Unlocks an achievement for the current player.
gpgs.achievement_set(achievementId, steps) -- Sets an achievement to have at least the given number of steps completed.
gpgs.achievement_increment(achievementId, steps) -- Increments an achievement by the given number of steps.
gpgs.achievement_show() -- Show achivements
gpgs.achievement_get()
gpgs.event_increment(eventId, amount) -- Increments an event specified by `eventId` by the given number of steps
gpgs.event_get()

-- Constants
gpgs.RESOLUTION_POLICY_MANUAL -- Official [GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.html#RESOLUTION_POLICY_MANUAL) for this constant
gpgs.RESOLUTION_POLICY_LONGEST_PLAYTIME -- Official [GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.html#RESOLUTION_POLICY_LONGEST_PLAYTIME) for this constant
gpgs.RESOLUTION_POLICY_LAST_KNOWN_GOOD -- Official [GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.html#RESOLUTION_POLICY_LAST_KNOWN_GOOD) for this constant
gpgs.RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED -- Official [GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.html#RESOLUTION_POLICY_MOST_RECENTLY_MODIFIED) for this constant
gpgs.RESOLUTION_POLICY_HIGHEST_PROGRESS -- Official [GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.html#RESOLUTION_POLICY_HIGHEST_PROGRESS) for this constant
gpgs.MSG_SIGN_IN -- The message type that GPGS sends when finishing the asynchronous operation after calling `gpgs.login()`
gpgs.MSG_SILENT_SIGN_IN -- The message type that GPGS sends when finishing the asynchronous operation after calling `gpgs.silent_login()`
gpgs.MSG_SHOW_SNAPSHOTS -- The message type that GPGS sends when finishing the asynchronous operation after calling `gpgs.snapshot_display_saves()`
gpgs.MSG_LOAD_SNAPSHOT -- The message type that GPGS sends when finishing the asynchronous operation after calling `gpgs.snapshot_open()`
gpgs.MSG_SAVE_SNAPSHOT -- The message type that GPGS sends when finishing the asynchronous operation after calling `gpgs.snapshot_commit_and_close()`
gpgs.MSG_GET_SERVER_TOKEN -- The message type that GPGS sends when finishing the asynchronous operation of server token retrieval
gpgs.STATUS_SUCCESS -- An operation success.
gpgs.STATUS_FAILED -- An operation failed. Check the error field in the massage table.
gpgs.STATUS_CREATE_NEW_SAVE -- A user wants to create new save as a result of `gpgs.snapshot_display_saves()` method. Turn off this button in `gpgs.snapshot_display_saves()` if you don't want to have this functionality.
gpgs.STATUS_CONFLICT -- The result of the calling `gpgs.snapshot_open()` or 'gpgs.snapshot_resolve_conflict()' is a conflict. You need to make decision on how to solve this conflict using 'gpgs.snapshot_resolve_conflict()'.
gpgs.SNAPSHOT_CURRENT -- The second parameter for 'gpgs.snapshot_resolve_conflict()' method, which means that you want to choose the current snapshot as a snapshot for conflict solving.
gpgs.SNAPSHOT_CONFLICTING -- The second parameter for 'gpgs.snapshot_resolve_conflict()' method, which means that you want to choose the conflicting snapshot as a snapshot for conflict solving.
gpgs.ERROR_STATUS_SNAPSHOT_NOT_FOUND -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_NOT_FOUND) for this constant
gpgs.ERROR_STATUS_SNAPSHOT_CREATION_FAILED -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_CREATION_FAILED) for this constant
gpgs.ERROR_STATUS_SNAPSHOT_CONTENTS_UNAVAILABLE -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_CONTENTS_UNAVAILABLE) for this constant
gpgs.ERROR_STATUS_SNAPSHOT_COMMIT_FAILED -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_COMMIT_FAILED) for this constant
gpgs.ERROR_STATUS_SNAPSHOT_FOLDER_UNAVAILABLE -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_FOLDER_UNAVAILABLE) for this constant
gpgs.ERROR_STATUS_SNAPSHOT_CONFLICT_MISSING -- This constant is used in `message.error_status` table when `MSG_LOAD_SNAPSHOT` is `STATUS_FAILED`. [Official GPGS documentation](https://developers.google.com/android/reference/com/google/android/gms/games/GamesStatusCodes.html#STATUS_SNAPSHOT_CONFLICT_MISSING) for this constant
```

### Examples

Example for gpgs.is_supported():
```lua
if gpgs then
  local is_supported = gpgs.is_supported()
end
```

Log in to GPGS using a button:
```lua
if gpgs then
  gpgs.login()
end
```

Example for gpgs.silent_login():
```lua
function init(self)
  if gpgs then
    gpgs.silent_login()
  end
end
```

Example for gpgs.get_display_name():
```lua
if gpgs then
  local name = gpgs.get_display_name()
end
```

Example for gpgs.get_id():
```lua
if gpgs then
  local id = gpgs.get_id()
end
```

Example for gpgs.get_server_auth_code():
```lua
if gpgs then
  local server_auth_code = gpgs.get_server_auth_code()
end
```

Example for gpgs.is_logged_in():
```lua
if gpgs then
  local is_loggedin = gpgs.is_logged_in()
end
```

Example for gpgs.set_callback(callback):
```lua
function callback(self, message_id, message)
  if message_id == gpgs.MSG_SIGN_IN or message_id == gpgs.MSG_SILENT_SIGN_IN then
    if message.status == gpgs.STATUS_SUCCESS then
    -- do something after login
    end
  elseif message_id == gpgs.MSG_LOAD_SNAPSHOT then
  -- do something when a save was loaded
  end
end

function init(self)
  gpgs.set_callback(callback)
end

function init(self)
  gpgs.set_callback(nil) -- remove callback
end
```

Example for gpgs.snapshot_display_saves(popupTitle, allowAddButton, allowDelete, maxNumberOfSavedGamesToShow):
```lua
if gpgs then
  gpgs.snapshot_display_saves("Choose the save of the game", false, true, 10)
end
```

Example for gpgs.snapshot_open(saveName, createIfNotFound, conflictPolicy):
```lua
if gpgs then
  gpgs.snapshot_open("my_save_1", true, gpgs.RESOLUTION_POLICY_LONGEST_PLAYTIME)
end
```

Example for gpgs.snapshot_commit_and_close(metadata):
```lua
if gpgs then
  local png_img, w, h = screenshot.png()
  gpgs.snapshot_commit_and_close({
      coverImage = png_img,
      description = "LEVEL 31, CAVE",
      playedTime = 12345667,
      progressValue = 657
  })
end
```

Example for gpgs.snapshot_get_data():
```lua
if gpgs then
  local bytes, error_message = gpgs.snapshot_get_data()
  if not bytes then
      print("snapshot_get_data ERROR:", error_message)
  else
      print("snapshot_get_data",bytes)
      -- Do something with your data
  end
end
```

Example for gpgs.snapshot_set_data(data):
```lua
  if gpgs then
    local success, error_message = gpgs.snapshot_set_data(my_data)
    if not success then
        print("snapshot_set_data ERROR:", error_message)
    end
  end
```

Example for gpgs.snapshot_is_opened():
```lua
if gpgs then
  local is_opened = gpgs.snapshot_is_opened()
end
```

Example for gpgs.snapshot_get_max_image_size():
```lua
if gpgs then
  local image_size = gpgs.snapshot_get_max_image_size()
end
```

Example for gpgs.snapshot_get_max_save_size():
```lua
if gpgs then
  local data_size = gpgs.snapshot_get_max_save_size()
end
```

Example for gpgs.snapshot_get_conflicting_data():
```lua
if gpgs then
  local bytes, error_message = gpgs.snapshot_get_conflicting_data()
  if not bytes then
      print("snapshot_get_conflicting_data ERROR:", error_message)
  else
      print("snapshot_get_conflicting_data:",bytes)
      -- Do something with conflicting data data
  end
end
```

Example for gpgs.snapshot_resolve_conflict(conflictId, snapshotId):
```lua
if gpgs then
  gpgs.snapshot_resolve_conflict(self.conflictId, gpgs.SNAPSHOT_CONFLICTING)
end
```


## iap (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for doing in-app purchases. Supported on iOS, Android (Google Play and Amazon) and Facebook Canvas platforms. [icon:ios] [icon:googleplay] [icon:amazon] [icon:facebook]

```lua
-- Functions
iap.buy(id, options) -- Purchase a product.
iap.finish(transaction) -- Explicitly finish a product transaction. [icon:attention] Calling iap.finish is required on a successful transaction if `auto_finish_transactions` is disabled in project settings. Calling this function with `auto_finish_transactions` set will be ignored and a warning is printed. The `transaction.state` field must equal `iap.TRANS_STATE_PURCHASED`.
iap.acknowledge(transaction) -- Acknowledge a transaction. [icon:attention] Calling iap.acknowledge is required on a successful transaction on Google Play unless iap.finish is called. The transaction.state field must equal iap.TRANS_STATE_PURCHASED.
iap.get_provider_id() -- Get current iap provider
iap.list(ids, callback) -- Get a list of all avaliable iap products.
iap.restore() -- Restore previously purchased products.
iap.set_listener(listener) -- Set the callback function to receive purchase transaction events.

-- Constants
iap.PROVIDER_ID_AMAZON -- provider id for Amazon
iap.PROVIDER_ID_APPLE -- provider id for Apple
iap.PROVIDER_ID_FACEBOOK -- provider id for Facebook
iap.PROVIDER_ID_GOOGLE -- iap provider id for Google
iap.REASON_UNSPECIFIED -- unspecified error reason
iap.REASON_USER_CANCELED -- user canceled reason
iap.TRANS_STATE_FAILED -- transaction failed state
iap.TRANS_STATE_PURCHASED -- transaction purchased state
iap.TRANS_STATE_PURCHASING -- transaction purchasing state This is an intermediate mode followed by TRANS_STATE_PURCHASED. Store provider support dependent.
iap.TRANS_STATE_RESTORED -- transaction restored state This is only available on store providers supporting restoring purchases.
iap.TRANS_STATE_UNVERIFIED -- transaction unverified state, requires verification of purchase
```

### Examples

Example for iap.buy(id, options):
```lua
  local function iap_listener(self, transaction, error)
    if error == nil then
      -- purchase is successful.
      print(transaction.date)
      -- required if auto finish transactions is disabled in project settings
      if (transaction.state == iap.TRANS_STATE_PURCHASED) then
        -- do server-side verification of purchase here..
        iap.finish(transaction)
      end
    else
      print(error.error, error.reason)
    end
  end

  function init(self)
      iap.set_listener(iap_listener)
      iap.buy("my_iap")
  end
```

Example for iap.list(ids, callback):
```lua
  local function iap_callback(self, products, error)
    if error == nil then
      for k,p in pairs(products) do
        -- present the product
        print(p.title)
        print(p.description)
      end
    else
      print(error.error)
    end
  end

  function init(self)
      iap.list({"my_iap"}, iap_callback)
  end
```


## ironsource (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with IronSource API

```lua
-- Functions
ironsource.init(app_key) -- Initialize the IronSource SDK
ironsource.set_callback(callback) -- Sets a callback function for receiving events from the SDK. Call `ironsource.set_callback(nil)` to remove callback
ironsource.set_consent(is_consent_provided) -- If the user provided consent, set the following flag to true (must be called before `ironsource.init()`). [Original docs](https://developers.is.com/ironsource-mobile/general/making-sure-youre-compliant-post-gdpr/#step-2) [Android](https://developers.is.com/ironsource-mobile/android/regulation-advanced-settings/), [iOS](https://developers.is.com/ironsource-mobile/ios/regulation-advanced-settings/)
ironsource.validate_integration() -- The ironSource SDK provides an easy way to verify that you’ve successfully integrated the ironSource SDK and any additional adapters; it also makes sure all required dependencies and frameworks were added for the various mediated ad networks. The Integration Helper will now also portray the compatibility between the SDK and adapter versions. Original docs [Android](https://developers.is.com/ironsource-mobile-android/integration-helper-android/), [iOS](https://developers.is.com/ironsource-mobile/ios/integration-helper-ios/)
ironsource.set_metadata(key, value) -- Function used for setting different parameterd for adapters and the SDK itself.
ironsource.set_user_id(user_id)
ironsource.launch_test_suite() -- The LevelPlay integration test suite enables you to quickly and easily test your app’s integration, verify platform setup and review ads related to your configured networks. Original docs [Android](https://developers.is.com/ironsource-mobile/android/unity-levelplay-test-suite/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/unity-levelplay-test-suite/)
ironsource.request_idfa() -- iOS Only. Display the App Tracking Transparency authorization request for accessing the IDFA. Original docs [iOS](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorization)
ironsource.get_idfa_status() -- iOS Only. Returns current authorization status for the IDFA One of event types: `ironsource.EVENT_STATUS_AUTHORIZED` `ironsource.EVENT_STATUS_DENIED` `ironsource.EVENT_STATUS_NOT_DETERMINED` `ironsource.EVENT_STATUS_RESTRICTED` or nil if not supported Original docs [iOS](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorization)
ironsource.set_adapters_debug() -- Manage the debug logs for your integrated mediation ad networks with this boolean. When set to TRUE it enables debug logs to help you troubleshoot issues with all of the mediation ad networks that permit to do so. Remove this code before your app goes live with our ad units!
ironsource.load_consent_view() -- iOS Only. Load the IronSource permission pop-up. [iOS](https://developers.is.com/ironsource-mobile/ios/permission-popup-ios/#step-1)
ironsource.show_consent_view() -- iOS Only. Display the IronSource permission pop-up. [iOS](https://developers.is.com/ironsource-mobile/ios/permission-popup-ios/#step-1)
ironsource.should_track_network_state(should_track) -- You can determine and monitor the internet connection on the user’s device through the ironSource Network Change Status function. This enables the SDK to change its availability according to network modifications, i.e. in the case of no network connection, the availability will turn to FALSE. The default of this function is false; if you’d like to listen to it for changes in connectivity, activate it in the SDK initialization [Android shouldTrackNetworkState](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS shouldTrackReachability](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)
ironsource.is_rewarded_video_available() -- You can receive the availability status of the AD Unit through the callback. Alternatively, ask for ad availability directly by calling this function. [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)
ironsource.show_rewarded_video(placement_name) -- You can show a video ad to your users and define the exact Placement you want to show an ad. The Reward settings of this Placement will be pulled from the ironSource server. Original docs [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)
ironsource.get_rewarded_video_placement_info(placement_name) -- Get details about the specific Reward associated with each Ad Placement. Original docs [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)
ironsource.get_rewarded_video_placement_info(placement_name) -- Get details about the specific Reward associated with each Ad Placement. Original docs [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)
ironsource.is_rewarded_video_placement_capped(placement_name) -- To ensure you don’t show the traffic driver (Rewarded Video button) to prompt the user to watch an ad when the placement is capped, you must call the below method to verify if a specific placement has reached its ad limit. When requesting availability, you might receive a TRUE response but in the case your placement has reached its capping limit, the ad will not be served to the user. Original docs [Android isRewardedVideoPlacementCapped](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-2), [iOS isRewardedVideoCappedForPlacement](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-2)
ironsource.set_dynamic_user_id(dynamic_user_id) -- The Dynamic UserID is a parameter to verify AdRewarded transactions and can be changed throughout the session. To receive this parameter through the server to server callbacks, it must be set before calling showRewardedVideo. You will receive a dynamicUserId parameter in the callback URL with the reward details. [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-2), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-2)
ironsource.load_interstitial() -- We recommend requesting an Interstitial Ad a short while before you plan on showing it to your users as the loading process can take time. [Android](https://developers.is.com/ironsource-mobile/android/interstitial-mediation-integration-android/#step-2), [iOS](https://developers.is.com/ironsource-mobile/ios/interstitial-integration-ios/#step-2)
ironsource.is_interstitial_ready() -- You can receive the availability status of the AD Unit through the callback. Alternatively, ask for ad availability directly by calling this function. [Android](https://developers.is.com/ironsource-mobile/android/interstitial-mediation-integration-android/#step-2), [iOS](https://developers.is.com/ironsource-mobile/ios/interstitial-integration-ios/#step-2)
ironsource.get_interstitial_placement_info(placement_name) -- Android Only. Get details about the specific Ad Placement. Original docs [Android](https://developers.is.com/ironsource-mobile/android/interstitial-mediation-integration-android/#step-3), [iOS](https://developers.is.com/ironsource-mobile/ios/interstitial-integration-ios/#step-3)
ironsource.is_interstitial_placement_capped(placement_name) -- In addition to LevelPlay‘s Ad Placements, you can now configure capping and pacing settings for selected placements. Capping and pacing improve the user experience in your app by limiting the number of ads served within a defined timeframe. Original docs [Android](https://developers.is.com/ironsource-mobile/android/interstitial-mediation-integration-android/#step-3), [iOS](https://developers.is.com/ironsource-mobile/ios/interstitial-integration-ios/#step-3)
ironsource.show_interstitial(placement_name) -- Serve an Interstitial ad to your users. Call it once you receive the ironsource.EVENT_AD_READY callback, you are ready to show an Interstitial Ad to your users. To provide the best experience for your users, make sure to pause any game action, including audio, during the time the ad is displayed. Original docs [Android](https://developers.is.com/ironsource-mobile/android/rewarded-video-integration-android/#step-1), [iOS](https://developers.is.com/ironsource-mobile/ios/rewarded-video-integration-ios/#step-1)

-- Constants
ironsource.MSG_INTERSTITIAL
ironsource.MSG_REWARDED
ironsource.MSG_CONSENT
ironsource.MSG_INIT
ironsource.MSG_IDFA
ironsource.EVENT_AD_AVAILABLE
ironsource.EVENT_AD_UNAVAILABLE
ironsource.EVENT_AD_OPENED
ironsource.EVENT_AD_CLOSED
ironsource.EVENT_AD_REWARDED
ironsource.EVENT_AD_CLICKED
ironsource.EVENT_AD_SHOW_FAILED
ironsource.EVENT_AD_READY
ironsource.EVENT_AD_SHOW_SUCCEEDED
ironsource.EVENT_AD_LOAD_FAILED
ironsource.EVENT_JSON_ERROR
ironsource.EVENT_INIT_COMPLETE
ironsource.EVENT_CONSENT_LOADED
ironsource.EVENT_CONSENT_SHOWN
ironsource.EVENT_CONSENT_LOAD_FAILED
ironsource.EVENT_CONSENT_SHOW_FAILED
ironsource.EVENT_CONSENT_ACCEPTED
ironsource.EVENT_CONSENT_DISMISSED
ironsource.EVENT_STATUS_AUTHORIZED
ironsource.EVENT_STATUS_DENIED
ironsource.EVENT_STATUS_NOT_DETERMINED
ironsource.EVENT_STATUS_RESTRICTED
```

### Examples

Example for ironsource.set_callback(callback):
```lua
local function ironsource_callback(self, message_id, message)
  callback_logger(self, message_id, message)
  if message_id == ironsource.MSG_INIT then
      if message.event == ironsource.EVENT_INIT_COMPLETE then
          -- ironSource SDK is initialized
          -- massage{}
      end
  elseif message_id == ironsource.MSG_REWARDED then
      if message.event == ironsource.EVENT_AD_AVAILABLE then
          -- Indicates that there's an available ad.
          -- The adInfo object includes information about the ad that was loaded successfully
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_UNAVAILABLE then
          -- Indicates that no ads are available to be displayed
          -- massage{}
      elseif message.event == ironsource.EVENT_AD_OPENED then
          -- The Rewarded Video ad view has opened. Your activity will loose focus
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_CLOSED then
          -- The Rewarded Video ad view is about to be closed. Your activity will regain its focus
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_REWARDED then
          -- The user completed to watch the video, and should be rewarded.
          -- The placement parameter will include the reward data.
          -- When using server-to-server callbacks, you may ignore this event and wait for the ironSource server callback
          -- massage{AdInfo, Placement}
      elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
          -- The rewarded video ad was failed to show
          -- massage{AdInfo, IronSourceError}
      elseif message.event == ironsource.EVENT_AD_CLICKED then
          -- Invoked when the video ad was clicked.
          -- This callback is not supported by all networks, and we recommend using it
          -- only if it's supported by all networks you included in your build
          -- massage{AdInfo, Placement}
      end
  elseif message_id == ironsource.MSG_INTERSTITIAL then
      if message.event == ironsource.EVENT_AD_READY then
          -- Invoked when the interstitial ad was loaded successfully.
          -- AdInfo parameter includes information about the loaded ad
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_LOAD_FAILED then
          -- Indicates that the ad failed to be loaded
          -- massage{IronSourceError}
      elseif message.event == ironsource.EVENT_AD_OPENED then
          -- Invoked when the Interstitial Ad Unit has opened, and user left the application screen.
          -- This is the impression indication.
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_CLOSED then
          -- Invoked when the interstitial ad closed and the user went back to the application screen.
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
          -- Invoked when the ad failed to show
          -- massage{AdInfo, IronSourceError}
      elseif message.event == ironsource.EVENT_AD_CLICKED then
          -- Invoked when end user clicked on the interstitial ad
          -- massage{AdInfo}
      elseif message.event == ironsource.EVENT_AD_SHOW_SUCCEEDED then
          -- Invoked before the interstitial ad was opened, and before the InterstitialOnAdOpenedEvent is reported.
          -- This callback is not supported by all networks, and we recommend using it only if
          -- it's supported by all networks you included in your build.
          -- massage{AdInfo}
      end
  elseif message_id == ironsource.MSG_CONSENT then
      if message.event == ironsource.EVENT_CONSENT_LOADED then
          -- Consent View was loaded successfully
          -- massage.consent_view_type
      elseif message.event == ironsource.EVENT_CONSENT_SHOWN then
          -- Consent view was displayed successfully
          -- massage.consent_view_type
      elseif message.event == ironsource.EVENT_CONSENT_LOAD_FAILED then
          -- Consent view was failed to load
          -- massage.consent_view_type, massage.error_code, massage.error_message
      elseif message.event == ironsource.EVENT_CONSENT_SHOW_FAILED then
          -- Consent view was not displayed, due to error
          -- massage.consent_view_type, massage.error_code, massage.error_message
      elseif message.event == ironsource.EVENT_CONSENT_ACCEPTED then
          -- The user pressed the Settings or Next buttons
          -- massage.consent_view_type
      elseif message.event == ironsource.EVENT_CONSENT_DISMISSED then
          -- The user dismiss consent
          -- massage.consent_view_type
      end
  elseif message_id == ironsource.MSG_IDFA then
      if message.event == ironsource.EVENT_STATUS_AUTHORIZED then
          -- ATTrackingManagerAuthorizationStatusAuthorized
      elseif message.event == ironsource.EVENT_STATUS_DENIED then
          -- ATTrackingManagerAuthorizationStatusDenied
      elseif message.event == ironsource.EVENT_STATUS_NOT_DETERMINED then
          -- ATTrackingManagerAuthorizationStatusNotDetermined
      elseif message.event == ironsource.EVENT_STATUS_RESTRICTED then
          -- ATTrackingManagerAuthorizationStatusRestricted
      end
  end
end
```


## permissions (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with permissions related APIs

```lua
-- Functions
permissions.check(permission) -- Determine whether you have been granted a particular permission.
permissions.request(request_tbl, callback) -- Requests permissions to be granted to this application.

-- Constants
permissions.PERMISSION_GRANTED -- The permission has been granted to the given package.
permissions.PERMISSION_DENIED -- The permission has not been granted to the given package.
permissions.PERMISSION_SHOW_RATIONALE -- Explain why your app needs the permission [Android doc](https://developer.android.com/training/permissions/requesting#explain)
```

### Examples

Example for permissions.check(permission):
```lua
local result = permissions.check("android.permission.ACCESS_NETWORK_STATE")
if result == permissions.PERMISSION_DENIED then
    -- You can directly ask for the permission.
elseif result == permissions.PERMISSION_GRANTED then
    -- You can use the API that requires the permission.
elseif result == permissions.PERMISSION_SHOW_RATIONALE then
    -- In an educational UI, explain to the user why your app requires this
    -- permission for a specific feature to behave as expected, and what
    -- features are disabled if it's declined. In this UI, include a
    -- "cancel" or "no thanks" button that lets the user continue
    -- using your app without granting the permission.
end
```

Example for permissions.request(request_tbl, callback):
```lua
local permissions_table = {"android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_CONTACTS"}
permissions.request(permissions_table,
    function(self, result)
        for permission, result in pairs(result) do
          if result == permissions.PERMISSION_DENIED then
              -- You can directly ask for the permission.
          elseif result == permissions.PERMISSION_GRANTED then
              -- You can use the API that requires the permission.
          elseif result == permissions.PERMISSION_SHOW_RATIONALE then
              -- In an educational UI, explain to the user why your app requires this
              -- permission for a specific feature to behave as expected, and what
              -- features are disabled if it's declined. In this UI, include a
              -- "cancel" or "no thanks" button that lets the user continue
              -- using your app without granting the permission.
          end
        end
    end)
```


## poki_sdk (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Poki SDK APIs

```lua
-- Functions
poki_sdk.gameplay_start()
poki_sdk.gameplay_stop()
poki_sdk.commercial_break(callback)
poki_sdk.rewarded_break(size, callback)
poki_sdk.set_debug(is_debug)
poki_sdk.capture_error(error)
poki_sdk.shareable_url(params, callback)
poki_sdk.get_url_param(key)

-- Constants
poki_sdk.REWARDED_BREAK_ERROR
poki_sdk.REWARDED_BREAK_SUCCESS
poki_sdk.REWARDED_BREAK_START
```

## push (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with local, as well as Apple''s and Google''s push notification services. These API's only exist on mobile platforms. [icon:ios] [icon:android]

```lua
-- Functions
push.register(notifications, callback) -- Send a request for push notifications. Note that the notifications table parameter is iOS only and will be ignored on Android.
push.set_listener(listener) -- Sets a listener function to listen to push notifications.
push.set_badge_count(count) -- Set the badge count for application icon. This function is only available on iOS. [icon:ios]
push.schedule(time, title, alert, payload, notification_settings)
push.cancel(id)
push.cancel_all_issued() -- Use this function to cancel a previously issued local push notifications.
push.get_scheduled(id)
push.get_all_scheduled()

-- Constants
push.NOTIFICATION_BADGE -- Badge notification type.
push.NOTIFICATION_SOUND -- Sound notification type.
push.NOTIFICATION_ALERT -- Alert notification type.
push.ORIGIN_LOCAL -- Local push origin.
push.ORIGIN_REMOTE -- Remote push origin.
push.PRIORITY_MIN -- This priority is for items might not be shown to the user except under special circumstances, such as detailed notification logs. Only available on Android. [icon:android]
push.PRIORITY_LOW -- Priority for items that are less important. Only available on Android. [icon:android]
push.PRIORITY_DEFAULT -- The default notification priority. Only available on Android. [icon:android]
push.PRIORITY_HIGH -- Priority for more important notifications or alerts. Only available on Android. [icon:android]
push.PRIORITY_MAX -- Set this priority for your application's most important items that require the user's prompt attention or input. Only available on Android. [icon:android]
```

### Examples

Register for push notifications on iOS. Note that the token needs to be converted on this platform.
```lua
local function push_listener(self, payload, origin)
     -- The payload arrives here.
end

function init(self)
     local alerts = {push.NOTIFICATION_BADGE, push.NOTIFICATION_SOUND, push.NOTIFICATION_ALERT}
     push.register(alerts, function (self, token, error)
     if token then
          -- NOTE: %02x to pad byte with leading zero
          local token_string = ""
          for i = 1,#token do
              token_string = token_string .. string.format("%02x", string.byte(token, i))
          end
          print(token_string)
          push.set_listener(push_listener)
     else
          -- Push registration failed.
          print(error.error)
     end
end
```

Register for push notifications on Android.
```lua
local function push_listener(self, payload, origin)
     -- The payload arrives here.
end

function init(self)
     push.register({}, function (self, token, error)
         if token then
              print(token)
              push.set_listener(push_listener)
         else
              -- Push registration failed.
              print(error.error)
         end
    end)
end
```

Set the push notification listener.
```lua
local function push_listener(self, payload, origin, activated)
     -- The payload arrives here.
     pprint(payload)
     if origin == push.ORIGIN_LOCAL then
         -- This was a local push
         ...
     end

     if origin == push.ORIGIN_REMOTE then
         -- This was a remote push
         ...
     end
end

local init(self)
     ...
     -- Assuming that push.register() has been successfully called earlier
     push.set_listener(push_listener)
end
```

This example demonstrates how to schedule a local notification:
```lua
-- Schedule a local push in 3 seconds
local payload = '{ "data" : { "field" : "Some value", "field2" : "Other value" } }'
id, err = push.schedule(3, "Update!", "There are new stuff in the app", payload, { action = "check it out" })
if err then
     -- Something went wrong
     ...
end
```


## review (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with review APIs

```lua
-- Functions
review.request_review() -- Open native review/rating popup
review.is_supported() -- Available only on iOS 10.3+. Android 5.0+ (API 21+) and the Google Play Store has to be installed.
```

## rive (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Rive models

```lua
-- Functions
rive.play_anim(url, anim_id, playback, options, complete_function) -- Plays the specified animation on a Rive model
rive.play_state_machine(url, state_machine_id, options, callback_function) -- Plays the specified animation on a Rive model
rive.cancel(url) -- Cancels all running animations on a specified spine model component
rive.get_go(url, bone_id) -- Returns the id of the game object that corresponds to a specified skeleton bone.
rive.pointer_move(url, x, y) -- Forward mouse/touch movement to a component
rive.pointer_up(url, x, y) -- Forward mouse/touch release event to a component
rive.pointer_down(url, x, y) -- Forward mouse/touch press event to a component
rive.get_text_run(url, name, nested_artboard) -- Gets the text run of a specified text component from within the Rive artboard assigned to the component.
rive.set_text_run(url, name, text_run, nested_artboard) -- Set the text run of a specified text component from within the Rive artboard assigned to the component.
rive.get_projection_matrix() -- Get an orthographic projection matrix that can be used to project regular Defold components into the same coordinate space as the rive model when using the 'fullscreen' coordinate space.
rive.get_state_machine_input(url, name, nested_artboard) -- Get the input values from a state machine input, either from the current top-level artboard, or from a nested artboard inside the Rive model artboard. Note that trigger inputs will not generate a value!
rive.set_state_machine_input(url, name, value, nested_artboard) -- Set the input values from a state machine input, either from the current top-level artboard, or from a nested artboard inside the Rive model artboard. Note - To set input for a trigger, use a bool value.
```

## safearea (extension)
> The extension needs to be added to the game.project file manually as dependency.

Defold native extension that will change the view/render of a game to fit into the safe area on iPhones and Android(API 28+) with notch.

```lua
-- Functions
safearea.set_background_color(color) -- set background color in runtime
safearea.get_insets() -- returns table with top, left, right, bottom values of insets and status
safearea.get_corners_radius() -- returns a table with `top_left`, `top_right`, `bottom_left`, and `bottom_right` values of rounded corners and status.

-- Constants
safearea.STATUS_OK
safearea.STATUS_NOT_AVAILABLE
safearea.STATUS_NOT_READY_YET
```

## siwa (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting Sign in with Apple. [icon:ios]

```lua
-- Functions
siwa.is_supported() -- Check if Sign in with Apple is available (iOS 13+).
siwa.get_credential_state(user_id, callback) -- Get the credential state of a user.
siwa.authenticate(callback) -- Show the Sign in with Apple UI

-- Constants
siwa.STATE_NOT_FOUND -- The user can’t be found.
siwa.STATE_UNKNOWN -- Unknown credential state.
siwa.STATE_AUTHORIZED -- The user is authorized.
siwa.STATE_REVOKED -- Authorization for the given user has been revoked.
siwa.STATUS_UNKNOWN -- The system hasn’t determined whether the user might be a real person.
siwa.STATUS_UNSUPPORTED -- The system can’t determine this user’s status as a real person.
siwa.STATUS_LIKELY_REAL -- The user appears to be a real person.
```

### Examples

Example for siwa.get_credential_state(user_id, callback):
```lua
siwa.get_credential_state(id, function(self, data)
    if data.credential_state == siwa.STATE_AUTHORIZED then
        print("User has still authorized the application", data.user_id)
    elseif data.credential_state == siwa.STATE_REVOKED then
        print("User has revoked authorization for the application", data.user_id)
    end
end)
```

Example for siwa.authenticate(callback):
```lua
siwa.authenticate(function(self, data)
    print(data.identity_token)
    print(data.user_id)
    print(data.first_name, data.family_name)
    print(data.email)
    if data.user_status == siwa.STATUS_LIKELY_REAL then
        print("Likely a real person")
    end
end)
```


## gui (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Spine models in GUI

```lua
-- Functions
gui.new_spine_node(pos, spine_scene) -- Dynamically create a new spine node.
gui.play_spine_anim(node, animation_id, playback, play_properties, complete_function) -- Starts a spine animation.
gui.cancel_spine(node) -- cancel a spine animation
gui.get_spine_bone(node, bone_id) -- The returned node can be used for parenting and transform queries. This function has complexity O(n), where n is the number of bones in the spine model skeleton.
gui.set_spine_scene(node, spine_scene) -- Set the spine scene on a spine node. The spine scene must be mapped to the gui scene in the gui editor.
gui.get_spine_scene(node) -- Returns the spine scene id of the supplied node. This is currently only useful for spine nodes. The returned spine scene must be mapped to the gui scene in the gui editor.
gui.set_spine_skin(node, spine_skin) -- Sets the spine skin on a spine node.
gui.get_spine_skin(node) -- Gets the spine skin of a spine node
gui.get_spine_animation(node) -- Gets the playing animation on a spine node
gui.set_spine_cursor(node, cursor) -- This is only useful for spine nodes. The cursor is normalized.
gui.get_spine_cursor(node) -- This is only useful for spine nodes. Gets the normalized cursor of the animation on a spine node.
gui.set_spine_playback_rate(node, playback_rate) -- This is only useful for spine nodes. Sets the playback rate of the animation on a spine node. Must be positive.
gui.get_spine_playback_rate(node) -- This is only useful for spine nodes. Gets the playback rate of the animation on a spine node.
gui.set_spine_attachment(node, slot, attachment) -- This is only useful for spine nodes. Sets an attachment to a slot on a spine node.
```

### Examples

Change skin of a Spine node
```lua
function init(self)
  gui.set_spine_skin(gui.get_node("spine_node"), "monster")
end
```


## spine (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Spine models

```lua
-- Functions
spine.play_anim(url, anim_id, playback, options, callback_function) -- Plays the specified animation on a Spine model. A [ref:spine_animation_done] message is sent to the callback (or message handler). Any spine events will also be handled in the same way. [icon:attention] The callback is not called (or message sent) if the animation is cancelled with [ref:spine.cancel]. The callback is called (or message sent) only for animations that play with the following playback modes * `go.PLAYBACK_ONCE_FORWARD` * `go.PLAYBACK_ONCE_BACKWARD` * `go.PLAYBACK_ONCE_PINGPONG`
spine.cancel(url, options) -- Cancels all running animations on a specified spine model component
spine.get_go(url, bone_id) -- Returns the id of the game object that corresponds to a specified skeleton bone.
spine.set_skin(url, skin) -- Sets the spine skin on a spine model.
spine.set_attachment(url, slot, attachment) -- Set the attachment of a lot on a spine model.
spine.reset_constant(url, constant) -- Resets a shader constant for a spine model component. (Previously set with `go.set()`)
spine.reset_ik_target(url, ik_constraint_id) -- reset the IK constraint target position to default of a spinemodel.
spine.set_ik_target_position(url, ik_constraint_id, position) -- set the target position of an IK constraint object.
spine.set_ik_target(url, ik_constraint_id, target_url) -- set the IK constraint object target position to follow position.
```

## steam (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with Steamworks

```lua
-- Functions
steam.init() -- Initialize Steamworks.
steam.update() -- Update Steamworks. Call this from a script component.
steam.restart(appid) -- Restart Steamworks.
steam.final() -- Finalize Steamworks.
steam.apps_is_dlc_installed(app_id) -- Takes AppID of DLC and checks if the user owns the DLC &amp; if the DLC is installed.
steam.friends_get_friend_persona_name(CSteamID) -- Returns the name of another user. Same rules as GetFriendPersonaState() apply as to whether or not the user knowns the name of the other user note that on first joining a lobby, chat room or game server the local user will not known the name of the other users automatically; that information will arrive asyncronously.
steam.friends_get_persona_name() -- Returns the local players name - guaranteed to not be NULL. This is the same name as on the users community profile page. This is stored in UTF-8 format.
steam.friends_get_persona_state() -- Gets the status of the current user. Returned as EPersonaState.
steam.friends_get_friend_persona_state(steamIDFriend) -- Returns the current status of the specified user. This will only be known by the local user if steamIDFriend is in their friends list; on the same game server; in a chat room or lobby; or in a small group with the local user.
steam.friends_get_friend_steam_level(steamIDFriend) -- Get friends steam level.
steam.friends_get_friend_relationship(steamIDFriend) -- Returns a relationship to a user.
steam.friends_activate_game_overlay_to_store(app_id, flag) -- Activates game overlay to store page for app.
steam.friends_activate_game_overlay_to_web_page(url, mode) -- Activates game overlay web browser directly to the specified URL. Full address with protocol type is required, e.g. http://www.steamgames.com/
steam.friends_set_rich_presence(key, value) -- Sets a Rich Presence key/value for the current user.
steam.friends_clear_rich_presence() -- Clears all of the current user&#x27;s Rich Presence key/values.
steam.set_listener(listener) -- Set a listener.
steam.user_get_steam_id() -- Returns the CSteamID of the account currently logged into the Steam client. A CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API.
steam.user_get_player_steam_level() -- Gets the Steam Level of the user, as shown on their profile.
steam.user_get_game_badge_level() -- Trading Card badges data access. If you only have one set of cards, the series will be 1. The user has can have two different badges for a series; the regular (max level 5) and the foil (max level 1).
steam.user_logged_on() -- Returns true if the Steam client current has a live connection to the Steam Servers.
steam.user_is_behind_nat() -- Returns true if this users looks like they are behind a NAT device. Only valid once the user has connected to steam .
steam.user_is_phone_verified() -- Gets whether the users phone number is verified.
steam.user_is_phone_identifying() -- Gets whether the users phone number is identifying.
steam.user_is_phone_requiring_verification() -- Gets whether the users phone number is awaiting (re)verification.
steam.user_is_two_factor_enabled() -- Gets whether the user has two factor enabled on their account.
steam.user_get_auth_session_ticket() -- Get an authentication ticket. Retrieve an authentication ticket to be sent to the entity who wishes to authenticate you.
steam.user_stats_get_stat_int(id) -- Get user stat as an integer.
steam.user_stats_set_stat_int(id, stat) -- Set user stat.
steam.user_stats_get_stat_float(id) -- Get user stat as a floating point number.
steam.user_stats_set_stat_float(id, stat) -- Set user stat.
steam.user_stats_request_current_stats() -- Ask the server to send down this user&#x27;s data and achievements for this game.
steam.user_stats_request_global_stats(history_days) -- Requests global stats data, which is available for stats marked as &quot;aggregated&quot;. This call is asynchronous, with the results returned in GlobalStatsReceived_t. nHistoryDays specifies how many days of day-by-day history to retrieve in addition to the overall totals. The limit is 60.
steam.user_stats_store_stats() -- Store the current data on the server. Will get a callback when set and one callback for every new achievement  If the callback has a result of k_EResultInvalidParam, one or more stats uploaded has been rejected, either because they broke constraints or were out of date. In this case the server sends back updated values. The stats should be re-iterated to keep in sync.
steam.user_stats_reset_all_stats(achievements) -- Reset stats.
steam.user_stats_set_achievement(name) -- Set achievement.
steam.user_stats_get_achievement(name) -- Get achievement.
steam.user_stats_clear_achievement(name) -- Clear achievement.
steam.user_stats_get_num_achievements() -- Used for iterating achievements. In general games should not need these functions because they should have a list of existing achievements compiled into them.
steam.user_stats_get_achievement_name(index) -- Get achievement name iAchievement in [0,GetNumAchievements)
steam.user_stats_get_achievement_display_attribute(name, key) -- Get general attributes for an achievement. Accepts the following keys * &quot;name&quot; and &quot;desc&quot; for retrieving the localized achievement name and description (returned in UTF8) * &quot;hidden&quot; for retrieving if an achievement is hidden (returns &quot;0&quot; when not hidden, &quot;1&quot; when hidden)
steam.user_stats_get_achievement_achieved_percent() -- Returns the percentage of users who have achieved the specified achievement.
steam.user_stats_find_or_create_leaderboard(leaderboard_name, eLeaderboardSortMethod, eLeaderboardDisplayType) -- Gets a leaderboard by name, it will create it if it&#x27;s not yet created. This call is asynchronous, with the result returned in a listener callback with event set to LeaderboardFindResult_t.
steam.user_stats_get_leaderboard_name(leaderboard) -- Get the name of a leaderboard.
steam.user_stats_get_leaderboard_entry_count(leaderboard) -- Get the total number of entries in a leaderboard, as of the last request.
steam.user_stats_download_leaderboard_entries(leaderboard, request, start, end) -- Asks the Steam back-end for a set of rows in the leaderboard. This call is asynchronous, with the result returned in a listener callback with event set to LeaderboardScoresDownloaded_t. LeaderboardScoresDownloaded_t will contain a handle to pull the results from GetDownloadedLeaderboardEntries(). You can ask for more entries than exist, and it will return as many as do exist. * k_ELeaderboardDataRequestGlobal requests rows in the leaderboard from the full table, with nRangeStart &amp; nRangeEnd in the range [1, TotalEntries] * k_ELeaderboardDataRequestGlobalAroundUser requests rows around the current user, nRangeStart being negate e.g. DownloadLeaderboardEntries( hLeaderboard, k_ELeaderboardDataRequestGlobalAroundUser, -3, 3 ) will return 7 rows, 3 before the user, 3 after * k_ELeaderboardDataRequestFriends requests all the rows for friends of the current user
steam.user_stats_get_downloaded_leaderboard_entry(hSteamLeaderboardEntries, index) -- Returns data about a single leaderboard entry
steam.user_stats_upload_leaderboard_score(leaderboard, eLeaderboardUploadScoreMethod, nScore) -- Uploads a user score to a specified leaderboard. This call is asynchronous, with the result returned in a listener callback with event set to LeaderboardScoreUploaded_t.
steam.utils_get_app_id() -- Returns the appID of the current process.
steam.utils_get_seconds_since_app_active() -- Return the number of seconds since the user.
steam.utils_is_steam_running_on_steam_deck() -- Returns true if currently running on the Steam Deck device.
steam.utils_get_image_size(image) -- Get size of image
steam.utils_get_image_rgba(image, size) -- Get image in RGBA format.
steam.utils_get_server_real_time() -- Returns the Steam server time in Unix epoch format. (Number of seconds since Jan 1, 1970 UTC)
steam.utils_show_floating_gamepad_text_input(mode, x, y, width, height) -- Opens a floating keyboard over the game content and sends OS keyboard keys directly to the game.
steam.utils_show_gamepad_text_input(input_mode, line_input_mode, description, existing_text) -- Activates the Big Picture text input dialog which only supports gamepad input.

-- Constants
steam.ELeaderboardDataRequestGlobal -- Requests rows in the leaderboard from the full table
steam.ELeaderboardDataRequestGlobalAroundUser -- Requests rows in the leaderboard from rows around the user
steam.ELeaderboardDataRequestFriends -- Requests all the rows for friends of the current user
steam.ELeaderboardSortMethodAscending -- Top-score is lowest number
steam.ELeaderboardSortMethodNone -- Top-score is highest number
steam.ELeaderboardUploadScoreMethodKeepBest -- Leaderboard will keep user&#x27;s best score
steam.ELeaderboardUploadScoreMethodForceUpdate -- Leaderboard will always replace score with specified
steam.ELeaderboardDisplayTypeNumeric -- Simple numerical score
steam.ELeaderboardDisplayTypeTimeSeconds -- The score represents a time, in seconds
steam.ELeaderboardDisplayTypeTimeMilliSeconds -- The score represents a time, in milliseconds
steam.EOverlayToStoreFlag_None -- Passed as parameter to the store
steam.EOverlayToStoreFlag_AddToCart -- Passed as parameter to the store
steam.EOverlayToStoreFlag_AddToCartAndShow -- Passed as parameter to the store
steam.EActivateGameOverlayToWebPageMode_Default -- Passed as parameter to ActivateGameOverlayToWebPage
steam.EActivateGameOverlayToWebPageMode_Modal -- Passed as parameter to ActivateGameOverlayToWebPage
steam.EPersonaStateOffline -- Friend is not currently logged on
steam.EPersonaStateOnline -- Friend is logged on
steam.EPersonaStateBusy -- User is on, but busy
steam.EPersonaStateAway -- Auto-away feature
steam.EPersonaStateSnooze -- Auto-away for a long time
steam.EPersonaStateLookingToTrade -- Online, trading
steam.EPersonaStateLookingToPlay -- Online, wanting to play
steam.EPersonaStateInvisible -- Online, but appears offline to friends.  This status is never published to clients.
```

## websocket (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for using websockets. Supported on all platforms.

```lua
-- Functions
websocket.connect(url, params, callback) -- Connects to a remote address
websocket.disconnect(connection) -- Explicitly close a websocket
websocket.send(connection, message, options) -- Send data on a websocket

-- Constants
websocket.EVENT_CONNECTED -- The websocket was connected
websocket.EVENT_DISCONNECTED -- The websocket disconnected
websocket.EVENT_MESSAGE -- The websocket received data
websocket.EVENT_ERROR -- The websocket encountered an error
```

### Examples

Example for websocket.connect(url, params, callback):
```lua
  local function websocket_callback(self, conn, data)
    if data.event == websocket.EVENT_DISCONNECTED then
      log("Disconnected: " .. tostring(conn))
      self.connection = nil
      update_gui(self)
    elseif data.event == websocket.EVENT_CONNECTED then
      update_gui(self)
      log("Connected: " .. tostring(conn))
    elseif data.event == websocket.EVENT_ERROR then
      log("Error: '" .. data.message .. "'")
    elseif data.event == websocket.EVENT_MESSAGE then
      log("Receiving: '" .. tostring(data.message) .. "'")
    end
  end

  function init(self)
    self.url = "ws://echo.websocket.events"
    local params = {
      timeout = 3000,
      headers = "Sec-WebSocket-Protocol: chat\r\nOrigin: mydomain.com\r\n"
    }
    self.connection = websocket.connect(self.url, params, websocket_callback)
  end

  function finalize(self)
      if self.connection ~= nil then
        websocket.disconnect(self.connection)
      end
  end
```

Example for websocket.send(connection, message, options):
```lua
  local function websocket_callback(self, conn, data)
    if data.event == websocket.EVENT_CONNECTED then
      websocket.send(conn, "Hello from the other side")
    end
  end

  function init(self)
    self.url = "ws://echo.websocket.org"
    local params = {}
    self.connection = websocket.connect(self.url, params, websocket_callback)
  end
```


## webview (extension)
> The extension needs to be added to the game.project file manually as dependency.

Functions and constants for interacting with webview APIs

```lua
-- Functions
webview.create(callback)
webview.destroy(webview_id) -- Destroys an instance of a webview.
webview.open(webview_id, url, options) -- Opens a web page in the webview, using an URL. Once the request is done, the callback (registered in `webview.create()`) is invoked.
webview.open_raw(webview_id, html, options) -- Opens a web page in the webview, using HTML data. Once the request is done, the callback (registered in `webview.create()`) is invoked.
webview.eval(webview_id, code) -- Evaluates JavaScript within the context of the currently loaded page (if any). Once the request is done, the callback (registered in `webview.create()`) is invoked. The callback will get the result in the `data["result"]` field.
webview.set_transparent(webview_id, transparent) -- Set transparency of webview background
webview.set_visible(webview_id, visible) -- Shows or hides a webview
webview.is_visible(webview_id) -- Returns the visibility state of the webview.
webview.set_position(webview_id, x, y, width, height) -- Sets the position and size of the webview

-- Constants
webview.CALLBACK_RESULT_URL_OK
webview.CALLBACK_RESULT_URL_ERROR
webview.CALLBACK_RESULT_URL_LOADING
webview.CALLBACK_RESULT_EVAL_OK
webview.CALLBACK_RESULT_EVAL_ERROR
```

### Examples

Example for webview.create(callback):
```lua
local function webview_callback(self, webview_id, request_id, type, data)
    if type == webview.CALLBACK_RESULT_URL_OK then
        -- the page is now loaded, let's show it
        webview.set_visible(webview_id, 1)
    elseif type == webview.CALLBACK_RESULT_URL_ERROR then
        print("Failed to load url: " .. data["url"])
        print("Error: " .. data["error"])
    elseif type == webview.CALLBACK_RESULT_URL_LOADING then
        -- a page is loading
        -- return false to prevent it from loading
        -- return true or nil to continue loading the page
        if data.url ~= "https://www.defold.com/" then
            return false
        end
    elseif type == webview.CALLBACK_RESULT_EVAL_OK then
        print("Eval ok. Result: " .. data['result'])
    elseif type == webview.CALLBACK_RESULT_EVAL_ERROR then
        print("Eval not ok. Request # " .. request_id)
    end
end
local webview_id = webview.create(webview_callback)
```

Example for webview.open(webview_id, url, options):
```lua
local request_id = webview.open(webview_id, "http://www.defold.com", {hidden = true})
```

Example for webview.open_raw(webview_id, html, options):
```lua
local html = sys.load_resource("/main/data/test.html")
local request_id = webview.open_raw(webview_id, html, {hidden = true})
```

Example for webview.eval(webview_id, code):
```lua
local request_id = webview.eval(webview_id, "GetMyFormData()")
```


## zendesk (extension)
> The extension needs to be added to the game.project file manually as dependency.

Defold native extension to interact with the Zendesk SDK.

```lua
-- Functions
zendesk.initialize() -- Initialize the Zendesk SDK
zendesk.set_callback() -- Set a callback for events from the Zendesk SDK
zendesk.show_messaging() -- Show the conversation screen.
zendesk.set_conversation_fields() -- Set conversation fields in the SDK to add contextual data about the conversation.
zendesk.clear_conversation_fields() -- Clear conversation fields from the SDK storage when the client side context changes.
zendesk.set_conversation_tags() -- Set custom conversation tags in the SDK to add contextual data about the conversation.
zendesk.clear_conversation_tags() -- Clear conversation tags from SDK storage when the client side context changes.
zendesk.login() -- Authenticate a user.
zendesk.logout() -- Unauthenticate a user.

-- Constants
zendesk.MSG_INIT_ERROR -- An error was detected while initializing the Zendesk SDK
zendesk.MSG_INIT_SUCCESS -- The Zendesk SDK has been initialized successfully
zendesk.MSG_INTERNAL_ERROR -- An internal error occured
zendesk.MSG_ERROR -- An generic error occured
zendesk.MSG_UNREAD_MESSAGE_COUNT_CHANGED -- The number of unread messages has changed
zendesk.MSG_AUTHENTICATION_FAILED -- A REST call failed for authentication reasons
zendesk.MSG_FIELD_VALIDATION_FAILED -- Validation checks failed for conversation fields
zendesk.MSG_LOGIN_SUCCESS -- Login was successful
zendesk.MSG_LOGIN_FAILED -- Login failed
zendesk.MSG_LOGOUT_SUCCESS -- Logout was successful
zendesk.MSG_LOGOUT_FAILED -- Logout failed
```
