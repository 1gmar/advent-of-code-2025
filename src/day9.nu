use test-utils.nu 'test part'

def rect-area [other: record]: record -> int {
  (($in.x - $other.x | math abs) + 1) * (($in.y - $other.y | math abs) + 1)
}

def for-all-pairs-do [action: closure]: table -> list<any> {
  let pts = $in
  $pts | enumerate | each --flatten {|p1|
    $pts | skip ($p1.index + 1) | each {|p2|
      do $action $p1.item $p2
    }
  }
}

def intersects [xRange: list<int> yRange: list<int>]: table -> bool {
  skip while { $in.c <= $xRange.0 }
  | take while { $in.c < $xRange.1 }
  | get range
  | any { $in has $yRange.0 + 1 or $in has $yRange.1 - 1 }
}

def is-valid [p1: record p2: record]: record -> bool {
  let segments = $in
  let range = [$p1 $p2] | {x: ($in | get x | sort) y: ($in | get y | sort)}
  ($segments.v | intersects $range.x $range.y) or ($segments.h | intersects $range.y $range.x)
  | not $in
}

def collect-segments []: table -> record {
  let pts = $in
  $pts | append [$pts.0] | window 2 | reduce --fold {h: [] v: []} {|seg acc|
    match $seg {
      [{x: $x1 y: $y1} {x: $x2 y: $y2}] => {
        if $x1 == $x2 {
          $acc | update v { $in | append [{c: $x1 range: $y1..$y2}] }
        } else {
          $acc | update h { $in | append [{c: $y1 range: $x1..$x2}] }
        }
      }
    }
    | update v { $in | sort-by c }
    | update h { $in | sort-by c }
  }
}

def parse-points []: string -> table {
  lines
  | parse '{x},{y}'
  | update cells { into int }
}

def part1 []: string -> int {
  parse-points
  | for-all-pairs-do {|p1 p2| $p1 | rect-area $p2 }
  | math max
}

def part2 []: string -> int {
  let pts = parse-points
  let segments = $pts | collect-segments
  $pts
  | for-all-pairs-do {|p1 p2| {p1: $p1 p2: $p2 s: ($p1 | rect-area $p2)} }
  | sort-by -r s
  | where ($segments | is-valid $it.p1 $it.p2)
  | first
  | get s
}

const smallInput = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 50]
    [(open ./resources/day9.txt) 4750176210]
  ]
  | test part { part1 }
}

# ignore
export def "test part2" [] {
  [
    [input expected];
    [$smallInput 24]
    [(open ./resources/day9.txt) 1574684850]
  ]
  | test part { part2 }
}
