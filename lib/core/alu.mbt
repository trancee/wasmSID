///|
pub struct ALU {
  mut zero : Bool
  mut carry : Bool // `true` if there is a carry in the most-significant bit 
  mut overflow : Bool // `true` if the input operands have the same sign, and the result has a different sign
  mut underflow : Bool
}

///|
let alu : ALU = { zero: false, carry: false, overflow: false, underflow: false }

///|
pub fn ALU::zero() -> Bool {
  alu.zero
}

///|
pub fn ALU::carry() -> Bool {
  alu.carry
}

///|
pub fn ALU::overflow() -> Bool {
  alu.overflow
}

///|
pub fn ALU::underflow() -> Bool {
  alu.underflow
}
