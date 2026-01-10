///|
pub struct CRA(UInt8) derive(Eq, Compare)

///|
/// There are two control registers in the 6526, CRA and CRB.
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
test "CRAFlags::op_get/basic_flags" {
  let dummy = CRAFlags::NONE
  inspect(dummy.op_get(NONE), content="0")
  inspect(dummy.op_get(START), content="1")
  inspect(dummy.op_get(PBON), content="2")
  inspect(dummy.op_get(OUTMODE), content="4")
  inspect(dummy.op_get(RUNMODE), content="8")
  inspect(dummy.op_get(LOAD), content="16")
  inspect(dummy.op_get(INMODE), content="32")
  inspect(dummy.op_get(SPMODE), content="64")
  inspect(dummy.op_get(TODIN), content="128")
}

///|
test "CRAFlags::op_get/bit_positions" {
  let dummy = CRAFlags::NONE
  // Test that each flag corresponds to exactly one bit position
  inspect(dummy.op_get(START), content="1") // 1 << 0
  inspect(dummy.op_get(PBON), content="2") // 1 << 1  
  inspect(dummy.op_get(OUTMODE), content="4") // 1 << 2
  inspect(dummy.op_get(RUNMODE), content="8") // 1 << 3
  inspect(dummy.op_get(LOAD), content="16") // 1 << 4
  inspect(dummy.op_get(INMODE), content="32") // 1 << 5
  inspect(dummy.op_get(SPMODE), content="64") // 1 << 6
  inspect(dummy.op_get(TODIN), content="128") // 1 << 7
}

///|
test "CRAFlags::op_get/none_flag" {
  let dummy = CRAFlags::NONE
  // NONE should return 0 (no bits set)
  inspect(dummy.op_get(NONE), content="0")

  // Test that dummy parameter doesn't affect result
  let start_dummy = CRAFlags::START
  inspect(start_dummy.op_get(NONE), content="0")
  inspect(start_dummy.op_get(START), content="1")
}

///|
fn CRAFlags::op_get(_ : CRAFlags, flag : CRAFlags) -> Int {
  match flag {
    NONE => 0
    //
    START => 1 << 0
    PBON => 1 << 1
    OUTMODE => 1 << 2
    RUNMODE => 1 << 3
    LOAD => 1 << 4
    INMODE => 1 << 5
    SPMODE => 1 << 6
    TODIN => 1 << 7
  }
}

///|
// fn CRA::land(self : CRA, value : CRAFlags) -> CRA {
//   self.0 & value[value]
// }

///|
// fn CRA::lor(self : CRA, value : CRA) -> CRA {
//   self.0 | value.0
// }

///|
fn cra(flag : CRAFlags) -> Int {
  flag[flag]
}

///|
// fn CRA::has(self : CRA, mask : CRAFlags) -> Bool {
//   (self.0 & mask[mask]) != 0
// }

///|
// fn CRA::clear(self : CRA, mask : CRAFlags) -> CRA {
//   self.0 & (-mask[mask] - 1)
// }
