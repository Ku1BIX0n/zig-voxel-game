const std = @import("std");
const Renderer = @import("../renderer/renderer.zig").Renderer;
const Mesh = @import("../renderer/mesh.zig").Mesh;
const Square = @import("../objects/square.zig").Square;
const c = @import("../c.zig").c;
const za = @import("zalgebra");

const SIZE: f32 = 32;
const MAX_DEPTH: u8 = 7;

const Node = struct{
    x: f32,
    y: f32,
    z: f32,
    size: f32,
    depth: u32,
    is_leaf: bool,
    parent: ?*Node,
    children: []?*Node,
    value: u8,
    // mesh: Mesh,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, x: f32, y: f32, z: f32, size: f32, depth: u32, parent: ?*Node) !*Node{
        const node = try allocator.create(Node);

        node.x = x;
        node.y = y;
        node.z = z;
        node.value = 0;
        node.depth = depth;
        node.size = size;
        // node.mesh = Square.init(size);
        // node.children = [_]?*Node{null}**8;
        node.children = try allocator.alloc(?*Node, 8);
        node.allocator = allocator;
        node.parent = parent;

        for (0..8) |i|{
            node.children[i] = null;
        }
        // node.update_buffer();

        return node;
    }

    pub fn insert(self: *Node, x: f32, y: f32, z: f32) !void{
        if (x > self.x + self.size/2 or x < self.x - self.size/2 or
            y > self.y + self.size/2 or y < self.y - self.size/2 or
            z > self.z + self.size/2 or z < self.z - self.size/2)
        {
            @panic("Failed");
        }

        if (self.depth == MAX_DEPTH){
            self.value = 20;
            self.is_leaf = true;
            self.optimize();

            return;
        }
 
        var index: usize = 0;                
        
        if (x >= self.x) index |= 1;
        if (y >= self.y) index |= 2;
        if (z >= self.z) index |= 4;

        const new_m_x = if (x >= self.x) x + self.size/4 else x-self.size/4;
        const new_m_y = if (y >= self.y) y + self.size/4 else y-self.size/4;
        const new_m_z = if (z >= self.z) z + self.size/4 else z-self.size/4;
        
        if (self.children[index]) |ch|{
            return try ch.insert(new_m_x, new_m_y, new_m_z);
        }else{
            const new_x = if (x >= self.x) self.x + self.size/2 else self.x-self.size/2;
            const new_y = if (y >= self.y) self.y + self.size/2 else self.y-self.size/2;
            const new_z = if (z >= self.z) self.z + self.size/2 else self.z-self.size/2;

            const child = try Node.init(self.allocator, new_x, new_y, new_z, self.size/2, self.depth+1, self);
            
            self.children[index] = child;
            return try child.insert(new_m_x, new_m_y, new_m_z);
        }
    }

    fn optimize(self: *Node) void{
        if (self.parent) |parent|{
            for (parent.children) |child|{
                if (child == null)
                    return;
            }

            parent.value = self.value;
            parent.is_leaf = true;
            // parent.update_buffer();

            for (0..8) |i|{
                if (parent.children[i]) |child|{
                    child.deinit();
                    parent.children[i] = null;
                }
            }

            // parent.children = [_]?*Node{null}**8;
            //
            // for (0..7) |i|{
            //     if (parent.children[i]) |child|{
            //         parent.allocator.destroy(child);
            //         parent.children[i] = null;
            //     }
            // }


            parent.optimize();
        }
    }

    pub fn find(self: *Node, x: f32, y: f32, z: f32) bool{
        if (self.value != 0) return true;
        
        if (self.depth == MAX_DEPTH){
            return false;
        }
 
        var index: usize = 0;                
        
        if (x >= self.size/2) index |= 1;
        if (y >= self.size/2) index |= 2;
        if (z >= self.size/2) index |= 4;

        if (self.children[index]) |ch|{
            return ch.find(x, y, z);
        }

        return false;
    }

    // pub fn update_buffer(self: *Node) void{
    //     self.mesh.deinit();
    //     self.mesh = Square.init(self.size);
    // }

    pub fn render(self: *Node, mesh: *Mesh, debug: bool, renderer: *Renderer) void{
        self.draw_childs(mesh, debug, renderer);
    }

    pub fn draw_childs(self: *Node, mesh: *Mesh, debug: bool,renderer: *Renderer) void{
        if (debug)
            draw_node(self, mesh, debug, renderer);

        if (self.is_leaf)
            return draw_node(self, mesh, debug, renderer);

        for (self.children) |ch|{
            if (ch) |child|{
                if (child.is_leaf == false){
                    child.draw_childs(mesh, debug, renderer);
                }else{
                    draw_node(child, mesh, debug, renderer);
                }
            }
        }
    }

    fn draw_node(node: *Node, mesh: *Mesh, debug: bool, renderer: *Renderer) void{
        if (debug)
            c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

        renderer.shader.set_mat4fv("model", za.Mat4.identity().scale(za.Vec3.new(node.size, node.size, node.size)).translate(za.Vec3.new(node.x, node.y, node.z)));

        mesh.draw();

        if (debug)
            c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_FILL);
    }

    pub fn deinit(self: *Node) void{
        for (0..8) |i|{
            if (self.children[i]) |child|{
                child.deinit();
                self.allocator.destroy(child);
            }
        }

        self.allocator.free(self.children);
        // self.mesh.deinit();
        self.allocator.destroy(self);
    }
};

pub const Octree = struct{
    allocator: std.mem.Allocator,
    root:      *Node,
    mesh:      Mesh,

    pub fn init(allocator: std.mem.Allocator) !*Octree{
        const octree = try allocator.create(Octree);

        octree.root      = try Node.init(allocator, 0, 0, 0, 32, 0, null);
        octree.allocator = allocator;
        octree.mesh      = Square.init(1);

        // try octree.root.insert(0, 0, 0);
        // try octree.root.insert(0.2, 0, 0);
        // try octree.root.insert(0, 0.2, 0);
        // try octree.root.insert(0.2, 0.2, 0);
        //
        // try octree.root.insert(0, 0, 0.2);
        // try octree.root.insert(0.2, 0, 0.2);
        // try octree.root.insert(0, 0.2, 0.2);

        return octree;
    }

    pub fn render(self: *Octree, debug: bool, renderer: *Renderer) void{
        self.root.render(&self.mesh, debug, renderer);
    }

    pub fn deinit(self: *Octree) void{
        self.root.deinit();
        self.allocator.destroy(self);
    }
};

