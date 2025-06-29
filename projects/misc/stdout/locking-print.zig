const std = @import("std");

pub fn main() !void {
    var lock = std.Thread.Mutex{};

    var t1 = try std.Thread.spawn(.{}, doHello, .{ &lock, 1 });
    var t2 = try std.Thread.spawn(.{}, doHello, .{ &lock, 2 });

    var threads: [2]*std.Thread = undefined;
    threads[0] = &t1;
    threads[1] = &t2;

    for (threads) |t| t.join();
}

fn doHello(l: *std.Thread.Mutex, id: usize) !void {
    l.*.lock();
    defer l.*.unlock();

    var out = std.io.getStdOut().writer();
    try out.print("T: {0}\n", .{id});
    try out.print("T: {0}\n", .{id});
    try out.print("T: {0}\n", .{id});
}
