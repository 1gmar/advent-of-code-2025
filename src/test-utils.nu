use std/assert

export def "test part" [part: closure]: table<input: string, expected: int> -> nothing {
  for it in ($in | enumerate) {
    timeit {
      assert equal ($it.item.input | do $part $in) $it.item.expected
    }
    | print $"✔️ (ansi green)Test case ($it.index + 1):⏱️(ansi bo)(ansi u)($in)(ansi reset)"
  }
}
