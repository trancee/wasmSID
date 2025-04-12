///|
pub(all) enum Flag {
  C = 0b00000001 // 0x01 Carry Flag
  Z = 0b00000010 // 0x02 Zero Flag
  I = 0b00000100 // 0x04 Interrupt Disable Flag
  D = 0b00001000 // 0x08 Decimal Mode Flag
  B = 0b00010000 // 0x10 Break Command Flag
  U = 0b00100000 // 0x20 Unused Flag
  V = 0b01000000 // 0x40 Overflow Flag
  N = 0b10000000 // 0x80 Negative Flag
} derive(Eq)

///| 0x01 Carry Flag
const CARRY = 0b00000001

///| 0x02 Zero Flag
// const ZERO = 0b00000010

///| 0x04 Interrupt Disable Flag
// const INTERRUPT = 0b00000100

///| 0x08 Decimal Mode Flag
// const DECIMAL = 0b00001000

///| 0x10 Break Command Flag
const BREAK = 0b00010000

///| 0x20 Unused Flag
const UNUSED = 0b00100000

///| 0x40 Overflow Flag
const OVERFLOW = 0b01000000

///| 0x80 Negative Flag
const NEGATIVE = 0b10000000

///|
pub fn Flag::lor(self : Flag, flag : Flag) -> Int {
  self.bits() | flag.bits()
}

///|
fn Flag::bits(self : Flag) -> Int {
  match self {
    C => 0b00000001 // 0x01 Carry Flag
    Z => 0b00000010 // 0x02 Zero Flag
    I => 0b00000100 // 0x04 Interrupt Disable Flag
    D => 0b00001000 // 0x08 Decimal Mode Flag
    B => 0b00010000 // 0x10 Break Command Flag
    U => 0b00100000 // 0x20 Unused Flag
    V => 0b01000000 // 0x40 Overflow Flag
    N => 0b10000000 // 0x80 Negative Flag
  }
}

///|
struct Flags {
  mut c : Bool // 0: Carry Flag
  mut z : Bool // 1: Zero Flag
  mut i : Bool // 2: Interrupt Disable Flag
  mut d : Bool // 3: Decimal Mode Flag
  mut b : Bool // 4: Break Command Flag
  mut u : Bool // 5: Unused Flag
  mut v : Bool // 6: Overflow Flag
  mut n : Bool // 7: Negative Flag
} derive(Show, Eq)

///|
fn Flags::new(flags~ : UInt8 = 0x00) -> Flags {
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

// fn Flags::to_string(self : Flags) -> String {
//   if self[N] { "N" } else { "n" } + if self[V] { "V" } else { "v" } + "-" + if self[B] {
//     "B"
//   } else {
//     "b"
//   } + if self[D] { "D" } else { "d" } + if self[I] { "I" } else { "i" } + if self[Z] {
//     "Z"
//   } else {
//     "z"
//   } + if self[C] { "C" } else { "c" }
// }

///|
fn Flags::op_get(self : Flags, flag : Flag) -> Bool {
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

///|
fn Flags::op_set(self : Flags, flag : Flag, value : Bool) -> Unit {
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

///|
fn Flags::reset(self : Flags) -> Unit {
  self[C] = false
  self[Z] = false
  self[I] = false
  self[D] = false
  self[B] = true
  self[U] = true
  self[V] = false
  self[N] = false
}

///|
fn Flags::clear(self : Flags, flag : Flag) -> Unit {
  self[flag] = false
}

///|
fn Flags::is_clear(self : Flags, flag : Flag) -> Bool {
  self[flag] == false
}

///|
fn Flags::not_set(self : Flags, flag : Flag) -> Bool {
  self[flag] == false
}

// fn Flags::set(self : Flags, flag : Flag) -> Unit {
//   self[flag] = true
// }

///|
fn Flags::is_set(self : Flags, flag : Flag) -> Bool {
  self[flag] == true
}

// Get status register value.
///|
pub fn Flags::get(self : Flags) -> UInt8 {
  self.getC() |
  self.getZ() |
  self.getI() |
  self.getD() |
  self.getB() |
  self.getU() |
  self.getV() |
  self.getN()
}

// Set status register value.
///|
pub fn Flags::set(self : Flags, flags : UInt8) -> Unit {
  self[C] = flags.bit(0)
  self[Z] = flags.bit(1)
  self[I] = flags.bit(2)
  self[D] = flags.bit(3)
  self[B] = flags.bit(4)
  self[U] = flags.bit(5)
  self[V] = flags.bit(6)
  self[N] = flags.bit(7)
}

///|
fn Flags::carry(self : Flags) -> Bool {
  self[C]
}

///|
fn Flags::not_carry(self : Flags) -> Bool {
  not(self.carry())
}

///|
fn Flags::clear_carry(self : Flags) -> Unit {
  self[C] = false
}

///|
fn Flags::set_carry(self : Flags) -> Unit {
  self[C] = true
}

///|
fn Flags::zero(self : Flags) -> Bool {
  self[Z]
}

///|
fn Flags::not_zero(self : Flags) -> Bool {
  not(self.zero())
}

///|
fn Flags::interrupt(self : Flags) -> Bool {
  self[I]
}

// fn Flags::not_interrupt(self : Flags) -> Bool {
//   not(self.interrupt())
// }

///|
fn Flags::clear_interrupt(self : Flags) -> Unit {
  self[I] = false
}

///|
pub fn Flags::set_interrupt(self : Flags) -> Unit {
  self[I] = true
}

///|
fn Flags::clear_break(self : Flags) -> Unit {
  self[B] = false
}

///|
fn Flags::set_break(self : Flags) -> Unit {
  self[B] = true
}

///|
fn Flags::decimal(self : Flags) -> Bool {
  self[D]
}

///|
fn Flags::clear_decimal(self : Flags) -> Unit {
  self[D] = false
}

///|
fn Flags::set_decimal(self : Flags) -> Unit {
  self[D] = true
}

///|
fn Flags::not_decimal(self : Flags) -> Bool {
  not(self.decimal())
}

///|
fn Flags::unused(self : Flags) -> Bool {
  self[U]
}

///|
fn Flags::clear_unused(self : Flags) -> Unit {
  self[U] = false
}

///|
fn Flags::set_unused(self : Flags) -> Unit {
  self[U] = true
}

///|
fn Flags::overflow(self : Flags) -> Bool {
  self[V]
}

///|
fn Flags::not_overflow(self : Flags) -> Bool {
  not(self.overflow())
}

///|
fn Flags::clear_overflow(self : Flags) -> Unit {
  self[V] = false
}

///|
fn Flags::set_overflow(self : Flags) -> Unit {
  self[V] = true
}

///|
fn Flags::negative(self : Flags) -> Bool {
  self[N]
}

///|
fn Flags::not_negative(self : Flags) -> Bool {
  not(self.negative())
}

///|
fn Flags::getC(self : Flags) -> Int {
  self[C].to_int() << 0
}

///|
fn Flags::getZ(self : Flags) -> Int {
  self[Z].to_int() << 1
}

///|
fn Flags::getI(self : Flags) -> Int {
  self[I].to_int() << 2
}

///|
fn Flags::getD(self : Flags) -> Int {
  self[D].to_int() << 3
}

///|
fn Flags::getB(self : Flags) -> Int {
  self[B].to_int() << 4
}

///|
fn Flags::getU(self : Flags) -> Int {
  self[U].to_int() << 5
}

///|
fn Flags::getV(self : Flags) -> Int {
  self[V].to_int() << 6
}

///|
fn Flags::getN(self : Flags) -> Int {
  self[N].to_int() << 7
}

///|
fn Flags::setN(self : Flags, value : Bool) -> Unit {
  self[N] = value
}

///|
fn Flags::setB(self : Flags, value : Bool) -> Unit {
  self[B] = value
}

///|
fn Flags::setI(self : Flags, value : Bool) -> Unit {
  self[I] = value
}

///|
fn Flags::setU(self : Flags, value : Bool) -> Unit {
  self[U] = value
}

///|
fn Flags::setV(self : Flags, value : Bool) -> Unit {
  self[V] = value
}

///|
fn Flags::setC(self : Flags, value : Bool) -> Unit {
  self[C] = value
}

///|
fn Flags::setZ(self : Flags, value : Bool) -> Unit {
  self[Z] = value
}

// Set N and Z flag values.
///|
fn Flags::setZN(self : Flags, value : UInt8) -> Unit {
  self.setZ(value == 0)
  self.setN(value.bit(7))
}
