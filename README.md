# powder.zig

## Overview

`powder.zig` is a falling sand game with an emphasis on particle interactions and modability.

It's heavily inspired by [The Powder Toy](https://powdertoy.co.uk/), an amazing falling sand game that I highly recommend playing. While I'm not going for an identical Zig port of the original, I will be attempting to implement a few of the main features, namely:

- Gas and fluid dynamics
- Lua scripting
- Temperature

## Modding

Mods can be easily written in Lua to extend the game's functionality.

The game exports a rich API that can be used to control almost every aspect of the simulation.

## Dependencies

- Zig (master)
- SDL2

## Quick Start

```console
$ zig build run
```
