const std = @import("std");
const math = std.math;

const Element = @import("element.zig").Element;
const Particle = @import("particle.zig").Particle;

const coords_to_index = @import("grid.zig").coords_to_index;
const init_grid = @import("grid.zig").init_grid;
const insert_particles_in_radius = @import("grid.zig").insert_particles_in_radius;

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const overlaps = c.SDL_HasIntersection;

const FPS = 60;
const DELTA_TIME_SEC: f32 = 1.0 / @intToFloat(f32, FPS);
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

fn update(grid: *[WINDOW_WIDTH * WINDOW_HEIGHT]Particle) void {
    if (!pause) {
        if (brush_held) {
            var mx: i32 = 0;
            var my: i32 = 0;
            _ = c.SDL_GetMouseState(&mx, &my);
            const x = @intCast(u32, mx);
            const y = @intCast(u32, my);

            insert_particles_in_radius(grid, x, y, Element.Sand, brush_radius);
        }

        var i: usize = grid.len;

        while (i > 0) {
            i -= 1;

            if (grid[i].element == Element.Air) {
                continue;
            }

            const below_i = i + WINDOW_WIDTH;
            const y = i / WINDOW_WIDTH;

            if (y < WINDOW_HEIGHT - 1 and grid[below_i].element == Element.Air) {
                grid[below_i].element = grid[i].element;
                grid[i].element = Element.Air;
            }
        }
    }
}

fn render(renderer: *c.SDL_Renderer, grid: [WINDOW_WIDTH * WINDOW_HEIGHT]Particle) void {
    set_color(renderer, PART_COLOR);

    for (grid) |particle, index| {
        if (particle.element == Element.Air) {
            continue;
        }

        const x = @intToFloat(f32, index % WINDOW_WIDTH);
        const y = @intToFloat(f32, index / WINDOW_WIDTH);

        _ = c.SDL_RenderFillRect(renderer, &make_rect(x, y, PART_SIZE, PART_SIZE));
    }
}

pub fn main() !void {
    var grid = init_grid();

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
            switch (event.@"type") {
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

        update(&grid);

        set_color(renderer, BACKGROUND_COLOR);
        _ = c.SDL_RenderClear(renderer);

        render(renderer, grid);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(1000 / FPS);
    }
}
