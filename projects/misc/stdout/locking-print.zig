const std = @import("std");
const Thread = std.Thread;

pub fn main() !void {
    var lock = Thread.Mutex{};

    var threads: [3]Thread = undefined;
    for (0..threads.len) |i| {
        threads[i] = try Thread.spawn(.{}, doHello, .{ &lock, i });
    }

    for (threads) |t| t.join();
}

fn doHello(l: *Thread.Mutex, id: usize) !void {
    l.*.lock();
    defer l.*.unlock();

    var out = std.io.getStdOut().writer();
    try out.print("T: {0}\n", .{id});
    try out.print("T: {0}\n", .{id});
    try out.print("T: {0}\n", .{id});
}
