//
// UInt8
//

///|
pub trait U8 {
  u8(Self) -> UInt8
}

///|
pub fn u8[T : U8](t : T) -> UInt8 {
  t.u8()
}

///|
pub fn to_uint8[T : U8](t : T) -> UInt8 {
  t.u8()
}

///|
pub impl U8 for Int with u8(self) {
  UInt8::new(self)
}

///|
pub impl U8 for UInt8 with u8(self) {
  UInt8::new(self.to_int())
}

///|
pub impl U8 for UInt16 with u8(self) {
  UInt8::new(self.to_int())
}

///|
pub impl U8 for Byte with u8(self) {
  UInt8::new(self.to_int())
}

///|
test "U8::u8/basic" {
  // Test normal range conversions
  let a : Int = 42
  inspect!(u8(a), content="2A")
  let b : Int = 255
  inspect!(u8(b), content="FF")
  let c : Int = 0
  inspect!(u8(c), content="00")
}

///|
test "u8/basic" {
  // Test basic conversion from different types
  let int_val = 42
  let byte_val = b'\x2A'
  let uint8_val = UInt8::new(42)
  let uint16_val = UInt16::new(42)
  inspect!(u8(int_val), content="2A")
  inspect!(u8(byte_val), content="2A")
  inspect!(u8(uint8_val), content="2A")
  inspect!(u8(uint16_val), content="2A")
}

///|
test "u8/boundary" {
  // Test boundary values (0 and 255)
  inspect!(u8(0), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  inspect!(u8(255), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  // Test values that should wrap around
  inspect!(u8(256), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u8(-1), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "Int::u8/normal" {
  inspect!((0).u8(), content="00")
  inspect!((127).u8(), content="7F")
  inspect!((255).u8(), content="FF")
}

///|
test "UInt8::u8/identity" {
  // Test that converting a UInt8 to itself preserves the value
  let original = UInt8::new(42)
  inspect!(original.u8(), content="2A")
  let max = UInt8::new(0xFF)
  inspect!(max.u8(), content="FF")
  let zero = UInt8::new(0x00)
  inspect!(zero.u8(), content="00")
}

///|
test "UInt16::u8/normal" {
  // Test normal cases within UInt8 range
  let val1 = UInt16::new(0x00)
  let val2 = UInt16::new(0xFF)
  inspect!(val1.u8(), content="00")
  inspect!(val2.u8(), content="FF")
}

///|
test "UInt16::u8/truncation" {
  // Test values that exceed UInt8 range (should truncate to lower byte)
  let val1 = UInt16::new(0x0100) // Should truncate to 0x00
  let val2 = UInt16::new(0xFF00) // Should truncate to 0x00
  let val3 = UInt16::new(0xFFFF) // Should truncate to 0xFF
  inspect!(val1.u8(), content="00")
  inspect!(val2.u8(), content="00")
  inspect!(val3.u8(), content="FF")
}

///|
test "UInt16::u8/boundary" {
  // Test boundary values
  let max = UInt16::new(0xFFFF)
  let above_max = UInt16::new(0x0100)
  let below_zero = UInt16::new(-1)
  inspect!(max.u8(), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(above_max.u8(), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(below_zero.u8(), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
}

///|
test "UInt8::u8/boundary" {
  // Test boundary values
  let max = UInt8::new(255)
  let min = UInt8::new(0)
  let mid = UInt8::new(128)
  inspect!(max.u8(), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  inspect!(min.u8(), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  inspect!(mid.u8(), content="80")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
}

///|
test "Int::u8/boundary" {
  inspect!((256).u8(), content="00") // Should wrap around
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!((-1).u8(), content="FF") // Should wrap to max value
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  inspect!((-256).u8(), content="00") // Should wrap to 0
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "Int::u8/extreme" {
  inspect!(@int.max_value.u8(), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(@int.min_value.u8(), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "u8/overflow" {
  // Test extreme values
  inspect!(u8(@int.max_value), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u8(@int.min_value), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
  // Test large positive and negative numbers
  inspect!(u8(1000), content="E8")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  inspect!(u8(-1000), content="18")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "U8::u8/boundary" {
  // Test boundary values
  let max : Int = 255
  inspect!(u8(max), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  let over_max : Int = 256
  inspect!(u8(over_max), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), true)
  assert_eq!(ALU::underflow(), false)
  let min : Int = 0
  inspect!(u8(min), content="00")
  assert_eq!(ALU::zero(), true)
  assert_eq!(ALU::carry(), false)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), false)
  let negative : Int = -1
  inspect!(u8(negative), content="FF")
  assert_eq!(ALU::zero(), false)
  assert_eq!(ALU::carry(), true)
  assert_eq!(ALU::overflow(), false)
  assert_eq!(ALU::underflow(), true)
}

///|
test "U8::u8/type_conversion" {
  // Test conversion between different numeric types
  let byte = b'\xFF'
  inspect!(u8(byte), content="FF")
  let uint16 = UInt16::new(255)
  inspect!(u8(uint16), content="FF")
  let uint8 = UInt8::new(42)
  inspect!(u8(uint8), content="2A")
}
