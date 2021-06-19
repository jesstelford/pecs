-- pecs ENTITY COMPONENT SYSTEM
-- github.com/jesstelford/pecs
-- v1.1.1
-- License: MIT Copyright (c) 2021 Jess Telford

-- | (code reformatted for aesthetics and   
-- | maximum PICO-8 code editor friendliness 
-- | by josiebb.)

-- | API changes:
-- |  createECSworld -> create_world
-- |  createComponent -> create_comp
-- |  createEntity -> create_ent
-- |  createSystem -> create_sys

local create_world do
  local _highest_id = 0

  function cuid()
    _highest_id += 1
    return _highest_id
  end

  local array_same, find, every, assign =

-- | array_same; O(n) comparison of 
-- | values in a table

    function(a, b)
      if (#a != #b) then return false end
      value_hash = {}

      for _, value in pairs(a) do
        value_hash[value] = (value_hash[value] or 0) + 1
      end

      for _, value in pairs(b) do
        value_hash[value] = (value_hash[value] or 0) - 1
      end

      for _, value in pairs(value_hash) do
        if (value != 0) then return false end
      end

      return true
    end,

-- | find

    function(collection, item, compare_func)
      for key, value in pairs(collection) do
        if (compare_func(key, value, item)) then
          return value
        end
      end
      return nil
    end,

-- | every

    function(collection, check_func)
      for key, value in pairs(collection) do
        if (not check_func(value, key, collection)) then
          return false
        end
      end
      return true
    end,

-- | assign

    function(...)
      local result = {}
      local args = { n = select("#", ...), ... }
      for i = 1, args.n do
        if (type(args[i]) == "table") then
          for key, value in pairs(args[i]) do 
            result[key] = value 
          end
        end
      end
      return result
    end

  create_world = function()
    local entities = {}
    local queries = {}
    local systems = {}
    local update_stack = {}

-- | Filter is an array of components, 
-- | eg; { Positionable, collidable }
-- | Return a reference to the filtered 
-- | list of entities (automatically
-- | updated when new entities match 
-- | or old entities no longer match)

    function create_query(filter)

-- | this filter already exists

      local query = find(queries, filter, function(a, _, b)
        return array_same(a, b)
      end)

      if (query != nil) then
        return query
      end

-- | Empty to start

      queries[filter] = {}

-- | Then iterate over all known 
-- | entities to populate the filter

      for _, ent in pairs(entities) do
        if (every(filter, function(comp_factory)
          return ent[comp_factory]
        end)) then
          queries[filter][ent._id] = ent
        end
      end

      return queries[filter]
    end

    function update_filters(ent)

-- | Extract out just the 
-- | components from this entity

      local comps = {}
      for _, comp in pairs(ent) do
        if (type(comp) == "table" 
        and comp._comp_factory != nil) then
          add(comps, comp)
        end
      end

      function has_comp(comp_factory)
        return ent[comp_factory] != nil
      end

-- | Check and update each filter

      for filter, entities in pairs(queries) do
        entities[ent._id] = every(filter, has_comp) and ent or nil
      end
    end

    function add_comp(ent, comp)

-- | Only comps created by 
-- | create_comp() can be added

      assert(comp and comp._comp_factory)

-- | And only once

      assert(not ent[comp._comp_factory])

-- | Store the comp keyed by its factory

      ent[comp._comp_factory] = comp
    end

    function create_ent(attributes, ...)
      local ent = assign({}, attributes or {})

      ent._id = cuid()

      setmetatable(ent,{
        __add=function(self, comp)
          add_comp(self, comp)

-- | This ent's set of components 
-- | has changed, so we need to 
-- | update the queries

          update_filters(self)
          return self
        end,

        __sub=function(self, comp_factory)
          self[comp_factory] = nil
          update_filters(self)
          return self
        end
      })

      local new_comps = 0
      for comp in all(pack(...)) do
        new_comps += 1
        add_comp(ent, comp)
      end

      entities[ent._id] = ent

      if (new_comps > 0) then update_filters(ent) end
      return ent
    end

    function create_comp(defaults)
      local function comp_factory(attributes)
        local comp = assign({}, defaults, attributes)
        comp._comp_factory = comp_factory
        comp._id = cuid()
        return comp
      end
      return comp_factory
    end

    function create_sys(compfilter, callback)
      local entities = create_query(compfilter)
      return function(...)
        for _, ent in pairs(entities) do
          callback(ent, ...)
        end
      end
    end

    function remove_ent(ent)
      entities[ent._id] = nil
      for _, filtered_entities in pairs(queries) do
        filtered_entities[ent._id] = nil
      end
    end

-- | Useful for delaying actions 
-- | until the next turn of the 
-- | update loop. Particularly 
-- | when the action would modify 
-- | a list that's currently being
-- | iterated on such as removing 
-- | an item due to collision, 
-- | or spawning new items.

    function queue(callback)
      add(update_stack, callback)
    end

-- | Must be called at the start of 
-- | each update() before anything else

    function update()
      for callback in all(update_stack) do
        callback()
        del(update_stack, callback)
      end
    end

    return {
      create_ent = create_ent,
      create_comp = create_comp,
      create_sys = create_sys,
      create_quer = create_quer,
      remove_ent = remove_ent,
      queue = queue,
      update = update,
    }
  end
end
-- END pecs P8 ENTITY COMPONENT SYSTEM