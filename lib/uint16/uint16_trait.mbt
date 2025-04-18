//
// UInt16
//

///|
pub trait U16 {
  u16(Self) -> UInt16
}

///|
pub fn u16[T : U16](t : T) -> UInt16 {
  t.u16()
}

///|
pub fn to_u16[T : U16](t : T) -> UInt16 {
  t.u16()
}

///|
pub impl U16 for Int with u16(self) {
  UInt16::new(self)
}

///|
pub impl U16 for UInt16 with u16(self) {
  UInt16::new(self.to_int())
}

// ///|
// pub impl U16 for UInt8 with u16(self) {
//   UInt16::new(self.to_int())
// }

///|
pub impl U16 for Byte with u16(self) {
  UInt16::new(self.to_int())
}
