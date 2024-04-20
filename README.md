# powder.zig

## Overview

`powder.zig` is a falling sand game with an emphasis on particle interactions and modability.

It's heavily inspired by [The Powder Toy](https://powdertoy.co.uk/), an amazing falling sand game that I highly recommend playing. While I'm not going for an identical Zig port of the original, I will be attempting to implement a few of the main features, namely:

- Fluid dynamics and gases
- Lua scripting
- Temperature

## Goals
The main aim of the project is to provide a lightweight falling sand engine that can be easily extended through a comprehensive modding API.
In the short term, providing a basic Lua API is a high priority. The main reason for that is that it's relatively simple to implement and it's easy to learn.
Of course, The Powder Toy already has a Lua scripting engine so I'm not really doing anything new - if it ain't broke don't fix it!

Once I have a playable, fun game, I intend to dive deeper into the simulation aspect than other falling sand games usually go.
I want to learn more about fluid dynamics to better simulate liquids and gases, and allow a configurable level of accuracy to enable use all the way from game engines to real-time approximations.

Then there are the "in an ideal world" goals which I might never get to, but would be pretty cool:
- Saving/loading a scene from disk
- Multiplayer
- Distributed physics pipeline
- 3D support
- WASM (get it running in the browser)

## Dependencies

- Zig (master)
- SDL2

## Quick Start

```console
$ zig build run
```
