type! Exception {
  InvalidAddressV2
  InvalidAddressV3
  InvalidAddressV3Even
  InvalidAddressV4Even
  InvalidVersionOffset(String)
  UnknownChannel
  UnknownColor(Int)
  UnknownCPUClock
  UnknownFile
  UnknownFrameRate
  UnknownHeader(String)
  UnknownMode
  UnknownModel(String)
  UnknownRegister(String, Int)
  UnknownScanLineCycles
  UnknownScanLines
  UnknownVersion
  UnknownVersionPSID
  UnknownVideoStandard
  UnsupportedNoSIDs(String, Int)
}

pub fn to_string(self : Exception) -> String {
  match self {
    InvalidAddressV2 => "address must not be set for PSID v2NG"
    InvalidAddressV3 => "address must not be set for PSID v3"
    InvalidAddressV3Even => "address must be set and an even number for PSID v3"
    InvalidAddressV4Even => "address must be set and an even number for PSID v4"
    InvalidVersionOffset(value) => "invalid data offset for version #\{value}"
    UnknownChannel => "unknown channel"
    UnknownColor(value) => "unknown color #\{value}"
    UnknownCPUClock => "unknown CPU clock"
    UnknownFile => "no PSID or RSID file"
    UnknownFrameRate => "unknown frame rate"
    UnknownHeader(header) => "unknown SID header: \{header}"
    UnknownMode => "unknown mode"
    UnknownModel(scope) => "unknown \{scope} model"
    UnknownRegister(scope, value) => "unknown \{scope} register #\{value}"
    UnknownScanLineCycles => "unknown scan line cycles"
    UnknownScanLines => "unknown scan lines"
    UnknownVersion => "unknown version"
    UnknownVersionPSID => "unknown PSID or RSID version"
    UnknownVideoStandard => "unknown video standard"
    UnsupportedNoSIDs(scope, value) =>
      "unsupported number of \{scope}s: #\{value}"
  }
}

pub impl Show for Exception with output(self, logger) {
  logger.write_string(self.to_string())
}

let s = "0123456789ABCDEF"

// fn hex(n : UInt8) -> String {
//   s[(n & 0x0F).0].to_string()
// }

//
// UInt8
//

pub type UInt8 Int derive(Show, Eq, Compare, Default)

trait U8 {
  u8(Self) -> UInt8
}

// fn U8::u8(self : Int) -> UInt8 {
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

fn u8(self : UInt16) -> UInt8 {
  self.0 & 0xFF
}

fn op_add(self : UInt8, other : UInt8) -> UInt8 {
  self.0 + other.0 // FIXME: Overflow
}

fn op_sub(self : UInt8, other : UInt8) -> UInt8 {
  self.0 - other.0 // FIXME: Underflow
}

fn op_mul(self : UInt8, other : UInt8) -> UInt8 {
  self.0 * other.0 // FIXME: Overflow
}

fn op_div(self : UInt8, other : UInt8) -> UInt8 {
  self.0 / other.0 // FIXME: Underflow
}

fn op_mod(self : UInt8, other : UInt8) -> UInt8 {
  self.0 % other.0
}

fn op_shl(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 << bit.0
}

fn op_shr(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 >> bit.0
}

fn flip(self : UInt8, other : UInt8) -> UInt8 {
  self.0 & (-other.0 - 1)
}

// bitwise and
fn land(self : UInt8, other : UInt8) -> UInt8 {
  self.0 & other.0
}

// bitwise or
fn lor(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 | bit.0
}

// bitwise xor
fn lxor(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 ^ bit.0
}

fn bit(self : UInt8, bit : UInt8) -> Bool {
  if bit >= 8 {
    println("UInt8::bit out of bounds")
    abort("out of bounds")
  }
  ((self >> bit) & 1) == 1
}

fn clr(self : UInt8, mask : UInt8) -> UInt8 {
  self.0 & (-mask.0 - 1)
}

fn set(self : UInt8, mask : UInt8) -> UInt8 {
  self.0 | mask.0
}

fn has(self : UInt8, mask : UInt8) -> Bool {
  (self.0 & mask.0) != 0
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

fn to_signed(self : UInt8) -> Int {
  self.0 - ((self & 0x80) << 1).0
}

pub fn to_hex(self : UInt8) -> String {
  s[((self >> 4) & 0x0F).0].to_string() + s[(self & 0x0F).0].to_string()
  // hex(self >> 4) + hex(self)
}

fn to_byte(self : UInt8) -> Byte {
  self.0.to_byte()
}

fn to_int(self : UInt8) -> Int {
  self.0
}

//
// UInt16
//

pub type UInt16 Int derive(Show, Eq, Compare, Default)

trait U16 {
  u16(Self) -> UInt16
}

// fn U16::u16(self : Int) -> UInt16 {
//   self & 0xFFFF
// }

fn u16(self : UInt8) -> UInt16 {
  self.0 & 0xFF
}

// fn to_u16[T : U16](t : T) -> UInt16 {
//   t.u16()
// }

fn op_add(self : UInt16, other : UInt16) -> UInt16 {
  self.0 + other.0 |> u16 // handle overflow
}

fn op_sub(self : UInt16, other : UInt16) -> UInt16 {
  self.0 - other.0 |> u16 // handle underflow
}

fn op_mul(self : UInt16, other : UInt16) -> UInt16 {
  self.0 * other.0 |> u16 // handle overflow
}

fn op_div(self : UInt16, other : UInt16) -> UInt16 {
  self.0 / other.0 |> u16 // handle underflow
}

fn op_shl(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 << bit.0 |> u16
}

fn op_shr(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 >> bit.0 |> u16
}

// bitwise and
fn land(self : UInt16, other : UInt16) -> UInt16 {
  self.0 & other.0
}

// bitwise or
fn lor(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 | bit.0
}

// bitwise xor
fn lxor(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 ^ bit.0
}

fn has(self : UInt16, bit : UInt16) -> Bool {
  (self.0 & bit.0) != 0
}

pub fn to_hex(self : UInt16) -> String {
  // println(
  //   "U16::to_hex \(self) $" + s[((self >> 12) & 0x0F).0].to_string() + s[((self >>
  //   8) & 0x0F).0].to_string() + s[((self >> 4) & 0x0F).0].to_string() + s[(self &
  //   0x0F).0].to_string(),
  // )
  // u8(self >> 8).to_hex() + u8(self & 0xFF).to_hex()
  s[((self >> 12) & 0x0F).0].to_string() +
  s[((self >> 8) & 0x0F).0].to_string() +
  s[((self >> 4) & 0x0F).0].to_string() +
  s[(self & 0x0F).0].to_string()
}

fn to_byte(self : UInt16) -> Byte {
  self.0.to_byte()
}

fn to_int(self : UInt16) -> Int {
  self.0
}
