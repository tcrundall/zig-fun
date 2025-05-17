// A base64 encoder/decoder
const std = @import("std");
const stdout = std.io.getStdOut().writer();

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

    // Fill each "slot" with raw bits which will eventually be converted into base64 chars
    // 256 base input --> 64 base output
    //            XYZ --> ABCD
    // A is 6 most significant bits of X
    // B is 2 least significant bits of X and 4 most significant bits of Y
    // C is 4 least significant bits of Y and 2 most significant bits of Z
    // D is 6 least significant bits of Z
    // If both Y and Z or just Y are not provided, then C and D or D are set to 255, which
    // will be interpreted as an '=' which is the "filler" symbol of base64
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

    // Encode three 8 bit characters into four 6 bit characters
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

    // Decode four 6 bit characters into three 8 bit characters
    // Fill each "slot" with raw bits representing base256 ASCII characters
    //  64 base (6 bits) input --> 256 base (8 bits) output
    //                    ABCD --> XYZ
    // X is all 6 bits of A and 2 most significant bits of B
    // Y is 4 least significant bits of B and 4 most significant bits of C
    // Z is 2 least significant bits of C and all 6 bits of D
    //
    // If C and D or D are '=', then Y and Z or Z are omitted
    fn _transform_6bit_to_8bit(self: Base64, input: []const u8, output: []u8) !void {
        const input_0 = self._char_ix(input[0]) orelse unreachable;
        const input_1 = self._char_ix(input[1]) orelse unreachable;
        const input_2 = self._char_ix(input[2]) orelse 0;
        const input_3 = self._char_ix(input[3]) orelse 0;
        output[0] = input_0 << 2 | input_1 >> 4;

        if (output.len == 1) return;
        output[1] = (input_1 & 0b1111) << 4 | input_2 >> 2;

        if (output.len == 2) return;

        output[2] = (input_2 & 0b11) << 6 | input_3;
        return;
    }

    // Decode four 6 bit characters into three 8 bit characters
    // Fill each "slot" with raw bits representing base256 ASCII characters
    //  64 base input --> 256 base output
    //           ABCD --> XYZ
    // X is all 6 bits of A and 2 most significant bits of B
    // Y is 4 least significant bits of B and 4 most significant bits of C
    // Z is 2 least significant bits of C and all 6 bits of D
    //
    // If C and D or D are '=', then Y and Z or Z are omitted
    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        var n_equal_symbols: usize = 0;
        if (input[input.len - 2] == '=') {
            n_equal_symbols = 2;
        } else if (input[input.len - 1] == '=') {
            n_equal_symbols = 1;
        }

        const n_out = try _calc_decode_length(input, n_equal_symbols);
        var out = try allocator.alloc(u8, n_out);

        var i: usize = 0;
        var out_ix: usize = 0;
        while (i < input.len - n_equal_symbols) : (i += 4) {
            const out_end = @min(out_ix + 3, out.len);
            try self._transform_6bit_to_8bit(input[i .. i + 4], out[out_ix..out_end]);
            out_ix += 3;
        }

        return out;
    }
};

// each group of 3 8-bit (base256) chars is mapped to 4 6-bit (base64) chars
// so we calculate length accordingly
fn _calc_encode_length(input: []const u8) !usize {
    if (input.len == 0) {
        const n_output: usize = 4;
        return n_output;
    }
    const n_output = try std.math.divCeil(usize, input.len, 3);
    return n_output * 4;
}

// each group of 4 6-bit (base64) chars is mapped to 3 8-bit (base256) chars
// so we calculate length accordingly
fn _calc_decode_length(input: []const u8, n_equals_signs: usize) !usize {
    if (input.len == 0) {
        const n_output: usize = 3;
        return n_output;
    }
    const n_output = try std.math.divCeil(usize, input.len, 4);
    return n_output * 3 - n_equals_signs;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try stdout.print("another message\n", .{});
    try stdout.print("Some formatted {b:06}\n", .{123});

    const base64 = Base64.init();
    std.debug.print("Encoding...\n", .{});
    var out_buf = try base64.encode(allocator, "asdfasdfasdfka sje;rlakw!");
    std.debug.print("Output:  {s}\n", .{out_buf});
    std.debug.print("Compare: YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==\n", .{});
    allocator.free(out_buf);

    std.debug.print("\nDecoding...\n", .{});
    out_buf = try base64.decode(allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==");
    std.debug.print("Output:  {s}\n", .{out_buf});
    std.debug.print("Compare: asdfasdfasdfka sje;rlakw!\n", .{});
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

test "Decode" {
    const base64 = Base64.init();
    var actual: []const u8 = undefined;
    var expected: []const u8 = undefined;

    actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3IQ==");
    expected = "asdfasdfasdfka sje;rlakw!";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjE=");
    expected = "asdfasdfasdfka sje;rlakw*1";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YQ==");
    expected = "a";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YWE=");
    expected = "aa";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YWFh");
    expected = "aaa";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YWFhYQ==");
    expected = "aaaa";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YWFhYWE=");
    expected = "aaaaa";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);

    actual = try base64.decode(testing.allocator, "YXNkZmFzZGZhc2Rma2Egc2plO3JsYWt3KjEy");
    expected = "asdfasdfasdfka sje;rlakw*12";
    try testing.expectEqualSlices(u8, expected, actual);
    testing.allocator.free(actual);
}

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

test "calculating decode length" {
    var input: []const u8 = "YQ==";
    comptime var expected_decode_length = 1;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 2));

    input = "YWE=";
    expected_decode_length = 2;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 1));

    input = "YWFh";
    expected_decode_length = 3;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 0));

    input = "YWFhYQ==";
    expected_decode_length = 4;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 2));

    input = "YWFhYWE=";
    expected_decode_length = 5;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 1));

    input = "YWFhYWFh";
    expected_decode_length = 6;
    try testing.expectEqual(expected_decode_length, _calc_decode_length(input, 0));
}

test "transform 6 bit to 8 bit" {
    const base64 = Base64.init();

    var input: []const u8 = undefined;
    var expected_output: []const u8 = undefined;
    var output = try testing.allocator.alloc(u8, 3);
    defer testing.allocator.free(output);

    input = "YWFh";
    expected_output = "aaa";
    try base64._transform_6bit_to_8bit(input, output[0..3]);
    try testing.expectEqualStrings(expected_output, output);

    var output_2 = try testing.allocator.alloc(u8, 2);
    defer testing.allocator.free(output_2);
    input = "YWE=";
    expected_output = "aa";
    try base64._transform_6bit_to_8bit(input, output_2[0..2]);
    try testing.expectEqualStrings(expected_output, output_2);

    var output_3 = try testing.allocator.alloc(u8, 1);
    defer testing.allocator.free(output_3);
    input = "YQ==";
    expected_output = "a";
    try base64._transform_6bit_to_8bit(input, output_3[0..1]);
    try testing.expectEqualStrings(expected_output, output_3);
}

test "transform 8 bit to 6 bit" {
    // TODO:
    _ = Base64.init();
}
