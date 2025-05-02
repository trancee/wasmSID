///|
let debug = false

///|
fn main {
  try {
    // instructions!()
    // instructions!(path="tests/65x02/nes6502/v1/", decimal_mode=false)
    // dormann!()
    // lorenz!()
    // nestest!()
    // sidtest!()
    benchmark!()
  } catch {
    error => println(error)
  }
}
