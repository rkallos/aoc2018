use "aoc-tools"
use "collections"
use "itertools"
use "debug"
use "regex"

actor Main
  new create(env: Env) =>
    AOCAppRunner(DayFour, env)

class LogEntry
  var month: USize = 0
  var day: USize = 0
  var hour: USize = 0
  var minute: USize = 0

  new from_line(line: String) ? =>
    try
      let preamble = Regex("\\[1518-(\\d+)-(\\d+) (\\d+):(\\d+)\\]")?
      let ms = preamble(line)?
      month = ms(1)?.usize()?
      day = ms(2)?.usize()?
      hour = ms(3)?.usize()?
      minute = ms(4)?.usize()?
    else
      error
    end

type GuardId is USize
type Hour is USize
type Minute is USize

class DayFour is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    let lines: Array[String] ref = Sort[Array[String], String](file_lines.clone())
    let guards: MapIs[(GuardId, Minute), USize] = MapIs[(GuardId, Minute), USize]
    let total_sleep: MapIs[GuardId, Minute] = MapIs[GuardId, Minute]

    var guard: GuardId = 0
    var asleep: (None | Minute) = None

    try
      for line in lines.values() do
        let entry = LogEntry.from_line(line)?
        if line.contains("begins shift") then
          guard = try
            line.trim(26).split(" ")(0)?.usize()?
          else
            Debug.err("Couldn't read usize from: \"" + line.trim(26) + "\"")
            error
          end
          asleep = None
        elseif line.contains("falls asleep") then
          asleep = entry.minute
        elseif line.contains("wakes up") then
          for min in Range(asleep as Minute, entry.minute) do
            guards.upsert((guard, min), 1, {(pv: Minute, v: Minute): Minute => pv + 1})?
            total_sleep.upsert(guard, 1, {(pv: Minute, v: Minute): Minute => pv + 1})?
          end
        end
      end
    else
      Debug.err("Something went wrong")
    end

    try
      var sleepiest_guard: (None | (GuardId, Minute)) = None
      for pair in total_sleep.pairs() do
        if (sleepiest_guard is None) or
          (pair._2 > (sleepiest_guard as (GuardId, Minute))._2)
        then
          sleepiest_guard = pair
        end
      end

      let sg = sleepiest_guard as (GuardId, Minute)
      Debug.out("Guard #" + sg._1.string() + " sleeps a total of " + sg._2.string() + " minutes")

      var best: (None | (GuardId, Minute)) = None
      for pair in guards.pairs() do
        if (best is None) or
          ((pair._1._1 == sg._1) and (pair._2 > guards((best as (GuardId, Minute)))?))
        then
          best = pair._1
        end
      end

      let b = (best as (GuardId, Minute), guards(best as (GuardId, Minute))?)
      Debug.out("(" + b._1._1.string() + "," + b._1._2.string() + ") = " + b._2.string())
      return (b._1._1 * b._1._2).string()
    end
    ""

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    let lines: Array[String] ref = Sort[Array[String], String](file_lines.clone())
    let guards: MapIs[(GuardId, Minute), USize] = MapIs[(GuardId, Minute), USize]
    let total_sleep: MapIs[GuardId, Minute] = MapIs[GuardId, Minute]

    var guard: GuardId = 0
    var asleep: (None | Minute) = None

    try
      for line in lines.values() do
        let entry = LogEntry.from_line(line)?
        if line.contains("begins shift") then
          guard = try
            line.trim(26).split(" ")(0)?.usize()?
          else
            Debug.err("Couldn't read usize from: \"" + line.trim(26) + "\"")
            error
          end
          asleep = None
        elseif line.contains("falls asleep") then
          asleep = entry.minute
        elseif line.contains("wakes up") then
          for min in Range(asleep as Minute, entry.minute) do
            guards.upsert((guard, min), 1, {(pv: Minute, v: Minute): Minute => pv + 1})?
            total_sleep.upsert(guard, 1, {(pv: Minute, v: Minute): Minute => pv + 1})?
          end
        end
      end
    else
      Debug.err("Something went wrong")
    end

    try
      var best: (None | (GuardId, Minute)) = None
      for pair in guards.pairs() do
        if (best is None) or
          (pair._2 > guards((best as (GuardId, Minute)))?)
        then
          best = pair._1
        end
      end

      let b = (best as (GuardId, Minute), guards(best as (GuardId, Minute))?)
      Debug.out("(" + b._1._1.string() + "," + b._1._2.string() + ") = " + b._2.string())
      return (b._1._1 * b._1._2).string()
    end
    ""
