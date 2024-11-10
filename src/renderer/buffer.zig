const std = @import("std");
const c   = @import("../c.zig").c;

pub const Buffer = struct{
    id: c.GLuint,

    //TODO: Add support for indices
    pub fn init() Buffer{
        var buffer_id: c.GLuint = undefined;

        c.glGenBuffers(1, &buffer_id);

        return Buffer{
            .id = buffer_id,
        };
    }

    pub fn deinit(self: *Buffer) void{
        c.glDeleteBuffers(1, &self.id);
    }

    pub fn bind(self: *Buffer) void{
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.id);
    }

    pub fn buffer_data(self: *Buffer, data_size: usize, data: ?*const anyopaque) void{
        if (data == null)
            @panic("Data in buffer is null");

        self.bind();
        c.glBufferData(c.GL_ARRAY_BUFFER, @as(c_long, @intCast(data_size)), data, c.GL_STATIC_DRAW);
    }
};

pub const AllocBuffer = struct{
    id:        c.GLuint,
    allocator: std.mem.Allocator,

    //TODO: Add support for indices
    pub fn init(allocator: std.mem.Allocator) !*AllocBuffer{
        const buffer = allocator.create(AllocBuffer);

        var buffer_id: c.GLuint = undefined;

        c.glGenBuffers(1, &buffer_id);

        buffer.id = buffer_id;
        buffer.allocator = allocator;

        return buffer;
    }

    pub fn deinit(self: *AllocBuffer) void{
        c.glDeleteBuffers(1, &self.id);
        self.allocator.destroy(self);
    }

    pub fn bind(self: *AllocBuffer) void{
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.id);
    }

    pub fn buffer_data(self: *Buffer, data_size: usize, data: ?*const anyopaque) void{
        if (data == null)
            @panic("Data in buffer is null");

        self.bind();
        c.glBufferData(c.GL_ARRAY_BUFFER, @as(c_long, @intCast(data_size)), data, c.GL_STATIC_DRAW);
    }
};
