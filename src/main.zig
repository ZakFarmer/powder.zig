const std = @import("std");
const math = std.math;

const sim = @import("simulation/simulation.zig");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const overlaps = c.SDL_HasIntersection;

const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @floatCast(f32, FPS);

pub const WINDOW_WIDTH = 800;
pub const WINDOW_HEIGHT = 600;

const BACKGROUND_COLOR = 0xFF181818;

const PART_COLOR = 0xFFFFFFFF;
const PART_SIZE: f32 = 1;

var brush_held: bool = false;
var brush_radius: u32 = 5;

var quit = false;
var pause = false;

fn make_rect(x: f32, y: f32, w: f32, h: f32) c.SDL_Rect {
    return c.SDL_Rect{ .x = @floatToInt(i32, x), .y = @floatToInt(i32, y), .w = @floatToInt(i32, w), .h = @floatToInt(i32, h) };
}

fn set_color(renderer: *c.SDL_Renderer, color: u32) void {
    const r = @truncate(u8, (color >> (0 * 8)) & 0xFF);
    const g = @truncate(u8, (color >> (1 * 8)) & 0xFF);
    const b = @truncate(u8, (color >> (2 * 8)) & 0xFF);
    const a = @truncate(u8, (color >> (3 * 8)) & 0xFF);
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

fn render(renderer: *c.SDL_Renderer, simulation: sim.Simulation) void {
    var i: usize = 0;

    while (i < simulation.particles.len) {
        const particle = simulation.particles[i];

        // std.debug.print("Particle: {d} {d}\n", .{particle.x, particle.y});

        set_color(renderer, 0xFFFFFFFF);
        _ = c.SDL_RenderFillRect(renderer, &make_rect(particle.x, particle.y, PART_SIZE, PART_SIZE));

        i += 1;
    }
}

pub fn main() !void {
    var simulation = sim.Simulation.init();

    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("powder.zig", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    // const keyboard = c.SDL_GetKeyboardState(null);

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_MOUSEBUTTONDOWN => switch (event.button.button) {
                    c.SDL_BUTTON_LEFT => {
                        brush_held = true;
                    },
                    else => {},
                },
                c.SDL_MOUSEBUTTONUP => switch (event.button.button) {
                    c.SDL_BUTTON_LEFT => {
                        brush_held = false;
                    },
                    else => {},
                },
                c.SDL_KEYDOWN => switch (event.key.keysym.sym) {
                    ' ' => {
                        pause = !pause;
                    },
                    else => {},
                },
                else => {},
            }
        }

        simulation.update();

        set_color(renderer, BACKGROUND_COLOR);
        _ = c.SDL_RenderClear(renderer);

        render(renderer, simulation);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(1000 / FPS);
    }
}
