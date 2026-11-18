use (path self ../src/day11.nu) *
use test-utils.nu 'test part'

const smallInput = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

export def "test part1" [] {
  [
    [input expected];
    [$smallInput 5]
    [(open ./resources/day11.txt) 552]
  ]
  | test part { part1 }
}

const smallInput2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

export def "test part2" [] {
  [
    [input expected];
    [$smallInput2 2]
    [(open ./resources/day11.txt) 307608674109300]
  ]
  | test part { part2 }
}
