const std = @import("std");

const Pair = struct {
    x: usize,
    y: usize,
};

fn twoSum(target: i32, nums: [*]i32, len: usize, allocator: std.mem.Allocator) !?Pair {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    var i: usize = 0;
    while (i < len) : (i += 1) {
        const partner_ix = map.get(nums[i]);
        if (partner_ix) |p| {
            return Pair{ .x = p, .y = i };
        }
        try map.put(target - nums[i], i);
    }
    return null;
}

pub fn main() !void {
    var gap = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gap.deinit();

    const allocator = gap.allocator();

    const target = 22;
    var nums: [4]i32 = [_]i32{ 2, 11, 7, 15 };
    const many_nums_ptr: [*]i32 = &nums;

    const result = try twoSum(target, many_nums_ptr, nums.len, allocator);
    if (result) |r| {
        std.debug.print("{}, {}", .{ r.x, r.y });
    }
}

const testing = std.testing;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const TestCase = struct {
    target: i32,
    expected_result: ?Pair,
};

test "Test" {
    const allocator = testing.allocator;
    var nums = [_]i32{ 2, 11, 7, 15, -14, -5 };
    const nums_ptr: [*]i32 = &nums;

    const test_cases = [_]TestCase{
        TestCase{ .target = 22, .expected_result = Pair{ .x = 2, .y = 3 } },
        TestCase{ .target = 13, .expected_result = Pair{ .x = 0, .y = 1 } },
        TestCase{ .target = 0, .expected_result = null },
        TestCase{ .target = 1, .expected_result = Pair{ .x = 3, .y = 4 } },
        TestCase{ .target = -19, .expected_result = Pair{ .x = 4, .y = 5 } },
    };

    for (test_cases) |tc| {
        const actual_result = try twoSum(tc.target, nums_ptr, nums.len, allocator);
        try expectEqual(tc.expected_result, actual_result);
    }
}
