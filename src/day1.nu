use test-utils.nu 'test part'

def to-signed-rotations []: string -> list<int> {
  $in
  | str replace --all --multiline 'L' '-'
  | str replace --all --multiline 'R' ''
  | lines
  | each { into int }
}

def did-the-dial-click [p: int prevP: int rot: int]: nothing -> bool {
  $prevP > 0 and ($p == 0 or ($rot < 0 and $p > $prevP) or ($rot > 0 and $p < $prevP))
}

def part1 []: string -> int {
  $in
  | to-signed-rotations
  | reduce --fold {p: 50 n: 0} {|it prev|
    let p = ($prev.p + $it) mod 100
    let n = $p == 0 | into int
    {p: $p n: ($prev.n + $n)}
  }
  | get n
}

def part2 []: string -> int {
  $in
  | to-signed-rotations
  | reduce --fold {p: 50 n: 0} {|it prev|
    let cycles = ($it | math abs) // 100
    let p = ($prev.p + $it) mod 100
    let n = did-the-dial-click $p $prev.p $it | into int
    {p: $p n: ($prev.n + $cycles + $n)}
  }
  | get n
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
