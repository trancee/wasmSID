//
// UInt16
//

///|
pub impl Default for UInt16 with default() {
  UINT16_DEFAULT
}

///|
pub impl Eq for UInt16 with op_equal(self, other) {
  self.to_int() == other.to_int()
}

///|
pub impl Compare for UInt16 with compare(self, other) {
  self.to_int().compare(other.to_int())
}

///|
pub impl Hash for UInt16 with hash(self) {
  self.to_int()
}

///|
pub impl Hash for UInt16 with hash_combine(self, hasher) {
  hasher.combine_int(self.to_int())
}

///|
pub impl Show for UInt16 with output(self, logger) -> Unit {
  logger.write_string(self.to_hex())
}

///| 
/// Operator Overloading 
///

///|
pub impl Add for UInt16 with op_add(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() + other.to_int()) // FIXME: Overflow
}

///|
pub impl Sub for UInt16 with op_sub(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() - other.to_int()) // FIXME: Underflow
}

///|
pub impl Mul for UInt16 with op_mul(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() * other.to_int()) // FIXME: Overflow
}

///|
pub impl Div for UInt16 with op_div(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() / other.to_int()) // FIXME: Underflow
}

///|
pub impl Neg for UInt16 with op_neg(self : UInt16) -> UInt16 {
  u16(-self.to_int()) // FIXME: Underflow
}

///|
pub impl Mod for UInt16 with op_mod(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() % other.to_int())
}

///|
pub impl BitAnd for UInt16 with land(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() & other.to_int())
}

///|
pub impl BitOr for UInt16 with lor(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() | other.to_int())
}

///|
pub impl BitXOr for UInt16 with lxor(self : UInt16, other : UInt16) -> UInt16 {
  u16(self.to_int() ^ other.to_int())
}

///|
pub impl Shl for UInt16 with op_shl(self : UInt16, other : Int) -> UInt16 {
  u16(self.to_int() << other)
}

///|
pub impl Shr for UInt16 with op_shr(self : UInt16, other : Int) -> UInt16 {
  u16(self.to_int() >> other)
}

///|
///|
// Test arithmetic operations
///|
test "uint16_arithmetic" {
  let max = UInt16::new(0xFFFF)
  let one = UInt16::new(0x0001)
  let zero = UInt16::new(0x0000)

  // Test addition
  assert_eq!(zero + one, one)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test overflow behavior
  assert_eq!(max + one, zero)
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  // Test subtraction
  assert_eq!(max - one, 0xFFFE)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test underflow bevavior
  assert_eq!(zero - one, max)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  // Test multiplication
  assert_eq!(max * one, max)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  assert_eq!(zero * max, zero)
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  assert_eq!(max * max, one)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  // Test division
  assert_eq!(max / one, max)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test division by zero
  assert_eq!(zero / one, zero)
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test division by max
  assert_eq!(max / max, one)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test negation
  assert_eq!(-max, one)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  assert_eq!(-one, max)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  assert_eq!(-zero, zero)
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test modulo
  assert_eq!(max % one, zero)
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
}

///|
test "panic_uint16_arithmetic" {
  let one = UInt16::new(0x0001)
  let zero = UInt16::new(0x0000)

  // Test division by zero
  assert_eq!(one / zero, zero)
}

// Test bitwise operations
///|
test "uint16_bitwise" {
  let max = UInt16::new(0xFFFF)
  let one = UInt16::new(0x0001)

  // Test shifts
  assert_eq!(max << 1, 0xFFFE)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  assert_eq!(max >> 1, 0x7FFF)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test bitwise operations
  assert_eq!(max & one, 0x0001)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  assert_eq!(max | one, 0xFFFF)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  assert_eq!(max ^ one, 0xFFFE)
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
}

// Test comparison operations
///|
test "uint16_comparison" {
  let max = UInt16::new(0xFFFF)
  let one = UInt16::new(0x0001)
  assert_eq!(max == one, false)
  assert_eq!(max != one, true)
  assert_eq!(max < one, false)
  assert_eq!(max <= one, false)
  assert_eq!(max > one, true)
  assert_eq!(max >= one, true)
}

// Test string representation
///|
test "uint16_string" {
  let max = UInt16::new(0xFFFF)
  assert_eq!(max.to_hex(), "FFFF")
}
