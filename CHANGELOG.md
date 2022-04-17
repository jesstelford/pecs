# PECS

## 2.0.0

### Major Changes

- [](): Made the API more friendly to use within PICO-8 by removing capital
  letters and shortening method names:

  - `createECSworld()` -> `.pecs()`
  - `.createComponent()` -> `.component()`
  - `.createEntity()` -> `.entity()`
  - `.createSystem()` -> `.system()`
  - `.createQuery()` -> `.query()`
  - `.removeEntity()` -> `.remove()`

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
