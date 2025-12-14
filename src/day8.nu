use test-utils.nu 'test part'

def sq-distance [other: list<int>]: list<int> -> int {
  ($in.0 - $other.0) ** 2 + ($in.1 - $other.1) ** 2 + ($in.2 - $other.2) ** 2
}

def sort-pairs-by-distance []: table -> table {
  let pts = $in
  $pts | each --flatten {|p1|
    $pts | skip ($p1.index + 1) | each {|p2|
      {
        p1: $p1
        p2: $p2
        d: ($p1.item | sq-distance $p2.item)
      }
    }
  } | sort-by d
}

def find-root [box_sets: table]: record -> record {
  let p = $in
  generate {|it| if $it.prev == null { {out: $it} } else {next: ($box_sets | get $it.prev)} } $p
  | first
}

def merge-boxes [box1: record box2: record]: table -> table {
  update $box2.node { update prev $box1.node }
  | update $box1.node { update size { $in + $box2.size } }
}

def connect [box_sets: table]: record -> record {
  let conn = $in
  $box_sets
  | get $conn.p1.index $conn.p2.index
  | each { find-root $box_sets }
  | match $in {
    [$r1 $r2] if $r1.node == $r2.node => {box_sets: $box_sets changed: false}
    [$r1 $r2] => {
      $box_sets
      | if $r1.size >= $r2.size { merge-boxes $r1 $r2 } else { merge-boxes $r2 $r1 }
      | {box_sets: $in changed: true}
    }
  }
}

def connect-all-boxes [] {
  {|it acc|
    $it | connect $acc.box_sets
    | match $in {
      {changed: true} => {box_sets: $in.box_sets size: ($acc.size - 1)}
      {changed: false} => {box_sets: $in.box_sets size: $acc.size}
    }
    | if $in.size > 1 { {next: $in} } else {out: $it}
  }
}

def for-closest-pairs-do [pipeline: closure]: string -> int {
  let pts = lines | each { split words | each { into int } } | enumerate
  let size = $pts | length
  let box_sets = 0..($size - 1) | each { {node: $in prev: null size: 1} }
  $pts
  | sort-pairs-by-distance
  | do $pipeline $box_sets $size
  | math product
}

def part1 [nr_of_conns: int]: string -> int {
  for-closest-pairs-do {|box_sets _|
    first $nr_of_conns
    | reduce --fold {box_sets: $box_sets} {|it acc| $it | connect $acc.box_sets }
    | get box_sets | where prev == null | get size
    | sort -r
    | first 3
  }
}

def part2 []: string -> int {
  for-closest-pairs-do {|box_sets size|
    | generate (connect-all-boxes) {box_sets: $box_sets size: $size}
    | first
    | get p1.item.0 p2.item.0
  }
}

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
