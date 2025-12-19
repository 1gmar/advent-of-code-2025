use utils.nu replicate
use test-utils.nu 'test part'

def parse-line []: record -> table {
  let line = $in
  $line.item
  | split chars | enumerate
  | each { if $in.item == '^' { {x: $in.index y: $line.index} } }
}

def diagram-to-graph []: string -> table {
  lines
  | skip 2 | enumerate
  | each --flatten { parse-line }
  | enumerate | flatten
}

def find-target-node-on [targetX: int sink: int]: table -> int {
  where x == $targetX
  | get index
  | default -e [$sink]
  | first
}

def link-split-nodes [splits: table sink: int]: record -> list<int> {
  let split = $in
  let splits_below = $splits | skip ($split.index + 1)
  [
    ($splits_below | find-target-node-on ($split.x - 1) $sink)
    ($splits_below | find-target-node-on ($split.x + 1) $sink)
  ]
}

def count-all-paths [] {
  {|node pathCountMap|
    $node.item | reduce --fold $pathCountMap {|target acc|
      $acc | update $target {|old| $acc | get $node.index | $in + $old }
    }
  }
}

def for-nodes-do [pipeline: closure]: string -> int {
  let nodes = diagram-to-graph
  let sink = $nodes | length
  $nodes | do $pipeline $nodes $sink
}

def part1 []: string -> int {
  for-nodes-do {|nodes sink| each --flatten { link-split-nodes $nodes $sink } | uniq | length }
}

def part2 []: string -> int {
  for-nodes-do {|nodes sink|
    each { link-split-nodes $nodes $sink } | enumerate
    | reduce --fold ($sink | replicate 0 | prepend [1]) (count-all-paths)
    | get $sink
  }
}

const smallInput = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 21]
    [(open ./resources/day7.txt) 1585]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 40]
    [(open ./resources/day7.txt) 16716444407407]
  ]
  | test part { part2 }
}
