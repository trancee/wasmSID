///|
pub(all) enum Register {
  SP // Stack Pointer
  A // Accumulator
  X // Index Register X
  Y // Index Register Y
}

///|
pub struct Registers {
  mut sp : UInt8 // Stack Pointer
  mut a : UInt8 // Accumulator
  mut x : UInt8 // Index Register X
  mut y : UInt8 // Index Register Y
} derive(Show, Default)

///|
test {
  let r = Registers::new()
  assert_eq!(r.sp, 0xFF)
}

///|
test {
  let r = Registers::new(sp=0xFFFF)
  assert_eq!(r.sp, 0xFF)
}

///|
test {
  let r = Registers::new(sp=-1)
  assert_eq!(r.sp, 0xFF)
}

///|
test {
  let r = Registers::new(sp=0)
  assert_eq!(r.sp, 0x00)
}

///|
pub fn Registers::new(
  sp~ : UInt8 = 0xFF,
  a~ : UInt8 = 0x00,
  x~ : UInt8 = 0x00,
  y~ : UInt8 = 0x00
) -> Registers {
  { sp, a, x, y }
}

///|
pub fn Registers::reset(self : Registers) -> Unit {
  self.sp = 0xFF
  self.a = 0x00
  self.x = 0x00
  self.y = 0x00
}

///|
pub fn Registers::op_get(self : Registers, register : Register) -> UInt8 {
  match register {
    SP => self.sp
    A => self.a
    X => self.x
    Y => self.y
  }
}

///|
pub fn Registers::op_set(
  self : Registers,
  register : Register,
  value : UInt8
) -> Unit {
  match register {
    SP => self.sp = value & 0xFF
    A => self.a = value & 0xFF
    X => self.x = value & 0xFF
    Y => self.y = value & 0xFF
  }
}

// Tests

///|
test "new_registers" {
  let r = Registers::new()
  assert_eq!(r[SP], 0xFF)
  assert_eq!(r[A], 0x00)
  assert_eq!(r[X], 0x00)
  assert_eq!(r[Y], 0x00)
}

///|
test "new_registers_with_sp" {
  let r = Registers::new(sp=0x1234)
  assert_eq!(r[SP], 0x34)
  assert_eq!(r[A], 0x00)
  assert_eq!(r[X], 0x00)
  assert_eq!(r[Y], 0x00)
}

///|
test "new_registers_with_setting_sp_afterwards" {
  let r = Registers::new()
  assert_eq!(r[SP], 0xFF)
  assert_eq!(r[A], 0x00)
  assert_eq!(r[X], 0x00)
  assert_eq!(r[Y], 0x00)
  r[SP] = 0x1234
  assert_eq!(r[SP], 0x34)
}

///|
test "new_registers_with_sp_overflow" {
  let r = Registers::new(sp=0xFF)
  assert_eq!(r[SP], 0xFF)
  assert_eq!(r[A], 0x00)
  assert_eq!(r[X], 0x00)
  assert_eq!(r[Y], 0x00)
  r[SP] += 1
  assert_eq!(r[SP], 0x00)
}

///|
test "new_registers_with_sp_underflow" {
  let r = Registers::new(sp=0x00)
  assert_eq!(r[SP], 0x00)
  assert_eq!(r[A], 0x00)
  assert_eq!(r[X], 0x00)
  assert_eq!(r[Y], 0x00)
  r[SP] -= 1
  assert_eq!(r[SP], 0xFF)
}
