const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

pub const Rect = struct {
    left: f32,
    top: f32,
    width: f32,
    height: f32,

    pub fn getRight(self: *Rect) f32 {
        return self.left + self.width;
    }

    pub fn getBottom(self: *Rect) f32 {
        return self.top + self.height;
    }

    pub fn getTopLeft(self: *Rect) struct { x: f32, y: f32 } {
        return .{ 
            .x = self.left,
            .y = self.top,
        };
    }

    pub fn setTopLeft(self: *Rect, topLeft: struct { x: f32, y: f32 }) void {
        self.left = topLeft.x;
        self.top = topLeft.y;
    }

    pub fn getCenter(self: *Rect) struct { x: f32, y: f32 } {
        return .{ self.left + self.width / 2, self.top + self.height / 2 };
    }

    pub fn getSize(self: *Rect) struct { x: f32, y: f32 } {
        return .{ self.width, self.height };
    }

    pub fn contains(self: *Rect, rect: Rect) bool {
        return self.left <= rect.left and
            self.getRight() >= rect.getRight() and
            self.top <= rect.top and
            self.getBottom() >= rect.getBottom();
    }

    pub fn intersects(self: *Rect, rect: Rect) bool {
        return self.left < rect.getRight() and
            self.getRight() > rect.left and
            self.top < rect.getBottom() and
            self.getBottom() > rect.top;
    }

    // fn makeRect(x: f32, y: f32, w: f32, h: f32) c.SDL_Rect {
    //     return c.SDL_Rect{ .x = @floatToInt(i32, x), .y = @floatToInt(i32, y), .w = @floatToInt(i32, w), .h = @floatToInt(i32, h) };
    // }

    pub fn toSDL(self: *const Rect) c.SDL_Rect {
        return c.SDL_Rect {
            .x = @floatToInt(i32, self.left),
            .y = @floatToInt(i32, self.top),
            .w = @floatToInt(i32, self.width),
            .h = @floatToInt(i32, self.height),
        };
    }
};
