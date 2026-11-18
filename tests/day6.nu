use (path self ../src/day6.nu) *
use test-utils.nu 'test part'

const smallInput = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 4277556]
    [(open ./resources/day6.txt) 3261038365331]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 3263827]
    [(open ./resources/day6.txt) 8342588849093]
  ]
  | test part { part2 }
}
