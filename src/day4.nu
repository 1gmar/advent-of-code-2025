use test-utils.nu 'test part'

def create-columns [] {
  split chars
  | enumerate
  | reduce --fold {} {|x acc| $acc | insert $"($x.index)" $x.item }
}

def create-windowed-view [] {
  window 3
  | each {
    transpose 0 1 2 3
    | window 3
    | each { transpose 0 1 2 3 | skip 1 | reject '0' }
  }
}

def add-table-borders [] {
  let table = $in
  let border = $table.0
  | items {|k _| {k: $k v: '.'} }
  | reduce --fold {} {|row acc| $acc | insert $row.k $row.v }
  $table
  | prepend $border
  | append $border
  | insert 'right' '.'
  | enumerate | flatten
}

def count-@-cells-on-border [] {
  [
    ($in.0.'1' == '@')
    ($in.0.'2' == '@')
    ($in.0.'3' == '@')
    ($in.1.'1' == '@')
    ($in.1.'3' == '@')
    ($in.2.'1' == '@')
    ($in.2.'2' == '@')
    ($in.2.'3' == '@')
  ] | each { into int } | math sum
}

def count-@-neighbors-per-window [] {
  where $it.1.'2' == '@' | each { count-@-cells-on-border }
}

def get-cell-pos [row: int] {
  {|window|
    $window.item
    | count-@-cells-on-border
    | if $in < 4 { {row: $row col: $window.index} }
  }
}

def collect-@-cell-pos [] {
  {|row|
    $row.item
    | enumerate
    | where $it.item.1.'2' == '@'
    | each (get-cell-pos $row.index)
  }
}

def remove-cells-at [col: string rows: list<int>] {
  update $col {|row| if $row.index - 1 in $rows { 'x' } else { $row | get $col } }
}

def find-cell-pos-to-remove [] {
  create-windowed-view
  | enumerate
  | each --flatten (collect-@-cell-pos)
}

def update-table [table: table] {
  let rowsByCols = $in
  $rowsByCols
  | columns
  | reduce --fold $table {|col acc| $acc | remove-cells-at $col ($rowsByCols | get $col).row }
}

def part1 []: string -> int {
  lines
  | each { create-columns }
  | add-table-borders
  | create-windowed-view
  | each --flatten { count-@-neighbors-per-window }
  | where $it < 4
  | length
}

def part2 []: string -> int {
  let input = $in
  mut table = $input
  | lines
  | each { create-columns }
  | add-table-borders
  mut count = 0
  loop {
    let posToRemove = $table | find-cell-pos-to-remove
    let removed = $posToRemove | length
    if $removed > 0 { $count += $removed } else { break }
    let rowsByCols = $posToRemove | group-by col
    $table = $rowsByCols | update-table $table
  }
  $count
}

const smallInput = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 13]
    [(open ./resources/day4.txt) 1376]
  ]
  | test part { part1 }
}

export def "test part2 small input" [] {
  [
    [input expected];
    [$smallInput 43]
  ]
  | test part { part2 }
}

# ignore
export def "test part2 big input" [] {
  [
    [input expected];
    [(open ./resources/day4.txt) 8587]
  ]
  | test part { part2 }
}
