const w4 = @import("wasm4.zig");

pub const ground_level = 71;

pub fn drawGround() void {
    w4.DRAW_COLORS.* = 0x3;
    w4.hline(0, ground_level + 1, 160);
    w4.rect(0, ground_level + 2, 160, 87);
}
