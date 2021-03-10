-- A PICO-8 Entity Component System (ECS) library
-- License: MIT Copyright (c) 2021 Jess Telford
-- From: https://github.com/jesstelford/pico-8-pecs

-- This "lite" version contains no "System" portion, and reduces token use where
-- possible.
-- Use this if you want to save tokens, or are not using the System or Query
-- aspects of PECS
local createECSWorld do
  local _highestId = 0

  function cuid()
    _highestId += 1
    return _highestId
  end

  function assign(...)
    local result = {}
    local args = { n = select("#", ...), ... }
    for i = 1, args.n do
      if (type(args[i]) == "table") then
        for key, value in pairs(args[i]) do result[key] = value end
      end
    end
    return result
  end

  createECSWorld = function()
    local entities = {}
    local onNextUpdateStack = {}

    function addComponentToEntity(entity, component)
      -- Only components created by createComponent() can be added
      assert(component and component._componentFactory)
      -- And only once
      assert(not entity[component._componentFactory])

      -- Store the component keyed by its factory
      entity[component._componentFactory] = component
    end

    function createEntity(attributes, ...)
      local entity = assign({}, attributes or {})

      entity._id = cuid()

      setmetatable(entity,{
        __add=function(self, component)
          addComponentToEntity(self, component)
          return self
        end,

        __sub=function(self, componentFactory)
          self[componentFactory] = nil
          return self
        end
      })

      for component in all(pack(...)) do
        addComponentToEntity(entity, component)
      end

      entities[entity._id] = entity
      return entity
    end

    function createComponent(defaults)
      local function componentFactory(attributes)
        local component = assign({}, defaults, attributes)
        component._componentFactory = componentFactory
        component._id = cuid()
        return component
      end
      return componentFactory
    end

    function removeEntity(entity)
      entities[entity._id] = nil
    end

    -- Useful for delaying actions until the next turn of the update loop.
    -- Particularly when the action would modify a list that's currently being
    -- iterated on such as removing an item due to collision, or spawning new items.
    function queue(callback)
      add(onNextUpdateStack, callback)
    end

    -- Must be called at the start of each update() before anything else
    function update()
      for callback in all(onNextUpdateStack) do
        callback()
        del(onNextUpdateStack, callback)
      end
    end

    return {
      createEntity=createEntity,
      createComponent=createComponent,
      removeEntity=removeEntity,
      queue=queue,
      update=update,
    }
  end
end
