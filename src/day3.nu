use utils.nu [ replicate ]

def find-split-index [size: int window: list<string> acc: list<string>] {
  0..($size - 1)
  | zip { $window | zip $acc }
  | where ($it.1.0 > $it.1.1)
  | default -e [[-1]]
  | first | first
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
  | reduce --fold ($size | replicate '0') {|window acc| $window | accumulate-batteries $size $acc }
}

export def part1 []: string -> int {
  lines
  | each { find-max-joltage 2 | str join | into int }
  | math sum
}

export def part2 []: string -> int {
  lines
  | each { find-max-joltage 12 | str join | into int }
  | math sum
}
