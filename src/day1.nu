use test-utils.nu 'test part'

def to-signed-rotations []: string -> list<int> {
  str replace --all --multiline 'L' '-'
  | str replace --all --multiline 'R' ''
  | lines
  | each { into int }
}

def did-the-dial-click [p: int prevP: int rot: int]: nothing -> bool {
  $prevP > 0 and ($p == 0 or ($rot < 0 and $p > $prevP) or ($rot > 0 and $p < $prevP))
}

def count-dial-clicks [counter: closure]: list<int> -> int {
  reduce --fold {dial: 50 count: 0} {|rot prev|
    let dial = ($prev.dial + $rot) mod 100
    {dial: $dial count: ($prev.count + (do $counter $dial $rot $prev))}
  }
  | get count
}

def part1 []: string -> int {
  to-signed-rotations
  | count-dial-clicks {|dial _ _| $dial == 0 | into int }
}

def part2 []: string -> int {
  to-signed-rotations
  | count-dial-clicks {|dial rot prev|
    (($rot | math abs) // 100) + (did-the-dial-click $dial $prev.dial $rot | into int)
  }
}

const smallInput = "L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 3]
    [(open ./resources/day1.txt) 995]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 6]
    [(open ./resources/day1.txt) 5847]
  ]
  | test part { part2 }
}
