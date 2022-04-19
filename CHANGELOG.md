# PECS

## 2.0.0

### Major Changes

- [](): Renamed most API methods to be lowercase and fewer characters. This
  improves the ergonomics when developing within the PICO-8 code editor:

  - `createECSworld()` -> `pecs()`
  - `.createComponent()` -> `.component()`
  - `.createEntity()` -> `.entity()`
  - `.createSystem()` -> `.system()`
  - `.createQuery()` -> `.query()`
  - `.removeEntity()` -> `.remove()`

- [](): Removed the "lite" version (`pecs-lite.lua`); Systems are a core piece
  of ECS, and should be embraced.

- [](): Shaved some tokens.

## 1.1.1

### Patch Changes

- [`783fd8b`](https://github.com/jesstelford/pecs/commit/783fd8b): Added an
  example: A particle emitter which shows off the way to think in Components &
  Systems. See [`example/particles.p8`](./example/particles.p8).

## 1.1.0

### Minor Changes

- [`da35247`](https://github.com/jesstelford/pecs/commit/da35247): Added a
  "lite" version without System support
- [`a295dc6`](https://github.com/jesstelford/pecs/commit/a295dc6): Shaved off 99
  tokens (3 for "lite")

## 1.0.0

Initial Release
