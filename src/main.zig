const std = @import("std");
const w4 = @import("wasm4.zig");
const world = @import("world.zig");
const Player = @import("Player.zig");
const Obstacle = @import("Obstacle.zig");

const GameState = enum { title, running, game_over };

var buffer: [1000]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;

var frame_count: u32 = 0;
var player: Player = undefined;
var obstacles: std.BoundedArray(Obstacle, 40) = undefined;
var prev_state: u8 = 0;
var current_game_state: GameState = undefined;
var score: u32 = 0;

export fn start() void {
    w4.PALETTE.* = .{
        0xe0f8cf,
        0xe5b083,
        0x306850,
        0x071821,
    };

    prng = std.rand.DefaultPrng.init(0);
    random = prng.random();

    player = Player.init();
    obstacles = std.BoundedArray(Obstacle, 40).init(0) catch @panic("couldn't init obstacles array");
    current_game_state = .title;
}

fn startGame() void {
    prng = std.rand.DefaultPrng.init(frame_count);
    random = prng.random();
    current_game_state = .running;
}

export fn update() void {
    frame_count +%= 1;
    processInput();
    if (current_game_state == .running) {
        player.update();
        updateObstacles();
        if (findCollision()) {
            current_game_state = .game_over;
            w4.tone(620 | (140 << 16), (10 << 24) | 24, 100, w4.TONE_MODE2);
        }
        if (frame_count % 60 == 0) score += 1;
    }
    draw();
}

fn processInput() void {
    const gamepad = w4.GAMEPAD1.*;
    const just_pressed = gamepad & (gamepad ^ prev_state);

    if (current_game_state == .running and just_pressed & w4.BUTTON_UP != 0) {
        player.jump();
    }

    if (current_game_state == .title and just_pressed != 0) {
        startGame();
    }
    if (current_game_state == .game_over and just_pressed & (w4.BUTTON_1 | w4.BUTTON_2) != 0) {
        reset();
    }

    prev_state = gamepad;
}

fn updateObstacles() void {
    if (frame_count % 2 == 0) {
        for (obstacles.slice()) |*obstacle| {
            obstacle.updatePosition();
        }
    }
    for (obstacles.constSlice()) |*obstacle| {
        if (obstacle.x <= -9) {
            _ = obstacles.orderedRemove(0);
        }
    }
    handleObstacleSpawning();
}

fn handleObstacleSpawning() void {
    if (frame_count % 40 == 0) {
        if (random.intRangeLessThan(u8, 0, 100) <= 30) {
            var obstacle = Obstacle.spawn();
            obstacles.append(obstacle) catch @panic("couldn't append obstacle");
        }
    }
}

fn findCollision() bool {
    const obstacle = fetchClosestObstacle();
    if (obstacle == null) return false;
    const x_interlap = std.math.absInt(obstacle.?.x - player.x) catch @panic("int overflow");
    const y_interlap = std.math.absInt(player.y - world.ground_level) catch @panic("int overflow");
    if (x_interlap < 8 and y_interlap < 8) return true;
    return false;
}

fn fetchClosestObstacle() ?Obstacle {
    for (obstacles.constSlice()) |obstacle| {
        if (obstacle.x >= player.x) return obstacle;
    }
    return null;
}

fn draw() void {
    if (current_game_state == .title) {
        drawTitle();
    }

    if (current_game_state != .title) {
        w4.DRAW_COLORS.* = 0x3;
        //ground
        w4.hline(0, 72, 160);
        w4.rect(0, 73, 160, 87);

        drawScore();
        drawObstacles();
        player.draw();

        if (current_game_state == .game_over) {
            drawGameOver();
        }
    }
}

fn drawTitle() void {
    w4.DRAW_COLORS.* = 0x0004;
    w4.text("Press any button", 15, 50);
    w4.text("to start", 45, 60);
}

fn drawObstacles() void {
    w4.DRAW_COLORS.* = 0x3;
    for (obstacles.constSlice()) |obstacle| {
        obstacle.draw();
    }
}

fn drawScore() void {
    w4.DRAW_COLORS.* = 0x0004;
    w4.text("Score:", 80, 1);
    const score_string = std.fmt.allocPrint(
        allocator,
        "{d}",
        .{score},
    ) catch @panic("can't print score");
    defer allocator.free(score_string);
    w4.text(score_string, 130, 1);
}

fn drawGameOver() void {
    w4.DRAW_COLORS.* = 0x0044;
    w4.rect(0, 20, 160, 30);
    w4.DRAW_COLORS.* = 0x0001;
    w4.text("Game Over", 45, 30);
}

fn reset() void {
    prng = std.rand.DefaultPrng.init(frame_count);
    random = prng.random();

    player = Player.init();
    obstacles = std.BoundedArray(Obstacle, 40).init(0) catch @panic("couldn't init obstacles array");
    score = 0;
    current_game_state = .running;
}
