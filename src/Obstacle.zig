const w4 = @import("wasm4.zig");

const Self = @This();

x: i32,

const smiley = [8]u8{
    0b11000011,
    0b10000001,
    0b00100100,
    0b00100100,
    0b00000000,
    0b00100100,
    0b10011001,
    0b11000011,
};

pub fn spawn() Self {
    return Self{.x = 160};
}

pub fn draw(self: Self) void {
    w4.blit(&smiley, self.x, 64, 8, 8, w4.BLIT_1BPP);
}

pub fn updatePosition(self: *Self) void {
    self.x -= 1;
}
