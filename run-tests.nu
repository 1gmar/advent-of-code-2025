use src *

def main [] {
  print "Running tests..."
  let test_commands = (
    scope commands
    | where ($it.type == "custom") and ($it.name =~ '^day\d\d? test')
    | get name
    | each {|test| [$"print 'Running test: ($test)'" $test] }
    | flatten
    | str join ";"
  )
  nu --commands $"use src * ; ($test_commands)"

  print "Tests completed successfully!"
}
