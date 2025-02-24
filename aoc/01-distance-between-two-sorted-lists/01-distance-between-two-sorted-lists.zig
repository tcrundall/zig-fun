const std = @import("std");

pub fn main() !void {
    const cwd = std.fs.cwd();

    const new_file = try cwd.createFile("foo.txt", .{});
    defer new_file.close();

    var fw = new_file.writer();
    _ = try fw.writeAll("Test\n");

    const f = try cwd.openFile("aoc/01-distance-between-two-sorted-lists/input.txt", .{});
    defer f.close();

    const reader = f.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var left_list = std.ArrayList(i32).init(allocator);
    defer left_list.deinit();

    var right_list = std.ArrayList(i32).init(allocator);
    defer right_list.deinit();

    // std.debug.print("{d}\n", .{'0'});
    // std.debug.print("{d}\n", .{'1' - '0'});

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
        try left_list.append(val);

        val = 0;
        while (true) {
            const byte = reader.readByte() catch {
                break :read_file;
            };
            if (byte == ' ') continue;
            if (byte == '\n') break;
            // std.debug.print("byte: {c}\n", .{byte});

            // std.debug.print("{}\n", .{val});
            val *= 10;
            val += byte - '0';
        }
        try right_list.append(val);
    }

    const left_slice = try left_list.toOwnedSlice();
    defer allocator.free(left_slice);
    printSlice(left_slice);
    bubbleSort(left_slice);

    const right_slice = try right_list.toOwnedSlice();
    bubbleSort(right_slice);
    defer allocator.free(right_slice);

    std.debug.print("\n\n\n", .{});
    // printSlice(left_slice);
    // printSlice(right_slice);

    const result = sumOfDifference(left_slice, right_slice);
    std.debug.print("Result: {}\n", .{result});
}

fn bubbleSort(list: []i32) void {
    const len = list.len;
    std.debug.print("Len: {}\n", .{len});
    var n_done: u16 = 0;

    while (true) {
        var curr_ix: usize = 0;
        while (curr_ix < len - n_done - 1) {
            if (list[curr_ix] > list[curr_ix + 1]) {
                const tmp = list[curr_ix + 1];
                list[curr_ix + 1] = list[curr_ix];
                list[curr_ix] = tmp;
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
