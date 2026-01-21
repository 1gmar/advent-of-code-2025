use test-utils.nu 'test part'

def roots []: record -> list<string> {
  let graph = $in
  $graph | columns | where $it not-in ($graph | values | flatten)
}

def parse-graph []: string -> record {
  let graph = lines
    | each { split row ':' }
    | reduce -f {} {|it| insert $it.0 ($it.1 | split words) }
  $graph
  | values | flatten | uniq
  | where $it not-in ($graph | columns)
  | reduce -f $graph {|n| insert $n [] }
}

def top-sort []: record -> list<string> {
  let graph = $in
  let roots = $graph | roots
  generate {|state|
    match $state.queue {
      [] => { }
      [$node ..$_] => ($state | next-state $node)
    }
  } {queue: $roots graph: $graph}
}

def next-state [node: string]: record -> record {
  let state = $in
  let next_graph = $state.graph | update $node []
  let next_nodes = $state.graph
    | get $node
    | where $it not-in ($next_graph | values | flatten)
  {
    next: {
      queue: ($state.queue | skip | append $next_nodes)
      graph: $next_graph
    }
    out: $node
  }
}

def count-all-paths [graph: record]: list<string> -> record {
  let sorted_nodes = $in
  let root = $sorted_nodes | first
  let init_count = $graph | update cells { 0 } | update cells -c [$root] { 1 }
  $sorted_nodes
  | reduce -f $init_count {|n map|
    $graph | get $n | reduce -f $map {|t acc| update $t { $in + ($acc | get $n) } }
  }
}

def count-all-paths-between [source: string target: string graph: record]: list<string> -> int {
  skip until { $in == $source }
  | take until { $in == $target }
  | append [$target]
  | count-all-paths $graph
  | get $target
}

def part1 []: string -> int {
  let graph = parse-graph
  $graph
  | top-sort
  | count-all-paths-between you out $graph
}

def part2 []: string -> int {
  let graph = parse-graph
  let top_sorted_nodes = $graph | top-sort
  [
    ($top_sorted_nodes | count-all-paths-between svr fft $graph)
    ($top_sorted_nodes | count-all-paths-between fft dac $graph)
    ($top_sorted_nodes | count-all-paths-between dac out $graph)
  ]
  | math product
}

const smallInput = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 5]
    [(open ./resources/day11.txt) 552]
  ]
  | test part { part1 }
}

const smallInput2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

export def "test part2" [] {
  [
    [input expected];
    [$smallInput2 2]
    [(open ./resources/day11.txt) 307608674109300]
  ]
  | test part { part2 }
}
