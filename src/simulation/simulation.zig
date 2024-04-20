const std = @import("std");
const constants = @import("../constants.zig");
const Element = @import("element.zig").Element;
const Particle = @import("particle.zig").Particle;
const Vec2 = @import("../physics/vec.zig").Vec2;

pub const Simulation = struct {
    particles: std.ArrayList(Particle),
    gravity: Vec2,

    pub fn spawnParticle(self: *Simulation, element: Element, lifetime: i32, x: f32, y: f32) !void {
        const particle = makeParticle(element, lifetime, x, y);

        try self.particles.append(particle);
    }

    pub fn init(allocator: std.mem.Allocator) !Simulation {
        var particles = std.ArrayList(Particle).init(allocator);

        return Simulation{
            .particles = particles,
            .gravity = Vec2{ .x = 0, .y = constants.GRAVITY },
        };
    }

    pub fn deinit(self: *Simulation) void {
        self.particles.deinit();
    }

    pub fn update(self: *Simulation) void {
        for (self.particles.items) |*particle| {
            particle.applyForce(self.gravity);
            particle.update();
        }
    }
};

fn makeParticle(element: Element, lifetime: i32, x: f32, y: f32) Particle {
    return Particle{
        .element = element,
        .x = x,
        .y = y,
        .vx = 0,
        .vy = 0,
        .lifetime = lifetime,
    };
}
