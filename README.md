# Zig fun

A place for all of my zig experimentation and learning

## Links

- [zig book](https://pedropark99.github.io/zig-book/)
- [zig guide](https://zig.guide/master/)
- docs
  - [language reference](https://ziglang.org/documentation/master/)
  - [filesystem api](https://ziglang.org/documentation/master/std/#std.fs)
  - [bulitins](https://ziglang.org/documentation/master/#Builtin-Functions)
- [ziglings](https://codeberg.org/ziglings/exercises/#ziglings)
- [community forum](https://ziggit.dev/)

## Projects

- [ ] [compiling-c](./projects/compiling-c/README.md)
- [ ] [aoc](./projects/aoc/README.md)
- [ ] [zig-book - projects](https://pedropark99.github.io/zig-book/)
  - [x] [project 1 - base64 de/encoder](./projects/zig-book/project-1/main.zig)
  - [x] project 2 - building HTTP server from scratch
  - [x] project 3 - build a stack
  - [ ] project 4 - image filter
- [ ] [leetcode](./projects/leetcode/README.md)
- [ ] simple ssh server and client

## Learning

- [ ] [zig-book](https://pedropark99.github.io/zig-book/)
  - [x] Ch. 5 - Debugging Zig
  - [x] Ch. 6 - Pointers and optionals
  - [x] Ch. 8 - Unit tests
  - [ ] Ch. 9 - Build system
  - [x] Ch. 10 - Error handling and unions
  - [x] Ch. 11 - Data structures
  - [ ] ch. 13 - Filesystem and IO
  - [ ] ch. 14 - Zig interop with C
  - [ ]  (ch. 16 - threads and parallelism)
  - [ ]  (ch. 17 - vectors and SIMD)
- [ ] [zig build blog post](https://zig.news/xq/zig-build-explained-part-1-59lf)

## Notes

### Debugging

Links:
- [zig book debug chapter](https://pedropark99.github.io/zig-book/Chapters/02-debugging.html#fn3)
- [lldb docs](https://lldb.llvm.org/)
- [lldb cheatsheet](https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa)

When considering debuggers, `Mason` provides `lldb` but not `gdb` so I s'pose I'll go with that.
See this [blog post for instructions](https://eliasdorneles.com/til/posts/customizing-neovim-debugging-highlight-zig-debug-w-codelldb/)

I have `lldb-dap` arleady installed since I installed llvm

Following [setup from docs](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-lldb-vscode)

Mini cheatsheet
```lldb
p <my-var> # print out my-var

br list # list all breakpoints
b <location> # set a breakpoint, location could be e.g. main.zig:16, <some-func-name>

# Print ints and unsigned chars in binary format
type format add -f binary int
type format add -f binary "unsigned char"
```
