const std = @import("std");

const log = std.log.scoped(.server);

var active_server: ?std.http.Server = null;

fn startServer() !void {
    var server = std.http.Server.init(.{ .reuse_address = true });

    errdefer server.deinit();

    const address = try std.net.Address.parseIp("127.0.0.1", 0);

    try server.listen(address);

    active_server = server;
}

fn startListener(allocator: std.mem.Allocator) void {
    listen(allocator) catch |e| {
        log.err("{}", .{e});
        std.os.abort();
    };
}

fn listen(allocator: std.mem.Allocator) !void {
    while (true) {
        if (active_server) |*server| {
            var res = try server.accept(.{ .allocator = allocator });

            defer res.deinit();

            while (res.reset() != .closing) {
                try res.wait();

                res.status = .ok;
                res.transfer_encoding = .chunked;

                try res.send();
                try res.writeAll("Hello, World!\n");
                try res.finish();
            }
        } else {
            return error.NoActiveServer;
        }
    }
}

export fn start_server() c_int {
    const allocator = std.heap.page_allocator;

    startServer() catch |e| {
        log.err("{}", .{e});

        return 1;
    };

    const thread = std.Thread.spawn(.{}, startListener, .{
        allocator,
    }) catch |e| {
        log.err("{}", .{e});

        return 1;
    };

    thread.detach();

    return 0;
}

export fn stop_server() void {
    if (active_server) |*server| {
        server.deinit();

        active_server = null;
    }
}

export fn get_port() c_int {
    return if (active_server) |server|
        server.socket.listen_address.getPort()
    else
        0;
}
