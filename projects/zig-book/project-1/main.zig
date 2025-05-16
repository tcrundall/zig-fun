// A base64 encoder/decoder
const std = @import("std");

const DecodeError = error{
    InvalidIndex,
};

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

    pub fn _char_at(self: Base64, index: usize) !u8 {
        if (index == 0xFF) return '=';
        if (index >= self._table.len) return DecodeError.InvalidIndex;

        return self._table[index];
    }

    pub fn _char_ix(_: Base64, char: u8) ?u8 {
        if ((char >= 'A') and (char <= 'Z')) {
            return char - 'A';
        }
        if ((char >= 'a') and (char <= 'z')) {
            return char - 'a' + 26;
        }
        if ((char >= '0') and (char <= '9')) {
            return char - '0' + 52;
        }
        if (char == '+') {
            return 62;
        }
        if (char == '/') {
            return 63;
        }
        if (char == '=') {
            return null;
        }
        unreachable;
    }

    fn _transform_8bit_to_6bit(self: Base64, input: []const u8, output: []u8) !void {
        output[0] = input[0] >> 2;
        output[1] = (input[0] & 0b11) << 4;
        output[2] = 0xFF;
        output[3] = 0xFF;
        if (input.len > 1) {
            output[1] |= input[1] >> 4;
            output[2] = (input[1] & 0b1111) << 2;
        }
        if (input.len > 2) {
            output[2] |= input[2] >> 6;
            output[3] = input[2] & 0b111111;
        }

        for (output, 0..) |b, i| {
            output[i] = try self._char_at(b);
        }
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const n_out = try _calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);

        var in_ix: usize = 0;
        var out_ix: usize = 0;
        while (in_ix < input.len) {
            const in_end_ix = @min(input.len, in_ix + 3);
            const out_ix_end = out_ix + 4;

            try _transform_8bit_to_6bit(self, input[in_ix..in_end_ix], out[out_ix..out_ix_end]);
            in_ix += 3;
            out_ix += 4;
        }
        return out;
    }

    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        var n_equal_symbols: usize = 0;
        if (input[input.len - 1] == '=') {
            n_equal_symbols += 1;
        }
        if (input[input.len - 2] == '=') {
            n_equal_symbols += 1;
        }

        const n_out = try _calc_decode_length(input);
        var out = try allocator.alloc(u8, n_out - n_equal_symbols);

        // edgecase: will output be the right length?
        var i: usize = 0;
        var out_ix: usize = 0;
        while (i < input.len) : (i += 4) {
            const bits1 = self._char_ix(input[i]) orelse unreachable;
            const bits2 = self._char_ix(input[i + 1]) orelse unreachable;
            const bits3 = self._char_ix(input[i + 2]) orelse 0;
            const bits4 = self._char_ix(input[i + 3]) orelse 0;

            out[out_ix] = (bits1 << 2) | (bits2 >> 4);
            out[out_ix + 1] = ((bits2 & 0b1111) << 4) | (bits3 >> 4);
            if (bits3 != 0) {
                out[out_ix + 2] = ((bits3 & 0b11) << 6) | bits4;
            }

            out_ix += 3;
        }

        return out;
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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const base64 = Base64.init();
    const out_buf = try base64.encode(allocator, "asdfasdfasdfka sje;rlakw!");
    std.debug.print("Output:  {s}\n", .{out_buf});
    std.debug.print("Compare: YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==\n", .{});
    allocator.free(out_buf);
}

const testing = std.testing;

test "Encode" {
    const base64 = Base64.init();

    var actual = try base64.encode(testing.allocator, "asdfasdfasdfka sje;rlakw!");
    var expected = "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.encode(testing.allocator, "asdfasdfasdfka sje;rlakw*1");
    expected = "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjE=";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.encode(testing.allocator, "asdfasdfasdfka sje;rlakw*12");
    expected = "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjEy";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);
}

// test "Decode" {
//     const base64 = Base64.init();
//
//     // var actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==");
//     // var expected = "asdfasdfasdfka sje;rlakw!";
//     // try testing.expectEqualSlices(u8, expected, actual);
//     // testing.allocator.free(actual);
//     //
//     // actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjE=");
//     // expected = "asdfasdfasdfka sje;rlakw*1";
//     // try testing.expectEqualSlices(u8, expected, actual);
//     // testing.allocator.free(actual);
//
//     const actual = try base64.decode(testing.allocator, "aa==");
//     const expected = "i";
//     try testing.expectEqualSlices(u8, expected, actual);
//     testing.allocator.free(actual);
//
//     // const actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjEy");
//     // const expected = "asdfasdfasdfka sje;rlakw*12";
//     // try testing.expectEqualSlices(u8, expected, actual);
//     // testing.allocator.free(actual);
// }

test "Get ix" {
    const base64 = Base64.init();

    for ("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0..) |char, expected_ix| {
        const actual_ix = base64._char_ix(char) orelse unreachable;
        try testing.expectEqual(expected_ix, actual_ix);
    }

    for ("abcdefghijklmnopqrstuvwxyz", 26..) |char, expected_ix| {
        const actual_ix = base64._char_ix(char) orelse unreachable;
        try testing.expectEqual(expected_ix, actual_ix);
    }

    for ("0123456789", 52..) |char, expected_ix| {
        const actual_ix = base64._char_ix(char) orelse unreachable;
        try testing.expectEqual(expected_ix, actual_ix);
    }

    try testing.expectEqual(62, base64._char_ix('+'));
    try testing.expectEqual(63, base64._char_ix('/'));
    try testing.expectEqual(null, base64._char_ix('='));
}

test "Char at" {
    const base64 = Base64.init();

    for (0.., "ABCDEFGHIJKLMNOPQRSTUVWXYZ") |index, expected_char| {
        const actual_char = try base64._char_at(index);
        try testing.expectEqual(expected_char, actual_char);
    }

    for (26.., "abcdefghijklmnopqrstuvwxyz") |index, expected_char| {
        const actual_char = try base64._char_at(index);
        try testing.expectEqual(expected_char, actual_char);
    }

    for (52.., "0123456789") |index, expected_char| {
        const actual_char = try base64._char_at(index);
        try testing.expectEqual(expected_char, actual_char);
    }

    try testing.expectEqual('+', base64._char_at(62));
    try testing.expectEqual('/', base64._char_at(63));

    try testing.expectEqual('=', base64._char_at(0xFF));
    try testing.expectEqual('=', base64._char_at(255));

    for (64..255) |invalid_index| {
        try testing.expectEqual(DecodeError.InvalidIndex, base64._char_at(invalid_index));
    }
}
