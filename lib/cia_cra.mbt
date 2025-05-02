///|
pub type CRA UInt8 derive(Eq, Compare)

///| There are two control registers in the 6526, CRA and CRB.
/// CRA is associated with TIMER A and CRB is associated with TIMER B.
/// The register format is as follows:
pub enum CRAFlags {
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
  /// 1 = TIMER A counts positive CNT transitions.
  /// 0 = TIMER A counts phi2 pulses.
  INMODE
  /// 1 = SERIAL PORT output (CNT sources shift clock).
  /// 0 = SERIAL PORT input (external shift clock required).
  SPMODE
  /// 1 = 50Hz clock required on TOD pin for accurate time.
  /// 0 = 60Hz clock required on TOD pin for accurate time.
  TODIN
}

///|
fn CRAFlags::op_get(_ : CRAFlags, flag : CRAFlags) -> UInt8 {
  match flag {
    NONE => 0
    //
    START => u8(1 << 0)
    PBON => u8(1 << 1)
    OUTMODE => u8(1 << 2)
    RUNMODE => u8(1 << 3)
    LOAD => u8(1 << 4)
    INMODE => u8(1 << 5)
    SPMODE => u8(1 << 6)
    TODIN => u8(1 << 7)
  }
}

///|
fn CRA::land(self : CRA, value : CRAFlags) -> CRA {
  self._ & value[value]
}

///|
fn CRA::lor(self : CRA, value : CRA) -> CRA {
  self._ | value._
}

///|
fn cra(flag : CRAFlags) -> UInt8 {
  flag[flag]
}

///|
fn CRA::has(self : CRA, mask : CRAFlags) -> Bool {
  (self._ & mask[mask]) != 0
}

///|
fn CRA::clear(self : CRA, mask : CRAFlags) -> CRA {
  self._ & (-mask[mask] - 1)
}
