use "collections"
use "itertools"

use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayFour, env)

primitive Upper
  fun apply(c: U8): U8 =>
    if (c >= 'a') and (c <= 'z') then c - 0x20 else c end

primitive CICmp
  fun apply(c1: U8, c2: U8): U8 =>
    (c1.i16() - c2.i16()).abs().u8()

class DayFour is AOCApp

  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    try
      var polymer: String ref = file_lines(0)?.clone()
      reduce_polymer(polymer)
      return polymer.size().string()
    end
    ""

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    try
      var polymer: String ref = file_lines(0)?.clone()

      var best: USize = -1
      for bad in Range[U8]('A', 'Z' + 1) do
        let copy: String ref = polymer.clone()
        remove_unit(bad, copy)
        reduce_polymer(copy)
        best = best.min(copy.size())
      end

      return best.string()
    end
    ""

  fun reduce_polymer(polymer: String ref): None =>
    var done = true
    repeat
      let firsts = Iter[U8](polymer.values())
      let seconds = Iter[U8](polymer.values()).skip(1)
      let pairs = firsts.zip[U8](seconds)

      var idx: ISize = 0
      done = true
      for pair in pairs do
        if CICmp(pair._1, pair._2) == 0x20 then
          polymer.delete(idx, 2)
          done = false
          idx = idx + 1
        else
          idx = idx + 1
        end
      end  
    until done end

  fun remove_unit(c: U8, polymer: String ref): None =>
    let target: U8 = Upper(c)
    var idx: ISize = 0
    var diff: I16 = 0
    try
      repeat
        while
          (CICmp(polymer(idx.usize())?, target) == 0) or
          (CICmp(polymer(idx.usize())?, target) == 0x20)
        do
          polymer.delete(idx)
        end
        idx = idx + 1
      until (idx > polymer.size().isize()) end
    end
