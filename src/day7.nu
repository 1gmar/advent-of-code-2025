use utils.nu replicate
use test-utils.nu 'test part'

def trim-overlapping-beams [] {
  {|cell prev|
    match $prev {
      [] => [$cell]
      [{c: '|' i: $i} ..$_] if $i == $cell.i => $prev
      [{c: _ i: $i} ..$_] if $i == $cell.i => ($prev | skip | prepend [$cell])
      _ => ($prev | prepend [$cell])
    }
  }
}

def propagate-beams [row: record]: record -> record {
  match $in.item {
    ['S' '.'] => {cell: {c: '|' i: $in.index}}
    ['|' '.'] => {cell: {c: '|' i: $in.index}}
    ['|' '^'] => {
      cell: [{c: '|' i: ($in.index - 1)} {c: '^' i: $in.index} {c: '|' i: ($in.index + 1)}]
      split: {x: $in.index y: $row.index}
    }
    _ => {cell: {c: '.' i: $in.index}}
  }
}

def fold-diagram-line [] {
  {|row acc|
    let line_data = $acc.fold | zip $row.item | enumerate | each { propagate-beams $row }
    let line_splits = $line_data | get split? | where $it != null
    let beamed_line = $line_data | get cell | flatten
    | reduce --fold [] (trim-overlapping-beams)
    | get c | reverse
    {fold: $beamed_line splits: ($acc.splits | append $line_splits)}
  }
}

def collect-timeline-splits []: string -> record {
  let diagram = lines | each { split chars }
  let src_line = $diagram.0
  $diagram | skip | enumerate
  | reduce --fold {fold: $src_line splits: []} (fold-diagram-line)
}

def find-target-node-on [side: int split: record sink: int]: list<record> -> int {
  where x == ($split.x + $side)
  | get index
  | default -e [$sink]
  | first
}

def link-split-nodes [splits: list<record> sink: int]: record -> list<int> {
  let split = $in
  let splits_below = $splits | where y > $split.y
  [
    ($splits_below | find-target-node-on -1 $split $sink)
    ($splits_below | find-target-node-on 1 $split $sink)
  ]
}

def count-all-paths [] {
  {|node pathCountMap|
    $node.item | reduce --fold $pathCountMap {|target acc|
      $acc | update $target {|old| $acc | get $node.index | $in + $old }
    }
  }
}

def part1 []: string -> int {
  collect-timeline-splits | get splits | length
}

def part2 []: string -> int {
  let splits = collect-timeline-splits | get splits | enumerate | flatten
  let sink = $splits | length
  $splits
  | each { link-split-nodes $splits $sink } | enumerate
  | reduce --fold ($sink | replicate 0 | prepend [1]) (count-all-paths)
  | get $sink
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
