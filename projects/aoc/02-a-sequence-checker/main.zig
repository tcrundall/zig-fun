const std = @import("std");

const SequenceState = enum {
    firstNumber,
    firstComparison,
    isAscending,
    isDescending,
};

const MyStruct = struct { fbs: std.io.FixedBufferStream([]u8) };

// pub fn fixedBufferStream(buffer: anytype) FixedBufferStream(Slice(@TypeOf(buffer))) {
fn createBufferStream(comptime buffer: *[100]u8) MyStruct {
    std.debug.print("Type of buffer {}", .{@TypeOf(&buffer)});
    const output_fbs = std.io.fixedBufferStream(&buffer);
    return MyStruct{ .fbs = output_fbs };
}

pub fn main() !void {
    const input_file_name: []const u8 = "projects/aoc/02-a-sequence-checker/input.txt";
    const buffer_len: i32 = 100;

    const cwd = std.fs.cwd();
    const input_file = try cwd.openFile(input_file_name, .{});
    defer input_file.close();

    const reader = input_file.reader();
    comptime var output_buf: [buffer_len]u8 = undefined;
    comptime var output = createBufferStream(&output_buf);
    const writer = output.fbs.writer();

    var safe_rows_count: u32 = 0;
    lineloop: while (true) {
        reader.streamUntilDelimiter(writer, '\n', buffer_len) catch break;
        const line = output.fbs.getWritten();
        std.debug.print("\n{s: <30}", .{line});
        output.fbs.reset();

        var prev_num: i32 = undefined;
        var curr_num: i32 = 0;
        var sequence_state = SequenceState.firstNumber;

        for (line, 0..) |c, i| {
            // Read next integer
            if (c != ' ') {
                curr_num *= 10;
                curr_num += c - '0';
                // std.debug.print("i: {}, line.len {}\n", .{ i, line.len });
                if (i < line.len - 1) continue;
            }
            switch (sequence_state) {
                .firstNumber => {
                    prev_num = curr_num;
                    curr_num = 0;
                    sequence_state = SequenceState.firstComparison;
                    continue;
                },
                .firstComparison => {
                    if (curr_num > prev_num) {
                        sequence_state = SequenceState.isAscending;
                        std.debug.print("{s: <20}", .{"is ascending"});
                    } else {
                        sequence_state = SequenceState.isDescending;
                        std.debug.print("{s: <20}", .{"is descending"});
                    }
                },
                .isAscending => {
                    if (curr_num < prev_num) continue :lineloop;
                    std.debug.print("{s: <20}", .{"still ascending"});
                },
                .isDescending => {
                    if (curr_num > prev_num) continue :lineloop;
                    std.debug.print("{s: <20}", .{"still descending"});
                },
            }

            if (prev_num == curr_num) continue :lineloop;
            if (@abs(prev_num - curr_num) > 3) continue :lineloop;
            prev_num = curr_num;
            curr_num = 0;
        }
        safe_rows_count += 1;
        std.debug.print("SAFE ROW", .{});
    }
    std.debug.print("\n\nTotal safe row count {}\n", .{safe_rows_count});
}
