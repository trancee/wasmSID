//
// UInt8
//

///|
pub fn UInt8::bit(self : UInt8, bit : Int) -> Bool {
  self.bitn(bit) == 1
}

///|
pub fn UInt8::bitn(self : UInt8, bit : UInt8) -> Int {
  (self.to_int() >> bit.to_int()) & 1
}

///|
pub fn UInt8::clr(self : UInt8, mask : UInt8) -> UInt8 {
  u8(self.to_int() & (-mask.to_int() - 1))
}

///|
pub fn UInt8::clrb(self : UInt8, bit : UInt8) -> UInt8 {
  self.clr(1 << bit.to_int())
}

///|
pub fn UInt8::set(self : UInt8, mask : UInt8) -> UInt8 {
  u8(self.to_int() | mask.to_int())
}

///|
pub fn UInt8::setb(self : UInt8, bit : UInt8) -> UInt8 {
  self.set(1 << bit.to_int())
}

///|
pub fn UInt8::has(self : UInt8, mask : UInt8) -> Bool {
  u8(self.to_int() & mask.to_int()) != 0
}

///|
pub fn UInt8::is_neg(self : UInt8) -> Bool {
  self.bit(7)
}
