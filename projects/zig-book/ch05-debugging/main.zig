const std = @import("std");
const stdout = std.io.getStdOut().writer();

fn add_and_increment(a: u8, b: u8) u8 {
    const sum = a + b;
    const incremented = sum + 1;
    return incremented;
}

pub fn main() !void {
    var n = add_and_increment(2, 3);
    n = add_and_increment(n, n);
    try stdout.print("Result: {d}!\n", .{n});
    const my_str = "test test test";
    const my_slice = my_str[0..8];
    const my_slice_2: []const u8 = "asdfasdf";

    try stdout.print("my_str: {any}\n", .{@TypeOf(my_str)});
    try stdout.print("my_slice: {any}\n", .{@TypeOf(my_slice)});
    try stdout.print("my_slice_2: {any}\n", .{@TypeOf(my_slice_2)});
}
