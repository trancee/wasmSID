///|
pub type ICR UInt8 derive(Eq, Compare)

///|
pub enum ICRFlags {
  NONE
  //
  TA
  TB
  ALRM
  SP
  FLG
  //
  SC
  IR
}

///|
fn ICRFlags::op_get(_ : ICRFlags, flag : ICRFlags) -> UInt8 {
  match flag {
    NONE => 0
    //
    TA => u8(1 << 0)
    TB => u8(1 << 1)
    ALRM => u8(1 << 2)
    SP => u8(1 << 3)
    FLG => u8(1 << 4)
    // u8(1 << 5)
    // u8(1 << 6)
    SC => u8(1 << 7)
    IR => u8(1 << 7)
  }
}

///|
fn ICR::land(self : ICR, value : ICRFlags) -> ICR {
  self._ & value[value]
}

///|
fn ICR::lor(self : ICR, value : ICR) -> ICR {
  self._ | value._
}

///|
fn icr(flag : ICRFlags) -> UInt8 {
  flag[flag]
}

///|
fn ICR::has(self : ICR, mask : ICRFlags) -> Bool {
  (self._ & mask[mask]) != 0
}

///|
fn ICR::clear(self : ICR, mask : ICRFlags) -> CRA {
  self._ & (-mask[mask] - 1)
}
