use utils.nu [ rational replicate ]
use test-utils.nu 'test part'

def next-generation [machine_line: record]: table -> record {
  let queue = $in
  let diagram = $queue | first
  if $diagram.item == $machine_line.target { return {out: $diagram.count} }
  let next_diags = $machine_line.buttons
    | skip ($diagram.index + 1)
    | each { update item { $in bit-xor $diagram.item } | insert count ($diagram.count + 1) }
  {
    next: ($queue | skip | append $next_diags)
  }
}

def find-min-presses-for-lights-config []: record -> int {
  let machine_line = $in
  generate {|queue| $queue | next-generation $machine_line } [{item: 0 count: 0 index: -1}]
  | first
}

def parse-group [l_delim: string r_delim: string --binary (-b)]: string -> list<int> {
  str trim -l -c $l_delim | str trim -r -c $r_delim | split row ','
  | into int -r (if $binary { 2 } else 10)
}

def parse-machine-line-diagram []: string -> record {
  let line = $in | split row ' '
  {
    target: (
      $line
      | first | str replace -a '.' '0' | str replace -a '#' '1' | str reverse
      | parse-group -b ']' '['
      | first
    )
    buttons: (
      $line | skip | drop
      | each { parse-group '(' ')' | reduce -f 0 {|x n| $n bit-or 2 ** $x } }
      | enumerate
    )
  }
}

def parse-machine-line-joltage []: string -> record {
  let line = $in | split row ' '
  let target = $line | last | parse-group '{' '}'
  {
    target: $target
    buttons: (
      $line | skip | drop | each {
        let b = parse-group '(' ')'
        0..<($target | length) | each { if $in in $b { 1 } else 0 }
      }
    )
  }
}

def sum-cols []: table -> record {
  let input = $in
  $input | values
  | each { rational sum } | zip ($input | columns)
  | reduce -f {} {|it| insert $it.1 $it.0 }
}

def is-basic-variable []: list<oneof<int, record>> -> bool {
  if not ($in | is-integer-solution) { return false }
  let col = $in | each { rational numerator }
  ($col | math sum) == 1 and ($col | sort | uniq) == [0 1]
}

def is-integer-solution []: list<oneof<int, record>> -> bool {
  all { rational is-integer }
}

def basic-solution-vars []: table -> list<any> {
  let table = $in | drop
  let x_cols = $table | columns | where $it starts-with 'x'
  let solution_rows = $table
    | select ...$x_cols | values
    | where ($it | is-basic-variable)
    | each { enumerate | where ($it.item | rational compare 1) == 0 | first | get index }
  $table | get c | select ...$solution_rows
}

def find-pivot-col [sort_criteria: closure]: table -> string {
  let table = $in
  let col_idx = $table
    | last | reject c | values | enumerate
    | sort-by -c $sort_criteria
    | get index
    | first
  $table | columns | get $col_idx
}

def find-pivot-row [col: string]: table -> int {
  let table = $in | drop
  $table
  | get $col
  | zip ($table | get c) | enumerate
  | where ($it.item.0 | rational compare 0) > 0
  | each { update item {|t| $t.item.1 | rational div $t.item.0 } }
  | where ($it.item | rational compare 0) >= 0
  | sort-by -c {|l r| ($l.item | rational compare $r.item) < 0 }
  | first | get index
}

def max-step-in []: table -> table {
  let table = $in
  let col = $table | find-pivot-col {|l r| ($l.item | rational compare $r.item) < 0 }
  $table | step-in $col
}

def min-step-in []: table -> table {
  let table = $in
  let col = $table | find-pivot-col {|l r|
      if ($l.item | rational compare $r.item) == 0 {
        $l.index < $r.index
      } else {
        ($l.item | rational compare $r.item) > 0
      }
    }
  $table | step-in $col
}

def step-in [pivot_col: string]: table -> table {
  let table = $in
  let pivot_row = $table | find-pivot-row $pivot_col
  let updated_pr_table = $table | update $pivot_row {
      update cells -c ($in | columns) {
        $in | rational div ($table | get $pivot_row | get $pivot_col)
      }
    }
  $updated_pr_table | enumerate | each {|r|
    match ($r.item | get $pivot_col) {
      0 => $r.item
      _ if $r.index == $pivot_row => $r.item
      $v => {
        let multiplier = $v | rational abs
        $r.item | values
        | zip ($updated_pr_table | get $pivot_row | values)
        | zip ($r.item | columns)
        | reduce -f {} {|it|
          insert $it.1 {
            if ($v | rational compare 0) < 0 {
              $it.0.0 | rational add ($multiplier | rational mul $it.0.1)
            } else {
              $it.0.0 | rational add ($multiplier | rational mul (-1) | rational mul $it.0.1)
            }
          }
        }
      }
    }
  }
}

def plane-cut-with-biggest-fractional-part []: table -> record {
  drop | where not ($it.c | rational is-integer) | update cells {|cell|
    -1 | rational mul $cell | rational add ($cell | rational floor)
  }
  | uniq
  | sort-by -c {|l r| ($l.c | rational compare $r.c) < 0 }
  | first
}

def add-plane-cut [cut: record]: table -> table {
  let opt_table = $in
  let height = $opt_table | drop | length
  let sv_index = $opt_table | columns | where $it starts-with 's' | length
  let table_with_cut = $opt_table | drop | append [$cut]
    | insert $"s($sv_index)" 0
    | update $height { update $"s($sv_index)" 1 }
  $table_with_cut
  | append ($opt_table | last)
  | default 0 ...($table_with_cut | columns)
  | move --last c
}

def generate-artificial-vars-matrix [h: int w: int] {
  let ones = $h | replicate 1 | enumerate | transpose -i -r | transpose -i 'a0'
  1..<$h | reduce -f $ones {|it|
    insert $"a($it)" 0 | update $it { roll right -c -b $it }
  }
}

def add-artificial-vars []: table -> table {
  let table = $in
  let height = $table | drop | length
  let width = $table | columns | drop | length
  let artificial_vars = generate-artificial-vars-matrix $height $width
  let table_with_vars = $table
    | merge $artificial_vars
    | default 0 ...($artificial_vars | columns)
    | append ($table | last | update cells { 0 })
    | default (-1) ...($artificial_vars | columns)
    | default 0 c
    | move --last c
  let artificial_objective = $table_with_vars
    | sum-cols
    | update cells -c ($table | columns | drop) { $in | rational add 1 }
  $table_with_vars
  | drop
  | append $artificial_objective
}

def remove-artificial-vars []: table -> table {
  let table = $in
  let table_no_vars = $table
    | reject ...($table | columns | where $it starts-with 'a')
  $table_no_vars
  | drop 2
  | append ($table_no_vars | last 2 | sum-cols)
}

def build-simplex-tableau []: record -> table {
  let machine_line = $in
  let c_col = $machine_line.target | enumerate | transpose -i -r | transpose -i c
  let table = $machine_line.buttons
    | each { enumerate | transpose -i -r -d }
    | enumerate | flatten | transpose -i -r
    | rename -b { 'x' + $in }
    | merge $c_col
  $table
  | append ($table | last | update cells { -1 } | update cells -c [c] { 0 })
}

def loop-to-optimal-state []: table -> table {
  let table = $in
  generate {|t|
    let is_optimal_state = $t
      | last | values | drop
      | all { ($in | rational compare 0) <= 0 }
    if $is_optimal_state { {out: $t} } else {next: ($t | min-step-in)}
  } $table
  | first
}

def max-step-until-c-col-is-positive []: table -> table {
  let table = $in
  generate {|t|
    let is_c_col_pos = $t | get c | all { ($in | rational compare 0) >= 0 }
    if $is_c_col_pos { {out: $t} } else {next: ($t | max-step-in)}
  } $table
  | first
}

def cut-the-plane-towards-next-solution []: table -> record {
  let table = $in
  let cut = $table | plane-cut-with-biggest-fractional-part
  let entering_cut_col = $cut
    | items {|c v| [$c $v] }
    | where ($it.1 | rational compare 0) < 0
    | first | first
  let next_table = $table
    | add-plane-cut $cut
    | step-in $entering_cut_col
    | max-step-until-c-col-is-positive
    | loop-to-optimal-state
  if ($next_table | basic-solution-vars | is-integer-solution) {
    {out: $next_table}
  } else {
    next: $next_table
  }
}

def phase-1 []: table -> table {
  add-artificial-vars | loop-to-optimal-state | remove-artificial-vars
}

def phase-2 []: table -> table {
  let opt_table = loop-to-optimal-state
  if ($opt_table | basic-solution-vars | is-integer-solution) { return $opt_table }
  generate {|t| $t | cut-the-plane-towards-next-solution } $opt_table
  | first
}

def find-min-presses-for-joltage-config []: record -> int {
  build-simplex-tableau
  | phase-1
  | phase-2
  | basic-solution-vars
  | math sum
  | rational numerator
}

def serialize-problem []: record -> string {
  let machine_line = $in
  let obj_fun = $machine_line.buttons | enumerate | get index | str join ','
  let button_matrix = $machine_line.buttons
    | each { enumerate | transpose -i -r -d }
    | enumerate | flatten | transpose -i -r
  let constraint_xs = $button_matrix | each {|r|
      $r | columns | zip ($r | values) | where $it.1 == 1 | each { get 0 } | str join ','
    }
  let constraints = $constraint_xs
    | zip $machine_line.target
    | each { $in.0 + '=' + ($in.1 | into string) }
    | str join '|'
  $obj_fun + '|' + $constraints
}

def delegate-to-prolog []: list<string> -> string {
  scryer-prolog -g "use_module('./src/simplex.pl')." -g "simplex_wrapper:main" -- ...$in
}

def part1 []: string -> int {
  lines
  | each { parse-machine-line-diagram | find-min-presses-for-lights-config }
  | math sum
}

def part2 []: string -> int {
  lines
  | each { parse-machine-line-joltage | find-min-presses-for-joltage-config }
  | math sum
}

def part2-prolog []: string -> int {
  lines
  | each { parse-machine-line-joltage | serialize-problem }
  | delegate-to-prolog
  | into int
}

const smallInput = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 7]
    [(open ./resources/day10.txt) 509]
  ]
  | test part { part1 }
}

# ignore
export def "test part2" [] {
  [
    [input expected];
    [$smallInput 33]
    [(open ./resources/day10.txt) 20083]
  ]
  | test part { part2 }
}

export def "test part2 via prolog" [] {
  [
    [input expected];
    [$smallInput 33]
    [(open ./resources/day10.txt) 20083]
  ]
  | test part { part2-prolog }
}
