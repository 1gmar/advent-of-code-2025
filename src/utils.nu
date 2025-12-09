export def replicate [this: any]: int -> list<any> {
  1..$in | each { $this }
}
