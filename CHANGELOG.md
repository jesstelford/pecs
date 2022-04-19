# PECS

## 2.0.0

### Major Changes

- [9c26ecf](https://github.com/jesstelford/pecs/commit/9c26ecf): Renames most methods of the PECS api to be single word lowercase. This greatly increases the usability when coding in the PICO-8 editor (inspired by @josiebb's changes in #1 - thanks!):

  - `createECSworld()` -> `pecs()`
  - `.createComponent()` -> `.component()`
  - `.createEntity()` -> `.entity()`
  - `.createSystem()` -> `.system()`
  - `.createQuery()` -> `.query()`
  - `.removeEntity()` -> `.remove()`

- [9c26ecf](https://github.com/jesstelford/pecs/commit/9c26ecf): Remove `pecs-lite.lua`. PECS "lite" reduced the token count by removing queries & system susport. However, this effectively neuters the library, making it fairly pointless. Therefore, I've removed the "lite" version completely, which also makes maintenance easier for me.

### Minor Changes

- [9c26ecf](https://github.com/jesstelford/pecs/commit/9c26ecf): Reduce token count by 9 to 567 (thanks @josiebb!)

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
