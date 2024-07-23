pub type CRB UInt8 derive(Eq, Compare)

/// There are two control registers in the 6526, CRA and CRB.
/// CRA is associated with TIMER A and CRB is associated with TIMER B.
/// The register format is as follows:

enum CRBFlags {
  NONE
  //
  /// 1 = START TIMER A
  /// 0 = STOP TIMER A
  /// (This bit is automatically reset when underflow occurs during one-shot mode).
  START
  /// 1 = TIMER A output appears on PB6.
  /// 0 = PB6 normal operation.
  PBON
  /// 1 = TOGGLE
  /// 0 = PULSE
  OUTMODE
  /// 1 = ONE-SHOT
  /// 0 = CONTINUOUS
  RUNMODE
  /// 1 = FORCE LOAD
  /// (This is a STROBE input, there is no data storage, bit 4 will always read back a zero and writing a zero has no effect).
  LOAD
  /// 0 = TIMER B counts phi2 pulses.
  /// 1 = TIMER B counts positive CNT transitions.
  INMODE
  /// 0 = TIMER B counts TIMER A underflow pulses.
  /// 1 = TIMER B counts TIMER A underflow pulses while CNT is high.
  UNDERFLOW
  /// 1 = writing to TOD registers sets ALARM.
  /// 0 = writing to TOD registers sets TOD clock.
  ALARM
}

fn op_get(self : CRBFlags, flag : CRBFlags) -> Int {
  match flag {
    NONE => 0
    //
    START => 1 << 0
    PBON => 1 << 1
    OUTMODE => 1 << 2
    RUNMODE => 1 << 3
    LOAD => 1 << 4
    INMODE => 1 << 5
    UNDERFLOW => 1 << 6
    ALARM => 1 << 7
  }
}

fn land(self : CRB, value : CRBFlags) -> CRB {
  self.0 & value[value]
}

fn lor(self : CRB, value : CRB) -> CRB {
  self.0 | value.0
}

fn crb(flag : CRBFlags) -> Int {
  flag[flag]
}

fn has(self : CRB, mask : CRBFlags) -> Bool {
  (self.0 & mask[mask]) != 0
}

fn clear(self : CRB, mask : CRBFlags) -> CRB {
  self.0 & (-mask[mask] - 1)
}
