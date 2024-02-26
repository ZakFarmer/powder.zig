const Element = @import("element.zig").Element;
const Vec2 = @import("../physics/vec.zig").Vec2;

pub const Particle = struct {
    element: Element,
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,

    pub fn applyForce(self: *Particle, force: Vec2) void {
        self.vx += force.x;
        self.vy += force.y;
    }

    pub fn update(self: *Particle) void {
        const vx = self.vx;
        const vy = self.vy;

        const x = self.x + vx;
        const y = self.y + vy;

        self.x = x;
        self.y = y;
    }
};
