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
  registers~ : Registers = Registers::new(),
  flags~ : Flags = Flags::new(),
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
) -> CPU! {
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
    cpu.load!(address.or(pc), data, length~, offset~) |> ignore
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
  length~ : Int = data.length(),
  offset~ : Int = 0,
  //
  has_load_address~ : Bool = false
) -> UInt16! {
  if length > @core.UINT16_SIZE {
    fail!("data too large")
  }
  // if self.debug {
  //   println(
  //     "CPU::load $" + u16(offset).to_hex() + " - $" + u16(length).to_hex(),
  //   )
  // }
  let address = if has_load_address {
    u16(data[0]) | // lo
    (u16(data[1]) << 8) // hi
  } else {
    address
  }
  let start = if has_load_address { 2 } else { offset }
  for i = 0; i < length - start; i = i + 1 {
    self.write(address + i, u8(data[i + start]), dummy=true)
  }
  address
}

///|
fn read_instruction(self : CPU, prefetch~ : Bool = false) -> UInt8 {
  let value = self.read(self.pc)
  if not(prefetch) {
    self.pc += 1
  }
  value
}

///|
fn read_instruction_word(self : CPU) -> UInt16 {
  self.read_instruction()._ | (self.read_instruction()._ << 8) |> u16
}

///|
fn read_zeropage(self : CPU, offset : UInt8) -> UInt8 {
  self.read_address(offset._)
}

///|
fn read_zeropage_word(self : CPU, offset : UInt8) -> UInt16 {
  self.read_address(offset._)._ | (self.read_address((offset + 1)._)._ << 8)
  |> u16
}

///|
fn read_zeropage_address_word(self : CPU, address : UInt16) -> UInt16 {
  u16(self.read(address)) | // lo
  (u16(self.read(((address + 1) & 0x00FF) | (address & 0xFF00))) << 8) // hi
}

///|
fn read_address(self : CPU, address : UInt16) -> UInt8 {
  self.read(address)
}

///|
fn read_address_word(self : CPU, address : UInt16) -> UInt16 {
  self.read(address)._ | (self.read(address + 1)._ << 8) |> u16
}

///|
pub fn read(self : CPU, address : UInt16, dummy~ : Bool = false) -> UInt8 {
  (match self.read {
    Some(read) => read(address, dummy)
    None => self.mem[address._]
  })
  |> u8
}

///|
pub fn read16(self : CPU, address : UInt16, dummy~ : Bool = false) -> UInt16 {
  // println(
  //   "$" + U16::u16(address).to_hex() + " → " + self.mem[address + 1].to_hex() + self.mem[address].to_hex(),
  // )
  u16(self.read(address, dummy~)) | // lo
  (u16(self.read(address + 1, dummy~)) << 8) // hi
}

///|
fn read16zp(self : CPU, address : UInt16, dummy~ : Bool = false) -> UInt16 {
  // println(
  //   ("read16zp $" + address.to_hex() + ":#$" + self.read(address).to_hex() + " $" + (address +
  //   1)&(0x00FF)) | (address&(0xFF00).to_hex() + ":#$" + self.read(
  //     (address + 1)&(0x00FF) | address&(0xFF00),
  //   ).to_hex()),
  // )
  u16(self.read(address, dummy~)) | // lo
  (u16(self.read(((address + 1) & 0x00FF) | (address & 0xFF00), dummy~)) << 8) // hi
}

///|
pub fn write(
  self : CPU,
  address : UInt16,
  value : UInt8,
  dummy~ : Bool = false
) -> Unit {
  match self.write {
    Some(write) => write(address, value, dummy)
    None => self.mem[address._] = value
  }
  // println("$" + u16(address).to_hex() + " ← " + self.mem[address].to_hex())
}

///|
pub fn write16(
  self : CPU,
  address : UInt16,
  value : UInt16,
  dummy~ : Bool = false
) -> Unit {
  self.write(address + 1, u8(value._ >> 8), dummy~) // hi
  self.write(address, u8(value._), dummy~) // lo
  // println(
  //   "$" + u16(address).to_hex() + " ← " + self.mem[address + 1].to_hex() + self.mem[address].to_hex(),
  // )
}

///|
pub fn push(self : CPU, value : UInt8, dummy~ : Bool = false) -> Unit {
  self.write(u16(self.registers[SP]) | 0x0100, value, dummy~)
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
  self.read(u16(self.registers[SP]) | 0x0100, dummy~)
}

///|
fn pop16(self : CPU) -> UInt16 {
  u16(self.pop()) | // lo 
  (u16(self.pop()) << 8) // hi
}

///|
pub fn dump(
  self : CPU,
  address~ : UInt16 = 0x0000,
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
      str = (address + i).to_hex() + "|"
    }
    str += self.mem[(address + i)._].to_hex() + " "
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
    // let opcode = self.read(self.pc, dummy=true)._
    let opcode = self.read_instruction()._

    //
    let (name, op, mode, size, cycles, _, illegal) = instructions[opcode]
    if self.debug {
      self.dump_step(opcode, name, mode, size, cycles, illegal)
    }

    //
    match name {
      "ADC"
      | "ANC"
      | "AND"
      | "ARR"
      | "ASL"
      | "ASR"
      | "BCC"
      | "BCS"
      | "BEQ"
      | "BIT"
      | "BMI"
      | "BNE"
      | "BPL"
      | "BRK"
      | "BVC"
      | "BVS"
      | "CLC"
      | "CLD"
      | "CLI"
      | "CLV"
      | "CMP"
      | "CPX"
      | "CPY"
      | "DCP"
      | "DEC"
      | "DEX"
      | "DEY"
      | "EOR"
      | "INC"
      | "INX"
      | "INY"
      | "ISC"
      | "JAM"
      | "JMP"
      | "JSR"
      | "LAS"
      | "LAX"
      | "LDA"
      | "LDX"
      | "LDY"
      | "LSR"
      | "NOP"
      | "ORA"
      | "PHA"
      | "PHP"
      | "PLA"
      | "PLP"
      | "RLA"
      | "ROL"
      | "ROR"
      | "RRA"
      | "RTI"
      | "RTS"
      | "SAX"
      | "SBC"
      | "SBX"
      | "SEC"
      | "SED"
      | "SEI"
      | "SHA"
      | "SHS"
      | "SHX"
      | "SHY"
      | "SLO"
      | "SRE"
      | "STA"
      | "STX"
      | "STY"
      | "TAX"
      | "TAY"
      | "TSX"
      | "TXA"
      | "TXS"
      | "TYA"
      | "XAA" => op(self, -1, mode)
      _ => {
        println("\{name} missing")
        panic()
      }
    }

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
fn get_address(
  self : CPU,
  mode : Mode,
  illegal : Bool,
  dummy~ : Bool = true
) -> UInt16 {
  let pc = self.pc + 1 |> u16
  match mode {
    ///| Implied
    /// In the implied addressing mode, the address containing the operand is implicitly stated in the operation code of the instruction.
    Implied => {
      let _ = self.read(pc, dummy=true) // FIXME: pre-fetch
      0 |> u16
    }
    ///| Accumulator  A
    /// This form of addressing is represented with a one byte instruction, implying an operation on the accumulator.
    Accumulator => {
      let _ = self.read(pc, dummy=true) // FIXME: pre-fetch
      0 |> u16
    }
    Immediate => pc |> u16
    Indirect => self.read16zp(self.read16(pc, dummy~), dummy~) |> u16
    ///| X-Indexed Zero Page Indirect ($nn,X)
    /// In indexed indirect addressing, the second byte of the instruction is added to the contents of the `X` index register, discarding the carry. 
    /// The result of this addition points to a memory location on page zero whose contents is the low order eight bits of the effective address.
    /// The next memory location in page zero contains the high order eight bits of the effective address.
    /// Both memory locations specifying the high and low order bytes of the effective address must be in page zero.
    IndexedIndirect => {
      let offset = self.read(pc, dummy~)
      let _ = self.read(u16(offset), dummy=true) // FIXME: pre-fetch
      self.read16zp(u16(offset + self.registers[X]), dummy~) |> u16
    }
    ///| Zero Page Indirect Y-Indexed ($nn),Y
    /// In indirect indexed addressing, the second byte of the instruction points to a memory location in page zero.
    /// The contents of this memory location is added to the contents of the `Y` index register, the result being the low order eight bits of the effective address.
    /// The carry from this addition is added to the contents of the next page zero memory location, the result being the high order eight bits of the effective address.
    IndirectIndexed => {
      let offset = self.read(pc, dummy~)
      let value = self.read16zp(u16(offset), dummy~)
      // 0x13 does not care about page boundary
      if page_boundary(value, value + u16(self.registers[Y])) {
        // FIXME: pre-fetch
        let _ = self.read(
          (value & 0xFF00) | u16(u8(value) + self.registers[Y]),
          dummy=true,
        )
        if not(illegal) {
          self.cycles += 1
        }
      }
      value + u16(self.registers[Y]) |> u16
    }
    ///| Absolute $nnnn
    /// In absolute addressing, the second byte of the instruction specifies the eight low order bits of the effective address while the third byte specifies the eight high order bits.
    /// Thus, the absolute addressing mode allows access to the entire 65K bytes of addressable memory.
    Absolute | AbsoluteSP => {
      let value = self.read16(pc, dummy~)
      value |> u16
    }
    ///| X-Indexed Absolute $nnnn,X
    /// This form of addressing is used in conjunction with the `X` index register.
    /// The effective address is formed by adding the contents of `X` to the address contained in the second and third bytes of the instruction.
    /// This mode allows the index register to contain the index or count value and the instruction to contain the base address.
    /// This type of indexing allows any location referencing and the index to modify multiple fields resulting in reduced coding and execution time.
    AbsoluteX => {
      let value = self.read16(pc, dummy~)
      // println("\{value} + \{self.registers[X]} = \{value + u16(self.registers[X])} \{page_boundary(value, value + u16(self.registers[X]))}")
      // 0x1e always needs this
      if page_boundary(value, value + u16(self.registers[X])) {
        // FIXME: pre-fetch
        let _ = self.read(
          (value & 0xFF00) | u16(u8(value) + self.registers[X]),
          dummy=true,
        )
        self.cycles += 1
      }
      value + u16(self.registers[X]) |> u16
    }
    ///| Y-Indexed Absolute $nnnn,Y
    /// This form of addressing is used in conjunction with the `Y` index register.
    /// The effective address is formed by adding the contents of `Y` to the address contained in the second and third bytes of the instruction.
    /// This mode allows the index register to contain the index or count value and the instruction to contain the base address.
    /// This type of indexing allows any location referencing and the index to modify multiple fields resulting in reduced coding and execution time.
    AbsoluteY => { // 0x99
      let value = self.read16(pc, dummy~)
      // 0x19 needs this
      // 0x1b* does not need this
      if illegal || page_boundary(value, value + u16(self.registers[Y])) {
        // FIXME: pre-fetch
        let _ = self.read(
          (value & 0xFF00) | u16(u8(value) + self.registers[Y]),
          dummy=true,
        )
        self.cycles += 1
      }
      value + u16(self.registers[Y]) |> u16
    }
    ///| Zero Page  $nn
    /// The zero page instructions allow for shorter code and execution times by only fetching the second byte of the instruction and assuming a zero high address byte.
    /// Careful use of the zero page can result in significant increase in code efficiency.
    ZeroPage => {
      let offset = self.read(pc, dummy~)
      // 0x04* needs this
      // 0x05 does not need this, uses the value in the opcode
      // if illegal {
      //   // FIXME: pre-fetch
      //   let _ = self.read(u16(offset), dummy=true)

      // }
      offset |> u16
    }
    ///| X-Indexed Zero Page  $nn,X
    /// This form of addressing is used in conjunction with the `X` index register.
    /// The effective address is calculated by adding the second byte to the contents of the index register.
    /// Since this is a form of "Zero Page" addressing, the content of the second byte references a location in page zero.
    /// Additionally, due to the “Zero Page" addressing nature of this mode, no carry is added to the high order 8 bits of memory and crossing of page boundaries does not occur.
    ZeroPageX => {
      let offset = self.read(pc, dummy~)
      let _ = self.read(u16(offset), dummy=true) // FIXME: pre-fetch
      offset + self.registers[X] |> u16
    }
    ///| Y-Indexed Zero Page  $nn,Y
    /// This form of addressing is used in conjunction with the `Y` index register.
    /// The effective address is calculated by adding the second byte to the contents of the index register.
    /// Since this is a form of "Zero Page" addressing, the content of the second byte references a location in page zero.
    /// Additionally, due to the “Zero Page" addressing nature of this mode, no carry is added to the high order 8 bits of memory and crossing of page boundaries does not occur.
    ZeroPageY => {
      let offset = self.read(pc, dummy~)
      let _ = self.read(u16(offset), dummy=true) // FIXME: pre-fetch
      offset + self.registers[Y] |> u16
    }
    ///| Relative $nnnn
    /// Relative addressing is used only with branch instructions and establishes a destination for the conditional branch.
    ///
    /// The second byte of the instruction becomes the operand which is an “Offset" added to the contents of the lower eight bits of the program counter when the counter is set at the next instruction.
    /// The range of the offset is `-128` to `+127` bytes from the next instruction.
    Relative => {
      let offset = self.read(pc, dummy~).to_signed()
      // println(offset)
      // if offset > 0x7F {
      //   let _ = self.read(pc + 1, dummy=true) // FIXME: pre-fetch
      // }
      pc + 1 + offset |> u16
    }
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
  let pc = self.pc |> u16
  let read8 = fn() { "$" + self.read(pc, dummy~).to_hex() }
  let read16 = fn() {
    "$" + self.read(pc + 1, dummy~).to_hex() + self.read(pc, dummy~).to_hex()
  }
  let unofficial = if illegal { "*" } else { " " }
  let address_mode = match mode {
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
      .read16zp(u16(self.read(pc, dummy~) + self.registers[X]), dummy~)
      .to_hex() +
      " = " +
      self
      .read(
        self.read16zp(u16(self.read(pc, dummy~) + self.registers[X]), dummy~),
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
      self.read16zp(u16(self.read(pc, dummy~)), dummy~).to_hex() +
      " @ " +
      (self.read16zp(u16(self.read(pc, dummy~)), dummy~) +
      u16(self.registers[Y])).to_hex() +
      " = " +
      self
      .read(
        self.read16zp(u16(self.read(pc, dummy~)), dummy~) +
        u16(self.registers[Y]),
        dummy~,
      )
      .to_hex()
    Absolute | AbsoluteSP =>
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
      (self.read16(pc, dummy~) + u16(self.registers[X])).to_hex() +
      " = " +
      self
      .read(self.read16(pc, dummy~) + u16(self.registers[X]), dummy~)
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
  let mut instruction = ""
  for i = 0; i < 3; i = i + 1 {
    instruction += " " +
      (if i < size { self.read(pc - 1 + i, dummy~).to_hex() } else { "  " })
  }
  let mut spaces = ""
  for i = 31 - name.length() - address_mode.length(); i > 0; i = i - 1 {
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
    "\{pc-1}" +
    " " +
    instruction +
    " " +
    unofficial +
    (match opcode._ {
      0xE3 | 0xE7 | 0xEF | 0xF3 | 0xF7 | 0xFB | 0xFF => "ISB"
      _ => name
    }) +
    address_mode +
    spaces +
    " A:" +
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
fn branch(
  self : CPU,
  address : UInt16,
  prefetch : (UInt16, UInt8)?,
  wrap : Bool?
) -> Unit {
  self.read_instruction() |> ignore

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1 // page is crossed
  }

  //
  self.pc = address
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
/// https://www.pagetable.com/c64ref/6502/?tab=2#ADC
fn opADC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    ADC #$nn	      $69	    2	    2
  /// Absolute	                    ADC $nnnn	      $6D	    3	    4
  /// X-Indexed Absolute	          ADC $nnnn,X	    $7D	    3	    4+p
  /// Y-Indexed Absolute	          ADC $nnnn,Y	    $79	    3	    4+p
  /// Zero Page	                    ADC $nn	        $65	    2	    3
  /// X-Indexed Zero Page	          ADC $nn,X	      $75	    2	    4
  /// X-Indexed Zero Page Indirect	ADC ($nn,X)	    $61	    2	    6
  /// Zero Page Indirect Y-Indexed	ADC ($nn),Y	    $71	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  let a = self.registers[A].to_int()
  let b = value.to_int()
  let c = self.flags[C].to_int()

  //
  self.adc(a, b, c)
}

///|
fn adc(self : CPU, a : Int, b : Int, c : Int) -> Unit {
  self.registers[A] = a + b + c

  //
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
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#AND
fn opAND(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    AND #$nn	      $29	    2	    2
  /// Absolute	                    AND $nnnn	      $2D	    3	    4
  /// X-Indexed Absolute	          AND $nnnn,X	    $3D	    3	    4+p
  /// Y-Indexed Absolute	          AND $nnnn,Y	    $39	    3	    4+p
  /// Zero Page	                    AND $nn	        $25	    2	    3
  /// X-Indexed Zero Page	          AND $nn,X	      $35	    2	    4
  /// X-Indexed Zero Page Indirect	AND ($nn,X)	    $21	    2	    6
  /// Zero Page Indirect Y-Indexed	AND ($nn),Y	    $31	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.registers[A] = self.registers[A] & value
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
fn opASL(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Accumulator	                  ASL A	          $0A	    1	    2
  /// Absolute	                    ASL $nnnn	      $0E	    3	    6
  /// X-Indexed Absolute	          ASL $nnnn,X	    $1E	    3	    7
  /// Zero Page	                    ASL $nn	        $06	    2	    5
  /// X-Indexed Zero Page	          ASL $nn,X	      $16	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, _) = prefetch.unwrap()

  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if mode is AbsoluteX {
      value = self.read_address(address) // |> ignore
    }
  }

  //
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & NEGATIVE) != 0)
    self.registers[A] = self.registers[A] << 1 // overflow
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch
    self.flags.setC((value & NEGATIVE) != 0)
    value = value << 1 // overflow
    self.write(address, value)
    self.flags.setZN(value)
  }
}

///| `ASR` - "AND" then Logical Shift Right
/// Operation: (A ∧ M) / 2 → A
/// 
/// N	V	-	B	D	I	Z	C
/// 0	-	-	-	-	-	✓	✓
/// 
/// The undocumented `ASR` instruction performs a bit-by-bit `AND` operation of the accumulator and memory, then shifts the accumulator `1` bit to the right, with the higher bit of the result always being set to `0`, and the low bit which is shifted out of the field being stored in the carry flag.
/// 
/// This instruction affects the accumulator. 
/// It does not affect the overflow flag. 
/// The `N` flag is always reset. 
/// The `Z` flag is set if the result of the shift is `0` and reset otherwise. 
/// The carry is set equal to bit `0` of the result of the "AND" operation.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#ASR
fn opASR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    ASR #$nn	      $4B*	  2	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (_, data) = prefetch.unwrap()
    value = data
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if mode is AbsoluteX {
      value = self.read_address(address) // |> ignore
    }
  }

  // self.opAND(address, mode)
  self.registers[A] = self.registers[A] & value
  self.flags.setZN(self.registers[A])

  // self.opLSR(address, Mode::Accumulator)
  self.flags.setC(self.registers[A].bit(0))
  self.registers[A] = self.registers[A] >> 1 // underflow
  self.flags.setZN(self.registers[A])
}

///| `BCC` - Branch on Carry Clear
/// Operation: Branch on C = 0
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction tests the state of the carry bit and takes a conditional branch if the carry bit is reset.
/// 
/// It affects no flags or registers other than the program counter and then only if the `C` flag is not on.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BCC
fn opBCC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BCC $nnnn	      $90	    2	    2+t+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if self.flags.not_carry() {
    self.branch(address, prefetch, wrap)
  }
}

///| `BCS` - Branch on Carry Set
/// Operation: Branch on C = 1
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction takes the conditional branch if the carry flag is on.
/// 
/// `BCS` does not affect any of the flags or registers except for the program counter and only then if the carry flag is on.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BCS
fn opBCS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BCS $nnnn	      $B0	    2	    2+t+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if self.flags.carry() {
    self.branch(address, prefetch, wrap)
  }
}

///| `BEQ` - Branch on Result Zero
/// Operation: Branch on Z = 1
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction could also be called "Branch on Equal."
/// 
/// It takes a conditional branch whenever the `Z` flag is on or the previous result is equal to `0`.
/// 
/// `BEQ` does not affect any of the flags or registers other than the program counter and only then when the `Z` flag is set.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BEQ
fn opBEQ(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BEQ $nnnn	      $F0	    2	    2+t+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if self.flags.zero() {
    self.branch(address, prefetch, wrap)
  }
}

///| `BIT` - Test Bits in Memory with Accumulator
/// Operation: A ∧ M, M7 → N, M6 → V
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	-
/// 
/// This instruction performs an `AND` between a memory location and the accumulator but does not store the result of the `AND` into the accumulator.
/// 
/// The bit instruction affects the `N` flag with `N` being set to the value of bit `7` of the memory being tested, 
/// the `V` flag with `V` being set equal to bit `6` of the memory being tested and 
/// `Z` being set by the result of the `AND` operation between the accumulator and the memory if the result is zero, `Z` is reset otherwise. 
/// It does not affect the accumulator.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BIT
fn opBIT(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    BIT $nnnn	      $2C	    3	    4
  /// Zero Page	                    BIT $nn	        $24	    2	    3

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let value = self.read(address)
  self.flags.setV((value & OVERFLOW) != 0)
  self.flags.setZ((value & self.registers[A]) == 0)
  self.flags.setN(value.bit(7))
}

///| `BMI` - Branch on Result Minus
/// Operation: Branch on N = 1
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction takes the conditional branch if the `N` bit is set.
/// 
/// `BMI` does not affect any of the flags or any other part of the machine other than the program counter and then only if the `N` bit is on.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BMI
fn opBMI(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BMI $nnnn	      $30	    2 	  2+t+p

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  if self.flags.negative() {
    self.branch(address, value, wrap)
  }
}

///| `BNE` - Branch on Result Not Zero
/// Operation: Branch on Z = 0
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction could also be called "Branch on Not Equal." 
/// It tests the `Z` flag and takes the conditional branch if the `Z` flag is not on, indicating that the previous result was not zero.
/// 
/// `BNE` does not affect any of the flags or registers other than the program counter and only then if the `Z` flag is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BNE
fn opBNE(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BNE $nnnn	      $D0	    2	    2+t+p

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  if self.flags.not_zero() {
    self.branch(address, value, wrap)
  }
}

///| `BPL` - Branch on Result Plus
/// Operation: Branch on N = 0
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction is the complementary branch to branch on result minus. 
/// It is a conditional branch which takes the branch when the `N` bit is reset (`0`). 
/// `BPL` is used to test if the previous result bit `7` was off (`0`) and branch on result minus is used to determine if the previous result was minus or bit `7` was on (`1`).
/// 
/// The instruction affects no flags or other registers other than the `P` counter and only affects the `P` counter when the `N` bit is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BPL
fn opBPL(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BPL $nnnn	      $10	    2	    2+t+p

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  if self.flags.not_negative() {
    self.branch(address, value, wrap)
  }
}

///| `BRK` - Break Command
/// Operation: PC + 2↓, [FFFE] → PCL, [FFFF] → PCH
///
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	1	-	-
/// 
/// The break command causes the microprocessor to go through an inter­rupt sequence under program control.
/// This means that the program counter of the second byte after the `BRK` is automatically stored on the stack along with the processor status at the beginning of the break instruction.
/// The microprocessor then transfers control to the interrupt vector.
///
/// Other than changing the program counter, the break instruction changes no values in either the registers or the flags.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#BRK
fn opBRK(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      BRK	            $00	    1	    7

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if self.irq {
    println("*** IRQ")
    return
  }

  //
  self.push16(self.pc + 1)
  self.push(self.flags.get().set(UNUSED | BREAK))

  //
  self.flags.set_interrupt() // brkn
  // self.flags.set_break() // benchmark does not like it

  //
  self.pc = self.read16(IRQ)
}

///| `BVC` - Branch on Overflow Clear
/// Operation: Branch on V = 0
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction tests the status of the `V` flag and takes the conditional branch if the flag is not set.
/// 
/// `BVC` does not affect any of the flags and registers other than the program counter and only when the overflow flag is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BVC
fn opBVC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BVC $nnnn	      $50	    2	    2+t+p

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  if self.flags.not_overflow() {
    self.branch(address, value, wrap)
  }
}

///| `BVS` - Branch on Overflow Set
/// Operation: Branch on V = 1
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction tests the `V` flag and takes the conditional branch if `V` is on.
/// 
/// `BVS` does not affect any flags or registers other than the program, counter and only when the overflow flag is set.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#BVS
fn opBVS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Relative	                    BVS $nnnn	      $70	    2	    2+t+p

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  if self.flags.overflow() {
    self.branch(address, value, wrap)
  }
}

///| `CLC` - Clear Carry Flag
/// Operation: 0 → C
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	0
/// 
/// This instruction initializes the carry flag to a `0`. 
/// This operation should normally precede an `ADC` loop. 
/// It is also useful when used with a `ROL` instruction to clear a bit in memory.
/// 
/// This instruction affects no registers in the microprocessor and no flags other than the carry flag which is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CLC
fn opCLC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      CLC	            $18	    1	    2

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  self.flags.clear_carry()
}

///| `CLD` - Clear Decimal Mode
/// Operation: 0 → D
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	0	-	-	-
/// 
/// This instruction sets the decimal mode flag to a `0`. 
/// This all subsequent `ADC` and `SBC` instructions to operate as simple operations.
/// 
/// `CLD` affects no registers in the microprocessor and no flags other than the decimal mode flag which is set to a `0`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CLD
fn opCLD(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      CLD	            $D8	    1	    2

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  self.flags.clear_decimal()
}

///| `CLI` - Clear Interrupt Disable
/// Operation: 0 → I
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	0	-	-
/// 
/// This instruction initializes the interrupt disable to a `0`. 
/// This allows the microprocessor to receive interrupts.
/// 
/// It affects no registers in the microprocessor and no flags other than the interrupt disable which is cleared.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CLI
fn opCLI(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      CLI	            $58	    1	    2

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  self.flags.clear_interrupt()
}

///| `CLV` - Clear Overflow Flag
/// Operation: 0 → V
/// 
/// N	V	-	B	D	I	Z	C
/// -	0	-	-	-	-	-	-
/// 
/// This instruction clears the overflow flag to a `0`. 
/// This command is used in conjunction with the set overflow pin which can change the state of the overflow flag with an external signal.
/// 
/// `CLV` affects no registers in the microprocessor and no flags other than the overflow flag which is set to a `0`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CLV
fn opCLV(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      CLV	            $B8	    1	    2

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  self.flags.clear_overflow()
}

///| `CMP` - Compare Memory and Accumulator
/// Operation: A - M
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// This instruction subtracts the contents of memory from the contents of the accumulator.
/// 
/// The use of the `CMP` affects the following flags: 
/// `Z` flag is set on an equal comparison, reset otherwise; 
/// the `N` flag is set or reset by the result bit `7`, 
/// the carry flag is set when the value in memory is less than or equal to the accumulator, reset when it is greater than the accumulator. 
/// The accumulator is not affected.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CMP
fn opCMP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    CMP #$nn	      $C9	    2	    2
  /// Absolute	                    CMP $nnnn	      $CD	    3	    4
  /// X-Indexed Absolute	          CMP $nnnn,X	    $DD	    3	    4+p
  /// Y-Indexed Absolute	          CMP $nnnn,Y	    $D9	    3	    4+p
  /// Zero Page	                    CMP $nn	        $C5	    2	    3
  /// X-Indexed Zero Page	          CMP $nn,X	      $D5	    2	    4
  /// X-Indexed Zero Page Indirect	CMP ($nn,X)	    $C1	    2	    6
  /// Zero Page Indirect Y-Indexed	CMP ($nn),Y	    $D1	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.compare(self.registers[A], value)
}

///| `CPX` - Compare Index Register `X` To Memory
/// Operation: X - M
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// This instruction subtracts the value of the addressed memory location from the content of index register `X` using the adder but does not store the result; 
/// therefore, its only use is to set the `N`, `Z` and `C` flags to allow for comparison between the index register `X` and the value in memory.
/// 
/// The `CPX` instruction does not affect any register in the machine; 
/// it also does not affect the overflow flag. 
/// It causes the carry to be set on if the absolute value of the index register `X` is equal to or greater than the data from memory. 
/// If the value of the memory is greater than the content of the index register `X`, carry is reset. 
/// If the results of the subtraction contain a bit `7`, then the `N` flag is set, if not, it is reset. 
/// If the value in memory is equal to the value in index register `X`, the `Z` flag is set, otherwise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CPX
fn opCPX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    CPX #$nn	      $E0	    2	    2
  /// Absolute	                    CPX $nnnn	      $EC	    3	    4
  /// Zero Page	                    CPX $nn	        $E4	    2	    3

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.compare(self.registers[X], value)
}

///| `CPY` - Compare Index Register `Y` To Memory
/// Operation: Y - M
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// This instruction performs a two's complement subtraction between the index register `Y` and the specified memory location. 
/// The results of the subtraction are not stored anywhere. 
/// The instruction is strictly used to set the flags.
/// 
/// `CPY` affects no registers in the microprocessor and also does not affect the overflow flag. 
/// If the value in the index register `Y` is equal to or greater than the value in the memory, the carry flag will be set, otherwise it will be cleared. 
/// If the results of the subtraction contain bit `7` on the `N` bit will be set, otherwise it will be cleared. 
/// If the value in the index register `Y` and the value in the memory are equal, the zero flag will be set, otherwise it will be cleared.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#CPY
fn opCPY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    CPY #$nn	      $C0	    2	    2
  /// Absolute	                    CPY $nnnn	      $CC	    3	    4
  /// Zero Page	                    CPY $nn	        $C4	    2	    3

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.compare(self.registers[Y], value)
}

///| `DEC` - Decrement Memory By One
/// Operation: M - 1 → M
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction subtracts `1`, in two's complement, from the contents of the addressed memory location.
/// 
/// The decrement instruction does not affect any internal register in the microprocessor.
/// It does not affect the carry or overflow flags. 
/// If bit `7` is on as a result of the decrement, then the `N` flag is set, otherwise it is reset. 
/// If the result of the decrement is `0`, the `Z` flag is set, other­wise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#DEC
fn opDEC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    DEC $nnnn	      $CE	    3	    6
  /// X-Indexed Absolute	          DEC $nnnn,X	    $DE	    3	    7
  /// Zero Page	                    DEC $nn	        $C6	    2	    5
  /// X-Indexed Zero Page	          DEC $nn,X	      $D6	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore
    value = self.read_address(address) // |> ignore
  }

  //
  self.write(address, value, dummy=true) // FIXME: pre-fetch
  value -= 1 // underflow
  self.write(address, value)
  self.flags.setZN(value)
}

///| `DEX` - Decrement Index Register `X` By One
/// Operation: X - 1 → X
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction subtracts one from the current value of the index register `X` and stores the result in the index register `X`.
/// 
/// `DEX` does not affect the carry or overflow flag, 
/// it sets the `N` flag if it has bit `7` on as a result of the decrement, otherwise it resets the `N` flag; 
/// sets the `Z` flag if `X` is a `0` as a result of the decrement, otherwise it resets the `Z` flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#DEX
fn opDEX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      DEX	            $CA	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.registers[X] -= 1 // underflow
  self.flags.setZN(self.registers[X])
}

///| `DEY` - Decrement Index Register `Y` By One
/// Operation: Y - 1 → Y
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction subtracts one from the current value in the index register `Y` and stores the result into the index register `Y`. 
/// The result does not affect or consider carry so that the value in the index register `Y` is decremented to `0` and then through `$00` to `$FF`.
/// 
/// Decrement `Y` does not affect the carry or overflow flags; 
/// if the `Y` register contains bit `7` on as a result of the decrement the `N` flag is set, otherwise the `N` flag is reset. 
/// If the `Y` register is `0` as a result of the decrement, the `Z` flag is set otherwise the `Z` flag is reset. 
/// This instruction only affects the index register `Y`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#DEY
fn opDEY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      DEY	            $88	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.registers[Y] -= 1 // underflow
  self.flags.setZN(self.registers[Y])
}

///| `EOR` - "Exclusive OR" Memory with Accumulator
/// Operation: A ⊻ M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// The `EOR` instruction transfers the memory and the accumulator to the adder which performs a binary "EXCLUSIVE OR" on a bit-by-bit basis and stores the result in the accumulator.
/// 
/// This instruction affects the accumulator; 
/// sets the zero flag if the result in the accumulator is `0`, otherwise resets the zero flag 
/// sets the negative flag if the result in the accumulator has bit `7` on, otherwise resets the negative flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#EOR
fn opEOR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    EOR #$nn	      $49	    2	    2
  /// Absolute	                    EOR $nnnn	      $4D	    3	    4
  /// X-Indexed Absolute	          EOR $nnnn,X	    $5D	    3	    4+p
  /// Y-Indexed Absolute	          EOR $nnnn,Y	    $59	    3	    4+p
  /// Zero Page	                    EOR $nn	        $45	    2	    3
  /// X-Indexed Zero Page	          EOR $nn,X	      $55	    2	    4
  /// X-Indexed Zero Page Indirect	EOR ($nn,X)	    $41	    2	    6
  /// Zero Page Indirect Y-Indexed	EOR ($nn),Y	    $51	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.registers[A] = self.registers[A] ^ value
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
fn opINC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    INC $nnnn	      $EE	    3	    6
  /// X-Indexed Absolute	          INC $nnnn,X	    $FE	    3	    7
  /// Zero Page	                    INC $nn	        $E6	    2	    5
  /// X-Indexed Zero Page	          INC $nn,X	      $F6	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore
    value = self.read_address(address) // |> ignore
  }

  // 
  self.write(address, value, dummy=true) // FIXME: pre-fetch
  value += 1 // overflow
  self.write(address, value)
  self.flags.setZN(value)
}

///| `INX` - Increment Index Register `X` By One
/// Operation: X + 1 → X
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// Increment `X` adds `1` to the current value of the `X` register. 
/// This is an 8-bit increment which does not affect the carry operation, 
/// therefore, if the value of `X` before the increment was `$FF`, the resulting value is `$00`.
/// 
/// `INX` does not affect the carry or overflow flags; 
/// it sets the `N` flag if the result of the increment has a one in bit `7`, otherwise resets `N`; 
/// sets the `Z` flag if the result of the increment is `0`, otherwise it resets the `Z` flag.
/// 
/// `INX` does not affect any other register other than the `X` register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#INX
fn opINX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      INX	            $E8	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.registers[X] += 1 // overflow
  self.flags.setZN(self.registers[X])
}

///| `INY` - Increment Index Register `Y` By One
/// Operation: Y + 1 → Y
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// Increment `Y` increments or adds one to the current value in the `Y` register, storing the result in the `Y` register. 
/// As in the case of `INX` the primary application is to step thru a set of values using the `Y` register.
/// 
/// The `INY` does not affect the carry or overflow flags, 
/// sets the `N` flag if the result of the increment has a one in bit `7`, otherwise resets `N`, 
/// sets `Z` if as a result of the increment the `Y` register is zero otherwise resets the `Z` flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#INY
fn opINY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      INY	            $C8	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.registers[Y] += 1 // overflow
  self.flags.setZN(self.registers[Y])
}

///| `JMP` - Jump Indirect
/// Operation: [PC + 1] → PCL, [PC + 2] → PCH
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction establishes a new value for the program counter.
/// 
/// It affects only the program counter in the microprocessor and affects no flags in the status register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#JMP
fn opJMP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    JMP $nnnn	      $4C	    3	    3
  /// Absolute Indirect	            JMP ($nnnn)	    $6C	    3	    5

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.pc = address
}

///| `JSR` - Jump To Subroutine
/// Operation: PC + 2↓, [PC + 1] → PCL, [PC + 2] → PCH
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction transfers control of the program counter to a subroutine location but leaves a return pointer on the stack to allow the user to return to perform the next instruction in the main program after the subroutine is complete. 
/// To accomplish this, `JSR` instruction stores the program counter address which points to the last byte of the jump instruction onto the stack using the stack pointer. 
/// The stack byte contains the program count high first, followed by program count low. 
/// The `JSR` then transfers the addresses following the jump instruction to the program counter low and the program counter high, thereby directing the program to begin at that new address.
/// 
/// The `JSR` instruction affects no flags, causes the stack pointer to be decremented by `2` and substitutes new values into the program counter low and the program counter high.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#JSR
fn opJSR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    JSR $nnnn	      $20	    3	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.read(u16(self.registers[SP]) | 0x0100, dummy=true) |> ignore
  self.push16(self.pc)

  //
  let offset = self.read_instruction()

  //
  self.pc = address | (offset._ << 8)
}

///| `LDA` - Load Accumulator with Memory
/// Operation: M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// When instruction `LDA` is executed by the microprocessor, data is transferred from memory to the accumulator and stored in the accumulator.
/// 
/// `LDA` affects the contents of the accumulator, does not affect the carry or overflow flags; 
/// sets the zero flag if the accumulator is zero as a result of the `LDA`, otherwise resets the zero flag; 
/// sets the negative flag if bit `7` of the accumulator is set, other­wise resets the negative flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#LDA
fn opLDA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    LDA #$nn	      $A9	    2	    2
  /// Absolute	                    LDA $nnnn	      $AD	    3	    4
  /// X-Indexed Absolute	          LDA $nnnn,X	    $BD	    3	    4+p
  /// Y-Indexed Absolute	          LDA $nnnn,Y	    $B9	    3	    4+p
  /// Zero Page	                    LDA $nn	        $A5	    2	    3
  /// X-Indexed Zero Page	          LDA $nn,X	      $B5	    2	    4
  /// X-Indexed Zero Page Indirect	LDA ($nn,X)	    $A1	    2	    6
  /// Zero Page Indirect Y-Indexed	LDA ($nn),Y	    $B1	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1
  }

  //
  let value = if mode is Immediate {
    let (_, value) = prefetch.unwrap()
    value
  } else {
    self.read_address(address)
  }

  //
  self.registers[A] = value
  self.flags.setZN(value)
}

///| `LDX` - Load Index Register `X` From Memory
/// Operation: M → X
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// Load the index register `X` from memory.
/// 
/// `LDX` does not affect the `C` or `V` flags; 
/// sets `Z` if the value loaded was zero, otherwise resets it; 
/// sets `N` if the value loaded in bit `7` is a `1`; 
/// otherwise `N` is reset, and affects only the `X` register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#LDX
fn opLDX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    LDX #$nn	      $A2	    2	    2
  /// Absolute	                    LDX $nnnn	      $AE	    3	    4
  /// Y-Indexed Absolute	          LDX $nnnn,Y	    $BE	    3	    4+p
  /// Zero Page	                    LDX $nn	        $A6	    2	    3
  /// Y-Indexed Zero Page	          LDX $nn,Y	      $B6	    2	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1
  }

  //
  let value = if mode is Immediate {
    let (_, value) = prefetch.unwrap()
    value
  } else {
    self.read_address(address)
  }

  //
  self.registers[X] = value
  self.flags.setZN(value)
}

///| `LDY` - Load Index Register `Y` From Memory
/// Operation: M → Y
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// Load the index register `Y` from memory.
/// 
/// `LDY` does not affect the `C` or `V` flags, 
/// sets the `N` flag if the value loaded in bit `7` is a `1`, otherwise resets `N`, 
/// sets `Z` flag if the loaded value is zero otherwise resets `Z` 
/// and only affects the `Y` register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#LDY
fn opLDY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    LDY #$nn	      $A0	    2	    2
  /// Absolute	                    LDY $nnnn	      $AC	    3	    4
  /// X-Indexed Absolute	          LDY $nnnn,X	    $BC	    3	    4+p
  /// Zero Page	                    LDY $nn	        $A4	    2	    3
  /// X-Indexed Zero Page	          LDY $nn,X	      $B4	    2	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1
  }

  //
  let value = if mode is Immediate {
    let (_, value) = prefetch.unwrap()
    value
  } else {
    self.read_address(address)
  }

  //
  self.registers[Y] = value
  self.flags.setZN(value)
}

///| `LSR` - Logical Shift Right
/// Operation: 0 → /M7...M0/ → C
/// 
/// N	V	-	B	D	I	Z	C
/// 0	-	-	-	-	-	✓	✓
/// 
/// This instruction shifts either the accumulator or a specified memory location `1` bit to the right, with the higher bit of the result always being set to `0`, and the low bit which is shifted out of the field being stored in the carry flag.
/// 
/// The shift right instruction either affects the accumulator by shifting it right `1` or is a read/modify/write instruction which changes a specified memory location but does not affect any internal registers.
/// The shift right does not affect the overflow flag.
/// The `N` flag is always reset. 
/// The `Z` flag is set if the result of the shift is `0` and reset otherwise. 
/// The carry is set equal to bit `0` of the input.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#LSR
fn opLSR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Accumulator	                  LSR A	          $4A	    1	    2
  /// Absolute	                    LSR $nnnn	      $4E	    3	    6
  /// X-Indexed Absolute	          LSR $nnnn,X	    $5E	    3	    7
  /// Zero Page	                    LSR $nn	        $46	    2	    5
  /// X-Indexed Zero Page	          LSR $nn,X	      $56	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Accumulator {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore

    //
    // if wrap is Some(true) &&
    //   (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
    //   value = self.read_address(address) // |> ignore

    //   //
    //   // self.cycles += 1
    // }
  }

  //
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & CARRY) != 0)
    self.registers[A] = self.registers[A] >> 1 // underflow
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch
    self.flags.setC((value & CARRY) != 0)
    value = value >> 1 // underflow
    self.write(address, value)
    self.flags.setZN(value)
  }
}

///| `NOP` - No Operation
/// Operation: No operation
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#NOP
fn opNOP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      NOP	            $1A*	  1     2
  /// Implied	                      NOP	            $3A*	  1     2
  /// Implied	                      NOP	            $5A*	  1     2
  /// Implied	                      NOP	            $7A*	  1     2
  /// Implied	                      NOP	            $DA*	  1     2
  /// Implied	                      NOP	            $EA	    1     2
  /// Implied	                      NOP	            $FA*	  1     2
  /// Immediate	                    NOP #$nn	      $80*	  2	    2
  /// Immediate	                    NOP #$nn	      $82*	  2	    2
  /// Immediate	                    NOP #$nn	      $89*	  2	    2
  /// Immediate	                    NOP #$nn	      $C2*	  2	    2
  /// Immediate	                    NOP #$nn	      $E2*	  2	    2
  /// Absolute	                    NOP $nnnn	      $0C*	  3	    4
  /// X-Indexed Absolute	          NOP $nnnn,X	    $1C*	  3	    4+p
  /// X-Indexed Absolute	          NOP $nnnn,X	    $3C*	  3	    4+p
  /// X-Indexed Absolute	          NOP $nnnn,X	    $5C*	  3	    4+p
  /// X-Indexed Absolute	          NOP $nnnn,X	    $7C*	  3	    4+p
  /// X-Indexed Absolute	          NOP $nnnn,X	    $DC*	  3	    4+p
  /// X-Indexed Absolute	          NOP $nnnn,X	    $FC*	  3	    4+p
  /// Zero Page	                    NOP $nn	        $04*	  2	    3
  /// Zero Page	                    NOP $nn	        $44*	  2	    3
  /// Zero Page	                    NOP $nn	        $64*	  2	    3
  /// X-Indexed Zero Page	          NOP $nn,X	      $14*	  2	    4
  /// X-Indexed Zero Page	          NOP $nn,X	      $34*	  2	    4
  /// X-Indexed Zero Page	          NOP $nn,X	      $54*	  2	    4
  /// X-Indexed Zero Page	          NOP $nn,X	      $74*	  2	    4
  /// X-Indexed Zero Page	          NOP $nn,X	      $D4*	  2	    4
  /// X-Indexed Zero Page	          NOP $nn,X	      $F4*	  2	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  if prefetch is None {
    self.read_address(address) |> ignore
  } else if wrap is None {
    let (offset, _) = prefetch.unwrap()
    if mode is Implied || mode is Immediate {

    } else {
      self.read_address(offset) |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    self.read_address(offset) |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      self.read_address(address) |> ignore

      //
      self.cycles += 1
    }
  }
}

///| `ORA` - "OR" Memory with Accumulator
/// Operation: A ∨ M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// The `ORA` instruction transfers the memory and the accumulator to the adder which performs a binary "OR" on a bit-by-bit basis and stores the result in the accumulator.
/// 
/// This instruction affects the accumulator; 
/// sets the zero flag if the result in the accumulator is `0`, otherwise resets the zero flag; 
/// sets the negative flag if the result in the accumulator has bit `7` on, otherwise resets the negative flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#ORA
fn opORA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    ORA #$nn	      $09	    2	    2
  /// Absolute	                    ORA $nnnn	      $0D	    3	    4
  /// X-Indexed Absolute	          ORA $nnnn,X	    $1D	    3	    4+p
  /// Y-Indexed Absolute	          ORA $nnnn,Y	    $19	    3	    4+p
  /// Zero Page	                    ORA $nn	        $05	    2	    3
  /// X-Indexed Zero Page	          ORA $nn,X	      $15	    2	    4
  /// X-Indexed Zero Page Indirect	ORA ($nn,X)	    $01	    2	    6
  /// Zero Page Indirect Y-Indexed	ORA ($nn),Y	    $11	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  //
  self.registers[A] = self.registers[A] | value
  self.flags.setZN(self.registers[A])
}

///| `PHA` - Push Accumulator On Stack
/// Operation: A↓
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction transfers the current value of the accumulator to the next location on the stack, automatically decrementing the stack to point to the next empty location.
/// 
/// The Push `A` instruction only affects the stack pointer register which is decremented by `1` as a result of the operation. 
/// It affects no flags.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#PHA
fn opPHA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      PHA	            $48	    1	    3

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.push(self.registers[A])
}

///| `PHP` - Push Processor Status On Stack
/// Operation: P↓
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
///
/// This instruction transfers the contents of the processor status reg­ister unchanged to the stack, as governed by the stack pointer.
///
/// The `PHP` instruction affects no registers or flags in the micropro­cessor.
fn opPHP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      PHP	            $08	    1	    3

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.push(self.flags.get() | BREAK | UNUSED)
}

///| `PLA` - Pull Accumulator From Stack
/// Operation: A↑
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction adds `1` to the current value of the stack pointer and uses it to address the stack and loads the contents of the stack into the `A` register.
/// 
/// The `PLA` instruction does not affect the carry or overflow flags. 
/// It sets `N` if the bit `7` is on in accumulator `A` as a result of instructions, otherwise it is reset. 
/// If accumulator `A` is zero as a result of the `PLA`, then the `Z` flag is set, otherwise it is reset. 
/// The `PLA` instruction changes content of the accumulator `A` to the contents of the memory location at stack register plus `1` and also increments the stack register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#PLA
fn opPLA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      PLA	            $68	    1	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.read_address(u16(self.registers[SP]) | 0x0100) |> ignore

  //
  self.registers[A] = self.pop()
  self.flags.setZN(self.registers[A])
}

///| `PLP` - Pull Processor Status From Stack
/// Operation: P↑
///
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	✓	✓	✓	✓
/// 
/// This instruction transfers the next value on the stack to the Proces­sor Status register, thereby changing all of the flags and setting the mode switches to the values from the stack.
///
/// The `PLP` instruction affects no registers in the processor other than the status register.
/// This instruction could affect all flags in the status register.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#PLP
fn opPLP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      PLP	            $28	    1	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.read_address(u16(self.registers[SP]) | 0x0100) |> ignore

  //
  self.flags.set(self.pop().clr(BREAK).set(UNUSED)) |> ignore
}

///| `ROL` - Rotate Left
/// Operation: C ← /M7...M0/ ← C
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// The rotate left instruction shifts either the accumulator or addressed memory left `1` bit, with the input carry being stored in bit `0` and with the input bit `7` being stored in the carry flags.
/// 
/// The `ROL` instruction either shifts the accumulator left `1` bit and stores the carry in accumulator bit `0` or does not affect the internal registers at all. 
/// The `ROL` instruction sets carry equal to the input bit `7`, 
/// sets `N` equal to the input bit `6`, 
/// sets the `Z` flag if the result of the rotate is `0`, 
/// otherwise it resets `Z` and does not affect the overflow flag at all.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#ROL
fn opROL(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Accumulator	                  ROL A	          $2A	    1	    2
  /// Absolute	                    ROL $nnnn	      $2E	    3	    6
  /// X-Indexed Absolute	          ROL $nnnn,X	    $3E	    3	    7
  /// Zero Page	                    ROL $nn	        $26	    2	    5
  /// X-Indexed Zero Page	          ROL $nn,X	      $36	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Accumulator {

    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  //
  let c = self.flags[C].to_int()
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & NEGATIVE) != 0)
    self.registers[A] = (self.registers[A] << 1) | c // overflow
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch
    self.flags.setC((value & NEGATIVE) != 0)
    value = (value << 1) | c // overflow
    self.write(address, value)
    self.flags.setZN(value)
  }
}

///| `ROR` - Rotate Right
/// Operation: C → /M7...M0/ → C
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// The rotate right instruction shifts either the accumulator or addressed memory right `1` bit with bit `0` shifted into the carry and carry shifted into bit `7`.
/// 
/// The `ROR` instruction either shifts the accumulator right `1` bit and stores the carry in accumulator bit `7` or does not affect the internal registers at all. 
/// The `ROR` instruction sets carry equal to input bit `0`, sets `N` equal to the input carry and sets the `Z` flag if the result of the rotate is `0`; otherwise it resets `Z` and does not affect the overflow flag at all.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#ROR
fn opROR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Accumulator	                  ROR A	          $6A	    1	    2
  /// Absolute	                    ROR $nnnn	      $6E	    3	    6
  /// X-Indexed Absolute	          ROR $nnnn,X	    $7E	    3	    7
  /// Zero Page	                    ROR $nn	        $66	    2	    5
  /// X-Indexed Zero Page	          ROR $nn,X	      $76	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, _) = prefetch.unwrap()
    if mode is Accumulator {

    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  //
  let c = self.flags[C].to_int()

  //
  if mode == Accumulator {
    self.flags[C] = self.registers[A].bit(0)
    self.registers[A] = (self.registers[A] >> 1) | (c << 7) // underflow

    //
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch

    //
    self.flags[C] = value.bit(0)

    //
    value = (value >> 1) | (c << 7) // underflow
    self.write(address, value)

    //
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
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#RTI
fn opRTI(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      RTI	            $40	    1	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.read(u16(self.registers[SP]) | 0x0100, dummy=true) |> ignore

  //
  // self.flags.set((self.pop() & 0xCF) | UNUSED | BREAK) // pull() & 0xEF | 0x20
  // self.flags.set((self.pop() & 0xEF) | UNUSED) // nestest: pull() & 0xEF | 0x20
  // self.flags.set(self.pop() | UNUSED) |> ignore
  self.flags.set(self.pop().clr(BREAK).set(UNUSED)) |> ignore

  //
  self.pc = self.pop16()
}

///| `RTS` - Return From Subroutine
/// Operation: PC↑, PC + 1 → PC
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction loads the program count low and program count high from the stack into the program counter and increments the program counter so that it points to the instruction following the `JSR`. 
/// The stack pointer is adjusted by incrementing it twice.
/// 
/// The `RTS` instruction does not affect any flags and affects only `PCL` and `PCH`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#RTS
fn opRTS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      RTS	            $60	    1	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  self.read(u16(self.registers[SP]) | 0x0100, dummy=true) |> ignore

  //
  self.pc = self.pop16()

  //
  self.read(self.pc, dummy=true) |> ignore

  //
  self.pc += 1 // overflow
}

///| `SBC` - Subtract Memory from Accumulator with Borrow
/// Operation: A - M - ~C → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
/// 
/// This instruction subtracts the value of memory and borrow from the value of the accumulator, using two's complement arithmetic, and stores the result in the accumulator. 
/// Borrow is defined as the carry flag complemented; 
/// therefore, a resultant carry flag indicates that a borrow has not occurred.
/// 
/// This instruction affects the accumulator. 
/// The carry flag is set if the result is greater than or equal to `0`. 
/// The carry flag is reset when the result is less than `0`, indicating a borrow. 
/// The over­flow flag is set when the result exceeds `+127` or `-127`, otherwise it is reset. 
/// The negative flag is set if the result in the accumulator has bit `7` on, otherwise it is reset. 
/// The `Z` flag is set if the result in the accumulator is `0`, otherwise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SBC
fn opSBC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    SBC #$nn	      $E9	    2	    2
  /// Immediate	                    SBC #$nn	      $EB*    2	    2
  /// Absolute	                    SBC $nnnn	      $ED	    3	    4
  /// X-Indexed Absolute	          SBC $nnnn,X	    $FD	    3	    4+p
  /// Y-Indexed Absolute	          SBC $nnnn,Y	    $F9	    3	    4+p
  /// Zero Page	                    SBC $nn	        $E5	    2	    3
  /// X-Indexed Zero Page	          SBC $nn,X	      $F5	    2	    4
  /// X-Indexed Zero Page Indirect	SBC ($nn,X)	    $E1	    2	    6
  /// Zero Page Indirect Y-Indexed	SBC ($nn),Y	    $F1	    2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if wrap is Some(true) &&
      (mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY) {
      value = self.read_address(address) // |> ignore

      //
      self.cycles += 1
    }
  }

  // 
  let a = self.registers[A]._
  let b = value._
  let c = self.flags[C].to_int()

  //
  self.sbc(a, b, c)
}

///|
fn sbc(self : CPU, a : Int, b : Int, c : Int) -> Unit {
  self.registers[A] = a - b - (1 - c)

  //
  self.flags.setC(a - b - (1 - c) >= 0)
  self.flags.setV(
    ((a ^ b) & 0x80) != 0 && ((a ^ self.registers[A]._) & 0x80) != 0,
  )
  self.flags.setZN(self.registers[A])

  //
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

///| `SEC` - Set Carry Flag
/// Operation: 1 → C
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	1
/// 
/// This instruction initializes the carry flag to a `1`. 
/// This operation should normally precede a `SBC` loop. 
/// It is also useful when used with a `ROL` instruction to initialize a bit in memory to a `1`.
/// 
/// This instruction affects no registers in the microprocessor and no flags other than the carry flag which is set.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SEC
fn opSEC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      SEC	            $38	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.flags.set_carry()
}

///| `SED` - Set Decimal Mode
/// Operation: 1 → D
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	1	-	-	-
/// 
/// This instruction sets the decimal mode flag `D` to a `1`. 
/// This makes all subsequent `ADC` and `SBC` instructions operate as a decimal arithmetic operation.
/// 
/// `SED` affects no registers in the microprocessor and no flags other than the decimal mode which is set to a `1`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SED
fn opSED(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      SED	            $F8	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.flags.set_decimal()
}

///| `SEI` - Set Interrupt Disable
/// Operation: 1 → I
///
/// This instruction initializes the interrupt disable to a `1`.
/// It is used to mask interrupt requests during system reset operations and during interrupt commands.
///
/// It affects no registers in the microprocessor and no flags other than the interrupt disable which is set.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SEI
fn opSEI(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      SEI	            $78	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.flags.set_interrupt()
}

///| `STA` - Store Accumulator in Memory
/// Operation: A → M
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This instruction transfers the contents of the accumulator to memory.
/// 
/// This instruction affects none of the flags in the processor status register and does not affect the accumulator.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#STA
fn opSTA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    STA $nnnn	      $8D	    3	    4
  /// X-Indexed Absolute	          STA $nnnn,X	    $9D	    3	    5
  /// Y-Indexed Absolute	          STA $nnnn,Y	    $99	    3	    5
  /// Zero Page	                    STA $nn	        $85	    2	    3
  /// X-Indexed Zero Page	          STA $nn,X	      $95	    2	    4
  /// X-Indexed Zero Page Indirect	STA ($nn,X)	    $81	    2	    6
  /// Zero Page Indirect Y-Indexed	STA ($nn),Y	    $91	    2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if prefetch is None {

  } else if wrap is None {

  } else {
    let (offset, _) = prefetch.unwrap()
    self.read_address(offset) |> ignore
  }

  //
  self.write(address, self.registers[A])
}

///| `STX` - Store Index Register `X` In Memory
/// Operation: X → M
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// Transfers value of `X` register to addressed memory location.
/// 
/// No flags or registers in the microprocessor are affected by the store operation.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#STX
fn opSTX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    STX $nnnn	      $8E	    3	    4
  /// Zero Page	                    STX $nn	        $86	    2	    3
  /// Y-Indexed Zero Page	          STX $nn,Y	      $96	    2	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.write(address, self.registers[X])
}

///| `STY` - Store Index Register `Y` In Memory
/// Operation: Y → M
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// Transfer the value of the `Y` register to the addressed memory location.
/// 
/// `STY` does not affect any flags or registers in the microprocessor.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#STY
fn opSTY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    STY $nnnn	      $8C	    3	    4
  /// Zero Page	                    STY $nn	        $84	    2	    3
  /// X-Indexed Zero Page	          STY $nn,X	      $94	    2	    4

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.write(address, self.registers[Y])
}

///| `TAX` - Transfer Accumulator To Index `X`
/// Operation: A → X
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction takes the value from accumulator `A` and transfers or loads it into the index register `X` without disturbing the content of the accumulator `A`.
/// 
/// `TAX` only affects the index register `X`, does not affect the carry or overflow flags. 
/// The `N` flag is set if the resultant value in the index register `X` has bit `7` on, otherwise `N` is reset. 
/// The `Z` bit is set if the content of the register `X` is `0` as a result of the operation, otherwise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TXA
fn opTAX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TAX	            $AA	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.registers[X] = self.registers[A]
  self.flags.setZN(self.registers[X])
}

///| `TAY` - Transfer Accumulator To Index `Y`
/// Operation: A → Y
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction moves the value of the accumulator into index register `Y` without affecting the accumulator.
/// 
/// `TAY` instruction only affects the `Y` register and does not affect either the carry or overflow flags. 
/// If the index register `Y` has bit `7` on, then `N` is set, otherwise it is reset. 
/// If the content of the index register `Y` equals `0` as a result of the operation, `Z` is set on, otherwise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TAY
fn opTAY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TAY	            $A8	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.registers[Y] = self.registers[A]
  self.flags.setZN(self.registers[Y])
}

///| `TSX` - Transfer Stack Pointer To Index `X`
/// Operation: S → X
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction transfers the value in the stack pointer to the index register `X`.
/// 
/// `TSX` does not affect the carry or overflow flags. 
/// It sets `N` if bit `7` is on in index `X` as a result of the instruction, otherwise it is reset. 
/// If index `X` is zero as a result of the `TSX`, the `Z` flag is set, other­ wise it is reset. 
/// `TSX` changes the value of index `X`, making it equal to the content of the stack pointer.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TSX
fn opTSX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TSX	            $BA	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.registers[X] = self.registers[SP]
  self.flags.setZN(self.registers[X])
}

///| `TXA` - Transfer Index `X` To Accumulator
/// Operation: X → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	-
/// 
/// This instruction moves the value that is in the index register `X` to the accumulator `A` without disturbing the content of the index register `X`.
/// 
/// `TXA` does not affect any register other than the accumulator and does not affect the carry or overflow flag. 
/// If the result in `A` has bit `7` on, then the `N` flag is set, otherwise it is reset. 
/// If the resultant value in the accumulator is `0`, then the `Z` flag is set, other­ wise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TXA
fn opTXA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TXA	            $8A 	  1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
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
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TXS
fn opTXS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TXS	            $9A	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
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
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#TYA
fn opTYA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      TYA	            $98	    1	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
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
fn opALR(self : CPU, address : UInt16, mode : Mode) -> Unit {
  self.opAND(address, mode)
  self.opLSR(address, Mode::Accumulator)

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
fn opANC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    ANC #$nn	      $0B*	  2	    2
  /// Immediate	                    ANC #$nn	      $2B*	  2	    2

  let (address, value, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{value} \{wrap}")

  //
  let (_, value) = value.unwrap()
  let tmp = self.registers[A] & value

  //
  self.registers[A] = tmp
  self.flags.setZN(tmp)
  self.flags.setC(tmp.bit(7))
}

///| `ARR` - `AND` Accumulator then Rotate Right
/// Operation: (A ∧ M) / 2 → A
///
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
///
/// The undocumented `ARR` instruction performs a bit-by-bit `AND` operation of the accumulator and memory, 
/// then shifts the result right 1 bit with bit `0` shifted into the carry and carry shifted into bit `7`.
/// It then stores the result back in the accumulator.
///
/// If bit `7` of the result is on, then the `N` flag is set, otherwise it is reset.
/// The instruction sets the `Z` flag if the result is `0`;  otherwise it resets `Z`.
///
/// The `V` and `C` flags depend on the Decimal Mode Flag:
/// In decimal mode, the `V` flag is set if bit `6` is different than the original data's bit `6`, otherwise the `V` flag is reset.
///   The `C` flag is set if `(operand & 0xF0) + (operand & 0x10)` is greater than `0x50`, otherwise the `C` flag is reset.
/// In binary mode, the `V` flag is set if bit `6` of the result is different than bit `5` of the result, otherwise the `V` flag is reset.
///   The `C` flag is set if the result in the accumulator has bit `6` on, otherwise it is reset.
///
/// https://www.pagetable.com/c64ref/6502/?tab=2#ARR
fn opARR(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    ARR #$nn	      $6B*	  2	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  //
  let t = self.registers[A] & value
  let mut a = (t >> 1) | (self.flags.carry().to_int() << 7)

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
    self.flags.setC(a.bit(6))
    self.flags.setZN(a)
    self.flags.setV((a.bitn(6) ^ a.bitn(5)) != 0)
  }

  //
  self.registers[A] = a
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
fn opSBX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    SBX #$nn	      $CB*	  2	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  //
  let result = (self.registers[A] & self.registers[X]) - value // underflow
  self.flags.setC(not(ALU::underflow()))
  // self.flags.setC(not(result.is_neg()))
  self.flags.setZN(result)
  self.registers[X] = result
}

///| `DCP` - Decrement Memory By One then Compare with Accumulator
/// Operation: M - 1 → M, A - M
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// This undocumented instruction subtracts `1`, in two's complement, from the contents of the addressed memory location. 
/// It then subtracts the contents of memory from the contents of the accumulator.
/// 
/// The `DCP` instruction does not affect any internal register in the microprocessor. 
/// It does not affect the overflow flag. 
/// `Z` flag is set on an equal comparison, reset otherwise; 
/// the `N` flag is set or reset by the result bit `7`, 
/// the carry flag is set when the result in memory is less than or equal to the accumulator, 
/// reset when it is greater than the accumulator.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#DCP
fn opDCP(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    DCP $nnnn	      $CF*	  3	    6
  /// X-Indexed Absolute	          DCP $nnnn,X	    $DF*	  3	    7
  /// Y-Indexed Absolute	          DCP $nnnn,Y	    $DB*	  3	    7
  /// Zero Page	                    DCP $nn	        $C7*	  2	    5
  /// X-Indexed Zero Page	          DCP $nn,X	      $D7*	  2	    6
  /// X-Indexed Zero Page Indirect	DCP ($nn,X)	    $C3*	  2	    8
  /// Zero Page Indirect Y-Indexed	DCP ($nn),Y	    $D3*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  // self.opDEC(address, mode)
  self.write(address, value, dummy=true) // FIXME: pre-fetch
  value -= 1 // underflow
  self.write(address, value)
  self.flags.setZN(value)

  // self.opCMP(address, mode)
  self.compare(self.registers[A], value)
}

///| `ISC` - Increment Memory By One then `SBC` then Subtract Memory from Accumulator with Borrow
/// Operation: M + 1 → M, A - M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
/// 
/// This undocumented instruction adds `1` to the contents of the addressed memory location. 
/// It then subtracts the value of the result in memory and borrow from the value of the accumulator, using two's complement arithmetic, and stores the result in the accumulator.
/// 
/// This instruction affects the accumulator. 
/// The carry flag is set if the result is greater than or equal to `0`. 
/// The carry flag is reset when the result is less than `0`, indicating a borrow. 
/// The over­flow flag is set when the result exceeds `+127` or `-127`, otherwise it is reset. 
/// The negative flag is set if the result in the accumulator has bit `7` on, otherwise it is reset. 
/// The `Z` flag is set if the result in the accumulator is `0`, otherwise it is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#ISC
fn opISC(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    ISC $nnnn	      $EF*	  3	    6
  /// X-Indexed Absolute	          ISC $nnnn,X	    $FF*	  3	    7
  /// Y-Indexed Absolute	          ISC $nnnn,Y	    $FB*	  3	    7
  /// Zero Page	                    ISC $nn	        $E7*	  2	    5
  /// X-Indexed Zero Page	          ISC $nn,X	      $F7*	  2	    6
  /// X-Indexed Zero Page Indirect	ISC ($nn,X)	    $E3*	  2	    8
  /// Zero Page Indirect Y-Indexed	ISC ($nn),Y	    $F3*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore
    value = self.read_address(address) // |> ignore
  }

  // self.opINC(address, mode)
  self.write(address, value, dummy=true) // FIXME: pre-fetch
  value += 1 // overflow
  self.write(address, value)
  self.flags.setZN(value)

  // self.opSBC(address, mode)
  let a = self.registers[A]._
  let b = value._
  let c = self.flags[C].to_int()

  //
  self.sbc(a, b, c)
}

///| `JAM` - Halt the CPU
/// Operation: Stop execution
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// This undocumented instruction stops execution. 
/// The microprocessor will not fetch further instructions, and will neither handle IRQs nor NMIs. 
/// It will handle a RESET though.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#JAM
fn opJAM(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Implied	                      JAM	            $02*	  1	    X
  /// Implied	                      JAM	            $12*	  1	    X
  /// Implied	                      JAM	            $22*	  1	    X
  /// Implied	                      JAM	            $32*	  1	    X
  /// Implied	                      JAM	            $42*	  1	    X
  /// Implied	                      JAM	            $52*	  1	    X
  /// Implied	                      JAM	            $62*	  1	    X
  /// Implied	                      JAM	            $72*	  1	    X
  /// Implied	                      JAM	            $92*	  1	    X
  /// Implied	                      JAM	            $B2*	  1	    X
  /// Implied	                      JAM	            $D2*	  1	    X
  /// Implied	                      JAM	            $F2*	  1	    X

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFE, dummy=true) // FIXME: pre-fetch
  //
  let _ = self.read(0xFFFE, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  //
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  let _ = self.read(0xFFFF, dummy=true) // FIXME: pre-fetch
  //
  self.cycles += 9
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
fn opLAS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Y-Indexed Absolute	          LAS $nnnn,Y	    $BB*	  3	    4+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1
  }

  //
  let value = self.registers[SP] & self.read_address(address)

  //
  self.registers[A] = value
  self.registers[X] = value
  self.registers[SP] = value
  self.flags.setZN(value)
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
fn opLAX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    LAX #$nn	      $AB*	  2	    2
  /// Absolute	                    LAX $nnnn	      $AF*	  3	    4
  /// Y-Indexed Absolute	          LAX $nnnn,Y	    $BF*	  3	    4+p
  /// Zero Page	                    LAX $nn	        $A7*	  2	    3
  /// Y-Indexed Zero Page	          LAX $nn,Y	      $B7*	  2	    4
  /// X-Indexed Zero Page Indirect	LAX ($nn,X)	    $A3*	  2	    6
  /// Zero Page Indirect Y-Indexed	LAX ($nn),Y	    $B3*	  2	    5+p

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  if wrap is Some(true) {
    let (address, _) = prefetch.unwrap()
    self.read_address(address) |> ignore

    //
    self.cycles += 1
  }

  //
  let value = if mode is Immediate {
    // https://sourceforge.net/p/vice-emu/code/HEAD/tree/testprogs/CPU/lax/
    let magic = 0xEE

    //
    let (_, value) = prefetch.unwrap()

    //
    (self.registers[A] | magic) & value
  } else {
    self.read_address(address)
  }

  //
  self.registers[A] = value
  self.registers[X] = value
  self.flags.setZN(value)
}

///| `RLA` - Rotate Left then "AND" with Accumulator
/// Operation: C ← /M7...M0/ ← C, A ∧ M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// The undocumented `RLA` instruction shifts the addressed memory left `1` bit, with the input carry being stored in bit `0` and with the input bit `7` being stored in the carry flags. 
/// It then performs a bit-by-bit `AND` operation of the result and the value of the accumulator and stores the result back in the accumulator.
/// 
/// This instruction affects the accumulator; 
/// sets the zero flag if the result in the accumulator is `0`, otherwise resets the zero flag; 
/// sets the negative flag if the result in the accumulator has bit `7` on, otherwise resets the negative flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#RLA
fn opRLA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    RLA $nnnn	      $2F*	  3	    6
  /// X-Indexed Absolute	          RLA $nnnn,X	    $3F*	  3	    7
  /// Y-Indexed Absolute	          RLA $nnnn,Y	    $3B*	  3	    7
  /// Zero Page	                    RLA $nn	        $27*	  2	    5
  /// X-Indexed Zero Page	          RLA $nn,X	      $37*	  2	    6
  /// X-Indexed Zero Page Indirect	RLA ($nn,X)	    $23*	  2	    8
  /// Zero Page Indirect Y-Indexed	RLA ($nn),Y	    $33*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  // self.opROL(address, mode)
  let c = self.flags[C].to_int()
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & NEGATIVE) != 0)
    self.registers[A] = (self.registers[A] << 1) | c // overflow
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value)
    self.flags.setC((value & NEGATIVE) != 0)
    value = (value << 1) | c // overflow
    self.write(address, value)
    self.flags.setZN(value)

    // self.opAND(address, mode)
    self.registers[A] = self.registers[A] & value
    self.flags.setZN(self.registers[A])
  }
}

///| `RRA` - Rotate Right and Add Memory to Accumulator
/// Operation: C → /M7...M0/ → C, A + M + C → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	✓	-	-	-	-	✓	✓
/// 
/// The undocumented `RRA` instruction shifts the addressed memory right `1` bit with bit `0` shifted into the carry and carry shifted into bit `7`. 
/// It then adds the result and generated carry to the value of the accumulator and stores the result in the accumulator.
/// 
/// This instruction affects the accumulator; 
/// sets the carry flag when the sum of a binary add exceeds `255` or when the sum of a decimal add exceeds `99`, otherwise carry is reset. 
/// The overflow flag is set when the sign or bit `7` is changed due to the result exceeding `+127` or `-128`, otherwise overflow is reset. 
/// The negative flag is set if the accumulator result contains bit `7` on, otherwise the negative flag is reset. 
/// The zero flag is set if the accumulator result is `0`, otherwise the zero flag is reset.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#RRA
fn opRRA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    RRA $nnnn	      $6F*	  3	    6
  /// X-Indexed Absolute	          RRA $nnnn,X	    $7F*	  3	    7
  /// Y-Indexed Absolute	          RRA $nnnn,Y	    $7B*	  3	    7
  /// Zero Page	                    RRA $nn	        $67*	  2	    5
  /// X-Indexed Zero Page	          RRA $nn,X	      $77*	  2	    6
  /// X-Indexed Zero Page Indirect	RRA ($nn,X)	    $63*	  2	    8
  /// Zero Page Indirect Y-Indexed	RRA ($nn),Y	    $73*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  //
  let c = self.flags[C].to_int()

  // self.opROR(address, mode)
  if mode == Accumulator {
    self.flags[C] = self.registers[A].bit(0)
    self.registers[A] = (self.registers[A] >> 1) | (c << 7) // underflow

    //
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch

    //
    self.flags[C] = value.bit(0)

    //
    value = (value >> 1) | (c << 7) // underflow
    self.write(address, value)

    //
    self.flags.setZN(value)
  }

  //
  let a = self.registers[A].to_int()
  let b = value.to_int()
  let c = self.flags[C].to_int()

  // self.opADC(address, mode)
  self.adc(a, b, c)
}

///| `SAX` - Store Accumulator "AND" Index Register `X` in Memory
/// Operation: A ∧ X → M
/// 
/// N	V	-	B	D	I	Z	C
/// -	-	-	-	-	-	-	-
/// 
/// The undocumented `SAX` instruction performs a bit-by-bit `AND` operation of the value of the accumulator and the value of the index register `X` and stores the result in memory.
/// 
/// No flags or registers in the microprocessor are affected by the store operation.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SAX
fn opSAX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    SAX $nnnn	      $8F*	  3	    4
  /// Zero Page	                    SAX $nn	        $87*	  2	    3
  /// Y-Indexed Zero Page	          SAX $nn,Y	      $97*	  2	    4
  /// X-Indexed Zero Page Indirect	SAX ($nn,X)	    $83*	  2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  self.write(address, self.registers[A] & self.registers[X])
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
fn opSHA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Y-Indexed Absolute	          SHA $nnnn,Y	    $9F*	  3	    5
  /// Zero Page Indirect Y-Indexed	SHA ($nn),Y	    $93*	  2	    6

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let (offset, _) = prefetch.unwrap()
  self.read_address(offset) |> ignore

  //
  let mut address = address
  let mut value = self.registers[A] & self.registers[X]
  if wrap is Some(true) {
    value = value & u8(address >> 8)
    address = (u16(value) << 8) | (address & 0x00FF)
  } else {
    value = value & (u8(address >> 8) + 1)
  }

  //
  self.write(address, value)
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
fn opSHS(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Y-Indexed Absolute	          SHS $nnnn,Y	    $9B*	  3	    5

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let (offset, _) = prefetch.unwrap()
  self.read_address(offset) |> ignore

  //
  self.registers[SP] = self.registers[A] & self.registers[X]

  //
  let mut address = address
  let mut value = self.registers[SP]
  if wrap is Some(true) {
    value = value & u8(address >> 8)
    address = (u16(value) << 8) | (address & 0x00FF)
  } else {
    value = value & (u8(address >> 8) + 1)
  }

  //
  self.write(address, value)
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
fn opSHX(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Y-Indexed Absolute	          SHX $nnnn,Y	    $9E*	  3	    5

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let (offset, _) = prefetch.unwrap()
  self.read_address(offset) |> ignore

  //
  let mut address = address
  let mut value = self.registers[X]
  if wrap is Some(true) {
    value = value & u8(address >> 8)
    address = (u16(value) << 8) | (address & 0x00FF)
  } else {
    value = value & (u8(address >> 8) + 1)
  }

  //
  self.write(address, value)
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
fn opSHY(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// X-Indexed Absolute	          SHY $nnnn,X	    $9C*	  3	    5

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let (offset, _) = prefetch.unwrap()
  self.read_address(offset) |> ignore

  //
  let mut address = address
  let mut value = self.registers[Y]
  if wrap is Some(true) {
    value = value & u8(address >> 8)
    address = (u16(value) << 8) | (address & 0x00FF)
  } else {
    value = value & (u8(address >> 8) + 1)
  }

  //
  self.write(address, value)
}

///| `SLO` - Arithmetic Shift Left then "OR" Memory with Accumulator
/// Operation: M * 2 → M, A ∨ M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// The undocumented `SLO` instruction shifts the address memory location `1` bit to the left, with the bit `0` always being set to `0` and the bit `7` output always being contained in the carry flag. 
/// It then performs a bit-by-bit "OR" operation on the result and the accumulator and stores the result in the accumulator.
/// 
/// The negative flag is set if the accumulator result contains bit `7` on, otherwise the negative flag is reset. 
/// It sets `Z` flag if the result is equal to `0`, otherwise resets `Z` and stores the input bit `7` in the carry flag.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SLO
fn opSLO(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    SLO $nnnn	      $0F*	  3	    6
  /// X-Indexed Absolute	          SLO $nnnn,X	    $1F*	  3	    7
  /// Y-Indexed Absolute	          SLO $nnnn,Y	    $1B*	  3	    7
  /// Zero Page	                    SLO $nn	        $07*	  2	    5
  /// X-Indexed Zero Page         	SLO $nn,X	      $17*	  2	    6
  /// X-Indexed Zero Page Indirect	SLO ($nn,X)	    $03*	  2	    8
  /// Zero Page Indirect Y-Indexed	SLO ($nn),Y	    $13*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  //
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {

  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    if mode is IndirectIndexed || mode is AbsoluteX || mode is AbsoluteY {
      value = self.read_address(address) // |> ignore
    }
  }

  // self.opASL(address, mode)
  self.write(address, value) // FIXME: pre-fetch
  self.flags.setC((value & NEGATIVE) != 0)
  let value = value << 1 // overflow
  self.write(address, value)
  self.flags.setZN(value)

  // self.opORA(address, mode)
  self.registers[A] = self.registers[A] | value
  self.flags.setZN(self.registers[A])
}

///| `SRE` - Logical Shift Right then "Exclusive OR" Memory with Accumulator
/// Operation: M / 2 → M, A ⊻ M → A
/// 
/// N	V	-	B	D	I	Z	C
/// ✓	-	-	-	-	-	✓	✓
/// 
/// The undocumented `SRE` instruction shifts the specified memory location `1` bit to the right, with the higher bit of the result always being set to `0`, and the low bit which is shifted out of the field being stored in the carry flag. 
/// It then performs a bit-by-bit "EXCLUSIVE OR" of the result and the value of the accumulator and stores the result in the accumulator.
/// 
/// This instruction affects the accumulator. 
/// It does not affect the overflow flag. 
/// The negative flag is set if the accumulator result contains bit `7` on, otherwise the negative flag is reset. 
/// The `Z` flag is set if the result is `0` and reset otherwise. 
/// The carry is set equal to input bit `0`.
/// 
/// https://www.pagetable.com/c64ref/6502/?tab=2#SRE
fn opSRE(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Absolute	                    SRE $nnnn	      $4F*	  3	    6
  /// X-Indexed Absolute	          SRE $nnnn,X	    $5F*	  3	    7
  /// Y-Indexed Absolute	          SRE $nnnn,Y	    $5B*	  3	    7
  /// Zero Page	                    SRE $nn	        $47*	  2	    5
  /// X-Indexed Zero Page	          SRE $nn,X	      $57*	  2	    6
  /// X-Indexed Zero Page Indirect	SRE ($nn,X)	    $43*	  2	    8
  /// Zero Page Indirect Y-Indexed	SRE ($nn),Y	    $53*	  2	    8

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {
    value = self.read_address(address) // |> ignore
  } else if wrap is None {
    let (offset, data) = prefetch.unwrap()
    if mode is Immediate {
      value = data
    } else {
      value = self.read_address(offset) // |> ignore
    }
  } else {
    let (offset, _) = prefetch.unwrap()
    value = self.read_address(offset) // |> ignore

    //
    value = self.read_address(address) // |> ignore
  }

  // self.opLSR(address, mode)
  if mode == Accumulator {
    self.flags.setC((self.registers[A] & CARRY) != 0)
    self.registers[A] = self.registers[A] >> 1 // underflow
    self.flags.setZN(self.registers[A])
  } else {
    self.write(address, value) // FIXME: pre-fetch
    self.flags.setC((value & CARRY) != 0)
    value = value >> 1 // underflow
    self.write(address, value)
    self.flags.setZN(value)

    // self.opEOR(address, mode)
    self.registers[A] = self.registers[A] ^ value
    self.flags.setZN(self.registers[A])
  }
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
fn opXAA(self : CPU, _ : UInt16, mode : Mode) -> Unit {
  /// Addressing Mode	              Assembly Form 	Opcode	Bytes	Cycles
  /// Immediate	                    XAA #$nn	      $8B*	  2	    2

  let (address, prefetch, wrap) = self.get_address_by_mode(mode)
  // println("\{address} \{prefetch} \{wrap}")

  // 
  let mut value : UInt8 = 0x00
  if prefetch is None {

  } else if wrap is None {
    let (_, data) = prefetch.unwrap()
    value = data
  }

  // 
  let magic = 0xEE // https://sourceforge.net/p/vice-emu/code/HEAD/tree/testprogs/CPU/ane/

  //
  let tmp = (self.registers[A] | magic) & self.registers[X] & value

  //
  self.registers[A] = tmp
  self.flags.setZN(tmp)
}

///|
enum Mode {
  ///| Absolute $nnnn
  /// In absolute addressing, the second byte of the instruction specifies the eight low order bits of the effective address while the third byte specifies the eight high order bits.
  /// Thus, the absolute addressing mode allows access to the entire 65K bytes of addressable memory.
  Absolute // 0
  AbsoluteSP // 0
  ///| X-Indexed Absolute $nnnn,X
  /// This form of addressing is used in conjunction with the `X` index register.
  /// The effective address is formed by adding the contents of `X` to the address contained in the second and third bytes of the instruction.
  /// This mode allows the index register to contain the index or count value and the instruction to contain the base address.
  /// This type of indexing allows any location referencing and the index to modify multiple fields resulting in reduced coding and execution time.
  AbsoluteX // 1
  ///| Y-Indexed Absolute $nnnn,Y
  /// This form of addressing is used in conjunction with the `Y` index register.
  /// The effective address is formed by adding the contents of `Y` to the address contained in the second and third bytes of the instruction.
  /// This mode allows the index register to contain the index or count value and the instruction to contain the base address.
  /// This type of indexing allows any location referencing and the index to modify multiple fields resulting in reduced coding and execution time.
  AbsoluteY // 2
  Accumulator // 3
  Immediate // 4
  Implied // 5
  ///| X-Indexed Zero Page Indirect ($nn,X)
  /// In indexed indirect addressing, the second byte of the instruction is added to the contents of the `X` index register, discarding the carry. 
  /// The result of this addition points to a memory location on page zero whose contents is the low order eight bits of the effective address.
  /// The next memory location in page zero contains the high order eight bits of the effective address.
  /// Both memory locations specifying the high and low order bytes of the effective address must be in page zero.
  IndexedIndirect // 6
  Indirect // 7
  ///| Zero Page Indirect Y-Indexed($nn),Y
  /// In indirect indexed addressing, the second byte of the instruction points to a memory location in page zero.
  /// The contents of this memory location is added to the contents of the `Y` index register, the result being the low order eight bits of the effective address.
  /// The carry from this addition is added to the contents of the next page zero memory location, the result being the high order eight bits of the effective address.
  IndirectIndexed // 8
  Relative // 9
  ///| Zero Page $nn
  /// The zero page instructions allow for shorter code and execution times by only fetching the second byte of the instruction and assuming a zero high address byte.
  /// Careful use of the zero page can result in significant increase in code efficiency.
  ZeroPage // 10
  ///| X-Indexed Zero Page  $nn,X
  /// This form of addressing is used in conjunction with the `X` index register.
  /// The effective address is calculated by adding the second byte to the contents of the index register.
  /// Since this is a form of "Zero Page" addressing, the content of the second byte references a location in page zero.
  /// Additionally, due to the “Zero Page" addressing nature of this mode, no carry is added to the high order 8 bits of memory and crossing of page boundaries does not occur.
  ZeroPageX // 11
  ///| Y-Indexed Zero Page  $nn,Y
  /// This form of addressing is used in conjunction with the `Y` index register.
  /// The effective address is calculated by adding the second byte to the contents of the index register.
  /// Since this is a form of "Zero Page" addressing, the content of the second byte references a location in page zero.
  /// Additionally, due to the “Zero Page" addressing nature of this mode, no carry is added to the high order 8 bits of memory and crossing of page boundaries does not occur.
  ZeroPageY // 12
} derive(Eq, Show)

///|
pub let instructions : FixedArray[
  (String, (CPU, UInt16, Mode) -> Unit, Mode, Int, Int, Int, Bool),
] = [ // All 6502 instructions
  // 0x00
  ("BRK", opBRK, Implied, 1, 7, 0, false),
  ("ORA", opORA, IndexedIndirect, 2, 6, 0, false),
  ("JAM", opJAM, Implied, 1, 2, 0, true),
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
  ("JAM", opJAM, Implied, 1, 2, 0, true),
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
  ("JSR", opJSR, AbsoluteSP, 3, 6, 0, false),
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
  ("ASR", opASR, Immediate, 2, 2, 0, true),
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
