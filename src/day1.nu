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

export def part1 []: string -> int {
  to-signed-rotations
  | count-dial-clicks {|dial _ _| $dial == 0 | into int }
}

export def part2 []: string -> int {
  to-signed-rotations
  | count-dial-clicks {|dial rot prev|
    (($rot | math abs) // 100) + (did-the-dial-click $dial $prev.dial $rot | into int)
  }
}
