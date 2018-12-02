use "collections"
use "debug"
use "aoc-tools"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayTwo, env)


class DayTwo is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    var twos: USize = 0
    var threes: USize = 0

    for line in file_lines.values() do
      let map = MapIs[U32, USize]
      for rune in line.runes() do
        try
          map.upsert(rune, 1, {(pv, v) => pv + v})?
        end
      end

      var counted_two = false
      var counted_three = false
      for count in map.values() do
        if counted_two and counted_three then
          break
        elseif (count == 2) and (not counted_two) then
          counted_two = true
          twos = twos + 1
        elseif (count == 3) and (not counted_three) then
          counted_three = true
          threes = threes + 1
        end
      end
    end

    let prod = twos * threes
    prod.string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    var res: String iso = recover String(0) end
    try
      for idxi in Range(0, file_lines.size()) do
        let stri = file_lines(idxi)?
        
        for idxj in Range(idxi, file_lines.size()) do
          let strj = file_lines(idxj)?
          var differences: USize = 0
          var last_difference: USize = 0
          
          for idx in Range(0, stri.size()) do
            let chari = stri(idx)?
            let charj = strj(idx)?
            if chari != charj then
              differences = differences + 1
              last_difference = idx
            end
          end

          if differences == 1 then
            res = stri.clone().>delete(last_difference.isize())
            return res
          end
        end
      end
    end
    res
