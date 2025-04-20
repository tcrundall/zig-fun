# CMake Tutorial

This directory contains source code examples for the CMake Tutorial.
Each step has its own subdirectory containing code that may be used as a
starting point. The tutorial examples are progressive so that each step
provides the complete solution for the previous step.

## Notes

PRIVATE vs PUBLIC vs INTERFACE:
> For [target_link_libraries](https://cmake.org/cmake/help/latest/command/target_link_libraries.html#command:target_link_libraries):
>
> The PUBLIC, PRIVATE and INTERFACE scope keywords can be used to specify both the
> link dependencies and the link interface in one command.
> 
> Libraries and targets following PUBLIC are linked to, and are made part of the
> link interface. Libraries and targets following PRIVATE are linked to, but are
> not made part of the link interface. Libraries following INTERFACE are appended
> to the link interface and are not used for linking <target>.

What is "link interface"?
