/// 6526
///
/// $DC00-$DCFF CIA #1
/// $DC00-$DC0F Complex Interface Adapter (CIA) #1 Registers
/// $DC10-$DCFF CIA #1 register images (repeated every $10, 16 bytes).
///
/// $DD00-$DDFF CIA #2
/// $DD00-$DD0F Complex Interface Adapter (CIA) #2 Registers
/// $DD10-$DDFF CIA #2 Register Images  The result is that every 16-byte area in this 256-byte block is a mirror of every other.

let cia_mem_upper = 0xDC00

let cia_mem_lower = 0xDDFF

let cia_mem_length = 0x00FF

struct CIA {
  mem : @cpu.Memory
  baseaddress : Int
}

pub fn CIA::new(
  cpu : @cpu.CPU,
  baseaddress : Int,
  ~videoStandard : VideoStandard = Unknown
) -> CIA {
  println("CIA::new")
  let mem = @cpu.Memory::new(length=cia_mem_length)
  let cia : CIA = { mem, baseaddress }
  cpu.mem().hook(
    cia_mem_lower,
    cia_mem_upper,
    fn(address : Int) {
      println("CIA::r")
      cia.r(address).0
    },
    fn(address : Int, value : Int) {
      println("CIA::w")
      cia.w(address, value)
    },
  )
  cia.reset(~videoStandard)
  cia
}

pub fn reset(self : CIA, ~videoStandard : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=cia_mem_length)
  self.mem.reset()

  //
  if self.baseaddress == 0xDC00 {
    //Imitate CIA1 keyboard/joy port, some tunes check if buttons are not pressed
    self[RD_PRA] = 0x10
    self[RD_PRB] = 0xFF

    //initialize CIAs
    self[WR_TA_LO] = match videoStandard {
      NTSC => 0x24
      PAL => 0x40
      _ => 0x00
    }
    self[WR_TA_HI] = match videoStandard {
      NTSC => 0x95
      PAL => 0x42
      _ => 0x00
    }

    //Reset-default, but for PSID CIA1 TimerA IRQ should be enabled anyway if SID is CIA-timed
    self[WR_ICR] = 0x81

    //some tunes (and PSID doc) expect already running CIA (Reset-default)
    self[WR_CRA] = 0x01
    //All counters other than CIA1 TimerA should be disabled and set to 0xFF for PSID:
    self[WR_CRB] = 0x00
  } else if self.baseaddress == 0xDD00 {
    //VICbank-selector default
    self[WR_PRA] = 0x03
    self[RD_PRA] = 0x03

    //
    self[WR_TA_LO] = 0xFF
    self[WR_TA_HI] = 0xFF
  }
}

pub fn emulate(self : CIA, cycles : UInt8) -> Bool {
  // println(">> emulate $" + self[WR_ICR].to_hex() + " \(cycles)")
  //

  // Timer A
  if self[WR_CRA].has(cra(LOAD)) {
    // force latch into counter (strobe-input)
    self[RD_TA_HI] = self[WR_TA_HI]
    self[RD_TA_LO] = self[WR_TA_LO]
  } else if (self[WR_CRA] & (cra(START) | cra(INMODE))).has(cra(START)) { // Enabled, counts Phi2
    //count timer
    let mut tmp = (self[RD_TA_HI] << 8) + self[RD_TA_LO] - cycles
    if tmp <= 0 { // Timer counted down
      tmp += (self[WR_TA_HI] << 8) + self[WR_TA_LO] //reload timer
      if self[WR_CRA].has(cra(RUNMODE)) {
        self[WR_CRA] = self[WR_CRA].clr(cra(START)) //disable if one-shot
      }
      self[RD_ICR] = self[RD_ICR].set(icr(TA))
      if self[WR_ICR].has(icr(TA)) { //generate interrupt if mask allows
        self[RD_ICR] = self[RD_ICR].set(icr(IR))
      }
    }
    self[RD_TA_HI] = tmp >> 8
    self[RD_TA_LO] = tmp & 0xFF
  }
  self[WR_CRA] = self[WR_CRA].clr(cra(LOAD)) //strobe is edge-sensitive
  self[RD_CRA] = self[WR_CRA] //control-registers are readable

  // TimerB
  if self[WR_CRB].has(crb(LOAD)) {
    //force latch into counter (strobe-input)
    self[RD_TB_HI] = self[WR_TB_HI]
    self[RD_TB_LO] = self[WR_TB_LO]
    //what about clocking TimerB by TimerA? (maybe not used in any music)
  } else if (self[WR_CRB] & (crb(START) | crb(INMODE))).has(crb(START)) { //Enabled, counts Phi2
    //count timer
    let mut tmp = (self[RD_TB_HI] << 8) + self[RD_TB_LO] - cycles
    if tmp <= 0 { // Timer counted down
      tmp += (self[WR_TB_HI] << 8) + self[WR_TB_LO] //reload timer
      if self[WR_CRB].has(cra(RUNMODE)) {
        self[WR_CRB] = self[WR_CRB].clr(crb(START)) //disable if one-shot
      }
      self[RD_ICR] = self[RD_ICR].set(icr(TB))
      if self[WR_ICR].has(icr(TB)) { //generate interrupt if mask allows
        self[RD_ICR] = self[RD_ICR].set(icr(IR))
      }
    }
    self[RD_TB_HI] = tmp >> 8
    self[RD_TB_LO] = tmp & 0xFF
  }
  self[WR_CRB] = self[WR_CRB].clr(crb(LOAD)) //strobe is edge-sensitive
  self[RD_CRB] = self[WR_CRB] //control-registers are readable

  //
  // println("<< emulate $" + self[WR_ICR].to_hex() + " \(cycles)")
  self[RD_ICR].has(icr(IR))
}

/// The `MASK` register provides convenient control of individual mask bits.
/// When writing to the `MASK` register, if bit 7 (`SET`/`CLEAR`) of data written is a
/// `ZERO`, any mask bit written with a on will be cleared, while those mask bits written with a zero will be unaffected.
/// If bit 7 of the data written is a `ONE`, any mask bit written with a one will be set, while those mask bits written with a zero will be unaffected.
/// In order for an interrupt flag to set `IR` and generate an Interrupt Request, the corresponding `MASK` bit must be set.
pub fn writeCIAIRQmask(self : CIA, mask : UInt8) -> Unit {
  // println(">> writeCIAIRQmask $" + self[WR_ICR].to_hex() + " \(mask)")
  match mask.0 & 0x80 {
    0 => self[WR_ICR] = self[WR_ICR].clr(mask & 0x1F) // CLEAR
    _ => self[WR_ICR] = self[WR_ICR].set(mask & 0x1F) // SET
  }
  // println("<< writeCIAIRQmask $" + self[WR_ICR].to_hex())
}

pub fn acknowledgeCIAIRQ(self : CIA) -> Unit {
  // println(">> acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
  self[RD_ICR] = 0x00 // reading a CIA interrupt-register clears its read-part and IRQ-flag
  // println("<< acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
}

fn r(self : CIA, address : UInt16) -> UInt8 {
  println("CIA $" + address.to_hex() + " → $" + self.mem[address.0].to_hex())
  self.mem[address.0].0
}

fn w(self : CIA, address : UInt16, value : UInt8) -> Unit {
  // println("CIA $" + address.to_hex() + " ← $" + self.mem[address.0].to_hex())
  self.mem[address.0] = value.0
}

fn op_get(self : CIA, register : Register) -> UInt8 {
  println("CIA get")
  let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
  if self.baseaddress + address < cia_mem_upper || self.baseaddress + address > cia_mem_lower {
    // self.dump()
    println("CIA \(register) → $" + self.mem[address % 0x100].to_hex())
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

fn op_set(self : CIA, register : Register, value : UInt8) -> Unit {
  println("CIA::set \(register) = #$" + value.to_hex())
  let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
  if self.baseaddress + address < cia_mem_upper || self.baseaddress + address > cia_mem_lower {
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

test "cia1_instantiate" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let mem = cpu.mem()
  let cia = CIA::new(cpu, cia_mem_upper)
  cia[WR_TA_HI] = 0
  cia[WR_TA_LO] = timer
  cia.writeCIAIRQmask(0x00)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], 0)
  @test.eq!(cia[WR_CRA], cra(NONE))
  @test.eq!(cia[RD_CRA], cra(NONE))
  @test.eq!(cia[WR_ICR], icr(NONE))
  @test.eq!(cia[RD_ICR], icr(NONE))
}

test "cia1_timera" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let mem = cpu.mem()
  let cia = CIA::new(cpu, cia_mem_upper)
  cia[WR_TA_HI] = 0
  cia[WR_TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  cia[WR_CRA] = cra(START)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(NONE))
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer - 1)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(TA) | icr(IR))
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer - 2)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(TA) | icr(IR))
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
}

test "cia1_timera_forceload" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let mem = cpu.mem()
  let cia = CIA::new(cpu, cia_mem_upper)
  cia[WR_TA_HI] = 0
  cia[WR_TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  cia[WR_CRA] = cra(START) | cra(LOAD)
  @test.eq!(cia[WR_CRA], cra(START) | cra(LOAD))
  @test.eq!(cia[RD_CRA], cra(NONE))
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer - 1)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), false)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer - 2)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  @test.eq!(cia.emulate(1), true) // interrupt happened
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer)
  @test.eq!(cia[WR_CRA], cra(START))
  @test.eq!(cia[RD_CRA], cra(START))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
}

test "cia1_timera_oneshot" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let mem = cpu.mem()
  let cia = CIA::new(cpu, cia_mem_upper)
  cia[WR_TA_HI] = 0
  cia[WR_TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
  //
  cia[WR_CRA] = cra(START) | cra(RUNMODE)
  @test.eq!(cia[WR_CRA], cra(START) | cra(RUNMODE))
  @test.eq!(cia[RD_CRA], cra(NONE))
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], 0)
  //
  @test.eq!(cia.emulate(1), true)
  @test.eq!(cia[WR_TA_HI], 0)
  @test.eq!(cia[WR_TA_LO], timer)
  @test.eq!(cia[RD_TA_HI], 0)
  @test.eq!(cia[RD_TA_LO], timer - 1)
  @test.eq!(cia[WR_CRA], cra(RUNMODE))
  @test.eq!(cia[RD_CRA], cra(RUNMODE))
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(TA) | icr(IR))
  //
  cia.acknowledgeCIAIRQ()
  @test.eq!(cia[WR_ICR], icr(TA))
  @test.eq!(cia[RD_ICR], icr(NONE))
}
