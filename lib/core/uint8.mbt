//
// UInt8
//
///|
pub const UINT8_BITS = 8
///|
pub const UINT8_SIGN_BIT = 7

///|
pub const UINT8_SIZE : Int = 1 << UINT8_BITS

///|
pub const UINT8_MAX = 0xFF

///|
pub const UINT8_MIN = 0x00

///|
pub const UINT8_DEFAULT = 0x00

///|
pub(all) type UInt8 Int

///|
pub fn UInt8::default() -> UInt8 {
  UINT8_DEFAULT
}

///|
pub fn UInt8::init(self : Int) -> UInt8 {
  alu.zero = (self & UINT8_MAX) == UINT8_DEFAULT
  alu.carry = (self & 0x100) != 0
  alu.overflow = self > UINT8_MAX
  alu.underflow = self < UINT8_MIN
  self & UINT8_MAX
}

///|
pub fn UInt8::new(self : Int) -> UInt8 {
  alu.zero = (self & UINT8_MAX) == UINT8_DEFAULT
  alu.carry = (self & 0x100) != 0
  alu.overflow = self > UINT8_MAX
  alu.underflow = self < UINT8_MIN
  self & UINT8_MAX
}

///|
pub fn UInt8::to_int(self : UInt8) -> Int {
  self._ & UINT8_MAX
}

///|
pub fn UInt8::to_u16(self : UInt8) -> UInt16 {
  self.to_int() |> u16
}

///|
pub fn UInt8::to_signed(self : UInt8) -> Int {
  self.to_int() - (if self.bit(UINT8_SIGN_BIT) { UINT8_SIZE } else { 0 })
}

///|
pub fn UInt8::to_byte(self : UInt8) -> Byte {
  self.to_int().to_byte()
}

///|
pub fn UInt8::to_hex(self : UInt8) -> String {
  [HEX[(self.to_int() >> 4) & 0x0F], HEX[self.to_int() & 0x0F]]
}

///|
test "UInt8/valid_range" {
  let zero : UInt8 = 0
  let max : UInt8 = 255
  let mid : UInt8 = 128
  inspect!(zero.to_int(), content="0")
  inspect!(max.to_int(), content="255")
  inspect!(mid.to_int(), content="128")
}

///|
test "UInt8/overflow" {
  let overflow : UInt8 = 256 // should wrap around to 0
  let big_overflow : UInt8 = 512 // should wrap around to 0
  inspect!(overflow.to_int(), content="0")
  inspect!(big_overflow.to_int(), content="0")
}

///|
test "UInt8/negative" {
  let neg_one : UInt8 = -1 // should wrap around to 255
  let neg_256 : UInt8 = -256 // should wrap around to 0
  inspect!(neg_one.to_int(), content="255")
  inspect!(neg_256.to_int(), content="0")
}

///|
test "UInt8::to_signed/positive" {
  // Test positive numbers (0-127)
  inspect!(UInt8::new(0).to_signed(), content="0")
  inspect!(UInt8::new(64).to_signed(), content="64")
  inspect!(UInt8::new(127).to_signed(), content="127")
}

///|
test "UInt8::to_signed/negative" {
  // Test negative numbers (128-255)
  inspect!(UInt8::new(128).to_signed(), content="-128")
  inspect!(UInt8::new(192).to_signed(), content="-64")
  inspect!(UInt8::new(255).to_signed(), content="-1")
}

///|
test "UInt8::to_signed/boundary" {
  // Test boundary values where the signed/unsigned conversion matters most
  inspect!(UInt8::new(127).to_signed(), content="127") // Max positive
  inspect!(UInt8::new(128).to_signed(), content="-128") // Min negative
  inspect!(UInt8::new(0).to_signed(), content="0") // Zero
}

///|
test "UInt8::to_byte/normal" {
  let val = UInt8::new(42)
  inspect!(val.to_byte().to_int(), content="42")
  let val2 = UInt8::new(127)
  inspect!(val2.to_byte().to_int(), content="127")
}

///|
test "UInt8::to_byte/boundary" {
  let min = UInt8::new(0)
  let max = UInt8::new(255)
  inspect!(min.to_byte().to_int(), content="0")
  inspect!(max.to_byte().to_int(), content="255")
}
