use (path self ../src/day8.nu) *
use test-utils.nu 'test part'

const smallInput = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"

export def "test part1" [] {
  [
    [input param expected];
    [$smallInput 10 40]
    [(open ./resources/day8.txt) 1000 140008]
  ]
  | test part {|p| part1 $p }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 25272]
    [(open ./resources/day8.txt) 9253260633]
  ]
  | test part { part2 }
}
