use utils.nu replicate
use test-utils.nu 'test part'

def next-generation [machine_line: record]: table -> record {
  let queue = $in
  let path = $queue | first
  let next_diags = $machine_line.buttons
    | skip ($path.index + 1)
    | each { update item { $in bit-xor $path.item } }
  if ($next_diags | any { $in.item == $machine_line.target }) {
    return {out: ($path.count + 1)}
  }
  {next: ($queue | skip | append ($next_diags | each { insert count ($path.count + 1) }))}
}

def find-min-lights-config-steps []: record -> int {
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

def part1 []: string -> int {
  lines
  | each { parse-machine-line-diagram | find-min-lights-config-steps }
  | math sum
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

export def "test part2 via prolog" [] {
  [
    [input expected];
    [$smallInput 33]
    [(open ./resources/day10.txt) 20083]
  ]
  | test part { part2-prolog }
}
