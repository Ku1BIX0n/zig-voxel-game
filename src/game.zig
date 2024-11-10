const c             = @import("c.zig").c;
const std           = @import("std");
const Renderer      = @import("renderer/renderer.zig").Renderer;
const Input         = @import("input/input.zig").Input;
const CameraManager = @import("game/camera_manager.zig").CameraManager;
const Camera        = @import("game/camera.zig").Camera;
const Octree        = @import("game/octree.zig").Octree;

const OCTR_SIZE: f32 = 16;

pub const Game = struct{
    window:         ?*c.SDL_Window,
    renderer:       *Renderer,
    input:          *Input,
    camera:         *Camera,
    camera_manager: *CameraManager,
    octree:         *Octree,
    allocator:      std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer, window: ?*c.SDL_Window) !*Game{
        const game = try allocator.create(Game);

        game.window         = window;
        game.renderer       = renderer;
        game.camera         = try Camera.init(allocator, window);
        game.input          = try Input.init(allocator);
        game.camera_manager = try CameraManager.init(allocator, game.input, game.camera);
        game.octree         = try Octree.init(allocator);
        game.allocator      = allocator;

        const size = 120;

        for (0..size) |x|{
            for (0..size) |y|{
                for (0..size) |z|{
                    const fx = @as(f32, @floatFromInt(x))/4-16;
                    const fy = @as(f32, @floatFromInt(y))/4-16;
                    const fz = @as(f32, @floatFromInt(z))/4-16;

                    try game.octree.root.insert(fx, fy, fz);
                }
            }
        }

        return game;
    }

    pub fn deinit(self: *Game) void{
        self.octree.deinit();
        self.camera.deinit();
        self.camera_manager.deinit();
        self.input.deinit();
        self.renderer.deinit();
        self.allocator.destroy(self);
    }
};
