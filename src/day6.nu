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

export def part1 []: string -> int {
  solve-problems { str trim | split row -r '\s+' }
}

export def part2 []: string -> int {
  solve-problems { split chars } { each { str join | str trim } | split list { is-empty } }
}
