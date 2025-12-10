use test-utils.nu 'test part'

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

def part1 []: string -> int {
  let input = parse-input
  $input.ids
  | where ($input.ranges | any { $in.min <= $it and $in.max >= $it })
  | length
}

def part2 []: string -> int {
  split row "\n\n" | first
  | parse-ranges | sort-by min
  | reduce --fold [] (merge-ranges)
  | each { $in.max - $in.min + 1 }
  | math sum
}

const smallInput = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 3]
    [(open ./resources/day5.txt) 607]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 14]
    [(open ./resources/day5.txt) 342433357244012]
  ]
  | test part { part2 }
}
