use test-utils.nu 'test part'

def zeros [size: int]: nothing -> list<string> {
  generate {|i = 0| if $i < $size { {out: '0' next: ($i + 1)} } }
}

def find-split-index [size: int window: list<string> acc: list<string>] {
  0..($size - 1)
  | zip { $window | zip $acc }
  | where ($it.1.0 > $it.1.1)
  | default -e [[-1]]
  | first
  | get 0
}

def accumulate-batteries [size: int acc: list<string>]: list<string> -> list<string> {
  let window = $in
  let index = find-split-index $size $window $acc
  if $index < 0 { return $acc }
  $acc
  | take $index
  | append ($window | skip $index)
}

def find-max-joltage [size: int]: string -> list<string> {
  split chars
  | window $size
  | reduce --fold (zeros $size) {|window acc| $window | accumulate-batteries $size $acc }
}

def part1 []: string -> int {
  lines
  | each { find-max-joltage 2 | str join | into int }
  | math sum
}

def part2 []: string -> int {
  lines
  | each { find-max-joltage 12 | str join | into int }
  | math sum
}

const smallInput = "987654321111111
811111111111119
234234234234278
818181911112111"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 357]
    [(open ./resources/day3.txt) 17343]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 3121910778619]
    [(open ./resources/day3.txt) 172664333119298]
  ]
  | test part { part2 }
}
