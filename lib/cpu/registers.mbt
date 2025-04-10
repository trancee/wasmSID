///|
pub enum Register {
  SP // Stack Pointer
  A // Accumulator
  X // Index Register X
  Y // Index Register Y
}

///|
struct Registers {
  mut sp : UInt8 // Stack Pointer
  mut a : UInt8 // Accumulator
  mut x : UInt8 // Index Register X
  mut y : UInt8 // Index Register Y
}

///|
fn Registers::new(sp~ : UInt8 = 0xFF) -> Registers {
  { sp, a: 0, x: 0, y: 0 }
}

///|
fn reset(self : Registers) -> Unit {
  self.sp = 0xFF
  self.a = 0x00
  self.x = 0x00
  self.y = 0x00
}

///|
fn op_get(self : Registers, register : Register) -> UInt8 {
  match register {
    SP => self.sp
    A => self.a
    X => self.x
    Y => self.y
  }
}

///|
fn op_set(self : Registers, register : Register, value : UInt8) -> Unit {
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
