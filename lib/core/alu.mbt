///|
pub struct ALU {
  mut zero : Bool
  mut carry : Bool // `true` if there is a carry in the most-significant bit 
  mut overflow : Bool // `true` if the input operands have the same sign, and the result has a different sign
  mut underflow : Bool
} derive(Show)

///|
let alu : ALU = { zero: false, carry: false, overflow: false, underflow: false }

///|
pub fn ALU::zero() -> Bool {
  alu.zero
}

///|
pub fn ALU::z() -> String {
  if alu.zero {
    "Z"
  } else {
    "z"
  }
}

///|
pub fn ALU::carry() -> Bool {
  alu.carry
}

///|
pub fn ALU::c() -> String {
  if alu.carry {
    "C"
  } else {
    "c"
  }
}

///|
pub fn ALU::overflow() -> Bool {
  alu.overflow
}

///|
pub fn ALU::o() -> String {
  if alu.overflow {
    "O"
  } else {
    "o"
  }
}

///|
pub fn ALU::underflow() -> Bool {
  alu.underflow
}

///|
pub fn ALU::u() -> String {
  if alu.underflow {
    "U"
  } else {
    "u"
  }
}

///|
pub fn ALU::to_string() -> String {
  ALU::z() + ALU::c() + ALU::o() + ALU::u()
}
