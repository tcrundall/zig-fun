const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try stdout.print("123\n", .{});
    var my_num: u32 = 6;
    try stdout.print("{d}\n", .{my_num});
    my_num = 10;
    var my_other_num: u32 = 999;
    var my_var_pointer = &my_num;
    var my_var_pointer_2 = &my_num;
    try stdout.print("{any} my_var_pointer:   {x} - {d}\n", .{ @TypeOf(my_var_pointer), my_var_pointer, my_var_pointer.* });
    const my_const_pointer = my_var_pointer;
    try stdout.print("{any} my_const_pointer: {x} - {d}\n", .{ @TypeOf(my_const_pointer), my_const_pointer, my_const_pointer.* });
    my_var_pointer = &my_other_num;
    try stdout.print("{any} my_var_pointer:   {x} - {d}\n", .{ @TypeOf(my_var_pointer), my_var_pointer, my_var_pointer.* });
    my_var_pointer = &my_other_num;
    my_var_pointer_2 = &my_other_num;
    my_const_pointer.* = 37;
    try stdout.print("{any} my_const_pointer: {x} - {d}\n", .{ @TypeOf(my_const_pointer), my_const_pointer, my_const_pointer.* });
    try stdout.print("{any} my_var_pointer:   {x} - {d}\n", .{ @TypeOf(my_var_pointer), my_var_pointer, my_var_pointer.* });
    try stdout.print("{any} my_var_pointer_2: {x} - {d}\n", .{ @TypeOf(my_var_pointer_2), my_var_pointer_2, my_var_pointer_2.* });
    my_var_pointer.* = 66;
    try stdout.print("{any} my_const_pointer: {x} - {d}\n", .{ @TypeOf(my_const_pointer), my_const_pointer, my_const_pointer.* });
    try stdout.print("{any} my_var_pointer:   {x} - {d}\n", .{ @TypeOf(my_var_pointer), my_var_pointer, my_var_pointer.* });
    try stdout.print("{any} my_var_pointer_2: {x} - {d}\n", .{ @TypeOf(my_var_pointer_2), my_var_pointer_2, my_var_pointer_2.* });

    const ar = [_]i32{ 1, 2, 3, 4 };
    var ptr: [*]const i32 = &ar;
    try stdout.print("{d}\n", .{ptr[0]});
    ptr += 1;
    try stdout.print("{d}\n", .{ptr[0]});
    ptr += 1;
    try stdout.print("{d}\n", .{ptr[0]});

    var maybe_int: ?u8 = 5;
    maybe_int = null;
    try stdout.print("{any}\n", .{maybe_int});
    maybe_int = 10;
    try stdout.print("{any}\n", .{maybe_int});
    var my_int: u8 = undefined;
    maybe_int = null;
    my_int = maybe_int orelse 20;
    try stdout.print("{any}\n", .{my_int});
    maybe_int = null;
    if (maybe_int) |payload| {
        try stdout.print("Payload: {d}\n", .{payload});
    }
    my_int = maybe_int.?;
    try stdout.print("Undefined? {d}\n", .{my_int});
}
