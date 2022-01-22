const w4 = @import("wasm4.zig");
const ground_level = @import("world.zig").ground_level;

const Self = @This();

const obstacle_width = 8;
const obstacle_height = 8;
const obstacle_flags = 0; // BLIT_1BPP
const obstacle = [8]u8{ 0x00, 0x5a, 0x00, 0x5a, 0x00, 0x5a, 0x00, 0x5a };

x: i32,

pub fn spawn() Self {
    return Self{ .x = 160 };
}

pub fn draw(self: Self) void {
    w4.DRAW_COLORS.* = 0x0024;
    w4.blit(&obstacle, self.x, ground_level - obstacle_height + 1, obstacle_width, obstacle_height, obstacle_flags);
}

pub fn updatePosition(self: *Self) void {
    self.x -= 1;
}
