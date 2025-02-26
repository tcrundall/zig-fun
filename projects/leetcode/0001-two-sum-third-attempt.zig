const std = @import("std");

const TwoSumResult = struct {
    index_1: usize,
    index_2: usize,
};

fn getTwoSum(allocator: std.mem.Allocator, nums: []i32, target: i32) !?TwoSumResult {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    for (nums, 0..) |num, i| {
        const res = map.get(num);
        if (res) |r| {
            return .{ .index_1 = r, .index_2 = i };
        }

        try map.put(target - num, i);
    }
    return null;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const target = 8;
    var nums = [_]i32{ 2, 7, 5, 3 };

    const result = try getTwoSum(allocator, &nums, target);
    if (result) |r| {
        std.debug.print("({d}, {d})\n", .{ r.index_1, r.index_2 });
    } else {
        std.debug.print("No pair found\n", .{});
    }
}
