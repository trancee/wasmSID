pub type ICR UInt8 derive(Eq, Compare)

enum ICRFlags {
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

fn ICRFlags::op_get(self : ICRFlags, flag : ICRFlags) -> Int {
  match flag {
    NONE => 0
    //
    TA => 1 << 0
    TB => 1 << 1
    ALRM => 1 << 2
    SP => 1 << 3
    FLG => 1 << 4
    // 1 << 5
    // 1 << 6
    SC => 1 << 7
    IR => 1 << 7
  }
}

fn ICR::land(self : ICR, value : ICRFlags) -> ICR {
  self._ & value[value]
}

fn ICR::lor(self : ICR, value : ICR) -> ICR {
  self._ | value._
}

fn icr(flag : ICRFlags) -> Int {
  flag[flag]
}

fn ICR::has(self : ICR, mask : ICRFlags) -> Bool {
  (self._ & mask[mask]) != 0
}

fn ICR::clear(self : ICR, mask : ICRFlags) -> CRA {
  self._ & (-mask[mask] - 1)
}
