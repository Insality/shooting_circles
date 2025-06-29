local evolved = {
    __HOMEPAGE = 'https://github.com/BlackMATov/evolved.lua',
    __DESCRIPTION = 'Evolved ECS (Entity-Component-System) for Lua',
    __VERSION = '1.1.0',
    __LICENSE = [[
        MIT License

        Copyright (C) 2024-2025, by Matvey Cherevko (blackmatov@gmail.com)

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]]
}

---@class evolved.id

---@alias evolved.entity evolved.id
---@alias evolved.fragment evolved.id
---@alias evolved.query evolved.id
---@alias evolved.system evolved.id

---@alias evolved.component any
---@alias evolved.storage evolved.component[]

---@alias evolved.default evolved.component
---@alias evolved.duplicate fun(component: evolved.component): evolved.component

---@alias evolved.execute fun(
---  chunk: evolved.chunk,
---  entity_list: evolved.entity[],
---  entity_count: integer)

---@alias evolved.prologue fun()
---@alias evolved.epilogue fun()

---@alias evolved.set_hook fun(
---  entity: evolved.entity,
---  fragment: evolved.fragment,
---  new_component: evolved.component,
---  old_component?: evolved.component)

---@alias evolved.assign_hook fun(
---  entity: evolved.entity,
---  fragment: evolved.fragment,
---  new_component: evolved.component,
---  old_component: evolved.component)

---@alias evolved.insert_hook fun(
---  entity: evolved.entity,
---  fragment: evolved.fragment,
---  new_component: evolved.component)

---@alias evolved.remove_hook fun(
---  entity: evolved.entity,
---  fragment: evolved.fragment,
---  component: evolved.component)

---@class (exact) evolved.each_state
---@field package [1] integer structural_changes
---@field package [2] evolved.chunk entity_chunk
---@field package [3] integer entity_place
---@field package [4] integer chunk_fragment_index

---@class (exact) evolved.execute_state
---@field package [1] integer structural_changes
---@field package [2] evolved.chunk[] chunk_stack
---@field package [3] integer chunk_stack_size
---@field package [4] table<evolved.fragment, integer>? exclude_set

---@alias evolved.each_iterator fun(
---  state: evolved.each_state?):
---    evolved.fragment?, evolved.component?

---@alias evolved.execute_iterator fun(
---  state: evolved.execute_state?):
---    evolved.chunk?, evolved.entity[]?, integer?

---
---
---
---
---

local __debug_mode = false ---@type boolean

local __freelist_ids = {} ---@type integer[]
local __acquired_count = 0 ---@type integer
local __available_index = 0 ---@type integer

local __defer_depth = 0 ---@type integer
local __defer_length = 0 ---@type integer
local __defer_bytecode = {} ---@type any[]

local __root_chunks = {} ---@type table<evolved.fragment, evolved.chunk>
local __major_chunks = {} ---@type table<evolved.fragment, evolved.assoc_list>
local __minor_chunks = {} ---@type table<evolved.fragment, evolved.assoc_list>

local __pinned_chunks = {} ---@type table<evolved.chunk, integer>

local __entity_chunks = {} ---@type table<integer, evolved.chunk>
local __entity_places = {} ---@type table<integer, integer>

local __structural_changes = 0 ---@type integer

local __sorted_includes = {} ---@type table<evolved.query, evolved.assoc_list>
local __sorted_excludes = {} ---@type table<evolved.query, evolved.assoc_list>
local __sorted_requires = {} ---@type table<evolved.fragment, evolved.assoc_list>

local __group_subsystems = {} ---@type table<evolved.system, evolved.assoc_list>

---
---
---
---
---

---@class evolved.chunk
---@field package __parent? evolved.chunk
---@field package __child_set table<evolved.chunk, integer>
---@field package __child_list evolved.chunk[]
---@field package __child_count integer
---@field package __entity_list evolved.entity[]
---@field package __entity_count integer
---@field package __fragment evolved.fragment
---@field package __fragment_set table<evolved.fragment, integer>
---@field package __fragment_list evolved.fragment[]
---@field package __fragment_count integer
---@field package __component_count integer
---@field package __component_indices table<evolved.fragment, integer>
---@field package __component_storages evolved.storage[]
---@field package __component_fragments evolved.fragment[]
---@field package __with_fragment_edges table<evolved.fragment, evolved.chunk>
---@field package __without_fragment_edges table<evolved.fragment, evolved.chunk>
---@field package __unreachable_or_collected boolean
---@field package __has_setup_hooks boolean
---@field package __has_assign_hooks boolean
---@field package __has_insert_hooks boolean
---@field package __has_remove_hooks boolean
---@field package __has_unique_major boolean
---@field package __has_unique_minors boolean
---@field package __has_unique_fragments boolean
---@field package __has_explicit_major boolean
---@field package __has_explicit_minors boolean
---@field package __has_explicit_fragments boolean
---@field package __has_required_fragments boolean
local __chunk_mt = {}
__chunk_mt.__index = __chunk_mt

---@class evolved.builder
---@field package __components table<evolved.fragment, evolved.component>
local __builder_mt = {}
__builder_mt.__index = __builder_mt

---
---
---
---
---

local __lua_error = error
local __lua_next = next
local __lua_pcall = pcall
local __lua_print = print
local __lua_select = select
local __lua_setmetatable = setmetatable
local __lua_string_format = string.format
local __lua_table_concat = table.concat
local __lua_table_sort = table.sort

---@type fun(narray: integer, nhash: integer): table
local __lua_table_new = (function()
    -- https://luajit.org/extensions.html
    -- https://create.roblox.com/docs/reference/engine/libraries/table#create
    -- https://forum.defold.com/t/solved-is-luajit-table-new-function-available-in-defold/78623

    do
        ---@diagnostic disable-next-line: undefined-field
        local table_new = table and table.new
        if table_new then
            ---@cast table_new fun(narray: integer, nhash: integer): table
            return table_new
        end
    end

    do
        ---@diagnostic disable-next-line: undefined-field
        local table_create = table and table.create
        if table_create then
            ---@cast table_create fun(count: integer, value: any): table
            return function(narray)
                return table_create(narray)
            end
        end
    end

    do
        local table_new_loader = package and package.preload and package.preload['table.new']
        local table_new = table_new_loader and table_new_loader()
        if table_new then
            ---@cast table_new fun(narray: integer, nhash: integer): table
            return table_new
        end
    end

    ---@return table
    return function()
        return {}
    end
end)()

---@type fun(tab: table)
local __lua_table_clear = (function()
    -- https://luajit.org/extensions.html
    -- https://create.roblox.com/docs/reference/engine/libraries/table#clear
    -- https://forum.defold.com/t/solved-is-luajit-table-new-function-available-in-defold/78623

    do
        ---@diagnostic disable-next-line: undefined-field
        local table_clear = table and table.clear
        if table_clear then
            ---@cast table_clear fun(tab: table)
            return table_clear
        end
    end

    do
        local table_clear_loader = package and package.preload and package.preload['table.clear']
        local table_clear = table_clear_loader and table_clear_loader()
        if table_clear then
            ---@cast table_clear fun(tab: table)
            return table_clear
        end
    end

    ---@param tab table
    return function(tab)
        for i = 1, #tab do tab[i] = nil end
        for k in __lua_next, tab do tab[k] = nil end
    end
end)()

---@type fun(a1: table, f: integer, e: integer, t: integer, a2?: table): table
local __lua_table_move = (function()
    -- https://luajit.org/extensions.html
    -- https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lib_table.c#L132
    -- https://create.roblox.com/docs/reference/engine/libraries/table#move

    do
        ---@diagnostic disable-next-line: deprecated
        local table_move = table and table.move
        if table_move then
            ---@cast table_move fun(a1: table, f: integer, e: integer, t: integer, a2?: table): table
            return table_move
        end
    end

    ---@type fun(a1: table, f: integer, e: integer, t: integer, a2?: table): table
    return function(a1, f, e, t, a2)
        if a2 == nil then
            a2 = a1
        end

        if e < f then
            return a2
        end

        local d = t - f

        if t > e or t <= f or a2 ~= a1 then
            for i = f, e do
                a2[i + d] = a1[i]
            end
        else
            for i = e, f, -1 do
                a2[i + d] = a1[i]
            end
        end

        return a2
    end
end)()

---@type fun(lst: table, i: integer, j: integer): ...
local __lua_table_unpack = (function()
    do
        ---@diagnostic disable-next-line: deprecated
        local table_unpack = unpack
        if table_unpack then return table_unpack end
    end

    do
        ---@diagnostic disable-next-line: deprecated
        local table_unpack = table and table.unpack
        if table_unpack then return table_unpack end
    end
end)()

---
---
---
---
---

---@param fmt string
---@param ... any
---@diagnostic disable-next-line: unused-local, unused-function
local function __error_fmt(fmt, ...)
    __lua_error(__lua_string_format('| evolved.lua | %s',
        __lua_string_format(fmt, ...)))
end

---@param fmt string
---@param ... any
---@diagnostic disable-next-line: unused-local, unused-function
local function __warning_fmt(fmt, ...)
    __lua_print(__lua_string_format('| evolved.lua | %s',
        __lua_string_format(fmt, ...)))
end

---
---
---
---
---

---@return evolved.id
---@nodiscard
local function __acquire_id()
    local freelist_ids = __freelist_ids
    local available_index = __available_index

    if available_index ~= 0 then
        local acquired_index = available_index
        local freelist_id = freelist_ids[acquired_index]

        local next_available_index = freelist_id % 0x100000
        local shifted_version = freelist_id - next_available_index

        __available_index = next_available_index

        local acquired_id = acquired_index + shifted_version
        freelist_ids[acquired_index] = acquired_id

        return acquired_id --[[@as evolved.id]]
    else
        local acquired_count = __acquired_count

        if acquired_count == 0xFFFFF then
            __error_fmt('id index overflow')
        end

        acquired_count = acquired_count + 1
        __acquired_count = acquired_count

        local acquired_index = acquired_count
        local shifted_version = 0x100000

        local acquired_id = acquired_index + shifted_version
        freelist_ids[acquired_index] = acquired_id

        return acquired_id --[[@as evolved.id]]
    end
end

---@param id evolved.id
local function __release_id(id)
    local acquired_index = id % 0x100000
    local shifted_version = id - acquired_index

    local freelist_ids = __freelist_ids

    if freelist_ids[acquired_index] ~= id then
        __error_fmt('id is not acquired or already released')
    end

    shifted_version = shifted_version == 0xFFFFF * 0x100000
        and 0x100000
        or shifted_version + 0x100000

    freelist_ids[acquired_index] = __available_index + shifted_version
    __available_index = acquired_index
end

---
---
---
---
---

---@enum evolved.table_pool_tag
local __table_pool_tag = {
    bytecode = 1,
    chunk_list = 2,
    system_list = 3,
    each_state = 4,
    execute_state = 5,
    entity_set = 6,
    entity_list = 7,
    fragment_set = 8,
    fragment_list = 9,
    component_map = 10,
    component_list = 11,
    __count = 11,
}

---@class (exact) evolved.table_pool
---@field package __size integer
---@field package [integer] table

---@type table<evolved.table_pool_tag, evolved.table_pool>
local __tagged_table_pools = (function()
    local table_pools = __lua_table_new(__table_pool_tag.__count, 0)
    local table_pool_reserve = 16

    for tag = 1, __table_pool_tag.__count do
        ---@type evolved.table_pool
        local table_pool = __lua_table_new(table_pool_reserve, 1)
        for i = 1, table_pool_reserve do table_pool[i] = {} end
        table_pool.__size = table_pool_reserve
        table_pools[tag] = table_pool
    end

    return table_pools
end)()

---@param tag evolved.table_pool_tag
---@return table
---@nodiscard
local function __acquire_table(tag)
    local table_pool = __tagged_table_pools[tag]
    local table_pool_size = table_pool.__size

    if table_pool_size == 0 then
        return {}
    end

    local table = table_pool[table_pool_size]

    table_pool[table_pool_size] = nil
    table_pool_size = table_pool_size - 1

    table_pool.__size = table_pool_size
    return table
end

---@param tag evolved.table_pool_tag
---@param table table
---@param no_clear? boolean
local function __release_table(tag, table, no_clear)
    local table_pool = __tagged_table_pools[tag]
    local table_pool_size = table_pool.__size

    if not no_clear then
        __lua_table_clear(table)
    end

    table_pool_size = table_pool_size + 1
    table_pool[table_pool_size] = table

    table_pool.__size = table_pool_size
end

---
---
---
---
---

---@class (exact) evolved.assoc_list
---@field package __item_set table<any, integer>
---@field package __item_list any[]
---@field package __item_count integer

local __assoc_list_new
local __assoc_list_sort
local __assoc_list_sort_ex
local __assoc_list_insert
local __assoc_list_insert_ex
local __assoc_list_remove
local __assoc_list_remove_ex

---@param reserve? integer
---@return evolved.assoc_list
---@nodiscard
function __assoc_list_new(reserve)
    ---@type evolved.assoc_list
    return {
        __item_set = __lua_table_new(0, reserve or 0),
        __item_list = __lua_table_new(reserve or 0, 0),
        __item_count = 0,
    }
end

---@generic K
---@param al evolved.assoc_list<K>
---@param comp? fun(a: K, b: K): boolean
function __assoc_list_sort(al, comp)
    __assoc_list_sort_ex(
        al.__item_set, al.__item_list, al.__item_count,
        comp)
end

---@generic K
---@param al_item_set table<K, integer>
---@param al_item_list K[]
---@param al_item_count integer
---@param comp? fun(a: K, b: K): boolean
function __assoc_list_sort_ex(al_item_set, al_item_list, al_item_count, comp)
    if al_item_count < 2 then
        return
    end

    __lua_table_sort(al_item_list, comp)

    for al_item_index = 1, al_item_count do
        local al_item = al_item_list[al_item_index]
        al_item_set[al_item] = al_item_index
    end
end

---@generic K
---@param al evolved.assoc_list<K>
---@param item K
function __assoc_list_insert(al, item)
    al.__item_count = __assoc_list_insert_ex(
        al.__item_set, al.__item_list, al.__item_count,
        item)
end

---@generic K
---@param al_item_set table<K, integer>
---@param al_item_list K[]
---@param al_item_count integer
---@param item K
---@return integer new_al_count
---@nodiscard
function __assoc_list_insert_ex(al_item_set, al_item_list, al_item_count, item)
    local item_index = al_item_set[item]

    if item_index then
        return al_item_count
    end

    al_item_count = al_item_count + 1
    al_item_set[item] = al_item_count
    al_item_list[al_item_count] = item

    return al_item_count
end

---@generic K
---@param al evolved.assoc_list<K>
---@param item K
function __assoc_list_remove(al, item)
    al.__item_count = __assoc_list_remove_ex(
        al.__item_set, al.__item_list, al.__item_count,
        item)
end

---@generic K
---@param al_item_set table<K, integer>
---@param al_item_list K[]
---@param al_item_count integer
---@param item K
---@return integer new_al_count
---@nodiscard
function __assoc_list_remove_ex(al_item_set, al_item_list, al_item_count, item)
    local item_index = al_item_set[item]

    if not item_index then
        return al_item_count
    end

    for al_item_index = item_index, al_item_count - 1 do
        local al_next_item = al_item_list[al_item_index + 1]
        al_item_set[al_next_item] = al_item_index
        al_item_list[al_item_index] = al_next_item
    end

    al_item_set[item] = nil
    al_item_list[al_item_count] = nil
    al_item_count = al_item_count - 1

    return al_item_count
end

---
---
---
---
---

---@type evolved.each_iterator
local function __each_iterator(each_state)
    if not each_state then return end

    local structural_changes = each_state[1]
    local entity_chunk = each_state[2]
    local entity_place = each_state[3]
    local chunk_fragment_index = each_state[4]

    if structural_changes ~= __structural_changes then
        __error_fmt('structural changes are prohibited during iteration')
    end

    local chunk_fragment_list = entity_chunk.__fragment_list
    local chunk_fragment_count = entity_chunk.__fragment_count
    local chunk_component_indices = entity_chunk.__component_indices
    local chunk_component_storages = entity_chunk.__component_storages

    if chunk_fragment_index <= chunk_fragment_count then
        each_state[4] = chunk_fragment_index + 1
        local fragment = chunk_fragment_list[chunk_fragment_index]
        local component_index = chunk_component_indices[fragment]
        local component_storage = chunk_component_storages[component_index]
        return fragment, component_storage and component_storage[entity_place]
    end

    __release_table(__table_pool_tag.each_state, each_state, true)
end

---@type evolved.execute_iterator
local function __execute_iterator(execute_state)
    if not execute_state then return end

    local structural_changes = execute_state[1]
    local chunk_stack = execute_state[2]
    local chunk_stack_size = execute_state[3]
    local exclude_set = execute_state[4]

    if structural_changes ~= __structural_changes then
        __error_fmt('structural changes are prohibited during iteration')
    end

    while chunk_stack_size > 0 do
        local chunk = chunk_stack[chunk_stack_size]

        chunk_stack[chunk_stack_size] = nil
        chunk_stack_size = chunk_stack_size - 1

        local chunk_child_list = chunk.__child_list
        local chunk_child_count = chunk.__child_count

        for i = 1, chunk_child_count do
            local chunk_child = chunk_child_list[i]
            local chunk_child_fragment = chunk_child.__fragment

            local is_chunk_child_matched =
                (not chunk_child.__has_explicit_major) and
                (not exclude_set or not exclude_set[chunk_child_fragment])

            if is_chunk_child_matched then
                chunk_stack_size = chunk_stack_size + 1
                chunk_stack[chunk_stack_size] = chunk_child
            end
        end

        local chunk_entity_list = chunk.__entity_list
        local chunk_entity_count = chunk.__entity_count

        if chunk_entity_count > 0 then
            execute_state[3] = chunk_stack_size
            return chunk, chunk_entity_list, chunk_entity_count
        end
    end

    __release_table(__table_pool_tag.chunk_list, chunk_stack, true)
    __release_table(__table_pool_tag.execute_state, execute_state, true)
end

---
---
---
---
---

local __TAG = __acquire_id()
local __NAME = __acquire_id()

local __UNIQUE = __acquire_id()
local __EXPLICIT = __acquire_id()

local __DEFAULT = __acquire_id()
local __DUPLICATE = __acquire_id()

local __PREFAB = __acquire_id()
local __DISABLED = __acquire_id()

local __INCLUDES = __acquire_id()
local __EXCLUDES = __acquire_id()
local __REQUIRES = __acquire_id()

local __ON_SET = __acquire_id()
local __ON_ASSIGN = __acquire_id()
local __ON_INSERT = __acquire_id()
local __ON_REMOVE = __acquire_id()

local __GROUP = __acquire_id()

local __QUERY = __acquire_id()
local __EXECUTE = __acquire_id()

local __PROLOGUE = __acquire_id()
local __EPILOGUE = __acquire_id()

local __DESTRUCTION_POLICY = __acquire_id()
local __DESTRUCTION_POLICY_DESTROY_ENTITY = __acquire_id()
local __DESTRUCTION_POLICY_REMOVE_FRAGMENT = __acquire_id()

---
---
---
---
---

local __safe_tbls = {
    ---@type table<evolved.fragment, integer>
    __EMPTY_FRAGMENT_SET = __lua_setmetatable({}, {
        __tostring = function() return 'empty fragment set' end,
        __newindex = function() __error_fmt 'attempt to modify empty fragment set' end
    }),

    ---@type evolved.fragment[]
    __EMPTY_FRAGMENT_LIST = __lua_setmetatable({}, {
        __tostring = function() return 'empty fragment list' end,
        __newindex = function() __error_fmt 'attempt to modify empty fragment list' end
    }),

    ---@type table<evolved.fragment, evolved.component>
    __EMPTY_COMPONENT_MAP = __lua_setmetatable({}, {
        __tostring = function() return 'empty component map' end,
        __newindex = function() __error_fmt 'attempt to modify empty component map' end
    }),

    ---@type evolved.component[]
    __EMPTY_COMPONENT_LIST = __lua_setmetatable({}, {
        __tostring = function() return 'empty component list' end,
        __newindex = function() __error_fmt 'attempt to modify empty component list' end
    }),

    ---@type evolved.component[]
    __EMPTY_COMPONENT_STORAGE = __lua_setmetatable({}, {
        __tostring = function() return 'empty component storage' end,
        __newindex = function() __error_fmt 'attempt to modify empty component storage' end
    }),
}

---
---
---
---
---

local __evolved_id

local __evolved_pack
local __evolved_unpack

local __evolved_defer
local __evolved_commit

local __evolved_spawn
local __evolved_clone

local __evolved_alive
local __evolved_alive_all
local __evolved_alive_any

local __evolved_empty
local __evolved_empty_all
local __evolved_empty_any

local __evolved_has
local __evolved_has_all
local __evolved_has_any

local __evolved_get

local __evolved_set
local __evolved_remove
local __evolved_clear
local __evolved_destroy

local __evolved_batch_set
local __evolved_batch_remove
local __evolved_batch_clear
local __evolved_batch_destroy

local __evolved_each
local __evolved_execute

local __evolved_process

local __evolved_debug_mode
local __evolved_collect_garbage

local __evolved_chunk
local __evolved_builder

---
---
---
---
---

---@param id evolved.id
---@return string
---@nodiscard
local function __id_name(id)
    ---@type string?
    local id_name = __evolved_get(id, __NAME)

    if id_name then
        return id_name
    end

    local id_index, id_version = __evolved_unpack(id)
    return __lua_string_format('$%d#%d:%d', id, id_index, id_version)
end

---@generic K
---@param old_list K[]
---@return K[]
---@nodiscard
local function __list_copy(old_list)
    local old_list_size = #old_list

    if old_list_size == 0 then
        return {}
    end

    local new_list = __lua_table_new(old_list_size, 0)

    __lua_table_move(
        old_list, 1, old_list_size,
        1, new_list)

    return new_list
end

---@param fragment evolved.fragment
---@return evolved.storage
---@nodiscard
---@diagnostic disable-next-line: unused-local
local function __component_storage(fragment)
    return {}
end

---
---
---
---
---

local __debug_fns = {}

---@param entity evolved.entity
function __debug_fns.validate_entity(entity)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        __error_fmt('the entity (%s) is not alive and cannot be used',
            __id_name(entity))
    end
end

---@param prefab evolved.entity
function __debug_fns.validate_prefab(prefab)
    local prefab_index = prefab % 0x100000

    if __freelist_ids[prefab_index] ~= prefab then
        __error_fmt('the prefab (%s) is not alive and cannot be used',
            __id_name(prefab))
    end
end

---@param ... evolved.entity entities
function __debug_fns.validate_entities(...)
    for i = 1, __lua_select('#', ...) do
        __debug_fns.validate_entity(__lua_select(i, ...))
    end
end

---@param fragment evolved.fragment
function __debug_fns.validate_fragment(fragment)
    local fragment_index = fragment % 0x100000

    if __freelist_ids[fragment_index] ~= fragment then
        __error_fmt('the fragment (%s) is not alive and cannot be used',
            __id_name(fragment))
    end
end

---@param ... evolved.fragment fragments
function __debug_fns.validate_fragments(...)
    for i = 1, __lua_select('#', ...) do
        __debug_fns.validate_fragment(__lua_select(i, ...))
    end
end

---@param components table<evolved.fragment, evolved.component>
function __debug_fns.validate_component_map(components)
    for fragment in __lua_next, components do
        __debug_fns.validate_fragment(fragment)
    end
end

---@param query evolved.query
function __debug_fns.validate_query(query)
    local query_index = query % 0x100000

    if __freelist_ids[query_index] ~= query then
        __error_fmt('the query (%s) is not alive and cannot be used',
            __id_name(query))
    end
end

---@param system evolved.system
function __debug_fns.validate_system(system)
    local system_index = system % 0x100000

    if __freelist_ids[system_index] ~= system then
        __error_fmt('the system (%s) is not alive and cannot be used',
            __id_name(system))
    end
end

---@param ... evolved.system systems
function __debug_fns.validate_systems(...)
    for i = 1, __lua_select('#', ...) do
        __debug_fns.validate_system(__lua_select(i, ...))
    end
end

---
---
---
---
---

local __new_chunk
local __update_chunk_tags
local __update_chunk_flags
local __trace_major_chunks
local __update_major_chunks_hook
local __update_major_chunks_trace

---@param chunk_parent? evolved.chunk
---@param chunk_fragment evolved.fragment
---@return evolved.chunk
---@nodiscard
function __new_chunk(chunk_parent, chunk_fragment)
    ---@type table<evolved.fragment, integer>
    local chunk_fragment_set = {}

    ---@type evolved.fragment[]
    local chunk_fragment_list = {}

    ---@type integer
    local chunk_fragment_count = 0

    if chunk_parent then
        local parent_fragment_list = chunk_parent.__fragment_list
        local parent_fragment_count = chunk_parent.__fragment_count

        for parent_fragment_index = 1, parent_fragment_count do
            local parent_fragment = parent_fragment_list[parent_fragment_index]

            chunk_fragment_count = __assoc_list_insert_ex(
                chunk_fragment_set, chunk_fragment_list, chunk_fragment_count,
                parent_fragment)
        end
    end

    do
        chunk_fragment_count = chunk_fragment_count + 1
        chunk_fragment_set[chunk_fragment] = chunk_fragment_count
        chunk_fragment_list[chunk_fragment_count] = chunk_fragment
    end

    ---@type evolved.chunk
    local chunk = __lua_setmetatable({
        __parent = nil,
        __child_set = {},
        __child_list = {},
        __child_count = 0,
        __entity_list = {},
        __entity_count = 0,
        __fragment = chunk_fragment,
        __fragment_set = chunk_fragment_set,
        __fragment_list = chunk_fragment_list,
        __fragment_count = chunk_fragment_count,
        __component_count = 0,
        __component_indices = {},
        __component_storages = {},
        __component_fragments = {},
        __with_fragment_edges = {},
        __without_fragment_edges = {},
        __unreachable_or_collected = false,
        __has_setup_hooks = false,
        __has_assign_hooks = false,
        __has_insert_hooks = false,
        __has_remove_hooks = false,
        __has_unique_major = false,
        __has_unique_minors = false,
        __has_unique_fragments = false,
        __has_explicit_major = false,
        __has_explicit_minors = false,
        __has_explicit_fragments = false,
        __has_required_fragments = false,
    }, __chunk_mt)

    if chunk_parent then
        chunk.__parent = chunk_parent

        chunk_parent.__child_count = __assoc_list_insert_ex(
            chunk_parent.__child_set, chunk_parent.__child_list, chunk_parent.__child_count,
            chunk)

        chunk_parent.__with_fragment_edges[chunk_fragment] = chunk
        chunk.__without_fragment_edges[chunk_fragment] = chunk_parent
    end

    if not chunk_parent then
        local root_fragment = chunk_fragment
        __root_chunks[root_fragment] = chunk
    end

    do
        local major_fragment = chunk_fragment
        local major_chunks = __major_chunks[major_fragment]

        if not major_chunks then
            major_chunks = __assoc_list_new(4)
            __major_chunks[major_fragment] = major_chunks
        end

        __assoc_list_insert(major_chunks, chunk)
    end

    for i = 1, chunk_fragment_count do
        local minor_fragment = chunk_fragment_list[i]
        local minor_chunks = __minor_chunks[minor_fragment]

        if not minor_chunks then
            minor_chunks = __assoc_list_new(4)
            __minor_chunks[minor_fragment] = minor_chunks
        end

        __assoc_list_insert(minor_chunks, chunk)
    end

    __update_chunk_tags(chunk)
    __update_chunk_flags(chunk)

    return chunk
end

---@param chunk evolved.chunk
function __update_chunk_tags(chunk)
    local fragment_list = chunk.__fragment_list
    local fragment_count = chunk.__fragment_count

    local component_count = chunk.__component_count
    local component_indices = chunk.__component_indices
    local component_storages = chunk.__component_storages
    local component_fragments = chunk.__component_fragments

    for i = 1, fragment_count do
        local fragment = fragment_list[i]
        local component_index = component_indices[fragment]

        if component_index and __evolved_has(fragment, __TAG) then
            if component_index ~= component_count then
                local last_component_storage = component_storages[component_count]
                local last_component_fragment = component_fragments[component_count]
                component_indices[last_component_fragment] = component_index
                component_storages[component_index] = last_component_storage
                component_fragments[component_index] = last_component_fragment
            end

            component_indices[fragment] = nil
            component_storages[component_count] = nil
            component_fragments[component_count] = nil

            component_count = component_count - 1
            chunk.__component_count = component_count
        end

        if not component_index and not __evolved_has(fragment, __TAG) then
            component_count = component_count + 1
            chunk.__component_count = component_count

            local component_storage = __component_storage(fragment)
            local component_storage_index = component_count

            component_indices[fragment] = component_storage_index
            component_storages[component_storage_index] = component_storage
            component_fragments[component_storage_index] = fragment

            ---@type evolved.default?, evolved.duplicate?
            local fragment_default, fragment_duplicate =
                __evolved_get(fragment, __DEFAULT, __DUPLICATE)

            if fragment_duplicate then
                for place = 1, chunk.__entity_count do
                    local new_component = fragment_default
                    if new_component ~= nil then new_component = fragment_duplicate(new_component) end
                    if new_component == nil then new_component = true end
                    component_storage[place] = new_component
                end
            else
                local new_component = fragment_default
                if new_component == nil then new_component = true end
                for place = 1, chunk.__entity_count do
                    component_storage[place] = new_component
                end
            end
        end
    end
end

---@param chunk evolved.chunk
function __update_chunk_flags(chunk)
    local chunk_parent = chunk.__parent
    local chunk_fragment = chunk.__fragment

    local has_setup_hooks = (chunk_parent ~= nil and chunk_parent.__has_setup_hooks)
        or __evolved_has_any(chunk_fragment, __DEFAULT, __DUPLICATE)

    local has_assign_hooks = (chunk_parent ~= nil and chunk_parent.__has_assign_hooks)
        or __evolved_has_any(chunk_fragment, __ON_SET, __ON_ASSIGN)

    local has_insert_hooks = (chunk_parent ~= nil and chunk_parent.__has_insert_hooks)
        or __evolved_has_any(chunk_fragment, __ON_SET, __ON_INSERT)

    local has_remove_hooks = (chunk_parent ~= nil and chunk_parent.__has_remove_hooks)
        or __evolved_has(chunk_fragment, __ON_REMOVE)

    local has_unique_major = __evolved_has(chunk_fragment, __UNIQUE)
    local has_unique_minors = chunk_parent ~= nil and chunk_parent.__has_unique_fragments
    local has_unique_fragments = has_unique_major or has_unique_minors

    local has_explicit_major = __evolved_has(chunk_fragment, __EXPLICIT)
    local has_explicit_minors = chunk_parent ~= nil and chunk_parent.__has_explicit_fragments
    local has_explicit_fragments = has_explicit_major or has_explicit_minors

    local has_required_fragments = (chunk_parent ~= nil and chunk_parent.__has_required_fragments)
        or __evolved_has(chunk_fragment, __REQUIRES)

    chunk.__has_setup_hooks = has_setup_hooks
    chunk.__has_assign_hooks = has_assign_hooks
    chunk.__has_insert_hooks = has_insert_hooks
    chunk.__has_remove_hooks = has_remove_hooks

    chunk.__has_unique_major = has_unique_major
    chunk.__has_unique_minors = has_unique_minors
    chunk.__has_unique_fragments = has_unique_fragments

    chunk.__has_explicit_major = has_explicit_major
    chunk.__has_explicit_minors = has_explicit_minors
    chunk.__has_explicit_fragments = has_explicit_fragments

    chunk.__has_required_fragments = has_required_fragments
end

---@param major evolved.fragment
---@param trace fun(chunk: evolved.chunk, ...: any): boolean
---@param ... any additional trace arguments
function __trace_major_chunks(major, trace, ...)
    ---@type evolved.chunk[]
    local chunk_stack = __acquire_table(__table_pool_tag.chunk_list)
    local chunk_stack_size = 0

    do
        local major_chunks = __major_chunks[major]
        local major_chunk_list = major_chunks and major_chunks.__item_list --[=[@as evolved.chunk[]]=]
        local major_chunk_count = major_chunks and major_chunks.__item_count or 0 --[[@as integer]]

        if major_chunk_count > 0 then
            __lua_table_move(
                major_chunk_list, 1, major_chunk_count,
                chunk_stack_size + 1, chunk_stack)

            chunk_stack_size = chunk_stack_size + major_chunk_count
        end
    end

    while chunk_stack_size > 0 do
        local chunk = chunk_stack[chunk_stack_size]

        chunk_stack[chunk_stack_size] = nil
        chunk_stack_size = chunk_stack_size - 1

        if trace(chunk, ...) then
            local chunk_child_list = chunk.__child_list
            local chunk_child_count = chunk.__child_count

            __lua_table_move(
                chunk_child_list, 1, chunk_child_count,
                chunk_stack_size + 1, chunk_stack)

            chunk_stack_size = chunk_stack_size + chunk_child_count
        end
    end

    __release_table(__table_pool_tag.chunk_list, chunk_stack, true)
end

---@param major evolved.fragment
function __update_major_chunks_hook(major)
    __trace_major_chunks(major, __update_major_chunks_trace)
end

---@param chunk evolved.chunk
---@return boolean
function __update_major_chunks_trace(chunk)
    __update_chunk_tags(chunk)
    __update_chunk_flags(chunk)
    return true
end

---
---
---
---
---

---@param chunk? evolved.chunk
---@param fragment evolved.fragment
---@return evolved.chunk
---@nodiscard
local function __chunk_with_fragment(chunk, fragment)
    if not chunk then
        local root_chunk = __root_chunks[fragment]
        return root_chunk or __new_chunk(nil, fragment)
    end

    if chunk.__fragment_set[fragment] then
        return chunk
    end

    do
        local with_fragment_edge = chunk.__with_fragment_edges[fragment]
        if with_fragment_edge then return with_fragment_edge end
    end

    if fragment < chunk.__fragment then
        local sibling_chunk = __chunk_with_fragment(
            __chunk_with_fragment(chunk.__parent, fragment),
            chunk.__fragment)

        chunk.__with_fragment_edges[fragment] = sibling_chunk
        sibling_chunk.__without_fragment_edges[fragment] = chunk

        return sibling_chunk
    end

    return __new_chunk(chunk, fragment)
end

---@param chunk? evolved.chunk
---@param components table<evolved.fragment, evolved.component>
---@return evolved.chunk?
---@nodiscard
local function __chunk_with_components(chunk, components)
    for fragment in __lua_next, components do
        chunk = __chunk_with_fragment(chunk, fragment)
    end

    return chunk
end

---@param chunk? evolved.chunk
---@param fragment evolved.fragment
---@return evolved.chunk?
---@nodiscard
local function __chunk_without_fragment(chunk, fragment)
    if not chunk then
        return nil
    end

    if not chunk.__fragment_set[fragment] then
        return chunk
    end

    if fragment == chunk.__fragment then
        return chunk.__parent
    end

    do
        local without_fragment_edge = chunk.__without_fragment_edges[fragment]
        if without_fragment_edge then return without_fragment_edge end
    end

    if fragment < chunk.__fragment then
        local sibling_chunk = __chunk_with_fragment(
            __chunk_without_fragment(chunk.__parent, fragment),
            chunk.__fragment)

        chunk.__without_fragment_edges[fragment] = sibling_chunk
        sibling_chunk.__with_fragment_edges[fragment] = chunk

        return sibling_chunk
    end

    return chunk
end

---@param chunk? evolved.chunk
---@param ... evolved.fragment fragments
---@return evolved.chunk?
---@nodiscard
local function __chunk_without_fragments(chunk, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return chunk
    end

    for i = 1, fragment_count do
        ---@type evolved.fragment
        local fragment = __lua_select(i, ...)
        chunk = __chunk_without_fragment(chunk, fragment)
    end

    return chunk
end

---@param chunk? evolved.chunk
---@return evolved.chunk?
---@nodiscard
local function __chunk_without_unique_fragments(chunk)
    if not chunk then
        return nil
    end

    if not chunk.__has_unique_fragments then
        return chunk
    end

    while chunk and chunk.__has_unique_major do
        chunk = chunk.__parent
    end

    local new_chunk = nil

    if chunk then
        local chunk_fragment_list = chunk.__fragment_list
        local chunk_fragment_count = chunk.__fragment_count

        for i = 1, chunk_fragment_count do
            local fragment = chunk_fragment_list[i]

            if not __evolved_has(fragment, __UNIQUE) then
                new_chunk = __chunk_with_fragment(new_chunk, fragment)
            end
        end
    end

    return new_chunk
end

---
---
---
---
---

---@param head_fragment evolved.fragment
---@param ... evolved.fragment tail_fragments
---@return evolved.chunk
---@nodiscard
local function __chunk_fragments(head_fragment, ...)
    local chunk = __root_chunks[head_fragment]
        or __chunk_with_fragment(nil, head_fragment)

    for i = 1, __lua_select('#', ...) do
        ---@type evolved.fragment
        local tail_fragment = __lua_select(i, ...)
        chunk = chunk.__with_fragment_edges[tail_fragment]
            or __chunk_with_fragment(chunk, tail_fragment)
    end

    return chunk
end

---@param components table<evolved.fragment, evolved.component>
---@return evolved.chunk?
---@nodiscard
local function __chunk_components(components)
    local root_fragment = __lua_next(components)

    if not root_fragment then
        return
    end

    local chunk = __root_chunks[root_fragment]
        or __chunk_with_fragment(nil, root_fragment)

    for tail_fragment in __lua_next, components, root_fragment do
        chunk = chunk.__with_fragment_edges[tail_fragment]
            or __chunk_with_fragment(chunk, tail_fragment)
    end

    return chunk
end

---
---
---
---
---

---@param chunk evolved.chunk
---@param fragment evolved.fragment
---@return boolean
---@nodiscard
local function __chunk_has_fragment(chunk, fragment)
    return chunk.__fragment_set[fragment] ~= nil
end

---@param chunk evolved.chunk
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
local function __chunk_has_all_fragments(chunk, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return true
    end

    local fs = chunk.__fragment_set

    if fragment_count == 1 then
        local f1 = ...
        return fs[f1] ~= nil
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        return fs[f1] ~= nil and fs[f2] ~= nil
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        return fs[f1] ~= nil and fs[f2] ~= nil and fs[f3] ~= nil
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        return fs[f1] ~= nil and fs[f2] ~= nil and fs[f3] ~= nil and fs[f4] ~= nil
    end

    do
        local f1, f2, f3, f4 = ...
        return fs[f1] ~= nil and fs[f2] ~= nil and fs[f3] ~= nil and fs[f4] ~= nil and
            __chunk_has_all_fragments(chunk, __lua_select(5, ...))
    end
end

---@param chunk evolved.chunk
---@param fragment_list evolved.fragment[]
---@param fragment_count integer
---@return boolean
---@nodiscard
local function __chunk_has_all_fragment_list(chunk, fragment_list, fragment_count)
    local fragment_set = chunk.__fragment_set

    for i = 1, fragment_count do
        local fragment = fragment_list[i]
        if not fragment_set[fragment] then
            return false
        end
    end

    return true
end

---@param chunk evolved.chunk
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
local function __chunk_has_any_fragments(chunk, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return false
    end

    local fs = chunk.__fragment_set

    if fragment_count == 1 then
        local f1 = ...
        return fs[f1] ~= nil
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        return fs[f1] ~= nil or fs[f2] ~= nil
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        return fs[f1] ~= nil or fs[f2] ~= nil or fs[f3] ~= nil
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        return fs[f1] ~= nil or fs[f2] ~= nil or fs[f3] ~= nil or fs[f4] ~= nil
    end

    do
        local f1, f2, f3, f4 = ...
        return fs[f1] ~= nil or fs[f2] ~= nil or fs[f3] ~= nil or fs[f4] ~= nil or
            __chunk_has_any_fragments(chunk, __lua_select(5, ...))
    end
end

---@param chunk evolved.chunk
---@param fragment_list evolved.fragment[]
---@param fragment_count integer
---@return boolean
---@nodiscard
local function __chunk_has_any_fragment_list(chunk, fragment_list, fragment_count)
    local fragment_set = chunk.__fragment_set

    for i = 1, fragment_count do
        local fragment = fragment_list[i]
        if fragment_set[fragment] then
            return true
        end
    end

    return false
end

---@param chunk evolved.chunk
---@param place integer
---@param ... evolved.fragment fragments
---@return evolved.component ... components
---@nodiscard
local function __chunk_get_components(chunk, place, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return
    end

    local indices = chunk.__component_indices
    local storages = chunk.__component_storages

    if fragment_count == 1 then
        local f1 = ...
        local i1 = indices[f1]
        return
            i1 and storages[i1][place]
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        local i1, i2 = indices[f1], indices[f2]
        return
            i1 and storages[i1][place],
            i2 and storages[i2][place]
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        local i1, i2, i3 = indices[f1], indices[f2], indices[f3]
        return
            i1 and storages[i1][place],
            i2 and storages[i2][place],
            i3 and storages[i3][place]
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        local i1, i2, i3, i4 = indices[f1], indices[f2], indices[f3], indices[f4]
        return
            i1 and storages[i1][place],
            i2 and storages[i2][place],
            i3 and storages[i3][place],
            i4 and storages[i4][place]
    end

    do
        local f1, f2, f3, f4 = ...
        local i1, i2, i3, i4 = indices[f1], indices[f2], indices[f3], indices[f4]
        return
            i1 and storages[i1][place],
            i2 and storages[i2][place],
            i3 and storages[i3][place],
            i4 and storages[i4][place],
            __chunk_get_components(chunk, place, __lua_select(5, ...))
    end
end

---
---
---
---
---

---@param chunk evolved.chunk
---@param req_fragment_set table<evolved.fragment, integer>
---@param req_fragment_list evolved.fragment[]
---@param req_fragment_count integer
---@return integer
---@nodiscard
local function __chunk_required_fragments(chunk, req_fragment_set, req_fragment_list, req_fragment_count)
    ---@type evolved.fragment[]
    local fragment_stack = __acquire_table(__table_pool_tag.fragment_list)
    local fragment_stack_size = 0

    do
        local chunk_fragment_list = chunk.__fragment_list
        local chunk_fragment_count = chunk.__fragment_count

        __lua_table_move(
            chunk_fragment_list, 1, chunk_fragment_count,
            fragment_stack_size + 1, fragment_stack)

        fragment_stack_size = fragment_stack_size + chunk_fragment_count
    end

    while fragment_stack_size > 0 do
        local stack_fragment = fragment_stack[fragment_stack_size]

        fragment_stack[fragment_stack_size] = nil
        fragment_stack_size = fragment_stack_size - 1

        local fragment_requires = __sorted_requires[stack_fragment]
        local fragment_require_list = fragment_requires and fragment_requires.__item_list
        local fragment_require_count = fragment_requires and fragment_requires.__item_count or 0

        for fragment_require_index = 1, fragment_require_count do
            ---@cast fragment_require_list -?
            local required_fragment = fragment_require_list[fragment_require_index]

            if req_fragment_set[required_fragment] then
                -- this fragment has already been gathered
            else
                req_fragment_count = req_fragment_count + 1
                req_fragment_set[required_fragment] = req_fragment_count
                req_fragment_list[req_fragment_count] = required_fragment

                fragment_stack_size = fragment_stack_size + 1
                fragment_stack[fragment_stack_size] = required_fragment
            end
        end
    end

    __release_table(__table_pool_tag.fragment_list, fragment_stack, true)
    return req_fragment_count
end

---@param fragment evolved.fragment
---@param req_fragment_set table<evolved.fragment, integer>
---@param req_fragment_list evolved.fragment[]
---@param req_fragment_count integer
---@return integer
---@nodiscard
local function __fragment_required_fragments(fragment, req_fragment_set, req_fragment_list, req_fragment_count)
    ---@type evolved.fragment[]
    local fragment_stack = __acquire_table(__table_pool_tag.fragment_list)
    local fragment_stack_size = 0

    do
        fragment_stack_size = fragment_stack_size + 1
        fragment_stack[fragment_stack_size] = fragment
    end

    while fragment_stack_size > 0 do
        local stack_fragment = fragment_stack[fragment_stack_size]

        fragment_stack[fragment_stack_size] = nil
        fragment_stack_size = fragment_stack_size - 1

        local fragment_requires = __sorted_requires[stack_fragment]
        local fragment_require_list = fragment_requires and fragment_requires.__item_list
        local fragment_require_count = fragment_requires and fragment_requires.__item_count or 0

        for fragment_require_index = 1, fragment_require_count do
            ---@cast fragment_require_list -?
            local required_fragment = fragment_require_list[fragment_require_index]

            if req_fragment_set[required_fragment] then
                -- this fragment has already been gathered
            else
                req_fragment_count = req_fragment_count + 1
                req_fragment_set[required_fragment] = req_fragment_count
                req_fragment_list[req_fragment_count] = required_fragment

                fragment_stack_size = fragment_stack_size + 1
                fragment_stack[fragment_stack_size] = required_fragment
            end
        end
    end

    __release_table(__table_pool_tag.fragment_list, fragment_stack, true)
    return req_fragment_count
end

---
---
---
---
---

local __defer_set
local __defer_remove
local __defer_clear
local __defer_destroy

local __defer_batch_set
local __defer_batch_remove
local __defer_batch_clear
local __defer_batch_destroy

local __defer_spawn_entity
local __defer_clone_entity

local __defer_call_hook

---
---
---
---
---

---@param chunk evolved.chunk
---@param place integer
local function __detach_entity(chunk, place)
    local entity_list = chunk.__entity_list
    local entity_count = chunk.__entity_count

    local component_count = chunk.__component_count
    local component_storages = chunk.__component_storages

    if place == entity_count then
        entity_list[place] = nil

        for component_index = 1, component_count do
            local component_storage = component_storages[component_index]
            component_storage[place] = nil
        end
    else
        local last_entity = entity_list[entity_count]
        local last_entity_index = last_entity % 0x100000
        __entity_places[last_entity_index] = place

        entity_list[place] = last_entity
        entity_list[entity_count] = nil

        for component_index = 1, component_count do
            local component_storage = component_storages[component_index]
            local last_component = component_storage[entity_count]
            component_storage[place] = last_component
            component_storage[entity_count] = nil
        end
    end

    chunk.__entity_count = entity_count - 1
end

---@param chunk evolved.chunk
local function __detach_all_entities(chunk)
    local entity_list = chunk.__entity_list

    local component_count = chunk.__component_count
    local component_storages = chunk.__component_storages

    __lua_table_clear(entity_list)

    for component_index = 1, component_count do
        __lua_table_clear(component_storages[component_index])
    end

    chunk.__entity_count = 0
end

---@param entity evolved.entity
---@param components table<evolved.fragment, evolved.component>
local function __spawn_entity(entity, components)
    if __defer_depth <= 0 then
        __error_fmt('spawn entity operations should be deferred')
    end

    local chunk = __chunk_components(components)

    if not chunk then
        return
    end

    local req_fragment_set
    local req_fragment_list
    local req_fragment_count = 0

    local ini_chunk = chunk
    local ini_fragment_set = ini_chunk.__fragment_set

    if chunk.__has_required_fragments then
        ---@type table<evolved.fragment, integer>
        req_fragment_set = __acquire_table(__table_pool_tag.fragment_set)

        ---@type evolved.fragment[]
        req_fragment_list = __acquire_table(__table_pool_tag.fragment_list)

        req_fragment_count = __chunk_required_fragments(ini_chunk,
            req_fragment_set, req_fragment_list, req_fragment_count)

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]
            chunk = __chunk_with_fragment(chunk, req_fragment)
        end
    end

    local chunk_entity_list = chunk.__entity_list
    local chunk_entity_count = chunk.__entity_count

    local chunk_component_indices = chunk.__component_indices
    local chunk_component_storages = chunk.__component_storages

    local place = chunk_entity_count + 1
    chunk.__entity_count = place

    chunk_entity_list[place] = entity

    do
        local entity_index = entity % 0x100000

        __entity_chunks[entity_index] = chunk
        __entity_places[entity_index] = place

        __structural_changes = __structural_changes + 1
    end

    if chunk.__has_setup_hooks then
        for fragment, component in __lua_next, components do
            local component_index = chunk_component_indices[fragment]

            if component_index then
                ---@type evolved.duplicate?
                local fragment_duplicate =
                    __evolved_get(fragment, __DUPLICATE)

                local new_component = component

                if new_component ~= nil and fragment_duplicate then
                    new_component = fragment_duplicate(new_component)
                end

                if new_component == nil then
                    new_component = true
                end

                local component_storage = chunk_component_storages[component_index]

                component_storage[place] = new_component
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                local req_component_index = chunk_component_indices[req_fragment]

                if req_component_index then
                    ---@type evolved.default?, evolved.duplicate?
                    local req_fragment_default, req_fragment_duplicate =
                        __evolved_get(req_fragment, __DEFAULT, __DUPLICATE)

                    local req_component = req_fragment_default

                    if req_component ~= nil and req_fragment_duplicate then
                        req_component = req_fragment_duplicate(req_component)
                    end

                    if req_component == nil then
                        req_component = true
                    end

                    local req_component_storage = chunk_component_storages[req_component_index]

                    req_component_storage[place] = req_component
                end
            end
        end
    else
        for fragment, component in __lua_next, components do
            local component_index = chunk_component_indices[fragment]

            if component_index then
                local new_component = component

                local component_storage = chunk_component_storages[component_index]

                component_storage[place] = new_component
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                local req_component_index = chunk_component_indices[req_fragment]

                if req_component_index then
                    local req_component = true

                    local req_component_storage = chunk_component_storages[req_component_index]

                    req_component_storage[place] = req_component
                end
            end
        end
    end

    if chunk.__has_insert_hooks then
        local chunk_fragment_list = chunk.__fragment_list
        local chunk_fragment_count = chunk.__fragment_count

        for chunk_fragment_index = 1, chunk_fragment_count do
            local fragment = chunk_fragment_list[chunk_fragment_index]

            ---@type evolved.set_hook?, evolved.insert_hook?
            local fragment_on_set, fragment_on_insert =
                __evolved_get(fragment, __ON_SET, __ON_INSERT)

            local component_index = chunk_component_indices[fragment]

            if component_index then
                local component_storage = chunk_component_storages[component_index]

                local new_component = component_storage[place]

                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment, new_component)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment, new_component)
                end
            else
                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment)
                end
            end
        end
    end

    if req_fragment_set then
        __release_table(__table_pool_tag.fragment_set, req_fragment_set)
    end

    if req_fragment_list then
        __release_table(__table_pool_tag.fragment_list, req_fragment_list)
    end
end

---@param entity evolved.entity
---@param prefab evolved.entity
---@param components table<evolved.fragment, evolved.component>
local function __clone_entity(entity, prefab, components)
    if __defer_depth <= 0 then
        __error_fmt('clone entity operations should be deferred')
    end

    local prefab_index = prefab % 0x100000
    local prefab_chunk = __entity_chunks[prefab_index]
    local prefab_place = __entity_places[prefab_index]

    local chunk = __chunk_with_components(
        __chunk_without_unique_fragments(prefab_chunk),
        components)

    if not chunk then
        return
    end

    local req_fragment_set
    local req_fragment_list
    local req_fragment_count = 0

    local ini_chunk = chunk
    local ini_fragment_set = ini_chunk.__fragment_set

    if chunk.__has_required_fragments then
        ---@type table<evolved.fragment, integer>
        req_fragment_set = __acquire_table(__table_pool_tag.fragment_set)

        ---@type evolved.fragment[]
        req_fragment_list = __acquire_table(__table_pool_tag.fragment_list)

        req_fragment_count = __chunk_required_fragments(ini_chunk,
            req_fragment_set, req_fragment_list, req_fragment_count)

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]
            chunk = __chunk_with_fragment(chunk, req_fragment)
        end
    end

    local chunk_entity_list = chunk.__entity_list
    local chunk_entity_count = chunk.__entity_count

    local chunk_component_indices = chunk.__component_indices
    local chunk_component_storages = chunk.__component_storages

    local place = chunk_entity_count + 1
    chunk.__entity_count = place

    chunk_entity_list[place] = entity

    do
        local entity_index = entity % 0x100000

        __entity_chunks[entity_index] = chunk
        __entity_places[entity_index] = place

        __structural_changes = __structural_changes + 1
    end

    if prefab_chunk then
        local prefab_component_count = prefab_chunk.__component_count
        local prefab_component_storages = prefab_chunk.__component_storages
        local prefab_component_fragments = prefab_chunk.__component_fragments

        if prefab_chunk.__has_setup_hooks then
            for prefab_component_index = 1, prefab_component_count do
                local fragment = prefab_component_fragments[prefab_component_index]
                local component_index = chunk_component_indices[fragment]

                if component_index then
                    ---@type evolved.duplicate?
                    local fragment_duplicate =
                        __evolved_get(fragment, __DUPLICATE)

                    local prefab_component_storage = prefab_component_storages[prefab_component_index]
                    local prefab_component = prefab_component_storage[prefab_place]

                    local new_component = prefab_component

                    if new_component ~= nil and fragment_duplicate then
                        new_component = fragment_duplicate(new_component)
                    end

                    if new_component == nil then
                        new_component = true
                    end

                    local component_storage = chunk_component_storages[component_index]

                    component_storage[place] = new_component
                end
            end
        else
            for prefab_component_index = 1, prefab_component_count do
                local fragment = prefab_component_fragments[prefab_component_index]
                local component_index = chunk_component_indices[fragment]

                if component_index then
                    local prefab_component_storage = prefab_component_storages[prefab_component_index]
                    local prefab_component = prefab_component_storage[prefab_place]

                    local new_component = prefab_component

                    if new_component == nil then
                        new_component = true
                    end

                    local component_storage = chunk_component_storages[component_index]

                    component_storage[place] = new_component
                end
            end
        end
    end

    if chunk.__has_setup_hooks then
        for fragment, component in __lua_next, components do
            local component_index = chunk_component_indices[fragment]

            if component_index then
                ---@type evolved.duplicate?
                local fragment_duplicate =
                    __evolved_get(fragment, __DUPLICATE)

                local new_component = component

                if new_component ~= nil and fragment_duplicate then
                    new_component = fragment_duplicate(new_component)
                end

                if new_component == nil then
                    new_component = true
                end

                local component_storage = chunk_component_storages[component_index]

                component_storage[place] = new_component
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                local req_component_index = chunk_component_indices[req_fragment]

                if req_component_index then
                    ---@type evolved.default?, evolved.duplicate?
                    local req_fragment_default, req_fragment_duplicate =
                        __evolved_get(req_fragment, __DEFAULT, __DUPLICATE)

                    local req_component = req_fragment_default

                    if req_component ~= nil and req_fragment_duplicate then
                        req_component = req_fragment_duplicate(req_component)
                    end

                    if req_component == nil then
                        req_component = true
                    end

                    local req_component_storage = chunk_component_storages[req_component_index]

                    req_component_storage[place] = req_component
                end
            end
        end
    else
        for fragment, component in __lua_next, components do
            local component_index = chunk_component_indices[fragment]

            if component_index then
                local new_component = component

                local component_storage = chunk_component_storages[component_index]

                component_storage[place] = new_component
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                local req_component_index = chunk_component_indices[req_fragment]

                if req_component_index then
                    local req_component = true

                    local req_component_storage = chunk_component_storages[req_component_index]

                    req_component_storage[place] = req_component
                end
            end
        end
    end

    if chunk.__has_insert_hooks then
        local chunk_fragment_list = chunk.__fragment_list
        local chunk_fragment_count = chunk.__fragment_count

        for chunk_fragment_index = 1, chunk_fragment_count do
            local fragment = chunk_fragment_list[chunk_fragment_index]

            ---@type evolved.set_hook?, evolved.insert_hook?
            local fragment_on_set, fragment_on_insert =
                __evolved_get(fragment, __ON_SET, __ON_INSERT)

            local component_index = chunk_component_indices[fragment]

            if component_index then
                local component_storage = chunk_component_storages[component_index]

                local new_component = component_storage[place]

                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment, new_component)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment, new_component)
                end
            else
                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment)
                end
            end
        end
    end

    if req_fragment_set then
        __release_table(__table_pool_tag.fragment_set, req_fragment_set)
    end

    if req_fragment_list then
        __release_table(__table_pool_tag.fragment_list, req_fragment_list)
    end
end

---
---
---
---
---

local __chunk_set
local __chunk_remove
local __chunk_clear

---
---
---
---
---

---@param chunk evolved.chunk
local function __purge_chunk(chunk)
    if __defer_depth <= 0 then
        __error_fmt('this operation should be deferred')
    end

    if chunk.__child_count > 0 or chunk.__entity_count > 0 then
        __error_fmt('chunk should be empty before purging')
    end

    local chunk_parent = chunk.__parent
    local chunk_fragment = chunk.__fragment

    local major_chunks = __major_chunks[chunk_fragment]
    local minor_chunks = __minor_chunks[chunk_fragment]

    local with_fragment_edges = chunk.__with_fragment_edges
    local without_fragment_edges = chunk.__without_fragment_edges

    if __root_chunks[chunk_fragment] == chunk then
        __root_chunks[chunk_fragment] = nil
    end

    if major_chunks then
        __assoc_list_remove(major_chunks, chunk)

        if major_chunks.__item_count == 0 then
            __major_chunks[chunk_fragment] = nil
        end
    end

    if minor_chunks then
        __assoc_list_remove(minor_chunks, chunk)

        if minor_chunks.__item_count == 0 then
            __minor_chunks[chunk_fragment] = nil
        end
    end

    if chunk_parent then
        chunk.__parent, chunk_parent.__child_count = nil, __assoc_list_remove_ex(
            chunk_parent.__child_set, chunk_parent.__child_list, chunk_parent.__child_count,
            chunk)
    end

    for with_fragment, with_fragment_edge in __lua_next, with_fragment_edges do
        with_fragment_edges[with_fragment] = nil
        with_fragment_edge.__without_fragment_edges[with_fragment] = nil
    end

    for without_fragment, without_fragment_edge in __lua_next, without_fragment_edges do
        without_fragment_edges[without_fragment] = nil
        without_fragment_edge.__with_fragment_edges[without_fragment] = nil
    end

    chunk.__unreachable_or_collected = true
end

---@param chunk_list evolved.chunk[]
---@param chunk_count integer
local function __clear_chunk_list(chunk_list, chunk_count)
    if __defer_depth <= 0 then
        __error_fmt('this operation should be deferred')
    end

    if chunk_count == 0 then
        return
    end

    for i = 1, chunk_count do
        local chunk = chunk_list[i]
        __chunk_clear(chunk)
    end
end

---@param entity_list evolved.entity[]
---@param entity_count integer
local function __destroy_entity_list(entity_list, entity_count)
    if __defer_depth <= 0 then
        __error_fmt('this operation should be deferred')
    end

    if entity_count == 0 then
        return
    end

    for i = 1, entity_count do
        local entity = entity_list[i]
        local entity_index = entity % 0x100000

        if __freelist_ids[entity_index] ~= entity then
            -- this entity is not alive, nothing to purge
        else
            local chunk = __entity_chunks[entity_index]
            local place = __entity_places[entity_index]

            if chunk and chunk.__has_remove_hooks then
                local chunk_fragment_list = chunk.__fragment_list
                local chunk_fragment_count = chunk.__fragment_count
                local chunk_component_indices = chunk.__component_indices
                local chunk_component_storages = chunk.__component_storages

                for chunk_fragment_index = 1, chunk_fragment_count do
                    local fragment = chunk_fragment_list[chunk_fragment_index]

                    ---@type evolved.remove_hook?
                    local fragment_on_remove = __evolved_get(fragment, __ON_REMOVE)

                    if fragment_on_remove then
                        local component_index = chunk_component_indices[fragment]

                        if component_index then
                            local component_storage = chunk_component_storages[component_index]
                            local old_component = component_storage[place]
                            __defer_call_hook(fragment_on_remove, entity, fragment, old_component)
                        else
                            __defer_call_hook(fragment_on_remove, entity, fragment)
                        end
                    end
                end
            end

            if chunk then
                __detach_entity(chunk, place)

                __entity_chunks[entity_index] = nil
                __entity_places[entity_index] = nil

                __structural_changes = __structural_changes + 1
            end

            __release_id(entity)
        end
    end
end

---@param fragment_list evolved.fragment[]
---@param fragment_count integer
local function __destroy_fragment_list(fragment_list, fragment_count)
    if __defer_depth <= 0 then
        __error_fmt('this operation should be deferred')
    end

    if fragment_count == 0 then
        return
    end

    local processed_fragment_set = __acquire_table(__table_pool_tag.fragment_set)
    local processing_fragment_stack = __acquire_table(__table_pool_tag.fragment_list)
    local processing_fragment_stack_size = 0

    do
        __lua_table_move(
            fragment_list, 1, fragment_count,
            processing_fragment_stack_size + 1, processing_fragment_stack)

        processing_fragment_stack_size = processing_fragment_stack_size + fragment_count
    end

    local releasing_fragment_list = __acquire_table(__table_pool_tag.fragment_list)
    local releasing_fragment_count = 0

    local destroy_entity_policy_fragment_list = __acquire_table(__table_pool_tag.fragment_list)
    local destroy_entity_policy_fragment_count = 0

    local remove_fragment_policy_fragment_list = __acquire_table(__table_pool_tag.fragment_list)
    local remove_fragment_policy_fragment_count = 0

    while processing_fragment_stack_size > 0 do
        local processing_fragment = processing_fragment_stack[processing_fragment_stack_size]

        processing_fragment_stack[processing_fragment_stack_size] = nil
        processing_fragment_stack_size = processing_fragment_stack_size - 1

        if processed_fragment_set[processing_fragment] then
            -- this fragment has already beed processed
        else
            processed_fragment_set[processing_fragment] = true

            releasing_fragment_count = releasing_fragment_count + 1
            releasing_fragment_list[releasing_fragment_count] = processing_fragment

            local processing_fragment_destruction_policy = __evolved_get(processing_fragment, __DESTRUCTION_POLICY)
                or __DESTRUCTION_POLICY_REMOVE_FRAGMENT

            if processing_fragment_destruction_policy == __DESTRUCTION_POLICY_DESTROY_ENTITY then
                destroy_entity_policy_fragment_count = destroy_entity_policy_fragment_count + 1
                destroy_entity_policy_fragment_list[destroy_entity_policy_fragment_count] = processing_fragment

                local minor_chunks = __minor_chunks[processing_fragment]
                local minor_chunk_list = minor_chunks and minor_chunks.__item_list --[=[@as evolved.chunk[]]=]
                local minor_chunk_count = minor_chunks and minor_chunks.__item_count or 0 --[[@as integer]]

                for minor_chunk_index = 1, minor_chunk_count do
                    local minor_chunk = minor_chunk_list[minor_chunk_index]

                    local minor_chunk_entity_list = minor_chunk.__entity_list
                    local minor_chunk_entity_count = minor_chunk.__entity_count

                    __lua_table_move(
                        minor_chunk_entity_list, 1, minor_chunk_entity_count,
                        processing_fragment_stack_size + 1, processing_fragment_stack)

                    processing_fragment_stack_size = processing_fragment_stack_size + minor_chunk_entity_count
                end
            elseif processing_fragment_destruction_policy == __DESTRUCTION_POLICY_REMOVE_FRAGMENT then
                remove_fragment_policy_fragment_count = remove_fragment_policy_fragment_count + 1
                remove_fragment_policy_fragment_list[remove_fragment_policy_fragment_count] = processing_fragment
            else
                __error_fmt('unknown DESTRUCTION_POLICY (%s) on (%s)',
                    __id_name(processing_fragment_destruction_policy), __id_name(processing_fragment))
            end
        end
    end

    __release_table(__table_pool_tag.fragment_set, processed_fragment_set)
    __release_table(__table_pool_tag.fragment_list, processing_fragment_stack, true)

    if destroy_entity_policy_fragment_count > 0 then
        for i = 1, destroy_entity_policy_fragment_count do
            local fragment = destroy_entity_policy_fragment_list[i]

            local minor_chunks = __minor_chunks[fragment]
            local minor_chunk_list = minor_chunks and minor_chunks.__item_list --[=[@as evolved.chunk[]]=]
            local minor_chunk_count = minor_chunks and minor_chunks.__item_count or 0 --[[@as integer]]

            for minor_chunk_index = 1, minor_chunk_count do
                local minor_chunk = minor_chunk_list[minor_chunk_index]
                __chunk_clear(minor_chunk)
            end
        end

        __release_table(__table_pool_tag.fragment_list, destroy_entity_policy_fragment_list)
    else
        __release_table(__table_pool_tag.fragment_list, destroy_entity_policy_fragment_list, true)
    end

    if remove_fragment_policy_fragment_count > 0 then
        for i = 1, remove_fragment_policy_fragment_count do
            local fragment = remove_fragment_policy_fragment_list[i]

            local minor_chunks = __minor_chunks[fragment]
            local minor_chunk_list = minor_chunks and minor_chunks.__item_list --[=[@as evolved.chunk[]]=]
            local minor_chunk_count = minor_chunks and minor_chunks.__item_count or 0 --[[@as integer]]

            for minor_chunk_index = 1, minor_chunk_count do
                local minor_chunk = minor_chunk_list[minor_chunk_index]
                __chunk_remove(minor_chunk, fragment)
            end
        end

        __release_table(__table_pool_tag.fragment_list, remove_fragment_policy_fragment_list)
    else
        __release_table(__table_pool_tag.fragment_list, remove_fragment_policy_fragment_list, true)
    end

    if releasing_fragment_count > 0 then
        __destroy_entity_list(releasing_fragment_list, releasing_fragment_count)
        __release_table(__table_pool_tag.fragment_list, releasing_fragment_list)
    else
        __release_table(__table_pool_tag.fragment_list, releasing_fragment_list, true)
    end
end

---
---
---
---
---

---@param old_chunk evolved.chunk
---@param fragment evolved.fragment
---@param component evolved.component
function __chunk_set(old_chunk, fragment, component)
    if __defer_depth <= 0 then
        __error_fmt('batched chunk operations should be deferred')
    end

    local new_chunk = __chunk_with_fragment(old_chunk, fragment)

    if not new_chunk then
        return
    end

    local old_entity_list = old_chunk.__entity_list
    local old_entity_count = old_chunk.__entity_count

    if old_entity_count == 0 then
        return
    end

    local old_component_count = old_chunk.__component_count
    local old_component_indices = old_chunk.__component_indices
    local old_component_storages = old_chunk.__component_storages
    local old_component_fragments = old_chunk.__component_fragments

    if old_chunk == new_chunk then
        local old_chunk_has_setup_hooks = old_chunk.__has_setup_hooks
        local old_chunk_has_assign_hooks = old_chunk.__has_assign_hooks

        ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.assign_hook?
        local fragment_default, fragment_duplicate, fragment_on_set, fragment_on_assign

        if old_chunk_has_setup_hooks or old_chunk_has_assign_hooks then
            fragment_default, fragment_duplicate, fragment_on_set, fragment_on_assign =
                __evolved_get(fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_ASSIGN)
        end

        if fragment_on_set or fragment_on_assign then
            local old_component_index = old_component_indices[fragment]

            if old_component_index then
                local old_component_storage = old_component_storages[old_component_index]

                if fragment_duplicate then
                    for old_place = 1, old_entity_count do
                        local entity = old_entity_list[old_place]

                        local new_component = component
                        if new_component == nil then new_component = fragment_default end
                        if new_component ~= nil then new_component = fragment_duplicate(new_component) end
                        if new_component == nil then new_component = true end

                        local old_component = old_component_storage[old_place]
                        old_component_storage[old_place] = new_component

                        if fragment_on_set then
                            __defer_call_hook(fragment_on_set, entity, fragment, new_component, old_component)
                        end

                        if fragment_on_assign then
                            __defer_call_hook(fragment_on_assign, entity, fragment, new_component, old_component)
                        end
                    end
                else
                    local new_component = component
                    if new_component == nil then new_component = fragment_default end
                    if new_component == nil then new_component = true end

                    for old_place = 1, old_entity_count do
                        local entity = old_entity_list[old_place]

                        local old_component = old_component_storage[old_place]
                        old_component_storage[old_place] = new_component

                        if fragment_on_set then
                            __defer_call_hook(fragment_on_set, entity, fragment, new_component, old_component)
                        end

                        if fragment_on_assign then
                            __defer_call_hook(fragment_on_assign, entity, fragment, new_component, old_component)
                        end
                    end
                end
            else
                for old_place = 1, old_entity_count do
                    local entity = old_entity_list[old_place]

                    if fragment_on_set then
                        __defer_call_hook(fragment_on_set, entity, fragment)
                    end

                    if fragment_on_assign then
                        __defer_call_hook(fragment_on_assign, entity, fragment)
                    end
                end
            end
        else
            local old_component_index = old_component_indices[fragment]

            if old_component_index then
                local old_component_storage = old_component_storages[old_component_index]

                if fragment_duplicate then
                    for old_place = 1, old_entity_count do
                        local new_component = component
                        if new_component == nil then new_component = fragment_default end
                        if new_component ~= nil then new_component = fragment_duplicate(new_component) end
                        if new_component == nil then new_component = true end
                        old_component_storage[old_place] = new_component
                    end
                else
                    local new_component = component
                    if new_component == nil then new_component = fragment_default end
                    if new_component == nil then new_component = true end
                    for old_place = 1, old_entity_count do
                        old_component_storage[old_place] = new_component
                    end
                end
            else
                -- nothing
            end
        end
    else
        local req_fragment_set
        local req_fragment_list
        local req_fragment_count = 0

        local ini_new_chunk = new_chunk
        local ini_fragment_set = ini_new_chunk.__fragment_set

        if new_chunk.__has_required_fragments then
            ---@type table<evolved.fragment, integer>
            req_fragment_set = __acquire_table(__table_pool_tag.fragment_set)

            ---@type evolved.fragment[]
            req_fragment_list = __acquire_table(__table_pool_tag.fragment_list)

            req_fragment_count = __fragment_required_fragments(fragment,
                req_fragment_set, req_fragment_list, req_fragment_count)

            for i = 1, req_fragment_count do
                local req_fragment = req_fragment_list[i]
                new_chunk = __chunk_with_fragment(new_chunk, req_fragment)
            end
        end

        local new_entity_list = new_chunk.__entity_list
        local new_entity_count = new_chunk.__entity_count

        local new_component_indices = new_chunk.__component_indices
        local new_component_storages = new_chunk.__component_storages

        local new_chunk_has_setup_hooks = new_chunk.__has_setup_hooks
        local new_chunk_has_insert_hooks = new_chunk.__has_insert_hooks

        ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.insert_hook?
        local fragment_default, fragment_duplicate, fragment_on_set, fragment_on_insert

        if new_chunk_has_setup_hooks or new_chunk_has_insert_hooks then
            fragment_default, fragment_duplicate, fragment_on_set, fragment_on_insert =
                __evolved_get(fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_INSERT)
        end

        if new_entity_count == 0 then
            old_chunk.__entity_list, new_chunk.__entity_list =
                new_entity_list, old_entity_list

            old_entity_list, new_entity_list =
                new_entity_list, old_entity_list

            for old_ci = 1, old_component_count do
                local old_f = old_component_fragments[old_ci]
                local new_ci = new_component_indices[old_f]
                old_component_storages[old_ci], new_component_storages[new_ci] =
                    new_component_storages[new_ci], old_component_storages[old_ci]
            end

            new_chunk.__entity_count = old_entity_count
        else
            __lua_table_move(
                old_entity_list, 1, old_entity_count,
                new_entity_count + 1, new_entity_list)

            for old_ci = 1, old_component_count do
                local old_f = old_component_fragments[old_ci]
                local old_cs = old_component_storages[old_ci]
                local new_ci = new_component_indices[old_f]
                local new_cs = new_component_storages[new_ci]
                __lua_table_move(old_cs, 1, old_entity_count, new_entity_count + 1, new_cs)
            end

            new_chunk.__entity_count = new_entity_count + old_entity_count
        end

        do
            local entity_chunks = __entity_chunks
            local entity_places = __entity_places

            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                local entity = new_entity_list[new_place]
                local entity_index = entity % 0x100000
                entity_chunks[entity_index] = new_chunk
                entity_places[entity_index] = new_place
            end

            __detach_all_entities(old_chunk)
        end

        if fragment_on_set or fragment_on_insert then
            local new_component_index = new_component_indices[fragment]

            if new_component_index then
                local new_component_storage = new_component_storages[new_component_index]

                if fragment_duplicate then
                    for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                        local entity = new_entity_list[new_place]

                        local new_component = component
                        if new_component == nil then new_component = fragment_default end
                        if new_component ~= nil then new_component = fragment_duplicate(new_component) end
                        if new_component == nil then new_component = true end

                        new_component_storage[new_place] = new_component

                        if fragment_on_set then
                            __defer_call_hook(fragment_on_set, entity, fragment, new_component)
                        end

                        if fragment_on_insert then
                            __defer_call_hook(fragment_on_insert, entity, fragment, new_component)
                        end
                    end
                else
                    local new_component = component
                    if new_component == nil then new_component = fragment_default end
                    if new_component == nil then new_component = true end

                    for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                        local entity = new_entity_list[new_place]

                        new_component_storage[new_place] = new_component

                        if fragment_on_set then
                            __defer_call_hook(fragment_on_set, entity, fragment, new_component)
                        end

                        if fragment_on_insert then
                            __defer_call_hook(fragment_on_insert, entity, fragment, new_component)
                        end
                    end
                end
            else
                for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                    local entity = new_entity_list[new_place]

                    if fragment_on_set then
                        __defer_call_hook(fragment_on_set, entity, fragment)
                    end

                    if fragment_on_insert then
                        __defer_call_hook(fragment_on_insert, entity, fragment)
                    end
                end
            end
        else
            local new_component_index = new_component_indices[fragment]

            if new_component_index then
                local new_component_storage = new_component_storages[new_component_index]

                if fragment_duplicate then
                    for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                        local new_component = component
                        if new_component == nil then new_component = fragment_default end
                        if new_component ~= nil then new_component = fragment_duplicate(new_component) end
                        if new_component == nil then new_component = true end
                        new_component_storage[new_place] = new_component
                    end
                else
                    local new_component = component
                    if new_component == nil then new_component = fragment_default end
                    if new_component == nil then new_component = true end
                    for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                        new_component_storage[new_place] = new_component
                    end
                end
            else
                -- nothing
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.insert_hook?
                local req_fragment_default, req_fragment_duplicate, req_fragment_on_set, req_fragment_on_insert

                if new_chunk_has_setup_hooks or new_chunk_has_insert_hooks then
                    req_fragment_default, req_fragment_duplicate, req_fragment_on_set, req_fragment_on_insert =
                        __evolved_get(req_fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_INSERT)
                end

                if req_fragment_on_set or req_fragment_on_insert then
                    local req_component_index = new_component_indices[req_fragment]

                    if req_component_index then
                        local req_component_storage = new_component_storages[req_component_index]

                        if req_fragment_duplicate then
                            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                                local entity = new_entity_list[new_place]

                                local req_component = req_fragment_default
                                if req_component ~= nil then req_component = req_fragment_duplicate(req_component) end
                                if req_component == nil then req_component = true end

                                req_component_storage[new_place] = req_component

                                if req_fragment_on_set then
                                    __defer_call_hook(req_fragment_on_set, entity, req_fragment, req_component)
                                end

                                if req_fragment_on_insert then
                                    __defer_call_hook(req_fragment_on_insert, entity, req_fragment, req_component)
                                end
                            end
                        else
                            local req_component = req_fragment_default
                            if req_component == nil then req_component = true end

                            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                                local entity = new_entity_list[new_place]

                                req_component_storage[new_place] = req_component

                                if req_fragment_on_set then
                                    __defer_call_hook(req_fragment_on_set, entity, req_fragment, req_component)
                                end

                                if req_fragment_on_insert then
                                    __defer_call_hook(req_fragment_on_insert, entity, req_fragment, req_component)
                                end
                            end
                        end
                    else
                        for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                            local entity = new_entity_list[new_place]

                            if req_fragment_on_set then
                                __defer_call_hook(req_fragment_on_set, entity, req_fragment)
                            end

                            if req_fragment_on_insert then
                                __defer_call_hook(req_fragment_on_insert, entity, req_fragment)
                            end
                        end
                    end
                else
                    local req_component_index = new_component_indices[req_fragment]

                    if req_component_index then
                        local req_component_storage = new_component_storages[req_component_index]

                        if req_fragment_duplicate then
                            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                                local req_component = req_fragment_default
                                if req_component ~= nil then req_component = req_fragment_duplicate(req_component) end
                                if req_component == nil then req_component = true end
                                req_component_storage[new_place] = req_component
                            end
                        else
                            local req_component = req_fragment_default
                            if req_component == nil then req_component = true end
                            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                                req_component_storage[new_place] = req_component
                            end
                        end
                    else
                        -- nothing
                    end
                end
            end
        end

        if req_fragment_set then
            __release_table(__table_pool_tag.fragment_set, req_fragment_set)
        end

        if req_fragment_list then
            __release_table(__table_pool_tag.fragment_list, req_fragment_list)
        end

        __structural_changes = __structural_changes + 1
    end
end

---@param old_chunk evolved.chunk
---@param ... evolved.fragment fragments
function __chunk_remove(old_chunk, ...)
    if __defer_depth <= 0 then
        __error_fmt('batched chunk operations should be deferred')
    end

    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return
    end

    local new_chunk = __chunk_without_fragments(old_chunk, ...)

    if old_chunk == new_chunk then
        return
    end

    local old_entity_list = old_chunk.__entity_list
    local old_entity_count = old_chunk.__entity_count

    if old_entity_count == 0 then
        return
    end

    local old_fragment_list = old_chunk.__fragment_list
    local old_fragment_count = old_chunk.__fragment_count
    local old_component_indices = old_chunk.__component_indices
    local old_component_storages = old_chunk.__component_storages

    if old_chunk.__has_remove_hooks then
        ---@type table<evolved.fragment, integer>
        local new_fragment_set = new_chunk and new_chunk.__fragment_set
            or __safe_tbls.__EMPTY_FRAGMENT_SET

        for i = 1, old_fragment_count do
            local fragment = old_fragment_list[i]

            if not new_fragment_set[fragment] then
                ---@type evolved.remove_hook?
                local fragment_on_remove = __evolved_get(fragment, __ON_REMOVE)

                if fragment_on_remove then
                    local old_component_index = old_component_indices[fragment]

                    if old_component_index then
                        local old_component_storage = old_component_storages[old_component_index]

                        for old_place = 1, old_entity_count do
                            local entity = old_entity_list[old_place]
                            local old_component = old_component_storage[old_place]
                            __defer_call_hook(fragment_on_remove, entity, fragment, old_component)
                        end
                    else
                        for old_place = 1, old_entity_count do
                            local entity = old_entity_list[old_place]
                            __defer_call_hook(fragment_on_remove, entity, fragment)
                        end
                    end
                end
            end
        end
    end

    if new_chunk then
        local new_entity_list = new_chunk.__entity_list
        local new_entity_count = new_chunk.__entity_count

        local new_component_count = new_chunk.__component_count
        local new_component_storages = new_chunk.__component_storages
        local new_component_fragments = new_chunk.__component_fragments

        if new_entity_count == 0 then
            old_chunk.__entity_list, new_chunk.__entity_list =
                new_entity_list, old_entity_list

            old_entity_list, new_entity_list =
                new_entity_list, old_entity_list

            for new_ci = 1, new_component_count do
                local new_f = new_component_fragments[new_ci]
                local old_ci = old_component_indices[new_f]
                old_component_storages[old_ci], new_component_storages[new_ci] =
                    new_component_storages[new_ci], old_component_storages[old_ci]
            end

            new_chunk.__entity_count = old_entity_count
        else
            __lua_table_move(
                old_entity_list, 1, old_entity_count,
                new_entity_count + 1, new_entity_list)

            for new_ci = 1, new_component_count do
                local new_f = new_component_fragments[new_ci]
                local new_cs = new_component_storages[new_ci]
                local old_ci = old_component_indices[new_f]
                local old_cs = old_component_storages[old_ci]
                __lua_table_move(old_cs, 1, old_entity_count, new_entity_count + 1, new_cs)
            end

            new_chunk.__entity_count = new_entity_count + old_entity_count
        end

        do
            local entity_chunks = __entity_chunks
            local entity_places = __entity_places

            for new_place = new_entity_count + 1, new_entity_count + old_entity_count do
                local entity = new_entity_list[new_place]
                local entity_index = entity % 0x100000
                entity_chunks[entity_index] = new_chunk
                entity_places[entity_index] = new_place
            end

            __detach_all_entities(old_chunk)
        end
    else
        local entity_chunks = __entity_chunks
        local entity_places = __entity_places

        for old_place = 1, old_entity_count do
            local entity = old_entity_list[old_place]
            local entity_index = entity % 0x100000
            entity_chunks[entity_index] = nil
            entity_places[entity_index] = nil
        end

        __detach_all_entities(old_chunk)
    end

    __structural_changes = __structural_changes + 1
end

---@param chunk evolved.chunk
function __chunk_clear(chunk)
    if __defer_depth <= 0 then
        __error_fmt('batched chunk operations should be deferred')
    end

    local chunk_entity_list = chunk.__entity_list
    local chunk_entity_count = chunk.__entity_count

    if chunk_entity_count == 0 then
        return
    end

    if chunk.__has_remove_hooks then
        local chunk_fragment_list = chunk.__fragment_list
        local chunk_fragment_count = chunk.__fragment_count
        local chunk_component_indices = chunk.__component_indices
        local chunk_component_storages = chunk.__component_storages

        for chunk_fragment_index = 1, chunk_fragment_count do
            local fragment = chunk_fragment_list[chunk_fragment_index]

            ---@type evolved.remove_hook?
            local fragment_on_remove = __evolved_get(fragment, __ON_REMOVE)

            if fragment_on_remove then
                local component_index = chunk_component_indices[fragment]

                if component_index then
                    local component_storage = chunk_component_storages[component_index]

                    for place = 1, chunk_entity_count do
                        local entity = chunk_entity_list[place]
                        local old_component = component_storage[place]
                        __defer_call_hook(fragment_on_remove, entity, fragment, old_component)
                    end
                else
                    for place = 1, chunk_entity_count do
                        local entity = chunk_entity_list[place]
                        __defer_call_hook(fragment_on_remove, entity, fragment)
                    end
                end
            end
        end
    end

    do
        local entity_chunks = __entity_chunks
        local entity_places = __entity_places

        for place = 1, chunk_entity_count do
            local entity = chunk_entity_list[place]
            local entity_index = entity % 0x100000
            entity_chunks[entity_index] = nil
            entity_places[entity_index] = nil
        end

        __detach_all_entities(chunk)
    end

    __structural_changes = __structural_changes + 1
end

---
---
---
---
---

---@param system evolved.system
local function __system_process(system)
    ---@type evolved.query?, evolved.execute?, evolved.prologue?, evolved.epilogue?
    local query, execute, prologue, epilogue = __evolved_get(system,
        __QUERY, __EXECUTE, __PROLOGUE, __EPILOGUE)

    if prologue then
        local success, result = __lua_pcall(prologue)

        if not success then
            __error_fmt('system prologue failed: %s', result)
        end
    end

    if execute then
        __evolved_defer()
        for chunk, entity_list, entity_count in __evolved_execute(query or system) do
            local success, result = __lua_pcall(execute, chunk, entity_list, entity_count)

            if not success then
                __evolved_commit()
                __error_fmt('system execution failed: %s', result)
            end
        end
        __evolved_commit()
    end

    do
        local group_subsystems = __group_subsystems[system]
        local group_subsystem_list = group_subsystems and group_subsystems.__item_list --[=[@as evolved.system[]]=]
        local group_subsystem_count = group_subsystems and group_subsystems.__item_count or 0 --[[@as integer]]

        if group_subsystem_count > 0 then
            local subsystem_list = __acquire_table(__table_pool_tag.system_list)

            __lua_table_move(
                group_subsystem_list, 1, group_subsystem_count,
                1, subsystem_list)

            for subsystem_index = 1, group_subsystem_count do
                local subsystem = subsystem_list[subsystem_index]
                if not __evolved_has(subsystem, __DISABLED) then
                    __system_process(subsystem)
                end
            end

            __release_table(__table_pool_tag.system_list, subsystem_list)
        end
    end

    if epilogue then
        local success, result = __lua_pcall(epilogue)

        if not success then
            __error_fmt('system epilogue failed: %s', result)
        end
    end
end

---
---
---
---
---

---@enum evolved.defer_op
local __defer_op = {
    set = 1,
    remove = 2,
    clear = 3,
    destroy = 4,

    batch_set = 5,
    batch_remove = 6,
    batch_clear = 7,
    batch_destroy = 8,

    spawn_entity = 9,
    clone_entity = 10,

    call_hook = 11,

    __count = 11,
}

---@type table<evolved.defer_op, fun(bytes: any[], index: integer): integer>
local __defer_ops = __lua_table_new(__defer_op.__count, 0)

---@param entity evolved.entity
---@param fragment evolved.fragment
---@param component evolved.component
function __defer_set(entity, fragment, component)
    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.set
    bytecode[length + 2] = entity
    bytecode[length + 3] = fragment
    bytecode[length + 4] = component

    __defer_length = length + 4
end

__defer_ops[__defer_op.set] = function(bytes, index)
    local entity = bytes[index + 0]
    local fragment = bytes[index + 1]
    local component = bytes[index + 2]

    __evolved_set(entity, fragment, component)

    return 3
end

---@param entity evolved.entity
---@param ... evolved.fragment fragments
function __defer_remove(entity, ...)
    local fragment_count = __lua_select('#', ...)
    if fragment_count == 0 then return end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.remove
    bytecode[length + 2] = entity
    bytecode[length + 3] = fragment_count

    if fragment_count == 0 then
        -- nothing
    elseif fragment_count == 1 then
        local f1 = ...
        bytecode[length + 4] = f1
    elseif fragment_count == 2 then
        local f1, f2 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
    elseif fragment_count == 3 then
        local f1, f2, f3 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
    elseif fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
        bytecode[length + 7] = f4
    else
        local f1, f2, f3, f4 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
        bytecode[length + 7] = f4
        for i = 5, fragment_count do
            bytecode[length + 3 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 3 + fragment_count
end

__defer_ops[__defer_op.remove] = function(bytes, index)
    local entity = bytes[index + 0]
    local fragment_count = bytes[index + 1]

    if fragment_count == 0 then
        -- nothing
    elseif fragment_count == 1 then
        local f1 = bytes[index + 2]
        __evolved_remove(entity, f1)
    elseif fragment_count == 2 then
        local f1, f2 = bytes[index + 2], bytes[index + 3]
        __evolved_remove(entity, f1, f2)
    elseif fragment_count == 3 then
        local f1, f2, f3 = bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_remove(entity, f1, f2, f3)
    elseif fragment_count == 4 then
        local f1, f2, f3, f4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        __evolved_remove(entity, f1, f2, f3, f4)
    else
        local f1, f2, f3, f4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        __evolved_remove(entity, f1, f2, f3, f4,
            __lua_table_unpack(bytes, index + 6, index + 1 + fragment_count))
    end

    return 2 + fragment_count
end

---@param ... evolved.entity entities
function __defer_clear(...)
    local entity_count = __lua_select('#', ...)
    if entity_count == 0 then return end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.clear
    bytecode[length + 2] = entity_count

    if entity_count == 0 then
        -- nothing
    elseif entity_count == 1 then
        local e1 = ...
        bytecode[length + 3] = e1
    elseif entity_count == 2 then
        local e1, e2 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
    elseif entity_count == 3 then
        local e1, e2, e3 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
    elseif entity_count == 4 then
        local e1, e2, e3, e4 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
        bytecode[length + 6] = e4
    else
        local e1, e2, e3, e4 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
        bytecode[length + 6] = e4
        for i = 5, entity_count do
            bytecode[length + 2 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 2 + entity_count
end

__defer_ops[__defer_op.clear] = function(bytes, index)
    local entity_count = bytes[index + 0]

    if entity_count == 0 then
        -- nothing
    elseif entity_count == 1 then
        local e1 = bytes[index + 1]
        __evolved_clear(e1)
    elseif entity_count == 2 then
        local e1, e2 = bytes[index + 1], bytes[index + 2]
        __evolved_clear(e1, e2)
    elseif entity_count == 3 then
        local e1, e2, e3 = bytes[index + 1], bytes[index + 2], bytes[index + 3]
        __evolved_clear(e1, e2, e3)
    elseif entity_count == 4 then
        local e1, e2, e3, e4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_clear(e1, e2, e3, e4)
    else
        local e1, e2, e3, e4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_clear(e1, e2, e3, e4,
            __lua_table_unpack(bytes, index + 5, index + 0 + entity_count))
    end

    return 1 + entity_count
end

---@param ... evolved.entity entities
function __defer_destroy(...)
    local entity_count = __lua_select('#', ...)
    if entity_count == 0 then return end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.destroy
    bytecode[length + 2] = entity_count

    if entity_count == 0 then
        -- nothing
    elseif entity_count == 1 then
        local e1 = ...
        bytecode[length + 3] = e1
    elseif entity_count == 2 then
        local e1, e2 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
    elseif entity_count == 3 then
        local e1, e2, e3 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
    elseif entity_count == 4 then
        local e1, e2, e3, e4 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
        bytecode[length + 6] = e4
    else
        local e1, e2, e3, e4 = ...
        bytecode[length + 3] = e1
        bytecode[length + 4] = e2
        bytecode[length + 5] = e3
        bytecode[length + 6] = e4
        for i = 5, entity_count do
            bytecode[length + 2 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 2 + entity_count
end

__defer_ops[__defer_op.destroy] = function(bytes, index)
    local entity_count = bytes[index + 0]

    if entity_count == 0 then
        -- nothing
    elseif entity_count == 1 then
        local e1 = bytes[index + 1]
        __evolved_destroy(e1)
    elseif entity_count == 2 then
        local e1, e2 = bytes[index + 1], bytes[index + 2]
        __evolved_destroy(e1, e2)
    elseif entity_count == 3 then
        local e1, e2, e3 = bytes[index + 1], bytes[index + 2], bytes[index + 3]
        __evolved_destroy(e1, e2, e3)
    elseif entity_count == 4 then
        local e1, e2, e3, e4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_destroy(e1, e2, e3, e4)
    else
        local e1, e2, e3, e4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_destroy(e1, e2, e3, e4,
            __lua_table_unpack(bytes, index + 5, index + 0 + entity_count))
    end

    return 1 + entity_count
end

---@param query evolved.query
---@param fragment evolved.fragment
---@param component evolved.component
function __defer_batch_set(query, fragment, component)
    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.batch_set
    bytecode[length + 2] = query
    bytecode[length + 3] = fragment
    bytecode[length + 4] = component

    __defer_length = length + 4
end

__defer_ops[__defer_op.batch_set] = function(bytes, index)
    local query = bytes[index + 0]
    local fragment = bytes[index + 1]
    local component = bytes[index + 2]

    __evolved_batch_set(query, fragment, component)

    return 3
end

---@param query evolved.query
---@param ... evolved.fragment fragments
function __defer_batch_remove(query, ...)
    local length = __defer_length
    local bytecode = __defer_bytecode

    local fragment_count = __lua_select('#', ...)

    bytecode[length + 1] = __defer_op.batch_remove
    bytecode[length + 2] = query
    bytecode[length + 3] = fragment_count

    if fragment_count == 0 then
        -- nothing
    elseif fragment_count == 1 then
        local f1 = ...
        bytecode[length + 4] = f1
    elseif fragment_count == 2 then
        local f1, f2 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
    elseif fragment_count == 3 then
        local f1, f2, f3 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
    elseif fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
        bytecode[length + 7] = f4
    else
        local f1, f2, f3, f4 = ...
        bytecode[length + 4] = f1
        bytecode[length + 5] = f2
        bytecode[length + 6] = f3
        bytecode[length + 7] = f4
        for i = 5, fragment_count do
            bytecode[length + 3 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 3 + fragment_count
end

__defer_ops[__defer_op.batch_remove] = function(bytes, index)
    local query = bytes[index + 0]
    local fragment_count = bytes[index + 1]

    if fragment_count == 0 then
        -- nothing
    elseif fragment_count == 1 then
        local f1 = bytes[index + 2]
        __evolved_batch_remove(query, f1)
    elseif fragment_count == 2 then
        local f1, f2 = bytes[index + 2], bytes[index + 3]
        __evolved_batch_remove(query, f1, f2)
    elseif fragment_count == 3 then
        local f1, f2, f3 = bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_batch_remove(query, f1, f2, f3)
    elseif fragment_count == 4 then
        local f1, f2, f3, f4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        __evolved_batch_remove(query, f1, f2, f3, f4)
    else
        local f1, f2, f3, f4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        __evolved_batch_remove(query, f1, f2, f3, f4,
            __lua_table_unpack(bytes, index + 6, index + 1 + fragment_count))
    end

    return 2 + fragment_count
end

---@param ... evolved.query chunks_or_queries
function __defer_batch_clear(...)
    local argument_count = __lua_select('#', ...)
    if argument_count == 0 then return end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.batch_clear
    bytecode[length + 2] = argument_count

    if argument_count == 0 then
        -- nothing
    elseif argument_count == 1 then
        local a1 = ...
        bytecode[length + 3] = a1
    elseif argument_count == 2 then
        local a1, a2 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
    elseif argument_count == 3 then
        local a1, a2, a3 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
        bytecode[length + 6] = a4
    else
        local a1, a2, a3, a4 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
        bytecode[length + 6] = a4
        for i = 5, argument_count do
            bytecode[length + 2 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 2 + argument_count
end

__defer_ops[__defer_op.batch_clear] = function(bytes, index)
    local argument_count = bytes[index + 0]

    if argument_count == 0 then
        -- nothing
    elseif argument_count == 1 then
        local a1 = bytes[index + 1]
        __evolved_batch_clear(a1)
    elseif argument_count == 2 then
        local a1, a2 = bytes[index + 1], bytes[index + 2]
        __evolved_batch_clear(a1, a2)
    elseif argument_count == 3 then
        local a1, a2, a3 = bytes[index + 1], bytes[index + 2], bytes[index + 3]
        __evolved_batch_clear(a1, a2, a3)
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_batch_clear(a1, a2, a3, a4)
    else
        local a1, a2, a3, a4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_batch_clear(a1, a2, a3, a4,
            __lua_table_unpack(bytes, index + 5, index + 0 + argument_count))
    end

    return 1 + argument_count
end

---@param ... evolved.query chunks_or_queries
function __defer_batch_destroy(...)
    local argument_count = __lua_select('#', ...)
    if argument_count == 0 then return end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.batch_destroy
    bytecode[length + 2] = argument_count

    if argument_count == 0 then
        -- nothing
    elseif argument_count == 1 then
        local a1 = ...
        bytecode[length + 3] = a1
    elseif argument_count == 2 then
        local a1, a2 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
    elseif argument_count == 3 then
        local a1, a2, a3 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
        bytecode[length + 6] = a4
    else
        local a1, a2, a3, a4 = ...
        bytecode[length + 3] = a1
        bytecode[length + 4] = a2
        bytecode[length + 5] = a3
        bytecode[length + 6] = a4
        for i = 5, argument_count do
            bytecode[length + 2 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 2 + argument_count
end

__defer_ops[__defer_op.batch_destroy] = function(bytes, index)
    local argument_count = bytes[index + 0]

    if argument_count == 0 then
        -- nothing
    elseif argument_count == 1 then
        local a1 = bytes[index + 1]
        __evolved_batch_destroy(a1)
    elseif argument_count == 2 then
        local a1, a2 = bytes[index + 1], bytes[index + 2]
        __evolved_batch_destroy(a1, a2)
    elseif argument_count == 3 then
        local a1, a2, a3 = bytes[index + 1], bytes[index + 2], bytes[index + 3]
        __evolved_batch_destroy(a1, a2, a3)
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_batch_destroy(a1, a2, a3, a4)
    else
        local a1, a2, a3, a4 = bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]
        __evolved_batch_destroy(a1, a2, a3, a4,
            __lua_table_unpack(bytes, index + 5, index + 0 + argument_count))
    end

    return 1 + argument_count
end

---@param entity evolved.entity
---@param components table<evolved.fragment, evolved.component>
function __defer_spawn_entity(entity, components)
    ---@type table<evolved.fragment, evolved.component>
    local component_map = __acquire_table(__table_pool_tag.component_map)

    for fragment, component in __lua_next, components do
        component_map[fragment] = component
    end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.spawn_entity
    bytecode[length + 2] = entity
    bytecode[length + 3] = component_map

    __defer_length = length + 3
end

__defer_ops[__defer_op.spawn_entity] = function(bytes, index)
    local entity = bytes[index + 0]
    local component_map = bytes[index + 1]

    if __debug_mode then
        __debug_fns.validate_entity(entity)
        __debug_fns.validate_component_map(component_map)
    end

    __evolved_defer()
    do
        __spawn_entity(entity, component_map)
        __release_table(__table_pool_tag.component_map, component_map)
    end
    __evolved_commit()

    return 2
end

---@param entity evolved.entity
---@param prefab evolved.entity
---@param components table<evolved.fragment, evolved.component>
function __defer_clone_entity(entity, prefab, components)
    ---@type table<evolved.fragment, evolved.component>
    local component_map = __acquire_table(__table_pool_tag.component_map)

    for fragment, component in __lua_next, components do
        component_map[fragment] = component
    end

    local length = __defer_length
    local bytecode = __defer_bytecode

    bytecode[length + 1] = __defer_op.clone_entity
    bytecode[length + 2] = entity
    bytecode[length + 3] = prefab
    bytecode[length + 4] = component_map

    __defer_length = length + 4
end

__defer_ops[__defer_op.clone_entity] = function(bytes, index)
    local entity = bytes[index + 0]
    local prefab = bytes[index + 1]
    local component_map = bytes[index + 2]

    if __debug_mode then
        __debug_fns.validate_entity(entity)
        __debug_fns.validate_prefab(prefab)
        __debug_fns.validate_component_map(component_map)
    end

    __evolved_defer()
    do
        __clone_entity(entity, prefab, component_map)
        __release_table(__table_pool_tag.component_map, component_map)
    end
    __evolved_commit()

    return 3
end

---@param hook fun(...)
---@param ... any hook arguments
function __defer_call_hook(hook, ...)
    local length = __defer_length
    local bytecode = __defer_bytecode

    local argument_count = __lua_select('#', ...)

    bytecode[length + 1] = __defer_op.call_hook
    bytecode[length + 2] = hook
    bytecode[length + 3] = argument_count

    if argument_count == 0 then
        -- nothing
    elseif argument_count == 1 then
        local a1 = ...
        bytecode[length + 4] = a1
    elseif argument_count == 2 then
        local a1, a2 = ...
        bytecode[length + 4] = a1
        bytecode[length + 5] = a2
    elseif argument_count == 3 then
        local a1, a2, a3 = ...
        bytecode[length + 4] = a1
        bytecode[length + 5] = a2
        bytecode[length + 6] = a3
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = ...
        bytecode[length + 4] = a1
        bytecode[length + 5] = a2
        bytecode[length + 6] = a3
        bytecode[length + 7] = a4
    else
        local a1, a2, a3, a4 = ...
        bytecode[length + 4] = a1
        bytecode[length + 5] = a2
        bytecode[length + 6] = a3
        bytecode[length + 7] = a4
        for i = 5, argument_count do
            bytecode[length + 3 + i] = __lua_select(i, ...)
        end
    end

    __defer_length = length + 3 + argument_count
end

__defer_ops[__defer_op.call_hook] = function(bytes, index)
    local hook = bytes[index + 0]
    local argument_count = bytes[index + 1]

    if argument_count == 0 then
        hook()
    elseif argument_count == 1 then
        local a1 = bytes[index + 2]
        hook(a1)
    elseif argument_count == 2 then
        local a1, a2 = bytes[index + 2], bytes[index + 3]
        hook(a1, a2)
    elseif argument_count == 3 then
        local a1, a2, a3 = bytes[index + 2], bytes[index + 3], bytes[index + 4]
        hook(a1, a2, a3)
    elseif argument_count == 4 then
        local a1, a2, a3, a4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        hook(a1, a2, a3, a4)
    else
        local a1, a2, a3, a4 = bytes[index + 2], bytes[index + 3], bytes[index + 4], bytes[index + 5]
        hook(a1, a2, a3, a4,
            __lua_table_unpack(bytes, index + 6, index + 1 + argument_count))
    end

    return 2 + argument_count
end

---
---
---
---
---

---@param count? integer
---@return evolved.id ... ids
---@nodiscard
function __evolved_id(count)
    count = count or 1

    if count <= 0 then
        return
    end

    if count == 1 then
        return __acquire_id()
    end

    if count == 2 then
        return __acquire_id(), __acquire_id()
    end

    if count == 3 then
        return __acquire_id(), __acquire_id(), __acquire_id()
    end

    if count == 4 then
        return __acquire_id(), __acquire_id(), __acquire_id(), __acquire_id()
    end

    do
        return __acquire_id(), __acquire_id(), __acquire_id(), __acquire_id(),
            __evolved_id(count - 4)
    end
end

---@param index integer
---@param version integer
---@return evolved.id id
---@nodiscard
function __evolved_pack(index, version)
    if index < 1 or index > 0xFFFFF then
        __error_fmt('id index out of range [1;0xFFFFF]')
    end

    if version < 1 or version > 0xFFFFF then
        __error_fmt('id version out of range [1;0xFFFFF]')
    end

    local shifted_version = version * 0x100000
    return index + shifted_version --[[@as evolved.id]]
end

---@param id evolved.id
---@return integer index
---@return integer version
---@nodiscard
function __evolved_unpack(id)
    local index = id % 0x100000
    local version = (id - index) / 0x100000
    return index, version
end

---@return boolean started
function __evolved_defer()
    __defer_depth = __defer_depth + 1
    return __defer_depth == 1
end

---@return boolean committed
function __evolved_commit()
    if __defer_depth <= 0 then
        __error_fmt('unbalanced defer/commit')
    end

    __defer_depth = __defer_depth - 1

    if __defer_depth > 0 then
        return false
    end

    if __defer_length == 0 then
        return true
    end

    local length = __defer_length
    local bytecode = __defer_bytecode

    __defer_length = 0
    __defer_bytecode = __acquire_table(__table_pool_tag.bytecode)

    local bytecode_index = 1
    while bytecode_index <= length do
        local op = __defer_ops[bytecode[bytecode_index]]
        bytecode_index = bytecode_index + op(bytecode, bytecode_index + 1) + 1
    end

    __release_table(__table_pool_tag.bytecode, bytecode, true)
    return true
end

---@param components? table<evolved.fragment, evolved.component>
---@return evolved.entity
function __evolved_spawn(components)
    if not components then
        components = __safe_tbls.__EMPTY_COMPONENT_MAP
    end

    if __debug_mode then
        __debug_fns.validate_component_map(components)
    end

    local entity = __acquire_id()

    if __defer_depth > 0 then
        __defer_spawn_entity(entity, components)
    else
        __evolved_defer()
        do
            __spawn_entity(entity, components)
        end
        __evolved_commit()
    end

    return entity
end

---@param prefab evolved.entity
---@param components? table<evolved.fragment, evolved.component>
---@return evolved.entity
function __evolved_clone(prefab, components)
    if not components then
        components = __safe_tbls.__EMPTY_COMPONENT_MAP
    end

    if __debug_mode then
        __debug_fns.validate_prefab(prefab)
        __debug_fns.validate_component_map(components)
    end

    local entity = __acquire_id()

    if __defer_depth > 0 then
        __defer_clone_entity(entity, prefab, components)
    else
        __evolved_defer()
        do
            __clone_entity(entity, prefab, components)
        end
        __evolved_commit()
    end

    return entity
end

---@param entity evolved.entity
---@return boolean
---@nodiscard
function __evolved_alive(entity)
    local entity_index = entity % 0x100000
    return __freelist_ids[entity_index] == entity
end

---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function __evolved_alive_all(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return true
    end

    local freelist_ids = __freelist_ids

    for argument_index = 1, argument_count do
        ---@type evolved.entity
        local entity = __lua_select(argument_index, ...)
        local entity_index = entity % 0x100000
        if freelist_ids[entity_index] ~= entity then
            return false
        end
    end

    return true
end

---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function __evolved_alive_any(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return false
    end

    local freelist_ids = __freelist_ids

    for argument_index = 1, argument_count do
        ---@type evolved.entity
        local entity = __lua_select(argument_index, ...)
        local entity_index = entity % 0x100000
        if freelist_ids[entity_index] == entity then
            return true
        end
    end

    return false
end

---@param entity evolved.entity
---@return boolean
---@nodiscard
function __evolved_empty(entity)
    local entity_index = entity % 0x100000
    return __freelist_ids[entity_index] ~= entity or not __entity_chunks[entity_index]
end

---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function __evolved_empty_all(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return true
    end

    local freelist_ids = __freelist_ids

    for argument_index = 1, argument_count do
        ---@type evolved.entity
        local entity = __lua_select(argument_index, ...)
        local entity_index = entity % 0x100000
        if freelist_ids[entity_index] == entity and __entity_chunks[entity_index] then
            return false
        end
    end

    return true
end

---@param ... evolved.entity entities
---@return boolean
---@nodiscard
function __evolved_empty_any(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return false
    end

    local freelist_ids = __freelist_ids

    for argument_index = 1, argument_count do
        ---@type evolved.entity
        local entity = __lua_select(argument_index, ...)
        local entity_index = entity % 0x100000
        if freelist_ids[entity_index] ~= entity or not __entity_chunks[entity_index] then
            return true
        end
    end

    return false
end

---@param entity evolved.entity
---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function __evolved_has(entity, fragment)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        return false
    end

    local chunk = __entity_chunks[entity_index]

    if not chunk then
        return false
    end

    return __chunk_has_fragment(chunk, fragment)
end

---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __evolved_has_all(entity, ...)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        return __lua_select('#', ...) == 0
    end

    local chunk = __entity_chunks[entity_index]

    if not chunk then
        return __lua_select('#', ...) == 0
    end

    return __chunk_has_all_fragments(chunk, ...)
end

---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __evolved_has_any(entity, ...)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        return false
    end

    local chunk = __entity_chunks[entity_index]

    if not chunk then
        return false
    end

    return __chunk_has_any_fragments(chunk, ...)
end

---@param entity evolved.entity
---@param ... evolved.fragment fragments
---@return evolved.component ... components
---@nodiscard
function __evolved_get(entity, ...)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        return
    end

    local chunk = __entity_chunks[entity_index]

    if not chunk then
        return
    end

    local place = __entity_places[entity_index]
    return __chunk_get_components(chunk, place, ...)
end


---@param entity evolved.entity
---@param fragment evolved.fragment
---@param component evolved.component
function __evolved_set(entity, fragment, component)
    if __debug_mode then
        __debug_fns.validate_entity(entity)
        __debug_fns.validate_fragment(fragment)
    end

    if __defer_depth > 0 then
        __defer_set(entity, fragment, component)
        return
    end

    local entity_index = entity % 0x100000

    local entity_chunks = __entity_chunks
    local entity_places = __entity_places

    local old_chunk = entity_chunks[entity_index]
    local old_place = entity_places[entity_index]

    local new_chunk = __chunk_with_fragment(old_chunk, fragment)

    if not new_chunk then
        return
    end

    __evolved_defer()

    if old_chunk == new_chunk then
        local old_component_indices = old_chunk.__component_indices
        local old_component_storages = old_chunk.__component_storages

        local old_chunk_has_setup_hooks = old_chunk.__has_setup_hooks
        local old_chunk_has_assign_hooks = old_chunk.__has_assign_hooks

        ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.assign_hook?
        local fragment_default, fragment_duplicate, fragment_on_set, fragment_on_assign

        if old_chunk_has_setup_hooks or old_chunk_has_assign_hooks then
            fragment_default, fragment_duplicate, fragment_on_set, fragment_on_assign =
                __evolved_get(fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_ASSIGN)
        end

        local old_component_index = old_component_indices[fragment]

        if old_component_index then
            local old_component_storage = old_component_storages[old_component_index]

            local new_component = component
            if new_component == nil then new_component = fragment_default end
            if new_component ~= nil and fragment_duplicate then new_component = fragment_duplicate(new_component) end
            if new_component == nil then new_component = true end

            local old_component = old_component_storage[old_place]
            old_component_storage[old_place] = new_component

            if fragment_on_set then
                __defer_call_hook(fragment_on_set, entity, fragment, new_component, old_component)
            end

            if fragment_on_assign then
                __defer_call_hook(fragment_on_assign, entity, fragment, new_component, old_component)
            end
        else
            if fragment_on_set then
                __defer_call_hook(fragment_on_set, entity, fragment)
            end

            if fragment_on_assign then
                __defer_call_hook(fragment_on_assign, entity, fragment)
            end
        end
    else
        local req_fragment_set
        local req_fragment_list
        local req_fragment_count = 0

        local ini_new_chunk = new_chunk
        local ini_fragment_set = ini_new_chunk.__fragment_set

        if new_chunk.__has_required_fragments then
            ---@type table<evolved.fragment, integer>
            req_fragment_set = __acquire_table(__table_pool_tag.fragment_set)

            ---@type evolved.fragment[]
            req_fragment_list = __acquire_table(__table_pool_tag.fragment_list)

            req_fragment_count = __fragment_required_fragments(fragment,
                req_fragment_set, req_fragment_list, req_fragment_count)

            for i = 1, req_fragment_count do
                local req_fragment = req_fragment_list[i]
                new_chunk = __chunk_with_fragment(new_chunk, req_fragment)
            end
        end

        local new_entity_list = new_chunk.__entity_list
        local new_entity_count = new_chunk.__entity_count

        local new_component_indices = new_chunk.__component_indices
        local new_component_storages = new_chunk.__component_storages

        local new_chunk_has_setup_hooks = new_chunk.__has_setup_hooks
        local new_chunk_has_insert_hooks = new_chunk.__has_insert_hooks

        ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.insert_hook?
        local fragment_default, fragment_duplicate, fragment_on_set, fragment_on_insert

        if new_chunk_has_setup_hooks or new_chunk_has_insert_hooks then
            fragment_default, fragment_duplicate, fragment_on_set, fragment_on_insert =
                __evolved_get(fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_INSERT)
        end

        local new_place = new_entity_count + 1
        new_chunk.__entity_count = new_place

        new_entity_list[new_place] = entity

        if old_chunk then
            local old_component_count = old_chunk.__component_count
            local old_component_storages = old_chunk.__component_storages
            local old_component_fragments = old_chunk.__component_fragments

            for old_ci = 1, old_component_count do
                local old_f = old_component_fragments[old_ci]
                local old_cs = old_component_storages[old_ci]
                local new_ci = new_component_indices[old_f]
                local new_cs = new_component_storages[new_ci]
                new_cs[new_place] = old_cs[old_place]
            end

            __detach_entity(old_chunk, old_place)
        end

        do
            entity_chunks[entity_index] = new_chunk
            entity_places[entity_index] = new_place

            __structural_changes = __structural_changes + 1
        end

        do
            local new_component_index = new_component_indices[fragment]

            if new_component_index then
                local new_component_storage = new_component_storages[new_component_index]

                local new_component = component
                if new_component == nil then new_component = fragment_default end
                if new_component ~= nil and fragment_duplicate then new_component = fragment_duplicate(new_component) end
                if new_component == nil then new_component = true end

                new_component_storage[new_place] = new_component

                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment, new_component)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment, new_component)
                end
            else
                if fragment_on_set then
                    __defer_call_hook(fragment_on_set, entity, fragment)
                end

                if fragment_on_insert then
                    __defer_call_hook(fragment_on_insert, entity, fragment)
                end
            end
        end

        for i = 1, req_fragment_count do
            local req_fragment = req_fragment_list[i]

            if ini_fragment_set[req_fragment] then
                -- this fragment has already been initialized
            else
                ---@type evolved.default?, evolved.duplicate?, evolved.set_hook?, evolved.insert_hook?
                local req_fragment_default, req_fragment_duplicate, req_fragment_on_set, req_fragment_on_insert

                if new_chunk_has_setup_hooks or new_chunk_has_insert_hooks then
                    req_fragment_default, req_fragment_duplicate, req_fragment_on_set, req_fragment_on_insert =
                        __evolved_get(req_fragment, __DEFAULT, __DUPLICATE, __ON_SET, __ON_INSERT)
                end

                local req_component_index = new_component_indices[req_fragment]

                if req_component_index then
                    local req_component_storage = new_component_storages[req_component_index]

                    local req_component = req_fragment_default

                    if req_component ~= nil and req_fragment_duplicate then
                        req_component = req_fragment_duplicate(req_component)
                    end

                    if req_component == nil then
                        req_component = true
                    end

                    req_component_storage[new_place] = req_component

                    if req_fragment_on_set then
                        __defer_call_hook(req_fragment_on_set, entity, req_fragment, req_component)
                    end

                    if req_fragment_on_insert then
                        __defer_call_hook(req_fragment_on_insert, entity, req_fragment, req_component)
                    end
                else
                    if req_fragment_on_set then
                        __defer_call_hook(req_fragment_on_set, entity, req_fragment)
                    end

                    if req_fragment_on_insert then
                        __defer_call_hook(req_fragment_on_insert, entity, req_fragment)
                    end
                end
            end
        end

        if req_fragment_set then
            __release_table(__table_pool_tag.fragment_set, req_fragment_set)
        end

        if req_fragment_list then
            __release_table(__table_pool_tag.fragment_list, req_fragment_list)
        end
    end

    __evolved_commit()
end

---@param entity evolved.entity
---@param ... evolved.fragment fragments
function __evolved_remove(entity, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return
    end

    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        -- this entity is not alive, nothing to remove
        return
    end

    if __defer_depth > 0 then
        __defer_remove(entity, ...)
        return
    end

    local entity_chunks = __entity_chunks
    local entity_places = __entity_places

    local old_chunk = entity_chunks[entity_index]
    local old_place = entity_places[entity_index]

    local new_chunk = __chunk_without_fragments(old_chunk, ...)

    if old_chunk == new_chunk then
        return
    end

    __evolved_defer()

    do
        local old_fragment_list = old_chunk.__fragment_list
        local old_fragment_count = old_chunk.__fragment_count
        local old_component_indices = old_chunk.__component_indices
        local old_component_storages = old_chunk.__component_storages

        if old_chunk.__has_remove_hooks then
            ---@type table<evolved.fragment, integer>
            local new_fragment_set = new_chunk and new_chunk.__fragment_set
                or __safe_tbls.__EMPTY_FRAGMENT_SET

            for i = 1, old_fragment_count do
                local fragment = old_fragment_list[i]

                if not new_fragment_set[fragment] then
                    ---@type evolved.remove_hook?
                    local fragment_on_remove = __evolved_get(fragment, __ON_REMOVE)

                    if fragment_on_remove then
                        local old_component_index = old_component_indices[fragment]

                        if old_component_index then
                            local old_component_storage = old_component_storages[old_component_index]
                            local old_component = old_component_storage[old_place]
                            __defer_call_hook(fragment_on_remove, entity, fragment, old_component)
                        else
                            __defer_call_hook(fragment_on_remove, entity, fragment)
                        end
                    end
                end
            end
        end

        if new_chunk then
            local new_entity_list = new_chunk.__entity_list
            local new_entity_count = new_chunk.__entity_count

            local new_component_count = new_chunk.__component_count
            local new_component_storages = new_chunk.__component_storages
            local new_component_fragments = new_chunk.__component_fragments

            local new_place = new_entity_count + 1
            new_chunk.__entity_count = new_place

            new_entity_list[new_place] = entity

            for new_ci = 1, new_component_count do
                local new_f = new_component_fragments[new_ci]
                local new_cs = new_component_storages[new_ci]
                local old_ci = old_component_indices[new_f]
                local old_cs = old_component_storages[old_ci]
                new_cs[new_place] = old_cs[old_place]
            end
        end

        do
            __detach_entity(old_chunk, old_place)

            entity_chunks[entity_index] = new_chunk
            entity_places[entity_index] = new_chunk and new_chunk.__entity_count

            __structural_changes = __structural_changes + 1
        end
    end

    __evolved_commit()
end

---@param ... evolved.entity entities
function __evolved_clear(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return
    end

    if __defer_depth > 0 then
        __defer_clear(...)
        return
    end

    __evolved_defer()

    do
        local entity_chunks = __entity_chunks
        local entity_places = __entity_places

        for argument_index = 1, argument_count do
            ---@type evolved.entity
            local entity = __lua_select(argument_index, ...)
            local entity_index = entity % 0x100000

            if __freelist_ids[entity_index] ~= entity then
                -- this entity is not alive, nothing to clear
            else
                local chunk = entity_chunks[entity_index]
                local place = entity_places[entity_index]

                if chunk and chunk.__has_remove_hooks then
                    local chunk_fragment_list = chunk.__fragment_list
                    local chunk_fragment_count = chunk.__fragment_count
                    local chunk_component_indices = chunk.__component_indices
                    local chunk_component_storages = chunk.__component_storages

                    for chunk_fragment_index = 1, chunk_fragment_count do
                        local fragment = chunk_fragment_list[chunk_fragment_index]

                        ---@type evolved.remove_hook?
                        local fragment_on_remove = __evolved_get(fragment, __ON_REMOVE)

                        if fragment_on_remove then
                            local component_index = chunk_component_indices[fragment]

                            if component_index then
                                local component_storage = chunk_component_storages[component_index]
                                local old_component = component_storage[place]
                                __defer_call_hook(fragment_on_remove, entity, fragment, old_component)
                            else
                                __defer_call_hook(fragment_on_remove, entity, fragment)
                            end
                        end
                    end
                end

                if chunk then
                    __detach_entity(chunk, place)

                    entity_chunks[entity_index] = nil
                    entity_places[entity_index] = nil

                    __structural_changes = __structural_changes + 1
                end
            end
        end
    end

    __evolved_commit()
end

---@param ... evolved.entity entities
function __evolved_destroy(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return
    end

    if __defer_depth > 0 then
        __defer_destroy(...)
        return
    end

    __evolved_defer()

    do
        local purging_entity_list = __acquire_table(__table_pool_tag.entity_list)
        local purging_entity_count = 0

        local purging_fragment_list = __acquire_table(__table_pool_tag.fragment_list)
        local purging_fragment_count = 0

        for argument_index = 1, argument_count do
            ---@type evolved.entity
            local entity = __lua_select(argument_index, ...)
            local entity_index = entity % 0x100000

            if __freelist_ids[entity_index] ~= entity then
                -- this entity is not alive, nothing to destroy
            else
                if not __minor_chunks[entity] then
                    purging_entity_count = purging_entity_count + 1
                    purging_entity_list[purging_entity_count] = entity
                else
                    purging_fragment_count = purging_fragment_count + 1
                    purging_fragment_list[purging_fragment_count] = entity
                end
            end
        end

        if purging_fragment_count > 0 then
            __destroy_fragment_list(purging_fragment_list, purging_fragment_count)
            __release_table(__table_pool_tag.fragment_list, purging_fragment_list)
        else
            __release_table(__table_pool_tag.fragment_list, purging_fragment_list, true)
        end

        if purging_entity_count > 0 then
            __destroy_entity_list(purging_entity_list, purging_entity_count)
            __release_table(__table_pool_tag.entity_list, purging_entity_list)
        else
            __release_table(__table_pool_tag.entity_list, purging_entity_list, true)
        end
    end

    __evolved_commit()
end

---@param query evolved.query
---@param fragment evolved.fragment
---@param component evolved.component
function __evolved_batch_set(query, fragment, component)
    if __debug_mode then
        __debug_fns.validate_query(query)
        __debug_fns.validate_fragment(fragment)
    end

    if __defer_depth > 0 then
        __defer_batch_set(query, fragment, component)
        return
    end

    __evolved_defer()

    do
        ---@type evolved.chunk[]
        local chunk_list = __acquire_table(__table_pool_tag.chunk_list)
        local chunk_count = 0

        for chunk in __evolved_execute(query) do
            chunk_count = chunk_count + 1
            chunk_list[chunk_count] = chunk
        end

        for chunk_index = 1, chunk_count do
            local chunk = chunk_list[chunk_index]
            __chunk_set(chunk, fragment, component)
        end

        __release_table(__table_pool_tag.chunk_list, chunk_list)
    end

    __evolved_commit()
end

---@param query evolved.query
---@param ... evolved.fragment fragments
function __evolved_batch_remove(query, ...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return
    end

    local query_index = query % 0x100000

    if __freelist_ids[query_index] ~= query then
        -- this query is not alive, nothing to remove
        return
    end

    if __defer_depth > 0 then
        __defer_batch_remove(query, ...)
        return
    end

    __evolved_defer()

    do
        ---@type evolved.chunk[]
        local chunk_list = __acquire_table(__table_pool_tag.chunk_list)
        local chunk_count = 0

        for chunk in __evolved_execute(query) do
            chunk_count = chunk_count + 1
            chunk_list[chunk_count] = chunk
        end

        for chunk_index = 1, chunk_count do
            local chunk = chunk_list[chunk_index]
            __chunk_remove(chunk, ...)
        end

        __release_table(__table_pool_tag.chunk_list, chunk_list)
    end

    __evolved_commit()
end

---@param ... evolved.query queries
function __evolved_batch_clear(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return
    end

    if __defer_depth > 0 then
        __defer_batch_clear(...)
        return
    end

    __evolved_defer()

    do
        ---@type evolved.chunk[]
        local chunk_list = __acquire_table(__table_pool_tag.chunk_list)
        local chunk_count = 0

        for argument_index = 1, argument_count do
            ---@type evolved.query
            local query = __lua_select(argument_index, ...)
            local query_index = query % 0x100000

            if __freelist_ids[query_index] ~= query then
                -- this query is not alive, nothing to remove
            else
                for chunk in __evolved_execute(query) do
                    chunk_count = chunk_count + 1
                    chunk_list[chunk_count] = chunk
                end
            end
        end

        for chunk_index = 1, chunk_count do
            local chunk = chunk_list[chunk_index]
            __chunk_clear(chunk)
        end

        __release_table(__table_pool_tag.chunk_list, chunk_list)
    end

    __evolved_commit()
end

---@param ... evolved.query queries
function __evolved_batch_destroy(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return
    end

    if __defer_depth > 0 then
        __defer_batch_destroy(...)
        return
    end

    __evolved_defer()

    do
        local clearing_chunk_list = __acquire_table(__table_pool_tag.chunk_list)
        local clearing_chunk_count = 0

        local purging_entity_list = __acquire_table(__table_pool_tag.entity_list)
        local purging_entity_count = 0

        local purging_fragment_list = __acquire_table(__table_pool_tag.fragment_list)
        local purging_fragment_count = 0

        for argument_index = 1, argument_count do
            ---@type evolved.query
            local query = __lua_select(argument_index, ...)
            local query_index = query % 0x100000

            if __freelist_ids[query_index] ~= query then
                -- this query is not alive, nothing to destroy
            else
                for chunk, entity_list, entity_count in __evolved_execute(query) do
                    clearing_chunk_count = clearing_chunk_count + 1
                    clearing_chunk_list[clearing_chunk_count] = chunk

                    for i = 1, entity_count do
                        local entity = entity_list[i]

                        if not __minor_chunks[entity] then
                            purging_entity_count = purging_entity_count + 1
                            purging_entity_list[purging_entity_count] = entity
                        else
                            purging_fragment_count = purging_fragment_count + 1
                            purging_fragment_list[purging_fragment_count] = entity
                        end
                    end
                end
            end
        end

        if purging_fragment_count > 0 then
            __destroy_fragment_list(purging_fragment_list, purging_fragment_count)
            __release_table(__table_pool_tag.fragment_list, purging_fragment_list)
        else
            __release_table(__table_pool_tag.fragment_list, purging_fragment_list, true)
        end

        if clearing_chunk_count > 0 then
            __clear_chunk_list(clearing_chunk_list, clearing_chunk_count)
            __release_table(__table_pool_tag.chunk_list, clearing_chunk_list)
        else
            __release_table(__table_pool_tag.chunk_list, clearing_chunk_list, true)
        end

        if purging_entity_count > 0 then
            __destroy_entity_list(purging_entity_list, purging_entity_count)
            __release_table(__table_pool_tag.entity_list, purging_entity_list)
        else
            __release_table(__table_pool_tag.entity_list, purging_entity_list, true)
        end
    end

    __evolved_commit()
end

---@param entity evolved.entity
---@return evolved.each_iterator iterator
---@return evolved.each_state? iterator_state
---@nodiscard
function __evolved_each(entity)
    local entity_index = entity % 0x100000

    if __freelist_ids[entity_index] ~= entity then
        return __each_iterator
    end

    local entity_chunks = __entity_chunks
    local entity_places = __entity_places

    local chunk = entity_chunks[entity_index]
    local place = entity_places[entity_index]

    if not chunk then
        return __each_iterator
    end

    ---@type evolved.each_state
    local each_state = __acquire_table(__table_pool_tag.each_state)

    each_state[1] = __structural_changes
    each_state[2] = chunk
    each_state[3] = place
    each_state[4] = 1

    return __each_iterator, each_state
end

---@param query evolved.query
---@return evolved.execute_iterator iterator
---@return evolved.execute_state? iterator_state
---@nodiscard
function __evolved_execute(query)
    local query_index = query % 0x100000

    if __freelist_ids[query_index] ~= query then
        return __execute_iterator
    end

    ---@type evolved.chunk[]
    local chunk_stack = __acquire_table(__table_pool_tag.chunk_list)
    local chunk_stack_size = 0

    local query_includes = __sorted_includes[query]
    local query_include_set = query_includes and query_includes.__item_set --[[@as table<evolved.fragment, integer>]]
    local query_include_list = query_includes and query_includes.__item_list --[=[@as evolved.fragment[]]=]
    local query_include_count = query_includes and query_includes.__item_count or 0 --[[@as integer]]

    local query_excludes = __sorted_excludes[query]
    local query_exclude_set = query_excludes and query_excludes.__item_set --[[@as table<evolved.fragment, integer>]]
    local query_exclude_list = query_excludes and query_excludes.__item_list --[=[@as evolved.fragment[]]=]
    local query_exclude_count = query_excludes and query_excludes.__item_count or 0 --[[@as integer]]

    if query_include_count > 0 then
        local major_fragment = query_include_list[query_include_count]

        local major_chunks = __major_chunks[major_fragment]
        local major_chunk_list = major_chunks and major_chunks.__item_list --[=[@as evolved.chunk[]]=]
        local major_chunk_count = major_chunks and major_chunks.__item_count or 0 --[[@as integer]]

        for major_chunk_index = 1, major_chunk_count do
            local major_chunk = major_chunk_list[major_chunk_index]

            local is_major_chunk_matched =
                (query_include_count == 1 or __chunk_has_all_fragment_list(
                    major_chunk, query_include_list, query_include_count - 1)) and
                (query_exclude_count == 0 or not __chunk_has_any_fragment_list(
                    major_chunk, query_exclude_list, query_exclude_count))

            if is_major_chunk_matched and major_chunk.__has_explicit_minors then
                local major_chunk_fragment_list = major_chunk.__fragment_list
                local major_chunk_fragment_count = major_chunk.__fragment_count

                for major_chunk_fragment_index = 1, major_chunk_fragment_count - 1 do
                    local major_chunk_fragment = major_chunk_fragment_list[major_chunk_fragment_index]

                    if not query_include_set[major_chunk_fragment] and __evolved_has(major_chunk_fragment, __EXPLICIT) then
                        is_major_chunk_matched = false
                        break
                    end
                end
            end

            if is_major_chunk_matched then
                chunk_stack_size = chunk_stack_size + 1
                chunk_stack[chunk_stack_size] = major_chunk
            end
        end
    elseif query_exclude_count > 0 then
        for root_fragment, root_chunk in __lua_next, __root_chunks do
            local is_root_chunk_matched =
                not root_chunk.__has_explicit_major and
                not query_exclude_set[root_fragment]

            if is_root_chunk_matched then
                chunk_stack_size = chunk_stack_size + 1
                chunk_stack[chunk_stack_size] = root_chunk
            end
        end
    else
        for _, root_chunk in __lua_next, __root_chunks do
            local is_root_chunk_matched =
                not root_chunk.__has_explicit_major

            if is_root_chunk_matched then
                chunk_stack_size = chunk_stack_size + 1
                chunk_stack[chunk_stack_size] = root_chunk
            end
        end
    end

    ---@type evolved.execute_state
    local execute_state = __acquire_table(__table_pool_tag.execute_state)

    execute_state[1] = __structural_changes
    execute_state[2] = chunk_stack
    execute_state[3] = chunk_stack_size
    execute_state[4] = query_exclude_set

    return __execute_iterator, execute_state
end

---@param ... evolved.system systems
function __evolved_process(...)
    if __debug_mode then
        __debug_fns.validate_systems(...)
    end

    for i = 1, __lua_select('#', ...) do
        ---@type evolved.system
        local system = __lua_select(i, ...)
        if not __evolved_has(system, __DISABLED) then
            __system_process(system)
        end
    end
end

---@param yesno boolean
function __evolved_debug_mode(yesno)
    __debug_mode = yesno
end

function __evolved_collect_garbage()
    if __defer_depth > 0 then
        __defer_call_hook(__evolved_collect_garbage)
        return
    end

    __evolved_defer()

    do
        ---@type evolved.chunk[]
        local working_chunk_stack = __acquire_table(__table_pool_tag.chunk_list)
        local working_chunk_stack_size = 0

        ---@type evolved.chunk[]
        local postorder_chunk_stack = __acquire_table(__table_pool_tag.chunk_list)
        local postorder_chunk_stack_size = 0

        for _, root_chunk in __lua_next, __root_chunks do
            working_chunk_stack_size = working_chunk_stack_size + 1
            working_chunk_stack[working_chunk_stack_size] = root_chunk

            while working_chunk_stack_size > 0 do
                local working_chunk = working_chunk_stack[working_chunk_stack_size]

                working_chunk_stack[working_chunk_stack_size] = nil
                working_chunk_stack_size = working_chunk_stack_size - 1

                do
                    local working_chunk_child_list = working_chunk.__child_list
                    local working_chunk_child_count = working_chunk.__child_count

                    __lua_table_move(
                        working_chunk_child_list, 1, working_chunk_child_count,
                        working_chunk_stack_size + 1, working_chunk_stack)

                    working_chunk_stack_size = working_chunk_stack_size + working_chunk_child_count
                end

                postorder_chunk_stack_size = postorder_chunk_stack_size + 1
                postorder_chunk_stack[postorder_chunk_stack_size] = working_chunk
            end
        end

        for postorder_chunk_index = postorder_chunk_stack_size, 1, -1 do
            local postorder_chunk = postorder_chunk_stack[postorder_chunk_index]
            local postorder_chunk_pins = __pinned_chunks[postorder_chunk] or 0

            local is_not_pinned =
                postorder_chunk_pins == 0

            local should_be_purged =
                postorder_chunk.__child_count == 0 and
                postorder_chunk.__entity_count == 0

            if is_not_pinned and should_be_purged then
                __purge_chunk(postorder_chunk)
            end
        end

        __release_table(__table_pool_tag.chunk_list, working_chunk_stack)
        __release_table(__table_pool_tag.chunk_list, postorder_chunk_stack)
    end

    __evolved_commit()
end

---
---
---
---
---

---@param fragment evolved.fragment
---@param ... evolved.fragment fragments
---@return evolved.chunk chunk
---@return evolved.entity[] entity_list
---@return integer entity_count
---@nodiscard
function __evolved_chunk(fragment, ...)
    local chunk = __chunk_fragments(fragment, ...)
    return chunk, chunk.__entity_list, chunk.__entity_count
end

function __chunk_mt:__tostring()
    local fragment_names = {} ---@type string[]

    for i = 1, self.__fragment_count do
        fragment_names[i] = __id_name(self.__fragment_list[i])
    end

    return __lua_string_format('<%s>', __lua_table_concat(fragment_names, ', '))
end

---@return boolean
---@nodiscard
function __chunk_mt:alive()
    return not self.__unreachable_or_collected
end

---@return boolean
---@nodiscard
function __chunk_mt:empty()
    return self.__unreachable_or_collected or self.__entity_count == 0
end

---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function __chunk_mt:has(fragment)
    return __chunk_has_fragment(self, fragment)
end

---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __chunk_mt:has_all(...)
    return __chunk_has_all_fragments(self, ...)
end

---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __chunk_mt:has_any(...)
    return __chunk_has_any_fragments(self, ...)
end

---@return evolved.entity[] entity_list
---@return integer entity_count
---@nodiscard
function __chunk_mt:entities()
    return self.__entity_list, self.__entity_count
end

---@return evolved.fragment[] fragment_list
---@return integer fragment_count
---@nodiscard
function __chunk_mt:fragments()
    return self.__fragment_list, self.__fragment_count
end

---@param ... evolved.fragment fragments
---@return evolved.storage ... storages
---@nodiscard
function __chunk_mt:components(...)
    local fragment_count = __lua_select('#', ...)

    if fragment_count == 0 then
        return
    end

    local indices = self.__component_indices
    local storages = self.__component_storages

    local empty_component_storage = __safe_tbls.__EMPTY_COMPONENT_STORAGE

    if fragment_count == 1 then
        local f1 = ...
        local i1 = indices[f1]
        return
            i1 and storages[i1] or empty_component_storage
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        local i1, i2 = indices[f1], indices[f2]
        return
            i1 and storages[i1] or empty_component_storage,
            i2 and storages[i2] or empty_component_storage
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        local i1, i2, i3 = indices[f1], indices[f2], indices[f3]
        return
            i1 and storages[i1] or empty_component_storage,
            i2 and storages[i2] or empty_component_storage,
            i3 and storages[i3] or empty_component_storage
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        local i1, i2, i3, i4 = indices[f1], indices[f2], indices[f3], indices[f4]
        return
            i1 and storages[i1] or empty_component_storage,
            i2 and storages[i2] or empty_component_storage,
            i3 and storages[i3] or empty_component_storage,
            i4 and storages[i4] or empty_component_storage
    end

    do
        local f1, f2, f3, f4 = ...
        local i1, i2, i3, i4 = indices[f1], indices[f2], indices[f3], indices[f4]
        return
            i1 and storages[i1] or empty_component_storage,
            i2 and storages[i2] or empty_component_storage,
            i3 and storages[i3] or empty_component_storage,
            i4 and storages[i4] or empty_component_storage,
            self:components(__lua_select(5, ...))
    end
end

---
---
---
---
---

---@return evolved.builder builder
---@nodiscard
function __evolved_builder()
    return __lua_setmetatable({
        __components = {},
    }, __builder_mt)
end

function __builder_mt:__tostring()
    local fragment_list = {} ---@type evolved.fragment[]
    local fragment_count = 0 ---@type integer

    for fragment in __lua_next, self.__components do
        fragment_count = fragment_count + 1
        fragment_list[fragment_count] = fragment
    end

    __lua_table_sort(fragment_list)

    local fragment_names = {} ---@type string[]

    for i = 1, fragment_count do
        fragment_names[i] = __id_name(fragment_list[i])
    end

    return __lua_string_format('<%s>', __lua_table_concat(fragment_names, ', '))
end

---@return evolved.entity
function __builder_mt:spawn()
    local components = self.__components

    if __debug_mode then
        __debug_fns.validate_component_map(components)
    end

    local entity = __acquire_id()

    if __defer_depth > 0 then
        __defer_spawn_entity(entity, components)
    else
        __evolved_defer()
        do
            __spawn_entity(entity, components)
        end
        __evolved_commit()
    end

    return entity
end

---@param prefab evolved.entity
---@return evolved.entity
function __builder_mt:clone(prefab)
    local components = self.__components

    if __debug_mode then
        __debug_fns.validate_prefab(prefab)
        __debug_fns.validate_component_map(components)
    end

    local entity = __acquire_id()

    if __defer_depth > 0 then
        __defer_clone_entity(entity, prefab, components)
    else
        __evolved_defer()
        do
            __clone_entity(entity, prefab, components)
        end
        __evolved_commit()
    end

    return entity
end

---@param fragment evolved.fragment
---@return boolean
---@nodiscard
function __builder_mt:has(fragment)
    return self.__components[fragment] ~= nil
end

---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __builder_mt:has_all(...)
    local fragment_count = __lua_select("#", ...)

    if fragment_count == 0 then
        return true
    end

    local cs = self.__components

    if fragment_count == 1 then
        local f1 = ...
        return cs[f1] ~= nil
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        return cs[f1] ~= nil and cs[f2] ~= nil
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        return cs[f1] ~= nil and cs[f2] ~= nil and cs[f3] ~= nil
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        return cs[f1] ~= nil and cs[f2] ~= nil and cs[f3] ~= nil and cs[f4] ~= nil
    end

    do
        local f1, f2, f3, f4 = ...
        return cs[f1] ~= nil and cs[f2] ~= nil and cs[f3] ~= nil and cs[f4] ~= nil and
            self:has_all(__lua_select(5, ...))
    end
end

---@param ... evolved.fragment fragments
---@return boolean
---@nodiscard
function __builder_mt:has_any(...)
    local fragment_count = __lua_select("#", ...)

    if fragment_count == 0 then
        return false
    end

    local cs = self.__components

    if fragment_count == 1 then
        local f1 = ...
        return cs[f1] ~= nil
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        return cs[f1] ~= nil or cs[f2] ~= nil
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        return cs[f1] ~= nil or cs[f2] ~= nil or cs[f3] ~= nil
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        return cs[f1] ~= nil or cs[f2] ~= nil or cs[f3] ~= nil or cs[f4] ~= nil
    end

    do
        local f1, f2, f3, f4 = ...
        return cs[f1] ~= nil or cs[f2] ~= nil or cs[f3] ~= nil or cs[f4] ~= nil or
            self:has_any(__lua_select(5, ...))
    end
end

---@param ... evolved.fragment fragments
---@return evolved.component ... components
---@nodiscard
function __builder_mt:get(...)
    local fragment_count = __lua_select("#", ...)

    if fragment_count == 0 then
        return
    end

    local cs = self.__components

    if fragment_count == 1 then
        local f1 = ...
        return cs[f1]
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        return cs[f1], cs[f2]
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        return cs[f1], cs[f2], cs[f3]
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        return cs[f1], cs[f2], cs[f3], cs[f4]
    end

    do
        local f1, f2, f3, f4 = ...
        return cs[f1], cs[f2], cs[f3], cs[f4],
            self:get(__lua_select(5, ...))
    end
end

---@param fragment evolved.fragment
---@param component evolved.component
---@return evolved.builder builder
function __builder_mt:set(fragment, component)
    if __debug_mode then
        __debug_fns.validate_fragment(fragment)
    end

    do
        ---@type evolved.default?, evolved.duplicate?
        local fragment_default, fragment_duplicate =
            __evolved_get(fragment, __DEFAULT, __DUPLICATE)

        if component == nil then
            component = fragment_default
        end

        if component ~= nil and fragment_duplicate then
            component = fragment_duplicate(component)
        end

        if component == nil then
            component = true
        end
    end

    self.__components[fragment] = component

    return self
end

---@param ... evolved.fragment fragments
---@return evolved.builder builder
function __builder_mt:remove(...)
    local fragment_count = __lua_select("#", ...)

    if fragment_count == 0 then
        return self
    end

    local cs = self.__components

    if fragment_count == 1 then
        local f1 = ...
        cs[f1] = nil
        return self
    end

    if fragment_count == 2 then
        local f1, f2 = ...
        cs[f1] = nil; cs[f2] = nil
        return self
    end

    if fragment_count == 3 then
        local f1, f2, f3 = ...
        cs[f1] = nil; cs[f2] = nil; cs[f3] = nil
        return self
    end

    if fragment_count == 4 then
        local f1, f2, f3, f4 = ...
        cs[f1] = nil; cs[f2] = nil; cs[f3] = nil; cs[f4] = nil
        return self
    end

    do
        local f1, f2, f3, f4 = ...
        cs[f1] = nil; cs[f2] = nil; cs[f3] = nil; cs[f4] = nil
        return self:remove(__lua_select(5, ...))
    end
end

---@return evolved.builder builder
function __builder_mt:clear()
    __lua_table_clear(self.__components)
    return self
end

---@return evolved.builder builder
function __builder_mt:tag()
    return self:set(__TAG)
end

---@param name string
---@return evolved.builder builder
function __builder_mt:name(name)
    return self:set(__NAME, name)
end

---@return evolved.builder builder
function __builder_mt:unique()
    return self:set(__UNIQUE)
end

---@return evolved.builder builder
function __builder_mt:explicit()
    return self:set(__EXPLICIT)
end

---@param default evolved.component
---@return evolved.builder builder
function __builder_mt:default(default)
    return self:set(__DEFAULT, default)
end

---@param duplicate evolved.duplicate
---@return evolved.builder builder
function __builder_mt:duplicate(duplicate)
    return self:set(__DUPLICATE, duplicate)
end

---@return evolved.builder builder
function __builder_mt:prefab()
    return self:set(__PREFAB)
end

---@return evolved.builder builder
function __builder_mt:disabled()
    return self:set(__DISABLED)
end

---@param ... evolved.fragment fragments
---@return evolved.builder builder
function __builder_mt:include(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return self
    end

    local include_list = self:get(__INCLUDES)
    local include_count = include_list and #include_list or 0

    if include_count == 0 then
        include_list = __lua_table_new(argument_count, 0)
    end

    for i = 1, argument_count do
        ---@type evolved.fragment
        local fragment = __lua_select(i, ...)
        include_list[include_count + i] = fragment
    end

    return self:set(__INCLUDES, include_list)
end

---@param ... evolved.fragment fragments
---@return evolved.builder builder
function __builder_mt:exclude(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return self
    end

    local exclude_list = self:get(__EXCLUDES)
    local exclude_count = exclude_list and #exclude_list or 0

    if exclude_count == 0 then
        exclude_list = __lua_table_new(argument_count, 0)
    end

    for i = 1, argument_count do
        ---@type evolved.fragment
        local fragment = __lua_select(i, ...)
        exclude_list[exclude_count + i] = fragment
    end

    return self:set(__EXCLUDES, exclude_list)
end

---@param ... evolved.fragment fragments
---@return evolved.builder builder
function __builder_mt:require(...)
    local argument_count = __lua_select('#', ...)

    if argument_count == 0 then
        return self
    end

    local require_list = self:get(__REQUIRES)
    local require_count = require_list and #require_list or 0

    if require_count == 0 then
        require_list = __lua_table_new(argument_count, 0)
    end

    for i = 1, argument_count do
        ---@type evolved.fragment
        local fragment = __lua_select(i, ...)
        require_list[require_count + i] = fragment
    end

    return self:set(__REQUIRES, require_list)
end

---@param on_set evolved.set_hook
---@return evolved.builder builder
function __builder_mt:on_set(on_set)
    return self:set(__ON_SET, on_set)
end

---@param on_assign evolved.assign_hook
---@return evolved.builder builder
function __builder_mt:on_assign(on_assign)
    return self:set(__ON_ASSIGN, on_assign)
end

---@param on_insert evolved.insert_hook
---@return evolved.builder builder
function __builder_mt:on_insert(on_insert)
    return self:set(__ON_INSERT, on_insert)
end

---@param on_remove evolved.remove_hook
---@return evolved.builder builder
function __builder_mt:on_remove(on_remove)
    return self:set(__ON_REMOVE, on_remove)
end

---@param group evolved.system
---@return evolved.builder builder
function __builder_mt:group(group)
    return self:set(__GROUP, group)
end

---@param query evolved.query
---@return evolved.builder builder
function __builder_mt:query(query)
    return self:set(__QUERY, query)
end

---@param execute evolved.execute
---@return evolved.builder builder
function __builder_mt:execute(execute)
    return self:set(__EXECUTE, execute)
end

---@param prologue evolved.prologue
---@return evolved.builder builder
function __builder_mt:prologue(prologue)
    return self:set(__PROLOGUE, prologue)
end

---@param epilogue evolved.epilogue
---@return evolved.builder builder
function __builder_mt:epilogue(epilogue)
    return self:set(__EPILOGUE, epilogue)
end

---@param destruction_policy evolved.id
---@return evolved.builder builder
function __builder_mt:destruction_policy(destruction_policy)
    return self:set(__DESTRUCTION_POLICY, destruction_policy)
end

---
---
---
---
---

__evolved_set(__ON_SET, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__ON_ASSIGN, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__ON_INSERT, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__ON_REMOVE, __ON_INSERT, __update_major_chunks_hook)

__evolved_set(__ON_SET, __ON_REMOVE, __update_major_chunks_hook)
__evolved_set(__ON_ASSIGN, __ON_REMOVE, __update_major_chunks_hook)
__evolved_set(__ON_INSERT, __ON_REMOVE, __update_major_chunks_hook)
__evolved_set(__ON_REMOVE, __ON_REMOVE, __update_major_chunks_hook)

---
---
---
---
---

__evolved_set(__TAG, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__TAG, __ON_REMOVE, __update_major_chunks_hook)

__evolved_set(__UNIQUE, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__UNIQUE, __ON_REMOVE, __update_major_chunks_hook)

__evolved_set(__EXPLICIT, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__EXPLICIT, __ON_REMOVE, __update_major_chunks_hook)

__evolved_set(__DEFAULT, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__DEFAULT, __ON_REMOVE, __update_major_chunks_hook)

__evolved_set(__DUPLICATE, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__DUPLICATE, __ON_REMOVE, __update_major_chunks_hook)

__evolved_set(__REQUIRES, __ON_INSERT, __update_major_chunks_hook)
__evolved_set(__REQUIRES, __ON_REMOVE, __update_major_chunks_hook)

---
---
---
---
---

__evolved_set(__TAG, __NAME, 'TAG')
__evolved_set(__NAME, __NAME, 'NAME')

__evolved_set(__UNIQUE, __NAME, 'UNIQUE')
__evolved_set(__EXPLICIT, __NAME, 'EXPLICIT')

__evolved_set(__DEFAULT, __NAME, 'DEFAULT')
__evolved_set(__DUPLICATE, __NAME, 'DUPLICATE')

__evolved_set(__PREFAB, __NAME, 'PREFAB')
__evolved_set(__DISABLED, __NAME, 'DISABLED')

__evolved_set(__INCLUDES, __NAME, 'INCLUDES')
__evolved_set(__EXCLUDES, __NAME, 'EXCLUDES')
__evolved_set(__REQUIRES, __NAME, 'REQUIRES')

__evolved_set(__ON_SET, __NAME, 'ON_SET')
__evolved_set(__ON_ASSIGN, __NAME, 'ON_ASSIGN')
__evolved_set(__ON_INSERT, __NAME, 'ON_INSERT')
__evolved_set(__ON_REMOVE, __NAME, 'ON_REMOVE')

__evolved_set(__GROUP, __NAME, 'GROUP')

__evolved_set(__QUERY, __NAME, 'QUERY')
__evolved_set(__EXECUTE, __NAME, 'EXECUTE')

__evolved_set(__PROLOGUE, __NAME, 'PROLOGUE')
__evolved_set(__EPILOGUE, __NAME, 'EPILOGUE')

__evolved_set(__DESTRUCTION_POLICY, __NAME, 'DESTRUCTION_POLICY')
__evolved_set(__DESTRUCTION_POLICY_DESTROY_ENTITY, __NAME, 'DESTRUCTION_POLICY_DESTROY_ENTITY')
__evolved_set(__DESTRUCTION_POLICY_REMOVE_FRAGMENT, __NAME, 'DESTRUCTION_POLICY_REMOVE_FRAGMENT')

---
---
---
---
---

__evolved_set(__TAG, __TAG)

__evolved_set(__UNIQUE, __TAG)

__evolved_set(__EXPLICIT, __TAG)

__evolved_set(__PREFAB, __TAG)
__evolved_set(__PREFAB, __UNIQUE)
__evolved_set(__PREFAB, __EXPLICIT)

__evolved_set(__DISABLED, __TAG)
__evolved_set(__DISABLED, __UNIQUE)
__evolved_set(__DISABLED, __EXPLICIT)

__evolved_set(__INCLUDES, __DEFAULT, {})
__evolved_set(__INCLUDES, __DUPLICATE, __list_copy)

__evolved_set(__EXCLUDES, __DEFAULT, {})
__evolved_set(__EXCLUDES, __DUPLICATE, __list_copy)

__evolved_set(__REQUIRES, __DEFAULT, {})
__evolved_set(__REQUIRES, __DUPLICATE, __list_copy)

__evolved_set(__ON_SET, __UNIQUE)
__evolved_set(__ON_ASSIGN, __UNIQUE)
__evolved_set(__ON_INSERT, __UNIQUE)
__evolved_set(__ON_REMOVE, __UNIQUE)

---
---
---
---
---

---@param query evolved.query
---@param include_list evolved.fragment[]
__evolved_set(__INCLUDES, __ON_SET, function(query, _, include_list)
    local include_count = #include_list

    if include_count == 0 then
        __sorted_includes[query] = nil
        return
    end

    local sorted_includes = __assoc_list_new(include_count)

    for include_index = 1, include_count do
        local include = include_list[include_index]
        __assoc_list_insert(sorted_includes, include)
    end

    __assoc_list_sort(sorted_includes)
    __sorted_includes[query] = sorted_includes
end)

__evolved_set(__INCLUDES, __ON_REMOVE, function(query)
    __sorted_includes[query] = nil
end)

---
---
---
---
---

---@param query evolved.query
---@param exclude_list evolved.fragment[]
__evolved_set(__EXCLUDES, __ON_SET, function(query, _, exclude_list)
    local exclude_count = #exclude_list

    if exclude_count == 0 then
        __sorted_excludes[query] = nil
        return
    end

    local sorted_excludes = __assoc_list_new(exclude_count)

    for exclude_index = 1, exclude_count do
        local exclude = exclude_list[exclude_index]
        __assoc_list_insert(sorted_excludes, exclude)
    end

    __assoc_list_sort(sorted_excludes)
    __sorted_excludes[query] = sorted_excludes
end)

__evolved_set(__EXCLUDES, __ON_REMOVE, function(query)
    __sorted_excludes[query] = nil
end)

---
---
---
---
---

---@param fragment evolved.fragment
---@param require_list evolved.fragment[]
__evolved_set(__REQUIRES, __ON_SET, function(fragment, _, require_list)
    local require_count = #require_list

    if require_count == 0 then
        __sorted_requires[fragment] = nil
        return
    end

    local sorted_requires = __assoc_list_new(require_count)

    for require_index = 1, require_count do
        local require = require_list[require_index]
        __assoc_list_insert(sorted_requires, require)
    end

    __assoc_list_sort(sorted_requires)
    __sorted_requires[fragment] = sorted_requires
end)

__evolved_set(__REQUIRES, __ON_REMOVE, function(fragment)
    __sorted_requires[fragment] = nil
end)

---
---
---
---
---

---@param system evolved.system
---@param new_group evolved.system
---@param old_group? evolved.system
__evolved_set(__GROUP, __ON_SET, function(system, _, new_group, old_group)
    if new_group == old_group then
        return
    end

    if old_group then
        local old_group_systems = __group_subsystems[old_group]

        if old_group_systems then
            __assoc_list_remove(old_group_systems, system)

            if old_group_systems.__item_count == 0 then
                __group_subsystems[old_group] = nil
            end
        end
    end

    local new_group_systems = __group_subsystems[new_group]

    if not new_group_systems then
        new_group_systems = __assoc_list_new(4)
        __group_subsystems[new_group] = new_group_systems
    end

    __assoc_list_insert(new_group_systems, system)
end)

---@param system evolved.system
---@param old_group evolved.system
__evolved_set(__GROUP, __ON_REMOVE, function(system, _, old_group)
    local old_group_systems = __group_subsystems[old_group]

    if old_group_systems then
        __assoc_list_remove(old_group_systems, system)

        if old_group_systems.__item_count == 0 then
            __group_subsystems[old_group] = nil
        end
    end
end)

---
---
---
---
---

evolved.TAG = __TAG
evolved.NAME = __NAME

evolved.UNIQUE = __UNIQUE
evolved.EXPLICIT = __EXPLICIT

evolved.DEFAULT = __DEFAULT
evolved.DUPLICATE = __DUPLICATE

evolved.PREFAB = __PREFAB
evolved.DISABLED = __DISABLED

evolved.INCLUDES = __INCLUDES
evolved.EXCLUDES = __EXCLUDES
evolved.REQUIRES = __REQUIRES

evolved.ON_SET = __ON_SET
evolved.ON_ASSIGN = __ON_ASSIGN
evolved.ON_INSERT = __ON_INSERT
evolved.ON_REMOVE = __ON_REMOVE

evolved.GROUP = __GROUP

evolved.QUERY = __QUERY
evolved.EXECUTE = __EXECUTE

evolved.PROLOGUE = __PROLOGUE
evolved.EPILOGUE = __EPILOGUE

evolved.DESTRUCTION_POLICY = __DESTRUCTION_POLICY
evolved.DESTRUCTION_POLICY_DESTROY_ENTITY = __DESTRUCTION_POLICY_DESTROY_ENTITY
evolved.DESTRUCTION_POLICY_REMOVE_FRAGMENT = __DESTRUCTION_POLICY_REMOVE_FRAGMENT

evolved.id = __evolved_id

evolved.pack = __evolved_pack
evolved.unpack = __evolved_unpack

evolved.defer = __evolved_defer
evolved.commit = __evolved_commit

evolved.spawn = __evolved_spawn
evolved.clone = __evolved_clone

evolved.alive = __evolved_alive
evolved.alive_all = __evolved_alive_all
evolved.alive_any = __evolved_alive_any

evolved.empty = __evolved_empty
evolved.empty_all = __evolved_empty_all
evolved.empty_any = __evolved_empty_any

evolved.has = __evolved_has
evolved.has_all = __evolved_has_all
evolved.has_any = __evolved_has_any

evolved.get = __evolved_get

evolved.set = __evolved_set
evolved.remove = __evolved_remove
evolved.clear = __evolved_clear
evolved.destroy = __evolved_destroy

evolved.batch_set = __evolved_batch_set
evolved.batch_remove = __evolved_batch_remove
evolved.batch_clear = __evolved_batch_clear
evolved.batch_destroy = __evolved_batch_destroy

evolved.each = __evolved_each
evolved.execute = __evolved_execute

evolved.process = __evolved_process

evolved.debug_mode = __evolved_debug_mode
evolved.collect_garbage = __evolved_collect_garbage

evolved.chunk = __evolved_chunk
evolved.builder = __evolved_builder

evolved.collect_garbage()

return evolved
