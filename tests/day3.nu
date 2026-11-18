use (path self ../src/day3.nu) *
use test-utils.nu 'test part'

const smallInput = "987654321111111
811111111111119
234234234234278
818181911112111"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 357]
    [(open ./resources/day3.txt) 17343]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 3121910778619]
    [(open ./resources/day3.txt) 172664333119298]
  ]
  | test part { part2 }
}
