const Element = @import("element.zig").Element;
const Rect = @import("../physics/rect.zig").Rect;
const Vec2 = @import("../physics/vec.zig").Vec2;
const constants = @import("../constants.zig");

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
