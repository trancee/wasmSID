///|
struct Trap {
  address : UInt16
  handler : (CPU) -> Unit
}

///|
fn Trap::new(address : UInt16, handler : (CPU) -> Unit) -> Trap {
  { address, handler }
}

///|
pub const CPU_MEM_START = 0x0000

///|
pub const CPU_MEM_END = 0xFFFF

///|
pub const CPU_MEM_SIZE = 0xFFFF

///|
pub struct CPU {
  mem : FixedArray[UInt8]
  //
  mut read : ((UInt16, Bool) -> UInt8)?
  mut write : ((UInt16, UInt8, Bool) -> Unit)?
  //
  mut cycles : Int
  //
  mut pc : UInt16 // Program Counter
  //
  registers : Registers
  flags : Flags
  //
  decimal_mode : Bool
  // mut needs_interrupt : Vector
  mut nmi : Bool
  mut irq : Bool
  //
  traps : Array[Trap]
  //
  mut debug : Bool
}

///|
pub fn CPU::new(
  pc~ : UInt16 = 0x0000,
  //
  address? : UInt16,
  //
  data~ : Bytes = [],
  length~ : Int = data.length(),
  offset~ : Int = 0,
  //
  decimal_mode~ : Bool = true,
  //
  debug~ : Bool = false
) -> CPU {
  let registers = Registers::new()
  let flags = Flags::new()

  //
  let cpu : CPU = {
    mem: FixedArray::make(CPU_MEM_SIZE + 1, 0x00),
    //
    read: None,
    write: None,
    //
    cycles: 0,
    //
    pc,
    //
    registers,
    flags,
    //
    decimal_mode,
    //
    nmi: false,
    irq: false,
    //
    traps: [],
    //
    debug,
  }

  //
  cpu.write16(RESET, pc)

  //
  if data.length() > 0 {
    cpu.load(address.or(pc), data, length~, offset~) |> ignore
  }

  //
  cpu
}

///|
pub fn set_read(self : CPU, read : (UInt16, Bool) -> UInt8) -> Unit {
  self.read = Some(read)
}

///|
pub fn set_write(self : CPU, write : (UInt16, UInt8, Bool) -> Unit) -> Unit {
  self.write = Some(write)
}

///|
pub fn set_debug(self : CPU, debug : Bool) -> Unit {
  self.debug = debug
}

/// p.269
/// Interrupts
/// Defaults for NMI, BRK, and IRQ vectors (Non-Maskable Interrupt, BReaK, and Inter-
/// rupt ReQuest vectors) are permanently stored in the top six bytes of the 6510's
/// memory. With the 64, NMI jumps to $FE43, BRK to $FE66, and IRQ to $FF43. Hard-
/// ware reset (see Chapter 5) has no indirect vectors apart from the optional cartridge's
/// start address.

///| p.356
/// 6510/6502 Hardware Vectors
/// The 6510/6502 microprocessor chip reserves the highest six bytes of the address
/// space (locations $FFFA-$FFFF) for use as vectors. These three vectors point to
/// routines that handle processing under three special sets of circumstances. The chip
/// automatically causes a JMP through one of these vectors when external hardware
/// sends a Signal on the 6510/6502's NMI, RESET, or IRQ lines.

///| When the 6510/6502 receives an NMI (Non-Maskable
/// Interrupt) signal, it causes a jump to the address held
/// here.
pub const NMI = 0xFFFA

///| When the 6510/6502 receives a RESET signal, it causes a
/// jump to the address held here.
pub const RESET = 0xFFFC

///| When the 6510/6502 receives an IRQ (Interrupt Re-
/// Quest) Signal or processes a machine language BRK
/// instruction, it causes a jump to the address held here.
pub const IRQ = 0xFFFE

///|
pub fn CPU::reset(self : CPU, pc? : UInt16) -> Unit {
  // self.mem.clear()

  self.cycles = 0

  //
  self.pc = match pc {
    Some(pc) => pc
    None => self.read16(RESET)
  }

  //
  self.registers.reset()
  self.flags.reset()
}

///|
pub fn set_nmi(self : CPU, state~ : Bool = true) -> Unit {
  self.nmi = state
}

///|
pub fn set_irq(self : CPU, state~ : Bool = true) -> Unit {
  self.irq = state
}

///|
pub fn clear_registers(self : CPU) -> Unit {
  self.registers.reset()
}

///|
pub fn get_registers(self : CPU) -> Registers {
  self.registers
}

///|
pub fn clear_flags(self : CPU) -> Unit {
  self.flags.reset()
}

///|
pub fn get_flags(self : CPU) -> Flags {
  self.flags
}

///|
pub fn set_flags(self : CPU, flags : UInt8) -> Unit {
  self.flags.set(flags) |> ignore
}

///|
pub fn has_interrupt(self : CPU) -> Bool {
  self.flags[I]
}

///|
pub fn CPU::clear_interrupt(self : CPU) -> Unit {
  self.flags[I] = false
}

///|
pub fn CPU::set_interrupt(self : CPU) -> Unit {
  self.flags[I] = true
}

///|
pub fn trap(self : CPU, address : UInt16, handler : (CPU) -> Unit) -> Unit {
  self.traps.push(Trap::new(address, handler))
}

///|
pub fn pc(self : CPU) -> UInt16 {
  self.pc
}

///|
pub fn a(self : CPU) -> UInt8 {
  self.registers[A]
}

///|
pub fn register(self : CPU, register : Register, value : UInt8) -> Unit {
  self.registers[register] = value
}

// Load a program into memory
///|
pub fn load(
  self : CPU,
  //
  address : UInt16,
  //
  data : Bytes,
  length~ : UInt16 = u16(data.length()),
  offset~ : UInt16 = 0,
  //
  has_load_address~ : Bool = false
) -> UInt16 {
  // println(
  //   "CPU::load $" + UInt16(offset).to_hex() + " - $" + UInt16(length).to_hex(),
  // )
  let address : UInt16 = if has_load_address {
    u16(data[1] << 8) | u16(data[0])
  } else {
    address
  }
  let start : UInt16 = if has_load_address { 2 } else { offset }
  let zero : UInt16 = 0
  for i = zero; i < length - start; i = i + 1 {
    self.write(address + i, u8(data[(i + start).to_int()]), dummy=true)
  }
  address
}

///|
pub fn read(self : CPU, addr : UInt16, dummy~ : Bool = false) -> UInt8 {
  match self.read {
    Some(read) => read(addr, dummy)
    None => u8(self.mem[addr.to_int()])
  }
}

///|
pub fn read16(self : CPU, addr : UInt16, dummy~ : Bool = false) -> UInt16 {
  // println(
  //   "$" + U16::u16(addr).to_hex() + " → " + self.mem[addr + 1].to_hex() + self.mem[addr].to_hex(),
  // )
  (u16(self.read(addr + 1, dummy~)._) << 8) | // hi
  u16(self.read(addr, dummy~)._) // lo
}

///|
fn read16zp(self : CPU, addr : UInt16, dummy~ : Bool = false) -> UInt16 {
  // println(
  //   ("read16zp $" + addr.to_hex() + ":#$" + self.read(addr).to_hex() + " $" + (addr +
  //   1)&(0x00FF)) | (addr&(0xFF00).to_hex() + ":#$" + self.read(
  //     (addr + 1)&(0x00FF) | addr&(0xFF00),
  //   ).to_hex()),
  // )
  (u16(self.read(((addr + 1) & 0x00FF) | (addr & 0xFF00), dummy~)._) << 8) | // hi
  u16(self.read(addr, dummy~)._) // lo
}

///|
pub fn write(
  self : CPU,
  addr : UInt16,
  value : UInt8,
  dummy~ : Bool = false
) -> Unit {
  match self.write {
    Some(write) => write(addr, value, dummy)
    None => self.mem[addr.to_int()] = value
  }
  // println("$" + U16::u16(addr).to_hex() + " ← " + self.mem[addr].to_hex())
}

///|
pub fn write16(
  self : CPU,
  addr : UInt16,
  value : UInt16,
  dummy~ : Bool = false
) -> Unit {
  self.write(addr + 1, u8(value._ >> 8), dummy~) // hi
  self.write(addr, u8(value._), dummy~) // lo
  // println(
  //   "$" + U16::u16(addr).to_hex() + " ← " + self.mem[addr + 1].to_hex() + self.mem[addr].to_hex(),
  // )
}

///|
pub fn push(self : CPU, value : UInt8, dummy~ : Bool = false) -> Unit {
  self.write(u16(self.registers[SP]._) | 0x0100, value, dummy~)
  self.registers[SP] -= 1
}

///|
pub fn push16(self : CPU, value : UInt16) -> Unit {
  self.push(u8(value._ >> 8)) // hi
  self.push(u8(value._)) // lo
}

///|
fn pop(self : CPU, dummy~ : Bool = false) -> UInt8 {
  self.registers[SP] += 1
  self.read(u16(self.registers[SP]._) | 0x0100, dummy~)
}

///|
fn pop16(self : CPU) -> UInt16 {
  u16(self.pop()._) | // lo 
  (u16(self.pop()._) << 8) // hi
}

///|
pub fn dump(
  self : CPU,
  addr~ : UInt16 = 0x0000,
  cols~ : Int = 0x10,
  rows~ : Int = 0x10
) -> Unit {
  let mut i = 0
  let mut str = ""
  if rows > 1 {
    str = "     "
    while i < cols {
      str += u8(i).to_hex() + " "
      i = i + 1
    }
    i = 0
  }
  while i <= cols * rows {
    if i % cols == 0 {
      if str.length() > 0 {
        println(str)
      }
      str = (addr + i).to_hex() + "|"
    }
    str += self.mem[(addr + i).to_int()].to_hex() + " "
    i = i + 1
  }
}

///| triggers a NMI IRQ in the processor
/// this is very similar to the BRK instruction
pub fn nmi(self : CPU, pc? : UInt16) -> Unit {
  println(
    "*** NMI $" +
    u16(NMI).to_hex() +
    " #$" +
    self.read16(NMI, dummy=true).to_hex(),
  )
  // self.flags.set_break()
  self.push16(self.pc)
  self.push(self.flags.get())
  self.flags.set_interrupt()
  self.pc = pc.or(self.read16(NMI))
  self.cycles += 7
}

///| triggers a normal IRQ
/// this is very similar to the BRK instruction
pub fn irq(self : CPU, pc? : UInt16) -> Unit {
  if self.has_interrupt() {
    return
  }
  println(
    "*** IRQ $" +
    u16(IRQ).to_hex() +
    " #$" +
    self.read16(IRQ, dummy=true).to_hex(),
  )
  self.push16(self.pc)
  self.push(self.flags.get())
  self.flags.set_interrupt()
  self.pc = pc.or(self.read16(IRQ))
  self.cycles += 7
}

///|
pub fn interrupts(self : CPU) -> Bool {
  if self.nmi {
    self.nmi = false
    self.nmi()
    return true
  } else if self.irq && not(self.has_interrupt()) {
    self.irq = false
    self.irq()
    return true
  }
  return false
}

///|
pub fn step(self : CPU) -> Int {
  let cycles = self.cycles

  //
  if not(self.interrupts()) {
    let mut skip = false
    for trap in self.traps {
      if self.pc == trap.address {
        (trap.handler)(self)
        skip = true
      }
    }

    //
    let opcode = self.read(self.pc, dummy=true)._

    //
    let (name, op, mode, size, cycles, _, illegal) = instructions[opcode]
    if self.debug {
      self.dump_step(opcode, name, mode, size, cycles, illegal)
    }

    //
    let addr = self.get_addr(mode)

    //
    self.pc += size

    //
    op(self, addr, mode)

    //
    if skip {
      // self.reset(pc=self.pc)
      // abort("trap")
      return 0
    } else {
      self.cycles += cycles
    }
  }

  //
  self.cycles - cycles
}

///|
fn get_addr(self : CPU, mode : Mode, dummy~ : Bool = true) -> UInt16 {
  let pc = self.pc + 1 |> u16
  match mode {
    Implied => 0 |> u16
    Accumulator => 0 |> u16
    Immediate => pc |> u16
    Indirect => self.read16zp(self.read16(pc, dummy~), dummy~) |> u16
    IndexedIndirect =>
      self.read16zp(
        (self.read(pc, dummy~).to_int() + self.registers[X].to_int()) & 0xFF,
        dummy~,
      )
      |> u16
    IndirectIndexed =>
      self.read16zp(self.read(pc, dummy~).to_int(), dummy~) +
      self.registers[Y].to_int()
      |> u16
    Absolute => self.read16(pc, dummy~) |> u16
    AbsoluteX => self.read16(pc, dummy~) + self.registers[X].to_int() |> u16
    AbsoluteY => self.read16(pc, dummy~) + self.registers[Y].to_int() |> u16
    ZeroPage => self.read(pc, dummy~).to_int() & 0xFF |> u16
    ZeroPageX =>
      (self.read(pc, dummy~).to_int() + self.registers[X].to_int()) & 0xFF
      |> u16
    ZeroPageY =>
      (self.read(pc, dummy~).to_int() + self.registers[Y].to_int()) & 0xFF
      |> u16
    Relative => pc + 1 + self.read(pc, dummy~).to_signed() |> u16
  }
}

///|
fn dump_step(
  self : CPU,
  opcode : UInt8,
  name : String,
  mode : Mode,
  size : Int,
  _ : Int, // cycles
  illegal : Bool
) -> Unit {
  let dummy = true
  let pc = self.pc + 1 |> u16
  let read8 = fn() { "$" + self.read(pc, dummy~).to_hex() }
  let read16 = fn() {
    "$" + self.read(pc + 1, dummy~).to_hex() + self.read(pc, dummy~).to_hex()
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
      " (" +
      read16() +
      ")" +
      " = " +
      self.read16zp(self.read16(pc, dummy~), dummy~).to_hex()
    IndexedIndirect =>
      // Indexed-Indirect Addressing
      // https://www.c64-wiki.com/wiki/Indexed-indirect_addressing
      //
      // The X index register is used to offset the zero page vector used to determine the effective address.
      // ADC, AND, CMP, EOR, LDA, ORA, SBC, STA.
      " (" +
      read8() +
      ",X) @ " +
      (self.read(pc, dummy~) + self.registers[X]).to_hex() +
      " = " +
      self
      .read16zp(
        (self.read(pc, dummy~).to_int() + self.registers[X].to_int()) & 0xFF,
        dummy~,
      )
      .to_hex() +
      " = " +
      self
      .read(
        self.read16zp(
          (self.read(pc, dummy~).to_int() + self.registers[X].to_int()) & 0xFF,
          dummy~,
        ),
      )
      .to_hex()
    IndirectIndexed =>
      // Indirect-Indexed Addressing
      // https://www.c64-wiki.com/wiki/Indirect-indexed_addressing
      //
      // The Y Index Register is used as an offset from the given zero page vector.
      // The effective address is calculated as the vector plus the value in Y.
      // ADC, AND, CMP, EOR, LDA, ORA, SBC, and STA.
      " (" +
      read8() +
      "),Y = " +
      self.read16zp(self.read(pc, dummy~).to_int(), dummy~).to_hex() +
      " @ " +
      (self.read16zp(self.read(pc, dummy~).to_int(), dummy~) +
      self.registers[Y].to_int()).to_hex() +
      " = " +
      self
      .read(
        self.read16zp(self.read(pc, dummy~).to_int(), dummy~) +
        self.registers[Y].to_int(),
        dummy~,
      )
      .to_hex()
    Absolute =>
      // Absolute Addressing
      // https://www.c64-wiki.com/wiki/Absolute_addressing
      //
      // Specifies an address in memory which is to be the "object" of the instruction.
      // ADC, AND, ASL, BIT, CMP, CPX, CPY, DEC, EOR, INC, JMP, JSR, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, and STY.
      " " +
      read16() +
      (match name {
        "JMP" | "JSR" => ""
        _ => " = " + self.read(self.read16(pc, dummy~), dummy~).to_hex()
      })
    AbsoluteX =>
      // Indexed Absolute Addressing
      // https://www.c64-wiki.com/wiki/Indexed_absolute_addressing
      //
      // The contents of the X index register is added to a given base address.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA.
      " " +
      read16() +
      ",X @ " +
      (self.read16(pc, dummy~) + self.registers[X].to_int()).to_hex() +
      " = " +
      self
      .read(self.read16(pc, dummy~) + self.registers[X].to_int(), dummy~)
      .to_hex()
    AbsoluteY =>
      // Indexed Absolute Addressing
      // https://www.c64-wiki.com/wiki/Indexed_absolute_addressing
      //
      // The contents of the Y index register is added to a given base address.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA.
      " " +
      read16() +
      ",Y @ " +
      (self.read16(pc, dummy~) + self.registers[Y].to_int()).to_hex() +
      " = " +
      self
      .read(self.read16(pc, dummy~) + self.registers[Y].to_int(), dummy~)
      .to_hex()
    ZeroPage =>
      // Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Zeropage_addressing
      //
      // Specifies an address in zero-page which is to be the "object" of the instruction.
      // ADC, AND, ASL, BIT, CMP, CPX, CPY, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, and STY.
      " " +
      read8() +
      " = " +
      self.read(self.read(pc, dummy~).to_int(), dummy~).to_hex()
    ZeroPageX =>
      // Indexed Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Indexed_zeropage_addressing
      //
      // The contents of the X index register is added to a given base address in zero-page.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, STY.
      " " +
      read8() +
      ",X @ " +
      u8(self.read(pc, dummy~).to_int() + self.registers[X].to_int()).to_hex() +
      " = " +
      self
      .read((self.read(pc, dummy~) + self.registers[X]).to_int(), dummy~)
      .to_hex()
    ZeroPageY =>
      // Indexed Zeropage Addressing
      // https://www.c64-wiki.com/wiki/Indexed_zeropage_addressing
      //
      // The contents of the Y index register is added to a given base address in zero-page.
      // ADC, AND, ASL, CMP, DEC, EOR, INC, LDA, LDX, LDY, LSR, ORA, ROL, ROR, SBC, STA, STX, STY.
      " " +
      read8() +
      ",Y @ " +
      u8(self.read(pc, dummy~).to_int() + self.registers[Y].to_int()).to_hex() +
      " = " +
      self
      .read((self.read(pc, dummy~) + self.registers[Y]).to_int(), dummy~)
      .to_hex()
    Relative =>
      // Relative Addressing
      // https://www.c64-wiki.com/wiki/Relative_addressing
      //
      // A single, signed-integer byte that specifies, in relative terms, how far "up" or "down" to jump if the required conditions are met.
      // This signed 8-bit figure is called the offset.
      // BCC, BCS, BEQ, BMI, BNE, BPL, BVC, and BVS.
      " $" + (pc + 1 + self.read(pc, dummy~).to_signed()).to_hex()
  }
  let mut instr = ""
  for i = 0; i < 3; i = i + 1 {
    instr += " " +
      (if i < size { self.read(self.pc + i, dummy~).to_hex() } else { "  " })
  }
  let mut spaces = ""
  for i = 32 - name.length() - addr_mode.length(); i > 0; i = i - 1 {
    spaces += " "
  }
  // let mut stack = ""
  // for i = 0x01FF; i > 0x01F8; i = i - 1 {
  //   if self.registers[SP] + 0x0100 == i {
  //     stack += "➛"
  //   } else {
  //     stack += " "
  //   }
  //   stack += self.mem[i].to_hex()
  // }
  println(
    self.pc.to_hex() +
    " " +
    instr +
    " " +
    unofficial +
    (match opcode._ {
      0xE3 | 0xE7 | 0xEF | 0xF3 | 0xF7 | 0xFB | 0xFF => "ISB"
      _ => name
    }) +
    addr_mode +
    spaces +
    "A:" +
    self.registers[A].to_hex() +
    " X:" +
    self.registers[X].to_hex() +
    " Y:" +
    self.registers[Y].to_hex() +
    " P:" +
    self.flags.get().to_hex() +
    " SP:" +
    self.registers[SP].to_hex(),
  )
  // + " P:" + self.flags.get().to_hex() + " " + self.flags.to_string(),
  // + " PPU:  _,  _" + " CYC:" + (self.cycles + _cycles).to_string(),
}

// page_boundary returns true if the two addresses reference different pages
///|
fn page_boundary(a : UInt16, b : UInt16) -> Bool {
  (a & 0xFF00) != (b & 0xFF00)
}

// branch, then adds a cycle for taking a branch and adds another cycle
// if the branch jumps to a new page
///|
fn branch(self : CPU, addr : UInt16) -> Unit {
  if page_boundary(self.pc, addr) {
    self.cycles += 1
  }
  self.pc = addr
  self.cycles += 1
}

///|
fn compare(self : CPU, a : UInt8, b : UInt8) -> Unit {
  self.flags.setZN(a - b)
  self.flags.setC(a >= b)
}

//
// Instructions
//

///| `ADC` - Add Memory to Accumulator with Carry
/// Operation: A + M + C → A, C
///
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
///
/// This instruction adds the value of memory and carry from the previous operation to the value of the accumulator and stores the result in the accumulator.
///
/// This instruction affects the accumulator;
/// The `C` flag is set when the sum of a binary addition exceeds `255` or when the sum of a decimal addition exceeds `99`, otherwise `C` is reset.
/// The `V` flag is set when the sign or bit `7` is changed due to the result exceeding `+127` or `-128`, otherwise `V` is reset.
/// The `N` flag is set if the accumulator result contains bit `7` on, otherwise the `N` flag is reset.
/// The `Z` flag is set if the accumulator result is `0`, otherwise the `Z` flag is reset.
///
/// Note on the MOS 6502:
/// In decimal mode, the `N`, `V` and `Z` flags are not consistent with the decimal result.
fn opADC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let a = self.registers[A]._
  let b = self.read(addr)._
  let c = self.flags[C].to_int()
  self.registers[A] = a + b + c
  if self.flags.decimal() && self.decimal_mode {
    let mut lo = (a & 0x0F) + (b & 0x0F) + c
    let mut hi = (a & 0xF0) + (b & 0xF0)
    if lo > 0x09 {
      lo += 0x06
    }
    if lo > 0x0F {
      hi += 0x10
    }
    self.flags.setZ(self.registers[A] == 0)
    self.flags.setN((hi & 0x80) != 0)
    self.flags.setV(((a ^ b) & 0x80) == 0 && ((hi ^ a) & 0x80) != 0)
    if hi > 0x90 {
      hi += 0x60
    }
    self.flags.setC(hi > 0xFF)
    self.registers[A] = hi | (lo & 0x0F)
  } else {
    self.flags.setC(a + b + c > 0xFF)
    self.flags.setV(
      ((a ^ b) & 0x80) == 0 && ((self.registers[A] ^ a) & 0x80) != 0,
    )
    self.flags.setZN(self.registers[A])
  }
}

///| `AND` - Memory with Accumulator
/// Operation: A ∧ M → A
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// The `AND` instruction transfers the accumulator and memory to the adder which performs a bit-by-bit `AND` operation and stores the result back in the accumulator.
///
/// This instruction affects the accumulator;
/// sets the `Z` flag if the result in the accumulator is `0`, otherwise resets the `Z` flag;
/// sets the `N` flag if the result in the accumulator has bit `7` on, otherwise resets the `N` flag.
fn opAND(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.registers[A] & self.read(addr)
  self.flags.setZN(self.registers[A])
}

///| `ASL` - Arithmetic Shift Left
/// Operation: C ← /M7...M0/ ← 0
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
///
/// This instruction shifts either the accumulator or the address memory location `1` bit to the left,
/// with the bit `0` always being set to `0` and the input bit `7` being stored in the `C` flag.
/// `ASL` either shifts the accumulator left `1` bit or is a read/modify/write instruction that affects only memory.
///
/// The instruction does not affect the `V` flag,
/// sets `N` equal to the result bit `7` (bit `6` in the input),
/// sets `Z` flag if the result is equal to `0`,
/// otherwise resets `Z` and stores the input bit `7` in the `C` flag.
fn opASL(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & NEGATIVE) != 0)
    self.registers[A] = self.registers[A] << 1 // overflow
    self.flags.setZN(self.registers[A])
  } else {
    let mut value = self.read(addr)
    self.flags.setC((value & NEGATIVE) != 0)
    value = value << 1 // overflow
    self.write(addr, value)
    self.flags.setZN(value)
  }
}

// BCC - Branch if carry clear
///|
fn opBCC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.not_carry() {
    self.branch(addr)
  }
}

// BCS - Branch if carry set
///|
fn opBCS(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.carry() {
    self.branch(addr)
  }
}

// BEQ - Branch if equal
///|
fn opBEQ(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.zero() {
    self.branch(addr)
  }
}

// BIT - Bit test
///|
fn opBIT(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let value = self.read(addr)
  self.flags.setV((value & OVERFLOW) != 0)
  self.flags.setZ((value & self.registers[A]) == 0)
  self.flags.setN(value.bit(7))
}

// BMI - Branch if minus
///|
fn opBMI(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.negative() {
    self.branch(addr)
  }
}

// BNE - Branch if minus
///|
fn opBNE(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.not_zero() {
    self.branch(addr)
  }
}

// BPL - Branch if positive
///|
fn opBPL(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.not_negative() {
    self.branch(addr)
  }
}

///| `BRK` - Break Command
/// Operation: PC + 2↓, [FFFE] → PCL, [FFFF] → PCH
///
/// p.297
/// Force break. S:= PCH, SP:= SP-1, S:= PCL, SP:= SP-1, S:= PSR, SP:= SP-1, PCL: = $FE, PCH: = $FF
///
/// Operation: `BRK` is a forced interrupt, which saves the current program counter and
/// status register values and jumps to a standard address. Note that the value saved for
/// the program counter points to the `BRK` byte plus two (like a branch) and that the
/// processor status register on the stack has flag `B` set to `1`.
///
/// The break command causes the microprocessor to go through an inter­rupt sequence under program control.
/// This means that the program counter of the second byte after the `BRK` is automatically stored on the stack along with the processor status at the beginning of the break instruction.
/// The microprocessor then transfers control to the interrupt vector.
///
/// Other than changing the program counter, the break instruction changes no values in either the registers or the flags.
///
/// Note on the MOS 6502:
/// If an IRQ happens at the same time as a `BRK` instruction, the `BRK` instruction is ignored.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#BRK
fn opBRK(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  // println("*** BRK")
  if self.irq {
    println("*** IRQ")
    return
  }

  //
  self.push16(self.pc + 1)
  self.push(self.flags.get() | BREAK | UNUSED)

  // self.pc = match self.needs_interrupt {
  //   NMI => self.read16(NMI)
  //   IRQ => self.read16(IRQ)
  //   _ => self.read16(IRQ)
  // }

  //
  // println("*** BRK: " + self.read16(IRQ, dummy=true).to_hex())
  self.flags.set_interrupt() // brkn
  self.flags.set_break()
  self.pc = self.read16(IRQ)

  // abort("BRK")
}

// BVC - Branch if overflow clear
///|
fn opBVC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.not_overflow() {
    self.branch(addr)
  }
}

// BVS - Branch if overflow set
///|
fn opBVS(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  if self.flags.overflow() {
    self.branch(addr)
  }
}

// CLC - Clear carry flag
///|
fn opCLC(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.clear_carry()
}

// CLD - Clear decimal mode
///|
fn opCLD(self : CPU, _ : UInt16, _mode : Mode) -> Unit {
  self.flags.clear_decimal()
}

// CLI - Clear interrupt disable
///|
fn opCLI(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.clear_interrupt()
}

// CLV - Clear overflow flag
///|
fn opCLV(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.clear_overflow()
}

// CMP - Compare
///|
fn opCMP(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.compare(self.registers[A], self.read(addr))
}

// CPX - Compare x register
///|
fn opCPX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.compare(self.registers[X], self.read(addr))
}

// CPY - Compare y register
///|
fn opCPY(self : CPU, addr : UInt16, _ : Mode) -> Unit {
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
///|
fn opDEC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let value = self.read(addr) - 1 // underflow
  self.write(addr, value)
  self.flags.setZN(value)
}

// DEX - Decrement x register
///|
fn opDEX(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[X] -= 1 // underflow
  self.flags.setZN(self.registers[X])
}

// DEY - Decrement y register
///|
fn opDEY(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[Y] -= 1 // underflow
  self.flags.setZN(self.registers[Y])
}

// EOR - Exclusive or
///|
fn opEOR(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.registers[A] ^ self.read(addr)
  self.flags.setZN(self.registers[A])
}

///| `INC` - Increment Memory By One
/// Operation: M + 1 → M
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// This instruction adds `1` to the contents of the addressed memory loca­tion.
///
/// The increment memory instruction does not affect any internal registers and does not affect the carry or overflow flags.
/// If bit `7` is on as the result of the increment, `N` is set, otherwise it is reset;
/// if the increment causes the result to become `0`, the `Z` flag is set on, otherwise it is reset.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#INC
fn opINC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let value = self.read(addr) + 1 // overflow
  self.write(addr, value)
  self.flags.setZN(value)
}

// INX - Increment x register
///|
fn opINX(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[X] += 1 // overflow
  self.flags.setZN(self.registers[X])
}

// INY - Increment y register
///|
fn opINY(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[Y] += 1 // overflow
  self.flags.setZN(self.registers[Y])
}

// JMP - Jump
///|
fn opJMP(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.pc = addr
}

// JSR - Jump to subroutine
///|
fn opJSR(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.push16(self.pc - 1)
  self.pc = addr
}

// LDA - Load accumulator
///|
fn opLDA(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.read(addr)
  self.flags.setZN(self.registers[A])
}

// LDX - Load x register
///|
fn opLDX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[X] = self.read(addr)
  self.flags.setZN(self.registers[X])
}

// LDY - Load y register
///|
fn opLDY(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[Y] = self.read(addr)
  self.flags.setZN(self.registers[Y])
}

// LSR - Logical shift right
///|
fn opLSR(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & CARRY) != 0)
    self.registers[A] = self.registers[A] >> 1 // underflow
    self.flags.setZN(self.registers[A])
  } else {
    let mut value = self.read(addr)
    self.flags.setC((value & CARRY) != 0)
    value = value >> 1 // underflow
    self.write(addr, value)
    self.flags.setZN(value)
  }
}

// NOP - No operation
///|
fn opNOP(_ : CPU, _ : UInt16, _ : Mode) -> Unit {
  //
}

// ORA - Logical inclusive or
///|
fn opORA(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.registers[A] | self.read(addr)
  self.flags.setZN(self.registers[A])
}

// PHA - Push accumulator
///|
fn opPHA(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.push(self.registers[A])
}

///| `PHP` - Push Processor Status On Stack
/// Operation: P↓
///
/// This instruction transfers the contents of the processor status reg­ister unchanged to the stack, as governed by the stack pointer.
///
/// The `PHP` instruction affects no registers or flags in the micropro­cessor.
fn opPHP(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.push(self.flags.get() | BREAK | UNUSED)
}

// PLA - Pull accumulator
///|
fn opPLA(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.pop()
  self.flags.setZN(self.registers[A])
}

///| `PLP` - Pull Processor Status From Stack
/// Operation: P↑
///
/// This instruction transfers the next value on the stack to the Proces­sor Status register, thereby changing all of the flags and setting the mode switches to the values from the stack.
///
/// The `PLP` instruction affects no registers in the processor other than the status register.
/// This instruction could affect all flags in the status register.
fn opPLP(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  // self.flags.set(self.pop()&(0xCF)|(UNUSED)|(BREAK)) // pull() & 0xEF | 0x20
  // self.flags.set((self.pop() & 0xEF) | UNUSED) |> ignore // nestest: pull() & 0xEF | 0x20
  self.flags.set(self.pop()) |> ignore
}

// ROL - Rotate left
///|
fn opROL(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  let c = self.flags[C].to_int()
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & NEGATIVE) != 0)
    self.registers[A] = (self.registers[A] << 1) | c // overflow
    self.flags.setZN(self.registers[A])
  } else {
    let mut value = self.read(addr)
    self.flags.setC((value & NEGATIVE) != 0)
    value = (value << 1) | c // overflow
    self.write(addr, value)
    self.flags.setZN(value)
  }
}

// ROR - Rotate right
///|
fn opROR(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  let c = self.flags[C].to_int()
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & CARRY) != 0)
    self.registers[A] = (self.registers[A] >> 1) | (c << 7) // underflow
    self.flags.setZN(self.registers[A])
  } else {
    let mut value = self.read(addr)
    self.flags.setC((value & CARRY) != 0)
    value = (value >> 1) | (c << 7) // underflow
    self.write(addr, value)
    self.flags.setZN(value)
  }
}

///| `RTI` - Return From Interrupt
/// Operation: P↑ PC↑
///
/// This instruction transfers the processor status from the stack into the microprocessor and the program counter location for the instruction which was interrupted.
/// By virtue of the interrupt having stored this data before executing the instruction and the fact that the `RTI` reinitializes the microprocessor to the same state as when it was interrupted, the combination of interrupt plus `RTI` allows truly reentrant coding.
///
/// The `RTI` instruction reinitializes all flags to the position to the point they were at the time the interrupt was taken and sets the program counter back to its pre-interrupt state.
/// It affects no other registers in the microprocessor.
fn opRTI(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  // println("*** RTI")

  // self.flags.set(self.pop()&(0xCF)|(UNUSED)|(BREAK)) // pull() & 0xEF | 0x20
  // self.flags.set((self.pop() & 0xEF) | UNUSED) // nestest: pull() & 0xEF | 0x20
  self.flags.set(self.pop() | UNUSED) |> ignore

  //
  self.pc = self.pop16()

  // self.opSEI(addr, mode)
}

// RTS - Return from subrouting
///|
fn opRTS(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.pc = self.pop16() + 1 // overflow
}

// SBC - Subtract with carry
///|
fn opSBC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let a = self.registers[A]._
  let b = self.read(addr)._
  let c = self.flags[C].to_int()
  self.registers[A] = a - b - (1 - c)
  self.flags.setC(a - b - (1 - c) >= 0)
  self.flags.setV(
    ((a ^ b) & 0x80) != 0 && ((a ^ self.registers[A]._) & 0x80) != 0,
  )
  self.flags.setZN(self.registers[A])
  if self.flags.decimal() && self.decimal_mode {
    let mut lo = (a & 0x0F) - (b & 0x0F) - (1 - c)
    let mut hi = (a & 0xF0) - (b & 0xF0)
    if (lo & 0x10) != 0 {
      lo -= 0x06
      hi -= 0x10
    }
    if (hi & 0x100) != 0 {
      hi -= 0x60
    }
    self.registers[A] = hi | (lo & 0x0F)
  }
}

// SEC - Set carry flag
///|
fn opSEC(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.set_carry()
}

// SED - Set decimal flag
///|
fn opSED(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.set_decimal()
}

///| `SEI` - Set Interrupt Disable
/// Operation: 1 → I
///
/// This instruction initializes the interrupt disable to a `1`.
/// It is used to mask interrupt requests during system reset operations and during interrupt commands.
///
/// It affects no registers in the microprocessor and no flags other than the interrupt disable which is set.
fn opSEI(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.flags.set_interrupt()
}

// STA - Store accumulator
///|
fn opSTA(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.write(addr, self.registers[A])
}

// STX - Store x register
///|
fn opSTX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.write(addr, self.registers[X])
}

// STY - Store y register
///|
fn opSTY(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  self.write(addr, self.registers[Y])
}

// TAX - Transfer accumulator to x
///|
fn opTAX(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[X] = self.registers[A]
  self.flags.setZN(self.registers[X])
}

// TAY - Transfer accumulator to y
///|
fn opTAY(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[Y] = self.registers[A]
  self.flags.setZN(self.registers[Y])
}

// TSX - Transfer stack pointer to x
///|
fn opTSX(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[X] = self.registers[SP]
  self.flags.setZN(self.registers[X])
}

// TXA - Transfer x to accumulator
///|
fn opTXA(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.registers[X]
  self.flags.setZN(self.registers[A])
}

///| `TXS` - Transfer Index `X` To Stack Pointer
/// Operation: X → S
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// This instruction transfers the value in the index register `X` to the stack pointer.
///
/// `TXS` changes only the stack pointer, making it equal to the content of the index register `X`.
/// It does not affect any of the flags.
fn opTXS(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[SP] = self.registers[X]
}

///| `TYA` - Transfer Index `Y` To Accumulator
/// Operation: Y → A
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// This instruction moves the value that is in the index register `Y` to accumulator `A` without disturbing the content of the register `Y`.
///
/// `TYA` does not affect any other register other than the accumula­tor and does not affect the `C` or `V` flag.
/// If the result in the accumulator `A` has bit `7` on, the `N` flag is set, otherwise it is reset.
/// If the resulting value in the accumulator `A` is `0`, then the `Z` flag is set, otherwise it is reset.
fn opTYA(self : CPU, _ : UInt16, _ : Mode) -> Unit {
  self.registers[A] = self.registers[Y]
  self.flags.setZN(self.registers[A])
}

//
// Illegal opcodes
//
// https://www.nesdev.org/wiki/CPU_unofficial_opcodes
// https://www.nesdev.org/wiki/Programming_with_unofficial_opcodes
//

///|
// fn opAHX(_ : CPU, _ : UInt16, _ : Mode) -> Unit {
//   println("unimplemented: AHX")
//   abort("unimplemented: AHX")
// }

///| `ASR` - `AND` then Logical Shift Right
/// Operation: (A ∧ M) / 2 → A
///
/// N	V	-	B	D	I	Z	C
/// 0	-	-	-	-	-	✓	✓
///
/// The undocumented `ASR` instruction performs a bit-by-bit `AND` operation of the accumulator and memory, then shifts the accumulator 1 bit to the right, with the higher bit of the result always being set to 0, and the low bit which is shifted out of the field being stored in the carry flag.
///
/// This instruction affects the accumulator.
/// It does not affect the overflow flag.
/// The `N` flag is always reset.
/// The `Z` flag is set if the result of the shift is 0 and reset otherwise.
/// The carry is set equal to bit 0 of the result of the `AND` operation.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#ASR
fn opALR(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  self.opAND(addr, mode)
  self.opLSR(addr, Mode::Accumulator)

  // println("unimplemented: ALR")
  // abort("unimplemented: ALR")
}

///| `ANC` - `"AND"` Memory with Accumulator then Move Negative Flag to Carry Flag
/// Operation: A ∧ M → A, N → C
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
///
/// The undocumented `ANC` instruction performs a bit-by-bit `AND` operation of the accumulator and memory and stores the result back in the accumulator.
///
/// This instruction affects the accumulator;
///
/// sets the zero flag if the result in the accumulator is `0`,
/// otherwise resets the zero flag;
///
/// sets the negative flag and the carry flag if the result in the accumulator has bit `7` on,
/// otherwise resets the negative flag and the carry flag.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#ANC
fn opANC(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let tmp = self.registers[A] & self.read(addr)

  //
  self.registers[A] = tmp
  self.flags.setZN(tmp)
  self.flags.setC(tmp.bit(7))

  // println("unimplemented: ANC")
  // abort("unimplemented: ANC")
}

///| `ARR` - `AND` Accumulator then Rotate Right
/// Operation: (A ∧ M) / 2 → A
///
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
///
/// The undocumented `ARR` instruction performs a bit-by-bit `AND` operation of the accumulator and memory, 
/// then shifts the result right 1 bit with bit 0 shifted into the carry and carry shifted into bit 7.
/// It then stores the result back in the accumulator.
///
/// If bit 7 of the result is on, then the `N` flag is set, otherwise it is reset.
/// The instruction sets the `Z` flag if the result is 0;  otherwise it resets `Z`.
///
/// The `V` and `C` flags depend on the Decimal Mode Flag:
/// In decimal mode, the `V` flag is set if bit 6 is different than the original data's bit 6, otherwise the `V` flag is reset.
///   The `C` flag is set if (operand & 0xF0) + (operand & 0x10) is greater than 0x50, otherwise the `C` flag is reset.
/// In binary mode, the `V` flag is set if bit 6 of the result is different than bit 5 of the result, otherwise the `V` flag is reset.
///   The `C` flag is set if the result in the accumulator has bit 6 on, otherwise it is reset.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#ARR
fn opARR(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // https://github.com/davidhorrocks/hoxs64/blob/master/hoxs64/C6502.cpp#L774
  let t = self.registers[A] & self.read(addr)
  let mut a = (t >> 1) | (self.flags.carry().to_int() << 7)
  // println(
  //   "\t{\{self.cycles}} ARR A#$\{self.registers[A].to_hex()} & #$\{self.read(addr, dummy=true).to_hex()} = #$" +
  //   t.to_hex() +
  //   " / 2 = #$" +
  //   a.to_hex() +
  //   " C:\{self.flags.carry().to_int()}|\{a.bit(6).to_int()}" +
  //   " N:\{self.flags.negative().to_int()}|\{a.bit(7).to_int()}" +
  //   " V:\{self.flags.overflow().to_int()}|\{(a.bitn(6) ^ a.bitn(5)).to_int()}" +
  //   " Z:\{self.flags.zero().to_int()}|\{(a == 0).to_int()}" +
  //   " D:\{self.flags.decimal().to_int()}",
  // )

  //
  if self.flags.decimal() && self.decimal_mode {
    let ah = t >> 4
    let al = t & 0x0F
    self.flags.setN(self.flags.carry())
    self.flags.setZ(a == 0)
    self.flags.setV((t ^ a).bit(6))
    if al + (al & 1) > 5 {
      a = (a & 0xF0) | ((a + 0x06) & 0x0F)
    }
    if ah + (ah & 1) > 5 {
      a = (a & 0x0F) | ((a + 0x60) & 0xF0)
      self.flags.set_carry()
    } else {
      self.flags.clear_carry()
    }
  } else {
    self.flags.setN(self.flags.carry())
    self.flags.setZ(a == 0)
    self.flags.setC(a.bit(6)) // 0x40
    self.flags.setV((a.bitn(6) ^ a.bitn(5)) != 0)
  }
  self.registers[A] = a

  // println("unimplemented: ARR")
  // abort("unimplemented: ARR")
}

///|
// fn opAXS(_ : CPU, _ : UInt16, _ : Mode) -> Unit {
//   println("unimplemented: AXS")
//   abort("unimplemented: AXS")
// }

///| `SBX` - Subtract Memory from Accumulator `"AND"` Index Register `X`
/// Operation: (A ∧ X) - M → X
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
///
/// This undocumented instruction performs a bit-by-bit `"AND"` of the value of the accumulator and the index register `X` and subtracts the value of memory from this result,
/// using two's complement arithmetic, and stores the result in the index register `X`.
///
/// This instruction affects the index register `X`.
/// The `C` flag is set if the result is greater than or equal to `0`.
/// The `C` flag is reset when the result is less than `0`, indicating a borrow.
/// The `N` flag is set if the result in index register `X` has bit `7` on, otherwise it is reset.
/// The `Z` flag is set if the result in index register `X` is `0`, otherwise it is reset.
/// The `V` flag not affected at all.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#SBX
fn opSBX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // println(
  //   "SBX A#$" +
  //   self.registers[A].to_hex() +
  //   " X#$" +
  //   self.registers[X].to_hex() +
  //   " - #$" +
  //   self.read(addr).to_hex() +
  //   " = #$" +
  //   (self.registers[A] & self.registers[X]).to_hex() +
  //   " = #$" +
  //   ((self.registers[A] & self.registers[X]) - self.read(addr)).to_hex(),
  // )
  let tmp = (self.registers[A] & self.registers[X]) - self.read(addr) // underflow
  self.flags.setC(not(tmp.is_neg()))
  self.registers[X] = tmp
  self.flags.setZN(tmp)

  // println("unimplemented: SBX")
  // abort("unimplemented: SBX")
}

///|
fn opDCP(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to DEC value then CMP value, except supporting more addressing modes.
  // LDA #$FF followed by DCP can be used to check if the decrement underflows, which is useful for multi-byte decrements.
  self.opDEC(addr, mode)
  self.opCMP(addr, mode)
}

///|
fn opISC(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to INC value then SBC value, except supporting more addressing modes.
  self.opINC(addr, mode)
  self.opSBC(addr, mode)
}

///|
fn opJAM(_ : CPU, _ : UInt16, _ : Mode) -> Unit {
  println("unimplemented: JAM")
  abort("unimplemented: JAM")
}

///| `LAS` - `"AND"` Memory with Stack Pointer
/// Operation: M ∧ S → A, X, S
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// This undocumented instruction performs a bit-by-bit `"AND"` operation of the stack pointer and memory and stores the result back in the accumulator,
/// the index register `X` and the stack pointer.
///
/// The `LAS` instruction does not affect the carry or overflow flags.
/// It sets `N` if the bit `7` of the result is on, otherwise it is reset.
/// If the result is zero, then the `Z` flag is set, otherwise it is reset.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#LAS
fn opLAS(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let tmp = self.registers[SP] & self.read(addr)

  //
  self.registers[X] = tmp
  self.registers[A] = tmp
  self.flags.setZN(tmp)

  //
  self.registers[SP] = tmp

  // println("unimplemented: LAS")
  // abort("unimplemented: LAS")
}

///| `LAX` - Load Accumulator and Index Register `X` From Memory
/// Operation: M → A, X
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// The undocumented `LAX` instruction loads the accumulator and the index register `X` from memory.
///
/// `LAX` does not affect the `C` or `V` flags;
/// sets `Z` if the value loaded was zero, otherwise resets it;
/// sets `N` if the value loaded in bit `7` is a `1`;
/// otherwise `N` is reset, and affects only the `X` register.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#LAX
fn opLAX(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  let magic = 0xEE // https://sourceforge.net/p/vice-emu/code/HEAD/tree/testprogs/CPU/lax/

  //
  let tmp = match mode {
    Immediate => (self.registers[A] | magic) & self.read(addr) & self.read(addr)
    _ => self.read(addr)
  }

  //
  self.registers[X] = tmp
  self.registers[A] = tmp
  self.flags.setZN(tmp)
}

///|
fn opRLA(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to ROL value then AND value, except supporting more addressing modes.
  // LDA #$FF followed by RLA is an efficient way to rotate a variable while also loading it in A.
  self.opROL(addr, mode)
  self.opAND(addr, mode)
}

///|
fn opRRA(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to ROR value then ADC value, except supporting more addressing modes.
  // Essentially this computes A + value / 2, where value is 9-bit and the division is rounded up.
  self.opROR(addr, mode)
  self.opADC(addr, mode)
}

///|
fn opSAX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // Stores the bitwise AND of A and X. As with STA and STX, no flags are affected.
  self.write(addr, self.registers[A] & self.registers[X])
}

///| `SHA` - Store Accumulator `"AND"` Index Register `X` `"AND"` Value
/// Operation: A ∧ X ∧ V → M
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// The undocumented `SHA` instruction performs a bit-by-bit `AND` operation of the following three operands:
/// The first two are the accumulator and the index register `X`.
///
/// The third operand depends on the addressing mode.
/// In the zero page indirect Y-indexed case, the third operand is the data in memory at the given zero page address (ignoring the addressing mode's Y offset) plus 1.
/// In the Y-indexed absolute case, it is the upper 8 bits of the given address (ignoring the addressing mode's Y offset), plus 1.
///
/// It then transfers the result to the addressed memory location.
///
/// No flags or registers in the microprocessor are affected by the store operation.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#SHA
fn opSHA(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // https://sourceforge.net/p/vice-emu/code/HEAD/tree/testprogs/CPU/sha/
  // println(
  //   "SHA A#$" +
  //   self.registers[A].to_hex() +
  //   " X#$" +
  //   self.registers[X].to_hex() +
  //   " Y#$" +
  //   self.registers[Y].to_hex() +
  //   " $" +
  //   addr.to_hex() +
  //   " \{mode}",
  // )

  let tmp = self.registers[A] &
    self.registers[X] &
    (match mode {
      AbsoluteY => (addr >> 8).to_int() + 1 |> u8 // overflow
      IndirectIndexed => (addr >> 8).to_int() + 1 |> u8 // overflow

      ///
      _ => {
        println("unimplemented: SHA \{mode}")
        abort("unimplemented: SHA \{mode}")
      }
    })
  self.write(addr, tmp)
}

///| `SHX` - Store Index Register `X` `"AND"` Value
/// Operation: X ∧ (H + 1) → M
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// The undocumented `SHX` instruction performs a bit-by-bit `AND` operation of the index register `X` and the upper 8 bits of the given address (ignoring the addressing mode's Y offset), plus 1.
/// It then transfers the result to the addressed memory location.
///
/// No flags or registers in the microprocessor are affected by the store operation.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#SHX
fn opSHX(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // println("SHX X#$" + self.registers[X].to_hex() + " $" + addr.to_hex())

  let tmp = self.registers[X] & u8((addr >> 8).to_int() + 1) // overflow
  self.write(addr, tmp)

  // println("unimplemented: SHX")
  // abort("unimplemented: SHX")
}

///| `SHY` - Store Index Register `Y` `"AND"` Value
/// Operation: Y ∧ (H + 1) → M
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// The undocumented `SHY` instruction performs a bit-by-bit `AND` operation of the index register `Y` and the upper 8 bits of the given address (ignoring the addressing mode's X offset), plus 1.
/// It then transfers the result to the addressed memory location.
///
/// No flags or registers in the microprocessor are affected by the store operation.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#SHY
fn opSHY(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // println("SHY X#$" + self.registers[Y].to_hex() + " $" + addr.to_hex())

  let tmp = self.registers[Y] & u8((addr >> 8).to_int() + 1) // overflow
  self.write(addr, tmp)

  // println("unimplemented: SHY")
  // abort("unimplemented: SHY")
}

///|
fn opSLO(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to ASL value then ORA value, except supporting more addressing modes.
  // LDA #0 followed by SLO is an efficient way to shift a variable while also loading it in A.
  self.opASL(addr, mode)
  self.opORA(addr, mode)
}

///|
fn opSRE(self : CPU, addr : UInt16, mode : Mode) -> Unit {
  // Equivalent to LSR value then EOR value, except supporting more addressing modes.
  // LDA #0 followed by SRE is an efficient way to shift a variable while also loading it in A.
  self.opLSR(addr, mode)
  self.opEOR(addr, mode)
}

///| `SHS` - Transfer Accumulator `"AND"` Index Register `X` to Stack Pointer then Store Stack Pointer `"AND"` Hi-Byte In Memory
/// Operation: A ∧ X → S, S ∧ (H + 1) → M
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// The undocumented `SHS` instruction performs a bit-by-bit `AND` operation of the value of the accumulator and the value of the index register `X` and stores the result in the stack pointer.
/// It then performs a bit-by-bit `AND` operation of the resulting stack pointer and the upper 8 bits of the given address (ignoring the addressing mode's `Y` offset), plus 1,
/// and transfers the result to the addressed memory location.
///
/// No flags or registers in the microprocessor are affected by the store operation.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#SHS
fn opSHS(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  // println(
  //   "SHS A#$" +
  //   self.registers[A].to_hex() +
  //   " X#$" +
  //   self.registers[X].to_hex() +
  //   " $" +
  //   addr.to_hex(),
  // )

  let tmp = self.registers[A] & self.registers[X] & u8((addr >> 8).to_int() + 1) // overflow
  self.write(addr, tmp)

  //
  self.registers[SP] = self.registers[A] & self.registers[X]

  // println("unimplemented: SHS")
  // abort("unimplemented: SHS")
}

///|
// fn opTAS(_ : CPU, _ : UInt16, _ : Mode) -> Unit {
//   println("unimplemented: TAS")
//   abort("unimplemented: TAS")
// }

///| `XAA` - Non-deterministic Operation of Accumulator, Index Register `X`, Memory and Bus Contents
/// Operation: (A ∨ V) ∧ X ∧ M → A
///
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
///
/// The operation of the undocumented `XAA` instruction depends on the individual microprocessor.
/// On most machines, it performs a bit-by-bit `AND` operation of the following three operands:
/// The first two are the index register `X` and memory.
/// The third operand is the result of a bit-by-bit `AND` operation of the accumulator and a magic component.
/// This magic component depends on the individual microprocessor and is usually one of `$00`, `$EE`, `$EF`, `$FE` and `$FF`, and may be influenced by the `RDY` pin, leftover contents of the data bus, the temperature of the microprocessor, the supplied voltage, and other factors.
///
/// On some machines, additional bits of the result may be set or reset depending on non-deterministic factors.
///
/// It then transfers the result to the accumulator.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#XAA
fn opXAA(self : CPU, addr : UInt16, _ : Mode) -> Unit {
  let magic = 0xEF // https://sourceforge.net/p/vice-emu/code/HEAD/tree/testprogs/CPU/ane/

  //
  let tmp = (self.registers[A] | magic) & self.registers[X] & self.read(addr)

  //
  self.registers[A] = tmp
  self.flags.setZN(tmp)
}

///|
priv enum Mode {
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
} derive(Eq, Show)

///|
let instructions : FixedArray[
  (String, (CPU, UInt16, Mode) -> Unit, Mode, Int, Int, Int, Bool),
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
  ("ANC", opANC, Immediate, 2, 2, 0, true),
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
  ("ANC", opANC, Immediate, 2, 2, 0, true),
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
  ("ALR", opALR, Immediate, 2, 2, 0, true),
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
  ("ARR", opARR, Immediate, 2, 2, 0, true),
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
  ("NOP", opNOP, Immediate, 2, 2, 0, true),
  ("SAX", opSAX, IndexedIndirect, 2, 6, 0, true),
  ("STY", opSTY, ZeroPage, 2, 3, 0, false),
  ("STA", opSTA, ZeroPage, 2, 3, 0, false),
  ("STX", opSTX, ZeroPage, 2, 3, 0, false),
  ("SAX", opSAX, ZeroPage, 2, 3, 0, true),
  ("DEY", opDEY, Implied, 1, 2, 0, false),
  ("NOP", opNOP, Immediate, 2, 2, 0, true),
  ("TXA", opTXA, Implied, 1, 2, 0, false),
  ("XAA", opXAA, Immediate, 2, 2, 0, true), // FIXME: ANE
  ("STY", opSTY, Absolute, 3, 4, 0, false),
  ("STA", opSTA, Absolute, 3, 4, 0, false),
  ("STX", opSTX, Absolute, 3, 4, 0, false),
  ("SAX", opSAX, Absolute, 3, 4, 0, true),
  // 0x90
  ("BCC", opBCC, Relative, 2, 2, 1, false),
  ("STA", opSTA, IndirectIndexed, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 0, 2, 0, true),
  ("SHA", opSHA, IndirectIndexed, 2, 6, 0, true), // AHX
  ("STY", opSTY, ZeroPageX, 2, 4, 0, false),
  ("STA", opSTA, ZeroPageX, 2, 4, 0, false),
  ("STX", opSTX, ZeroPageY, 2, 4, 0, false),
  ("SAX", opSAX, ZeroPageY, 2, 4, 0, true),
  ("TYA", opTYA, Implied, 1, 2, 0, false),
  ("STA", opSTA, AbsoluteY, 3, 5, 0, false),
  ("TXS", opTXS, Implied, 1, 2, 0, false),
  ("SHS", opSHS, AbsoluteY, 3, 5, 0, true), // TAS
  ("SHY", opSHY, AbsoluteX, 3, 5, 0, true),
  ("STA", opSTA, AbsoluteX, 3, 5, 0, false),
  ("SHX", opSHX, AbsoluteY, 3, 5, 0, true),
  ("SHA", opSHA, AbsoluteY, 3, 5, 0, true), // AHX
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
  ("LAX", opLAX, Immediate, 2, 2, 0, true),
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
  ("LAS", opLAS, AbsoluteY, 3, 4, 1, true),
  ("LDY", opLDY, AbsoluteX, 3, 4, 1, false),
  ("LDA", opLDA, AbsoluteX, 3, 4, 1, false),
  ("LDX", opLDX, AbsoluteY, 3, 4, 1, false),
  ("LAX", opLAX, AbsoluteY, 3, 4, 1, true),
  // 0xC0
  ("CPY", opCPY, Immediate, 2, 2, 0, false),
  ("CMP", opCMP, IndexedIndirect, 2, 6, 0, false),
  ("NOP", opNOP, Immediate, 2, 2, 0, true),
  ("DCP", opDCP, IndexedIndirect, 2, 8, 0, true),
  ("CPY", opCPY, ZeroPage, 2, 3, 0, false),
  ("CMP", opCMP, ZeroPage, 2, 3, 0, false),
  ("DEC", opDEC, ZeroPage, 2, 5, 0, false),
  ("DCP", opDCP, ZeroPage, 2, 5, 0, true),
  ("INY", opINY, Implied, 1, 2, 0, false),
  ("CMP", opCMP, Immediate, 2, 2, 0, false),
  ("DEX", opDEX, Implied, 1, 2, 0, false),
  ("SBX", opSBX, Immediate, 2, 2, 0, true), // AXS
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
  ("NOP", opNOP, Immediate, 2, 2, 0, true),
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

///|
priv enum Instruction {
  // LDA
  LDA_IM // 0xA9
  // LDA_ZP // 0xA5
  // LDA_ZPX // 0xB5
  // LDA_ABS // 0xAD
  // LDA_ABSX // 0xBD
  // LDA_ABSY // 0xB9
  // LDA_INDX // 0xA1
  // LDA_INDY // 0xB1

  // // LDX
  // LDX_IM // 0xA2
  // LDX_ZP // 0xA6
  // LDX_ZPY // 0xB6
  // LDX_ABS // 0xAE
  // LDX_ABSY // 0xBE

  // // LDY
  // LDY_IM // 0xA0
  // LDY_ZP // 0xA4
  // LDY_ZPX // 0xB4
  // LDY_ABS // 0xAC
  // LDY_ABSX // 0xBC

  // // STA
  // STA_ZP // 0x85
  // STA_ZPX // 0x95
  // STA_ABS // 0x8D
  // STA_ABSX // 0x9D
  // STA_ABSY // 0x99
  // STA_INDX // 0x81
  // STA_INDY // 0x91

  // // STX
  // STX_ZP // 0x86
  // STX_ZPY // 0x96
  // STX_ABS // 0x8E

  // // STY
  // STY_ZP // 0x84
  // STY_ZPX // 0x94
  // STY_ABS // 0x8C
  // TSX // 0xBA
  // TXS // 0x9A
  // PHA // 0x48
  // PLA // 0x68
  // PHP // 0x08
  // PLP // 0x28
  JMP_ABS // 0x4C
  JMP_IND // 0x6C
  JSR // 0x20
  RTS // 0x60

  // //
  // // Logical Operations
  // //

  // // AND
  // AND_IM // 0x29
  // AND_ZP // 0x25
  // AND_ZPX // 0x35
  // AND_ABS // 0x2D
  // AND_ABSX // 0x3D
  // AND_ABSY // 0x39
  // AND_INDX // 0x21
  // AND_INDY // 0x31

  // // OR
  // ORA_IM // 0x09
  // ORA_ZP // 0x05
  // ORA_ZPX // 0x15
  // ORA_ABS // 0x0D
  // ORA_ABSX // 0x1D
  // ORA_ABSY // 0x19
  // ORA_INDX // 0x01
  // ORA_INDY // 0x11

  // // EOR
  // EOR_IM // 0x49
  // EOR_ZP // 0x45
  // EOR_ZPX // 0x55
  // EOR_ABS // 0x4D
  // EOR_ABSX // 0x5D
  // EOR_ABSY // 0x59
  // EOR_INDX // 0x41
  // EOR_INDY // 0x51

  // // BIT
  // BIT_ZP // 0x24
  // BIT_ABS // 0x2C

  // //
  // // Transfer Registers
  // //
  // TAX // 0xAA
  // TAY // 0xA8
  // TXA // 0x8A
  // TYA // 0x98

  // //
  // // Increments
  // // Decrements
  // //
  // INX // 0xE8
  // INY // 0xC8
  // DEY // 0x88
  // DEX // 0xCA
  // DEC_ZP // 0xC6
  // DEC_ZPX // 0xD6
  // DEC_ABS // 0xCE
  // DEC_ABSX // 0xDE
  // INC_ZP // 0xE6
  // INC_ZPX // 0xF6
  // INC_ABS // 0xEE
  // INC_ABSX // 0xFE

  // Branches
  BEQ // 0xF0
  BNE // 0xD0
  BCS // 0xB0
  BCC // 0x90
  BMI // 0x30
  BPL // 0x10
  BVC // 0x50
  BVS // 0x70

  // // Status Flag Changes
  // CLC // 0x18
  // SEC // 0x38
  // CLD // 0xD8
  // SED // 0xF8
  // CLI // 0x58
  // SEI // 0x78
  // CLV // 0xB8

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

  // // Shifts
  // ASL // 0x0A
  // ASL_ZP // 0x06
  // ASL_ZPX // 0x16
  // ASL_ABS // 0x0E
  // ASL_ABSX // 0x1E
  // LSR // 0x4A
  // LSR_ZP // 0x46
  // LSR_ZPX // 0x56
  // LSR_ABS // 0x4E
  // LSR_ABSX // 0x5E
  // ROL // 0x2A
  // ROL_ZP // 0x26
  // ROL_ZPX // 0x36
  // ROL_ABS // 0x2E
  // ROL_ABSX // 0x3E
  // ROR // 0x6A
  // ROR_ZP // 0x66
  // ROR_ZPX // 0x76
  // ROR_ABS // 0x6E
  // ROR_ABSX // 0x7E

  // // Miscellaneous
  // NOP // 0xEA
  // BRK // 0x00
  // RTI // 0x40
}

// fn op_get(self : Instruction, instruction : Instruction) -> UInt8 {
//   get_opcode(instruction)
// }

///|
fn Instruction::to_int(self : Instruction) -> Int {
  get_opcode(self)._
}

///|
fn get_opcode(instruction : Instruction) -> UInt8 {
  match instruction {
    // LDA
    LDA_IM => 0xA9
    // LDA_ZP => 0xA5
    // LDA_ZPX => 0xB5
    // LDA_ABS => 0xAD
    // LDA_ABSX => 0xBD
    // LDA_ABSY => 0xB9
    // LDA_INDX => 0xA1
    // LDA_INDY => 0xB1

    // // LDX
    // LDX_IM => 0xA2
    // LDX_ZP => 0xA6
    // LDX_ZPY => 0xB6
    // LDX_ABS => 0xAE
    // LDX_ABSY => 0xBE

    // // LDY
    // LDY_IM => 0xA0
    // LDY_ZP => 0xA4
    // LDY_ZPX => 0xB4
    // LDY_ABS => 0xAC
    // LDY_ABSX => 0xBC

    // // STA
    // STA_ZP => 0x85
    // STA_ZPX => 0x95
    // STA_ABS => 0x8D
    // STA_ABSX => 0x9D
    // STA_ABSY => 0x99
    // STA_INDX => 0x81
    // STA_INDY => 0x91

    // // STX
    // STX_ZP => 0x86
    // STX_ZPY => 0x96
    // STX_ABS => 0x8E

    // // STY
    // STY_ZP => 0x84
    // STY_ZPX => 0x94
    // STY_ABS => 0x8C
    // TSX => 0xBA
    // TXS => 0x9A
    // PHA => 0x48
    // PLA => 0x68
    // PHP => 0x08
    // PLP => 0x28
    JMP_ABS => 0x4C
    JMP_IND => 0x6C
    JSR => 0x20
    RTS => 0x60

    // //
    // // Logical Operations
    // //

    // // AND
    // AND_IM => 0x29
    // AND_ZP => 0x25
    // AND_ZPX => 0x35
    // AND_ABS => 0x2D
    // AND_ABSX => 0x3D
    // AND_ABSY => 0x39
    // AND_INDX => 0x21
    // AND_INDY => 0x31

    // // OR
    // ORA_IM => 0x09
    // ORA_ZP => 0x05
    // ORA_ZPX => 0x15
    // ORA_ABS => 0x0D
    // ORA_ABSX => 0x1D
    // ORA_ABSY => 0x19
    // ORA_INDX => 0x01
    // ORA_INDY => 0x11

    // // EOR
    // EOR_IM => 0x49
    // EOR_ZP => 0x45
    // EOR_ZPX => 0x55
    // EOR_ABS => 0x4D
    // EOR_ABSX => 0x5D
    // EOR_ABSY => 0x59
    // EOR_INDX => 0x41
    // EOR_INDY => 0x51

    // // BIT
    // BIT_ZP => 0x24
    // BIT_ABS => 0x2C

    // //
    // // Transfer Registers
    // //
    // TAX => 0xAA
    // TAY => 0xA8
    // TXA => 0x8A
    // TYA => 0x98

    // //
    // // Increments
    // // Decrements
    // //
    // INX => 0xE8
    // INY => 0xC8
    // DEY => 0x88
    // DEX => 0xCA
    // DEC_ZP => 0xC6
    // DEC_ZPX => 0xD6
    // DEC_ABS => 0xCE
    // DEC_ABSX => 0xDE
    // INC_ZP => 0xE6
    // INC_ZPX => 0xF6
    // INC_ABS => 0xEE
    // INC_ABSX => 0xFE

    // Branches
    BEQ => 0xF0
    BNE => 0xD0
    BCS => 0xB0
    BCC => 0x90
    BMI => 0x30
    BPL => 0x10
    BVC => 0x50
    BVS => 0x70

    // // Status Flag Changes
    // CLC => 0x18
    // SEC => 0x38
    // CLD => 0xD8
    // SED => 0xF8
    // CLI => 0x58
    // SEI => 0x78
    // CLV => 0xB8

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

    // // Shifts
    // ASL => 0x0A
    // ASL_ZP => 0x06
    // ASL_ZPX => 0x16
    // ASL_ABS => 0x0E
    // ASL_ABSX => 0x1E
    // LSR => 0x4A
    // LSR_ZP => 0x46
    // LSR_ZPX => 0x56
    // LSR_ABS => 0x4E
    // LSR_ABSX => 0x5E
    // ROL => 0x2A
    // ROL_ZP => 0x26
    // ROL_ZPX => 0x36
    // ROL_ABS => 0x2E
    // ROL_ABSX => 0x3E
    // ROR => 0x6A
    // ROR_ZP => 0x66
    // ROR_ZPX => 0x76
    // ROR_ABS => 0x6E
    // ROR_ABSX => 0x7E

    // // Miscellaneous
    // NOP => 0xEA
    // BRK => 0x00
    // RTI => 0x40
  }
}

///|
fn CPU::op_get(self : CPU, address : Int) -> Int {
  self.read(address, dummy=true)._
}

///|
fn CPU::op_set(self : CPU, address : Int, value : Int) -> Unit {
  self.write(address, value, dummy=true)
}
