const std = @import("std");
const c = @import("../c.zig").c;

pub const VertexArray = struct{
    id: c.GLuint,

    pub fn init() VertexArray{
        var id: c.GLuint = undefined;

        c.glGenVertexArrays(1, &id);

        return VertexArray{
            .id = id,
        };
    }

    pub fn bind(self: *VertexArray) void{
        c.glBindVertexArray(self.id);
    }

    pub fn deinit(self: *VertexArray) void{
        c.glDeleteVertexArrays(1, &self.id);
    }
};

pub const AllocVertexArray = struct{
    id:        c.GLuint,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*AllocVertexArray{
        const vertex_array = try allocator.create(AllocVertexArray);
        
        var id: c.GLuint = undefined;
        c.glGenVertexArrays(1, &id);
        
        vertex_array.id        = id;
        vertex_array.allocator = allocator;

        return vertex_array;
    }

    pub fn bind(self: *AllocVertexArray) void{
        c.glBindVertexArray(self.id);
    }

    pub fn deinit(self: *AllocVertexArray) void{
        self.allocator.destroy(self);
        c.glDeleteVertexArrays(1, &self.id);
    }
};
