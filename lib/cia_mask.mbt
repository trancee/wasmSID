pub type ICR UInt8 derive(Eq, Compare, Debug)

fn land(self : ICR, value : Mask) -> ICR {
  self.0 & value[value]
}

fn lor(self : ICR, value : Mask) -> UInt8 {
  self.0 | value[value]
}

fn to_int(self : ICR) -> Int {
  self.0.0
}

fn has(self : ICR, mask : Mask) -> Bool {
  (self.0 & mask[mask]) != 0
}

enum Mask {
  TIMER_A
  TIMER_B
  ALARM
  SERIAL_PORT
  FLAG
  SET_CLEAR
  IR
}

fn has(self : Mask, mask : Mask) -> Bool {
  self[mask] != 0
}

fn mask(mask : Mask) -> Int {
  mask[mask]
}

fn op_get(self : Mask, mask : Mask) -> Int {
  match mask {
    TIMER_A => 1
    TIMER_B => 2
    ALARM => 3
    SERIAL_PORT => 4
    FLAG => 5
    SET_CLEAR => 7
    IR => 7
  }
}

fn land(self : Mask, value : Int) -> Int {
  self & value
}

fn lor(self : Mask, value : Mask) -> Mask {
  self | value
}
