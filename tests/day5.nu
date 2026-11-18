use (path self ../src/day5.nu) *
use test-utils.nu 'test part'

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
