// A base64 encoder/decoder
const std = @import("std");

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};

fn _calc_encode_length(input: []const u8) !usize {
    if (input.len == 0) {
        const n_output: usize = 4;
        return n_output;
    }
    const n_output = try std.math.divCeil(usize, input.len, 3);
    return n_output * 4;
}

fn _calc_decode_length(input: []const u8) !usize {
    if (input.len == 0) {
        const n_output: usize = 3;
        return n_output;
    }
    const n_output = try std.math.divCeil(usize, input.len, 4);
    return n_output * 3;
}

fn _transform_8bit_to_6bit(input: []const u8, output: []u8) void {
    output[0] = input[0] >> 2;
    output[1] = ((input[0] & 0b11) << 4) | (input[1] >> 4);
    output[2] = ((input[1] & 0b1111) << 2) | (input[2] >> 6);
    output[3] = input[2] & 0b111111;
}

fn _transform_6bit_to_base64(input: []u8) void {
    const base64 = Base64.init();
    for (input, 0..) |b, i| {
        input[i] = base64._char_at(b);
    }
}

fn _encode(input: []const u8, output: []u8) !void {
    std.debug.print("Encoding...\n", .{});
    output[0] = input[0];
    for (input) |byte| {
        std.debug.print("{b:0>8}", .{byte});
    }
    std.debug.print("\n", .{});

    _transform_8bit_to_6bit(input[0..3], output[0..4]);
    for (output) |byte| {
        std.debug.print("{b:0>6}", .{byte});
    }
    std.debug.print("\n", .{});

    _transform_6bit_to_base64(output);
}

pub fn main() !void {
    std.debug.print("Hello\n", .{});
    const base64 = Base64.init();
    std.debug.print("{c}\n", .{base64._char_at(10)});

    const in_buf: [3]u8 = .{ 'H', 'i', '0' };
    std.debug.print("{}\n", .{try _calc_encode_length(&in_buf)});

    var out_buf: [4]u8 = undefined;
    try _encode(&in_buf, &out_buf);
    std.debug.print("{s}", .{out_buf});
    std.debug.print("\n", .{});
}
