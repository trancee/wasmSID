/// 6526
///
/// $DC00-$DCFF CIA #1
/// $DC00-$DC0F Complex Interface Adapter (CIA) #1 Registers
/// $DC10-$DCFF CIA #1 register images (repeated every $10, 16 bytes).
///
/// $DD00-$DDFF CIA #2
/// $DD00-$DD0F Complex Interface Adapter (CIA) #2 Registers
/// $DD10-$DDFF CIA #2 Register Images  The result is that every 16-byte area in this 256-byte block is a mirror of every other.

struct CIA {
  mem : @cpu.Memory
  baseaddress : Int // CIA-baseaddress location in C64-memory (IO)
}

pub fn CIA::new(mem : @cpu.Memory, baseaddress : Int) -> CIA {
  let cia : CIA = { mem, baseaddress }
  cia.reset()
  cia
}

pub fn reset(self : CIA) -> Unit {
  // Read
  self[RD_PRA] = 0x00
  self[RD_PRB] = 0x00
  self[RD_DDRA] = 0x00
  self[RD_DDRB] = 0x00
  self[RD_TA_LO] = 0x00
  self[RD_TA_HI] = 0x00
  self[RD_TB_LO] = 0x00
  self[RD_TB_HI] = 0x00
  self[RD_TOD_10TH] = 0x00
  self[RD_TOD_SEC] = 0x00
  self[RD_TOD_MIN] = 0x00
  self[RD_TOD_HR] = 0x00
  self[RD_SDR] = 0x00
  self[RD_ICR] = 0x00
  self[RD_CRA] = 0x00
  self[RD_CRB] = 0x00

  // Write
  self[WR_PRA] = 0x00
  self[WR_PRB] = 0x00
  self[WR_DDRA] = 0x00
  self[WR_DDRB] = 0x00
  self[WR_TA_LO] = 0x00
  self[WR_TA_HI] = 0x00
  self[WR_TB_LO] = 0x00
  self[WR_TB_HI] = 0x00
  self[WR_TOD_10TH] = 0x00
  self[WR_TOD_SEC] = 0x00
  self[WR_TOD_MIN] = 0x00
  self[WR_TOD_HR] = 0x00
  self[WR_SDR] = 0x00
  self[WR_ICR] = 0x00
  self[WR_CRA] = 0x00
  self[WR_CRB] = 0x00
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
pub fn writeCIAIRQmask(self : CIA, mask : Int) -> Unit {
  // println(">> writeCIAIRQmask $" + self[WR_ICR].to_hex() + " \(mask)")
  match mask & 0x80 {
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

fn op_get(self : CIA, register : Register) -> UInt8 {
  let address = self.baseaddress + register[register] % 0x10 // (repeated every $10, 16 bytes)
  if address < 0xDC00 || address > 0xDDFF {
    // self.dump()
    println("CIA::get out of bounds")
    abort("CIA::get out of bounds")
  }
  println("CIA \(register) → $" + self.mem[address % 0x100].to_hex())
  self.mem[address].0
}

fn op_set(self : CIA, register : Register, value : UInt8) -> Unit {
  let address = self.baseaddress + register[register] % 0x10 // (repeated every $10, 16 bytes)
  if address < 0xDC00 || address > 0xDDFF {
    // self.dump()
    println("CIA::set out of bounds")
    abort("CIA::set out of bounds")
  }
  println("CIA \(register) ← $" + value.to_hex())
  self.mem[address] = value.0
}

enum InterruptControlStatusRegister {
  TIMERA_UNDERFLOW
  TIMERB_UNDERFLOW
  TOD
  RECEIVED
  FLAG
  NMI_GENERATED
}

test "cia1_instantiate" {
  let timer = 3
  let cpu = @cpu.CPU::new()
  let mem = cpu.mem()
  let cia = CIA::new(mem, 0xDC00)
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
  let cia = CIA::new(mem, 0xDC00)
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
  let cia = CIA::new(mem, 0xDC00)
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
  let cia = CIA::new(mem, 0xDC00)
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
