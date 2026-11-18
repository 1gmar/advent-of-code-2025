use (path self ../src/day12.nu) *
use test-utils.nu 'test part'

export def "test part1" [] {
  [
    [input expected];
    [(open ./resources/day12.txt) 519]
  ]
  | test part { part1 }
}
