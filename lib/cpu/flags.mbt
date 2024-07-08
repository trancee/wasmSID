enum Flag {
  C // Carry Flag
  Z // Zero Flag
  I // Interrupt Disable Flag
  D // Decimal Mode Flag
  B // Break Command Flag
  U // Unused Flag
  V // Overflow Flag
  N // Negative Flag
} derive(Debug, Show, Eq)

fn op_add(self : Flag, flag : Flag) -> Int {
  println(
    "Flag::" + UInt8(self.bits()).to_hex() + " : " + UInt8(flag.bits()).to_hex(),
  )
  self.bits().lor(flag.bits())
}

fn bits(self : Flag) -> Int {
  match self {
    C => 0b00000001 // Carry Flag
    Z => 0b00000010 // Zero Flag
    I => 0b00000100 // Interrupt Disable Flag
    D => 0b00001000 // Decimal Mode Flag
    B => 0b00010000 // Break Command Flag
    U => 0b00100000 // Unused Flag
    V => 0b01000000 // Overflow Flag
    N => 0b10000000 // Negative Flag
  }
}

struct Flags {
  mut c : Bool // 0: Carry Flag
  mut z : Bool // 1: Zero Flag
  mut i : Bool // 2: Interrupt Disable Flag
  mut d : Bool // 3: Decimal Mode Flag
  mut b : Bool // 4: Break Command Flag
  mut u : Bool // 5: Unused Flag
  mut v : Bool // 6: Overflow Flag
  mut n : Bool // 7: Negative Flag
} derive(Debug, Eq)

fn Flags::new(~flags : UInt8 = 0x00) -> Flags {
  {
    c: flags.bit(0),
    z: flags.bit(1),
    i: flags.bit(2),
    d: flags.bit(3),
    b: flags.bit(4),
    u: flags.bit(5),
    v: flags.bit(6),
    n: flags.bit(7),
  }
}

fn Flags::to_string(self : Flags) -> String {
  if self[N] { "N" } else { "n" } + if self[V] { "V" } else { "v" } + "-" + if self[B] {
    "B"
  } else {
    "b"
  } + if self[D] { "D" } else { "d" } + if self[I] { "I" } else { "i" } + if self[Z] {
    "Z"
  } else {
    "z"
  } + if self[C] { "C" } else { "c" }
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

fn clear(self : Flags, flag : Flag) -> Unit {
  self[flag] = false
}

fn is_clear(self : Flags, flag : Flag) -> Bool {
  self[flag] == false
}

fn set(self : Flags, flag : Flag) -> Unit {
  self[flag] = true
}

fn is_set(self : Flags, flag : Flag) -> Bool {
  self[flag] == true
}

// Get status register value.
fn get_flags(self : Flags) -> UInt8 {
  self.getC().lor(self.getZ()).lor(self.getI()).lor(self.getD()).lor(
    self.getB(),
  ).lor(self.getU()).lor(self.getV()).lor(self.getN())
}

// Set status register value.
fn set_flags(self : Flags, flags : UInt8) -> Unit {
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
  // self[N] = value.land(0b10000000) != 0
  self[N] = value.bit(7)
}

fn setC(self : Flags, value : UInt8) -> Unit {
  self[C] = value.bit(0)
}

fn setZ(self : Flags, value : UInt8) -> Unit {
  self[Z] = value.land(0b11111111) == 0
}

// Set N and Z flag values.
fn setZN(self : Flags, value : UInt8) -> Unit {
  self.setZ(value)
  self.setN(value)
}
