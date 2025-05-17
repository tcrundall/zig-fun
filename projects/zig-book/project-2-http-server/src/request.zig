const std = @import("std");
const Connection = std.net.Server.Connection;

pub fn read_request(conn: Connection, buffer: []u8) !void {
    const reader = conn.stream.reader();
    _ = try reader.read(buffer);
}

pub fn write_response(conn: Connection) !void {
    const writer = conn.stream.writer();
    try writer.print("", .{});
}
