const Camera = @import("camera.zig").Camera;
const Input  = @import("../input/input.zig").Input;
const za     = @import("zalgebra");
const std    = @import("std");
const c      = @import("../c.zig").c;

pub const CameraManager = struct{
    l_mouse_y: i32,
    l_mouse_x: i32,
    input:     *Input,
    camera:    *Camera,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, input: *Input, camera: *Camera) !*CameraManager{
        const camera_manager = try allocator.create(CameraManager);

        camera_manager.l_mouse_x = input.get_mouse_x();
        camera_manager.l_mouse_y = input.get_mouse_y();
        camera_manager.input     = input;
        camera_manager.camera    = camera;
        camera_manager.allocator = allocator;

        return camera_manager;
    }

    pub fn update(self: *CameraManager) void{
        const d_mouse_x  = @as(f32, @floatFromInt(self.input.get_mouse_x())) - @as(f32 ,@floatFromInt(self.l_mouse_x));
        const d_mouse_y  = @as(f32, @floatFromInt(self.l_mouse_y)) - @as(f32, @floatFromInt(self.input.get_mouse_y()));

        self.camera.yaw   += d_mouse_x;
        self.camera.pitch += d_mouse_y; 

        if (self.camera.pitch > 89.9){ 
            self.camera.pitch = 89.9;
        }else if (self.camera.pitch < -89.9){
            self.camera.pitch = -89.9;
        }

        const x = @cos(za.toRadians(self.camera.pitch)) * @cos(za.toRadians(self.camera.yaw));
        const y = @sin(za.toRadians(self.camera.pitch));
        const z = @sin(za.toRadians(self.camera.yaw)) * @cos(za.toRadians(self.camera.pitch));
        const direction = za.Vec3.new(x, y, z);

        self.camera.front = direction.norm();

        self.l_mouse_x = self.input.get_mouse_x();
        self.l_mouse_y = self.input.get_mouse_y();

        // movement

        if (self.input.is_down(c.SDL_SCANCODE_W)){
            self.camera.position = self.camera.position.add(self.camera.front);
        }

        if (self.input.is_down(c.SDL_SCANCODE_S)){
            self.camera.position = self.camera.position.sub(self.camera.front);
        }

        if (self.input.is_down(c.SDL_SCANCODE_A)){
            self.camera.position = self.camera.position.sub(self.camera.front.cross(za.Vec3.up()).norm());
        }

        if (self.input.is_down(c.SDL_SCANCODE_D)){
            self.camera.position = self.camera.position.add(self.camera.front.cross(za.Vec3.up()).norm());
        }
    }

    pub fn deinit(self: *CameraManager) void{
        self.allocator.destroy(self);
    }
};
