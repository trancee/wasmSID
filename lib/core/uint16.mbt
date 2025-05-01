//
// UInt16
//

///|
pub const UINT16_BITS = 16

///|
pub const UINT16_SIGN_BIT = 15

///|
pub const UINT16_SIZE : Int = 1 << UINT16_BITS

///|
pub const UINT16_MAX = 0xFFFF

///|
pub const UINT16_MIN = 0x0000

///|
pub const UINT16_DEFAULT = 0x0000

///|
pub(all) type UInt16 Int derive(@json.FromJson)

///|
pub fn UInt16::default() -> UInt16 {
  UINT16_DEFAULT
}

///|
pub fn UInt16::init(self : Int) -> UInt16 {
  alu.zero = (self & UINT16_MAX) == UINT16_DEFAULT
  alu.carry = (self & 0x10000) != 0
  alu.overflow = self > UINT16_MAX
  alu.underflow = self < UINT16_MIN
  self & UINT16_MAX
}

///|
pub fn UInt16::new(self : Int) -> UInt16 {
  alu.zero = (self & UINT16_MAX) == UINT16_DEFAULT
  alu.carry = (self & 0x10000) != 0
  alu.overflow = self > UINT16_MAX
  alu.underflow = self < UINT16_MIN
  self & UINT16_MAX
}

///|
pub fn UInt16::to_int(self : UInt16) -> Int {
  self._ & UINT16_MAX
}

///|
pub fn UInt16::to_signed(self : UInt16) -> Int {
  self.to_int() - (if self.bit(UINT16_SIGN_BIT) { UINT16_SIZE } else { 0 })
}

///|
pub fn UInt16::to_byte(self : UInt16) -> Byte {
  self.to_int().to_byte()
}

///|
pub fn UInt16::to_hex(self : UInt16) -> String {
  [
    HEX[(self.to_int() >> 12) & 0x0F],
    HEX[(self.to_int() >> 8) & 0x0F],
    HEX[(self.to_int() >> 4) & 0x0F],
    HEX[self.to_int() & 0x0F],
  ]
}

///|
test "MAX_VALUE/basic" {
  // MAX_VALUE should be exactly 65535 (0xFFFF)
  inspect!(UINT16_MAX, content="65535")
}

///|
test "MIN_VALUE" {
  inspect!(UINT16_MIN, content="0")
  inspect!(UINT16_MIN <= UINT16_MAX, content="true")
  inspect!(UINT16_MIN >= UINT16_DEFAULT, content="true")
}

///|
test "DEFAULT_VALUE" {
  // Test if DEFAULT_VALUE is actually zero
  inspect!(UINT16_DEFAULT, content="0")
  // Test if DEFAULT_VALUE is equal to the minimum allowed value
  inspect!(UINT16_DEFAULT == UINT16_MIN, content="true")
  // Test if DEFAULT_VALUE is less than the maximum allowed value
  inspect!(UINT16_DEFAULT < UINT16_MAX, content="true")
}

///|
test "HEX/content" {
  inspect!(HEX, content="0123456789ABCDEF")
  inspect!(HEX.length(), content="16")
}

///|
test "UInt16/basic_range" {
  let zero : UInt16 = 0
  let max : UInt16 = 65535
  let mid : UInt16 = 32768
  let minus : UInt16 = -1
  inspect!(zero, content="0000")
  inspect!(zero._, content="0")
  inspect!(max, content="FFFF")
  inspect!(max._, content="65535")
  inspect!(mid, content="8000")
  inspect!(mid._, content="32768")
  inspect!(minus, content="FFFF")
  inspect!(minus._, content="-1")
}

///|
test "default" {
  // Test that default value is indeed 0
  inspect!(UInt16::default(), content="0000")
  inspect!(UInt16::default()._, content="0")
}

///|
test "UInt16::init/normal" {
  // Test normal cases within range
  inspect!(UInt16::init(0x00), content="0000")
  inspect!(UInt16::init(0x00).to_int(), content="0")
  inspect!(UInt16::init(0xFF), content="00FF")
  inspect!(UInt16::init(0xFF).to_int(), content="255")
  inspect!(UInt16::init(0xFFFF), content="FFFF")
  inspect!(UInt16::init(0xFFFF).to_int(), content="65535")
  inspect!(UInt16::init(0xFFFFFF), content="FFFF")
  inspect!(UInt16::init(0xFFFFFF).to_int(), content="65535")
  inspect!(UInt16::init(0xFFFFFFFF), content="FFFF")
  inspect!(UInt16::init(0xFFFFFFFF).to_int(), content="65535")
}

///|
test "UInt16::new" {
  // Test normal cases
  inspect!(UInt16::new(0x00), content="0000")
  inspect!(UInt16::new(0x00).to_int(), content="0")
  inspect!(UInt16::new(0xFF), content="00FF")
  inspect!(UInt16::new(0xFF).to_int(), content="255")
  inspect!(UInt16::new(0xFFFF), content="FFFF")
  inspect!(UInt16::new(0xFFFF).to_int(), content="65535")
  inspect!(UInt16::new(0xFFFFFF), content="FFFF")
  inspect!(UInt16::new(0xFFFFFF).to_int(), content="65535")
  inspect!(UInt16::new(0xFFFFFFFF), content="FFFF")
  inspect!(UInt16::new(0xFFFFFFFF).to_int(), content="65535")
}

///|
test "UInt16::to_signed/zero_and_positive" {
  // Test zero
  inspect!(UInt16::new(0).to_signed(), content="0")
  // Test small positive number
  inspect!(UInt16::new(1).to_signed(), content="1")
  // Test largest positive number (0x7FFF)
  inspect!(UInt16::new(32767).to_signed(), content="32767")
}

///|
test "UInt16::to_byte/basic" {
  let zero = UInt16::new(0)
  let max_byte = UInt16::new(255)
  inspect!(zero.to_byte(), content="b'\\x00'")
  inspect!(max_byte.to_byte(), content="b'\\xFF'")
}

///|
test "UInt16::to_hex/regular" {
  inspect!(UInt16::new(0x1234).to_hex(), content="1234")
  inspect!(UInt16::new(0x5678).to_hex(), content="5678")
  inspect!(UInt16::new(0x9ABC).to_hex(), content="9ABC")
}

///|
test "UInt16::to_hex/boundary" {
  inspect!(UInt16::new(0x0000).to_hex(), content="0000")
  inspect!(UInt16::new(0x00FF).to_hex(), content="00FF")
  inspect!(UInt16::new(0xFFFF).to_hex(), content="FFFF")
}

///|
test "UInt16::to_hex/overflow" {
  // Values larger than 0xFFFF should be truncated
  inspect!(UInt16::new(0x12345).to_hex(), content="2345")
  inspect!(UInt16::new(0xFFFFF).to_hex(), content="FFFF")
  inspect!(UInt16::new(0xFFFFFF).to_hex(), content="FFFF")
  inspect!(UInt16::new(0xFFFFFFF).to_hex(), content="FFFF")
  inspect!(UInt16::new(0xFFFFFFFF).to_hex(), content="FFFF")
  inspect!(UInt16::new(0xCAFEBABE).to_hex(), content="BABE")
}

///|
test "UInt16::to_byte/overflow" {
  let above_byte = UInt16::new(0x0100)
  let max_uint16 = UInt16::new(0xFFFF)
  // 256 should wrap to 0
  inspect!(above_byte.to_byte(), content="b'\\x00'")
  // 65535 (0xFFFF) should wrap to 255 (0xFF)
  inspect!(max_uint16.to_byte(), content="b'\\xFF'")
}

///|
test "UInt16::to_signed/negative" {
  // Test smallest negative number (0x8000)
  inspect!(UInt16::new(32768).to_signed(), content="-32768")
  // Test -1 (0xFFFF)
  inspect!(UInt16::new(65535).to_signed(), content="-1")
  inspect!(UInt16::new(-1).to_signed(), content="-1")
  inspect!(UInt16::new(-2).to_signed(), content="-2")
  // Test medium negative number (0xC000)
  inspect!(UInt16::new(49152).to_signed(), content="-16384")
}

///|
test "UInt16::to_int/overflow" {
  let overflow_value = UInt16::new(0x10000)
  inspect!(overflow_value, content="0000")
  inspect!(overflow_value.to_int(), content="0")
}

///|
test "UInt16::to_int" {
  // Test normal values within range
  inspect!(UInt16::new(0).to_int(), content="0")
  inspect!(UInt16::new(42).to_int(), content="42")
  inspect!(UInt16::new(65535).to_int(), content="65535")
}

///|
test "UInt16::to_int/boundary" {
  // Test boundary values
  inspect!(UInt16::new(UINT16_MAX).to_int(), content="65535")
  inspect!(UInt16::new(UINT16_MIN).to_int(), content="0")
}

///|
test "UInt16::to_int/overflow" {
  // Test overflow behavior
  inspect!(UInt16::new(UINT16_MAX + 1).to_int(), content="0")
  inspect!(UInt16::new(2 * UINT16_MAX).to_int(), content="65534")
  inspect!(UInt16::new(2 * (UINT16_MAX - 1)).to_int(), content="65532")
  inspect!(UInt16::new(2 * (UINT16_MAX + 1)).to_int(), content="0")
  inspect!(UInt16::new(2 * (UINT16_MAX + 1) - 1).to_int(), content="65535")
}

///|
test "UInt16::new/boundary" {
  // Test boundary cases
  inspect!(UInt16::new(-1).to_int(), content="65535")
  inspect!(UInt16::new(65536).to_int(), content="0")
  inspect!(UInt16::new(65537).to_int(), content="1")
}

///|
test "UInt16::init/boundary" {
  // Test boundary cases
  inspect!(UInt16::init(-1).to_int(), content="65535") // Negative numbers should wrap around
  inspect!(UInt16::init(65536).to_int(), content="0") // Values > MAX_VALUE should wrap to 0
  inspect!(UInt16::init(65537).to_int(), content="1") // Values > MAX_VALUE + 1 should wrap to 1
}

///|
test "UInt16::init/extreme" {
  // Test extreme values
  inspect!(UInt16::init(@int.max_value).to_int(), content="65535")
  inspect!(UInt16::init(@int.min_value).to_int(), content="0")
}

///|
test "default/type_check" {
  // Test that default value is indeed a UInt16
  let x = UInt16::default()
  inspect!(x, content="0000")
  inspect!(x.to_int(), content="0")
  inspect!(x.to_hex(), content="0000")
}

///|
test "UInt16/overflow" {
  let overflow : UInt16 = 65536
  let big_overflow : UInt16 = 131071
  inspect!(overflow, content="0000")
  inspect!(overflow.to_int(), content="0")
  inspect!(big_overflow.to_int(), content="65535")
}

///|
test "UInt16/negative" {
  let neg_one : UInt16 = -1
  let neg_max : UInt16 = -65535
  inspect!(neg_one.to_int(), content="65535")
  inspect!(neg_max.to_int(), content="1")
}

///|
test "HEX/chars" {
  // Test first and last characters
  inspect!(HEX[0], content="0")
  inspect!(HEX[9], content="9")
  inspect!(HEX[10], content="A")
  inspect!(HEX[15], content="F")
}

///|
test "panic HEX/bounds" {
  ignore(HEX[16])
}

///|
test "DEFAULT_VALUE/type_conversion" {
  // Test if DEFAULT_VALUE can be safely converted to UInt16
  let uint16_val = UInt16::new(UINT16_DEFAULT)
  inspect!(uint16_val.to_int(), content="0")
}

///|
test "MIN_VALUE/boundary" {
  let u = UInt16::new(UINT16_MIN)
  inspect!(u.to_int(), content="0")
  inspect!(u - u, content="0000")
}

///|
test "MAX_VALUE/boundary" {
  // MAX_VALUE should be the largest possible 16-bit unsigned integer
  assert_true!(UINT16_MAX < UINT16_SIZE)
  assert_true!(UINT16_MAX >= UINT16_SIZE - 1)
  assert_true!(UINT16_MAX + 1 == UINT16_SIZE)
}

///|
test "MAX_VALUE/bitwise" {
  // All bits in MAX_VALUE should be set to 1
  inspect!((UINT16_MAX & 0xFFFF) == UINT16_MAX, content="true")
  inspect!((UINT16_MAX | 0x0000) == UINT16_MAX, content="true")
}
