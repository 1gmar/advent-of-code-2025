use test-utils.nu 'test part'

def reduce-values-with [op: string]: [
  list<int> -> int
  table -> record
] {
  match $op {
    '+' => (math sum)
    '*' => (math product)
  }
}

def solve-problems [line_parser: closure value_parser?: closure]: string -> int {
  let table = lines | each { do $line_parser | enumerate | transpose -r -d }
  let ops = $table | last | values | where $it in "+*"
  $table
  | drop
  | values
  | do ($value_parser | default { ({|| }) })
  | each { into int }
  | zip $ops
  | each {|t| $t.0 | reduce-values-with $t.1 }
  | math sum
}

def part1 []: string -> int {
  solve-problems { str trim | split row -r '\s+' }
}

def part2 []: string -> int {
  solve-problems { split chars } { each { str join | str trim } | split list { is-empty } }
}

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
