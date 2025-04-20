# Building C with Zig

## Resources

- [Cmake tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
- [Using ZIG as drop in (youtube vid)](https://www.youtube.com/watch?v=kuZIzL0K4o4)
- [List of C projects built with zig](https://github.com/allyourcodebase/zlib)
- [Zig build guide](https://ziglang.org/learn/build-system)
- [Build system tricks](https://ziggit.dev/t/build-system-tricks/3531)

## Zig

Compile with clang via zig:
```bash
# Compile c
zig cc -o hello hello.c

# Compile c++
zig c++ -o hello_cpp hello.cpp

# Cross compile for e.g. Rasberry pi
zig c++ -o hello_cpp hello.cpp -target aarch64-linux-gnu
```

## Questions

- zig build:
    - [ ] How to add prefix to include path
    - [ ] Why does step3 behave differently to step2 re: flags set
