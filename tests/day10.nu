use (path self ../src/day10.nu) *
use test-utils.nu 'test part'

const smallInput = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 7]
    [(open ./resources/day10.txt) 509]
  ]
  | test part { part1 }
}

# ignore
export def "test part2" [] {
  [
    [input expected];
    [$smallInput 33]
    [(open ./resources/day10.txt) 20083]
  ]
  | test part { part2 }
}

export def "test part2 via prolog" [] {
  [
    [input expected];
    [$smallInput 33]
    [(open ./resources/day10.txt) 20083]
  ]
  | test part { part2-prolog }
}
