const std = @import("std");

pub fn main() !u8 {
    var out = std.io.getStdOut().writer();
    out.print("Hello\n", .{}) catch {
        return 3;
    };

    var buffer = std.io.bufferedWriter(out);
    var bw = buffer.writer();
    try bw.print("Hello from buffered writer\n", .{});
    try buffer.flush();

    return 0;
}
