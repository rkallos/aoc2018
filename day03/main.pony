use "collections"
use "debug"
use "itertools"
use "regex"

use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayThree, env)

class DayThree is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    let grid = SparseGrid[USize]

    try
      let r = Regex("#\\d+ @ (\\d+),(\\d+): (\\d+)x(\\d+)")?
      for line in file_lines.values() do
        let matched = r(line)?

        let x0: ISize = matched(1)?.isize()?
        let y0: ISize = matched(2)?.isize()?
        let w: ISize = matched(3)?.isize()?
        let h: ISize = matched(4)?.isize()?

        Debug.out("x0=" + x0.string() + ",y0=" + y0.string() + ",w=" + w.string() + ",h=" + h.string())

        for x in Range[ISize](x0, x0 + w) do
          for y in Range[ISize](y0, y0 + h) do
            let v: USize = try grid(x, y)? else 0 end
            Debug.out("(" + x.string() + "," + y.string() + ")=" + v.string())
            grid.update(x, y, v + 1)
          end
        end
      end
    else
      Debug.err("Something went wrong")
    end

    Iter[USize](grid.values()) 
      .filter({(v: USize): Bool => v >= 2})
      .count()
      .string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    let grid = SparseGrid[USize]
    let owner = SparseGrid[USize]
    let not_overlapping = SetIs[USize]

    let res = recover String(0) end
    try
      let r = Regex("#(\\d+) @ (\\d+),(\\d+): (\\d+)x(\\d+)")?
      for line in file_lines.values() do
        let matched = r(line)?

        let id: USize = matched(1)?.usize()?
        let x0: ISize = matched(2)?.isize()?
        let y0: ISize = matched(3)?.isize()?
        let w: ISize = matched(4)?.isize()?
        let h: ISize = matched(5)?.isize()?

        Debug.out("id=" + id.string() + "x0=" + x0.string() + ",y0=" + y0.string() + ",w=" + w.string() + ",h=" + h.string())

        not_overlapping.set(id)

        for x in Range[ISize](x0, x0 + w) do
          for y in Range[ISize](y0, y0 + h) do
            let v: USize = try grid(x, y)? else 0 end
            Debug.out("(" + x.string() + "," + y.string() + ")=" + v.string())
            if v == 0 then
              grid.update(x, y, v + 1)
              owner.update(x, y, id)
            else
              not_overlapping.unset(id)
              let prev_owner = owner(x, y)?
              not_overlapping.unset(prev_owner)
            end
          end
        end
      end

      for no in not_overlapping.values() do
        res.append(no.string())
      end
    end
    res
