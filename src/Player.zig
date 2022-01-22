const w4 = @import("wasm4.zig");
const ground_level = @import("world.zig").ground_level;

const Self = @This();

const peak_y = 32;

x: i32,
y: i32,
vertical_velocity: f32,

pub fn init() Self {
    return Self{ .x = 10, .y = ground_level, .vertical_velocity = 0 };
}

pub fn draw(self: Self) void {
    w4.DRAW_COLORS.* = 0x43;
    w4.oval(self.x, self.y - 16, 8, 16);
}

pub fn update(self: *Self) void {
    self.y = @maximum(@minimum(@floatToInt(i32, @intToFloat(f32, self.y) + self.vertical_velocity), ground_level), peak_y);
    if (self.y < ground_level) {
        self.vertical_velocity += 0.3;
    }
}

pub fn jump(self: *Self) void {
    if (self.y == ground_level) {
        self.vertical_velocity = -5;
        w4.tone(270 | (350 << 16), 10, 100, w4.TONE_MODE2);
    }
}
