<div align="center">
  <br>
  <br>
  <h1>PECS</h1>
  <p>
    <b>A <a href="https://www.lexaloffle.com/pico-8.php">PICO-8</a> <a href="https://en.wikipedia.org/wiki/Entity_component_system">ECS</a> library.</b><br />
  <sup>(Originally based on <a href="https://www.lexaloffle.com/bbs/?uid=45947">KatrinaKitten</a>'s excellent <a href="https://www.lexaloffle.com/bbs/?tid=39021">Tiny ECS Framework v1.1</a>)</sup>
  </p>
  <br>
  <br>
  <br>
</div>

---

## Usage

Everything is part of a _World_. Create one with `createECSWorld()`:

```lua
local world = createECSWorld()
```

_Components_ describe data containers that can be instantiated:

```lua
local Position = world.createComponent()
```

An _Entity_ is a collection of _Components_:

```lua
local player = world.createEntity({ name="Jess" })
```

_Components_ are added to _Entities_ along with initial data:

```lua
player += Position({ x=100, y=0 })
```

All data within an _Entity_ can be accessed as long as you know the _Component_
it belongs to:

```lua
-- Direct access to component data
if player[Position] then
  print(player[Position].x)
end
```

Game logic lives in a _System_ as a function which is called once per _Entity_.
A filter (eg; `{ Position }`) determines the criteria by which entities are
considered part of the _System_.
When the function is called, only matching entities in the world will be passed
to the function.
This ensures performance is maintained when there are many entities.
The function receives any arguments passed when calling the method. Useful for
passing in elapsed time, etc.

```lua
local move = world.createSystem({ Position }, function(entity, ticks)
  entity[Position].x += ticks
end)

-- Run the system method against all matched entities
-- Any args passed will be available in the system callback function
local ticks = 1
move(ticks)
```

## Example

```lua
local world = createECSWorld()
local Position = world.createComponent()
local player = world.createEntity({ name="Jess" })
player += Position({ x=100, y=0 })

local move = world.createSystem({ Position }, function(entity, ticks)
  entity[Position].x += ticks
end)

function _update()
  move(time())
end

function _draw()
  print(player[Position].x, 10, 10, 7)
end
```

## API

To remove a _Component_ from an _Entity_:

```lua
player -= Position
```

To remove an _Entity_ from the _World_:

```lua
world.removeEntity(player)
```
