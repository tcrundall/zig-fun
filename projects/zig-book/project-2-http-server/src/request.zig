const std = @import("std");
const testing = std.testing;
const Connection = std.net.Server.Connection;
const Map = std.static_string_map.StaticStringMap;

pub fn read_request(conn: Connection, buffer: []u8) !void {
    const reader = conn.stream.reader();
    _ = try reader.read(buffer);
}

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

pub const Request = struct {
    method: Method,
    uri: []const u8,
    version: []const u8,

    pub fn init(
        method: Method,
        uri: []const u8,
        version: []const u8,
    ) Request {
        return Request{
            .method = method,
            .uri = uri,
            .version = version,
        };
    }

    pub fn parse_request(text: []const u8) !Request {
        const new_line_ix = std.mem.indexOfScalar(u8, text, '\n') orelse text.len;
        var header_parts = std.mem.splitScalar(u8, text[0..new_line_ix], ' ');

        const method = try Method.init(header_parts.next().?);
        const uri = header_parts.next().?;
        const version = header_parts.next().?;

        return Request.init(
            method,
            uri,
            version,
        );
    }
};

test "request parse" {
    var method = Method.GET;
    const uri: []const u8 = "/health";
    const version: []const u8 = "HTTP/1.1";

    var expected_request = Request{
        .method = method,
        .uri = uri,
        .version = version,
    };
    const request_text = "GET /health HTTP/1.1";

    var actual_request = Request.parse_request(request_text);
    try testing.expectEqualDeep(expected_request, actual_request);

    method = Method.POST;

    expected_request = Request{
        .method = method,
        .uri = uri,
        .version = version,
    };
    const request_post_text = "POST /health HTTP/1.1\nSome stuff";

    actual_request = Request.parse_request(request_post_text);
    try testing.expectEqualDeep(expected_request, actual_request);
}

test "request init" {
    const method = Method.GET;
    const uri: []const u8 = "/health";
    const version: []const u8 = "HTTP/1.1";

    const expected_request = Request{
        .method = method,
        .uri = uri,
        .version = version,
    };

    const actual_request = Request.init(method, uri, version);

    try testing.expectEqualDeep(expected_request, actual_request);
}

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
