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

export def part1 []: string -> int {
  let input = parse-input
  $input.regions
  | where ($it.target | zip ($input.shapes) | each { math product } | math sum) <= $it.area
  | length
}
