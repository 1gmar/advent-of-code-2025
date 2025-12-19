use test-utils.nu 'test part'

def rect-area [other: record]: record -> int {
  (($in.x - $other.x | math abs) + 1) * (($in.y - $other.y | math abs) + 1)
}

def for-pairs-in-quadrants-do [quad1: closure quad2: closure action: closure]: table -> list<any> {
  let pts = $in
  let q2_slice = $pts | where $quad2
  $pts | where $quad1 | each --flatten {|p1| $q2_slice | each { do $action $p1 $in } }
}

def get-quadrant-edge-criteria []: table -> record {
  let pts = $in
  let mid_xy = $pts | math avg | update cells { math floor }
  {
    upper_left: {|it| $it.x < $mid_xy.x and $it.y < $mid_xy.y }
    lower_right: {|it| $it.x >= $mid_xy.x and $it.y >= $mid_xy.y }
    upper_right: {|it| $it.x >= $mid_xy.x and $it.y < $mid_xy.y }
    lower_left: {|it| $it.x < $mid_xy.x and $it.y >= $mid_xy.y }
  }
}

def for-opposite-quadrants-do [action: closure]: table -> list<any> {
  let pts = $in
  let qec = $pts | get-quadrant-edge-criteria
  $pts
  | for-pairs-in-quadrants-do $qec.upper_left $qec.lower_right $action
  | append ($pts | for-pairs-in-quadrants-do $qec.upper_right $qec.lower_left $action)
}

def for-all-quadrants-do [action: closure]: table -> list<any> {
  let pts = $in
  let qec = $pts | get-quadrant-edge-criteria
  $pts
  | for-pairs-in-quadrants-do $qec.lower_left $qec.lower_right $action
  | append ($pts | for-pairs-in-quadrants-do $qec.upper_left $qec.lower_right $action)
  | append ($pts | for-pairs-in-quadrants-do $qec.upper_right $qec.lower_left $action)
  | append ($pts | for-pairs-in-quadrants-do $qec.lower_left $qec.upper_left $action)
  | append ($pts | for-pairs-in-quadrants-do $qec.upper_left $qec.upper_right $action)
  | append ($pts | for-pairs-in-quadrants-do $qec.upper_right $qec.lower_right $action)
}

def is-valid [p1: record p2: record]: record -> bool {
  let segments = $in
  if not ($segments | is-inside-polygon {x: $p1.x y: $p2.y}) { return false }
  if not ($segments | is-inside-polygon {x: $p2.x y: $p1.y}) { return false }
  let verts = $segments.v
  let horz = $segments.h
  let range = [$p1 $p2] | {x: ($in | get x | sort) y: ($in | get y | sort)}
  let any_vert = $verts | skip while { $in.x <= $range.x.0 } | take while { $in.x < $range.x.1 }
  | any { $range.y.0 + 1 in $in.range or $range.y.1 - 1 in $in.range }
  if $any_vert { return false }
  $horz | skip while { $in.y <= $range.y.0 } | take while { $in.y < $range.y.1 }
  | all { $range.x.0 + 1 not-in $in.range and $range.x.1 - 1 not-in $in.range }
}

def collect-segments []: table -> record {
  let pts = $in
  $pts | append [$pts.0] | window 2 | reduce --fold {h: [] v: []} {|seg acc|
    match $seg {
      [{x: $x1 y: $y1} {x: $x2 y: $y2}] => {
        if $x1 == $x2 {
          $acc | update v { $in | append [{x: $x1 range: $y1..$y2}] }
        } else {
          $acc | update h { $in | append [{y: $y1 range: $x1..$x2}] }
        }
      }
    }
    | update v { $in | sort-by x }
    | update h { $in | sort-by y }
  }
}

def is-inside-polygon [point: record]: record -> bool {
  let segments = $in
  let y_limits = $segments.h | where range has $point.x
  | reduce --fold {min: 100000 max: 0} {|s acc|
    {min: ([$acc.min $s.y] | math min) max: ([$acc.max $s.y] | math max)}
  }
  let x_limits = $segments.v | where range has $point.y
  | reduce --fold {min: 100000 max: 0} {|s acc|
    {min: ([$acc.min $s.x] | math min) max: ([$acc.max $s.x] | math max)}
  }
  $point.x in $x_limits.min..$x_limits.max and $point.y in $y_limits.min..$y_limits.max
}

def part1 []: string -> int {
  lines
  | parse '{x},{y}'
  | update cells { into int }
  | for-opposite-quadrants-do {|p1 p2| $p1 | rect-area $p2 }
  | math max
}

def part2 []: string -> int {
  let pts = lines | parse '{x},{y}' | update cells { into int }
  let segments = $pts | collect-segments
  $pts
  | for-all-quadrants-do {|p1 p2| if ($segments | is-valid $p1 $p2) { $p1 | rect-area $p2 } }
  | math max
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
