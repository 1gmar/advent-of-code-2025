export def replicate [this: any]: int -> list<any> {
  1..$in | each { $this }
}

export def gcd []: list<int> -> int {
  match $in {
    [0 $snd] => $snd
    [$fst 0] => $fst
    [$fst $snd] => (
      match ($fst mod $snd) {
        0 => $snd
        $rem => ([$snd $rem] | gcd)
      }
    )
  }
}

export def primes []: nothing -> list<int> {
  2.. | generate {|num primes = []|
    match ($primes | all { $num mod $in != 0 }) {
      true => {next: ($primes | append [$num]) out: $num}
      false => {next: $primes}
    }
  }
}

export def lcm [num2: int]: int -> int {
  let num1 = $in
  generate {|row|
    match $row {
      [1 1] => {out: 1}
      [1 $x] => ($row | reverse | div-row | update next { reverse })
      _ => ($row | div-row)
    }
  } [$num1 $num2]
  | math product
}

def div-row []: list<int> -> record {
  let x = $in | first
  let y = $in | last
  let factor = primes | where ($x mod $it == 0) | first
  {
    next: [
      ($x // $factor)
      (if $y mod $factor == 0 { $y // $factor } else $y)
    ]
    out: $factor
  }
}

export module rational {

  export def abs []: oneof<int, record<num: int, den: int>> -> record<num: int, den: int> {
    wrap-if-int | values | math abs | {num: $in.0 den: $in.1}
  }

  export def add [other: oneof<int, record<num: int, den: int>>]: [
    oneof<int, record<num: int, den: int>> -> record<num: int, den: int>
  ] {
    let term1 = $in | wrap-if-int
    let term2 = $other | wrap-if-int
    let common_den = $term1.den | lcm $term2.den
    let mul1 = $common_den // $term1.den
    let mul2 = $common_den // $term2.den
    {num: ($mul1 * $term1.num + $mul2 * $term2.num) den: $common_den}
    | simplify
  }

  export def compare [other: oneof<int, record<num: int, den: int>>]: [
    oneof<int, record<num: int, den: int>> -> int
  ] {
    let term1 = $in | wrap-if-int
    let term2 = $other | wrap-if-int
    let common_den = $term1.den | lcm $term2.den
    let mul1 = $common_den // $term1.den
    let mul2 = $common_den // $term2.den
    $mul1 * $term1.num - $mul2 * $term2.num
  }

  export def floor []: record<num: int, den: int> -> int {
    $in.num // $in.den
  }

  export def is-integer []: oneof<int, record<num: int, den: int>> -> bool {
    match $in {
      $i if ($i | describe) == int => true
      {den: 1} => true
      _ => false
    }
  }

  export def mul [other: oneof<int, record<num: int, den: int>>]: [
    oneof<int, record<num: int, den: int>> -> record<num: int, den: int>
  ] {
    let factor1 = $in | wrap-if-int
    let factor2 = $other | wrap-if-int
    {num: ($factor1.num * $factor2.num) den: ($factor1.den * $factor2.den)}
    | simplify
  }

  export def div [other: oneof<int, record<num: int, den: int>>]: [
    oneof<int, record<num: int, den: int>> -> record<num: int, den: int>
  ] {
    let dividend = $in | wrap-if-int
    let divisor = $other | wrap-if-int
    let result = $dividend | mul {num: $divisor.den den: $divisor.num}
    let abs_vals = $result | values | math abs
    let sign = if $result.num != 0 {
      $result.num // $abs_vals.0 * $result.den // $abs_vals.1
    } else 1
    {num: ($sign * $abs_vals.0) den: $abs_vals.1}
  }

  export def numerator []: oneof<int, record<num: int, den: int>> -> int {
    match $in { {$num} => $num $i => $i }
  }

  export def sum []: [
    list<oneof<int, record<num: int, den: int>>> -> record<num: int, den: int>
  ] {
    reduce {|it| add $it }
  }

  def wrap-if-int []: oneof<int, record<num: int, den: int>> -> record<num: int, den: int> {
    if ($in | describe) == int { {num: $in den: 1} } else $in
  }

  def simplify []: record<num: int, den: int> -> record<num: int, den: int> {
    let fraction = $in
    let divisor = $fraction | values | gcd
    {
      num: ($fraction.num // $divisor)
      den: ($fraction.den // $divisor)
    }
  }
}
