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
pub fn to_u8[T : U8](t : T) -> UInt8 {
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

// ///|
// pub impl U8 for UInt16 with u8(self) {
//   UInt8::new(self.to_int())
// }

///|
pub impl U8 for Byte with u8(self) {
  UInt8::new(self.to_int())
}

///|
test "u8/positive_int" {
  let uint8_max = UInt8::new(255) // maximum value for uint8
  let uint8_min = UInt8::new(0) // minimum value for uint8
  let uint8_mid = UInt8::new(127) // mid-range value for uint8
  inspect!(UInt8::new(255), content="FF")
  inspect!(UInt8::new(0), content="00")
  inspect!(UInt8::new(127), content="7F")
  assert_eq!(uint8_max.to_int(), 255)
  assert_eq!(uint8_min.to_int(), 0)
  assert_eq!(uint8_mid.to_int(), 127)
}

///|
test "UInt8::bit(positive_int)" {
  let value = UInt8::new(5) // binary: 0101
  assert_true!(value.bit(0)) // 5 has its 0th bit set
  assert_false!(value.bit(3)) // 5 does not have its 1st bit set
  assert_true!(value.bit(2)) // 5 has its 2nd bit set
}

///|
test "UInt8::bit(nagative_int)" {
  let value = UInt8::new(0b11111101) // -5
  assert_true!(value.bit(0))
  assert_false!(value.bit(1))
  assert_true!(value.bit(7))
}

///|
test "U8::u8/basic" {
  // Test basic conversions from different types
  inspect!(u8(42), content="2A")
  inspect!(u8(0xFF), content="FF")
  inspect!(u8(0x00), content="00")
}

///|
test "U8::u8/overflow" {
  // Test overflow behavior
  inspect!(u8(256), content="00") // 256 = 0x100, should wrap to 0
  inspect!(u8(257), content="01") // 257 = 0x101, should wrap to 1
  inspect!(u8(-1), content="FF") // -1 should wrap to 255
}

///|
test "U8::u8/type_conversion" {
  // Test different type conversions
  let byte : Byte = b'\x42'
  let uint16 : UInt16 = 0xFF
  let uint8 : UInt8 = UInt8::new(0x7F)
  inspect!(to_u8(byte), content="42")
  // inspect!(to_u8(uint16), content="FF")
  inspect!(to_u8(uint8), content="7F")
}
