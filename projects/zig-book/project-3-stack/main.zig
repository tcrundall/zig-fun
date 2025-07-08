const std = @import("std");

const Stack = struct {
    pub fn init(allocator: std.mem.Allocator) void {}

    pub fn deinit() void {}

    pub fn peek() u32 {}

    pub fn pop() u32 {}

    pub fn push() u32 {}
};

pub fn main() void {
    std.debug.print("Hello world\n", .{});
}

test "can push" {
    var my_stack = Stack{};
    my_stack.init();
}

test "can pop" {}
