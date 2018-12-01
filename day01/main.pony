use "collections"
use "itertools"

use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayOne, env)

primitive _Misc
  fun read_int(s: String): I64 ? =>
    if s(0)? == '+' then
      s.trim(1).i64()?
    else
      s.i64()?
    end

class DayOne is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    var freq: I64 = 0
    Iter[String](file_lines.values())
      .fold[I64](I64(0), {(acc, line): I64 =>
        acc + try _Misc.read_int(line)? else 0 end
      }).string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    var freq: I64 = 0
    let set: SetIs[I64] = SetIs[I64].>set(I64(0))
    for line in Iter[String](file_lines.values()).cycle() do
      try
        freq = freq + _Misc.read_int(line)?
        if set.contains(freq) then
          return freq.string()
        else
          set.set(freq)
        end
      end
    end
    freq.string() // doesn't reach here
