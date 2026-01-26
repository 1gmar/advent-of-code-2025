export def replicate [this: any]: int -> list<any> {
  1..$in | each { $this }
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
    let common_den = lcm $term1.den $term2.den
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
    $term1.num * $term2.den - $term2.num * $term1.den
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
    if ($result.den < 0) {
      {num: (-1 * $result.num) den: (-1 * $result.den)}
    } else $result
  }

  export def numerator []: oneof<int, record<num: int, den: int>> -> int {
    match $in { {$num} => $num $i => $i }
  }

  export def sum []: [
    list<oneof<int, record<num: int, den: int>>> -> record<num: int, den: int>
  ] {
    reduce {|it| add $it }
  }

  def gcd [m: int n: int]: nothing -> int {
    match ([$m $n] | math abs) {
      [0 $snd] => $snd
      [$fst 0] => $fst
      [$fst $snd] => (gcd $snd ($fst mod $snd))
    }
  }

  def lcm [m: int n: int]: nothing -> int {
    let gcd = gcd $m $n
    $m * ($n // $gcd)
  }

  def wrap-if-int []: oneof<int, record<num: int, den: int>> -> record<num: int, den: int> {
    if ($in | describe) == int { {num: $in den: 1} } else $in
  }

  def simplify []: record<num: int, den: int> -> record<num: int, den: int> {
    let fraction = $in
    let divisor = gcd $fraction.num $fraction.den
    {
      num: ($fraction.num // $divisor)
      den: ($fraction.den // $divisor)
    }
  }
}
