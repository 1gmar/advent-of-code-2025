use test-utils.nu 'test part'

def num-len [num: int]: nothing -> int {
  $num | math log 10 | math floor | $in + 1
}

def repeat-seq [n: int len: int]: int -> int {
  let seq = $in
  let seqLen = $len // $n
  1..$n
  | reduce --fold 0 {|it acc| $seq * 10 ** ($len - $it * $seqLen) + $acc }
}

def next-invalid-id [nrOfSeq: int]: int -> int {
  let id = $in
  let len = num-len $id
  let sequence = $id // (10 ** ($len - $len // $nrOfSeq))
  generate {|seq| {out: ($seq | repeat-seq $nrOfSeq $len) next: ($seq + 1)} } $sequence
  | where $it >= $id
  | first
}

def invalid-id-generator [nrOfSeq: int hb: int]: int -> record<out: int, next: int> {
  let id = $in
  let idLen = num-len $id
  if $idLen mod $nrOfSeq != 0 { return {next: (10 ** $idLen)} }
  let nextId = $id | next-invalid-id $nrOfSeq
  if $nextId <= $hb { {out: $nextId next: ($nextId + 1)} }
}

def generate-id-for-nrOfSeq [lb: int hb: int]: int -> list<int> {
  let nrOfSeq = $in
  generate {|id| $id | invalid-id-generator $nrOfSeq $hb } $lb
}

def generate-invalid-ids [upperBoundNSeq?: int]: record -> list<int> {
  let range = $in
  2..($upperBoundNSeq | default $range.max.len)
  | each --flatten { generate-id-for-nrOfSeq $range.min.val $range.max.val }
  | uniq
}

def parse-range [] {
  split words
  | {
    min: {val: ($in.0 | into int) len: ($in.0 | str length)}
    max: {val: ($in.1 | into int) len: ($in.1 | str length)}
  }
}

def part1 []: string -> int {
  split row ','
  | each { parse-range }
  | each --flatten { generate-invalid-ids 2 }
  | math sum
}

def part2 []: string -> int {
  split row ','
  | each { parse-range }
  | each --flatten { generate-invalid-ids }
  | math sum
}

const smallInput = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224, 1698522-1698528,446443-446449,38593856-38593862,565653-565659, 824824821-824824827,2121212118-2121212124"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 1227775554]
    [(open ./resources/day2.txt) 16793817782]
  ]
  | test part { part1 }
}

export def "test part2" [] {
  [
    [input expected];
    [$smallInput 4174379265]
    [(open ./resources/day2.txt) 27469417404]
  ]
  | test part { part2 }
}
