const std = @import("std");
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
const Method = Request.Method;
const Response = @import("response.zig");
const stdout = std.io.getStdOut().writer();
const Map = std.static_string_map.StaticStringMap;

const end_points = Map([]const u8).initComptime(.{
    .{ "/", "value" },
    .{ "/health", "value" },
    .{ "/v2", "value" },
    .{ "/v3", "value" },
});

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    try Request.read_request(connection, buffer[0..buffer.len]);
    try stdout.print("Raw request:\n---------\n{s}\n---------\n", .{buffer});
    const request = try Request.Request.parse_request(buffer[0..buffer.len]);
    try stdout.print(
        "{any}\n",
        .{request},
    );
    if (request.method == Method.GET) {
        if (end_points.get(request.uri)) |_| {
            try Response.send_200(connection);
        } else {
            try Response.send_404(connection);
        }
    }
    connection.stream.close();
}

const testing = std.testing;
test "dummy" {
    try testing.expectEqual(true, true);
}
