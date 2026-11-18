def parse-ranges []: string -> list<record> {
  lines | each { split words | each { into int } | {min: $in.0 max: $in.1} }
}

def parse-input []: string -> record {
  split row "\n\n"
  | {
    ranges: ($in.0 | parse-ranges)
    ids: ($in.1 | lines | into int)
  }
}

def merge-ranges [] {
  {|r1 acc|
    match $acc {
      [] => [$r1]
      [$r0 ..$_] if $r1.max <= $r0.max => $acc
      [$r0 ..$_] if $r1.min <= $r0.max => ($acc | skip | prepend [{min: $r0.min max: $r1.max}])
      _ => ($acc | prepend [$r1])
    }
  }
}

export def part1 []: string -> int {
  let input = parse-input
  $input.ids
  | where ($input.ranges | any { $it in $in.min..$in.max })
  | length
}

export def part2 []: string -> int {
  split row "\n\n" | first
  | parse-ranges | sort-by min
  | reduce --fold [] (merge-ranges)
  | each { $in.max - $in.min + 1 }
  | math sum
}
