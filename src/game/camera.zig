const std   = @import("std");
const Input = @import("../input/input.zig").Input;
const za    = @import("zalgebra");
const c     = @import("../c.zig").c;

pub const Camera = struct{
    pitch:     f32,
    yaw:       f32,
    front:     za.Vec3,
    fov:       f16,
    position:  za.Vec3,
    window:    ?*c.SDL_Window,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, window: ?*c.SDL_Window) !*Camera{
        const camera = try allocator.create(Camera);

        camera.allocator = allocator;
        camera.pitch     = 0;
        camera.yaw       = -90;
        camera.fov       = 60;
        camera.front     = za.Vec3.new(0, 0, 0);
        camera.position  = za.Vec3.new(0, 0, 0);
        camera.window    = window;

        return camera;
    }

    pub fn get_view(self: *Camera) za.Mat4{
        return za.Mat4.lookAt(self.position, self.position.add(self.front), za.Vec3.up());
    }

    pub fn get_projection(self: *Camera) za.Mat4{
        var width:  i32 = 0;
        var height: i32 = 0;

        c.SDL_GetWindowSize(self.window, &width, &height);
        c.glViewport(0, 0, width, height);

        return za.Mat4.perspective(self.fov, @as(f32, @floatFromInt(width))/@as(f32, @floatFromInt(height)), 0.1, 1000);
    }

    pub fn deinit(self: *Camera) void{
        self.allocator.destroy(self);
    }
};
