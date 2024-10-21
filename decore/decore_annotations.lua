---Download Defold annotations from here: https://github.com/astrochili/defold-annotations/releases/

---@class entity
---@field parent_prefab_id string|nil The parent prefab_id, used for prefab inheritance
---@field id number|nil @Unique entity id, autofilled by decore.create_entity
---@field name string|nil @The entity name
---@field prefab_id string|nil @The entity id from decore collections, autofilled by decore.create_entity
---@field pack_id string|nil @The entity id from decore collections, autofilled by decore.create_entity
---@field tiled_id number|nil @The entity id from Tiled, autofilled by decore.create_entity
---@field layer_id number|nil @The layer name from Tiled, autofilled by decore.create_entity

---@class system
---@field id string|number|nil
---@field active boolean
---@field filter fun(self: system, entity: entity)|nil
---@field world world
---@field entities entity[]
---@field indices table<entity, number> @Entity index in entities table
---@field nocache boolean
---@field index number
---@field modified boolean
---@field interval number|nil
---@field onAdd fun(self: system, entity:entity)|nil
---@field onRemove fun(self: system, entity:entity)|nil
---@field onModify fun(dt:number)|nil
---@field onAddToWorld fun(self: system, world:world)|nil
---@field onRemoveFromWorld fun(self: system, world:world)|nil
---@field preWrap fun(dt:number)|nil
---@field postWrap fun()|nil
---@field update fun(dt:number)|nil
---@field preProcess fun(dt:number)|nil
---@field process fun(entity:entity, dt:number)|nil
---@field postProcess fun(dt:number)|nil
---@field compare fun(e1:entity, e2:entity)|nil

---@class world
---@field entities entity[]
---@field systems system[]
---@field add fun(self: world, ...): ...
---@field addEntity fun(self: world, entity: entity): entity
---@field addSystem fun(self: world, system: system): system
---@field remove fun(self: world)
---@field removeEntity fun(self: world, entity: entity): entity
---@field removeSystem fun(self: world, system: system): system
---@field refresh fun(self: world)
---@field update fun(self: world, dt:number, filter:fun()|nil)
---@field clearEntities fun(self: world)
---@field clearSystems fun(self: world)
---@field getEntityCount fun(self: world)
---@field getSystemCount fun(self: world)
---@field setSystemIndex fun(self: world)
---@field entitiesToChange entity[]
---@field entitiesToRemove entity[]
---@field systemsToChange system[]
---@field systemsToAdd system[]
---@field systemsToRemove system[]

---@class tiny_ecs @Tiny ECS module
---@field requireAll fun(...) @Returns a filter function that requires all of the specified components
---@field requireAny fun(...) @Returns a filter function that requires any of the specified components
---@field rejectAll fun(...) @Returns a filter function that rejects all of the specified components
---@field rejectAny fun(...) @Returns a filter function that rejects any of the specified components
---@field filter fun(pattern: string) @Returns a filter function that matches the specified pattern
---@field system fun(table: system) @Creates a new system
---@field processingSystem fun(table: system) @Creates a new processing system
---@field sortedSystem fun(table: system) @Creates a new sorted system
---@field sortedProcessingSystem fun(table: system) @Creates a new sorted processing system
---@field world fun(...) @Creates a new world
---@field addEntity fun(world: world, entity: entity): entity @Adds an entity to the world
---@field addSystem fun(world: world, system: system): system @Adds a system to the world
---@field add fun(world: world, ...) @Adds entities to the world
---@field removeEntity fun(world: world, entity: entity): entity @Removes an entity from the world
---@field removeSystem fun(world: world, system: system): system @Removes a system from the world
---@field remove fun(world: world, ...) @Removes entities from the world
---@field refresh fun(world: world) @Refreshes the world
---@field update fun(world: world, dt: number, filter: fun()|nil) @Updates the world
---@field clearEntities fun(world: world) @Clears all entities from the world
---@field clearSystems fun(world: world) @Clears all systems from the world
---@field getEntityCount fun(world: world) @Returns the number of entities in the world
---@field getSystemCount fun(world: world) @Returns the number of systems in the world
---@field setSystemIndex fun(world: world) @Sets the index of a system in the world

--- JSON file scheme for entities data
---@class decore.entities_pack_data
---@field pack_id string
---@field entities table<string, entity>

--- JSON file scheme for components data
---@class decore.components_pack_data
---@field pack_id string
---@field components table<string, any>

--- JSON file scheme for worlds data
---@class decore.worlds_pack_data
---@field pack_id string
---@field worlds table<string, decore.world.instance>

---@class decore.world.instance_id
---@field world_id string|nil
---@field pack_id string|nil

---@class decore.entities_pack_data.instance
---@field prefab_id string|nil
---@field pack_id string|nil
---@field components table<string, any>|nil

---@class decore.world.instance
---@field included_worlds decore.world.instance_id[]|nil
---@field entities decore.entities_pack_data.instance[]



