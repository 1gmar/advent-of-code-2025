use test-utils.nu 'test part'

def parse-input []: string -> record {
  let segments = lines | split list ''
  let shapes = $segments
    | drop
    | each {
      skip | ($in | length) * ($in.0 | str length)
    }
  let regions = $segments
    | last
    | each {
      split row ':' | {
        area: ($in.0 | split row 'x' | into int | math product)
        target: ($in.1 | split words | into int)
      }
    }
  {shapes: $shapes regions: $regions}
}

def part1 []: string -> int {
  let input = parse-input
  $input.regions
  | where ($it.target | zip ($input.shapes) | each { math product } | math sum) <= $it.area
  | length
}

export def "test part1" [] {
  [
    [input expected];
    [(open ./resources/day12.txt) 519]
  ]
  | test part { part1 }
}
