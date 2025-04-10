//
// UInt16
//

///|
pub(all) type UInt16 Int derive(Show, Eq, Compare, Default)

///|
pub fn UInt16::init(self : Int) -> UInt16 {
  self & 0xFFFF
}

///|
pub fn UInt16::new(self : Int) -> UInt16 {
  self & 0xFFFF
}

///|
pub fn UInt16::u16(self : Int) -> UInt16 {
  self & 0xFFFF
}

///|
// pub trait U16 {
//   u16(Self) -> UInt16
// }

///|
pub fn u16(self : UInt8) -> UInt16 {
  self._ & 0xFFFF
}

///|
pub fn UInt16::op_add(self : UInt16, other : UInt16) -> UInt16 {
  self._ + other._ |> u16 // handle overflow
}

///|
pub fn UInt16::op_sub(self : UInt16, other : UInt16) -> UInt16 {
  self._ - other._ |> u16 // handle underflow
}

///|
pub fn UInt16::op_mul(self : UInt16, other : UInt16) -> UInt16 {
  self._ * other._ |> u16 // handle overflow
}

///|
pub fn UInt16::op_div(self : UInt16, other : UInt16) -> UInt16 {
  self._ / other._ |> u16 // handle underflow
}

///|
pub fn UInt16::op_shl(self : UInt16, bit : UInt16) -> UInt16 {
  self._ << bit._ |> u16
}

///|
pub fn UInt16::op_shr(self : UInt16, bit : UInt16) -> UInt16 {
  self._ >> bit._ |> u16
}

// bitwise and
///|
pub fn UInt16::land(self : UInt16, other : UInt16) -> UInt16 {
  self._ & other._ |> u16
}

// bitwise or
///|
pub fn UInt16::lor(self : UInt16, bit : UInt16) -> UInt16 {
  self._ | bit._ |> u16
}

// bitwise xor
///|
pub fn UInt16::lxor(self : UInt16, bit : UInt16) -> UInt16 {
  self._ ^ bit._ |> u16
}

///|
pub fn UInt16::has(self : UInt16, bit : UInt16) -> Bool {
  (self._ & bit._) != 0
}

///|
pub fn UInt16::to_hex(self : UInt16) -> String {
  let builder = StringBuilder::new()
  builder.write_char(HEX[((self >> 12) & 0x0F)._])
  builder.write_char(HEX[((self >> 8) & 0x0F)._])
  builder.write_char(HEX[((self >> 4) & 0x0F)._])
  builder.write_char(HEX[((self >> 0) & 0x0F)._])
  builder.to_string()
}

///|
pub fn UInt16::to_byte(self : UInt16) -> Byte {
  self._.to_byte()
}

///|
pub fn UInt16::to_int(self : UInt16) -> Int {
  self._
}
