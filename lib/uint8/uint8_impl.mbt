//
// UInt8
//

///|
pub impl Default for UInt8 with default() {
  DEFAULT_VALUE
}

///|
pub impl Eq for UInt8 with op_equal(self, other) {
  self.to_int() == other.to_int()
}

///|
pub impl Compare for UInt8 with compare(self, other) {
  self.to_int().compare(other.to_int())
}

///|
pub impl Hash for UInt8 with hash(self) {
  self.to_int()
}

///|
pub impl Hash for UInt8 with hash_combine(self, hasher) {
  hasher.combine_int(self.to_int())
}

///|
pub impl Show for UInt8 with output(self, logger) -> Unit {
  logger.write_string(self.to_hex())
}

///| 
/// Operator Overloading 
///

///|
pub impl Add for UInt8 with op_add(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() + other.to_int()) // FIXME: Overflow
}

///|
pub impl Sub for UInt8 with op_sub(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() - other.to_int()) // FIXME: Underflow
}

///|
pub impl Mul for UInt8 with op_mul(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() * other.to_int()) // FIXME: Overflow
}

///|
pub impl Div for UInt8 with op_div(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() / other.to_int()) // FIXME: Underflow
}

///|
pub impl Neg for UInt8 with op_neg(self : UInt8) -> UInt8 {
  u8(-self.to_int()) // FIXME: Underflow
}

///|
pub impl Mod for UInt8 with op_mod(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() % other.to_int())
}

///|
pub impl BitAnd for UInt8 with land(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() & other.to_int())
}

///|
pub impl BitOr for UInt8 with lor(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() | other.to_int())
}

///|
pub impl BitXOr for UInt8 with lxor(self : UInt8, other : UInt8) -> UInt8 {
  u8(self.to_int() ^ other.to_int())
}

///|
pub impl Shl for UInt8 with op_shl(self : UInt8, other : Int) -> UInt8 {
  u8(self.to_int() << other)
}

///|
pub impl Shr for UInt8 with op_shr(self : UInt8, other : Int) -> UInt8 {
  u8(self.to_int() >> other)
}

///|
///|
// Test arithmetic operations
///|
test "uint8_arithmetic" {
  let max = UInt8::new(0xFF)
  let one = UInt8::new(0x01)
  let zero = UInt8::new(0x00)

  // Test addition
  assert_eq!(zero + one, one)
  // Test overflow behavior
  assert_eq!(max + one, zero)
  // Test subtraction
  assert_eq!(max - one, 0xFE)
  // Test underflow bevavior
  assert_eq!(zero - one, max)
  // Test multiplication
  assert_eq!(max * one, max)
  assert_eq!(zero * max, zero)
  assert_eq!(max * max, one)
  // Test division
  assert_eq!(max / one, max)
  // Test division by zero
  assert_eq!(zero / one, zero)
  // Test division by max
  assert_eq!(max / max, one)
  // Test negation
  assert_eq!(-max, one)
  assert_eq!(-one, max)
  assert_eq!(-zero, zero)
  // Test modulo
  assert_eq!(max % one, zero)
}

///|
test "panic_uint8_arithmetic" {
  let one = UInt8::new(0x01)
  let zero = UInt8::new(0x00)

  // Test division by zero
  assert_eq!(one / zero, zero)
}

// Test bitwise operations
///|
test "uint8_bitwise" {
  let max = UInt8::new(0xFF)
  let one = UInt8::new(0x01)

  // Test shifts
  assert_eq!(max << 1, 0xFE)
  assert_eq!(max >> 1, 0x7F)
  // Test bitwise operations
  assert_eq!(max & one, 0x01)
  assert_eq!(max | one, 0xFF)
  assert_eq!(max ^ one, 0xFE)
}

// Test comparison operations
///|
test "uint8_comparison" {
  let max = UInt8::new(0xFF)
  let one = UInt8::new(0x01)
  assert_eq!(max == one, false)
  assert_eq!(max != one, true)
  assert_eq!(max < one, false)
  assert_eq!(max <= one, false)
  assert_eq!(max > one, true)
  assert_eq!(max >= one, true)
}

// Test string representation
///|
test "uint8_string" {
  let max = UInt8::new(0xFF)
  assert_eq!(max.to_hex(), "FF")
}
