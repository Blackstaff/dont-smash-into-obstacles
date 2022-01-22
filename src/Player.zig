const w4 = @import("wasm4.zig");
const ground_level = @import("world.zig").ground_level;

const Self = @This();

const player_width = 8;
const player_height = 16;
const player_flags = 1; // BLIT_2BPP
const player = [32]u8{ 0x05, 0x50, 0x1a, 0xa4, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0x19, 0x6a, 0x19, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0x59, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0xa9, 0x1a, 0xa4, 0x05, 0x50 };
const player_dead = [32]u8{ 0x05, 0x50, 0x1a, 0xa4, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0x49, 0x6a, 0x19, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0x59, 0x6a, 0x59, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0xa9, 0x6a, 0xa9, 0x1a, 0xa4, 0x05, 0x50 };

const PlayerState = enum { running, dead };

const peak_y = 32;

x: i32,
y: i32,
vertical_velocity: f32,
state: PlayerState,

pub fn init() Self {
    return Self{ .x = 10, .y = ground_level, .vertical_velocity = 0, .state = .running };
}

pub fn draw(self: Self) void {
    w4.DRAW_COLORS.* = 0x0240;
    var sprite: [*]const u8 = undefined;
    if (self.state == .dead) {
        sprite = &player_dead;
    } else {
        sprite = &player;
    }
    w4.blit(sprite, self.x, self.y - player_height + 1, player_width, player_height, player_flags);
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

pub fn hitObstacle(self: *Self) void {
    self.state = .dead;
}
