const Element = @import("element.zig").Element;
const Rect = @import("../physics/rect.zig").Rect;
const Vec2 = @import("../physics/vec.zig").Vec2;
const constants = @import("../constants.zig");
const std = @import("std");

pub const Particle = struct {
    element: Element,
    /// The particle's X velocity.
    vx: f32,
    /// The particle's Y velocity.
    vy: f32,
    /// The particle's rectangular bounding box.
    rect: Rect,
    /// The number of frames the particle should live for.
    /// A lifetime of -1 means the particle should live forever.
    lifetime: i32,

    pub fn applyForce(self: *Particle, force: Vec2) void {
        self.vx += force.x;
        self.vy += force.y;
    }

    test "applyForce should add the force to the particle's velocity" {
        var particle = Particle{
            .element = Element{ .x = 0, .y = 0, .width = 0, .height = 0 },
            .vx = 0,
            .vy = 0,
            .rect = Rect{ .left = 0, .top = 0, .width = 0, .height = 0 },
            .lifetime = 0,
        };

        particle.applyForce(Vec2 { .x = 1, .y = 2 });

        try std.testing.expect(particle.vx == 1);
        try std.testing.expect(particle.vy == 2);
    }

    pub fn update(self: *Particle) void {
        const topLeft = self.rect.getTopLeft();

        if (self.lifetime > 0) {
            self.lifetime -= 1;
        }

        if (topLeft.x < 0 or topLeft.x > constants.WINDOW_WIDTH) {
            self.vx = -self.vx * constants.RESTITUTION;
        }

        if (topLeft.y < 0 or topLeft.y > constants.WINDOW_HEIGHT) {
            self.vy = -self.vy * constants.RESTITUTION;
        }

        const vx = self.vx;
        const vy = self.vy;

        const x = topLeft.x + vx;
        const y = topLeft.y + vy;

        self.rect.left = x;
        self.rect.top = y;
    }
};