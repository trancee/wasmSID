//
// UInt16
//

///|
pub trait U16 {
  u16(Self) -> UInt16
}

///|
pub fn u16[T : U16](t : T) -> UInt16 {
  t.u16()
}

///|
pub fn to_uint16[T : U16](t : T) -> UInt16 {
  t.u16()
}

///|
pub impl U16 for Int with u16(self) {
  UInt16::new(self)
}

///|
pub impl U16 for UInt16 with u16(self) {
  UInt16::new(self.to_int())
}

///|
pub impl U16 for UInt8 with u16(self) {
  UInt16::new(self.to_int())
}

///|
pub impl U16 for Byte with u16(self) {
  UInt16::new(self.to_int())
}

///|
test "U16::u16/basic_conversion" {
  let i : Int = 42
  let u8 : UInt8 = UInt8::new(255)
  let byte : Byte = b'\xFF'
  inspect!(u16(i), content="002A")
  inspect!(u16(u8), content="00FF")
  inspect!(u16(byte), content="00FF")
}

///|
test "u16/basic" {
  // Test normal integers within range
  inspect!(u16(0), content="0000")
  inspect!(u16(255), content="00FF")
  inspect!(u16(65535), content="FFFF")
}

///|
test "u16/overflow" {
  // Test values that exceed UInt16 range
  inspect!(u16(65536), content="0000") // Should wrap around
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u16(-1), content="FFFF") // Should wrap to max value
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!(u16(-65536), content="0000") // Should wrap to 0
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "u16/type_conversion" {
  // Test conversion from different types
  let byte = b'\xFF'
  let uint8 = UInt8::new(255)
  let uint16 = UInt16::new(65535)
  inspect!(u16(byte), content="00FF")
  inspect!(u16(uint8), content="00FF")
  inspect!(u16(uint16), content="FFFF")
}

///|
test "U16::u16/identity" {
  // Test that converting a UInt16 to itself preserves the value
  let original = UInt16::new(0x1234)
  inspect!(u16(original), content="1234")
  let max = UInt16::new(0xFFFF)
  inspect!(u16(max), content="FFFF")
  let zero = UInt16::new(0x0000)
  inspect!(u16(zero), content="0000")
}

///|
test "U16/uint8_to_uint16" {
  let n = UInt8::new(42)
  inspect!(n.u16(), content="002A")
  let zero = UInt8::new(0)
  inspect!(zero.u16(), content="0000")
  let max = UInt8::new(255)
  inspect!(max.u16(), content="00FF")
}

///|
test "U16/uint8_to_uint16/negative" {
  let neg_one = UInt8::new(-1) // wraps to 255
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!(neg_one.u16(), content="00FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  let neg_256 = UInt8::new(-256) // wraps to 0
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!(neg_256.u16(), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
}

///|
test "U16/uint8_to_uint16/overflow" {
  let overflow = UInt8::new(256) // wraps to 0
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(overflow.u16(), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  let big_overflow = UInt8::new(512) // wraps to 0
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(big_overflow.u16(), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
}

///|
test "U16::u16/boundary" {
  // Test boundary values for UInt16
  let max = UInt16::new(0xFFFF)
  let min = UInt16::new(0x0000)
  let mid = UInt16::new(0x8000)
  inspect!(u16(max), content="FFFF")
  inspect!(u16(min), content="0000")
  inspect!(u16(mid), content="8000")
}

///|
test "U16::u16/boundary" {
  inspect!(u16(0), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  inspect!(u16(65535), content="FFFF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  inspect!(u16(-1), content="FFFF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!(u16(65536), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
}

///|
test "U16::u16/overflow" {
  inspect!(u16(@int.max_value), content="FFFF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u16(@int.min_value), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!(u16(65537), content="0001")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u16(-65536), content="0000")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}
