//
// UInt8
//

///|
pub(all) type UInt8 Int derive(Show, Eq, Compare, Default)

///|
pub fn UInt8::init(self : Int) -> UInt8 {
  self & 0xFF
}

///|
pub fn UInt8::new(self : Int) -> UInt8 {
  self & 0xFF
}

///|
pub fn UInt8::u8(self : Int) -> UInt8 {
  self & 0xFF
}

// pub trait U8 {
//   u8(Self) -> UInt8
// }

// pub fn U8::u8(self : Int) -> UInt8 {
//   self & 0xFF
// }

// fn U8::u8(self : UInt8) -> UInt8 {
//   self & 0xFF
// }

// fn U8::u8(self : UInt16) -> UInt8 {
//   self.0 & 0xFF
// }

// fn U8::u8(self : Bool) -> UInt8 {
//   if self {
//     1
//   } else {
//     0
//   }
// }

///|
pub fn u8(self : UInt16) -> UInt8 {
  self._ & 0xFF
}

///|
pub fn UInt8::op_add(self : UInt8, other : UInt8) -> UInt8 {
  self._ + other._ // FIXME: Overflow
}

///|
pub fn UInt8::op_sub(self : UInt8, other : UInt8) -> UInt8 {
  self._ - other._ // FIXME: Underflow
}

///|
pub fn UInt8::op_mul(self : UInt8, other : UInt8) -> UInt8 {
  self._ * other._ // FIXME: Overflow
}

///|
pub fn UInt8::op_div(self : UInt8, other : UInt8) -> UInt8 {
  self._ / other._ // FIXME: Underflow
}

///|
pub fn UInt8::op_mod(self : UInt8, other : UInt8) -> UInt8 {
  self._ % other._
}

///|
pub fn UInt8::op_shl(self : UInt8, bit : UInt8) -> UInt8 {
  self._ << bit._
}

///|
pub fn UInt8::op_shr(self : UInt8, bit : UInt8) -> UInt8 {
  self._ >> bit._
}

///|
pub fn UInt8::flip(self : UInt8, other : UInt8) -> UInt8 {
  self._ & (-other._ - 1)
}

///|
pub fn UInt8::land(self : UInt8, other : UInt8) -> UInt8 {
  self._ & other._
}

///|
pub fn UInt8::lor(self : UInt8, bit : UInt8) -> UInt8 {
  self._ | bit._
}

///|
pub fn UInt8::lxor(self : UInt8, bit : UInt8) -> UInt8 {
  self._ ^ bit._
}

///|
pub fn UInt8::borrow(self : UInt8) -> Bool {
  self._.is_neg()
}

///|
pub fn UInt8::bit(self : UInt8, bit : UInt8) -> Bool {
  if bit >= 8 {
    println("UInt8::bit out of bounds")
    abort("out of bounds")
  }
  ((self >> bit) & 1) == 1
}

///|
pub fn UInt8::bitn(self : UInt8, bit : UInt8) -> UInt8 {
  (self >> bit) & 1
}

///|
pub fn UInt8::clr(self : UInt8, mask : UInt8) -> UInt8 {
  self._ & (-mask._ - 1)
}

///|
pub fn UInt8::set(self : UInt8, mask : UInt8) -> UInt8 {
  self._ | mask._
}

///|
pub fn UInt8::has(self : UInt8, mask : UInt8) -> Bool {
  (self._ & mask._) != 0
}

// fn to_byte(
//   b0 : Bool,
//   b1 : Bool,
//   b2 : Bool,
//   b3 : Bool,
//   b4 : Bool,
//   b5 : Bool,
//   b6 : Bool,
//   b7 : Bool
// ) -> UInt8 {
//   (b0 |> to_u8) | (b1 |> to_u8)<<(1).0 | (b2 |> to_u8)<<(2).0 | (b3 |> to_u8)<<(
//     3,
//   ).0 | (b4 |> to_u8)<<(4).0 | (b5 |> to_u8)<<(5).0 | (b6 |> to_u8)<<(6).0 |
//   (b7 |> to_u8)<<(7).0
// }

///|
pub fn UInt8::to_signed(self : UInt8) -> Int {
  self._ - ((self & 0x80) << 1)._
}

///|
pub fn UInt8::to_hex(self : UInt8) -> String {
  let builder = StringBuilder::new()
  builder.write_char(HEX[((self >> 4) & 0x0F)._])
  builder.write_char(HEX[((self >> 0) & 0x0F)._])
  builder.to_string()
}

///|
pub fn UInt8::to_byte(self : UInt8) -> Byte {
  self._.to_byte()
}

///|
pub fn UInt8::to_int(self : UInt8) -> Int {
  self._
}
