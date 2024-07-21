pub type ICR UInt8 derive(Eq, Compare, Debug)

enum ICRFlags {
  NONE
  //
  TA
  TB
  ALRM
  SP
  FLG
  //
  //
  SC
  IR
}

fn op_get(self : ICRFlags, flag : ICRFlags) -> Int {
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

fn land(self : ICR, value : ICRFlags) -> ICR {
  self.0 & value[value]
}

fn lor(self : ICR, value : ICR) -> ICR {
  self.0 | value.0
}

fn icr(flag : ICRFlags) -> Int {
  flag[flag]
}

fn has(self : ICR, mask : ICRFlags) -> Bool {
  (self.0 & mask[mask]) != 0
}

fn clear(self : ICR, mask : ICRFlags) -> CRA {
  self.0 & (-mask[mask] - 1)
}
