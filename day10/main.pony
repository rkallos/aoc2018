use "collections"
use "debug"
use "regex"

use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayTen, env)

class DayTen is AOCApp
  fun part1(file_lines: Array[String] val, args: Array[String] val): (String | AOCAppError) =>
    let t: I64 =
      try
        args(3)?.i64()?
      else
        return AOCAppError("missing time argument")
      end

    let render: Bool = if args.size() == 5 then true else false end

    let r =
      try
        Regex("position=< *([-0-9]+), *([-0-9]+)> velocity=< *([-0-9]+), *([-0-9]+)>")?
      else
        return AOCAppError("bad regex")
      end
      
    var min_x: I64 = 100000
    var max_x: I64 = -100000
    var min_y: I64 = 100000
    var max_y: I64 = -100000
    let points: Array[(I64, I64)] = Array[(I64, I64)]
    for line in file_lines.values() do
      let matched =
        try
          r(line)?
        else
          return AOCAppError("did not match line")
        end

        try
          let x: I64 = matched(1)?.i64()?
          let y: I64 = matched(2)?.i64()?
          let dx: I64 = matched(3)?.i64()?
          let dy: I64 = matched(4)?.i64()?

          let x2 = x + (t * dx)
          let y2 = y + (t * dy)

          min_x = min_x.min(x2)
          max_x = max_x.max(x2)
          min_y = min_y.min(y2)
          max_y = max_y.max(y2)

          if render then
            points.push((x2, y2))
          end
        else
          return AOCAppError("error checking coordinates")
        end
    end

    let bb_x = max_x - min_x
    let bb_y = max_y - min_y

    if not render then
      return "Bounding box: " + bb_x.string() + "x" + bb_y.string() + "=" + (bb_x * bb_y).string() +
      "\nxmin=" + min_x.string() + ",xmax=" + max_x.string() + ",ymin=" + min_y.string() + ",ymax=" + max_y.string()
    end

    let line_len: USize = (bb_x + 2).usize()
    let num_lines: USize = (bb_y.usize() + 1)
    Debug.out("line_len=" + line_len.string() + ",num_lines=" + num_lines.string())
    let arr: Array[U8] iso =
      recover iso
        Array[U8].init(' ', (num_lines * line_len))
      end
    let out: String iso =
      recover iso
        String.from_iso_array(consume arr)
      end

    for i in Range[USize](1, num_lines) do
      let idx: USize = i * line_len
      try
        out(idx)? = '\n'
      else
        return AOCAppError("unable to add \n to output")
      end
    end

    
    for point in points.values() do
      (let x, let y) = point
      let row: USize = (y - min_y).usize()
      let col: USize = ((x - min_x) + 1).usize()
      let idx: USize = (row * line_len) + if row == 0 then col - 1 else col end
      try
        out(idx)? = '*'
      else
        return AOCAppError("unable to add '*' to output at (" + x.string() + "," + y.string() + ")=" + idx.string())
      end
    end

    consume out

  fun part2(file_lines: Array[String] val, args: Array[String] val): (String | AOCAppError) =>
    ""
