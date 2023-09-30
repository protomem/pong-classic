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

        width: i32,
        height: i32,

        speed: i32,

        pub fn init(x: i32, y: i32, width: i32, height: i32) Self {
            return Self{
                .x = x - @divExact(width, 2),
                .y = y - @divExact(height, 2),
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
                    if (self.y <= 0) {
                        speed = 0;
                    }
                    break :upspd -speed;
                },
                .Down => downspd: {
                    var speed = self.speed;
                    if (self.y + self.height >= SCREEN_HEIGHT) {
                        speed = 0;
                    }
                    break :downspd speed;
                },
            };
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

    var leftPuddle = Puddle().init(30, @divExact(SCREEN_HEIGHT, 2), 20, 150);
    var rightPuddle = Puddle().init(SCREEN_WIDTH - 30, @divExact(SCREEN_HEIGHT, 2), 20, 150);

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

        leftPuddle.draw(renderer);
        rightPuddle.draw(renderer);

        defer sdl.SDL_RenderPresent(renderer);
        defer sdl.SDL_Delay(16);
    }
}
