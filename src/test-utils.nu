use std/assert

export def "test part" [part: closure]: table<input: string, expected: int> -> nothing {
  for it in ($in | enumerate) {
    timeit {
      assert equal ($it.item.input | do $part) $it.item.expected
    }
    | print $"✔️ (ansi green)Test case ($it.index + 1):⏱️(ansi bo)(ansi u)(if $in > 5sec { ansi red } else { ansi green })($in)(ansi reset)(if $in > 5sec { '🥲' })"
  }
}
