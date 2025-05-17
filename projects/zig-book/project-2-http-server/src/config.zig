const std = @import("std");
const net = std.net;
const Map = std.static_string_map.StaticStringMap;

const MethodMap = Map(Method).initComptime(.{
    .{ "GET", Method.GET },
    .{ "POST", Method.POST },
});

const MethodError = error{ UnrecognizedMethod, SomeOtherError };

pub const Method = enum {
    GET,
    POST,

    fn init(text: []const u8) !Method {
        return MethodMap.get(text) orelse MethodError.UnrecognizedMethod;
    }

    fn is_supported(text: []const u8) bool {
        const method = MethodMap.get(text);
        if (method) |_| {
            return true;
        }
        return false;
    }
};

pub const Socket = struct {
    _address: net.Address,
    _stream: net.Stream,

    pub fn init() !Socket {
        const host = [4]u8{ 127, 0, 0, 1 };
        const port: u16 = 8006;
        const addr = net.Address.initIp4(host, port);
        const socket = try std.posix.socket(
            addr.any.family,
            std.posix.SOCK.STREAM,
            std.posix.IPPROTO.TCP,
        );
        const stream = net.Stream{ .handle = socket };
        return Socket{ ._address = addr, ._stream = stream };
    }
};

const testing = std.testing;

test "test enum" {
    var method: []const u8 = undefined;

    method = "GET";
    try testing.expectEqual(true, Method.is_supported(method));

    method = "POST";
    try testing.expectEqual(true, Method.is_supported(method));

    method = "MISC";
    try testing.expectEqual(false, Method.is_supported(method));
}

test "test init" {
    var method_str: []const u8 = undefined;
    var method: Method = undefined;

    method_str = "GET";
    method = try Method.init(method_str);
    try testing.expectEqual(Method.GET, method);

    method_str = "POST";
    method = try Method.init(method_str);
    try testing.expectEqual(Method.POST, method);

    method_str = "MISC";
    try testing.expectError(MethodError.UnrecognizedMethod, Method.init(method_str));
}
