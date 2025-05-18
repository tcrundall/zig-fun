const std = @import("std");
const net = std.net;
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
test "dummy2" {
    try testing.expectEqual(true, true);
}
