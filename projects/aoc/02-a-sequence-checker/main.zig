const std = @import("std");

pub fn main() !void {
    const input_file_name: []const u8 = "projects/aoc/02-a-sequence-checker/input.txt";

    const cwd = std.fs.cwd();
    const input_file = try cwd.openFile(input_file_name, .{});

    const reader = input_file.reader();
    const buffer_len = 100;
    var output: [buffer_len]u8 = undefined;
    var output_fbs = std.io.fixedBufferStream(&output);
    const writer = output_fbs.writer();

    var safe_rows_count: u32 = 0;
    lineloop: while (true) {
        reader.streamUntilDelimiter(writer, '\n', buffer_len) catch break;
        const line = output_fbs.getWritten();
        output_fbs.reset();

        var is_first_number = true;
        var is_first_comparison = true;
        var is_ascending: bool = undefined;

        var prev_num: i32 = undefined;
        var current_num: i32 = 0;
        for (line) |c| {
            if (c != ' ') {
                current_num *= 10;
                current_num += c - '0';
            } else {
                if (is_first_number) {
                    prev_num = current_num;
                    current_num = 0;
                    is_first_number = false;
                } else if (is_first_comparison) {
                    if (current_num == prev_num) continue :lineloop;
                    is_ascending = current_num > prev_num;
                    is_first_comparison = false;
                    if (@abs(current_num - prev_num) > 3) {
                        continue :lineloop;
                    }
                } else if (is_ascending != (current_num > prev_num)) {
                    continue :lineloop;
                } else {
                    if (current_num == prev_num) continue :lineloop;
                    prev_num = current_num;
                    current_num = 0;
                }
            }
        }
        safe_rows_count += 1;
        std.debug.print("{s}\n", .{line});
        std.debug.print("SAFE ROW\n", .{});
        std.debug.print("\n", .{});
    }
    std.debug.print("Total safe row count {}\n", .{safe_rows_count});
}
