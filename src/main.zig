const std = @import("std");
const math = std.math;

const Element = @import("simulation/element.zig").Element;
const sim = @import("simulation/simulation.zig");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
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
var pause = true;

fn makeRect(x: f32, y: f32, w: f32, h: f32) c.SDL_Rect {
    return c.SDL_Rect{ .x = @floatToInt(i32, x), .y = @floatToInt(i32, y), .w = @floatToInt(i32, w), .h = @floatToInt(i32, h) };
}

fn setColor(renderer: *c.SDL_Renderer, color: u32) void {
    const r = @truncate(u8, (color >> (0 * 8)) & 0xFF);
    const g = @truncate(u8, (color >> (1 * 8)) & 0xFF);
    const b = @truncate(u8, (color >> (2 * 8)) & 0xFF);
    const a = @truncate(u8, (color >> (3 * 8)) & 0xFF);
    _ = c.SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

fn render(renderer: *c.SDL_Renderer, simulation: sim.Simulation) void {
    for (simulation.particles.items) |particle| {
        const rect = particle.rect.toSDL();

        setColor(renderer, 0xFFFFFFFF);
        _ = c.SDL_RenderFillRect(renderer, &rect);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer _ = gpa.deinit();

    var simulation = try sim.Simulation.init(allocator);

    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    const window = c.SDL_CreateWindow("powder.zig", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    _ = c.TTF_Init();

    // const _font = c.TTF_OpenFont("res/fonts/KodeMono-Regular.ttf", 24) orelse {
    //     c.SDL_Log("Unable to initialise SDL TTF font: %s", c.SDL_GetError());
    //     return error.SDLInitializationFailed;
    // };

    defer {
        simulation.deinit();

        c.SDL_DestroyRenderer(renderer);
        c.SDL_DestroyWindow(window);
        c.SDL_Quit();
    }

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

        // Brush input
        if (brush_held) {
            var mx: i32 = 0;
            var my: i32 = 0;
            _ = c.SDL_GetMouseState(&mx, &my);

            const x = @intCast(i32, mx);
            const y = @intCast(i32, my);

            var y_offset: i32 = @intCast(i32, brush_radius);

            while (y_offset >= -@intCast(i32, brush_radius)) {
                var x_offset: i32 = -@intCast(i32, brush_radius);

                while (x_offset < @intCast(i32, brush_radius)) {
                    if (x + x_offset < 0 or x + x_offset >= WINDOW_WIDTH or y + y_offset < 0 or y + y_offset >= WINDOW_HEIGHT) {
                        continue;
                    }

                    if (x_offset * x_offset + y_offset * y_offset <= brush_radius * brush_radius) {
                        try simulation.spawnParticle(Element.Sand, @intCast(i32, 1), @intToFloat(f32, x + x_offset), @intToFloat(f32, y + y_offset));
                    }

                    x_offset += 1;
                }

                y_offset -= 1;
            }
        }
        // End brush input

        if (!pause) {
            simulation.update();
        }

        setColor(renderer, BACKGROUND_COLOR);
        _ = c.SDL_RenderClear(renderer);

        render(renderer, simulation);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(1000 / FPS);
    }
}
