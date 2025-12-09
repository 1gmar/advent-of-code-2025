use utils.nu replicate
use test-utils.nu 'test part'

def sum-up-table []: list<list<int>> -> int {
  each { math sum } | math sum
}

def combine-tables [op: closure other: list<list<int>>]: list<list<int>> -> list<list<int>> {
  zip $other | each {|t| $t.0 | zip $t.1 | each $op }
}

def count-@-cells-per-window []: list<list<int>> -> list<list<int>> {
  each { enumerate | transpose -r -d }
  | window 3
  | each {
    transpose -i 0 1 2 | window 3 | each {
      math sum
      | $in.'0' + $in.'1' + $in.'2'
      | $in > 4 | into int
    }
  }
}

def add-table-borders [border: list<int>]: list<list<int>> -> list<list<int>> {
  append [$border]
  | prepend [$border]
  | each { append [0] | prepend [0] }
}

def compute-table-for-remaining-rolls [border: list<int>]: list<list<int>> -> list<list<int>> {
  let table = $in
  $table
  | add-table-borders $border
  | count-@-cells-per-window
  | combine-tables { $in.0 bit-and $in.1 } $table
}

def parse-table []: string -> list<list<int>> {
  lines | each { split chars | each { $in == '@' | into int } }
}

def count-removed-rolls [table: list<list<int>>]: list<list<int>> -> int {
  combine-tables { $in.0 bit-xor $in.1 } $table | sum-up-table
}

def fixed-point-iteration [border: list<int>]: list<list<int>> -> list<list<int>> {
  let $table = $in
  generate {|table_i|
    $table_i
    | compute-table-for-remaining-rolls $border
    | if $in == $table_i { {out: $table_i} } else {next: $in}
  } $table | first
}

def part1 []: string -> int {
  let table = $in | parse-table
  let border = $table | length | replicate 0
  $table
  | compute-table-for-remaining-rolls $border
  | count-removed-rolls $table
}

def part2 []: string -> int {
  let table = $in | parse-table
  let border = $table | length | replicate 0
  $table
  | fixed-point-iteration $border
  | count-removed-rolls $table
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

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 43]
    [(open ./resources/day4.txt) 8587]
  ]
  | test part { part2 }
}
