struct CPU {
  mem : Memory
  mut cycles : UInt16
  mut pc : UInt16 // Program Counter
  // Registers
  mut registers : Registers
  // Flags
  mut flags : Flags
}

pub fn CPU::new(
  ~pc : Int = 0x0000,
  ~data : Array[Int] = [],
  ~offset : Int = 0,
  ~length : Int = data.length()
) -> CPU {
  let mem = Memory::new()
  let registers = Registers::new()
  let flags = Flags::new(flags=0x24)
  let cpu : CPU = { mem, cycles: 0, pc, registers, flags }
  if data.length() > 0 {
    cpu.load(data, ~offset, ~length)
  }
  cpu
}

pub fn mem(self : CPU) -> Memory {
  self.mem
}

pub fn pc(self : CPU) -> Int {
  self.pc.0
}

// Load a program into memory
pub fn load(
  self : CPU,
  data : Array[Int],
  ~offset : Int = 0,
  ~length : Int = data.length()
) -> Unit {
  // println(
  //   "CPU::load $" + UInt16(offset).to_hex() + " - $" + UInt16(length).to_hex(),
  // )
  for i = 0; i < length; i = i + 1 {
    self.mem[i + offset] = data[i]
    // if i == 0x1000 {
    //   break
    // }
    // println("$" + UInt16(i + offset).to_hex() + " < " + UInt8(data[i]).to_hex())
  }
}

pub fn read(self : CPU, addr : Int, ~log : Bool = true) -> Int {
  // if log {
  //   println("$" + u16(addr).to_hex() + " → " + self.mem[addr].to_hex())
  // }
  self.mem[addr].0
}

fn read16(self : CPU, addr : Int, ~log : Bool = true) -> UInt16 {
  // if log {
  //   println(
  //     "$" + u16(addr).to_hex() + " → " + self.mem[addr + 1].to_hex() + self.mem[addr].to_hex(),
  //   )
  // }
  u16(self.read(addr + 1, log=false)).lsl(8).lor(self.read(addr, log=false))
}

fn read16zp(self : CPU, addr : Int) -> UInt16 {
  // println(
  //   "read16zp $" + UInt16(addr).to_hex() + " [" + UInt8(self.read(addr)).to_hex() +
  //   "] $" + UInt16((addr + 1).land(0x00FF).lor(addr.land(0xFF00))).to_hex() + " [" +
  //   UInt8(self.read((addr + 1).land(0x00FF).lor(addr.land(0xFF00)))).to_hex() + "]",
  // )
  u16(self.read((addr + 1).land(0x00FF).lor(addr.land(0xFF00)), log=false)).lsl(
    8,
  ).lor(self.read(addr.land(0x00FF).lor(addr.land(0xFF00)), log=false))
}

pub fn write(self : CPU, addr : Int, value : UInt8, ~log : Bool = true) -> Unit {
  self.mem[addr] = value
  // if log {
  //   println("$" + u16(addr).to_hex() + " ← " + self.mem[addr].to_hex())
  // }
}

// fn push(self : CPU, value : UInt8) -> Unit {
//   self.write(0x0100 + self.registers[SP].0, value)
//   self.registers[SP] = self.registers[SP] - 1
// }

pub fn push(self : CPU, value : UInt8) -> Unit {
  self.write(self.registers[SP].lor(0x0100), value)
  self.registers[SP] = self.registers[SP] - 1
}

pub fn push16(self : CPU, value : UInt16) -> Unit {
  self.push(u8(value.lsr(8)))
  self.push(u8(value))
}

// fn pop(self : CPU) -> UInt8 {
//   self.registers[SP] = self.registers[SP] + 1
//   println("SP: $" + UInt16(self.registers[SP]).to_hex())
//   self.read(0x0100 + self.registers[SP])
// }

fn pop(self : CPU) -> UInt8 {
  self.registers[SP] = self.registers[SP] + 1
  self.read(self.registers[SP].lor(0x0100))
}

fn pop16(self : CPU) -> UInt16 {
  u16(self.pop()).lor(u16(self.pop()).lsl(8).0)
}

pub fn step(self : CPU) -> Int {
  let cycles = self.cycles
  let opcode = self.read(self.pc + 0)
  //
  let ins = instructions[opcode]
  let (name, _, mode, _size, _cycles, pagecycles, illegal) = ins
  //
  let addr = self.get_addr(mode)
  let read8 = fn() { "$" + self.mem[self.pc + 1].to_hex() }
  let read16 = fn() {
    "$" + self.mem[self.pc + 1 + 1].to_hex() + self.mem[self.pc + 1].to_hex()
  }
  let unofficial = if illegal { "*" } else { " " }
  let addr_mode = match mode {
    Implied =>
      // Implied Addressing
      // https://www.c64-wiki.com/wiki/Implied_addressing
      //
      // Does not require the specification of any additional information.
      // BRK, CLC, CLD, CLI, CLV, DEX, DEY, INX, INY, NOP, PHA, PHP, PLA, PLP, RTI, RTS, SEC, SED, SEI, TAX, TAY, TSX, TXA, TXS, and TYA.
      ""
    Accumulator =>
      // Accumulator Addressing
      // https://www.c64-wiki.com/wiki/Accumulator_addressing
      //
      // The input for the shift operation is picked up from the CPU's accumulator, and the output is stored back into the accumulator.
      // ASL, LSR, ROL, and ROR.
      " A"
    Immediate =>
      // Immediate Addressing
      // https://www.c64-wiki.com/wiki/Immediate_addressing
      //
      // The byte value to be used or retrieved in the instruction, located immediately after the opcode for the instruction itself.
      // ADC, AND, CMP, CPX, CPY, EOR, LDA, LDX, LDY, ORA, and SBC.
      " #" + read8()
    Indirect =>
      // Absolute-Indirect Addressing
      // https://www.c64-wiki.com/wiki/Absolute-indirect_addressing
      //
      // The given address is a vector to the effective address.
      // JMP
      " (" + read16() + ")" + " = " + self.read16zp(self.read16(self.pc + 1).0).to_hex()
    IndexedIndirect =>
      // Indexed-Indirect Addressing
      // https://www.c64-wiki.com/wiki/Indexed-indirect_addressing
      //
      // The X index register is used to offset the zero page vector used to determine the effective address.
      // ADC, AND, CMP, EOR, LDA, ORA, SBC, STA.
      " (" + read8() + ",X) @ " + (self.mem[self.pc + 1] + self.registers[X]).land(
        0xFF,
      ).to_hex() + " = " + self.read16zp(
        (self.mem[self.pc + 1].0 + self.registers[X]).land(0xFF),
      ).to_hex() + " = " + self.mem[self.read16zp(
        (self.mem[self.pc + 1].0 + self.registers[X]).land(0xFF),
      ).0].to_hex()
    IndirectIndexed =>
      // Indirect-Indexed Addressing
      // https://www.c64-wiki.com/wiki/Indirect-indexed_addressing
      //
      // The Y Index Register is used as an offset from the given zero page vector.
      // The effective address is calculated as the vector plus the value in Y.
      // ADC, AND, CMP, EOR, LDA, ORA, SBC, and STA.
      " (" + read8() + "),Y = " + self.read16zp(self.mem[self.pc + 1].0).to_hex() +
      " @ " + UInt16(self.read16zp(self.mem[self.pc + 1].0) + self.registers[Y]).to_hex() +
      " = " + self.mem[self.read16zp(self.mem[self.pc + 1].0) + self.registers[Y]].to_hex()
    Absolute =>
      // Absolute Addressing
      // https://www.c64-wiki.com/wiki/Absolute_addressing
      //
      // Specifies an address in memory which is to be the "object" of the instruction.
      // ADC, AND, ASL, BIT, CMP, CPX, CPY, DEC, EOR, INC, JMP, JSR, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, and STY.
      " " + read16() + match name {
        "JMP" | "JSR" => ""
        _ => " = " + self.mem[self.read16(self.pc + 1).0].to_hex()
      }
    AbsoluteX =>
      // Indexed Absolute Addressing
      // https://www.c64-wiki.com/wiki/Indexed_absolute_addressing
      //
      // The contents of the X index register is added to a given base address.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA.
      " " + read16() + ",X @ " + UInt16(
        self.read16(self.pc + 1) + self.registers[X],
      ).to_hex() + " = " + self.mem[self.read16(self.pc + 1) + self.registers[X]].to_hex()
    AbsoluteY =>
      // Indexed Absolute Addressing
      // https://www.c64-wiki.com/wiki/Indexed_absolute_addressing
      //
      // The contents of the Y index register is added to a given base address.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA.
      " " + read16() + ",Y @ " + UInt16(
        self.read16(self.pc + 1) + self.registers[Y],
      ).to_hex() + " = " + self.mem[self.read16(self.pc + 1) + self.registers[Y]].to_hex()
    ZeroPage =>
      // Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Zeropage_addressing
      //
      // Specifies an address in zero-page which is to be the "object" of the instruction.
      // ADC, AND, ASL, BIT, CMP, CPX, CPY, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, and STY.
      " " + read8() + " = " + self.mem[self.mem[self.pc + 1].0].to_hex()
    ZeroPageX =>
      // Indexed Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Indexed_zeropage_addressing
      //
      // The contents of the X index register is added to a given base address in zero-page.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, STY.
      " " + read8() + ",X @ " + UInt8(
        (self.read(self.pc + 1) + self.registers[X]).land(0xFF),
      ).to_hex() + " = " + self.mem[(self.read(self.pc + 1) + self.registers[X]).land(
        0xFF,
      )].to_hex()
    ZeroPageY =>
      // Indexed Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Indexed_zeropage_addressing
      //
      // The contents of the Y index register is added to a given base address in zero-page.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, STY.
      " " + read8() + ",Y @ " + UInt8(
        (self.read(self.pc + 1) + self.registers[Y]).land(0xFF),
      ).to_hex() + " = " + self.mem[(self.read(self.pc + 1) + self.registers[Y]).land(
        0xFF,
      )].to_hex()
    Relative =>
      // Relative Addressing
      // https://www.c64-wiki.com/wiki/Relative_addressing
      //
      // A single, signed-integer byte that specifies, in relative terms, how far "up" or "down" to jump if the required conditions are met.
      // This signed 8-bit figure is called the offset.
      // BCC, BCS, BEQ, BMI, BNE, BPL, BVC, and BVS.
      " $" + UInt16(self.pc + 2 + self.mem[self.pc + 1].to_signed()).to_hex()
  }
  let mut instr = ""
  let mut i = 0
  while i < 3 {
    instr += " " + if i < _size.0 {
        UInt8(self.read(self.pc + i)).to_hex()
      } else {
        "  "
      }
    i = i + 1
  }
  let mut spaces = ""
  let mut i = 32 - name.length() - addr_mode.length()
  while i > 0 {
    spaces = spaces + " "
    i = i - 1
  }
  // let mut stack = ""
  // let mut i = 0x01FF
  // while i > 0x01F8 {
  //   if self.registers[SP] + 0x0100 == i {
  //     stack += "➛"
  //   }
  //   stack += self.mem[i].to_hex()
  //   i = i - 1
  // }
  println(
    self.pc.to_hex() + " " + instr + " " + unofficial + if opcode == 0xE3 || opcode ==
    0xE7 || opcode == 0xEF || opcode == 0xF3 || opcode == 0xF7 || opcode == 0xFB ||
    opcode == 0xFF {
      "ISB"
    } else {
      name
    } + addr_mode + spaces + "A:" + UInt8(self.registers[A]).to_hex() + " X:" + UInt8(
      self.registers[X],
    ).to_hex() + " Y:" + UInt8(self.registers[Y]).to_hex() + " P:" + self.flags.get_flags().to_hex() +
    " SP:" + UInt8(self.registers[SP]).to_hex(), // + " PPU:  _,  _" + " CYC:" + (self.cycles + _cycles).to_string(),
  )
  self.pc = self.pc + _size
  self.cycles = self.cycles + _cycles
  //
  (ins.1)(self, addr.0, mode)
  //
  self.cycles - cycles
}

fn get_addr(self : CPU, mode : Mode) -> UInt16 {
  match mode {
    Absolute => self.read16(self.pc + 1)
    AbsoluteX => self.read16(self.pc + 1) + self.registers[X]
    AbsoluteY => self.read16(self.pc + 1) + self.registers[Y]
    IndexedIndirect =>
      self.read16zp((self.read(self.pc + 1) + self.registers[X]).land(0xFF))
    Indirect => self.read16zp(self.read16(self.pc + 1).0)
    IndirectIndexed => self.read16zp(self.read(self.pc + 1)) + self.registers[Y]
    ZeroPage => self.read(self.pc + 1).land(0xFF)
    ZeroPageX => (self.read(self.pc + 1) + self.registers[X]).land(0xFF)
    ZeroPageY => (self.read(self.pc + 1) + self.registers[Y]).land(0xFF)
    Immediate => self.pc + 1
    Accumulator | Implied => 0
    Relative => self.pc + 2 + UInt8(self.read(self.pc + 1)).to_signed()
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
  self.flags.setZN(a - b)
  self.flags[C] = a >= b
}

//
// Instructions
//

// ADC - Add with carry
fn opADC(self : CPU, addr : Int, mode : Mode) -> Unit {
  let a = self.registers[A]
  let b = self.read(addr)
  let c = self.flags[C].to_int()
  self.registers[A] = a + b + c // capped at 0xff
  self.flags.setZN(self.registers[A])
  self.flags[C] = a + b + c > 0xff // not capped at 0xff
  // (a^b)&0x80 == 0 && (a^self.a)&0x80 != 0
  self.flags[V] = a.lxor(b).land(0x80) == 0 && a.lxor(self.registers[A]).land(
      0x80,
    ) != 0
}

// AND - Logical and
// ** opcode name changed
fn opAND(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.registers[A].land(self.read(addr)) // self.a & self.mem[info.address]
  self.flags.setZN(self.registers[A])
}

// ASL - Arithmetic Shift Left
// https://www.c64-wiki.com/wiki/ASL
//
// Status Flags
// The `Negative` status flag is set if the result is negative, i.e. has its most significant bit set.
// The `Zero` flag is set if the result is zero, or cleared if it is non-zero.
// The `Carry` flag is set or cleared depending on the result.
fn opASL(self : CPU, addr : Int, mode : Mode) -> Unit {
  match mode {
    Accumulator => {
      self.flags[C] = self.registers[A].lsr(7).land(1) != 0 // (self.registers[A] >> 7) & 1
      self.registers[A] = self.registers[A].lsl(1)
      self.flags.setZN(self.registers[A])
    }
    _ => {
      let mut value = self.read(addr)
      self.flags[C] = value.lsr(7).land(1) != 0 // (val >> 7) & 1
      value = value.lsl(1)
      self.write(addr, value)
      self.flags.setZN(value)
    }
  }
}

// BCC - Branch if carry clear
fn opBCC(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_clear(C) {
    self.branch(addr)
  }
}

// BCS - Branch if carry set
fn opBCS(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_set(C) {
    self.branch(addr)
  }
}

// BEQ - Branch if equal
fn opBEQ(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_set(Z) {
    self.branch(addr)
  }
}

// BIT - Bit test
fn opBIT(self : CPU, addr : Int, mode : Mode) -> Unit {
  let value = self.read(addr) // :- same as go!
  self.flags[V] = value.lsr(6).land(1) != 0 // (val >> 6) & 1
  self.flags.setZ(value.land(self.registers[A])) // val & self.A
  self.flags.setN(value)
}

// BMI - Branch if minus
fn opBMI(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_set(N) {
    self.branch(addr)
  }
}

// BNE - Branch if minus
fn opBNE(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_clear(Z) {
    self.branch(addr)
  }
}

// BPL - Branch if positive
fn opBPL(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_clear(N) {
    self.branch(addr)
  }
}

// BRK - Force interrupt
fn opBRK(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.push16(self.pc)
  self.opPHP(addr, mode)
  self.opSEI(addr, mode)
  self.pc = self.read16(0xFFFE)
}

// BVC - Branch if overflow clear
fn opBVC(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_clear(V) {
    self.branch(addr)
  }
}

// BVS - Branch if overflow set
fn opBVS(self : CPU, addr : Int, mode : Mode) -> Unit {
  if self.flags.is_set(V) {
    self.branch(addr)
  }
}

// CLC - Clear carry flag
fn opCLC(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.clear(C)
}

// CLD - Clear decimal mode
fn opCLD(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.clear(D)
}

// CLI - Clear interrupt disable
fn opCLI(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.clear(I)
}

// CLV - Clear overflow flag
fn opCLV(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.clear(V)
}

// CMP - Compare
fn opCMP(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.compare(self.registers[A], self.read(addr))
}

// CPX - Compare x register
fn opCPX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.compare(self.registers[X], self.read(addr))
}

// CPY - Compare y register
fn opCPY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.compare(self.registers[Y], self.read(addr))
}

// DEC - Decrement memory
// https://www.c64-wiki.com/wiki/DEC
//
// If the byte in question is taken as an unsigned integer, DEC "counts down" from 255 thru 0/$FF thru $0.
// If a byte already containing the value 0/$0 is DECremented, it "wraps over" to the value 255/$FF.
//
// If the byte is taken as a signed integer, DEC will "count down" from +127 thru −128, or +$7F thru −$80.
// If a byte already holding the value −128/−$80 is DECremented, it "wraps over" to the value +127/$7F.
fn opDEC(self : CPU, addr : Int, mode : Mode) -> Unit {
  let value = (self.read(addr) - 1).land(0xFF)
  self.write(addr, value)
  self.flags.setZN(value)
}

// DEX - Decrement x register
fn opDEX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[X] = self.registers[X] - 1
  self.flags.setZN(self.registers[X])
}

// DEY - Decrement y register
fn opDEY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[Y] = self.registers[Y] - 1
  self.flags.setZN(self.registers[Y])
}

// EOR - Exclusive or
fn opEOR(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.registers[A].lxor(self.read(addr))
  self.flags.setZN(self.registers[A])
}

// INC - Increment memory
// https://www.c64-wiki.com/wiki/INC
//
// If the byte in question is taken as an unsigned integer, INC "counts" from 0 thru 255/$0 thru $FF.
// If a byte already containing the value 255/$FF is INCremented, it "wraps over" to the value 0.
//
// If the byte is taken as a signed integer, INC will "count" from −128 thru +127, or −$80 thru +$7F.
// If a byte already holding the value 127/$7F is INCremented, it "wraps over" to the value −128/−$80.
fn opINC(self : CPU, addr : Int, mode : Mode) -> Unit {
  let value = (self.read(addr) + 1).land(0xFF)
  self.write(addr, value)
  self.flags.setZN(value)
}

// INX - Increment x register
fn opINX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[X] = self.registers[X] + 1
  self.flags.setZN(self.registers[X])
}

// INY - Increment y register
fn opINY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[Y] = self.registers[Y] + 1
  self.flags.setZN(self.registers[Y])
}

// JMP - Jump
fn opJMP(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.pc = addr
}

// JSR - Jump to subroutine
fn opJSR(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.push16(self.pc - 1)
  self.pc = addr
}

// LDA - Load accumulator
fn opLDA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.read(addr)
  self.flags.setZN(self.registers[A])
}

// LDX - Load x register
fn opLDX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[X] = self.read(addr)
  self.flags.setZN(self.registers[X])
}

// LDY - Load y register
fn opLDY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[Y] = self.read(addr)
  self.flags.setZN(self.registers[Y])
}

// LSR - Logical shift right
fn opLSR(self : CPU, addr : Int, mode : Mode) -> Unit {
  match mode {
    Accumulator => {
      self.flags[C] = self.registers[A].land(1) != 0 // self.A & 1
      self.registers[A] = self.registers[A].lsr(1) // self.A >>= 1
      self.flags.setZN(self.registers[A])
    }
    _ => {
      let mut value = self.read(addr)
      self.flags[C] = value.land(1) != 0 // value & 1
      value = value.lsr(1) // val >>= 1
      self.write(addr, value)
      self.flags.setZN(value)
    }
  }
}

// NOP - No operation
fn opNOP(self : CPU, addr : Int, mode : Mode) -> Unit {
  //
}

// ORA - Logical inclusive or
fn opORA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.registers[A].lor(self.read(addr))
  self.flags.setZN(self.registers[A])
}

// PHA - Push accumulator
fn opPHA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.push(self.registers[A])
}

// PHP - Push processor status
fn opPHP(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.push(self.flags.get_flags().lor(0x10))
}

// PLA - Pull accumulator
fn opPLA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.pop()
  self.flags.setZN(self.registers[A])
}

// PLP - Pull processor status
fn opPLP(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.set_flags(self.pop().land(0xEF).lor(0x20)) // pull() & 0xEF | 0x20
}

// ROL - Rotate left
fn opROL(self : CPU, addr : Int, mode : Mode) -> Unit {
  let c = self.flags[C].to_int()
  match mode {
    Accumulator => {
      self.flags[C] = self.registers[A].lsr(7).land(1) != 0 // (self.A >> 7) & 1
      self.registers[A] = self.registers[A].lsl(1).lor(c) // (self.A << 1) | c
      self.flags.setZN(self.registers[A])
    }
    _ => {
      let mut value = self.read(addr)
      self.flags[C] = value.lsr(7).land(1) != 0 // (val >> 7) & 1
      value = value.lsl(1).lor(c) // (val << 1) | c
      self.write(addr, value)
      self.flags.setZN(value)
    }
  }
}

// ROR - Rotate right
fn opROR(self : CPU, addr : Int, mode : Mode) -> Unit {
  let c = self.flags[C].to_int()
  match mode {
    Accumulator => {
      self.flags[C] = self.registers[A].land(1) != 0 // self.A & 1
      self.registers[A] = self.registers[A].lsr(1).lor(c.lsl(7)) // (self.A >> 1) | (c << 7)
      self.flags.setZN(self.registers[A])
    }
    _ => {
      let mut value = self.read(addr)
      self.flags[C] = value.land(1) != 0 // val & 1
      value = value.lsr(1).lor(c.lsl(7)) // (val >> 1) | (c << 7)
      self.write(addr, value)
      self.flags.setZN(value)
    }
  }
}

// RTI - Return from interrupt
fn opRTI(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.set_flags(self.pop().land(0xEF).lor(0x20)) // pull() & 0xEF | 0x20
  self.pc = self.pop16()
}

// RTS - Return from subrouting
fn opRTS(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.pc = self.pop16() + 1
}

// SBC - Subtract with carry
fn opSBC(self : CPU, addr : Int, mode : Mode) -> Unit {
  let a = self.registers[A]
  let b = self.read(addr)
  let c = self.flags[C].to_int()
  self.registers[A] = a - b - (1 - c) // capped at 0xff
  self.flags.setZN(self.registers[A])
  self.flags[C] = a - b - (1 - c) >= 0 // not capped at 0xff
  self.flags[V] = a.lxor(b).land(0x80) != 0 && a.lxor(self.registers[A]).land(
      0x80,
    ) != 0
}

// SEC - Set carry flag
fn opSEC(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.set(C)
}

// SED - Set decimal flag
fn opSED(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.set(D)
}

// SEI - Set interrupt disable
fn opSEI(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.flags.set(I)
}

// STA - Store accumulator
fn opSTA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.write(addr, self.registers[A])
}

// STX - Store x register
fn opSTX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.write(addr, self.registers[X])
}

// STY - Store y register
fn opSTY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.write(addr, self.registers[Y])
}

// TAX - Transfer accumulator to x
fn opTAX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[X] = self.registers[A]
  self.flags.setZN(self.registers[X])
}

// TAY - Transfer accumulator to y
fn opTAY(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[Y] = self.registers[A]
  self.flags.setZN(self.registers[Y])
}

// TSX - Transfer stack pointer to x
fn opTSX(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[X] = self.registers[SP]
  self.flags.setZN(self.registers[X])
}

// TXA - Transfer x to accumulator
fn opTXA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.registers[X]
  self.flags.setZN(self.registers[A])
}

// TXS - Transfer x to stack pointer
fn opTXS(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[SP] = self.registers[X]
}

// TYA - Transfer y to accumulator
fn opTYA(self : CPU, addr : Int, mode : Mode) -> Unit {
  self.registers[A] = self.registers[Y]
  self.flags.setZN(self.registers[A])
}

//
// Illegal opcodes
//
// https://www.nesdev.org/wiki/CPU_unofficial_opcodes
// https://www.nesdev.org/wiki/Programming_with_unofficial_opcodes
//

fn opAHX(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: AHX")
  //abort("AHX")
}

fn opALR(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: ALR")
  //abort("ALR")
}

fn opANC(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: ANC")
  //abort("ANC")
}

fn opARR(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: ARR")
  //abort("ARR")
}

fn opAXS(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: AXS")
  //abort("AXS")
}

fn opDCP(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to DEC value then CMP value, except supporting more addressing modes.
  // LDA #$FF followed by DCP can be used to check if the decrement underflows, which is useful for multi-byte decrements.
  self.opDEC(addr, mode)
  self.opCMP(addr, mode)
}

fn opISC(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to INC value then SBC value, except supporting more addressing modes.
  self.opINC(addr, mode)
  self.opSBC(addr, mode)
}

fn opJAM(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: JAM")
  //abort("JAM")
}

fn opLAS(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: LAS")
  //abort("LAS")
}

fn opLAX(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Shortcut for LDA value then TAX. Saves a byte and two cycles and allows use of the X register with the (d),Y addressing mode.
  // Notice that the immediate is missing; the opcode that would have been LAX is affected by line noise on the data bus.
  // MOS 6502: even the bugs have bugs.
  self.opLDA(addr, mode)
  self.opTAX(addr, mode)
}

fn opRLA(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to ROL value then AND value, except supporting more addressing modes.
  // LDA #$FF followed by RLA is an efficient way to rotate a variable while also loading it in A.
  self.opROL(addr, mode)
  self.opAND(addr, mode)
}

fn opRRA(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to ROR value then ADC value, except supporting more addressing modes.
  // Essentially this computes A + value / 2, where value is 9-bit and the division is rounded up.
  self.opROR(addr, mode)
  self.opADC(addr, mode)
}

fn opSAX(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Stores the bitwise AND of A and X. As with STA and STX, no flags are affected.
  self.write(addr, self.registers[A].land(self.registers[X]))
}

fn opSHX(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: SHX")
  //abort("SHX")
}

fn opSHY(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: SHY")
  //abort("SHY")
}

fn opSLO(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to ASL value then ORA value, except supporting more addressing modes.
  // LDA #0 followed by SLO is an efficient way to shift a variable while also loading it in A.
  self.opASL(addr, mode)
  self.opORA(addr, mode)
}

fn opSRE(self : CPU, addr : Int, mode : Mode) -> Unit {
  // Equivalent to LSR value then EOR value, except supporting more addressing modes.
  // LDA #0 followed by SRE is an efficient way to shift a variable while also loading it in A.
  self.opLSR(addr, mode)
  self.opEOR(addr, mode)
}

fn opTAS(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: TAS")
  //abort("TAS")
}

fn opXAA(self : CPU, addr : Int, mode : Mode) -> Unit {
  println("unimplemented: XAA")
  //abort("XAA")
}

enum Mode {
  Absolute // 0
  AbsoluteX // 1
  AbsoluteY // 2
  Accumulator // 3
  Immediate // 4
  Implied // 5
  IndexedIndirect // 6
  Indirect // 7
  IndirectIndexed // 8
  Relative // 9
  ZeroPage // 10
  ZeroPageX // 11
  ZeroPageY // 12
} derive(Debug, Show, Eq)

let instructions : FixedArray[
  (String, (CPU, Int, Mode) -> Unit, Mode, UInt16, UInt16, UInt16, Bool),
] = [ // All 6502 instructions
  // 0x00
  ("BRK", opBRK, Implied, 1, 7, 0, false),
  ("ORA", opORA, IndexedIndirect, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("SLO", opSLO, IndexedIndirect, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPage, 2, 3, 0, true),
  ("ORA", opORA, ZeroPage, 2, 3, 0, false),
  ("ASL", opASL, ZeroPage, 2, 5, 0, false),
  ("SLO", opSLO, ZeroPage, 2, 5, 0, true),
  ("PHP", opPHP, Implied, 1, 3, 0, false),
  ("ORA", opORA, Immediate, 2, 2, 0, false),
  ("ASL", opASL, Accumulator, 1, 2, 0, false),
  ("ANC", opANC, Immediate, 0, 2, 0, true),
  ("NOP", opNOP, Absolute, 3, 4, 0, true),
  ("ORA", opORA, Absolute, 3, 4, 0, false),
  ("ASL", opASL, Absolute, 3, 6, 0, false),
  ("SLO", opSLO, Absolute, 3, 6, 0, true),
  // 0x10
  ("BPL", opBPL, Relative, 2, 2, 1, false),
  ("ORA", opORA, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("SLO", opSLO, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("ORA", opORA, ZeroPageX, 2, 4, 0, false),
  ("ASL", opASL, ZeroPageX, 2, 6, 0, false),
  ("SLO", opSLO, ZeroPageX, 2, 6, 0, true),
  ("CLC", opCLC, Implied, 1, 2, 0, false),
  ("ORA", opORA, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("SLO", opSLO, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("ORA", opORA, AbsoluteX, 3, 4, 1, false),
  ("ASL", opASL, AbsoluteX, 3, 7, 0, false),
  ("SLO", opSLO, AbsoluteX, 3, 7, 0, true),
  // 0x20
  ("JSR", opJSR, Absolute, 3, 6, 0, false),
  ("AND", opAND, IndexedIndirect, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("RLA", opRLA, IndexedIndirect, 2, 8, 0, true),
  ("BIT", opBIT, ZeroPage, 2, 3, 0, false),
  ("AND", opAND, ZeroPage, 2, 3, 0, false),
  ("ROL", opROL, ZeroPage, 2, 5, 0, false),
  ("RLA", opRLA, ZeroPage, 2, 5, 0, true),
  ("PLP", opPLP, Implied, 1, 4, 0, false),
  ("AND", opAND, Immediate, 2, 2, 0, false),
  ("ROL", opROL, Accumulator, 1, 2, 0, false),
  ("ANC", opANC, Immediate, 0, 2, 0, true),
  ("BIT", opBIT, Absolute, 3, 4, 0, false),
  ("AND", opAND, Absolute, 3, 4, 0, false),
  ("ROL", opROL, Absolute, 3, 6, 0, false),
  ("RLA", opRLA, Absolute, 3, 6, 0, true),
  // 0x30
  ("BMI", opBMI, Relative, 2, 2, 1, false),
  ("AND", opAND, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("RLA", opRLA, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("AND", opAND, ZeroPageX, 2, 4, 0, false),
  ("ROL", opROL, ZeroPageX, 2, 6, 0, false),
  ("RLA", opRLA, ZeroPageX, 2, 6, 0, true),
  ("SEC", opSEC, Implied, 1, 2, 0, false),
  ("AND", opAND, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("RLA", opRLA, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("AND", opAND, AbsoluteX, 3, 4, 1, false),
  ("ROL", opROL, AbsoluteX, 3, 7, 0, false),
  ("RLA", opRLA, AbsoluteX, 3, 7, 0, true),
  // 0x40
  ("RTI", opRTI, Implied, 1, 6, 0, false),
  ("EOR", opEOR, IndexedIndirect, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("SRE", opSRE, IndexedIndirect, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPage, 2, 3, 0, true),
  ("EOR", opEOR, ZeroPage, 2, 3, 0, false),
  ("LSR", opLSR, ZeroPage, 2, 5, 0, false),
  ("SRE", opSRE, ZeroPage, 2, 5, 0, true),
  ("PHA", opPHA, Implied, 1, 3, 0, false),
  ("EOR", opEOR, Immediate, 2, 2, 0, false),
  ("LSR", opLSR, Accumulator, 1, 2, 0, false),
  ("ALR", opALR, Immediate, 0, 2, 0, true),
  ("JMP", opJMP, Absolute, 3, 3, 0, false),
  ("EOR", opEOR, Absolute, 3, 4, 0, false),
  ("LSR", opLSR, Absolute, 3, 6, 0, false),
  ("SRE", opSRE, Absolute, 3, 6, 0, true),
  // 0x50
  ("BVC", opBVC, Relative, 2, 2, 1, false),
  ("EOR", opEOR, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("SRE", opSRE, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("EOR", opEOR, ZeroPageX, 2, 4, 0, false),
  ("LSR", opLSR, ZeroPageX, 2, 6, 0, false),
  ("SRE", opSRE, ZeroPageX, 2, 6, 0, true),
  ("CLI", opCLI, Implied, 1, 2, 0, false),
  ("EOR", opEOR, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("SRE", opSRE, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("EOR", opEOR, AbsoluteX, 3, 4, 1, false),
  ("LSR", opLSR, AbsoluteX, 3, 7, 0, false),
  ("SRE", opSRE, AbsoluteX, 3, 7, 0, true),
  // 0x60
  ("RTS", opRTS, Implied, 1, 6, 0, false),
  ("ADC", opADC, IndexedIndirect, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("RRA", opRRA, IndexedIndirect, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPage, 2, 3, 0, true),
  ("ADC", opADC, ZeroPage, 2, 3, 0, false),
  ("ROR", opROR, ZeroPage, 2, 5, 0, false),
  ("RRA", opRRA, ZeroPage, 2, 5, 0, true),
  ("PLA", opPLA, Implied, 1, 4, 0, false),
  ("ADC", opADC, Immediate, 2, 2, 0, false),
  ("ROR", opROR, Accumulator, 1, 2, 0, false),
  ("ARR", opARR, Immediate, 0, 2, 0, true),
  ("JMP", opJMP, Indirect, 3, 5, 0, false),
  ("ADC", opADC, Absolute, 3, 4, 0, false),
  ("ROR", opROR, Absolute, 3, 6, 0, false),
  ("RRA", opRRA, Absolute, 3, 6, 0, true),
  // 0x70
  ("BVS", opBVS, Relative, 2, 2, 1, false),
  ("ADC", opADC, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("RRA", opRRA, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("ADC", opADC, ZeroPageX, 2, 4, 0, false),
  ("ROR", opROR, ZeroPageX, 2, 6, 0, false),
  ("RRA", opRRA, ZeroPageX, 2, 6, 0, true),
  ("SEI", opSEI, Implied, 1, 2, 0, false),
  ("ADC", opADC, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("RRA", opRRA, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("ADC", opADC, AbsoluteX, 3, 4, 1, false),
  ("ROR", opROR, AbsoluteX, 3, 7, 0, false),
  ("RRA", opRRA, AbsoluteX, 3, 7, 0, true),
  // 0x80
  ("NOP", opNOP, Immediate, 2, 2, 0, true),
  ("STA", opSTA, IndexedIndirect, 2, 6, 0, false),
  ("NOP", opNOP, Immediate, 0, 2, 0, true),
  ("SAX", opSAX, IndexedIndirect, 2, 6, 0, true),
  ("STY", opSTY, ZeroPage, 2, 3, 0, false),
  ("STA", opSTA, ZeroPage, 2, 3, 0, false),
  ("STX", opSTX, ZeroPage, 2, 3, 0, false),
  ("SAX", opSAX, ZeroPage, 2, 3, 0, true),
  ("DEY", opDEY, Implied, 1, 2, 0, false),
  ("NOP", opNOP, Immediate, 0, 2, 0, true),
  ("TXA", opTXA, Implied, 1, 2, 0, false),
  ("XAA", opXAA, Immediate, 0, 2, 0, true), // FIXME: ANE
  ("STY", opSTY, Absolute, 3, 4, 0, false),
  ("STA", opSTA, Absolute, 3, 4, 0, false),
  ("STX", opSTX, Absolute, 3, 4, 0, false),
  ("SAX", opSAX, Absolute, 3, 4, 0, true),
  // 0x90
  ("BCC", opBCC, Relative, 2, 2, 1, false),
  ("STA", opSTA, IndirectIndexed, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("AHX", opAHX, IndirectIndexed, 0, 6, 0, true),
  ("STY", opSTY, ZeroPageX, 2, 4, 0, false),
  ("STA", opSTA, ZeroPageX, 2, 4, 0, false),
  ("STX", opSTX, ZeroPageY, 2, 4, 0, false),
  ("SAX", opSAX, ZeroPageY, 2, 4, 0, true),
  ("TYA", opTYA, Implied, 1, 2, 0, false),
  ("STA", opSTA, AbsoluteY, 3, 5, 0, false),
  ("TXS", opTXS, Implied, 1, 2, 0, false),
  ("TAS", opTAS, AbsoluteY, 0, 5, 0, true),
  ("SHY", opSHY, AbsoluteX, 0, 5, 0, true),
  ("STA", opSTA, AbsoluteX, 3, 5, 0, false),
  ("SHX", opSHX, AbsoluteY, 0, 5, 0, true),
  ("AHX", opAHX, AbsoluteY, 0, 5, 0, true), // FIXME: SHA
  // 0xA0
  ("LDY", opLDY, Immediate, 2, 2, 0, false),
  ("LDA", opLDA, IndexedIndirect, 2, 6, 0, false),
  ("LDX", opLDX, Immediate, 2, 2, 0, false),
  ("LAX", opLAX, IndexedIndirect, 2, 6, 0, true),
  ("LDY", opLDY, ZeroPage, 2, 3, 0, false),
  ("LDA", opLDA, ZeroPage, 2, 3, 0, false),
  ("LDX", opLDX, ZeroPage, 2, 3, 0, false),
  ("LAX", opLAX, ZeroPage, 2, 3, 0, true),
  ("TAY", opTAY, Implied, 1, 2, 0, false),
  ("LDA", opLDA, Immediate, 2, 2, 0, false),
  ("TAX", opTAX, Implied, 1, 2, 0, false),
  ("LAX", opLAX, Immediate, 0, 2, 0, true),
  ("LDY", opLDY, Absolute, 3, 4, 0, false),
  ("LDA", opLDA, Absolute, 3, 4, 0, false),
  ("LDX", opLDX, Absolute, 3, 4, 0, false),
  ("LAX", opLAX, Absolute, 3, 4, 0, true),
  // 0xB0
  ("BCS", opBCS, Relative, 2, 2, 1, false),
  ("LDA", opLDA, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("LAX", opLAX, IndirectIndexed, 2, 5, 1, true),
  ("LDY", opLDY, ZeroPageX, 2, 4, 0, false),
  ("LDA", opLDA, ZeroPageX, 2, 4, 0, false),
  ("LDX", opLDX, ZeroPageY, 2, 4, 0, false),
  ("LAX", opLAX, ZeroPageY, 2, 4, 0, true),
  ("CLV", opCLV, Implied, 1, 2, 0, false),
  ("LDA", opLDA, AbsoluteY, 3, 4, 1, false),
  ("TSX", opTSX, Implied, 1, 2, 0, false),
  ("LAS", opLAS, AbsoluteY, 0, 4, 1, true),
  ("LDY", opLDY, AbsoluteX, 3, 4, 1, false),
  ("LDA", opLDA, AbsoluteX, 3, 4, 1, false),
  ("LDX", opLDX, AbsoluteY, 3, 4, 1, false),
  ("LAX", opLAX, AbsoluteY, 3, 4, 1, true),
  // 0xC0
  ("CPY", opCPY, Immediate, 2, 2, 0, false),
  ("CMP", opCMP, IndexedIndirect, 2, 6, 0, false),
  ("NOP", opNOP, Immediate, 0, 2, 0, true),
  ("DCP", opDCP, IndexedIndirect, 2, 8, 0, true),
  ("CPY", opCPY, ZeroPage, 2, 3, 0, false),
  ("CMP", opCMP, ZeroPage, 2, 3, 0, false),
  ("DEC", opDEC, ZeroPage, 2, 5, 0, false),
  ("DCP", opDCP, ZeroPage, 2, 5, 0, true),
  ("INY", opINY, Implied, 1, 2, 0, false),
  ("CMP", opCMP, Immediate, 2, 2, 0, false),
  ("DEX", opDEX, Implied, 1, 2, 0, false),
  ("AXS", opAXS, Immediate, 0, 2, 0, true), // FIXME: SBX
  ("CPY", opCPY, Absolute, 3, 4, 0, false),
  ("CMP", opCMP, Absolute, 3, 4, 0, false),
  ("DEC", opDEC, Absolute, 3, 6, 0, false),
  ("DCP", opDCP, Absolute, 3, 6, 0, true),
  // 0xD0
  ("BNE", opBNE, Relative, 2, 2, 1, false),
  ("CMP", opCMP, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("DCP", opDCP, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("CMP", opCMP, ZeroPageX, 2, 4, 0, false),
  ("DEC", opDEC, ZeroPageX, 2, 6, 0, false),
  ("DCP", opDCP, ZeroPageX, 2, 6, 0, true),
  ("CLD", opCLD, Implied, 1, 2, 0, false),
  ("CMP", opCMP, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("DCP", opDCP, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("CMP", opCMP, AbsoluteX, 3, 4, 1, false),
  ("DEC", opDEC, AbsoluteX, 3, 7, 0, false),
  ("DCP", opDCP, AbsoluteX, 3, 7, 0, true),
  // 0xE0
  ("CPX", opCPX, Immediate, 2, 2, 0, false),
  ("SBC", opSBC, IndexedIndirect, 2, 6, 0, false),
  ("NOP", opNOP, Immediate, 0, 2, 0, true),
  ("ISC", opISC, IndexedIndirect, 2, 8, 0, true),
  ("CPX", opCPX, ZeroPage, 2, 3, 0, false),
  ("SBC", opSBC, ZeroPage, 2, 3, 0, false),
  ("INC", opINC, ZeroPage, 2, 5, 0, false),
  ("ISC", opISC, ZeroPage, 2, 5, 0, true),
  ("INX", opINX, Implied, 1, 2, 0, false),
  ("SBC", opSBC, Immediate, 2, 2, 0, false),
  ("NOP", opNOP, Implied, 1, 2, 0, false),
  ("SBC", opSBC, Immediate, 2, 2, 0, true),
  ("CPX", opCPX, Absolute, 3, 4, 0, false),
  ("SBC", opSBC, Absolute, 3, 4, 0, false),
  ("INC", opINC, Absolute, 3, 6, 0, false),
  ("ISC", opISC, Absolute, 3, 6, 0, true),
  // 0xF0
  ("BEQ", opBEQ, Relative, 2, 2, 1, false),
  ("SBC", opSBC, IndirectIndexed, 2, 5, 1, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("ISC", opISC, IndirectIndexed, 2, 8, 0, true),
  ("NOP", opNOP, ZeroPageX, 2, 4, 0, true),
  ("SBC", opSBC, ZeroPageX, 2, 4, 0, false),
  ("INC", opINC, ZeroPageX, 2, 6, 0, false),
  ("ISC", opISC, ZeroPageX, 2, 6, 0, true),
  ("SED", opSED, Implied, 1, 2, 0, false),
  ("SBC", opSBC, AbsoluteY, 3, 4, 1, false),
  ("NOP", opNOP, Implied, 1, 2, 0, true),
  ("ISC", opISC, AbsoluteY, 3, 7, 0, true),
  ("NOP", opNOP, AbsoluteX, 3, 4, 1, true),
  ("SBC", opSBC, AbsoluteX, 3, 4, 1, false),
  ("INC", opINC, AbsoluteX, 3, 7, 0, false),
  ("ISC", opISC, AbsoluteX, 3, 7, 0, true),
]

enum Instruction {
  // LDA
  LDA_IM // 0xA9
  LDA_ZP // 0xA5
  LDA_ZPX // 0xB5
  LDA_ABS // 0xAD
  LDA_ABSX // 0xBD
  LDA_ABSY // 0xB9
  LDA_INDX // 0xA1
  LDA_INDY // 0xB1

  // LDX
  LDX_IM // 0xA2
  LDX_ZP // 0xA6
  LDX_ZPY // 0xB6
  LDX_ABS // 0xAE
  LDX_ABSY // 0xBE

  // LDY
  LDY_IM // 0xA0
  LDY_ZP // 0xA4
  LDY_ZPX // 0xB4
  LDY_ABS // 0xAC
  LDY_ABSX // 0xBC

  // STA
  STA_ZP // 0x85
  STA_ZPX // 0x95
  STA_ABS // 0x8D
  STA_ABSX // 0x9D
  STA_ABSY // 0x99
  STA_INDX // 0x81
  STA_INDY // 0x91

  // STX
  STX_ZP // 0x86
  STX_ZPY // 0x96
  STX_ABS // 0x8E

  // STY
  STY_ZP // 0x84
  STY_ZPX // 0x94
  STY_ABS // 0x8C
  TSX // 0xBA
  TXS // 0x9A
  PHA // 0x48
  PLA // 0x68
  PHP // 0x08
  PLP // 0x28
  JMP_ABS // 0x4C
  JMP_IND // 0x6C
  JSR // 0x20
  RTS // 0x60

  //
  // Logical Operations
  //

  // AND
  AND_IM // 0x29
  AND_ZP // 0x25
  AND_ZPX // 0x35
  AND_ABS // 0x2D
  AND_ABSX // 0x3D
  AND_ABSY // 0x39
  AND_INDX // 0x21
  AND_INDY // 0x31

  // OR
  ORA_IM // 0x09
  ORA_ZP // 0x05
  ORA_ZPX // 0x15
  ORA_ABS // 0x0D
  ORA_ABSX // 0x1D
  ORA_ABSY // 0x19
  ORA_INDX // 0x01
  ORA_INDY // 0x11

  // EOR
  EOR_IM // 0x49
  EOR_ZP // 0x45
  EOR_ZPX // 0x55
  EOR_ABS // 0x4D
  EOR_ABSX // 0x5D
  EOR_ABSY // 0x59
  EOR_INDX // 0x41
  EOR_INDY // 0x51

  // BIT
  BIT_ZP // 0x24
  BIT_ABS // 0x2C

  //
  // Transfer Registers
  //
  TAX // 0xAA
  TAY // 0xA8
  TXA // 0x8A
  TYA // 0x98

  //
  // Increments
  // Decrements
  //
  INX // 0xE8
  INY // 0xC8
  DEY // 0x88
  DEX // 0xCA
  DEC_ZP // 0xC6
  DEC_ZPX // 0xD6
  DEC_ABS // 0xCE
  DEC_ABSX // 0xDE
  INC_ZP // 0xE6
  INC_ZPX // 0xF6
  INC_ABS // 0xEE
  INC_ABSX // 0xFE

  // Branches
  BEQ // 0xF0
  BNE // 0xD0
  BCS // 0xB0
  BCC // 0x90
  BMI // 0x30
  BPL // 0x10
  BVC // 0x50
  BVS // 0x70

  // Status Flag Changes
  CLC // 0x18
  SEC // 0x38
  CLD // 0xD8
  SED // 0xF8
  CLI // 0x58
  SEI // 0x78
  CLV // 0xB8

  // Arithmetics
  ADC // 0x69
  ADC_ZP // 0x65
  ADC_ZPX // 0x75
  ADC_ABS // 0x6D
  ADC_ABSX // 0x7D
  ADC_ABSY // 0x79
  ADC_INDX // 0x61
  ADC_INDY // 0x71
  SBC // 0xE9
  SBC_ABS // 0xED
  SBC_ZP // 0xE5
  SBC_ZPX // 0xF5
  SBC_ABSX // 0xFD
  SBC_ABSY // 0xF9
  SBC_INDX // 0xE1
  SBC_INDY // 0xF1

  // Comparisons
  CMP // 0xC9
  CMP_ZP // 0xC5
  CMP_ZPX // 0xD5
  CMP_ABS // 0xCD
  CMP_ABSX // 0xDD
  CMP_ABSY // 0xD9
  CMP_INDX // 0xC1
  CMP_INDY // 0xD1
  CPX // 0xE0
  CPY // 0xC0
  CPX_ZP // 0xE4
  CPY_ZP // 0xC4
  CPX_ABS // 0xEC
  CPY_ABS // 0xCC

  // Shifts
  ASL // 0x0A
  ASL_ZP // 0x06
  ASL_ZPX // 0x16
  ASL_ABS // 0x0E
  ASL_ABSX // 0x1E
  LSR // 0x4A
  LSR_ZP // 0x46
  LSR_ZPX // 0x56
  LSR_ABS // 0x4E
  LSR_ABSX // 0x5E
  ROL // 0x2A
  ROL_ZP // 0x26
  ROL_ZPX // 0x36
  ROL_ABS // 0x2E
  ROL_ABSX // 0x3E
  ROR // 0x6A
  ROR_ZP // 0x66
  ROR_ZPX // 0x76
  ROR_ABS // 0x6E
  ROR_ABSX // 0x7E

  // Miscellaneous
  NOP // 0xEA
  BRK // 0x00
  RTI // 0x40
} derive(Debug, Show)

// fn op_get(self : Instruction, instruction : Instruction) -> UInt8 {
//   get_opcode(instruction)
// }

fn get_opcode(instruction : Instruction) -> UInt8 {
  match instruction {
    // LDA
    LDA_IM => 0xA9
    LDA_ZP => 0xA5
    LDA_ZPX => 0xB5
    LDA_ABS => 0xAD
    LDA_ABSX => 0xBD
    LDA_ABSY => 0xB9
    LDA_INDX => 0xA1
    LDA_INDY => 0xB1

    // LDX
    LDX_IM => 0xA2
    LDX_ZP => 0xA6
    LDX_ZPY => 0xB6
    LDX_ABS => 0xAE
    LDX_ABSY => 0xBE

    // LDY
    LDY_IM => 0xA0
    LDY_ZP => 0xA4
    LDY_ZPX => 0xB4
    LDY_ABS => 0xAC
    LDY_ABSX => 0xBC

    // STA
    STA_ZP => 0x85
    STA_ZPX => 0x95
    STA_ABS => 0x8D
    STA_ABSX => 0x9D
    STA_ABSY => 0x99
    STA_INDX => 0x81
    STA_INDY => 0x91

    // STX
    STX_ZP => 0x86
    STX_ZPY => 0x96
    STX_ABS => 0x8E

    // STY
    STY_ZP => 0x84
    STY_ZPX => 0x94
    STY_ABS => 0x8C
    TSX => 0xBA
    TXS => 0x9A
    PHA => 0x48
    PLA => 0x68
    PHP => 0x08
    PLP => 0x28
    JMP_ABS => 0x4C
    JMP_IND => 0x6C
    JSR => 0x20
    RTS => 0x60

    //
    // Logical Operations
    //

    // AND
    AND_IM => 0x29
    AND_ZP => 0x25
    AND_ZPX => 0x35
    AND_ABS => 0x2D
    AND_ABSX => 0x3D
    AND_ABSY => 0x39
    AND_INDX => 0x21
    AND_INDY => 0x31

    // OR
    ORA_IM => 0x09
    ORA_ZP => 0x05
    ORA_ZPX => 0x15
    ORA_ABS => 0x0D
    ORA_ABSX => 0x1D
    ORA_ABSY => 0x19
    ORA_INDX => 0x01
    ORA_INDY => 0x11

    // EOR
    EOR_IM => 0x49
    EOR_ZP => 0x45
    EOR_ZPX => 0x55
    EOR_ABS => 0x4D
    EOR_ABSX => 0x5D
    EOR_ABSY => 0x59
    EOR_INDX => 0x41
    EOR_INDY => 0x51

    // BIT
    BIT_ZP => 0x24
    BIT_ABS => 0x2C

    //
    // Transfer Registers
    //
    TAX => 0xAA
    TAY => 0xA8
    TXA => 0x8A
    TYA => 0x98

    //
    // Increments
    // Decrements
    //
    INX => 0xE8
    INY => 0xC8
    DEY => 0x88
    DEX => 0xCA
    DEC_ZP => 0xC6
    DEC_ZPX => 0xD6
    DEC_ABS => 0xCE
    DEC_ABSX => 0xDE
    INC_ZP => 0xE6
    INC_ZPX => 0xF6
    INC_ABS => 0xEE
    INC_ABSX => 0xFE

    // Branches
    BEQ => 0xF0
    BNE => 0xD0
    BCS => 0xB0
    BCC => 0x90
    BMI => 0x30
    BPL => 0x10
    BVC => 0x50
    BVS => 0x70

    // Status Flag Changes
    CLC => 0x18
    SEC => 0x38
    CLD => 0xD8
    SED => 0xF8
    CLI => 0x58
    SEI => 0x78
    CLV => 0xB8

    // Arithmetics
    ADC => 0x69
    ADC_ZP => 0x65
    ADC_ZPX => 0x75
    ADC_ABS => 0x6D
    ADC_ABSX => 0x7D
    ADC_ABSY => 0x79
    ADC_INDX => 0x61
    ADC_INDY => 0x71
    SBC => 0xE9
    SBC_ABS => 0xED
    SBC_ZP => 0xE5
    SBC_ZPX => 0xF5
    SBC_ABSX => 0xFD
    SBC_ABSY => 0xF9
    SBC_INDX => 0xE1
    SBC_INDY => 0xF1

    // Comparisons
    CMP => 0xC9
    CMP_ZP => 0xC5
    CMP_ZPX => 0xD5
    CMP_ABS => 0xCD
    CMP_ABSX => 0xDD
    CMP_ABSY => 0xD9
    CMP_INDX => 0xC1
    CMP_INDY => 0xD1
    CPX => 0xE0
    CPY => 0xC0
    CPX_ZP => 0xE4
    CPY_ZP => 0xC4
    CPX_ABS => 0xEC
    CPY_ABS => 0xCC

    // Shifts
    ASL => 0x0A
    ASL_ZP => 0x06
    ASL_ZPX => 0x16
    ASL_ABS => 0x0E
    ASL_ABSX => 0x1E
    LSR => 0x4A
    LSR_ZP => 0x46
    LSR_ZPX => 0x56
    LSR_ABS => 0x4E
    LSR_ABSX => 0x5E
    ROL => 0x2A
    ROL_ZP => 0x26
    ROL_ZPX => 0x36
    ROL_ABS => 0x2E
    ROL_ABSX => 0x3E
    ROR => 0x6A
    ROR_ZP => 0x66
    ROR_ZPX => 0x76
    ROR_ABS => 0x6E
    ROR_ABSX => 0x7E

    // Miscellaneous
    NOP => 0xEA
    BRK => 0x00
    RTI => 0x40
  }
}
