const std = @import("std");
//const c = @cImport(@cInclude("stdio.h"));
test "sample input" {
    const sample_input =
        \\Step C must be finished before step A can begin.
        \\Step C must be finished before step F can begin.
        \\Step A must be finished before step B can begin.
        \\Step A must be finished before step D can begin.
        \\Step B must be finished before step E can begin.
        \\Step D must be finished before step E can begin.
        \\Step F must be finished before step E can begin.
    ;

    std.debug.assert(std.mem.compare(u8, calcStepOrder(sample_input), "CABDFE") == std.mem.Compare.Equal);
    std.debug.assert(calcFinishTime(sample_input, 2, 1) == 15);
}

test "read line" {
    const str: []const u8 =
        "Step F must be finished before step P can begin";
    var s1: u8 = str[5];
    var s2: u8 = str[36];

    std.debug.assert(s1 == 'F');
    std.debug.assert(s2 == 'P');
}

const max_num_nodes = 26;
var adjacency_matrix: [max_num_nodes][max_num_nodes]bool = undefined;

pub fn main() void {
    std.debug.warn("{}\n", calcStepOrder(main_input));
    std.debug.warn("{}\n", calcFinishTime(main_input, 5, 61));
}

fn calcStepOrder(text: []const u8) []const u8 {
    var line_it = std.mem.separate(text, "\n");
    var num_nodes: usize = 0;
    // Populate adjacency matrix with edges from nodes to their dependencies
    while (line_it.next()) |line| {
        var dependency_node_idx: usize = line[5] - 'A';
        var node_idx: usize = line[36] - 'A';
        adjacency_matrix[node_idx][dependency_node_idx] = true;

        num_nodes = std.math.max(num_nodes, node_idx + 1);
        num_nodes = std.math.max(num_nodes, dependency_node_idx + 1);
    }

    var result: [max_num_nodes]u8 = undefined;
    var result_idx: usize = 0;
    var processed: [max_num_nodes]bool = [1]bool{false} ** max_num_nodes;
    while (true) {
        // Find nodes where processed[node_id] is false and the node has no
        // incoming edges
        var node_idx: usize = 0;
        while (node_idx < num_nodes) : (node_idx += 1) {
            if (processed[node_idx]) continue;

            var node_has_incoming_edges: bool = false;
            var node2_idx: usize = 0;
            while (node2_idx < num_nodes) : (node2_idx += 1) {
                if (adjacency_matrix[node_idx][node2_idx]) {
                    node_has_incoming_edges = true;
                    break;
                }
            }
            if (node_has_incoming_edges) continue;

            // Add node to output (naturally in alphabetical order), set
            // processed[node_idx] to true
            result[result_idx] = @truncate(u8, node_idx) + 'A';
            result_idx += 1;
            processed[node_idx] = true;

            // Remove edges originating from nodes from adjacency list
            var edge_removal_idx: usize = 0;
            while (edge_removal_idx < num_nodes) : (edge_removal_idx += 1) {
                adjacency_matrix[edge_removal_idx][node_idx] = false;
            }
            break;
        }

        // Termination check: processed[*] == true
        var check_idx: usize = 0;
        var done: bool = true;
        while (check_idx < num_nodes) : (check_idx += 1) {
            if (!processed[check_idx]) {
                done = false;
            }
        }
        if (done) {
            break;
        }
    }

    return result[0..num_nodes];
}

fn calcFinishTime(
    text: []const u8,
    comptime n_workers: usize,
    comptime base_seconds: u8)
usize {
    var line_it = std.mem.separate(text, "\n");
    var num_nodes: usize = 0;
    // Populate adjacency matrix with edges from nodes to their dependencies
    while (line_it.next()) |line| {
        var dependency_node_idx: usize = line[5] - 'A';
        var node_idx: usize = line[36] - 'A';
        adjacency_matrix[node_idx][dependency_node_idx] = true;

        num_nodes = std.math.max(num_nodes, node_idx + 1);
        num_nodes = std.math.max(num_nodes, dependency_node_idx + 1);
    }

    var t: usize = 0;
    var started: [max_num_nodes]bool = [1]bool{false} ** max_num_nodes;
    var finished: [max_num_nodes]bool = [1]bool{false} ** max_num_nodes;

    const Worker = struct {
        time_remaining: u8,
        step: u8,
    };
    var workers = [1]Worker{Worker{ .time_remaining = 0, .step = 0}} ** n_workers;
    while (true) : (t += 1) {
        // Advance all workers
        {
            var idx: usize = 0;
            while (idx < n_workers) : (idx += 1) {
                var worker = &workers[idx];
                if (worker.step != 0) {
                    worker.time_remaining -= 1;
                    if (worker.time_remaining == 0) {
                        // Mark worker as available
                        var node_idx = worker.step - 'A';
                        finished[node_idx] = true;
                        worker.step = 0;

                        // Remove edges originating from nodes from adjacency list
                        var edge_removal_idx: usize = 0;
                        while (edge_removal_idx < num_nodes) : (edge_removal_idx += 1) {
                            adjacency_matrix[edge_removal_idx][node_idx] = false;
                        }
                    }
                }
            }
        }

        // Find nodes where finished[node_id] is false and the node has no
        // incoming edges
        var node_idx: u8 = 0;
        while (node_idx < num_nodes) : (node_idx += 1) {
            if (started[node_idx] or finished[node_idx]) continue;

            var node_has_incoming_edges: bool = false;
            var node2_idx: usize = 0;
            while (node2_idx < num_nodes) : (node2_idx += 1) {
                if (adjacency_matrix[node_idx][node2_idx]) {
                    node_has_incoming_edges = true;
                    break;
                }
            }
            if (node_has_incoming_edges) continue;

            // Get first available worker to start working on this letter
            {
                var idx: usize = 0;
                while (idx < n_workers) : (idx += 1) {
                    if (workers[idx].step == 0) break;
                }
                workers[idx].time_remaining = node_idx + base_seconds;
                workers[idx].step = node_idx + 'A';
                started[node_idx] = true;
            }
        }

        // Termination check: finished[*] == true
        var check_idx: u8 = 0;
        var done: bool = true;
        while (check_idx < num_nodes) : (check_idx += 1) {
            if (!finished[check_idx]) {
                done = false;
                break;
            }
        }
        if (done) {
            break;
        }
    }

    return t;
}

const main_input =
    \\Step F must be finished before step P can begin.
    \\Step R must be finished before step J can begin.
    \\Step X must be finished before step H can begin.
    \\Step L must be finished before step N can begin.
    \\Step U must be finished before step Z can begin.
    \\Step B must be finished before step C can begin.
    \\Step S must be finished before step C can begin.
    \\Step N must be finished before step Y can begin.
    \\Step I must be finished before step J can begin.
    \\Step H must be finished before step K can begin.
    \\Step G must be finished before step Z can begin.
    \\Step Q must be finished before step V can begin.
    \\Step E must be finished before step P can begin.
    \\Step P must be finished before step W can begin.
    \\Step J must be finished before step D can begin.
    \\Step V must be finished before step W can begin.
    \\Step T must be finished before step D can begin.
    \\Step Z must be finished before step A can begin.
    \\Step K must be finished before step A can begin.
    \\Step Y must be finished before step O can begin.
    \\Step O must be finished before step W can begin.
    \\Step C must be finished before step M can begin.
    \\Step D must be finished before step A can begin.
    \\Step W must be finished before step M can begin.
    \\Step M must be finished before step A can begin.
    \\Step C must be finished before step A can begin.
    \\Step F must be finished before step Z can begin.
    \\Step I must be finished before step A can begin.
    \\Step W must be finished before step A can begin.
    \\Step T must be finished before step C can begin.
    \\Step S must be finished before step K can begin.
    \\Step B must be finished before step J can begin.
    \\Step O must be finished before step A can begin.
    \\Step Q must be finished before step P can begin.
    \\Step G must be finished before step M can begin.
    \\Step R must be finished before step T can begin.
    \\Step B must be finished before step G can begin.
    \\Step J must be finished before step O can begin.
    \\Step X must be finished before step E can begin.
    \\Step X must be finished before step C can begin.
    \\Step H must be finished before step Y can begin.
    \\Step Y must be finished before step A can begin.
    \\Step X must be finished before step W can begin.
    \\Step H must be finished before step A can begin.
    \\Step X must be finished before step A can begin.
    \\Step I must be finished before step M can begin.
    \\Step G must be finished before step J can begin.
    \\Step N must be finished before step G can begin.
    \\Step D must be finished before step M can begin.
    \\Step L must be finished before step D can begin.
    \\Step V must be finished before step T can begin.
    \\Step I must be finished before step Y can begin.
    \\Step S must be finished before step J can begin.
    \\Step K must be finished before step Y can begin.
    \\Step F must be finished before step R can begin.
    \\Step U must be finished before step T can begin.
    \\Step Z must be finished before step M can begin.
    \\Step T must be finished before step Z can begin.
    \\Step B must be finished before step I can begin.
    \\Step E must be finished before step K can begin.
    \\Step N must be finished before step J can begin.
    \\Step X must be finished before step Q can begin.
    \\Step F must be finished before step Y can begin.
    \\Step H must be finished before step P can begin.
    \\Step Z must be finished before step D can begin.
    \\Step V must be finished before step O can begin.
    \\Step E must be finished before step C can begin.
    \\Step V must be finished before step C can begin.
    \\Step P must be finished before step A can begin.
    \\Step B must be finished before step N can begin.
    \\Step S must be finished before step W can begin.
    \\Step P must be finished before step D can begin.
    \\Step L must be finished before step W can begin.
    \\Step D must be finished before step W can begin.
    \\Step K must be finished before step C can begin.
    \\Step L must be finished before step M can begin.
    \\Step R must be finished before step O can begin.
    \\Step F must be finished before step L can begin.
    \\Step R must be finished before step H can begin.
    \\Step K must be finished before step O can begin.
    \\Step T must be finished before step W can begin.
    \\Step R must be finished before step K can begin.
    \\Step C must be finished before step W can begin.
    \\Step N must be finished before step T can begin.
    \\Step R must be finished before step P can begin.
    \\Step E must be finished before step M can begin.
    \\Step G must be finished before step T can begin.
    \\Step U must be finished before step K can begin.
    \\Step Q must be finished before step D can begin.
    \\Step U must be finished before step S can begin.
    \\Step J must be finished before step V can begin.
    \\Step P must be finished before step Y can begin.
    \\Step X must be finished before step Z can begin.
    \\Step U must be finished before step H can begin.
    \\Step H must be finished before step M can begin.
    \\Step I must be finished before step C can begin.
    \\Step V must be finished before step M can begin.
    \\Step N must be finished before step I can begin.
    \\Step B must be finished before step K can begin.
    \\Step R must be finished before step Q can begin.
    \\Step O must be finished before step C can begin.
;
