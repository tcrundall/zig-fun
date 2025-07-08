const std = @import("std");

const Person = struct {
    name: []const u8,
    age: u32,
    height: u32,
};
const PersonArray = std.MultiArrayList(Person);

const Ex = struct {
    val: u8,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // var my_list = std.ArrayList(u32).init(allocator);
    var my_list = try std.ArrayList(u32).initCapacity(allocator, 100);
    defer _ = my_list.deinit();

    try my_list.append(10);
    var slice = try my_list.addManyAsSlice(3);
    slice[0] = 0;
    slice[1] = 1;
    slice[2] = 2;

    std.debug.print("{any}\nsize: {d}\n", .{ my_list.items, my_list.capacity });

    // _ = Ex{ .val = 10 };

    var my_multi_array = PersonArray{};
    defer my_multi_array.deinit(allocator);

    try my_multi_array.append(allocator, .{ .name = "Tim", .age = 90, .height = 200 });
    try my_multi_array.append(allocator, .{ .name = "Tim", .age = 91, .height = 200 });
    // std.debug.print("{any}\n", .{});

    std.debug.print("{any}\n", .{my_multi_array.items(.age)});
}
