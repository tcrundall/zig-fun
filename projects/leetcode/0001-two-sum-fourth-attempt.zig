const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var nums = [_]i32{ -1, 8, 4, 14 };
    const target = 13;

    const two_sum_result = try getTwoSum(allocator, &nums, target);
    if (two_sum_result) |tsr| {
        std.debug.print("({d}, {d})\n", .{ tsr.x, tsr.y });
    } else {
        std.debug.print("No pair found", .{});
    }
}

const TwoSumResult = struct {
    x: usize,
    y: usize,
};

fn getTwoSum(allocator: std.mem.Allocator, nums: []i32, target: i32) !?TwoSumResult {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    for (nums, 0..) |num, i| {
        const other_ix = map.get(num);
        if (other_ix) |j| {
            return .{ .x = j, .y = i };
        }
        try map.put(target - num, i);
    }
    return null;
}
