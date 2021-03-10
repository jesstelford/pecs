<div align="center">
  <br>
  <br>
  <h1>PECS</h1>
  <p>
    <b>A <a href="https://www.lexaloffle.com/pico-8.php">PICO-8</a> <a href="https://en.wikipedia.org/wiki/Entity_component_system">ECS</a> library.</b><br />
  <sup>(Based on <a href="https://www.lexaloffle.com/bbs/?uid=45947">KatrinaKitten</a>'s excellent <a href="https://www.lexaloffle.com/bbs/?tid=39021">Tiny ECS Framework v1.1</a>)</sup>
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
local Velocity = world.createComponent()
```

An _Entity_ is a collection of _Components_:

```lua
local player = world.createEntity({ name="Jess" })
```

_Components_ are added to _Entities_ along with initial data:

```lua
player += Position({ x=10, y=0 })
player += Velocity({ x=0, y=1 })
```

All data within an _Entity_ can be accessed as long as you know the _Component_
it belongs to:

```lua
-- Direct access to component data
if player[Position] then
  print(player[Position].y)
end
```

_Systems_ allow specifying game logic (as a function) which should apply to
_Entities_ that have a certain set of _Components_ (ie; a _filter_).

The game logic function of a _System_ is executed once per matched _Entity_,
ensuring performance is maintained when there are many entities.
The function receives any arguments passed when calling the method. Useful for
passing in elapsed time, etc.

```lua
local move = world.createSystem({ Position, Velocity }, function(entity, ticks)
  entity[Position].x += entity[Velocity].x * ticks
  entity[Position].y += entity[Velocity].y * ticks
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
local Velocity = world.createComponent()

local player = world.createEntity({ name="Jess" })

player += Position({ x=10, y=0 })
player += Velocity({ x=0, y=1 })

local move = world.createSystem({ Position, Velocity }, function(entity, ticks)
  entity[Position].x += entity[Velocity].x * ticks
  entity[Position].y += entity[Velocity].y * ticks
end)

local lastTime = time()
function _update()
  move(time() - lastTime)
  lastTime = time()
end

function _draw()
  cls()
  print(player[Position].x.." "..player[Position].y, 10, 10, 7)
end
```

## API

### `createECSWorld()`

Everything in PECS happens within a world. This must be called once per world
you wish to setup.

Can be called multiple times to create multiple worlds:

```lua
local world1 = createECSWorld()
local world2 = createECSWorld()
```

Each world has its own _Components_ and _Entities_.

### `.createEntity()`

### `.createComponent()`

### `.createSystem()`

### `.removeEntity()`

### `.queue()`

Useful for delaying actions until the next turn of the update loop.
Particularly when the action would modify a list that's currently being iterated
on such as removing an item due to collision, or spawning new items.

### `.update()`

Must be called at the start of each update() before anything else.

### Adding a Component to an Entity

```lua
player += Position
```

### Removing a Component from an Entity

```lua
player -= Position
```

### Removing an Entity from the world

```lua
world.removeEntity(player)
```
