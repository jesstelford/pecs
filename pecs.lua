-- pecs ENTITY COMPONENT SYSTEM
-- GITHUB.COM/JESSTELFORD/PECS
-- V2.0.0
-- license: mit COPYRIGHT (C)
-- 2022 jESS tELFORD
--
-- Contributors
-- jesstelford: core maintainer
-- josiebb: reduce tokens, pico8
--   editor support

local pecs do
  local _highest_id = 0

  function cuid()
    _highest_id += 1
    return _highest_id
  end

  local array_same, find, every, assign =

    -- array_same;
    -- O(n) comparison of values
    -- in a table
    function(a, b)
      if (#a ~= #b) return false
      value_hash = {}

      for _, value in pairs(a) do
        value_hash[value] = (value_hash[value] or 0) + 1
      end

      for _, value in pairs(b) do
        value_hash[value] = (value_hash[value] or 0) - 1
      end

      for _, value in pairs(value_hash) do
        if (value ~= 0) return false
      end

      return true
    end,

    -- find
    function(collection, item, compare_func)
      for key, value in pairs(collection) do
        if (compare_func(key, value, item)) return value
      end
      return nil
    end,

    -- every
    function(collection, check_func)
      for key, value in pairs(collection) do
        if (not check_func(value, key, collection)) return false
      end
      return true
    end,

    -- assign
    function(...)
      local result = {}
      local args = { n = select("#", ...), ... }
      for i = 1, args.n do
        if type(args[i]) == "table" then
          for key, value in pairs(args[i]) do
            result[key] = value
          end
        end
      end
      return result
    end

  pecs = function()
    local entities = {}
    local queries = {}
    local systems = {}
    local update_stack = {}

    function query(filter)
      -- filter already exists
      local cached = find(queries, filter, function(a, _, b)
        return array_same(a, b)
      end)

      if (cached ~= nil) return cached

      -- empty to start
      queries[filter] = {}

      -- iterate over all known
      -- entities to populate
      -- the filter
      for _, ent in pairs(entities) do
        if every(filter, function(comp_factory) return ent[comp_factory] end) then
          queries[filter][ent._id] = ent
        end
      end

      return queries[filter]
    end

    function update_filters(ent)

      -- extract out just this
      -- entity's components
      local comps = {}
      for _, comp in pairs(ent) do
        if type(comp) == "table" 
        and comp._comp_factory ~= nil then
          add(comps, comp)
        end
      end

      function has_comp(comp_factory)
        return ent[comp_factory] ~= nil
      end

      -- check and update each
      -- filter
      for filter, entities in pairs(queries) do
        entities[ent._id] = every(filter, has_comp) and ent or nil
      end
    end

    function add_comp(ent, comp)
      -- only ones created by
      -- .component() can be
      -- added.

      assert(comp and comp._comp_factory)

      -- and only once
      assert(not ent[comp._comp_factory])

      -- store the comp keyed by
      -- its factory
      ent[comp._comp_factory] = comp
    end

    function entity(attributes, ...)
      local ent = assign({}, attributes or {})

      ent._id = cuid()

      setmetatable(ent,{
        __add=function(self, comp)
          add_comp(self, comp)

          -- this ent's set of
          -- components has
          -- changed, so we need
          -- to update queries.

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

      if (new_comps > 0) update_filters(ent)
      return ent
    end

    function component(defaults)
      local function comp_factory(attributes)
        local comp = assign({}, defaults, attributes)
        comp._comp_factory = comp_factory
        comp._id = cuid()
        return comp
      end
      return comp_factory
    end

    function system(comp_filter, callback)
      local entities = query(comp_filter)
      return function(...)
        for _, ent in pairs(entities) do
          callback(ent, ...)
        end
      end
    end

    function remove(ent)
      entities[ent._id] = nil
      for _, filtered_entities in pairs(queries) do
        filtered_entities[ent._id] = nil
      end
    end

    function queue(callback)
      add(update_stack, callback)
    end

    -- must be called at the
    -- start of each update()
    -- before anything else
    function update()
      for callback in all(update_stack) do
        callback()
        del(update_stack, callback)
      end
    end

    return {
      entity = entity,
      component = component,
      system = system,
      query = query,
      remove = remove,
      queue = queue,
      update = update,
    }
  end
end
-- END pecs ENTITY COMPONENT SYSTEM
