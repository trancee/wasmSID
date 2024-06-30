fn to_hex_digit(n : UInt8) -> String {
  let s = "0123456789ABCDEF"
  s[n.0].to_string()
}

// fn to_hex(self : Int) -> String {
//   (self.lsr(8) |> to_u8).to_hex() + (self.land(0xff) |> to_u8).to_hex()
// }

//
// UInt8
//

type UInt8 Int derive(Eq, Compare, Debug)

trait U8 {
  u8(Self) -> UInt8
}

fn U8::u8(self : Int) -> UInt8 {
  // let x = self.land(0xff)
  // println("U8::Int(\(x))")
  UInt8(self.land(0xff))
}

fn U8::u8(self : Instruction) -> UInt8 {
  get_opcode(self)
}

fn U8::u8(self : Bool) -> UInt8 {
  // println("U8::Bool(\(self))")
  if self {
    UInt8(1)
  } else {
    UInt8(0)
  }
}

fn u8(self : UInt16) -> UInt8 {
  // println("u8(\(self))")
  self.0.land(0xff)
}

fn to_u8[T : U8](t : T) -> UInt8 {
  t.u8()
}

fn op_add(self : UInt8, other : UInt8) -> UInt8 {
  self.0 + other.0 |> to_u8
}

fn op_sub(self : UInt8, other : UInt8) -> Int {
  self.0 - other.0
}

// bitwise and
fn land(self : UInt8, other : UInt8) -> UInt8 {
  self.0.land(other.0)
}

// bitwise or
fn lor(self : UInt8, bit : Int) -> UInt8 {
  self.0.lor(bit)
}

// bitwise xor
fn lxor(self : UInt8, bit : Int) -> UInt8 {
  self.0.lxor(bit)
}

// logic shift left
fn lsl(self : UInt8, bit : Int) -> UInt8 {
  self.0.lsl(bit)
}

// logic shift right
fn lsr(self : UInt8, bit : Int) -> UInt8 {
  self.0.lsr(bit)
}

fn bit(self : UInt8, bit : Int) -> Bool {
  self.0.lsr(bit).land(1) == 1
}

fn to_byte(
  b0 : Bool,
  b1 : Bool,
  b2 : Bool,
  b3 : Bool,
  b4 : Bool,
  b5 : Bool,
  b6 : Bool,
  b7 : Bool
) -> UInt8 {
  (b0 |> to_u8).lor((b1 |> to_u8).lsl(1).0).lor((b2 |> to_u8).lsl(2).0).lor(
    (b3 |> to_u8).lsl(3).0,
  ).lor((b4 |> to_u8).lsl(4).0).lor((b5 |> to_u8).lsl(5).0).lor(
    (b6 |> to_u8).lsl(6).0,
  ).lor((b7 |> to_u8).lsl(7).0)
}

fn to_hex(self : UInt8) -> String {
  (u8(self.0).lsr(4) |> to_hex_digit) + (u8(self.0).land(0xf) |> to_hex_digit())
}

fn to_string(self : UInt8) -> String {
  self.0.to_string()
}

//
// UInt16
//

type UInt16 Int derive(Eq, Compare, Debug)

trait U16 {
  u16(Self) -> UInt16
}

fn U16::u16(i : Int) -> UInt16 {
  UInt16(i.land(0xFFFF))
}

fn u16(self : UInt8) -> UInt16 {
  self.0
}

fn to_u16[T : U16](t : T) -> UInt16 {
  t.u16()
}

fn op_add(self : UInt16, other : UInt16) -> Int {
  self.0 + other.0
}

fn op_sub(self : UInt16, other : UInt16) -> Int {
  self.0 - other.0
}

// bitwise and
fn land(self : UInt16, other : Int) -> UInt16 {
  self.0.land(other)
}

// bitwise or
fn lor(self : UInt16, bit : Int) -> UInt16 {
  self.0.lor(bit)
}

// logic shift left
fn lsl(self : UInt16, bit : Int) -> UInt16 {
  self.0.lsl(bit)
}

// logic shift right
fn lsr(self : UInt16, bit : Int) -> UInt16 {
  self.0.lsr(bit)
}

fn to_hex(self : UInt16) -> String {
  u8(self.lsr(8)).to_hex() + u8(self.land(0xff)).to_hex()
}

fn to_string(self : UInt16) -> String {
  self.0.to_string()
}
