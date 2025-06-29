# Project 2 - HTTP Server

This is the second project of the Zig Book

## Usage

Start server with
```bash
zig run main.zig
```

Then from a different shell, execute e.g.
```bash
curl -i localhost:<PORTNUMBER>/health
```
where `PORTNUMBER` is the port defined in `src/config.zig`.

Observe the 200 OK response.

Note, currently the server shuts down after one request, but the port won't be immediately released.
This interferes with starting the server a new, so either wait a minute or so, or change the port
number before your next attempt.

## Testing

Run tests with:
```bash
zig build test --summary all
```
