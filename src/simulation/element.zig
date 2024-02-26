pub const Element = enum {
    Air,
    Sand,
    Stone,

    pub fn color(self: Element) u32 {
        return switch (self) {
            Element.Air => 0x000000,
            Element.Sand => 0xFFFF00,
            Element.Stone => 0x808080,
        };
    }
};
