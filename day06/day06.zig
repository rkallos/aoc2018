const std = @import("std");

test "sample input" {
    const sample_input =
        \\1, 1
        \\1, 6
        \\8, 3
        \\3, 4
        \\5, 5
        \\8, 9
    ;
    std.debug.assert(findBestArea(sample_input) == 17);
    std.debug.assert(findSafeRegion(sample_input, 32) == 16);
}

const max_grid_size = 500;
const max_coord_size = 100;
var grid: [max_grid_size][max_grid_size][max_coord_size]usize = undefined;

pub fn main() void {
    std.debug.warn("Part 1: {}\n", findBestArea(main_input));
    std.debug.warn("Part 2: {}\n", findSafeRegion(main_input, 10000));
}

const Cell = union(enum) {
    Empty,
    Coord: usize,
};

fn findBestArea(text: []const u8) usize {
    var max_x: usize = 0;
    var max_y: usize = 0;

    var line_it = std.mem.separate(text, "\n");
    var coord_index_end: usize = 0;
    while (line_it.next()) |line| : (coord_index_end += 1) {
        // Read line as coord
        var coord_it = std.mem.separate(line, ", ");
        const coord_x = std.fmt.parseInt(usize, coord_it.next().?, 10) catch unreachable;
        const coord_y = std.fmt.parseInt(usize, coord_it.next().?, 10) catch unreachable;
        std.debug.assert(coord_x < max_grid_size);
        std.debug.assert(coord_y < max_grid_size);

        max_x = std.math.max(max_x, coord_x);
        max_y = std.math.max(max_y, coord_y);

        // Find Manhattan distances from current coord to all points in grid
        var y: usize = 0;
        while (y < max_grid_size) : (y += 1) {
            var x: usize = 0;
            while (x < max_grid_size) : (x += 1) {
                grid[y][x][coord_index_end] = manhattan(coord_x, coord_y, x, y);
            }
        }
    }

    const end_x = max_x + 1;
    const end_y = max_y + 1;

    // Why isn't this outside the fn?
    const Coord = union(enum) {
        Disqualified,
        Area: usize,
    };

    // Create an array of max_coord_size empty Coords
    // This uses max_coord_size instead of coord_index_end because
    // max_coord_size is known at compile-time.
    var coord_info = [1]Coord{Coord{ .Area = 0 }} ** max_coord_size;

    // Iterate through points and coords, collecting the minimum distance(s),
    // and incrementing the Area of each Coord in coord_info
    var y: usize = 0;
    while (y < end_y) : (y += 1) {
        var x: usize = 0;
        while (x < end_x) : (x += 1) {
            var smallest_dist: usize = std.math.maxInt(usize);
            var opt_best_coord: ?usize = null;
            var coord_index: usize = 0;
            while (coord_index < coord_index_end) : (coord_index += 1) {
                const this_dist = grid[y][x][coord_index];
                if (opt_best_coord) |best_coord| {
                    if (smallest_dist == this_dist) {
                        opt_best_coord = null;
                    } else if (this_dist < smallest_dist) {
                        smallest_dist = this_dist;
                        opt_best_coord = coord_index;
                    }
                } else if (this_dist < smallest_dist) {
                    smallest_dist = this_dist;
                    opt_best_coord = coord_index;
                }
            }
            if (opt_best_coord) |best_coord_index| {
                const disqualify =
                    x == 0 or y == 0 or x == end_x - 1 or y == end_y - 1;
                if (disqualify) {
                    coord_info[best_coord_index] = Coord.Disqualified;
                } else switch (coord_info[best_coord_index]) {
                    Coord.Disqualified => {},
                    Coord.Area => |*area| area.* += 1,
                }
            }
        }
    }

    var best_area: usize = 0;
    var coord_index: usize = 0;
    while (coord_index < coord_index_end) : (coord_index += 1) {
        switch (coord_info[coord_index]) {
            Coord.Disqualified => {},
            Coord.Area => |area| best_area = std.math.max(area, best_area),
        }
    }
    return best_area;
}

fn findSafeRegion(text: []const u8, comptime max_dist_to_all: usize) usize {
    var max_x: usize = 0;
    var max_y: usize = 0;

    var line_it = std.mem.separate(text, "\n");
    var coord_index_end: usize = 0;
    while (line_it.next()) |line| : (coord_index_end += 1) {
        // Read line as coord
        var coord_it = std.mem.separate(line, ", ");
        const coord_x = std.fmt.parseInt(usize, coord_it.next().?, 10) catch unreachable;
        const coord_y = std.fmt.parseInt(usize, coord_it.next().?, 10) catch unreachable;
        std.debug.assert(coord_x < max_grid_size);
        std.debug.assert(coord_y < max_grid_size);

        max_x = std.math.max(max_x, coord_x);
        max_y = std.math.max(max_y, coord_y);

        // Find Manhattan distances from current coord to all points in grid
        var y: usize = 0;
        while (y < max_grid_size) : (y += 1) {
            var x: usize = 0;
            while (x < max_grid_size) : (x += 1) {
                grid[y][x][coord_index_end] = manhattan(coord_x, coord_y, x, y);
            }
        }
    }

    const end_x = max_x + 1;
    const end_y = max_y + 1;

    // Iterate through points and coords, collecting the sum of distances to
    // all coords, and comparing it to max_dist_to_all to see if it is in the
    // "safe" region
    var safe_cells: usize = 0;
    var y: usize = 0;
    while (y < end_y) : (y += 1) {
        var x: usize = 0;
        while (x < end_x) : (x += 1) {
            var dist_sum: usize = 0;
            var coord_index: usize = 0;
            while (coord_index < coord_index_end) : (coord_index += 1) {
                dist_sum += grid[y][x][coord_index];
            }
            if (dist_sum < max_dist_to_all) {
                safe_cells += 1;
            }
        }
    }
    return safe_cells;
}

fn manhattan(x1: usize, y1: usize, x2: usize, y2: usize) usize {
    return
        (if (x1 > x2) x1 - x2 else x2 - x1) +
        (if (y1 > y2) y1 - y2 else y2 - y1);
}

const main_input =
    \\46, 246
    \\349, 99
    \\245, 65
    \\241, 253
    \\127, 128
    \\295, 69
    \\205, 74
    \\167, 72
    \\103, 186
    \\101, 242
    \\256, 75
    \\122, 359
    \\132, 318
    \\163, 219
    \\87, 309
    \\283, 324
    \\164, 342
    \\255, 174
    \\187, 305
    \\145, 195
    \\69, 266
    \\137, 239
    \\241, 232
    \\97, 319
    \\264, 347
    \\256, 214
    \\217, 47
    \\109, 118
    \\244, 120
    \\132, 310
    \\247, 309
    \\185, 138
    \\215, 323
    \\184, 51
    \\268, 188
    \\54, 226
    \\262, 347
    \\206, 260
    \\213, 175
    \\302, 277
    \\188, 275
    \\352, 143
    \\217, 49
    \\296, 237
    \\349, 339
    \\179, 309
    \\227, 329
    \\226, 346
    \\306, 238
    \\48, 163
;
