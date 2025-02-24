const std = @import("std");

pub fn main() !void {
    const file_name: []u8 = @constCast("projects/aoc/01-distance-between-two-sorted-lists/input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var left_col = std.ArrayList(i32).init(allocator);
    defer left_col.deinit();
    var right_col = std.ArrayList(i32).init(allocator);
    defer right_col.deinit();

    try readFile(file_name, &left_col, &right_col);

    const left_slice = try left_col.toOwnedSlice();
    defer allocator.free(left_slice);
    bubbleSort(left_slice);

    const right_slice = try right_col.toOwnedSlice();
    bubbleSort(right_slice);
    defer allocator.free(right_slice);

    const result = sumOfDifference(left_slice, right_slice);
    std.debug.print("Result: {}\n", .{result});
}

fn readFile(file_name: []u8, left_col: *std.ArrayList(i32), right_col: *std.ArrayList(i32)) !void {
    const cwd = std.fs.cwd();
    const f = try cwd.openFile(file_name, .{});
    defer f.close();

    const reader = f.reader();

    read_file: while (true) {
        var val: i32 = 0;
        while (true) {
            const byte = reader.readByte() catch {
                break :read_file;
            };
            if (byte == ' ') break;

            val *= 10;
            val += byte - '0';
        }
        try left_col.append(val);

        val = 0;
        while (true) {
            const byte = reader.readByte() catch {
                break :read_file;
            };
            // consume space separators
            if (byte == ' ') continue;
            if (byte == '\n') break;

            val *= 10;
            val += byte - '0';
        }
        try right_col.append(val);
    }
}

fn bubbleSort(list: []i32) void {
    const len = list.len;
    var n_done: u16 = 0;

    while (true) {
        var curr_ix: usize = 0;
        while (curr_ix < len - n_done - 1) {
            const curr = list[curr_ix];
            const next = list[curr_ix + 1];
            if (curr > next) {
                list[curr_ix] = next;
                list[curr_ix + 1] = curr;
            }
            curr_ix += 1;
        }
        n_done += 1;
        if (n_done == len) {
            break;
        }
    }
}

fn sumOfDifference(left: []i32, right: []i32) i64 {
    var sum: i64 = 0;
    for (left, right) |l, r| {
        sum += @abs(l - r);
    }
    return sum;
}

fn printSlice(slice: []i32) void {
    for (slice) |s| {
        std.debug.print("{}\n", .{s});
    }
}
