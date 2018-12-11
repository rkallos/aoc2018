use "collections"
use "debug"

use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(DayEleven, env)

primitive Power
  fun apply(x: I64, y: I64, serial_number: I64): I64 =>
    let rack_id = x + 10
    var power_level = rack_id * y
    power_level = power_level + serial_number
    power_level = power_level * rack_id
    power_level = (power_level / 100) % 10
    power_level - 5

primitive GridPower
  fun apply(x: I64, y: I64, size: I64, serial_number: I64): I64 =>
    var total = I64(0)
    for x2 in Range[I64](x, x + size) do
      for y2 in Range[I64](y, y + size) do
        let power = Power(x2, y2, serial_number)
        Debug.out("(" + x2.string() + "," + y2.string() + ")=" + power.string())
        total = total + power
      end
    end
    total

actor Cell
  new create(x: I64, y: I64, size: I64, serial_number: I64, keepmax: KeepMax tag) =>
    keepmax(x, y, size, GridPower(x, y, size, serial_number))

actor KeepMax
  var expected: I64
  var max_value: I64 = 0
  var _x: I64 = 0
  var _y: I64 = 0
  var _size: I64 = 0
  let reporter: AOCActorAppReporter tag

  new create(expected': I64, reporter': AOCActorAppReporter tag) =>
    expected = expected'
    reporter = reporter'

  be apply(x: I64, y: I64, size: I64, value: I64) =>
    if value > max_value then
      max_value = value
      _x = x
      _y = y
      _size = size
    end
    expected = expected - 1
    if expected == 0 then
      reporter(_x.string() + "," + _y.string() + "," + _size.string() + " = " + max_value.string())
    end

actor DayEleven is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val, reporter: AOCActorAppReporter) =>
    try
      let serial_number: I64 = file_lines(0)?.i64()?

      let keepmax = KeepMax(I64(299) * I64(299), reporter)

      for x in Range[I64](1, 300) do
        for y in Range[I64](1, 300) do
          Cell(x, y, 3, serial_number, keepmax)
        end
      end
    else
      Debug.err("Whoops")
    end

  be part2(file_lines: Array[String] val, args: Array[String] val, reporter: AOCActorAppReporter) =>
    try
      let serial_number: I64 = file_lines(0)?.i64()?

      var expected: I64 = 0
      for x in Range[I64](1, 300) do
        for y in Range[I64](1, 300) do
          for size in Range[I64](300 - x.max(y), 1, -1) do
            expected = expected + 1
          end
        end
      end

      Debug.out("expected = " + expected.string())
      let keepmax = KeepMax(expected, reporter)

      let grid = Grid[I64](301, 301, 0)

      for x in Range[USize](1, 300) do
        for y in Range[USize](1, 300) do
          grid.update(x, y, Power(x.i64(), y.i64(), serial_number))?
        end
      end

      let prefix_sum = Grid[I64](301, 301, 0)

      try
        for x in Range[USize](1, 300) do
          for y in Range[USize](1, 300) do
            let v = (((grid(x, y)? + prefix_sum(x, y - 1)?) + prefix_sum(x - 1, y)?) - prefix_sum(x - 1, y - 1)?)
            prefix_sum.update(x, y, v)?
          end
        end
      else
        reporter.err("building prefix_sum fucked up")
      end

      var best: I64 = 0
      var best_coord: (USize, USize, USize) = (0, 0, 0)
      for size in Range[USize](1, 300) do
        for x in Range[USize](size, 300) do
          for y in Range[USize](size, 300) do
            let total = ((prefix_sum(x, y)? - prefix_sum(x, y - size)?) - prefix_sum(x - size, y)?) + prefix_sum(x - size, y - size)?

            if total > best then
              best = total
              best_coord = ((x + 1) - size, (y + 1) - size, size)
            end
          end
        end
      end

      reporter("(" + best_coord._1.string() + "," + best_coord._2.string() + "," + best_coord._3.string() + ")=" + best.string())
    else
      reporter.err("Whoops")
    end
