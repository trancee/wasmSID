enum Register {
  SP // Stack Pointer
  A // Accumulator
  X // Index Register X
  Y // Index Register Y
}

struct Registers {
  mut sp : UInt8 // Stack Pointer
  mut a : UInt8 // Accumulator
  mut x : UInt8 // Index Register X
  mut y : UInt8 // Index Register Y
}

fn Registers::new() -> Registers {
  { sp: 0xFF, a: 0, x: 0, y: 0 }
}

fn op_get(self : Registers, register : Register) -> Int {
  match register {
    SP => self.sp.0
    A => self.a.0
    X => self.x.0
    Y => self.y.0
  }
}

fn op_set(self : Registers, register : Register, value : UInt8) -> Unit {
  match register {
    SP => self.sp = value
    A => self.a = value
    X => self.x = value
    Y => self.y = value
  }
}
