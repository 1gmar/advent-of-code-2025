use (path self ../src/day2.nu) *
use test-utils.nu 'test part'

const smallInput = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224, 1698522-1698528,446443-446449,38593856-38593862,565653-565659, 824824821-824824827,2121212118-2121212124"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 1227775554]
    [(open ./resources/day2.txt) 16793817782]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 4174379265]
    [(open ./resources/day2.txt) 27469417404]
  ]
  | test part { part2 }
}
