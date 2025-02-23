const std = @import("std");

const Pair = struct {
    x: usize,
    y: usize,
};

fn twoSum(target: i32, nums: []i32, allocator: std.mem.Allocator) !?Pair {
    var map = std.AutoHashMap(i32, usize).init(allocator);
    defer map.deinit();

    for (nums, 0..) |num, i| {
        const partner_ix = map.get(num);
        if (partner_ix) |p| {
            return Pair{ .x = p, .y = i };
        }
        try map.put(target - num, i);
    }
    return null;
}

pub fn main() !void {
    var gap = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gap.deinit();
    const allocator = gap.allocator();

    const target = 22;
    var nums: [4]i32 = [_]i32{ 2, 11, 7, 15 };

    const result = try twoSum(target, nums[0..1], allocator);
    if (result) |r| {
        std.debug.print("{}, {}", .{ r.x, r.y });
    } else {
        std.debug.print("No pair found", .{});
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

    const test_cases = [_]TestCase{
        TestCase{ .target = 22, .expected_result = Pair{ .x = 2, .y = 3 } },
        TestCase{ .target = 13, .expected_result = Pair{ .x = 0, .y = 1 } },
        TestCase{ .target = 0, .expected_result = null },
        TestCase{ .target = 1, .expected_result = Pair{ .x = 3, .y = 4 } },
        TestCase{ .target = -19, .expected_result = Pair{ .x = 4, .y = 5 } },
    };

    for (test_cases) |tc| {
        const actual_result = try twoSum(tc.target, &nums, allocator);
        try expectEqual(tc.expected_result, actual_result);
    }
}
