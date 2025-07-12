const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

pub const StackError = error{EmptyStack};

const Stack = struct {
    const Self = @This();

    allocator: Allocator,
    capacity: u8,
    stack: []u32,
    size: u8,

    pub fn init(alloc: Allocator, init_capacity: u8) !Self {
        const stack = try alloc.alloc(u32, init_capacity);
        return Stack{ .allocator = alloc, .capacity = init_capacity, .stack = stack, .size = 0 };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.stack);
    }

    pub fn peek(self: *Self) StackError!u32 {
        if (self.size == 0) return error.EmptyStack;

        return self.stack[self.size - 1];
    }

    pub fn pop(self: *Self) StackError!u32 {
        if (self.size == 0) return error.EmptyStack;

        self.size -= 1;
        return self.stack[self.size];
    }

    pub fn push(self: *Self, value: u32) std.mem.Allocator.Error!u32 {
        if (self.size == self.capacity) {
            const new_stack = try self.allocator.alloc(u32, 2 * self.capacity);
            self.capacity *= 2;

            for (self.stack, 0..self.size) |old_elem, i| {
                new_stack[i] = old_elem;
            }

            self.allocator.free(self.stack);
            self.stack = new_stack;
        }

        self.stack[self.size] = value;
        self.size += 1;
        return value;
    }
};

pub fn main() void {
    std.debug.print("Hello world\n", .{});
}

test "pop throws when stack empty" {
    var my_stack = try Stack.init(testing.allocator, 10);
    defer my_stack.deinit();

    try testing.expectError(error.EmptyStack, my_stack.pop());
}

test "peek throws when stack empty" {
    var my_stack = try Stack.init(testing.allocator, 10);
    defer my_stack.deinit();

    try testing.expectError(error.EmptyStack, my_stack.peek());
}

test "can peek" {
    const value1 = 42;
    const value2 = 43;
    const alloc = testing.allocator;
    var my_stack = try Stack.init(alloc, 2);
    defer my_stack.deinit();

    _ = try my_stack.push(value1);
    var res = my_stack.peek();
    try testing.expectEqual(value1, res);

    _ = try my_stack.push(value2);
    res = my_stack.peek();
    try testing.expectEqual(value2, res);
}

test "can pop" {
    const value = 42;
    const alloc = testing.allocator;
    var my_stack = try Stack.init(alloc, 2);
    defer my_stack.deinit();

    _ = try my_stack.push(value);
    const res = my_stack.pop();
    try testing.expectEqual(value, res);
    try testing.expectEqual(0, my_stack.size);
}

test "can push" {
    const value = 42;
    var my_stack = try Stack.init(testing.allocator, 2);
    defer my_stack.deinit();

    try testing.expectEqual(value, try my_stack.push(value));
    try testing.expectEqual(1, my_stack.size);
    try testing.expectEqual(value, my_stack.stack[0]);
}

test "handles over capacity" {
    const value = 42;
    const push_count: u8 = 20;
    var my_stack = try Stack.init(testing.allocator, 1);
    defer my_stack.deinit();

    for (0..push_count) |_| {
        _ = try my_stack.push(value);
    }
    try testing.expectEqual(push_count, my_stack.size);
}
