enum Flag {
  C // Carry Flag
  Z // Zero Flag
  I // Interrupt Disable Flag
  D // Decimal Mode Flag
  B // Break Command Flag
  U // Unused Flag
  V // Overflow Flag
  N // Negative Flag
}

struct Flags {
  mut c : Bool // Carry Flag
  mut z : Bool // Zero Flag
  mut i : Bool // Interrupt Disable Flag
  mut d : Bool // Decimal Mode Flag
  mut b : Bool // Break Command Flag
  mut u : Bool // Unused Flag
  mut v : Bool // Overflow Flag
  mut n : Bool // Negative Flag
}

fn Flags::new() -> Flags {
  {
    c: false,
    z: false,
    i: false,
    d: false,
    b: false,
    u: false,
    v: false,
    n: false,
  }
}

fn op_get(self : Flags, flag : Flag) -> Bool {
  match flag {
    C => self.c
    Z => self.z
    I => self.i
    D => self.d
    B => self.b
    U => self.u
    V => self.v
    N => self.n
  }
}

fn op_set(self : Flags, flag : Flag, value : Bool) -> Unit {
  match flag {
    C => self.c = value
    Z => self.z = value
    I => self.i = value
    D => self.d = value
    B => self.b = value
    U => self.u = value
    V => self.v = value
    N => self.n = value
  }
}

fn reset(self : Flags) -> Unit {
  self[C] = false
  self[Z] = false
  self[I] = false
  self[D] = false
  self[B] = false
  self[U] = false
  self[V] = false
  self[N] = false
}

// Get status register value.
fn get(self : Flags) -> UInt8 {
  self.getC().lor(self.getZ()).lor(self.getI()).lor(self.getD()).lor(
    self.getB(),
  ).lor(self.getU()).lor(self.getV()).lor(self.getN())
}

// Set status register value.
fn set(self : Flags, flags : UInt8) -> Unit {
  self[C] = flags.bit(0)
  self[Z] = flags.bit(1)
  self[I] = flags.bit(2)
  self[D] = flags.bit(3)
  self[B] = flags.bit(4)
  self[U] = flags.bit(5)
  self[V] = flags.bit(6)
  self[N] = flags.bit(7)
}

fn getC(self : Flags) -> Int {
  self[C].to_int().lsl(0)
}

fn getZ(self : Flags) -> Int {
  self[Z].to_int().lsl(1)
}

fn getI(self : Flags) -> Int {
  self[I].to_int().lsl(2)
}

fn getD(self : Flags) -> Int {
  self[D].to_int().lsl(3)
}

fn getB(self : Flags) -> Int {
  self[B].to_int().lsl(4)
}

fn getU(self : Flags) -> Int {
  self[U].to_int().lsl(5)
}

fn getV(self : Flags) -> Int {
  self[V].to_int().lsl(6)
}

fn getN(self : Flags) -> Int {
  self[N].to_int().lsl(7)
}

fn setN(self : Flags, value : UInt8) -> Unit {
  self[N] = value.land(0b10000000) != 0
}

fn setC(self : Flags, value : UInt8) -> Unit {
  self[C] = value.bit(0)
}

fn setZ(self : Flags, value : UInt8) -> Unit {
  self[Z] = value == 0
}

// Set N and Z flag values.
fn setZN(self : Flags, value : UInt8) -> Unit {
  self.setZ(value)
  self.setN(value)
}
