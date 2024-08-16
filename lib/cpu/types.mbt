fn hex(n : UInt8) -> String {
  let s = "0123456789ABCDEF"
  s[(n & 0x0F).0].to_string()
}

//
// UInt8
//

pub type UInt8 Int derive(Show, Eq, Compare)

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

// fn U8::u8(self : Instruction) -> UInt8 {
//   get_opcode(self)
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

// logic shift left
fn lsl(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 << bit.0
}

fn shl(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 << bit.0
}

// logic shift right
fn lsr(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 >> bit.0
}

fn shr(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 >> bit.0
}

// arithmetic shift right
fn asr(self : UInt8, bit : UInt8) -> UInt8 {
  self.0 >> bit.0
}

fn bit(self : UInt8, bit : UInt8) -> Bool {
  ((self >> bit) & 1) == 1
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

pub fn to_hex(self : UInt8) -> String {
  hex(self >> 4) + hex(self)
}

fn to_signed(self : UInt8) -> Int {
  self.0 - ((self & 0x80) << 1).0
}

//
// UInt16
//

pub type UInt16 Int derive(Show, Eq, Compare)

trait U16 {
  u16(Self) -> UInt16
}

// fn U16::u16(self : Int) -> UInt16 {
//   self & 0xFFFF
// }

fn u16(self : UInt8) -> UInt16 {
  self.0 & 0xFFFF
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

// bitwise and
fn land(self : UInt16, other : UInt16) -> UInt16 {
  self.0 & other.0
}

// bitwise or
fn lor(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 | bit.0
}

// logic shift left
fn lsl(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 << bit.0
}

fn shl(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 << bit.0
}

// logic shift right
fn lsr(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 >> bit.0
}

fn shr(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 >> bit.0
}

// arithmetic shift right
fn asr(self : UInt16, bit : UInt16) -> UInt16 {
  self.0 >> bit.0
}

pub fn to_hex(self : UInt16) -> String {
  u8(self >> 8).to_hex() + u8(self & 0xFF).to_hex()
}
