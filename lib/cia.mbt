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

// struct Memory {
//   mem : FixedArray[Int]
//   baseaddress : Int
// }

// pub fn Memory::new(
//   size : Int,
//   ~value : Int = 0x00,
//   ~baseaddress : Int
// ) -> Memory {
//   let mem = FixedArray::make(size + 1, value)
//   { mem, baseaddress }
// }

// fn reset(self : Memory, ~value : Int = 0x00) -> Unit {
//   for i = 0; i < self.mem.length(); i = i + 1 {
//     self.mem[i] = value
//   }
// }

// fn r(self : Memory, address : UInt16) -> UInt8 {
//   println(
//     "CIA $" + address.to_hex() + " → $" + UInt8(self.mem[address.0]).to_hex(),
//   )
//   self.mem[address.0]
// }

// fn w(self : Memory, address : UInt16, value : UInt8) -> Unit {
//   println(
//     "CIA $" + address.to_hex() + " ← $" + UInt8(self.mem[address.0]).to_hex(),
//   )
//   self.mem[address.0] = value.0
// }

// fn op_get(self : Memory, register : Register) -> UInt8 {
//   println("CIA::get \{register}")
//   let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
//   if self.baseaddress + address < cia_mem_start ||
//     self.baseaddress + address > cia_mem_end {
//     // self.dump()
//     println("CIA \{register} → $" + UInt8(self.mem[address % 0x100]).to_hex())
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

// fn op_set(self : Memory, register : Register, value : UInt8) -> Unit {
//   println("CIA::set \{register} = #$" + value.to_hex())
//   let address = register[register] % 0x10 // (repeated every $10, 16 bytes)
//   if self.baseaddress + address < cia_mem_start ||
//     self.baseaddress + address > cia_mem_end {
//     // self.dump()
//     println("CIA \{register} ← $" + value.to_hex())
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

struct CIA {
  mem : FixedArray[Int]
  baseaddress : Int

  // ram : Memory
  // rom : Memory

  //
  mut timerA : Int
  mut timerB : UInt16

  //
  register : CIARegister
}

pub fn CIA::new(
  cpu : @cpu.CPU,
  baseaddress : Int,
  ~videoStandard : VideoStandard = Unknown
) -> CIA {
  println("CIA::new")
  let mem = FixedArray::make(cia_mem_size + 1, 0x00)
  // let ram = Memory::new(cia_mem_size + 1, ~baseaddress)
  // let rom = Memory::new(cia_mem_size + 1, ~baseaddress)
  // let cia : CIA = { ram, rom, baseaddress }
  let cia : CIA = {
    mem,
    baseaddress,

    //
    timerA: Int::default(),
    timerB: UInt16::default(),

    //
    register: CIARegister::default(),
  }
  cpu
  .mem()
  .hook(
    cia_mem_start,
    cia_mem_end,
    mem,
    fn(address : Int) {
      let register = try {
        CIAregister::from_int!(address - baseaddress)
      } catch {
        err => {
          println(err)
          panic()
        }
      }
      cia[register].0
    },
    fn(address : Int, value : Int) {
      let register = try {
        CIAregister::from_int!(address - baseaddress)
      } catch {
        err => {
          println(err)
          panic()
        }
      }
      cia[register] = value
    },
  )
  cia.reset(~videoStandard)
  cia
}

pub fn reset(self : CIA, ~videoStandard : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=cia_mem_length)
  // self.rom.reset()
  // self.ram.reset()
  for i = 0; i < self.mem.length(); i = i + 1 {
    self.mem[i] = 0x00
  }

  //
  match self.baseaddress {
    cia1_mem_start => {
      //Imitate CIA1 keyboard/joy port, some tunes check if buttons are not pressed
      self[PRA] = 0x10
      self[PRB] = 0xFF

      //initialize CIAs
      self[TA_LO] = match videoStandard {
        NTSC => 0x24
        PAL => 0x40
        _ => 0x00
      }
      self[TA_HI] = match videoStandard {
        NTSC => 0x95
        PAL => 0x42
        _ => 0x00
      }

      // //Reset-default, but for PSID CIA1 TimerA IRQ should be enabled anyway if SID is CIA-timed
      // self[ICR] = 0x81

      // //some tunes (and PSID doc) expect already running CIA (Reset-default)
      // self[CRA] = 0x01
      // //All counters other than CIA1 TimerA should be disabled and set to 0xFF for PSID:
      // self[CRB] = 0x00
    }
    cia2_mem_start => {
      //VICbank-selector default
      self[PRA] = 0x03

      //
      self[TA_LO] = 0xFF
      self[TA_HI] = 0xFF
    }
  }
}

pub fn emulate(self : CIA, cycles : Int) -> Bool {
  // println(">> emulate $" + self[ICR].to_hex() + " (\{cycles})")
  //

  // Timer A
  if self.register.controlA.forceLoad {
    println("TimerA Force Load")
    // force latch into counter (strobe-input)
    self.register.timerA = self.timerA
    self.register.controlA.forceLoad = false //strobe is edge-sensitive
  } else if self.register.controlA.start { // Enabled, counts Phi2
    //count timer
    let mut tmp = self.register.timerA - cycles
    // println("TimerA Start #\{tmp}")
    if tmp <= 0 { // Timer counted down
      // println("TimerA Finish")
      tmp += self.timerA //reload timer
      if self.register.controlA.runMode {
        println("TimerA OneShot")
        self.register.controlA.start = false //disable if one-shot
      }
      self.register.interruptControl.timerA = true
      if self.register.interruptControl.timerA { //generate interrupt if mask allows
        self.register.interruptControl.interrupt = true
      }
    }
    self.register.timerA = tmp
  }
  // self[CRA] = self[CRA].clr(cra(LOAD)) //strobe is edge-sensitive
  // self[RD_CRA] = self[WR_CRA] //control-registers are readable

  // // TimerB
  // if self.ram[CRB].has(crb(LOAD)) {
  //   //force latch into counter (strobe-input)
  //   self.rom[TB_HI] = self.ram[TB_HI]
  //   self.rom[TB_LO] = self.ram[TB_LO]
  //   //what about clocking TimerB by TimerA? (maybe not used in any music)
  // } else if (self.ram[CRB] & (crb(START) | crb(INMODE))).has(crb(START)) { //Enabled, counts Phi2
  //   //count timer
  //   let mut tmp = (self.rom[TB_HI] << 8) + self.rom[TB_LO] - cycles
  //   if tmp <= 0 { // Timer counted down
  //     tmp += (self.ram[TB_HI] << 8) + self.ram[TB_LO] //reload timer
  //     if self.ram[CRB].has(cra(RUNMODE)) {
  //       self.ram[CRB] = self.ram[CRB].clr(crb(START)) //disable if one-shot
  //     }
  //     self.rom[ICR] = self.rom[ICR].set(icr(TB))
  //     if self.ram[ICR].has(icr(TB)) { //generate interrupt if mask allows
  //       self.rom[ICR] = self.rom[ICR].set(icr(IR))
  //     }
  //   }
  //   self.rom[TB_HI] = tmp >> 8
  //   self.rom[TB_LO] = tmp & 0xFF
  // }
  // self.ram[CRB] = self.ram[CRB].clr(crb(LOAD)) //strobe is edge-sensitive
  // self.rom[CRB] = self.ram[CRB] //control-registers are readable

  //
  // println("<< emulate $" + self[WR_ICR].to_hex() + " \(cycles)")

  self.register.interruptControl.interrupt
}

/// The `MASK` register provides convenient control of individual mask bits.
/// When writing to the `MASK` register, if bit 7 (`SET`/`CLEAR`) of data written is a
/// `ZERO`, any mask bit written with a `ONE` will be cleared, while those mask bits written with a zero will be unaffected.
/// If bit 7 of the data written is a `ONE`, any mask bit written with a one will be set, while those mask bits written with a zero will be unaffected.
/// In order for an interrupt flag to set `IR` and generate an Interrupt Request, the corresponding `MASK` bit must be set.
pub fn writeCIAIRQmask(self : CIA, mask : UInt8) -> Unit {
  println(
    ">> writeCIAIRQmask #$" +
    self[ICR].to_hex() +
    " #$" +
    (mask & 0x1F).to_hex(),
  )
  match mask.bit(7) {
    true => self[ICR] = self[ICR].set(mask & 0x1F) // SET
    false => self[ICR] = self[ICR].clr(mask & 0x1F) // CLEAR
  }
  println("<< writeCIAIRQmask $" + self[ICR].to_hex())
}

pub fn acknowledgeCIAIRQ(self : CIA) -> Unit {
  // println(">> acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
  self[ICR] = 0x00 // reading a CIA interrupt-register clears its read-part and IRQ-flag
  // println("<< acknowledgeCIAIRQ $" + self[RD_ICR].to_hex())
}

fn op_get(self : CIA, register : CIAregister) -> UInt8 {
  let address = cia(register) % 0x10 // (repeated every $10, 16 bytes)
  // println(
  //   "💻 CIA $" +
  //   UInt16(self.baseaddress + address).to_hex() +
  //   " → #$" +
  //   UInt8(self.mem[address]).to_hex() +
  //   " | \{register}",
  // )
  if self.baseaddress + address < cia_mem_start ||
    self.baseaddress + address > cia_mem_end {
    // self.dump()
    println(
      "CIA \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " → #$" +
      UInt8(self.mem[address]).to_hex(),
    )
    abort("out of bounds")
  }
  match register {
    PRA | RD_PRA =>
      /// Bit 0:  Select to read keyboard column 0
      ///         Read joystick 2 up direction
      (self.register.portA[0].to_int() << 0) |
      /// Bit 1:  Select to read keyboard column 1
      ///         Read joystick 2 down direction
      (self.register.portA[1].to_int() << 1) |
      /// Bit 2:  Select to read keyboard column 2
      ///         Read joystick 2 left direction
      ///         Read paddle 1 fire button
      (self.register.portA[2].to_int() << 2) |
      /// Bit 3:  Select to read keyboard column 3
      ///         Read joystick 2 right direction
      ///         Read paddle 2 fire button
      (self.register.portA[3].to_int() << 3) |
      /// Bit 4:  Select to read keyboard column 4
      ///         Read joystick 2 fire button
      (self.register.portA[4].to_int() << 4) |
      /// Bit 5:  Select to read keyboard column 5
      (self.register.portA[5].to_int() << 5) |
      /// Bit 6:  Select to read keyboard column 6
      ///         Select to read paddles on Port A or B
      (self.register.portA[6].to_int() << 6) |
      /// Bit 7:  Select to read keyboard column 7
      ///         Select to read paddles on Port A or B
      (self.register.portA[7].to_int() << 7)
    PRB | RD_PRB =>
      /// Bit 0:  Read keyboard row 0
      ///         Read joystick 1 up direction
      (self.register.portB[0].to_int() << 0) |
      /// Bit 1:  Read keyboard row 1
      ///         Read joystick 1 down direction
      (self.register.portB[1].to_int() << 1) |
      /// Bit 2:  Read keyboard row 2
      ///         Read joystick 1 left direction
      ///         Read paddle 1 fire button
      (self.register.portB[2].to_int() << 2) |
      /// Bit 3:  Read keyboard row 3
      ///         Read joystick 1 right direction
      ///         Read paddle 2 fire button
      (self.register.portB[3].to_int() << 3) |
      /// Bit 4:  Read keyboard row 4
      ///         Read joystick 1 fire button
      (self.register.portB[4].to_int() << 4) |
      /// Bit 5:  Read keyboard row 5
      (self.register.portB[5].to_int() << 5) |
      /// Bit 6:  Read keyboard row 6
      ///         Toggle or pulse data output for Timer A
      (self.register.portB[6].to_int() << 6) |
      /// Bit 7:  Read keyboard row 7
      ///         Toggle or pulse data output for Timer B
      (self.register.portB[7].to_int() << 7)
    DDRA | RD_DDRA =>
      /// Bit 0:  Select Bit 0 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[0].to_int() << 0) |
      /// Bit 1:  Select Bit 1 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[1].to_int() << 1) |
      /// Bit 2:  Select Bit 2 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[2].to_int() << 2) |
      /// Bit 3:  Select Bit 3 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[3].to_int() << 3) |
      /// Bit 4:  Select Bit 4 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[4].to_int() << 4) |
      /// Bit 5:  Select Bit 5 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[5].to_int() << 5) |
      /// Bit 6:  Select Bit 6 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[6].to_int() << 6) |
      /// Bit 7:  Select Bit 7 of Data Port A for input or output (0=input, 1=output)
      (self.register.directionA[7].to_int() << 7)
    DDRB | RD_DDRB =>
      /// Bit 0:  Select Bit 0 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[0].to_int() << 0) |
      /// Bit 1:  Select Bit 1 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[1].to_int() << 1) |
      /// Bit 2:  Select Bit 2 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[2].to_int() << 2) |
      /// Bit 3:  Select Bit 3 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[3].to_int() << 3) |
      /// Bit 4:  Select Bit 4 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[4].to_int() << 4) |
      /// Bit 5:  Select Bit 5 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[5].to_int() << 5) |
      /// Bit 6:  Select Bit 6 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[6].to_int() << 6) |
      /// Bit 7:  Select Bit 7 of Data Port B for input or output (0=input, 1=output)
      (self.register.directionB[7].to_int() << 7)
    TA_LO | RD_TA_LO => u8(self.register.timerA)
    TA_HI | RD_TA_HI => u8(self.register.timerA >> 8)
    TB_LO | RD_TB_LO => u8(self.register.timerB)
    TB_HI | RD_TB_HI => u8(self.register.timerB >> 8)
    TOD_10TH | RD_TOD_10TH =>
      /// Bits 0-3:  Time of Day tenths of second digit (BCD)
      /// Bits 4-7:  Unused
      self.register.timeOfDay.tenth & 0b00001111
    TOD_SEC | RD_TOD_SEC =>
      /// Bits 0-3:  Second digit of Time of Day seconds (BCD)
      /// Bits 4-6:  First digit of Time of Day seconds (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.seconds & 0b01111111
    TOD_MIN | RD_TOD_MIN =>
      /// Bits 0-3:  Second digit of Time of Day minutes (BCD)
      /// Bits 4-6:  First digit of Time of Day minutes (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.minutes & 0b01111111
    TOD_HR | RD_TOD_HR =>
      /// Bits 0-3:  Second digit of Time of Day hours (BCD)
      /// Bit 4:  First digit of Time of Day hours (BCD)
      /// Bits 5-6:  Unused
      /// Bit 7:  AM/PM Flag (1=PM, 0=AM)
      (self.register.timeOfDay.hours & 0b00011111) |
      (self.register.timeOfDay.pm.to_int() << 7)
    SDR | RD_SDR => self.register.serialData
    ICR | RD_ICR =>
      /// Bit 0:  Read / did Timer A count down to 0?  (1=yes)
      ///         Write/ enable or disable Timer A interrupt (1=enable, 0=disable)
      (self.register.interruptControl.timerA.to_int() << 0) |
      /// Bit 1:  Read / did Timer B count down to 0?  (1=yes)
      ///         Write/ enable or disable Timer B interrupt (1=enable, 0=disable)
      (self.register.interruptControl.timerB.to_int() << 1) |
      /// Bit 2:  Read / did Time of Day Clock reach the alarm time?  (1=yes)
      ///         Write/ enable or disable TOD clock alarm interrupt (1=enable,
      ///         0=disable)
      (self.register.interruptControl.alarm.to_int() << 2) |
      /// Bit 3:  Read / did the serial shift register finish a byte? (1=yes)
      ///         Write/ enable or disable serial shift register interrupt (1=enable,
      ///         0=disable)
      (self.register.interruptControl.serial.to_int() << 3) |
      /// Bit 4:  Read / was a signal sent on the flag line?  (1=yes)
      ///         Write/ enable or disable FLAG line interrupt (1=enable, 0=disable)
      (self.register.interruptControl.flag.to_int() << 4) |
      /// Bit 5:  Not used
      /// Bit 6:  Not used
      /// Bit 7:  Read / did any CIA #1 source cause an interrupt?  (1=yes)
      ///         Write/ set or clear bits of this register (1=bits written with 1 will
      ///         be set, 0=bits written with 1 will be cleared)
      (self.register.interruptControl.interrupt.to_int() << 7)
    CRA | RD_CRA =>
      /// Bit 0:  Start Timer A (1=start, 0=stop)
      (self.register.controlA.start.to_int() << 0) |
      /// Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of
      ///         Port B)
      (self.register.controlA.output.to_int() << 1) |
      /// Bit 2:  Port B output mode (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
      (self.register.controlA.outputMode.to_int() << 2) |
      /// Bit 3:  Timer A run mode (1=one-shot, 0=continuous)
      (self.register.controlA.runMode.to_int() << 3) |
      /// Bit 4:  Force latched value to be loaded to Timer A counter (1=force load
      ///         strobe)
      (self.register.controlA.forceLoad.to_int() << 4) |
      /// Bit 5:  Timer A input mode (1=count microprocessor cycles, 0=count signals on
      ///         CNT line at pin 4 of User Port)
      (
        match self.register.controlA.inputMode {
          TimerAInputMode::CountCycles => 0b01
          TimerAInputMode::CountSignals => 0b00
        } <<
        5
      ) |
      /// Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
      (self.register.controlA.serialMode.to_int() << 6) |
      /// Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
      (self.register.controlA.clockFrequency.to_int() << 7)
    CRB | RD_CRB =>
      /// Bit 0:  Start Timer B (1=start, 0=stop)
      (self.register.controlB.start.to_int() << 0) |
      /// Bit 1:  Select Timer B output on Port B (1=Timer B output appears on
      ///         Bit 7 of Port B)
      (self.register.controlB.output.to_int() << 1) |
      /// Bit 2:  Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one
      ///         cycle)
      (self.register.controlB.outputMode.to_int() << 2) |
      /// Bit 3:  Timer B run mode (1=one-shot, 0=continuous)
      (self.register.controlB.runMode.to_int() << 3) |
      /// Bit 4:  Force latched value to be loaded to Timer B counter (1=force
      ///         load strobe)
      (self.register.controlB.forceLoad.to_int() << 4) |
      /// Bits 5-6:  Timer B input mode
      ///            00 = Timer B counts microprocessor cycles
      ///            01 = Count signals on CNT line at pin 4 of User Port
      ///            10 = Count each time that Timer A counts down to 0
      ///            11 = Count Timer A 0's when CNT pulses are also present
      (
        match self.register.controlB.inputMode {
          TimerBInputMode::CountCycles => 0b00
          TimerBInputMode::CountSignals => 0b01
          TimerBInputMode::CountTimer => 0b10
          TimerBInputMode::CountZero => 0b11
        } <<
        5
      ) |
      /// Bit 7:  Select Time of Day write (0=writing to TOD registers sets
      ///         alarm, 1=writing to TOD registers sets clock)
      (self.register.controlB.writeMode.to_int() << 7)
    _ => {
      println("unknown read register \{register}")
      panic()
    }
  }
}

fn op_set(self : CIA, register : CIAregister, value : UInt8) -> Unit {
  let address = cia(register) % 0x10 // (repeated every $10, 16 bytes)
  // println(
  //   "💻 CIA $" +
  //   UInt16(self.baseaddress + address).to_hex() +
  //   " ← #$" +
  //   value.to_hex() +
  //   " | \{register}",
  // )
  if self.baseaddress + address < cia_mem_start ||
    self.baseaddress + address > cia_mem_end {
    // self.dump()
    println(
      "CIA \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex(),
    )
    abort("out of bounds")
  }
  match register {
    /// Data Port Register A
    PRA | WR_PRA => {
      /// Bit 0:  Select to read keyboard column 0
      ///         Read joystick 2 up direction
      self.register.portA[0] = value.bit(0)
      /// Bit 1:  Select to read keyboard column 1
      ///         Read joystick 2 down direction
      self.register.portA[1] = value.bit(1)
      /// Bit 2:  Select to read keyboard column 2
      ///         Read joystick 2 left direction
      ///         Read paddle 1 fire button
      self.register.portA[2] = value.bit(2)
      /// Bit 3:  Select to read keyboard column 3
      ///         Read joystick 2 right direction
      ///         Read paddle 2 fire button
      self.register.portA[3] = value.bit(3)
      /// Bit 4:  Select to read keyboard column 4
      ///         Read joystick 2 fire button
      self.register.portA[4] = value.bit(4)
      /// Bit 5:  Select to read keyboard column 5
      self.register.portA[5] = value.bit(5)
      /// Bit 6:  Select to read keyboard column 6
      ///         Select to read paddles on Port A or B
      self.register.portA[6] = value.bit(6)
      /// Bit 7:  Select to read keyboard column 7
      ///         Select to read paddles on Port A or B
      self.register.portA[7] = value.bit(7)
    }
    PRB | WR_PRB => {
      /// Bit 0:  Read keyboard row 0
      ///         Read joystick 1 up direction
      self.register.portB[0] = value.bit(0)
      /// Bit 1:  Read keyboard row 1
      ///         Read joystick 1 down direction
      self.register.portB[1] = value.bit(1)
      /// Bit 2:  Read keyboard row 2
      ///         Read joystick 1 left direction
      ///         Read paddle 1 fire button
      self.register.portB[2] = value.bit(2)
      /// Bit 3:  Read keyboard row 3
      ///         Read joystick 1 right direction
      ///         Read paddle 2 fire button
      self.register.portB[3] = value.bit(3)
      /// Bit 4:  Read keyboard row 4
      ///         Read joystick 1 fire button
      self.register.portB[4] = value.bit(4)
      /// Bit 5:  Read keyboard row 5
      self.register.portB[5] = value.bit(5)
      /// Bit 6:  Read keyboard row 6
      ///         Toggle or pulse data output for Timer A
      self.register.portB[6] = value.bit(6)
      /// Bit 7:  Read keyboard row 7
      ///         Toggle or pulse data output for Timer B
      self.register.portB[7] = value.bit(7)
    }
    DDRA | WR_DDRA => {
      /// Bit 0:  Select Bit 0 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[0] = value.bit(0)
      /// Bit 1:  Select Bit 1 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[1] = value.bit(1)
      /// Bit 2:  Select Bit 2 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[2] = value.bit(2)
      /// Bit 3:  Select Bit 3 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[3] = value.bit(3)
      /// Bit 4:  Select Bit 4 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[4] = value.bit(4)
      /// Bit 5:  Select Bit 5 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[5] = value.bit(5)
      /// Bit 6:  Select Bit 6 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[6] = value.bit(6)
      /// Bit 7:  Select Bit 7 of Data Port A for input or output (0=input, 1=output)
      self.register.directionA[7] = value.bit(7)
    }
    DDRB | WR_DDRB => {
      /// Bit 0:  Select Bit 0 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[0] = value.bit(0)
      /// Bit 1:  Select Bit 1 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[1] = value.bit(1)
      /// Bit 2:  Select Bit 2 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[2] = value.bit(2)
      /// Bit 3:  Select Bit 3 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[3] = value.bit(3)
      /// Bit 4:  Select Bit 4 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[4] = value.bit(4)
      /// Bit 5:  Select Bit 5 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[5] = value.bit(5)
      /// Bit 6:  Select Bit 6 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[6] = value.bit(6)
      /// Bit 7:  Select Bit 7 of Data Port B for input or output (0=input, 1=output)
      self.register.directionB[7] = value.bit(7)
    }
    TA_LO | WR_TA_LO => {
      self.register.timerA = self.register.timerA | u16(value).0
      self.timerA = self.register.timerA
    }
    TA_HI | WR_TA_HI => {
      self.register.timerA = self.register.timerA | (u16(value) << 8).0
      self.timerA = self.register.timerA
    }
    TB_LO | WR_TB_LO => {
      self.register.timerB = self.register.timerB | u16(value)
      self.timerB = self.register.timerB
    }
    TB_HI | WR_TB_HI => {
      self.register.timerB = self.register.timerB | (u16(value) << 8)
      self.timerB = self.register.timerB
    }
    TOD_10TH | WR_TOD_10TH =>
      /// Bits 0-3:  Time of Day tenths of second digit (BCD)
      /// Bits 4-7:  Unused
      self.register.timeOfDay.tenth = value & 0b00001111
    TOD_SEC | WR_TOD_SEC =>
      /// Bits 0-3:  Second digit of Time of Day seconds (BCD)
      /// Bits 4-6:  First digit of Time of Day seconds (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.seconds = value & 0b01111111
    TOD_MIN | WR_TOD_MIN =>
      /// Bits 0-3:  Second digit of Time of Day minutes (BCD)
      /// Bits 4-6:  First digit of Time of Day minutes (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.minutes = value & 0b01111111
    TOD_HR | WR_TOD_HR => {
      /// Bits 0-3:  Second digit of Time of Day hours (BCD)
      /// Bit 4:  First digit of Time of Day hours (BCD)
      /// Bits 5-6:  Unused
      /// Bit 7:  AM/PM Flag (1=PM, 0=AM)
      self.register.timeOfDay.hours = value & 0b00011111
      self.register.timeOfDay.pm = value.bit(7)
    }
    SDR | WR_SDR => self.register.serialData = value
    ICR | WR_ICR => {
      /// Bit 0:  Read / did Timer A count down to 0?  (1=yes)
      ///         Write/ enable or disable Timer A interrupt (1=enable, 0=disable)
      self.register.interruptControl.timerA = value.bit(0)
      /// Bit 1:  Read / did Timer B count down to 0?  (1=yes)
      ///         Write/ enable or disable Timer B interrupt (1=enable, 0=disable)
      self.register.interruptControl.timerB = value.bit(1)
      /// Bit 2:  Read / did Time of Day Clock reach the alarm time?  (1=yes)
      ///         Write/ enable or disable TOD clock alarm interrupt (1=enable,
      ///         0=disable)
      self.register.interruptControl.alarm = value.bit(2)
      /// Bit 3:  Read / did the serial shift register finish a byte? (1=yes)
      ///         Write/ enable or disable serial shift register interrupt (1=enable,
      ///         0=disable)
      self.register.interruptControl.serial = value.bit(3)
      /// Bit 4:  Read / was a signal sent on the flag line?  (1=yes)
      ///         Write/ enable or disable FLAG line interrupt (1=enable, 0=disable)
      self.register.interruptControl.flag = value.bit(4)
      /// Bit 5:  Not used
      /// Bit 6:  Not used
      /// Bit 7:  Read / did any CIA #1 source cause an interrupt?  (1=yes)
      ///         Write/ set or clear bits of this register (1=bits written with 1 will
      ///         be set, 0=bits written with 1 will be cleared)
      self.register.interruptControl.interrupt = value.bit(7)
    }
    CRA | WR_CRA => {
      /// Bit 0:  Start Timer A (1=start, 0=stop)
      self.register.controlA.start = value.bit(0)
      /// Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of
      ///         Port B)
      self.register.controlA.output = value.bit(1)
      /// Bit 2:  Port B output mode (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
      self.register.controlA.outputMode = value.bit(2)
      /// Bit 3:  Timer A run mode (1=one-shot, 0=continuous)
      self.register.controlA.runMode = value.bit(3)
      /// Bit 4:  Force latched value to be loaded to Timer A counter (1=force load
      ///         strobe)
      self.register.controlA.forceLoad = value.bit(4)
      /// Bit 5:  Timer A input mode (1=count microprocessor cycles, 0=count signals on
      ///         CNT line at pin 4 of User Port)
      self.register.controlA.inputMode = match (value & 0b00100000).0 >> 5 {
        0b01 => TimerAInputMode::CountCycles
        0b00 => TimerAInputMode::CountSignals
      }
      /// Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
      self.register.controlA.serialMode = value.bit(6)
      /// Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
      self.register.controlA.clockFrequency = value.bit(7)
    }
    CRB | WR_CRB => {
      /// Bit 0:  Start Timer B (1=start, 0=stop)
      self.register.controlB.start = value.bit(0)
      /// Bit 1:  Select Timer B output on Port B (1=Timer B output appears on
      ///         Bit 7 of Port B)
      self.register.controlB.output = value.bit(1)
      /// Bit 2:  Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one
      ///         cycle)
      self.register.controlB.outputMode = value.bit(2)
      /// Bit 3:  Timer B run mode (1=one-shot, 0=continuous)
      self.register.controlB.runMode = value.bit(3)
      /// Bit 4:  Force latched value to be loaded to Timer B counter (1=force
      ///         load strobe)
      self.register.controlB.forceLoad = value.bit(4)
      /// Bits 5-6:  Timer B input mode
      ///            00 = Timer B counts microprocessor cycles
      ///            01 = Count signals on CNT line at pin 4 of User Port
      ///            10 = Count each time that Timer A counts down to 0
      ///            11 = Count Timer A 0's when CNT pulses are also present
      self.register.controlB.inputMode = match (value & 0b01100000).0 >> 5 {
        0b00 => TimerBInputMode::CountCycles
        0b01 => TimerBInputMode::CountSignals
        0b10 => TimerBInputMode::CountTimer
        0b11 => TimerBInputMode::CountZero
      }
      /// Bit 7:  Select Time of Day write (0=writing to TOD registers sets
      ///         alarm, 1=writing to TOD registers sets clock)
      self.register.controlB.writeMode = value.bit(7)
    }
    _ => {
      println("unknown write register \{register}")
      panic()
    }
  }
}

test "cia1_instantiate" {
  let timer = 3
  //
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  //
  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //
  cia.writeCIAIRQmask(0x00)
  //
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  //
  assert_eq!(cia[CRA], cra(INMODE))
  assert_false!(cia.register.controlA.start)
  //
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt) // SC
}

test "cia1_timera" {
  let timer = 3
  //
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  //
  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  //
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  //
  cia[CRA] = cra(START)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_eq!(cia.register.timerA, timer - 1)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_eq!(cia.register.timerA, timer - 2)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), true)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(IR) | icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  //
  cia.acknowledgeCIAIRQ()
  //
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
}

test "cia1_timera_forceload" {
  let timer = 3
  //
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  //
  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  cia[CRA] = cra(START) | cra(LOAD)
  assert_eq!(cia[CRA], cra(START) | cra(LOAD))
  assert_true!(cia.register.controlA.start)
  assert_true!(cia.register.controlA.forceLoad)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_eq!(cia.register.timerA, timer - 1)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_eq!(cia.register.timerA, timer - 2)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), true) // interrupt happened
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(TA) | icr(IR))
  assert_true!(cia.register.interruptControl.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  //
  cia.acknowledgeCIAIRQ()
  //
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  // should start timer A again
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_eq!(cia.register.timerA, timer - 1)
  assert_eq!(cia[CRA], cra(START))
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
}

test "cia1_timera_oneshot" {
  let timer = 3
  //
  let cpu = @cpu.CPU::new()
  let cia = CIA::new(cpu, cia_mem_start)
  //
  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //
  cia.writeCIAIRQmask(icr(SC) | icr(TA))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  cia[CRA] = cra(START) | cra(RUNMODE)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  assert_true!(cia.register.controlA.start)
  assert_true!(cia.register.controlA.runMode)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_eq!(cia.register.timerA, timer - 1)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_eq!(cia.register.timerA, timer - 2)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  assert_eq!(cia[ICR], icr(TA))
  assert_true!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia.emulate(1), true) // interrupt happened
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  assert_eq!(cia[CRA], cra(RUNMODE))
  assert_eq!(cia[ICR], icr(TA) | icr(IR))
  assert_true!(cia.register.interruptControl.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  //
  cia.acknowledgeCIAIRQ()
  //
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  // should not start timer A again
  assert_eq!(cia.emulate(1), false)
  assert_eq!(cia[TA_HI], 0)
  assert_eq!(cia[TA_LO], timer)
  assert_eq!(cia.register.timerA, timer)
  assert_eq!(cia[CRA], cra(RUNMODE))
  assert_eq!(cia[ICR], icr(NONE))
  assert_false!(cia.register.interruptControl.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
}
