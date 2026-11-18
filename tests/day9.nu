use (path self ../src/day9.nu) *
use test-utils.nu 'test part'

const smallInput = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 50]
    [(open ./resources/day9.txt) 4750176210]
  ]
  | test part { part1 }
}

# ignore
export def "test part2" [] {
  [
    [input expected];
    [$smallInput 24]
    [(open ./resources/day9.txt) 1574684850]
  ]
  | test part { part2 }
}
