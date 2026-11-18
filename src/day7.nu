use utils.nu replicate

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

export def part1 []: string -> int {
  for-nodes-do {|nodes sink| each --flatten { link-split-nodes $nodes $sink } | uniq | length }
}

export def part2 []: string -> int {
  for-nodes-do {|nodes sink|
    each { link-split-nodes $nodes $sink } | enumerate
    | reduce --fold ($sink | replicate 0 | prepend [1]) (count-all-paths)
    | get $sink
  }
}
