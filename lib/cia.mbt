/// 6526
///
/// $DC00-$DCFF CIA #1
/// $DC00-$DC0F Complex Interface Adapter (CIA) #1 Registers
/// $DC10-$DCFF CIA #1 register images (repeated every $10, 16 bytes).
///
/// $DD00-$DDFF CIA #2
/// $DD00-$DD0F Complex Interface Adapter (CIA) #2 Registers
/// $DD10-$DDFF CIA #2 Register Images  The result is that every 16-byte area in this 256-byte block is a mirror of every other.

let cia_mem_start = 0xDC00

let cia1_mem_start = 0xDC00

let cia2_mem_start = 0xDD00

let cia_mem_end = 0xDDFF

let cia_mem_size = 0x00FF

struct Memory {
  mem : FixedArray[Int]
  baseaddress : Int
}

pub fn Memory::new(
  size : Int,
  ~value : Int = 0x00,
  ~baseaddress : Int
) -> Memory {
  let mem = FixedArray::make(size + 1, value)
  { mem, baseaddress }
}

fn reset(self : Memory, ~value : Int = 0x00) -> Unit {
  for i = 0; i < self.mem.length(); i = i + 1 {
    self.mem[i] = value
  }
}

fn r(self : Memory, address : UInt16) -> UInt8 {
  println(
    "CIA $" + address.to_hex() + " → $" + UInt8(self.mem[address.0]).to_hex(),
  )
  self.mem[address.0]
}

fn w(self : Memory, address : UInt16, value : UInt8) -> Unit {
  println(
    "CIA $" + address.to_hex() + " ← $" + UInt8(self.mem[address.0]).to_hex(),
  )
  self.mem[address.0] = value.0
}

fn op_get(self : Memory, register : Register) -> UInt8 {
  println("CIA::get \(register)")
  let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
  if self.baseaddress + address < cia_mem_start || self.baseaddress + address > cia_mem_end {
    // self.dump()
    println("CIA \(register) → $" + UInt8(self.mem[address % 0x100]).to_hex())
    abort("get out of bounds")
  }
  // println("CIA \(register) → $" + self.mem[address % 0x100].to_hex())
  // match register {
  //   /// FIXME: depends on memory bank?
  //   RD_ICR => self.acknowledgeCIAIRQ()
  // }
  // self.mem[address].0
  self.r(address)
}

fn op_set(self : Memory, register : Register, value : UInt8) -> Unit {
  println("CIA::set \(register) = #$" + value.to_hex())
  let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
  if self.baseaddress + address < cia_mem_start || self.baseaddress + address > cia_mem_end {
    // self.dump()
    println("CIA \(register) ← $" + value.to_hex())
    abort("set out of bounds")
  }
  // println("CIA \(register) ← $" + value.to_hex())
  // match register {
  //   /// FIXME: depends on memory bank?
  //   // WR_ICR => self.writeCIAIRQmask(value) //only writing 1 to $d019 bit0 would acknowledge, not any value (but RMW instructions write $d019 back before mod.)
  //   // WR_SDR => self.mem[address] = value.0
  //   _ => self.mem[address] = value.0
  // }
  self.w(address, value)
}

struct CIA {
  ram : Memory
  rom : Memory
  baseaddress : Int
}

pub fn CIA::new(
  cpu : @cpu.CPU,
  baseaddress : Int,
  ~videoStandard : VideoStandard = Unknown
) -> CIA {
  println("CIA::new")
  let ram = Memory::new(cia_mem_size + 1, ~baseaddress)
  let rom = Memory::new(cia_mem_size + 1, ~baseaddress)
  let cia : CIA = { ram, rom, baseaddress }
  cpu.mem().hook(
    cia_mem_start,
    cia_mem_end,
    rom.mem,
    fn(address : Int) {
      println("CIA::r")
      // cia.r(address).0
      0x00
    },
    fn(address : Int, value : Int) {
      println("CIA::w")
      // cia.w(address, value)
    },
  )
  cia.reset(~videoStandard)
  cia
}

pub fn reset(self : CIA, ~videoStandard : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=cia_mem_length)
  self.rom.reset()
  self.ram.reset()

  //
  match self.baseaddress {
    cia1_mem_start => {
      //Imitate CIA1 keyboard/joy port, some tunes check if buttons are not pressed
      self.rom[PRA] = 0x10
      self.rom[PRB] = 0xFF

      //initialize CIAs
      self.ram[TA_LO] = match videoStandard {
        NTSC => 0x24
        PAL => 0x40
        _ => 0x00
      }
      self.ram[TA_HI] = match videoStandard {
        NTSC => 0x95
        PAL => 0x42
        _ => 0x00
      }

      //Reset-default, but for PSID CIA1 TimerA IRQ should be enabled anyway if SID is CIA-timed
      self.ram[ICR] = 0x81

      //some tunes (and PSID doc) expect already running CIA (Reset-default)
      self.ram[CRA] = 0x01
      //All counters other than CIA1 TimerA should be disabled and set to 0xFF for PSID:
      self.ram[CRB] = 0x00
    }
    cia2_mem_start => {
      //VICbank-selector default
      self.ram[PRA] = 0x03
      self.rom[PRA] = 0x03

      //
      self.ram[TA_LO] = 0xFF
      self.ram[TA_HI] = 0xFF
    }
  }
}

pub fn emulate(self : CIA, cycles : UInt8) -> Bool {
  // println(">> emulate $" + self[WR_ICR].to_hex() + " \(cycles)")
  //

  // Timer A
  if self.ram[CRA].has(cra(LOAD)) {
    // force latch into counter (strobe-input)
    self.rom[TA_HI] = self.ram[TA_HI]
    self.rom[TA_LO] = self.ram[TA_LO]
  } else if (self.ram[CRA] & (cra(START) | cra(INMODE))).has(cra(START)) { // Enabled, counts Phi2
    //count timer
    let mut tmp = (self.rom[TA_HI] << 8) + self.rom[TA_LO] - cycles
    if tmp <= 0 { // Timer counted down
      tmp += (self.ram[TA_HI] << 8) + self.ram[TA_LO] //reload timer
      if self.ram[CRA].has(cra(RUNMODE)) {
        self.ram[CRA] = self.ram[CRA].clr(cra(START)) //disable if one-shot
      }
      self.rom[ICR] = self.rom[ICR].set(icr(TA))
      if self.ram[ICR].has(icr(TA)) { //generate interrupt if mask allows
        self.rom[ICR] = self.rom[ICR].set(icr(IR))
      }
    }
    self.rom[TA_HI] = tmp >> 8
    self.rom[TA_LO] = tmp & 0xFF
  }
  self.ram[CRA] = self.ram[CRA].clr(cra(LOAD)) //strobe is edge-sensitive
  self.rom[CRA] = self.ram[CRA] //control-registers are readable

  // TimerB
  if self.ram[CRB].has(crb(LOAD)) {
    //force latch into counter (strobe-input)
    self.rom[TB_HI] = self.ram[TB_HI]
    self.rom[TB_LO] = self.ram[TB_LO]
    //what about clocking TimerB by TimerA? (maybe not used in any music)
  } else if (self.ram[CRB] & (crb(START) | crb(INMODE))).has(crb(START)) { //Enabled, counts Phi2
    //count timer
    let mut tmp = (self.rom[TB_HI] << 8) + self.rom[TB_LO] - cycles
    if tmp <= 0 { // Timer counted down
      tmp += (self.ram[TB_HI] << 8) + self.ram[TB_LO] //reload timer
      if self.ram[CRB].has(cra(RUNMODE)) {
        self.ram[CRB] = self.ram[CRB].clr(crb(START)) //disable if one-shot
      }
      self.rom[ICR] = self.rom[ICR].set(icr(TB))
      if self.ram[ICR].has(icr(TB)) { //generate interrupt if mask allows
        self.rom[ICR] = self.rom[ICR].set(icr(IR))
      }
    }
    self.rom[TB_HI] = tmp >> 8
    self.rom[TB_LO] = tmp & 0xFF
  }
  self.ram[CRB] = self.ram[CRB].clr(crb(LOAD)) //strobe is edge-sensitive
  self.rom[CRB] = self.ram[CRB] //control-registers are readable

  //
  // println("<< emulate $" + self[WR_ICR].to_hex() + " \(cycles)")
  self.rom[ICR].has(icr(IR))
}

/// The `MASK` register provides convenient control of individual mask bits.
/// When writing to the `MASK` register, if bit 7 (`SET`/`CLEAR`) of data written is a
/// `ZERO`, any mask bit written with a `ONE` will be cleared, while those mask bits written with a zero will be unaffected.
/// If bit 7 of the data written is a `ONE`, any mask bit written with a one will be set, while those mask bits written with a zero will be unaffected.
/// In order for an interrupt flag to set `IR` and generate an Interrupt Request, the corresponding `MASK` bit must be set.
pub fn writeCIAIRQmask(self : CIA, mask : UInt8) -> Unit {
  println(">> writeCIAIRQmask $" + self.ram[ICR].to_hex() + " \(mask)")
  match mask.0 & 0x80 {
    0 => self.ram[ICR] = self.ram[ICR].clr(mask & 0x1F) // CLEAR
    _ => self.ram[ICR] = self.ram[ICR].set(mask & 0x1F) // SET
  }
  println("<< writeCIAIRQmask $" + self.ram[ICR].to_hex())
}

pub fn acknowledgeCIAIRQ(self : CIA) -> Unit {
  // println(">> acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
  self.rom[ICR] = 0x00 // reading a CIA interrupt-register clears its read-part and IRQ-flag
  // println("<< acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
}

// fn op_get(self : CIA, register : Register) -> UInt8 {
//   println("CIA::get \(register)")
//   let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
//   if self.baseaddress + address < cia_mem_start || self.baseaddress + address > cia_mem_end {
//     // self.dump()
//     println("CIA \(register) → $" + UInt8(self.mem[address % 0x100]).to_hex())
//     abort("get out of bounds")
//   }
//   // println("CIA \(register) → $" + self.mem[address % 0x100].to_hex())
//   // match register {
//   //   /// FIXME: depends on memory bank?
//   //   RD_ICR => self.acknowledgeCIAIRQ()
//   // }
//   // self.mem[address].0
//   self.r(address)
// }

// fn op_set(self : CIA, register : Register, value : UInt8) -> Unit {
//   println("CIA::set \(register) = #$" + value.to_hex())
//   let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
//   if self.baseaddress + address < cia_mem_start || self.baseaddress + address > cia_mem_end {
//     // self.dump()
//     println("CIA \(register) ← $" + value.to_hex())
//     abort("set out of bounds")
//   }
//   // println("CIA \(register) ← $" + value.to_hex())
//   // match register {
//   //   /// FIXME: depends on memory bank?
//   //   // WR_ICR => self.writeCIAIRQmask(value) //only writing 1 to $d019 bit0 would acknowledge, not any value (but RMW instructions write $d019 back before mod.)
//   //   // WR_SDR => self.mem[address] = value.0
//   //   _ => self.mem[address] = value.0
//   // }
//   self.w(address, value)
// }

test "cia1_instantiate" {
  let timer = 3
  //
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  //
  cia.ram[TA_HI] = 0
  cia.ram[TA_LO] = timer
  //
  cia.writeCIAIRQmask(0x00)
  //
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], 0)
  //
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(NONE))
  //
  @test.eq!(cia.ram[ICR], icr(TA) | icr(IR)) // should be NONE
  @test.eq!(cia.rom[ICR], icr(NONE))
}

test "cia1_timera" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  cia.ram[TA_HI] = 0
  cia.ram[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  cia.ram[CRA] = cra(START)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(NONE))
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer - 1)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(TA) | icr(IR))
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer - 2)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(TA) | icr(IR))
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
}

test "cia1_timera_forceload" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  cia.ram[TA_HI] = 0
  cia.ram[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  cia.ram[CRA] = cra(START) | cra(LOAD)
  @test.eq!(cia.ram[CRA], cra(START) | cra(LOAD))
  @test.eq!(cia.rom[CRA], cra(NONE))
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer - 1)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer - 2)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), true) // interrupt happened
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer)
  @test.eq!(cia.ram[CRA], cra(START))
  @test.eq!(cia.rom[CRA], cra(START))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
}

test "cia1_timera_oneshot" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  cia.ram[TA_HI] = 0
  cia.ram[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
  //
  cia.ram[CRA] = cra(START) | cra(RUNMODE)
  @test.eq!(cia.ram[CRA], cra(START) | cra(RUNMODE))
  @test.eq!(cia.rom[CRA], cra(NONE))
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia.ram[TA_HI], 0)
  @test.eq!(cia.ram[TA_LO], timer)
  @test.eq!(cia.rom[TA_HI], 0)
  @test.eq!(cia.rom[TA_LO], timer - 1)
  @test.eq!(cia.ram[CRA], cra(RUNMODE))
  @test.eq!(cia.rom[CRA], cra(RUNMODE))
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia.ram[ICR], icr(SC) | icr(TA))
  @test.eq!(cia.rom[ICR], icr(NONE))
}
