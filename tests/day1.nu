use (path self ../src/day1.nu) *
use test-utils.nu 'test part'

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
