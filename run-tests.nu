use src *

def render-test-part-text [] {
  {|part|
    let test = [$part.item.day $part.item.part] | str join ' '
    [$"print '├⏳ (ansi yellow)Running test: (ansi bo)($test)(ansi reset)'" $test]
  }
}

def main [testPattern: string = '^day\d\d? test'] {
  print $"💡 (ansi yellow)(ansi bo)Running tests...(ansi reset)"
  let tests_criteria = {|it|
    (
      $it.type == "custom"
      and $it.name =~ $testPattern
      and not ($it.description | str starts-with 'ignore')
    )
  }
  let test_commands = (
    scope commands
    | where $tests_criteria
    | get name
    | parse '{day} {part}'
    | group-by day
    | items {|day item|
      let day_cap = $day | str capitalize
      [$"print '🧩(ansi yb)  ($day_cap):(ansi reset)'"]
      | append ($item | enumerate | each --flatten (render-test-part-text))
      | append [$"print '└☀️ (ansi gb)($day_cap) passed!(ansi reset)'"]
    }
    | flatten
    | str join ";"
  )
  nu --commands $"use src * ; ($test_commands)"

  print $"✅ (ansi bo)(ansi green)All tests passed!(ansi reset)"
}
