const std   = @import("std");
const c     = @import("../c.zig").c;
const za    = @import("zalgebra");

fn compile_shader(allocator: std.mem.Allocator, path: []const u8, shader_type: c.GLenum) !u32{
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();

    var shader_source = try allocator.alloc(u8, file_size);
    defer allocator.free(shader_source);

    _ = try file.readAll(shader_source);

    const shader = c.glCreateShader(shader_type);
    c.glShaderSource(shader, 1, &shader_source.ptr, null);
    c.glCompileShader(shader);

    var success: c.GLint = 0;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS , &success);

    if (success == 0){
        var info_log: c.GLchar = undefined;
        c.glGetShaderInfoLog(shader, 512, null, &info_log);
        std.debug.print("Shader Compilation Failed: {any}", .{info_log});
    }

    return shader;
}

pub const Shader = struct{
    program_id: u32,

    pub fn init(allocator: std.mem.Allocator, vertex_path: []const u8, fragment_path: []const u8) !Shader{
        const vertex_shader = try compile_shader(allocator, vertex_path, c.GL_VERTEX_SHADER);
        const fragment_shader = try compile_shader(allocator, fragment_path, c.GL_FRAGMENT_SHADER);

        const program_id = c.glCreateProgram();
        c.glAttachShader(program_id, vertex_shader);
        c.glAttachShader(program_id, fragment_shader);
        c.glLinkProgram(program_id);

        var success: c.GLint = 0;
        c.glGetProgramiv(program_id, c.GL_LINK_STATUS , &success);

        if (success == 0){
            var info_log: [512]u8 = [_]u8{0} ** 512;
            c.glGetProgramInfoLog(program_id, 512, 0, &info_log[0]);
            std.debug.print("Program Compilation Failed: {s}\n", .{&info_log[0]});
        }

        c.glDeleteShader(vertex_shader);
        c.glDeleteShader(fragment_shader);

        if (program_id == 0)
            @panic("Failed to create a shader");

        return Shader{
            .program_id = program_id
        };
    }

    pub fn use(self: Shader) void{
        c.glUseProgram(self.program_id);
    }

    pub fn set_int(self: Shader, key: [*c]const u8, val: i32) void{
        c.glUniform1i(c.glGetUniformLocation(self.program_id, key), val);
    }

    pub fn set_mat4fv(self: Shader, key: [*c]const u8, val: za.Mat4) void{
        c.glUniformMatrix4fv(c.glGetUniformLocation(self.program_id, key), 1, c.GL_FALSE, val.getData());
    }

    pub fn deinit(self: Shader) void{
       c.glDeleteProgram(self.program_id);
    }
};
