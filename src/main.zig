const std = @import("std");
const sdl = @cImport(@cInclude("SDL2/SDL.h"));

const SCREEN_WIDTH = 1200;
const SCREEN_HEIGHT = 700;

const Direction = enum {
    Up,
    Down,
};

pub fn Puddle() type {
    return struct {
        const Self = @This();

        x: i32,
        y: i32,

        top: i32,
        bottom: i32,

        width: i32,
        height: i32,

        speed: i32,

        pub fn init(x: i32, y: i32, top: i32, bottom: i32, width: i32, height: i32) Self {
            return Self{
                .x = x - @divTrunc(width, 2),
                .y = y - @divTrunc(height, 2),
                .top = top,
                .bottom = bottom,
                .width = width,
                .height = height,
                .speed = 10,
            };
        }

        pub fn draw(self: Self, renderer: ?*sdl.SDL_Renderer) void {
            const rect = sdl.SDL_Rect{
                .x = self.x,
                .y = self.y,
                .w = self.width,
                .h = self.height,
            };

            _ = sdl.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            _ = sdl.SDL_RenderFillRect(renderer, &rect);
        }

        pub fn move(self: *Self, direction: Direction) void {
            self.y += switch (direction) {
                .Up => upspd: {
                    var speed = self.speed;
                    if (self.y <= self.top) {
                        speed = 0;
                    }
                    break :upspd -speed;
                },
                .Down => downspd: {
                    var speed = self.speed;
                    if (self.y + self.height >= self.bottom) {
                        speed = 0;
                    }
                    break :downspd speed;
                },
            };
        }
    };
}

pub fn Border() type {
    return struct {
        const Self = @This();

        x: i32,
        y: i32,

        width: i32,
        height: i32,

        pub fn init(x: i32, y: i32, width: i32, height: i32) Self {
            return Self{
                .x = x - @divTrunc(width, 2),
                .y = y - @divTrunc(height, 2),
                .width = width,
                .height = height,
            };
        }

        pub fn draw(self: Self, renderer: ?*sdl.SDL_Renderer) void {
            const rect = sdl.SDL_Rect{
                .x = self.x,
                .y = self.y,
                .w = self.width,
                .h = self.height,
            };

            _ = sdl.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            _ = sdl.SDL_RenderFillRect(renderer, &rect);
        }
    };
}

pub fn Marking() type {
    return struct {
        const Self = @This();

        x: i32,
        y: i32,

        width: i32,
        height: i32,

        num_rects: usize,
        gap: usize,

        pub fn init(x: i32, y: i32, width: i32, height: i32, num_rects: usize, gap: usize) Self {
            return Self{
                .x = x - @divTrunc(width, 2),
                .y = y - @divTrunc(height, 2),
                .width = width,
                .height = height,
                .num_rects = num_rects,
                .gap = gap,
            };
        }

        pub fn draw(self: Self, renderer: ?*sdl.SDL_Renderer) void {
            const height = @divTrunc(self.height - @as(i32, @intCast(self.gap * (self.num_rects - 1))), @as(i32, @intCast(self.num_rects)));

            _ = sdl.SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
            for (0..self.num_rects) |i| {
                const y = self.y + ((height + @as(i32, @intCast(self.gap))) * @as(i32, @intCast(i)));

                const rect = sdl.SDL_Rect{
                    .x = self.x,
                    .y = y,
                    .w = self.width,
                    .h = height,
                };

                _ = sdl.SDL_RenderFillRect(renderer, &rect);
            }
        }
    };
}

pub fn main() !void {
    _ = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "Ping Pong Classic",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH,
        SCREEN_HEIGHT,
        sdl.SDL_WINDOW_SHOWN,
    );
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(
        window,
        -1,
        sdl.SDL_RENDERER_PRESENTVSYNC,
    );
    defer sdl.SDL_DestroyRenderer(renderer);

    var borderTop = Border().init(@divTrunc(SCREEN_WIDTH, 2), @divTrunc(30, 2), SCREEN_WIDTH, 30);
    var borderBottom = Border().init(@divTrunc(SCREEN_WIDTH, 2), SCREEN_HEIGHT - @divTrunc(30, 2), SCREEN_WIDTH, 30);

    var marking = Marking().init(@divTrunc(SCREEN_WIDTH, 2), @divTrunc(SCREEN_HEIGHT, 2), 20, SCREEN_HEIGHT - (30 * 2), 10, 20);

    var leftPuddle = Puddle().init(30, @divTrunc(SCREEN_HEIGHT, 2), borderTop.y + borderTop.height, borderBottom.y, 20, 150);
    var rightPuddle = Puddle().init(SCREEN_WIDTH - 30, @divTrunc(SCREEN_HEIGHT, 2), borderTop.y + borderTop.height, borderBottom.y, 20, 150);

    var running = true;
    while (running) {
        var event = sdl.SDL_Event{ .type = 0 };
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => running = false,
                else => {},
            }
        }

        var keyboard = sdl.SDL_GetKeyboardState(null);
        if (keyboard[sdl.SDL_SCANCODE_W] != 0) {
            leftPuddle.move(.Up);
        }
        if (keyboard[sdl.SDL_SCANCODE_S] != 0) {
            leftPuddle.move(.Down);
        }
        if (keyboard[sdl.SDL_SCANCODE_UP] != 0) {
            rightPuddle.move(.Up);
        }
        if (keyboard[sdl.SDL_SCANCODE_DOWN] != 0) {
            rightPuddle.move(.Down);
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00); // Black color
        _ = sdl.SDL_RenderClear(renderer);

        defer sdl.SDL_RenderPresent(renderer);
        defer sdl.SDL_Delay(16);

        borderTop.draw(renderer);
        borderBottom.draw(renderer);

        marking.draw(renderer);

        leftPuddle.draw(renderer);
        rightPuddle.draw(renderer);
    }
}
