use src *

def main [testPattern: string = '^day\d\d? test'] {
  print $"💡 (ansi yellow)(ansi bo)Running tests...(ansi reset)"
  let test_commands = (
    scope commands
    | where ($it.type == "custom") and ($it.name =~ $testPattern)
    | get name
    | each {|test| [$"print '(ansi yellow)Running test: (ansi bo)($test)(ansi reset)'" $test] }
    | flatten
    | str join ";"
  )
  nu --commands $"use src * ; ($test_commands)"

  print $"✅ (ansi bo)(ansi green)All tests passed!(ansi reset)"
}
