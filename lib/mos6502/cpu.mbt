struct CPU {
  mem : Memory
  mut cycles : UInt16
  // Registers
  mut pc : UInt16 // Program Counter
  mut sp : UInt8 // Stack Pointer
  mut a : UInt8 // Accumulator
  mut x : UInt8 // Index Register X
  mut y : UInt8 // Index Register Y
  // Flags
  mut c : Bool // Carry Flag
  mut z : Bool // Zero Flag
  mut i : Bool // Interrupt Disable Flag
  mut d : Bool // Decimal Mode Flag
  mut b : Bool // Break Command Flag
  mut u : Bool // Unused Flag
  mut v : Bool // Overflow Flag
  mut n : Bool // Negative Flag
  //
  mut mode : Mode
}

fn flags(self : CPU) -> UInt8 {
  to_byte(self.c, self.z, self.i, self.d, self.b, self.u, self.v, self.n)
}

fn set_flags(self : CPU, flags : UInt8) -> Unit {
  self.c = flags.bit(0)
  self.z = flags.bit(1)
  self.i = flags.bit(2)
  self.d = flags.bit(3)
  self.b = flags.bit(4)
  self.u = flags.bit(5)
  self.v = flags.bit(6)
  self.n = flags.bit(7)
}

pub fn cpu_new(~pc : UInt16 = 0x0000) -> CPU {
  let mem = Memory::new()
  let cpu : CPU = {
    mem,
    cycles: 0,
    // Registers
    pc,
    sp: 0xFF,
    a: 0,
    x: 0,
    y: 0,
    // Flags
    c: false,
    z: false,
    i: false,
    d: false,
    b: false,
    u: false,
    v: false,
    n: false,
    //
    mode: Absolute,
  }
  cpu
}

// Load a program into memory
fn cpu_load(cpu : CPU, program : Array[UInt8]) -> CPU {
  for i = 0; i < program.length(); i = i + 1 {
    cpu.mem[i] = program[i]
  }
  cpu
}

fn read(self : CPU, addr : Int, ~log : Bool = true) -> UInt8 {
  // if log {
  //   println("$" + u16(addr).to_hex() + " → " + self.mem[addr].to_hex())
  // }
  self.mem[addr]
}

fn read16(self : CPU, addr : Int, ~log : Bool = true) -> UInt16 {
  // if log {
  //   println(
  //     "$" + u16(addr).to_hex() + " → " + self.mem[addr + 1].to_hex() + self.mem[addr].to_hex(),
  //   )
  // }
  u16(self.read(addr + 1, log=false)).lsl(8).lor(self.read(addr, log=false).0)
}

fn read16bug(self : CPU, addr : Int, ~log : Bool = true) -> UInt16 {
  // Low byte wraps without incrementing high byte
  // if log {
  //   println(
  //     "$" + u16(addr).to_hex() + " → " + self.mem[addr + 1].to_hex() + self.mem[addr].to_hex(),
  //   )
  // }
  u16(self.read(addr.land(0xFF00).lor(addr + 1), log=false)).lsl(8).lor(
    self.read(addr, log=false).0,
  )
}

fn write(self : CPU, addr : Int, value : UInt8, ~log : Bool = true) -> Unit {
  self.mem[addr] = value
  // if log {
  //   println("$" + u16(addr).to_hex() + " ← " + self.mem[addr].to_hex())
  // }
}

// fn push(self : CPU, value : UInt8) -> Unit {
//   self.write(0x0100 + self.sp.0, value)
//   self.sp = self.sp - 1
// }

fn push(self : CPU, value : UInt8) -> Unit {
  self.write(u16(self.sp).lor(0x0100).0, value)
  self.sp = self.sp - 1
}

fn push16(self : CPU, value : UInt16) -> Unit {
  self.push(u8(value.lsr(8)))
  self.push(u8(value))
}

// fn pop(self : CPU) -> UInt8 {
//   self.sp = self.sp + 1
//   self.read(0x0100 + self.sp.0)
// }

fn pop(self : CPU) -> UInt8 {
  self.sp = self.sp + 1
  self.read(u16(self.sp).lor(0x0100).0)
}

fn pop16(self : CPU) -> UInt16 {
  u16(self.pop()).lor(u16(self.pop()).lsl(8).0)
}

fn setZ(self : CPU, value : UInt8) -> Unit {
  self.z = value == 0
}

fn setN(self : CPU, value : UInt8) -> Unit {
  self.n = value.land(0b10000000) != 0
}

fn setZN(self : CPU, value : UInt8) -> Unit {
  self.setZ(value)
  self.setN(value)
}

fn step(self : CPU) -> Int {
  let cycles = self.cycles
  let opcode = self.read(self.pc.0)
  //
  let ins = instructions[opcode.0]
  let (name, _, mode, _size, _cycles, pagecycles) = ins
  //
  let addr = self.get_addr(mode)
  //
  let hexpc = self.pc.to_hex()
  let hexaddr = addr.to_hex()
  println("$\(hexpc) \(name) $\(hexaddr)")
  //
  self.pc = self.pc + _size
  self.cycles = self.cycles + _cycles
  //
  (ins.1)(self, addr.0)
  //
  self.cycles - cycles
}

fn get_addr(self : CPU, mode : Mode) -> UInt16 {
  match mode {
    Absolute => self.read16(self.pc + 1)
    AbsoluteX => self.read16(self.pc + 1) + u16(self.x)
    AbsoluteY => self.read16(self.pc + 1) + u16(self.y)
    IndexedIndirect => self.read16bug(self.read(self.pc + 1).0 + self.x.0)
    Indirect => self.read16bug(self.read16(self.pc + 1).0)
    IndirectIndexed => self.read16bug(self.read(self.pc + 1).0) + self.y.0
    ZeroPage => u16(self.read(self.pc + 1))
    ZeroPageX => u16(self.read(self.pc + 1) + self.x) // CHECKME
    ZeroPageY => u16(self.read(self.pc + 1) + self.y)
    Immediate => self.pc + 1
    Accumulator | Implicit => 0
    Relative => {
      let offset = u16(self.read(self.pc + 1))
      if offset < 0x80 {
        self.pc + offset + 2
      } else {
        self.pc + offset + 2 - 0x0100
      }
    }
  }
}

// pagesDiffer returns true if the two addresses reference different pages
fn pageFlip(a : UInt16, b : UInt16) -> Bool {
  a.land(0xFF00) != b.land(0xFF00)
}

// branch, then adds a cycle for taking a branch and adds another cycle
// if the branch jumps to a new page
fn branch(self : CPU, addr : Int) -> Unit {
  if pageFlip(self.pc, addr) {
    self.cycles = self.cycles + 1
  }
  self.pc = addr
  self.cycles = self.cycles + 1
}

fn compare(self : CPU, a : UInt8, b : UInt8) -> Unit {
  self.setZN(a - b)
  self.c = a >= b
}

//
// Instructions
//

// ADC - Add with carry
fn opADC(self : CPU, addr : Int) -> Unit {
  let a = self.a
  let b = self.read(addr)
  let c = U8::u8(self.c)
  self.a = u8(a.0 + b.0 + c.0) // capped at 0xff
  self.setZN(self.a)
  self.c = a.0 + b.0 + c.0 > 0xff // not capped at 0xff
  // (a^b)&0x80 == 0 && (a^self.a)&0x80 != 0
  self.v = a.lxor(b.0).land(0x80) == 0 && a.lxor(self.a.0).land(0x80) != 0
}

// AND - Logical and
// ** opcode name changed
fn opAND(self : CPU, addr : Int) -> Unit {
  self.a = self.a.land(self.read(addr)) // self.a & self.mem[info.address]
  self.setZN(self.a)
}

// ASL - Arithmetic shift left
fn opASL(self : CPU, addr : Int) -> Unit {
  match self.mode {
    Accumulator => {
      self.c = self.a.lsr(7).land(1) != 0 // (self.a >> 7) & 1
      self.a = self.a.lsl(1)
      self.setZN(self.a)
    }
    _ => {
      let mut value = self.read(addr)
      self.c = value.lsr(7).land(1) != 0 // (val >> 7) & 1
      value = value.lsl(1)
      self.write(addr, value)
      self.setZN(value)
    }
  }
}

// BCC - Branch if carry clear
fn opBCC(self : CPU, addr : Int) -> Unit {
  if self.c.not() {
    self.branch(addr)
  }
}

// BCS - Branch if carry set
fn opBCS(self : CPU, addr : Int) -> Unit {
  if self.c {
    self.branch(addr)
  }
}

// BEQ - Branch if equal
fn opBEQ(self : CPU, addr : Int) -> Unit {
  if self.z {
    self.branch(addr)
  }
}

// BIT - Bit test
fn opBIT(self : CPU, addr : Int) -> Unit {
  let value = self.read(addr) // :- same as go!
  self.v = value.lsr(6).land(1) != 0 // (val >> 6) & 1
  self.setZ(value.land(self.a)) // val & self.A
  self.setN(value)
}

// BMI - Branch if minus
fn opBMI(self : CPU, addr : Int) -> Unit {
  if self.n {
    self.branch(addr)
  }
}

// BNE - Branch if minus
fn opBNE(self : CPU, addr : Int) -> Unit {
  if not(self.z) {
    self.branch(addr)
  }
}

// BPL - Branch if positive
fn opBPL(self : CPU, addr : Int) -> Unit {
  if not(self.n) {
    self.branch(addr)
  }
}

// BRK - Force interrupt
fn opBRK(self : CPU, addr : Int) -> Unit {
  self.push16(self.pc)
  self.opPHP(addr)
  self.opSEI(addr)
  self.pc = self.read16(0xFFFE)
}

// BVC - Branch if overflow clear
fn opBVC(self : CPU, addr : Int) -> Unit {
  if not(self.v) {
    self.branch(addr)
  }
}

// BVS - Branch if overflow set
fn opBVS(self : CPU, addr : Int) -> Unit {
  if self.v {
    self.branch(addr)
  }
}

// CLC - Clear carry flag
fn opCLC(self : CPU, addr : Int) -> Unit {
  self.c = false
}

// CLD - Clear decimal mode
fn opCLD(self : CPU, addr : Int) -> Unit {
  self.d = false
}

// CLI - Clear interrupt disable
fn opCLI(self : CPU, addr : Int) -> Unit {
  self.i = false
}

// CLV - Clear overflow flag
fn opCLV(self : CPU, addr : Int) -> Unit {
  self.v = false
}

// CMP - Compare
fn opCMP(self : CPU, addr : Int) -> Unit {
  self.compare(self.a, self.read(addr))
}

// CPX - Compare x register
fn opCPX(self : CPU, addr : Int) -> Unit {
  self.compare(self.x, self.read(addr))
}

// CPY - Compare y register
fn opCPY(self : CPU, addr : Int) -> Unit {
  self.compare(self.y, self.read(addr))
}

// DEC - Decrement memory
// **opcode name
fn opDEC(self : CPU, addr : Int) -> Unit {
  let value = self.read(addr) - 1
  self.write(addr, value)
  self.setZN(value)
}

// DEX - Decrement x register
fn opDEX(self : CPU, addr : Int) -> Unit {
  self.x = self.x - 1 // self.x--
  self.setZN(self.x)
}

// DEY - Decrement y register
fn opDEY(self : CPU, addr : Int) -> Unit {
  self.y = self.y - 1 // self.y--
  self.setZN(self.y)
}

// EOR - Exclusive or
fn opEOR(self : CPU, addr : Int) -> Unit {
  self.a = self.a.lxor(self.read(addr).0)
  self.setZN(self.a)
}

// INC - Increment memory
// **opcode name
fn opINC(self : CPU, addr : Int) -> Unit {
  let value = self.read(addr) + 1
  self.write(addr, value)
  self.setZN(value)
}

// INX - Increment x register
fn opINX(self : CPU, addr : Int) -> Unit {
  self.x = self.x + 1 //self.x++
  self.setZN(self.x)
}

// INY - Increment y register
fn opINY(self : CPU, addr : Int) -> Unit {
  self.y = self.y + 1 // self.y++
  self.setZN(self.y)
}

// JMP - Jump
fn opJMP(self : CPU, addr : Int) -> Unit {
  self.pc = addr
}

// JSR - Jump to subroutine
fn opJSR(self : CPU, addr : Int) -> Unit {
  self.push16(self.pc - 1)
  self.pc = addr
}

// LDA - Load accumulator
fn opLDA(self : CPU, addr : Int) -> Unit {
  self.a = self.read(addr)
  self.setZN(self.a)
}

// LDX - Load x register
fn opLDX(self : CPU, addr : Int) -> Unit {
  self.x = self.read(addr)
  self.setZN(self.x)
}

// LDY - Load y register
fn opLDY(self : CPU, addr : Int) -> Unit {
  self.y = self.read(addr)
  self.setZN(self.y)
}

// LSR - Logical shift right
fn opLSR(self : CPU, addr : Int) -> Unit {
  match self.mode {
    Accumulator => {
      self.c = self.a.land(1) != 0 // self.A & 1
      self.a = self.a.lsr(1) // self.A >>= 1
      self.setZN(self.a)
    }
    _ => {
      let mut value = self.read(addr)
      self.c = value.land(1) != 0 // value & 1
      value = value.lsr(1) // val >>= 1
      self.write(addr, value)
      self.setZN(value)
    }
  }
}

// NOP - No operation
fn opNOP(self : CPU, addr : Int) -> Unit {
  //
}

// ORA - Logical inclusive or
fn opORA(self : CPU, addr : Int) -> Unit {
  self.a = self.a.lor(self.read(addr).0)
  self.setZN(self.a)
}

// PHA - Push accumulator
fn opPHA(self : CPU, addr : Int) -> Unit {
  self.push(self.a)
}

// PHP - Push processor status
fn opPHP(self : CPU, addr : Int) -> Unit {
  self.push(self.flags().lor(0x10))
}

// PLA - Pull accumulator
fn opPLA(self : CPU, addr : Int) -> Unit {
  self.a = self.pop()
  self.setZN(self.a)
}

// PLP - Pull processor status
fn opPLP(self : CPU, addr : Int) -> Unit {
  self.set_flags(self.pop().land(0xEF).lor(0x20)) // pull() & 0xEF | 0x20
}

// ROL - Rotate left
fn opROL(self : CPU, addr : Int) -> Unit {
  let c = if self.c { 1 } else { 0 }
  match self.mode {
    Accumulator => {
      self.c = self.a.lsr(7).land(1) != 0 // (self.A >> 7) & 1
      self.a = self.a.lsl(1).lor(c) // (self.A << 1) | c
      self.setZN(self.a)
    }
    _ => {
      let mut value = self.read(addr)
      self.c = value.lsr(7).land(1) != 0 // (val >> 7) & 1
      value = value.lsl(1).lor(c) // (val << 1) | c
      self.write(addr, value)
      self.setZN(value)
    }
  }
}

// ROR - Rotate right
fn opROR(self : CPU, addr : Int) -> Unit {
  let c = if self.c { 1 } else { 0 }
  match self.mode {
    Accumulator => {
      self.c = self.a.land(1) != 0 // self.A & 1
      self.a = self.a.lsr(1).lor(c.lsl(7)) // (self.A >> 1) | (c << 7)
      self.setZN(self.a)
    }
    _ => {
      let mut value = self.read(addr)
      self.c = value.land(1) != 0 // val & 1
      value = value.lsr(1).lor(c.lsl(7)) // (val >> 1) | (c << 7)
      self.write(addr, value)
      self.setZN(value)
    }
  }
}

// RTI - Return from interrupt
fn opRTI(self : CPU, addr : Int) -> Unit {
  self.set_flags(self.pop().land(0xEF).lor(0x20)) // pull() & 0xEF | 0x20
  self.pc = self.pop16()
}

// RTS - Return from subrouting
fn opRTS(self : CPU, addr : Int) -> Unit {
  self.pc = self.pop16() + 1
}

// SBC - Subtract with carry
fn opSBC(self : CPU, addr : Int) -> Unit {
  let a = self.a
  let b = self.read(addr)
  let c = U8::u8(self.c)
  // self.a = u8(a.0 - b.0 - (1 - c.0)) // capped at 0xff
  self.a = a - b - (u8(1) - c) // capped at 0xff
  self.setZN(self.a)
  self.c = a.0 - b.0 - (1 - c.0) >= 0 // not capped at 0xff
  self.v = a.lxor(b.0).land(0x80) != 0 && a.lxor(self.a.0).land(0x80) != 0
}

// SEC - Set carry flag
fn opSEC(self : CPU, addr : Int) -> Unit {
  self.c = true
}

// SED - Set decimal flag
fn opSED(self : CPU, addr : Int) -> Unit {
  self.d = true
}

// SEI - Set interrupt disable
fn opSEI(self : CPU, addr : Int) -> Unit {
  self.i = true
}

// STA - Store accumulator
fn opSTA(self : CPU, addr : Int) -> Unit {
  self.write(addr, self.a)
}

// STX - Store x register
fn opSTX(self : CPU, addr : Int) -> Unit {
  self.write(addr, self.x)
}

// STY - Store y register
fn opSTY(self : CPU, addr : Int) -> Unit {
  self.write(addr, self.y)
}

// TAX - Transfer accumulator to x
fn opTAX(self : CPU, addr : Int) -> Unit {
  self.x = self.a
  self.setZN(self.x)
}

// TAY - Transfer accumulator to y
fn opTAY(self : CPU, addr : Int) -> Unit {
  self.y = self.a
  self.setZN(self.y)
}

// TSX - Transfer stack pointer to x
fn opTSX(self : CPU, addr : Int) -> Unit {
  self.x = self.sp
  self.setZN(self.x)
}

// TXA - Transfer x to accumulator
fn opTXA(self : CPU, addr : Int) -> Unit {
  self.a = self.x
  self.setZN(self.a)
}

// TXS - Transfer x to stack pointer
fn opTXS(self : CPU, addr : Int) -> Unit {
  self.sp = self.x
}

// TYA - Transfer y to accumulator
fn opTYA(self : CPU, addr : Int) -> Unit {
  self.a = self.y
  self.setZN(self.a)
}

//
// Illegal opcodes
//
// https://www.nesdev.org/wiki/CPU_unofficial_opcodes
// https://www.nesdev.org/wiki/Programming_with_unofficial_opcodes
//

fn opAHX(self : CPU, addr : Int) -> Unit {
  println("unimplemented: AHX")
  //abort("AHX")
}

fn opALR(self : CPU, addr : Int) -> Unit {
  println("unimplemented: ALR")
  //abort("ALR")
}

fn opANC(self : CPU, addr : Int) -> Unit {
  println("unimplemented: ANC")
  //abort("ANC")
}

fn opARR(self : CPU, addr : Int) -> Unit {
  println("unimplemented: ARR")
  //abort("ARR")
}

fn opAXS(self : CPU, addr : Int) -> Unit {
  println("unimplemented: AXS")
  //abort("AXS")
}

fn opDCP(self : CPU, addr : Int) -> Unit {
  // Equivalent to DEC value then CMP value, except supporting more addressing modes.
  // LDA #$FF followed by DCP can be used to check if the decrement underflows, which is useful for multi-byte decrements.
  self.opDEC(addr)
  self.opCMP(addr)
}

fn opISC(self : CPU, addr : Int) -> Unit {
  // Equivalent to INC value then SBC value, except supporting more addressing modes.
  self.opINC(addr)
  self.opSBC(addr)
}

fn opKIL(self : CPU, addr : Int) -> Unit {
  println("unimplemented: KIL")
  //abort("KIL")
}

fn opLAS(self : CPU, addr : Int) -> Unit {
  println("unimplemented: LAS")
  //abort("LAS")
}

fn opLAX(self : CPU, addr : Int) -> Unit {
  // Shortcut for LDA value then TAX. Saves a byte and two cycles and allows use of the X register with the (d),Y addressing mode.
  // Notice that the immediate is missing; the opcode that would have been LAX is affected by line noise on the data bus.
  // MOS 6502: even the bugs have bugs.
  self.opLDA(addr)
  self.opTAX(addr)
}

fn opRLA(self : CPU, addr : Int) -> Unit {
  // Equivalent to ROL value then AND value, except supporting more addressing modes.
  // LDA #$FF followed by RLA is an efficient way to rotate a variable while also loading it in A.
  self.opROL(addr)
  self.opAND(addr)
}

fn opRRA(self : CPU, addr : Int) -> Unit {
  // Equivalent to ROR value then ADC value, except supporting more addressing modes.
  // Essentially this computes A + value / 2, where value is 9-bit and the division is rounded up.
  self.opROR(addr)
  self.opADC(addr)
}

fn opSAX(self : CPU, addr : Int) -> Unit {
  // Stores the bitwise AND of A and X. As with STA and STX, no flags are affected.
  self.write(addr, self.a.land(self.x))
}

fn opSHX(self : CPU, addr : Int) -> Unit {
  println("unimplemented: SHX")
  //abort("SHX")
}

fn opSHY(self : CPU, addr : Int) -> Unit {
  println("unimplemented: SHY")
  //abort("SHY")
}

fn opSLO(self : CPU, addr : Int) -> Unit {
  // Equivalent to ASL value then ORA value, except supporting more addressing modes.
  // LDA #0 followed by SLO is an efficient way to shift a variable while also loading it in A.
  self.opASL(addr)
  self.opORA(addr)
}

fn opSRE(self : CPU, addr : Int) -> Unit {
  // Equivalent to LSR value then EOR value, except supporting more addressing modes.
  // LDA #0 followed by SRE is an efficient way to shift a variable while also loading it in A.
  self.opLSR(addr)
  self.opEOR(addr)
}

fn opTAS(self : CPU, addr : Int) -> Unit {
  println("unimplemented: TAS")
  //abort("TAS")
}

fn opXAA(self : CPU, addr : Int) -> Unit {
  println("unimplemented: XAA")
  //abort("XAA")
}

enum Mode {
  Absolute // 0
  AbsoluteX // 1
  AbsoluteY // 2
  Accumulator // 3
  Immediate // 4
  Implicit // 5
  IndexedIndirect // 6
  Indirect // 7
  IndirectIndexed // 8
  Relative // 9
  ZeroPage // 10
  ZeroPageX // 11
  ZeroPageY // 12
} derive(Eq)

let instructions : FixedArray[
  (String, (CPU, Int) -> Unit, Mode, UInt16, UInt16, UInt16),
] = [ // All 6502 instructions
  ("BRK", opBRK, Implicit, 1, 7, 0),
  ("ORA", opORA, IndexedIndirect, 2, 6, 0),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("SLO", opSLO, IndexedIndirect, 2, 8, 0),
  ("NOP", opNOP, ZeroPage, 2, 3, 0),
  ("ORA", opORA, ZeroPage, 2, 3, 0),
  ("ASL", opASL, ZeroPage, 2, 5, 0),
  ("SLO", opSLO, ZeroPage, 2, 5, 0),
  ("PHP", opPHP, Implicit, 1, 3, 0),
  ("ORA", opORA, Immediate, 2, 2, 0),
  ("ASL", opASL, Accumulator, 1, 2, 0),
  ("ANC", opANC, Immediate, 0, 2, 0),
  ("NOP", opNOP, Absolute, 3, 4, 0),
  ("ORA", opORA, Absolute, 3, 4, 0),
  ("ASL", opASL, Absolute, 3, 6, 0),
  ("SLO", opSLO, Absolute, 3, 6, 0),
  ("BPL", opBPL, Relative, 2, 2, 1),
  ("ORA", opORA, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("SLO", opSLO, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("ORA", opORA, ZeroPageX, 2, 4, 0),
  ("ASL", opASL, ZeroPageX, 2, 6, 0),
  ("SLO", opSLO, ZeroPageX, 2, 6, 0),
  ("CLC", opCLC, Implicit, 1, 2, 0),
  ("ORA", opORA, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("SLO", opSLO, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("ORA", opORA, AbsoluteX, 3, 4, 1),
  ("ASL", opASL, AbsoluteX, 3, 7, 0),
  ("SLO", opSLO, AbsoluteX, 3, 7, 0),
  ("JSR", opJSR, Absolute, 3, 6, 0),
  ("AND", opAND, IndexedIndirect, 2, 6, 0),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("RLA", opRLA, IndexedIndirect, 2, 8, 0),
  ("BIT", opBIT, ZeroPage, 2, 3, 0),
  ("AND", opAND, ZeroPage, 2, 3, 0),
  ("ROL", opROL, ZeroPage, 2, 5, 0),
  ("RLA", opRLA, ZeroPage, 2, 5, 0),
  ("PLP", opPLP, Implicit, 1, 4, 0),
  ("AND", opAND, Immediate, 2, 2, 0),
  ("ROL", opROL, Accumulator, 1, 2, 0),
  ("ANC", opANC, Immediate, 0, 2, 0),
  ("BIT", opBIT, Absolute, 3, 4, 0),
  ("AND", opAND, Absolute, 3, 4, 0),
  ("ROL", opROL, Absolute, 3, 6, 0),
  ("RLA", opRLA, Absolute, 3, 6, 0),
  ("BMI", opBMI, Relative, 2, 2, 1),
  ("AND", opAND, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("RLA", opRLA, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("AND", opAND, ZeroPageX, 2, 4, 0),
  ("ROL", opROL, ZeroPageX, 2, 6, 0),
  ("RLA", opRLA, ZeroPageX, 2, 6, 0),
  ("SEC", opSEC, Implicit, 1, 2, 0),
  ("AND", opAND, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("RLA", opRLA, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("AND", opAND, AbsoluteX, 3, 4, 1),
  ("ROL", opROL, AbsoluteX, 3, 7, 0),
  ("RLA", opRLA, AbsoluteX, 3, 7, 0),
  ("RTI", opRTI, Implicit, 1, 6, 0),
  ("EOR", opEOR, IndexedIndirect, 2, 6, 0),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("SRE", opSRE, IndexedIndirect, 2, 8, 0),
  ("NOP", opNOP, ZeroPage, 2, 3, 0),
  ("EOR", opEOR, ZeroPage, 2, 3, 0),
  ("LSR", opLSR, ZeroPage, 2, 5, 0),
  ("SRE", opSRE, ZeroPage, 2, 5, 0),
  ("PHA", opPHA, Implicit, 1, 3, 0),
  ("EOR", opEOR, Immediate, 2, 2, 0),
  ("LSR", opLSR, Accumulator, 1, 2, 0),
  ("ALR", opALR, Immediate, 0, 2, 0),
  ("JMP", opJMP, Absolute, 3, 3, 0),
  ("EOR", opEOR, Absolute, 3, 4, 0),
  ("LSR", opLSR, Absolute, 3, 6, 0),
  ("SRE", opSRE, Absolute, 3, 6, 0),
  ("BVC", opBVC, Relative, 2, 2, 1),
  ("EOR", opEOR, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("SRE", opSRE, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("EOR", opEOR, ZeroPageX, 2, 4, 0),
  ("LSR", opLSR, ZeroPageX, 2, 6, 0),
  ("SRE", opSRE, ZeroPageX, 2, 6, 0),
  ("CLI", opCLI, Implicit, 1, 2, 0),
  ("EOR", opEOR, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("SRE", opSRE, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("EOR", opEOR, AbsoluteX, 3, 4, 1),
  ("LSR", opLSR, AbsoluteX, 3, 7, 0),
  ("SRE", opSRE, AbsoluteX, 3, 7, 0),
  ("RTS", opRTS, Implicit, 1, 6, 0),
  ("ADC", opADC, IndexedIndirect, 2, 6, 0),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("RRA", opRRA, IndexedIndirect, 2, 8, 0),
  ("NOP", opNOP, ZeroPage, 2, 3, 0),
  ("ADC", opADC, ZeroPage, 2, 3, 0),
  ("ROR", opROR, ZeroPage, 2, 5, 0),
  ("RRA", opRRA, ZeroPage, 2, 5, 0),
  ("PLA", opPLA, Implicit, 1, 4, 0),
  ("ADC", opADC, Immediate, 2, 2, 0),
  ("ROR", opROR, Accumulator, 1, 2, 0),
  ("ARR", opARR, Immediate, 0, 2, 0),
  ("JMP", opJMP, Indirect, 3, 5, 0),
  ("ADC", opADC, Absolute, 3, 4, 0),
  ("ROR", opROR, Absolute, 3, 6, 0),
  ("RRA", opRRA, Absolute, 3, 6, 0),
  ("BVS", opBVS, Relative, 2, 2, 1),
  ("ADC", opADC, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("RRA", opRRA, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("ADC", opADC, ZeroPageX, 2, 4, 0),
  ("ROR", opROR, ZeroPageX, 2, 6, 0),
  ("RRA", opRRA, ZeroPageX, 2, 6, 0),
  ("SEI", opSEI, Implicit, 1, 2, 0),
  ("ADC", opADC, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("RRA", opRRA, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("ADC", opADC, AbsoluteX, 3, 4, 1),
  ("ROR", opROR, AbsoluteX, 3, 7, 0),
  ("RRA", opRRA, AbsoluteX, 3, 7, 0),
  ("NOP", opNOP, Immediate, 2, 2, 0),
  ("STA", opSTA, IndexedIndirect, 2, 6, 0),
  ("NOP", opNOP, Immediate, 0, 2, 0),
  ("SAX", opSAX, IndexedIndirect, 2, 6, 0),
  ("STY", opSTY, ZeroPage, 2, 3, 0),
  ("STA", opSTA, ZeroPage, 2, 3, 0),
  ("STX", opSTX, ZeroPage, 2, 3, 0),
  ("SAX", opSAX, ZeroPage, 2, 3, 0),
  ("DEY", opDEY, Implicit, 1, 2, 0),
  ("NOP", opNOP, Immediate, 0, 2, 0),
  ("TXA", opTXA, Implicit, 1, 2, 0),
  ("XAA", opXAA, Immediate, 0, 2, 0),
  ("STY", opSTY, Absolute, 3, 4, 0),
  ("STA", opSTA, Absolute, 3, 4, 0),
  ("STX", opSTX, Absolute, 3, 4, 0),
  ("SAX", opSAX, Absolute, 3, 4, 0),
  ("BCC", opBCC, Relative, 2, 2, 1),
  ("STA", opSTA, IndirectIndexed, 2, 6, 0),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("AHX", opAHX, IndirectIndexed, 0, 6, 0),
  ("STY", opSTY, ZeroPageX, 2, 4, 0),
  ("STA", opSTA, ZeroPageX, 2, 4, 0),
  ("STX", opSTX, ZeroPageY, 2, 4, 0),
  ("SAX", opSAX, ZeroPageY, 2, 4, 0),
  ("TYA", opTYA, Implicit, 1, 2, 0),
  ("STA", opSTA, AbsoluteY, 3, 5, 0),
  ("TXS", opTXS, Implicit, 1, 2, 0),
  ("TAS", opTAS, AbsoluteY, 0, 5, 0),
  ("SHY", opSHY, AbsoluteX, 0, 5, 0),
  ("STA", opSTA, AbsoluteX, 3, 5, 0),
  ("SHX", opSHX, AbsoluteY, 0, 5, 0),
  ("AHX", opAHX, AbsoluteY, 0, 5, 0),
  ("LDY", opLDY, Immediate, 2, 2, 0),
  ("LDA", opLDA, IndexedIndirect, 2, 6, 0),
  ("LDX", opLDX, Immediate, 2, 2, 0),
  ("LAX", opLAX, IndexedIndirect, 2, 6, 0),
  ("LDY", opLDY, ZeroPage, 2, 3, 0),
  ("LDA", opLDA, ZeroPage, 2, 3, 0),
  ("LDX", opLDX, ZeroPage, 2, 3, 0),
  ("LAX", opLAX, ZeroPage, 2, 3, 0),
  ("TAY", opTAY, Implicit, 1, 2, 0),
  ("LDA", opLDA, Immediate, 2, 2, 0),
  ("TAX", opTAX, Implicit, 1, 2, 0),
  ("LAX", opLAX, Immediate, 0, 2, 0),
  ("LDY", opLDY, Absolute, 3, 4, 0),
  ("LDA", opLDA, Absolute, 3, 4, 0),
  ("LDX", opLDX, Absolute, 3, 4, 0),
  ("LAX", opLAX, Absolute, 3, 4, 0),
  ("BCS", opBCS, Relative, 2, 2, 1),
  ("LDA", opLDA, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("LAX", opLAX, IndirectIndexed, 2, 5, 1),
  ("LDY", opLDY, ZeroPageX, 2, 4, 0),
  ("LDA", opLDA, ZeroPageX, 2, 4, 0),
  ("LDX", opLDX, ZeroPageY, 2, 4, 0),
  ("LAX", opLAX, ZeroPageY, 2, 4, 0),
  ("CLV", opCLV, Implicit, 1, 2, 0),
  ("LDA", opLDA, AbsoluteY, 3, 4, 1),
  ("TSX", opTSX, Implicit, 1, 2, 0),
  ("LAS", opLAS, AbsoluteY, 0, 4, 1),
  ("LDY", opLDY, AbsoluteX, 3, 4, 1),
  ("LDA", opLDA, AbsoluteX, 3, 4, 1),
  ("LDX", opLDX, AbsoluteY, 3, 4, 1),
  ("LAX", opLAX, AbsoluteY, 3, 4, 1),
  ("CPY", opCPY, Immediate, 2, 2, 0),
  ("CMP", opCMP, IndexedIndirect, 2, 6, 0),
  ("NOP", opNOP, Immediate, 0, 2, 0),
  ("DCP", opDCP, IndexedIndirect, 2, 8, 0),
  ("CPY", opCPY, ZeroPage, 2, 3, 0),
  ("CMP", opCMP, ZeroPage, 2, 3, 0),
  ("DEC", opDEC, ZeroPage, 2, 5, 0),
  ("DCP", opDCP, ZeroPage, 2, 5, 0),
  ("INY", opINY, Implicit, 1, 2, 0),
  ("CMP", opCMP, Immediate, 2, 2, 0),
  ("DEX", opDEX, Implicit, 1, 2, 0),
  ("AXS", opAXS, Immediate, 0, 2, 0),
  ("CPY", opCPY, Absolute, 3, 4, 0),
  ("CMP", opCMP, Absolute, 3, 4, 0),
  ("DEC", opDEC, Absolute, 3, 6, 0),
  ("DCP", opDCP, Absolute, 3, 6, 0),
  ("BNE", opBNE, Relative, 2, 2, 1),
  ("CMP", opCMP, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("DCP", opDCP, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("CMP", opCMP, ZeroPageX, 2, 4, 0),
  ("DEC", opDEC, ZeroPageX, 2, 6, 0),
  ("DCP", opDCP, ZeroPageX, 2, 6, 0),
  ("CLD", opCLD, Implicit, 1, 2, 0),
  ("CMP", opCMP, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("DCP", opDCP, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("CMP", opCMP, AbsoluteX, 3, 4, 1),
  ("DEC", opDEC, AbsoluteX, 3, 7, 0),
  ("DCP", opDCP, AbsoluteX, 3, 7, 0),
  ("CPX", opCPX, Immediate, 2, 2, 0),
  ("SBC", opSBC, IndexedIndirect, 2, 6, 0),
  ("NOP", opNOP, Immediate, 0, 2, 0),
  ("ISC", opISC, IndexedIndirect, 2, 8, 0),
  ("CPX", opCPX, ZeroPage, 2, 3, 0),
  ("SBC", opSBC, ZeroPage, 2, 3, 0),
  ("INC", opINC, ZeroPage, 2, 5, 0),
  ("ISC", opISC, ZeroPage, 2, 5, 0),
  ("INX", opINX, Implicit, 1, 2, 0),
  ("SBC", opSBC, Immediate, 2, 2, 0),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("SBC", opSBC, Immediate, 2, 2, 0),
  ("CPX", opCPX, Absolute, 3, 4, 0),
  ("SBC", opSBC, Absolute, 3, 4, 0),
  ("INC", opINC, Absolute, 3, 6, 0),
  ("ISC", opISC, Absolute, 3, 6, 0),
  ("BEQ", opBEQ, Relative, 2, 2, 1),
  ("SBC", opSBC, IndirectIndexed, 2, 5, 1),
  ("KIL", opKIL, Implicit, 0, 2, 0),
  ("ISC", opISC, IndirectIndexed, 2, 8, 0),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0),
  ("SBC", opSBC, ZeroPageX, 2, 4, 0),
  ("INC", opINC, ZeroPageX, 2, 6, 0),
  ("ISC", opISC, ZeroPageX, 2, 6, 0),
  ("SED", opSED, Implicit, 1, 2, 0),
  ("SBC", opSBC, AbsoluteY, 3, 4, 1),
  ("NOP", opNOP, Implicit, 1, 2, 0),
  ("ISC", opISC, AbsoluteY, 3, 7, 0),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1),
  ("SBC", opSBC, AbsoluteX, 3, 4, 1),
  ("INC", opINC, AbsoluteX, 3, 7, 0),
  ("ISC", opISC, AbsoluteX, 3, 7, 0),
]

enum Instruction {
  // LDA
  INS_LDA_IM // 0xA9
  INS_LDA_ZP // 0xA5
  INS_LDA_ZPX // 0xB5
  INS_LDA_ABS // 0xAD
  INS_LDA_ABSX // 0xBD
  INS_LDA_ABSY // 0xB9
  INS_LDA_INDX // 0xA1
  INS_LDA_INDY // 0xB1

  // LDX
  INS_LDX_IM // 0xA2
  INS_LDX_ZP // 0xA6
  INS_LDX_ZPY // 0xB6
  INS_LDX_ABS // 0xAE
  INS_LDX_ABSY // 0xBE

  // LDY
  INS_LDY_IM // 0xA0
  INS_LDY_ZP // 0xA4
  INS_LDY_ZPX // 0xB4
  INS_LDY_ABS // 0xAC
  INS_LDY_ABSX // 0xBC

  // STA
  INS_STA_ZP // 0x85
  INS_STA_ZPX // 0x95
  INS_STA_ABS // 0x8D
  INS_STA_ABSX // 0x9D
  INS_STA_ABSY // 0x99
  INS_STA_INDX // 0x81
  INS_STA_INDY // 0x91

  // STX
  INS_STX_ZP // 0x86
  INS_STX_ZPY // 0x96
  INS_STX_ABS // 0x8E

  // STY
  INS_STY_ZP // 0x84
  INS_STY_ZPX // 0x94
  INS_STY_ABS // 0x8C
  INS_TSX // 0xBA
  INS_TXS // 0x9A
  INS_PHA // 0x48
  INS_PLA // 0x68
  INS_PHP // 0x08
  INS_PLP // 0x28
  INS_JMP_ABS // 0x4C
  INS_JMP_IND // 0x6C
  INS_JSR // 0x20
  INS_RTS // 0x60

  //
  // Logical Operations
  //

  // AND
  INS_AND_IM // 0x29
  INS_AND_ZP // 0x25
  INS_AND_ZPX // 0x35
  INS_AND_ABS // 0x2D
  INS_AND_ABSX // 0x3D
  INS_AND_ABSY // 0x39
  INS_AND_INDX // 0x21
  INS_AND_INDY // 0x31

  // OR
  INS_ORA_IM // 0x09
  INS_ORA_ZP // 0x05
  INS_ORA_ZPX // 0x15
  INS_ORA_ABS // 0x0D
  INS_ORA_ABSX // 0x1D
  INS_ORA_ABSY // 0x19
  INS_ORA_INDX // 0x01
  INS_ORA_INDY // 0x11

  // EOR
  INS_EOR_IM // 0x49
  INS_EOR_ZP // 0x45
  INS_EOR_ZPX // 0x55
  INS_EOR_ABS // 0x4D
  INS_EOR_ABSX // 0x5D
  INS_EOR_ABSY // 0x59
  INS_EOR_INDX // 0x41
  INS_EOR_INDY // 0x51

  // BIT
  INS_BIT_ZP // 0x24
  INS_BIT_ABS // 0x2C

  //
  // Transfer Registers
  //
  INS_TAX // 0xAA
  INS_TAY // 0xA8
  INS_TXA // 0x8A
  INS_TYA // 0x98

  //
  // Increments
  // Decrements
  //
  INS_INX // 0xE8
  INS_INY // 0xC8
  INS_DEY // 0x88
  INS_DEX // 0xCA
  INS_DEC_ZP // 0xC6
  INS_DEC_ZPX // 0xD6
  INS_DEC_ABS // 0xCE
  INS_DEC_ABSX // 0xDE
  INS_INC_ZP // 0xE6
  INS_INC_ZPX // 0xF6
  INS_INC_ABS // 0xEE
  INS_INC_ABSX // 0xFE

  // Branches
  INS_BEQ // 0xF0
  INS_BNE // 0xD0
  INS_BCS // 0xB0
  INS_BCC // 0x90
  INS_BMI // 0x30
  INS_BPL // 0x10
  INS_BVC // 0x50
  INS_BVS // 0x70

  // Status Flag Changes
  INS_CLC // 0x18
  INS_SEC // 0x38
  INS_CLD // 0xD8
  INS_SED // 0xF8
  INS_CLI // 0x58
  INS_SEI // 0x78
  INS_CLV // 0xB8

  // Arithmetics
  INS_ADC // 0x69
  INS_ADC_ZP // 0x65
  INS_ADC_ZPX // 0x75
  INS_ADC_ABS // 0x6D
  INS_ADC_ABSX // 0x7D
  INS_ADC_ABSY // 0x79
  INS_ADC_INDX // 0x61
  INS_ADC_INDY // 0x71
  INS_SBC // 0xE9
  INS_SBC_ABS // 0xED
  INS_SBC_ZP // 0xE5
  INS_SBC_ZPX // 0xF5
  INS_SBC_ABSX // 0xFD
  INS_SBC_ABSY // 0xF9
  INS_SBC_INDX // 0xE1
  INS_SBC_INDY // 0xF1

  // Comparisons
  INS_CMP // 0xC9
  INS_CMP_ZP // 0xC5
  INS_CMP_ZPX // 0xD5
  INS_CMP_ABS // 0xCD
  INS_CMP_ABSX // 0xDD
  INS_CMP_ABSY // 0xD9
  INS_CMP_INDX // 0xC1
  INS_CMP_INDY // 0xD1
  INS_CPX // 0xE0
  INS_CPY // 0xC0
  INS_CPX_ZP // 0xE4
  INS_CPY_ZP // 0xC4
  INS_CPX_ABS // 0xEC
  INS_CPY_ABS // 0xCC

  // Shifts
  INS_ASL // 0x0A
  INS_ASL_ZP // 0x06
  INS_ASL_ZPX // 0x16
  INS_ASL_ABS // 0x0E
  INS_ASL_ABSX // 0x1E
  INS_LSR // 0x4A
  INS_LSR_ZP // 0x46
  INS_LSR_ZPX // 0x56
  INS_LSR_ABS // 0x4E
  INS_LSR_ABSX // 0x5E
  INS_ROL // 0x2A
  INS_ROL_ZP // 0x26
  INS_ROL_ZPX // 0x36
  INS_ROL_ABS // 0x2E
  INS_ROL_ABSX // 0x3E
  INS_ROR // 0x6A
  INS_ROR_ZP // 0x66
  INS_ROR_ZPX // 0x76
  INS_ROR_ABS // 0x6E
  INS_ROR_ABSX // 0x7E

  // Miscellaneous
  INS_NOP // 0xEA
  INS_BRK // 0x00
  INS_RTI // 0x40
}

fn get_opcode(instruction : Instruction) -> UInt8 {
  match instruction {
    // LDA
    INS_LDA_IM => 0xA9
    INS_LDA_ZP => 0xA5
    INS_LDA_ZPX => 0xB5
    INS_LDA_ABS => 0xAD
    INS_LDA_ABSX => 0xBD
    INS_LDA_ABSY => 0xB9
    INS_LDA_INDX => 0xA1
    INS_LDA_INDY => 0xB1

    // LDX
    INS_LDX_IM => 0xA2
    INS_LDX_ZP => 0xA6
    INS_LDX_ZPY => 0xB6
    INS_LDX_ABS => 0xAE
    INS_LDX_ABSY => 0xBE

    // LDY
    INS_LDY_IM => 0xA0
    INS_LDY_ZP => 0xA4
    INS_LDY_ZPX => 0xB4
    INS_LDY_ABS => 0xAC
    INS_LDY_ABSX => 0xBC

    // STA
    INS_STA_ZP => 0x85
    INS_STA_ZPX => 0x95
    INS_STA_ABS => 0x8D
    INS_STA_ABSX => 0x9D
    INS_STA_ABSY => 0x99
    INS_STA_INDX => 0x81
    INS_STA_INDY => 0x91

    // STX
    INS_STX_ZP => 0x86
    INS_STX_ZPY => 0x96
    INS_STX_ABS => 0x8E

    // STY
    INS_STY_ZP => 0x84
    INS_STY_ZPX => 0x94
    INS_STY_ABS => 0x8C
    INS_TSX => 0xBA
    INS_TXS => 0x9A
    INS_PHA => 0x48
    INS_PLA => 0x68
    INS_PHP => 0x08
    INS_PLP => 0x28
    INS_JMP_ABS => 0x4C
    INS_JMP_IND => 0x6C
    INS_JSR => 0x20
    INS_RTS => 0x60

    //
    // Logical Operations
    //

    // AND
    INS_AND_IM => 0x29
    INS_AND_ZP => 0x25
    INS_AND_ZPX => 0x35
    INS_AND_ABS => 0x2D
    INS_AND_ABSX => 0x3D
    INS_AND_ABSY => 0x39
    INS_AND_INDX => 0x21
    INS_AND_INDY => 0x31

    // OR
    INS_ORA_IM => 0x09
    INS_ORA_ZP => 0x05
    INS_ORA_ZPX => 0x15
    INS_ORA_ABS => 0x0D
    INS_ORA_ABSX => 0x1D
    INS_ORA_ABSY => 0x19
    INS_ORA_INDX => 0x01
    INS_ORA_INDY => 0x11

    // EOR
    INS_EOR_IM => 0x49
    INS_EOR_ZP => 0x45
    INS_EOR_ZPX => 0x55
    INS_EOR_ABS => 0x4D
    INS_EOR_ABSX => 0x5D
    INS_EOR_ABSY => 0x59
    INS_EOR_INDX => 0x41
    INS_EOR_INDY => 0x51

    // BIT
    INS_BIT_ZP => 0x24
    INS_BIT_ABS => 0x2C

    //
    // Transfer Registers
    //
    INS_TAX => 0xAA
    INS_TAY => 0xA8
    INS_TXA => 0x8A
    INS_TYA => 0x98

    //
    // Increments
    // Decrements
    //
    INS_INX => 0xE8
    INS_INY => 0xC8
    INS_DEY => 0x88
    INS_DEX => 0xCA
    INS_DEC_ZP => 0xC6
    INS_DEC_ZPX => 0xD6
    INS_DEC_ABS => 0xCE
    INS_DEC_ABSX => 0xDE
    INS_INC_ZP => 0xE6
    INS_INC_ZPX => 0xF6
    INS_INC_ABS => 0xEE
    INS_INC_ABSX => 0xFE

    // Branches
    INS_BEQ => 0xF0
    INS_BNE => 0xD0
    INS_BCS => 0xB0
    INS_BCC => 0x90
    INS_BMI => 0x30
    INS_BPL => 0x10
    INS_BVC => 0x50
    INS_BVS => 0x70

    // Status Flag Changes
    INS_CLC => 0x18
    INS_SEC => 0x38
    INS_CLD => 0xD8
    INS_SED => 0xF8
    INS_CLI => 0x58
    INS_SEI => 0x78
    INS_CLV => 0xB8

    // Arithmetics
    INS_ADC => 0x69
    INS_ADC_ZP => 0x65
    INS_ADC_ZPX => 0x75
    INS_ADC_ABS => 0x6D
    INS_ADC_ABSX => 0x7D
    INS_ADC_ABSY => 0x79
    INS_ADC_INDX => 0x61
    INS_ADC_INDY => 0x71
    INS_SBC => 0xE9
    INS_SBC_ABS => 0xED
    INS_SBC_ZP => 0xE5
    INS_SBC_ZPX => 0xF5
    INS_SBC_ABSX => 0xFD
    INS_SBC_ABSY => 0xF9
    INS_SBC_INDX => 0xE1
    INS_SBC_INDY => 0xF1

    // Comparisons
    INS_CMP => 0xC9
    INS_CMP_ZP => 0xC5
    INS_CMP_ZPX => 0xD5
    INS_CMP_ABS => 0xCD
    INS_CMP_ABSX => 0xDD
    INS_CMP_ABSY => 0xD9
    INS_CMP_INDX => 0xC1
    INS_CMP_INDY => 0xD1
    INS_CPX => 0xE0
    INS_CPY => 0xC0
    INS_CPX_ZP => 0xE4
    INS_CPY_ZP => 0xC4
    INS_CPX_ABS => 0xEC
    INS_CPY_ABS => 0xCC

    // Shifts
    INS_ASL => 0x0A
    INS_ASL_ZP => 0x06
    INS_ASL_ZPX => 0x16
    INS_ASL_ABS => 0x0E
    INS_ASL_ABSX => 0x1E
    INS_LSR => 0x4A
    INS_LSR_ZP => 0x46
    INS_LSR_ZPX => 0x56
    INS_LSR_ABS => 0x4E
    INS_LSR_ABSX => 0x5E
    INS_ROL => 0x2A
    INS_ROL_ZP => 0x26
    INS_ROL_ZPX => 0x36
    INS_ROL_ABS => 0x2E
    INS_ROL_ABSX => 0x3E
    INS_ROR => 0x6A
    INS_ROR_ZP => 0x66
    INS_ROR_ZPX => 0x76
    INS_ROR_ABS => 0x6E
    INS_ROR_ABSX => 0x7E

    // Miscellaneous
    INS_NOP => 0xEA
    INS_BRK => 0x00
    INS_RTI => 0x40
  }
}
