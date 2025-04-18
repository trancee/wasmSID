//
// UInt16
//

///|
pub fn UInt16::bit(self : UInt16, bit : Int) -> Bool {
  self.bitn(bit) == 1
}

///|
pub fn UInt16::bitn(self : UInt16, bit : UInt16) -> Int {
  (self.to_int() >> bit.to_int()) & 1
}

///|
pub fn UInt16::clr(self : UInt16, mask : UInt16) -> UInt16 {
  u16(self.to_int() & (-mask.to_int() - 1))
}

///|
pub fn UInt16::clrb(self : UInt16, bit : UInt16) -> UInt16 {
  self.clr(1 << bit.to_int())
}

///|
pub fn UInt16::set(self : UInt16, mask : UInt16) -> UInt16 {
  u16(self.to_int() | mask.to_int())
}

///|
pub fn UInt16::setb(self : UInt16, bit : UInt16) -> UInt16 {
  self.set(1 << bit.to_int())
}

///|
pub fn UInt16::has(self : UInt16, mask : UInt16) -> Bool {
  u16(self.to_int() & mask.to_int()) != 0
}

///|
pub fn UInt16::is_neg(self : UInt16) -> Bool {
  self.bit(15)
}
