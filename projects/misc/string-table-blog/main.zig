const std = @import("std");
const mem = std.mem;

const Foo = struct {
    string_bytes: std.ArrayListUnmanaged(u8),
    string_table: std.HashMapUnmanaged(u32, void, IndexContext, std.hash_map.default_max_load_percentage),
};

const IndexContext = struct {
    string_bytes: *std.ArrayListUnmanaged(u8),

    pub fn eql(self: IndexContext, a: u32, b: u32) bool {
        _ = self;
        return a == b;
    }

    pub fn hash(self: IndexContext, x: u32) u64 {
        // const x_slice = mem.span(@ptrCast([*:0]const u8, self.string_bytes.items.ptr) + x);
        var pt: [*:0]const u8 = @ptrCast(self.string_bytes.items.ptr);
        pt += x;
        const x_slice = mem.span(pt);
        return std.hash_map.hashString(x_slice);
    }
};

const SliceAdapter = struct {
    string_bytes: *std.ArrayListUnmanaged(u8),

    pub fn eql(self: SliceAdapter, a_slice: []const u8, b: u32) bool {
        var pt: [*:0]const u8 = @ptrCast(self.string_bytes.items.ptr);
        pt += b;
        const b_slice = mem.span(pt);
        return mem.eql(u8, a_slice, b_slice);
    }

    pub fn hash(self: SliceAdapter, adapted_key: []const u8) u64 {
        _ = self;
        return std.hash_map.hashString(adapted_key);
    }
};

test "hash contexts" {
    const gpa = std.testing.allocator;

    var foo: Foo = .{
        .string_bytes = .{},
        .string_table = .{},
    };
    defer foo.string_bytes.deinit(gpa);
    defer foo.string_table.deinit(gpa);

    const index_context: IndexContext = .{ .string_bytes = &foo.string_bytes };

    const hello_index: u32 = @intCast(foo.string_bytes.items.len);
    try foo.string_bytes.appendSlice(gpa, "hello\x00");
    try foo.string_table.putContext(gpa, hello_index, {}, index_context);

    const world_index: u32 = @intCast(foo.string_bytes.items.len);
    try foo.string_bytes.appendSlice(gpa, "world\x00");
    try foo.string_table.putContext(gpa, world_index, {}, index_context);

    // now we want to check if a string exists based on a string literal
    const slice_context: SliceAdapter = .{ .string_bytes = &foo.string_bytes };
    const found_entry = foo.string_table.getEntryAdapted(@as([]const u8, "world"), slice_context).?;
    try std.testing.expectEqual(found_entry.key_ptr.*, world_index);
}
