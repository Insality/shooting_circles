
## Cheat Sheet

### Aliases

```
id :: implementation-specific

entity :: id
fragment :: id
query :: id
system :: id

component :: any
storage :: component[]

default :: component
duplicate :: {component -> component}

execute :: {chunk, entity[], integer}
prologue :: {}
epilogue :: {}

set_hook :: {entity, fragment, component, component?}
assign_hook :: {entity, fragment, component, component}
insert_hook :: {entity, fragment, component}
remove_hook :: {entity, fragment, component}

each_state :: implementation-specific
execute_state :: implementation-specific

each_iterator :: {each_state? -> fragment?, component?}
execute_iterator :: {execute_state? -> chunk?, entity[]?, integer?}
```

### Predefs

```
TAG :: fragment
NAME :: fragment

UNIQUE :: fragment
EXPLICIT :: fragment

DEFAULT :: fragment
DUPLICATE :: fragment

PREFAB :: fragment
DISABLED :: fragment

INCLUDES :: fragment
EXCLUDES :: fragment
REQUIRES :: fragment

ON_SET :: fragment
ON_ASSIGN :: fragment
ON_INSERT :: fragment
ON_REMOVE :: fragment

GROUP :: fragment

QUERY :: fragment
EXECUTE :: fragment

PROLOGUE :: fragment
EPILOGUE :: fragment

DESTRUCTION_POLICY :: fragment
DESTRUCTION_POLICY_DESTROY_ENTITY :: id
DESTRUCTION_POLICY_REMOVE_FRAGMENT :: id
```

### Functions

```
id :: integer? -> id...

pack :: integer, integer -> id
unpack :: id -> integer, integer

defer :: boolean
commit :: boolean

spawn :: <fragment, component>? -> entity
clone :: entity -> <fragment, component>? -> entity

alive :: entity -> boolean
alive_all :: entity... -> boolean
alive_any :: entity... -> boolean

empty :: entity -> boolean
empty_all :: entity... -> boolean
empty_any :: entity... -> boolean

has :: entity, fragment -> boolean
has_all :: entity, fragment... -> boolean
has_any :: entity, fragment... -> boolean

get :: entity, fragment...  -> component...

set :: entity, fragment, component -> ()
remove :: entity, fragment... -> ()
clear :: entity... -> ()
destroy :: entity... -> ()

batch_set :: query, fragment, component -> ()
batch_remove :: query, fragment... -> ()
batch_clear :: query... -> ()
batch_destroy :: query... -> ()

each :: entity -> {each_state? -> fragment?, component?}, each_state?
execute :: query -> {execute_state? -> chunk?, entity[]?, integer?}, execute_state?

process :: system... -> ()

debug_mode :: boolean -> ()
collect_garbage :: ()
```

### Classes

#### Chunk

```
chunk :: fragment, fragment... -> chunk, entity[], integer

chunk_mt:alive :: boolean
chunk_mt:empty :: boolean

chunk_mt:has :: fragment -> boolean
chunk_mt:has_all :: fragment... -> boolean
chunk_mt:has_any :: fragment... -> boolean

chunk_mt:entities :: entity[], integer
chunk_mt:fragments :: fragment[], integer
chunk_mt:components :: fragment... -> storage...
```

#### Builder

```
builder :: builder

builder_mt:spawn :: entity
builder_mt:clone :: entity -> entity

builder_mt:has :: fragment -> boolean
builder_mt:has_all :: fragment... -> boolean
builder_mt:has_any :: fragment... -> boolean

builder_mt:get :: fragment... -> component...

builder_mt:set :: fragment, component -> builder
builder_mt:remove :: fragment... -> builder
builder_mt:clear :: builder

builder_mt:tag :: builder
builder_mt:name :: string -> builder

builder_mt:unique :: builder
builder_mt:explicit :: builder

builder_mt:default :: component -> builder
builder_mt:duplicate :: {component -> component} -> builder

builder_mt:prefab :: builder
builder_mt:disabled :: builder

builder_mt:include :: fragment... -> builder
builder_mt:exclude :: fragment... -> builder
builder_mt:require :: fragment... -> builder

builder_mt:on_set :: {entity, fragment, component, component?} -> builder
builder_mt:on_assign :: {entity, fragment, component, component} -> builder
builder_mt:on_insert :: {entity, fragment, component} -> builder
builder_mt:on_remove :: {entity, fragment} -> builder

builder_mt:group :: system -> builder

builder_mt:query :: query -> builder
builder_mt:execute :: {chunk, entity[], integer} -> builder

builder_mt:prologue :: {} -> builder
builder_mt:epilogue :: {} -> builder

builder_mt:destruction_policy :: id -> builder
```

## License

`evolved.lua` is licensed under the [MIT License][license]. For more details, see the [LICENSE.md](./LICENSE.md) file in the repository.

# Changelog

## v1.1.0

- [`Systems`](#systems) can be queries themselves now
- Added the new [`evolved.REQUIRES`](#evolvedrequires) fragment trait

## v1.0.0

- Initial release

# API Reference

## Predefs

### `evolved.TAG`

### `evolved.NAME`

### `evolved.UNIQUE`

### `evolved.EXPLICIT`

### `evolved.DEFAULT`

### `evolved.DUPLICATE`

### `evolved.PREFAB`

### `evolved.DISABLED`

### `evolved.INCLUDES`

### `evolved.EXCLUDES`

### `evolved.REQUIRES`

### `evolved.ON_SET`

### `evolved.ON_ASSIGN`

### `evolved.ON_INSERT`

### `evolved.ON_REMOVE`

### `evolved.GROUP`

### `evolved.QUERY`

### `evolved.EXECUTE`

### `evolved.PROLOGUE`

### `evolved.EPILOGUE`

### `evolved.DESTRUCTION_POLICY`

### `evolved.DESTRUCTION_POLICY_DESTROY_ENTITY`

### `evolved.DESTRUCTION_POLICY_REMOVE_FRAGMENT`

## Functions

### `evolved.id`

```lua
---@param count? integer
---@return evolved.id ... ids
---@nodiscard
function evolved.id(count) end
```

### `evolved.pack`

```lua
---@param index integer
---@param version integer
---@return evolved.id id
---@nodiscard
function evolved.pack(index, version) end
```

### `evolved.unpack`

```lua
---@param id evolved.id
---@return integer index
---@return integer version
---@nodiscard
function evolved.unpack(id) end
```

### `evolved.defer`

```lua
---@return boolean started
function evolved.defer() end
```

### `evolved.commit`

```lua
---@return boolean committed
function evolved.commit() end
```

### `evolved.spawn`

```lua
---@param components? table<evolved.fragment, evolved.component>
---@return evolved.entity
function evolved.spawn(components) end
```

### `evolved.clone`

```lua
---@param prefab evolved.entity
---@param components? table<evolved.fragment, evolved.component>
---@return evolved.entity
function evolved.clone(prefab, components) end
```

### `evolved.alive`

```lua
---@param entity evolved.entity
---@return boolean
---@nodiscard
function evolved.alive(entity) end
```

### `evolved.alive_all`

```lua
---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function evolved.alive_all(...) end
```

### `evolved.alive_any`

```lua
---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function evolved.alive_any(...) end
```

### `evolved.empty`

```lua
---@param entity evolved.entity
---@return boolean
---@nodiscard
function evolved.empty(entity) end
```

### `evolved.empty_all`

```lua
---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function evolved.empty_all(...) end
```

### `evolved.empty_any`

```lua
---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function evolved.empty_any(...) end
```

### `evolved.has`

```lua
---@param entity evolved.entity
---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function evolved.has(entity, fragment) end
```

### `evolved.has_all`

```lua
---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.has_all(entity, ...) end
```

### `evolved.has_any`

```lua
---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.has_any(entity, ...) end
```

### `evolved.get`

```lua
---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return evolved.component ... components
---@nodiscard
function evolved.get(entity, ...) end
```

### `evolved.set`

```lua
---@param entity evolved.entity
---@param fragment evolved.fragment
---@param component evolved.component
function evolved.set(entity, fragment, component) end
```

### `evolved.remove`

```lua
---@param entity evolved.entity
---@param ... evolved.fragment fragments
function evolved.remove(entity, ...) end
```

### `evolved.clear`

```lua
---@param ... evolved.entity entities
function evolved.clear(...) end
```

### `evolved.destroy`

```lua
---@param ... evolved.entity entities
function evolved.destroy(...) end
```

### `evolved.batch_set`

```lua
---@param query evolved.query
---@param fragment evolved.fragment
---@param component evolved.component
function evolved.batch_set(query, fragment, component) end
```

### `evolved.batch_remove`

```lua
---@param query evolved.query
---@param ... evolved.fragment fragments
function evolved.batch_remove(query, ...) end
```

### `evolved.batch_clear`

```lua
---@param ... evolved.query queries
function evolved.batch_clear(...) end
```

### `evolved.batch_destroy`

```lua
---@param ... evolved.query queries
function evolved.batch_destroy(...) end
```

### `evolved.each`

```lua
---@param entity evolved.entity
---@return evolved.each_iterator iterator
---@return evolved.each_state? iterator_state
---@nodiscard
function evolved.each(entity) end
```

### `evolved.execute`

```lua
---@param query evolved.query
---@return evolved.execute_iterator iterator
---@return evolved.execute_state? iterator_state
---@nodiscard
function evolved.execute(query) end
```

### `evolved.process`

```lua
---@param ... evolved.system systems
function evolved.process(...) end
```

### `evolved.debug_mode`

```lua
---@param yesno boolean
function evolved.debug_mode(yesno) end
```

### `evolved.collect_garbage`

```lua
function evolved.collect_garbage() end
```

## Classes

### Chunk

#### `evolved.chunk`

```lua
---@param fragment evolved.fragment
---@param ... evolved.fragment fragments
---@return evolved.chunk chunk
---@return evolved.entity[] entity_list
---@return integer entity_count
---@nodiscard
function evolved.chunk(fragment, ...) end
```

#### `evolved.chunk_mt:alive`

```lua
---@return boolean
---@nodiscard
function evolved.chunk_mt:alive() end
```

#### `evolved.chunk_mt:empty`

```lua
---@return boolean
---@nodiscard
function evolved.chunk_mt:empty() end
```

#### `evolved.chunk_mt:has`

```lua
---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function evolved.chunk_mt:has(fragment) end
```

#### `evolved.chunk_mt:has_all`

```lua
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.chunk_mt:has_all(...) end
```

#### `evolved.chunk_mt:has_any`

```lua
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.chunk_mt:has_any(...) end
```

#### `evolved.chunk_mt:entities`

```lua
---@return evolved.entity[] entity_list
---@return integer entity_count
---@nodiscard
function evolved.chunk_mt:entities() end
```

#### `evolved.chunk_mt:fragments`

```lua
---@return evolved.fragment[] fragment_list
---@return integer fragment_count
---@nodiscard
function evolved.chunk_mt:fragments() end
```

#### `evolved.chunk_mt:components`

```lua
---@param ... evolved.fragment fragments
---@return evolved.storage ... storages
---@nodiscard
function evolved.chunk_mt:components(...) end
```

### Builder

#### `evolved.builder`

```lua
---@return evolved.builder builder
---@nodiscard
function evolved.builder() end
```

#### `evolved.builder_mt:spawn`

```lua
---@return evolved.entity
function evolved.builder_mt:spawn() end
```

#### `evolved.builder_mt:clone`

```lua
---@param prefab evolved.entity
---@return evolved.entity
function evolved.builder_mt:clone(prefab) end
```

#### `evolved.builder_mt:has`

```lua
---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function evolved.builder_mt:has(fragment) end
```

#### `evolved.builder_mt:has_all`

```lua
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.builder_mt:has_all(...) end
```

#### `evolved.builder_mt:has_any`

```lua
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function evolved.builder_mt:has_any(...) end
```

#### `evolved.builder_mt:get`

```lua
---@param ... evolved.fragment fragments
---@return evolved.component ... components
---@nodiscard
function evolved.builder_mt:get(...) end
```

#### `evolved.builder_mt:set`

```lua
---@param fragment evolved.fragment
---@param component evolved.component
---@return evolved.builder builder
function evolved.builder_mt:set(fragment, component) end
```

#### `evolved.builder_mt:remove`

```lua
---@param ... evolved.fragment fragments
---@return evolved.builder builder
function evolved.builder_mt:remove(...) end
```

#### `evolved.builder_mt:clear`

```lua
---@return evolved.builder builder
function evolved.builder_mt:clear() end
```

#### `evolved.builder_mt:tag`

```lua
---@return evolved.builder builder
function evolved.builder_mt:tag() end
```

#### `evolved.builder_mt:name`

```lua
---@param name string
---@return evolved.builder builder
function evolved.builder_mt:name(name) end
```

#### `evolved.builder_mt:unique`

```lua
---@return evolved.builder builder
function evolved.builder_mt:unique() end
```

#### `evolved.builder_mt:explicit`

```lua
---@return evolved.builder builder
function evolved.builder_mt:explicit() end
```

#### `evolved.builder_mt:default`

```lua
---@param default evolved.component
---@return evolved.builder builder
function evolved.builder_mt:default(default) end
```

#### `evolved.builder_mt:duplicate`

```lua
---@param duplicate evolved.duplicate
---@return evolved.builder builder
function evolved.builder_mt:duplicate(duplicate) end
```

#### `evolved.builder_mt:prefab`

```lua
---@return evolved.builder builder
function evolved.builder_mt:prefab() end
```

#### `evolved.builder_mt:disabled`

```lua
---@return evolved.builder builder
function evolved.builder_mt:disabled() end
```

#### `evolved.builder_mt:include`

```lua
---@param ... evolved.fragment fragments
---@return evolved.builder builder
function evolved.builder_mt:include(...) end
```

#### `evolved.builder_mt:exclude`

```lua
---@param ... evolved.fragment fragments
---@return evolved.builder builder
function evolved.builder_mt:exclude(...) end
```

### `evolved.builder_mt:require`

```lua
---@param ... evolved.fragment fragments
---@return evolved.builder builder
function evolved.builder_mt:require(...) end
```

#### `evolved.builder_mt:on_set`

```lua
---@param on_set evolved.set_hook
---@return evolved.builder builder
function evolved.builder_mt:on_set(on_set) end
```

#### `evolved.builder_mt:on_assign`

```lua
---@param on_assign evolved.assign_hook
---@return evolved.builder builder
function evolved.builder_mt:on_assign(on_assign) end
```

#### `evolved.builder_mt:on_insert`

```lua
---@param on_insert evolved.insert_hook
---@return evolved.builder builder
function evolved.builder_mt:on_insert(on_insert) end
```

#### `evolved.builder_mt:on_remove`

```lua
---@param on_remove evolved.remove_hook
---@return evolved.builder builder
function evolved.builder_mt:on_remove(on_remove) end
```

#### `evolved.builder_mt:group`

```lua
---@param group evolved.system
---@return evolved.builder builder
function evolved.builder_mt:group(group) end
```

#### `evolved.builder_mt:query`

```lua
---@param query evolved.query
---@return evolved.builder builder
function evolved.builder_mt:query(query) end
```

#### `evolved.builder_mt:execute`

```lua
---@param execute evolved.execute
---@return evolved.builder builder
function evolved.builder_mt:execute(execute) end
```

#### `evolved.builder_mt:prologue`

```lua
---@param prologue evolved.prologue
---@return evolved.builder builder
function evolved.builder_mt:prologue(prologue) end
```

#### `evolved.builder_mt:epilogue`

```lua
---@param epilogue evolved.epilogue
---@return evolved.builder builder
function evolved.builder_mt:epilogue(epilogue) end
```

#### `evolved.builder_mt:destruction_policy`

```lua
---@param destruction_policy evolved.id
---@return evolved.builder builder
function evolved.builder_mt:destruction_policy(destruction_policy) end
```
