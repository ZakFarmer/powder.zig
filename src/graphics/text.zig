const c = @cImport({
    @cInclude("SDL2/SDL.h"),
    @cInclude("SDL2/SDL_ttf.h"),
});

pub fn drawText(renderer: *c.SDL_Renderer, x: f32, y: f32, text: []const u8, font: c.TTF_Font, texture: c.SDL_Texture, rect: c.SDL_Rect) void {
    var textWidth: i32 = 0;
    var textHeight: i32 = 0;

    const surface = c.TTF_RenderText_Solid(font, text, c.SDL_Color{255, 255, 255, 255});
    const texture = c.SDL_CreateTextureFromSurface(renderer, surface);

    textWidth = surface->w;
    textHeight = surface->h;

    SDL_FreeSurface(surface);
}
