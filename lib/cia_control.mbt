pub type CRA UInt8 derive(Eq, Compare, Debug)

fn land(self : CRA, value : CRAFlags) -> CRA {
  self.0 & value[value]
}

fn lor(self : CRA, value : CRA) -> CRA {
  self.0 | value.0
}

enum CRAFlags {
  ENABLE_TIMERA
  PORTB6_TIMERA
  TOGGLED_PORTB6
  ONESHOT_TIMERA
  FORCELOADA_STROBE
  TIMERA_FROM_CNT
  SERIALPORT_IS_OUTPUT
  TIMEOFDAY_50Hz
}

fn has(self : CRA, mask : CRAFlags) -> Bool {
  (self.0 & mask[mask]) != 0
}

fn clear(self : CRA, mask : CRAFlags) -> CRA {
  self.0 ^ mask[mask]
}

fn lor(self : CRAFlags, value : CRAFlags) -> CRAFlags {
  self | value
}

// fn controlA(self : UInt8, control : ControlA) -> Bool {
//   (self & control[control]) != 0
// }

fn op_get(self : CRAFlags, control : CRAFlags) -> Int {
  match control {
    ENABLE_TIMERA => 0x01
    PORTB6_TIMERA => 0x02
    TOGGLED_PORTB6 => 0x04
    ONESHOT_TIMERA => 0x08
    FORCELOADA_STROBE => 0x10
    TIMERA_FROM_CNT => 0x20
    SERIALPORT_IS_OUTPUT => 0x40
    TIMEOFDAY_50Hz => 0x80
  }
}

// fn land(self : ControlA, value : Int) -> Int {
//   self & value
// }

// fn lor(self : ControlA, value : ControlA) -> ControlA {
//   self | value
// }

enum ControlB {
  ENABLE_TIMERB
  PORTB7_TIMERB
  TOGGLED_PORTB7
  ONESHOT_TIMERB
  FORCELOADB_STROBE
  TIMERB_FROM_CPUCLK
  TIMERB_FROM_CNT
  TIMERB_FROM_TIMERA
  TIMERB_FROM_TIMERA_AND_CNT
  TIMEOFDAY_WRITE_SETS_ALARM
}

fn controlB(self : UInt8, control : ControlB) -> Bool {
  (self & control[control]) != 0
}

fn op_get(self : ControlB, control : ControlB) -> Int {
  match control {
    ENABLE_TIMERB => 0x01
    PORTB7_TIMERB => 0x02
    TOGGLED_PORTB7 => 0x04
    ONESHOT_TIMERB => 0x08
    FORCELOADB_STROBE => 0x10
    TIMERB_FROM_CPUCLK => 0x00
    TIMERB_FROM_CNT => 0x20
    TIMERB_FROM_TIMERA => 0x40
    TIMERB_FROM_TIMERA_AND_CNT => 0x60
    TIMEOFDAY_WRITE_SETS_ALARM => 0x80
  }
}

fn land(self : ControlB, value : Int) -> Int {
  self & value
}

fn lor(self : ControlB, value : ControlB) -> ControlB {
  self | value
}
