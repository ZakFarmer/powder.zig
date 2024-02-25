const Element = @import("element.zig").Element;
const Particle = @import("particle.zig").Particle;

const WINDOW_HEIGHT = @import("main.zig").WINDOW_HEIGHT;
const WINDOW_WIDTH = @import("main.zig").WINDOW_WIDTH;

pub fn coords_to_index(x: u32, y: u32) usize {
    return y * WINDOW_WIDTH + x;
}

pub fn init_grid() [WINDOW_WIDTH * WINDOW_HEIGHT]Particle {
    var new_grid: [WINDOW_WIDTH * WINDOW_HEIGHT]Particle = undefined;
    for (new_grid) |*cell| {
        cell.* = Particle{ .element = Element.Air };
    }

    new_grid[coords_to_index(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)] = Particle{ .element = Element.Sand };

    return new_grid;
}

pub fn insert_particle(grid: []Particle, x: u32, y: u32, element: Element) void {
    grid[coords_to_index(x, y)] = Particle{ .element = element };
}

pub fn insert_particles_in_radius(grid: []Particle, _x: u32, _y: u32, element: Element, radius: u32) void {
    const x = @intCast(i32, _x);
    const y = @intCast(i32, _y);

    var y_offset: i32 = @intCast(i32, radius);

    while (y_offset >= -@intCast(i32, radius)) {
        var x_offset: i32 = -@intCast(i32, radius);
        while (x_offset < @intCast(i32, radius)) {
            if (x + x_offset < 0 or x + x_offset >= WINDOW_WIDTH or y + y_offset < 0 or y + y_offset >= WINDOW_HEIGHT) {
                continue;
            }
            if (x_offset * x_offset + y_offset * y_offset <= radius * radius) {
                insert_particle(grid, @intCast(u32, x + x_offset), @intCast(u32, y + y_offset), element);
            }
            x_offset += 1;
        }
        y_offset -= 1;
    }
}
