const std = @import("std");

const Pair = struct {
    x: usize,
    y: usize,
};

fn twoSum(target: i32, nums: [*]i32, nums_len: usize, allocator: std.mem.Allocator) !?Pair {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    var i: usize = 0;
    while (i < nums_len) : (i += 1) {
        const pair_ix = map.get(nums[i]);
        if (pair_ix) |p| {
            return Pair{ .x = p, .y = i };
        }

        try map.put(target - nums[i], i);
    }
    return null;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const target: i32 = 15;
    var nums = [_]i32{ 1, 5, 10, 15 };
    const nums_ptr: [*]i32 = &nums;

    const result = try twoSum(target, nums_ptr, nums.len, allocator);

    if (result) |r| {
        std.debug.print("({d}, {d})", .{ r.x, r.y });
    }
}
