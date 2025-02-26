const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const cwd = std.fs.cwd();

    const input_file = try cwd.openFile("projects/aoc/01-b-similarity-of-lists/input.txt", .{});
    const reader = input_file.reader();

    var col_1_arr = std.ArrayList(u32).init(allocator);
    defer col_1_arr.deinit();
    var col_2_arr = std.ArrayList(u32).init(allocator);
    defer col_2_arr.deinit();

    read_file: while (true) {
        var col_1_entry: u32 = 0;
        read_col_1: while (true) {
            const read_byte = reader.readByte() catch break :read_file;
            if (read_byte == ' ') break :read_col_1;
            col_1_entry *= 10;
            col_1_entry += read_byte - '0';
        }
        try col_1_arr.append(col_1_entry);

        var col_2_entry: u32 = 0;
        read_col_2: while (true) {
            const read_byte = reader.readByte() catch break :read_file;
            if (read_byte == ' ') continue :read_col_2;
            if (read_byte == '\n') break :read_col_2;
            col_2_entry *= 10;
            col_2_entry += read_byte - '0';
        }
        try col_2_arr.append(col_2_entry);
    }

    // TODO: could build hashmap instead of array list
    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (col_2_arr.items) |n| {
        var count: u32 = map.get(n) orelse 0;
        count += 1;
        try map.put(n, count);
    }

    // var it = map.iterator();
    // while (it.next()) |kv| {
    //     std.debug.print("{}: {}\n", .{ kv.key_ptr.*, kv.value_ptr.* });
    // }

    var total: u64 = 0;
    for (col_1_arr.items) |c1| {
        const count = map.get(c1) orelse 0;
        total += c1 * count;
    }
    std.debug.print("total: {}", .{total});
}
