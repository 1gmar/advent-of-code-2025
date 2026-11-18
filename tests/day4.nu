use (path self ../src/day4.nu) *
use test-utils.nu 'test part'

const smallInput = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 13]
    [(open ./resources/day4.txt) 1376]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 43]
    [(open ./resources/day4.txt) 8587]
  ]
  | test part { part2 }
}
