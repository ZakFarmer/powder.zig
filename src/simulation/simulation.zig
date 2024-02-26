const std = @import("std");
const constants = @import("../constants.zig");
const Element = @import("element.zig").Element;
const Particle = @import("particle.zig").Particle;
const Vec2 = @import("../physics/vec.zig").Vec2;

pub const Simulation = struct {
    particles: []Particle,
    gravity: Vec2,

    pub fn init() Simulation {
        var particles = [_]Particle{makeParticle(Element.Sand, 50.0, 50.0)} ** 10;

        return Simulation{
            .particles = &particles,
            .gravity = Vec2{ .x = 0, .y = 0 },
        };
    }

    pub fn update(self: *Simulation) void {
        for (self.particles) |*particle| {
            std.debug.print("Particle: {d}\n", .{particle.x});
            // particle.applyForce(self.gravity);
            // particle.update();
        }
    }
};

fn makeParticle(element: Element, x: f32, y: f32) Particle {
    return Particle{
        .element = element,
        .x = x,
        .y = y,
        .vx = 0,
        .vy = 0,
    };
}
