const std = @import("std");
const testing = std.testing;
const fmt = std.fmt;

const DivisionError = error{
    DivideByZero,
    NumberTooLarge,
};

fn divide(number: u32, divisor: u32) DivisionError!u32 {
    if (divisor == 0) {
        return error.DivideByZero;
    }
    if (number > 1000) {
        return error.NumberTooLarge;
    }

    return number / divisor;
}

pub fn main() !void {
    const writer = std.io.getStdOut().writer();
    try writer.print("Hello world\n", .{});
    try writer.print("10 / 3 = {d}\n", .{try divide(10, 3)});

    _ = divide(30, 0) catch |e| {
        try writer.print("{any}\n", .{e});
    };

    if (fmt.parseFloat(f32, "1.23.4")) |float| {
        try writer.print("{d}\n", .{float});
    } else |err| {
        try writer.print("Error: {any}\n", .{err});
    }

    if (divide(1010, 10)) |res| {
        try writer.print("Result {d}\n", .{res});
    } else |err| switch (err) {
        error.DivideByZero => try writer.print("Divided by zero: {any}\n", .{err}),
        error.NumberTooLarge => try writer.print("Number too large: {any}\n", .{err}),
    }
}

test "example" {
    try testing.expect(true);
}

test "divide" {
    try testing.expectError(error.DivideByZero, divide(10, 0));
    try testing.expectError(error.NumberTooLarge, divide(1010, 5));

    try testing.expectEqual(10, divide(10, 1));
    try testing.expectEqual(3, divide(10, 3));
}

const A = error{
    ConnectionTimeoutError,
    DatabaseNotFound,
    OutOfMemory,
    InvalidToken,
};

const C = error{
    ConnectionTimeoutError,
    DatabaseNotFound,
    OutOfMemory,
    InvalidToken,
};

const B = error{
    OutOfMemory,
};

fn cast(err: B) A {
    return err;
}

test "coerce error value" {
    const error_value = cast(B.OutOfMemory);
    try std.testing.expect(error_value == B.OutOfMemory);
    try std.testing.expect(error_value == A.OutOfMemory);
}
