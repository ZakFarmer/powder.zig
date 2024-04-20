const Element = @import("element.zig").Element;
const Vec2 = @import("../physics/vec.zig").Vec2;

pub const Particle = struct {
    element: Element,
    /// The particle's X position.
    x: f32,
    /// The particle's Y position.
    y: f32,
    /// The particle's X velocity.
    vx: f32,
    /// The particle's Y velocity.
    vy: f32,
    /// The number of frames the particle should live for.
    /// A lifetime of -1 means the particle should live forever.
    lifetime: i32,

    pub fn applyForce(self: *Particle, force: Vec2) void {
        self.vx += force.x;
        self.vy += force.y;
    }

    pub fn update(self: *Particle) void {
        if (self.lifetime > 0) {
            self.lifetime -= 1;
        }

        const vx = self.vx;
        const vy = self.vy;

        const x = self.x + vx;
        const y = self.y + vy;

        self.x = x;
        self.y = y;
    }
};
