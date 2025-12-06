use src *

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
    | each {|test| [$"print '⏳ (ansi yellow)Running test: (ansi bo)($test)(ansi reset)'" $test] }
    | flatten
    | str join ";"
  )
  nu --commands $"use src * ; ($test_commands)"

  print $"✅ (ansi bo)(ansi green)All tests passed!(ansi reset)"
}
