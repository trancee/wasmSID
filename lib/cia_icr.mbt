///|
pub struct ICR(UInt8) derive(Eq, Compare)

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
test "ICRFlags/basic_variants" {
  // Test that all enum variants can be created and are distinct
  let none = ICRFlags::NONE
  let ta = ICRFlags::TA
  let tb = ICRFlags::TB
  let alrm = ICRFlags::ALRM
  let sp = ICRFlags::SP
  let flg = ICRFlags::FLG
  let sc = ICRFlags::SC
  let ir = ICRFlags::IR

  // Test that they can be used in pattern matching
  fn classify_flag(flag : ICRFlags) -> String {
    match flag {
      NONE => "none"
      TA => "timer_a"
      TB => "timer_b"
      ALRM => "alarm"
      SP => "serial_port"
      FLG => "flag"
      SC => "set_clear"
      IR => "interrupt"
    }
  }

  inspect(classify_flag(none), content="none")
  inspect(classify_flag(ta), content="timer_a")
  inspect(classify_flag(tb), content="timer_b")
  inspect(classify_flag(alrm), content="alarm")
  inspect(classify_flag(sp), content="serial_port")
  inspect(classify_flag(flg), content="flag")
  inspect(classify_flag(sc), content="set_clear")
  inspect(classify_flag(ir), content="interrupt")
}

///|
test "ICRFlags/comprehensive_coverage" {
  // Test all variants in a collection to ensure none are missing
  let all_flags = [
    ICRFlags::NONE,
    ICRFlags::TA,
    ICRFlags::TB,
    ICRFlags::ALRM,
    ICRFlags::SP,
    ICRFlags::FLG,
    ICRFlags::SC,
    ICRFlags::IR,
  ]

  // Verify we have 8 variants (though SC and IR might be the same)
  assert_eq(all_flags.length(), 8)

  // Test that each can be used in match expressions without compilation errors
  all_flags.each(fn(flag) {
    let description = match flag {
      NONE => "No interrupt"
      TA => "Timer A interrupt"
      TB => "Timer B interrupt"
      ALRM => "Alarm interrupt"
      SP => "Serial port interrupt"
      FLG => "Flag interrupt"
      SC => "Set/Clear bit"
      IR => "Interrupt occurred bit"
    }
    assert_true(description.length() > 0)
  })
}

///|
fn ICRFlags::op_get(_ : ICRFlags, flag : ICRFlags) -> Int {
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

///|
// fn ICR::land(self : ICR, value : ICRFlags) -> ICR {
//   self.0 & value[value]
// }

///|
// fn ICR::lor(self : ICR, value : ICR) -> ICR {
//   self.0 | value.0
// }

///|
fn icr(flag : ICRFlags) -> Int {
  flag[flag]
}

///|
// fn ICR::has(self : ICR, mask : ICRFlags) -> Bool {
//   (self.0 & mask[mask]) != 0
// }

///|
// fn ICR::clear(self : ICR, mask : ICRFlags) -> CRA {
//   self.0 & (-mask[mask] - 1)
// }
