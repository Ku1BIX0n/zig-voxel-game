const c   = @import("../c.zig").c;
const std = @import("std");

pub const Input = struct{
    mouse_x:          i32,
    mouse_y:          i32,
    mouse_state:      u32,
    keyboard_state:   [512]u8,
    l_keyboard_state: [512]u8,
    allocator:        std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Input{
        const input = try allocator.create(Input);
        
        input.mouse_x          = 0;
        input.mouse_y          = 0;
        input.mouse_state      = 0;
        input.l_keyboard_state = [_]u8{0}**512;
        input.allocator        = allocator;

        @memcpy(&input.keyboard_state, @as([*]const u8, c.SDL_GetKeyboardState(null)));

        return input;
    }

    pub fn update(self: *Input) void{
        self.mouse_state = c.SDL_GetMouseState(&self.mouse_x, &self.mouse_y);

        @memcpy(&self.l_keyboard_state, &self.keyboard_state);
        
        @memcpy(&self.keyboard_state, @as([*]const u8, c.SDL_GetKeyboardState(null)));
    }
    
    pub fn get_mouse_x(self: *Input) i32{
        return self.mouse_x;
    }

    pub fn get_mouse_y(self: *Input) i32{
        return self.mouse_y;
    }

    pub fn is_down(self: *Input, scan_code: u8) bool{
        return self.keyboard_state[scan_code] == 1;
    }

    pub fn is_released(self: *Input, scan_code: u8) bool{
        return (self.l_keyboard_state[scan_code] == 1 and self.keyboard_state[scan_code] == 0);
    }

    pub fn deinit(self: *Input) void{
        self.allocator.destroy(self);
    }
};
