///| 6526
///
/// $DC00-$DCFF CIA #1
/// $DC00-$DC0F Complex Interface Adapter (CIA) #1 Registers
/// $DC10-$DCFF CIA #1 register images (repeated every $10, 16 bytes).
///
/// $DD00-$DDFF CIA #2
/// $DD00-$DD0F Complex Interface Adapter (CIA) #2 Registers
/// $DD10-$DDFF CIA #2 Register Images  The result is that every 16-byte area in this 256-byte block is a mirror of every other.
const CIA_MEM_START = 0xDC00

///|
const CIA_MEM_END = 0xDDFF

///|
const CIA1_MEM_START = 0xDC00

///|
const CIA2_MEM_START = 0xDD00

///|
const CIA_MEM_SIZE = 0x00FF

///|
pub struct Timer {
  mut latch : Int
  mut counter : Int
  // mut underflow : Bool
  // mut interrupt : Bool // enable/disable underflow interrupt
} derive(Show, Default)

///|
struct CIA {
  mem : FixedArray[Int]
  baseaddress : Int

  //
  timerA : Timer
  timerB : Timer

  //
  register : CIARegister

  //
  debug : Bool
}

///|
pub fn CIA::new(
  mem? : Memory,
  baseaddress : Int,
  //

  videoStandard~ : VideoStandard = Unknown,
  debug~ : Bool = false
) -> CIA {
  println("CIA::new")
  //

  let cia : CIA = {
    mem: FixedArray::make(CIA_MEM_SIZE + 1, 0x00),
    baseaddress,

    //
    timerA: Timer::default(),
    timerB: Timer::default(),

    //
    register: CIARegister::default(),

    //
    debug,
  }

  //
  if mem is Some(mem) {
    mem.hook(
      baseaddress,
      baseaddress + CIA_MEM_SIZE,
      // mem,
      fn(address : UInt16, dummy : Bool) -> UInt8 {
        let register = try {
          CIAregister::from_int!(address._ - baseaddress)
        } catch {
          err => {
            println(err)
            panic()
          }
        }
        cia.read(register, dummy~)._
      },
      fn(address : UInt16, value : UInt8, dummy : Bool) {
        let register = try {
          CIAregister::from_int!(address._ - baseaddress)
        } catch {
          err => {
            println(err)
            panic()
          }
        }
        cia.write(register, value, dummy~)
      },
    )
  }

  //
  cia.reset(videoStandard~)

  //
  cia
}

///|
pub fn reset(self : CIA, videoStandard~ : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=cia_mem_length)
  // self.rom.reset()
  // self.ram.reset()
  for i = 0; i < self.mem.length(); i = i + 1 {
    self.mem[i] = 0x00
  }

  //
  match self.baseaddress {
    CIA1_MEM_START => {
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
    CIA2_MEM_START => {
      //VICbank-selector default
      self[PRA] = 0x03

      //
      self[TA_LO] = 0xFF
      self[TA_HI] = 0xFF
    }
    _ => {
      println("CIA::reset unknown baseaddress")
      panic()
    }
  }
}

///| p.127
/// Timers. Program 5-2 allows you to see the timers updating on the screen. Timer
/// A normally controls the IRQ rate, which is why POKEs to $DC04 and $DC05 (56324
/// and 56325) alter the cursor flash rate. TA counts down with the system clock about
/// 60 times per second, too fast for Program 5-2 to show a pattern. Note, though, that
/// register 5 ($DC05 or 56335) never exceeds 66; this latched value was selected be-
/// cause 65*256/1,000,000 is about 1/60 second. When the computer is turned on,
/// $DCOD (56333) has bit 0 set high, enabling an IRQ interrupt to the 6510, although
/// PEEKing won't show this.
pub fn emulate(self : CIA, cycles : Int) -> Bool {
  // println(">> emulate $" + self[ICR].to_hex() + " (\{cycles})")
  //

  // Timer A
  if self.register.controlA.forceLoad {
    println("TimerA Force Load")
    // force latch into counter (strobe-input)
    self.timerA.counter = self.timerA.latch
    self.register.interruptControl.timerA = self.timerA.counter == 0
    self.register.controlA.forceLoad = false //strobe is edge-sensitive
  }
  if self.register.controlA.start { // Enabled, counts Phi2
    println("TA:#$" + u16(self.timerA.counter).to_hex() + " \{cycles}")
    //count timer
    let mut tmp = self.timerA.counter - cycles
    // println("TimerA Start #\{tmp}")
    self.register.interruptControl.timerA = tmp <= 0
    if self.register.interruptControl.timerA { // Timer counted down
      println("TimerA Finish \{tmp}")
      tmp += self.timerA.latch //reload timer
      if self.register.controlA.runMode == OneShot {
        println("TimerA OneShot")
        self.register.controlA.start = false //disable if one-shot
      }
      if self.register.interruptEnable.timerA { //generate interrupt if mask allows
        self.register.interruptControl.interrupt = true
      }
      println(self.timerA)
    }
    self.timerA.counter = tmp
  }

  // Timer B
  if self.register.controlB.forceLoad {
    println("TimerB Force Load")
    // force latch into counter (strobe-input)
    self.timerB.counter = self.timerB.latch
    self.register.interruptControl.timerB = self.timerB.counter == 0
    self.register.controlB.forceLoad = false //strobe is edge-sensitive
    //what about clocking TimerB by TimerA? (maybe not used in any music)
  }
  if self.register.controlB.start { // Enabled, counts Phi2
    println("TB:#$" + u16(self.timerB.counter).to_hex() + " \{cycles}")
    //count timer
    let mut tmp = self.timerB.counter -
      (match self.register.controlB.inputMode {
        CountCycles => cycles
        CountTimerA => if self.register.interruptControl.timerA { 1 } else { 0 }

        ///
        _ => {
          println("ControlB inputMode not implemented")
          panic()
        }
      })
    // println("TimerB Start #\{tmp}")
    self.register.interruptControl.timerB = tmp <= 0
    if self.register.interruptControl.timerB { // Timer counted down
      println("TimerB Finish \{tmp}")
      tmp += self.timerB.latch //reload timer
      if self.register.controlB.runMode == OneShot {
        println("TimerB OneShot")
        self.register.controlB.start = false //disable if one-shot
      }
      if self.register.interruptEnable.timerB { //generate interrupt if mask allows
        self.register.interruptControl.interrupt = true
      }
      println(self.timerB)
    }
    self.timerB.counter = tmp
  }
  // println("CIA IRQ:\{self.register.interruptControl.interrupt}")

  //
  self.register.interruptControl.interrupt
}

///|
fn CIA::read(
  self : CIA,
  register : CIAregister,
  dummy~ : Bool = false
) -> UInt8 {
  let address = cia(register) % 0x10 // (repeated every $10, 16 bytes)
  if self.debug && not(dummy) {
    println(
      "💻 CIA $" +
      u16(self.baseaddress + address).to_hex() +
      " → #$" +
      u8(self.mem[address]).to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < CIA_MEM_START ||
    self.baseaddress + address > CIA_MEM_END {
    // self.dump()
    println(
      "CIA \{register} $" +
      u16(self.baseaddress + address).to_hex() +
      " → #$" +
      u8(self.mem[address]).to_hex(),
    )
    abort("out of bounds")
  }

  //
  match register {
    PRA =>
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
    PRB =>
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
    DDRA =>
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
    DDRB =>
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
    TA_LO => u8(self.timerA.counter)
    TA_HI => u8(self.timerA.counter >> 8)
    TB_LO => u8(self.timerB.counter)
    TB_HI => u8(self.timerB.counter >> 8)
    TOD_10TH =>
      /// Bits 0-3:  Time of Day tenths of second digit (BCD)
      /// Bits 4-7:  Unused
      self.register.timeOfDay.tenth & 0b00001111
    TOD_SEC =>
      /// Bits 0-3:  Second digit of Time of Day seconds (BCD)
      /// Bits 4-6:  First digit of Time of Day seconds (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.seconds & 0b01111111
    TOD_MIN =>
      /// Bits 0-3:  Second digit of Time of Day minutes (BCD)
      /// Bits 4-6:  First digit of Time of Day minutes (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.minutes & 0b01111111
    TOD_HR =>
      /// Bits 0-3:  Second digit of Time of Day hours (BCD)
      /// Bit 4:  First digit of Time of Day hours (BCD)
      /// Bits 5-6:  Unused
      /// Bit 7:  AM/PM Flag (1=PM, 0=AM)
      (self.register.timeOfDay.hours & 0b00011111) |
      (self.register.timeOfDay.pm.to_int() << 7)
    SDR => self.register.serialData
    ICR => {
      /// Bit 0:  Read / did Timer A count down to 0?  (1=yes)
      let value = (self.register.interruptControl.timerA.to_int() << 0) |
        /// Bit 1:  Read / did Timer B count down to 0?  (1=yes)
        (self.register.interruptControl.timerB.to_int() << 1) |
        /// Bit 2:  Read / did Time of Day Clock reach the alarm time?  (1=yes)
        (self.register.interruptControl.alarm.to_int() << 2) |
        /// Bit 3:  Read / did the serial shift register finish a byte? (1=yes)
        (self.register.interruptControl.serial.to_int() << 3) |
        /// Bit 4:  Read / was a signal sent on the flag line?  (1=yes)
        (self.register.interruptControl.flag.to_int() << 4) |
        /// Bit 5:  Not used
        /// Bit 6:  Not used
        /// Bit 7:  Read / did any CIA #1 source cause an interrupt?  (1=yes)
        (self.register.interruptControl.interrupt.to_int() << 7)
      if not(dummy) {
        println(
          "ICR #$" +
          u8(value).to_hex() +
          " \{self.register.interruptControl} | \{value}",
        )
        self.register.interruptControl = CIAInterruptControl::default()
        println("ICR::CLR \{self.register.interruptControl}")
      }
      value
    }
    CRA =>
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
        (match self.register.controlA.inputMode {
          TimerAInputMode::CountCycles => 0b01
          TimerAInputMode::CountSignals => 0b00
        }) <<
        5
      ) |
      /// Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
      (self.register.controlA.serialMode.to_int() << 6) |
      /// Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
      (self.register.controlA.clockFrequency.to_int() << 7)
    CRB =>
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
        (match self.register.controlB.inputMode {
          TimerBInputMode::CountCycles => 0b00
          TimerBInputMode::CountSignals => 0b01
          TimerBInputMode::CountTimerA => 0b10
          TimerBInputMode::CountZero => 0b11
        }) <<
        5
      ) |
      /// Bit 7:  Select Time of Day write (0=writing to TOD registers sets
      ///         alarm, 1=writing to TOD registers sets clock)
      (self.register.controlB.writeMode.to_int() << 7)
    // _ => {
    //   println("unknown read register \{register}")
    //   panic()
    // }
  }
}

///|
fn CIA::op_get(self : CIA, register : CIAregister) -> UInt8 {
  self.read(register)
}

///|
fn CIA::write(
  self : CIA,
  register : CIAregister,
  value : UInt8,
  dummy~ : Bool = false
) -> Unit {
  let address = cia(register) % 0x10 // (repeated every $10, 16 bytes)
  if self.debug && not(dummy) {
    println(
      "💻 CIA $" +
      u16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < CIA_MEM_START ||
    self.baseaddress + address > CIA_MEM_END {
    // self.dump()
    println(
      "CIA \{register} $" +
      u16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex(),
    )
    abort("out of bounds")
  }

  //
  match register {
    /// Data Port Register A
    PRA => {
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
    PRB => {
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
    DDRA => {
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
    DDRB => {
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
    TA_LO => {
      self.timerA.counter = (self.timerA.counter & 0xFF00) | value.to_int()
      self.timerA.latch = (self.timerA.latch & 0xFF00) | value.to_int()
    }
    TA_HI => {
      self.timerA.counter = (value.to_int() << 8) |
        (self.timerA.counter & 0x00FF)
      self.timerA.latch = (value.to_int() << 8) | (self.timerA.latch & 0x00FF)
    }
    TB_LO => {
      self.timerB.counter = (self.timerB.counter & 0xFF00) | value.to_int()
      self.timerB.latch = (self.timerB.latch & 0xFF00) | value.to_int()
    }
    TB_HI => {
      self.timerB.counter = (value.to_int() << 8) |
        (self.timerB.counter & 0x00FF)
      self.timerB.latch = (value.to_int() << 8) | (self.timerB.latch & 0x00FF)
    }
    TOD_10TH =>
      /// Bits 0-3:  Time of Day tenths of second digit (BCD)
      /// Bits 4-7:  Unused
      self.register.timeOfDay.tenth = value & 0b00001111
    TOD_SEC =>
      /// Bits 0-3:  Second digit of Time of Day seconds (BCD)
      /// Bits 4-6:  First digit of Time of Day seconds (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.seconds = value & 0b01111111
    TOD_MIN =>
      /// Bits 0-3:  Second digit of Time of Day minutes (BCD)
      /// Bits 4-6:  First digit of Time of Day minutes (BCD)
      /// Bit 7:  Unused
      self.register.timeOfDay.minutes = value & 0b01111111
    TOD_HR => {
      /// Bits 0-3:  Second digit of Time of Day hours (BCD)
      /// Bit 4:  First digit of Time of Day hours (BCD)
      /// Bits 5-6:  Unused
      /// Bit 7:  AM/PM Flag (1=PM, 0=AM)
      self.register.timeOfDay.hours = value & 0b00011111
      self.register.timeOfDay.pm = value.bit(7)
    }
    SDR => self.register.serialData = value
    ICR => {
      /// Bit 7:  Write/ set or clear bits of this register
      ///         (1=bits written with 1 will be set, 0=bits written with 1 will be cleared)
      let flag = value.bit(7)

      /// Bit 0:  Write/ enable or disable Timer A interrupt (1=enable, 0=disable)
      if value.bit(0) {
        self.register.interruptEnable.timerA = flag
      }
      /// Bit 1:  Write/ enable or disable Timer B interrupt (1=enable, 0=disable)
      if value.bit(1) {
        self.register.interruptEnable.timerB = flag
      }
      /// Bit 2:  Write/ enable or disable TOD clock alarm interrupt (1=enable, 0=disable)
      if value.bit(2) {
        self.register.interruptEnable.alarm = flag
      }
      /// Bit 3:  Write/ enable or disable serial shift register interrupt (1=enable, 0=disable)
      if value.bit(3) {
        self.register.interruptEnable.serial = flag
      }
      /// Bit 4:  Write/ enable or disable FLAG line interrupt (1=enable, 0=disable)
      if value.bit(4) {
        self.register.interruptEnable.flag = flag
      }
      /// Bit 5:  Not used
      /// Bit 6:  Not used
      println("ICR #$" + value.to_hex() + " \{self.register.interruptEnable}")
    }
    CRA => {
      /// Bit 0:  Start Timer A (1=start, 0=stop)
      self.register.controlA.start = value.bit(0)
      /// Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of
      ///         Port B)
      self.register.controlA.output = value.bit(1)
      /// Bit 2:  Port B output mode (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
      self.register.controlA.outputMode = value.bit(2)
      /// Bit 3:  Timer A run mode (1=one-shot, 0=continuous)
      self.register.controlA.runMode = if value.bit(3) {
        RunMode::OneShot
      } else {
        RunMode::Continuous
      }
      /// Bit 4:  Force latched value to be loaded to Timer A counter (1=force load
      ///         strobe)
      self.register.controlA.forceLoad = value.bit(4)
      /// Bit 5:  Timer A input mode (1=count microprocessor cycles, 0=count signals on
      ///         CNT line at pin 4 of User Port)
      self.register.controlA.inputMode = match (value & 0b00100000)._ >> 5 {
        0b01 => TimerAInputMode::CountCycles
        0b00 => TimerAInputMode::CountSignals

        ///
        _ => {
          println("ControlA inputMode not implemented")
          panic()
        }
      }
      /// Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
      self.register.controlA.serialMode = if value.bit(6) {
        SerialMode::Output
      } else {
        SerialMode::Input
      }
      /// Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
      self.register.controlA.clockFrequency = value.bit(7)
    }
    CRB => {
      /// Bit 0:  Start Timer B (1=start, 0=stop)
      self.register.controlB.start = value.bit(0)
      /// Bit 1:  Select Timer B output on Port B (1=Timer B output appears on Bit 7 of Port B)
      self.register.controlB.output = value.bit(1)
      /// Bit 2:  Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one cycle)
      self.register.controlB.outputMode = value.bit(2)
      /// Bit 3:  Timer B run mode (1=one-shot, 0=continuous)
      self.register.controlB.runMode = if value.bit(3) {
        RunMode::OneShot
      } else {
        RunMode::Continuous
      }
      /// Bit 4:  Force latched value to be loaded to Timer B counter (1=force load strobe)
      self.register.controlB.forceLoad = value.bit(4)
      /// Bits 5-6:  Timer B input mode
      ///            00 = Timer B counts microprocessor cycles
      ///            01 = Count signals on CNT line at pin 4 of User Port
      ///            10 = Count each time that Timer A counts down to 0
      ///            11 = Count Timer A 0's when CNT pulses are also present
      self.register.controlB.inputMode = match (value & 0b01100000)._ >> 5 {
        0b00 => TimerBInputMode::CountCycles
        0b01 => TimerBInputMode::CountSignals
        0b10 => TimerBInputMode::CountTimerA
        0b11 => TimerBInputMode::CountZero

        ///
        _ => {
          println("ControlB inputMode not implemented")
          panic()
        }
      }
      /// Bit 7:  Select Time of Day write
      ///         (0=writing to TOD registers sets alarm, 1=writing to TOD registers sets clock)
      self.register.controlB.writeMode = value.bit(7)
    }
    // _ => {
    //   println("unknown write register \{register}")
    //   panic()
    // }
  }
}

///|
fn op_set(self : CIA, register : CIAregister, value : UInt8) -> Unit {
  self.write(register, value)
}

///|
test "cia1_instantiate" {
  let timer = 3
  //

  let cia = CIA::new(CIA_MEM_START)
  //

  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //

  cia[ICR] = 0x7F
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  //
  assert_false!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.output)
  assert_false!(cia.register.controlA.outputMode)
  assert_eq!(cia.register.controlA.runMode, RunMode::Continuous)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.inputMode, TimerAInputMode::CountCycles)
  assert_eq!(cia.register.controlA.serialMode, SerialMode::Input)
  assert_false!(cia.register.controlA.clockFrequency)
  assert_eq!(cia[CRA], cra(INMODE))
  //
  assert_false!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
}

///|
test "cia1_timera" {
  let timer = 3
  //

  let cia = CIA::new(CIA_MEM_START)
  //

  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //

  cia[ICR] = icr(SC) | icr(TA)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.interruptEnable.timerA)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  cia[CRA] = cra(START)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 1)
  assert_eq!(cia[TA_HI], (timer - 1) >> 8)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 2)
  assert_eq!(cia[TA_HI], (timer - 2) >> 8)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), true) // interrupt happened
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(IR) | icr(TA))
  // assert_false!(cia.register.interruptEnable.timerA) // becomes false as interrupt has occurred
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia[ICR], icr(NONE))
  // assert_false!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
}

///|
test "cia1_timera_forceload" {
  let timer = 3
  //

  let cia = CIA::new(CIA_MEM_START)
  //

  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //

  cia[ICR] = icr(SC) | icr(TA)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.interruptEnable.timerA)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  cia[CRA] = cra(START) | cra(LOAD)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.controlA.start)
  assert_true!(cia.register.controlA.forceLoad)
  assert_eq!(cia[CRA], cra(START) | cra(LOAD))
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 1)
  assert_eq!(cia[TA_HI], (timer - 1) >> 8)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 2)
  assert_eq!(cia[TA_HI], (timer - 2) >> 8)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), true) // interrupt happened
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(IR) | icr(TA))
  // assert_false!(cia.register.interruptEnable.timerA) // becomes false as interrupt has occurred
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia[ICR], icr(NONE))
  // assert_false!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  // should start timer A again
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 1)
  assert_eq!(cia[TA_HI], (timer - 1) >> 8)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_true!(cia.register.controlA.start)
  assert_eq!(cia[CRA], cra(START))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
}

///|
test "cia1_timera_oneshot" {
  let timer = 3
  //

  let cia = CIA::new(CIA_MEM_START)
  //

  cia[TA_HI] = timer >> 8
  cia[TA_LO] = timer
  //

  cia[ICR] = icr(SC) | icr(TA)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.interruptEnable.timerA)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  cia[CRA] = cra(START) | cra(RUNMODE)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_true!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.runMode, RunMode::OneShot)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 1)
  assert_eq!(cia[TA_HI], (timer - 1) >> 8)
  assert_eq!(cia[TA_LO], timer - 1)
  assert_true!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.runMode, RunMode::OneShot)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer - 2)
  assert_eq!(cia[TA_HI], (timer - 2) >> 8)
  assert_eq!(cia[TA_LO], timer - 2)
  assert_true!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.runMode, RunMode::OneShot)
  assert_eq!(cia[CRA], cra(START) | cra(RUNMODE))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  assert_true!(cia.register.interruptEnable.timerA) // stays true as no interrupt has occurred
  //
  assert_eq!(cia.emulate(1), true) // interrupt happened
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_false!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.runMode, RunMode::OneShot)
  assert_eq!(cia[CRA], cra(RUNMODE))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_true!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(IR) | icr(TA))
  // assert_false!(cia.register.interruptEnable.timerA) // becomes false as interrupt has occurred
  assert_false!(cia.register.interruptControl.interrupt)
  //
  assert_eq!(cia[ICR], icr(NONE))
  // assert_false!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  //
  // should not start timer A again
  assert_eq!(cia.emulate(1), false)
  //
  assert_eq!(cia.timerA.counter, timer)
  assert_eq!(cia[TA_HI], timer >> 8)
  assert_eq!(cia[TA_LO], timer)
  assert_false!(cia.register.controlA.start)
  assert_false!(cia.register.controlA.forceLoad)
  assert_eq!(cia.register.controlA.runMode, RunMode::OneShot)
  assert_eq!(cia[CRA], cra(RUNMODE))
  assert_true!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
  assert_eq!(cia[ICR], icr(NONE))
  // assert_false!(cia.register.interruptEnable.timerA)
  assert_false!(cia.register.interruptControl.interrupt)
}
