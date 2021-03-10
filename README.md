<div align="center">
  <br>
  <h1>PECS</h1>
  <p>
    <b>A <a href="https://www.lexaloffle.com/pico-8.php">PICO-8</a> <a href="https://en.wikipedia.org/wiki/Entity_component_system">Entity Component System (ECS)</a> library.</b><br />
  <sup>(Based on <a href="https://www.lexaloffle.com/bbs/?uid=45947">KatrinaKitten</a>'s excellent <a href="https://www.lexaloffle.com/bbs/?tid=39021">Tiny ECS Framework v1.1</a>)</sup>
  </p>
  <br>
  <br>
</div>

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

An _Entity_ is a collection of instantiated _Components_.

```lua
local player = world.createEntity()
player += Position({ x=10, y=0 })
player += Velocity({ x=0, y=1 })
```

All data within an _Entity_ can be accessed as long as you know the _Component_
it belongs to:

```lua
print(player[Position].x, 10, 10, 7)
```

_Systems_ allow specifying game logic (as a function) which applies to
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

### `createECSWorld() => World`

Everything in PECS happens within a world.

Can be called multiple times to create multiple worlds:

```lua
local world1 = createECSWorld()
local world2 = createECSWorld()
```

Each world has its own _Components_ and _Entities_.

#### `World#update()`

Must be called at the start of each `_update()` before anything else.

#### `World#createEntity([attr[, Component, ...]]) => Entity`

```lua
local player = world.createEntity()

local trap = world.createEntity({ type="spikes" })

local enemy = world.createEntity({}, Position({ x=10, y=10 }), Rotation({ angle=45 })
```

##### Adding a Component to an Entity

```lua
player += Position({ x=100, y=20 })
```

##### Removing a Component from an Entity

```lua
player -= Position
```

#### `World#createComponent([defaults]) => Component`

```lua
local Position = world.createComponent()

local Drawable = world.createComponent({ color: 8 })
```

#### `World#createSystem(filter, callback) => Function`

Where `filter` is a table of Components, and `callback` is a function that's
passed the entity to operate on.

Returns a function that when called will execute the `callback` once per Entity
that contains all the specified Components.

When executing the function, any parameters are passed through to the
`callback`.

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

Systems efficiently maintain a list of filtered entities that is only updated
when needed. It is safe to create many systems that operate over large lists of
Entities (within PICO-8's limits).

#### `World#removeEntity(Entity)`

Remove the given entity from the world.

Any Systems which previously matched this entity will no longer operate on it.

#### `World#queue(Function)`

Useful for delaying actions until the next turn of the update loop.
Particularly when the action would modify a list that's currently being iterated
on such as removing an item due to collision, or spawning new items.
