///| 6526 FUNCTIONAL DESCRIPTION
///
/// REGISTER MAP
///
/// PRA      | PERIPHERAL DATA REG A
/// PRB      | PERIPHERAL DATA REG B
/// DDRA     | DATA DIRECTION REG A
/// DDRB     | DATA DIRECTION REG B
/// TA LO    | TIMER A LOW REGISTER
/// TA HI    | TIMER A HIGH REGISTER
/// TB LO    | TIMER B LOW REGISTER
/// TB HI    | TIMER B HIGH REGISTER
/// TOD 10TH | 10THS OF SECONDS REGISTER
/// TOD SEC  | SECONDS REGISTER
/// TOD MIN  | MINUTES REGISTER
/// TOD HR   | HOURS - AM/PM REGISTER
/// SDR      | SERIAL DATA REGISTER
/// ICR      | INTERRUPT CONTROL REGISTER
/// CRA      | CONTROL REG A
/// CRB      | CONTROL REG B
pub struct TimeOfDay {
  mut tenth : UInt8
  mut seconds : UInt8
  mut minutes : UInt8
  mut hours : UInt8

  /// AM/PM Flag (1=PM, 0=AM)
  mut pm : Bool
} derive(Show, Default)

///|
pub enum RunMode {
  OneShot
  Continuous
} derive(Show, Eq)

///|
fn RunMode::to_int(self : RunMode) -> Int {
  match self {
    OneShot => 1
    Continuous => 0
  }
}

///|
pub enum SerialMode {
  Output
  Input
} derive(Show, Eq)

///|
fn SerialMode::to_int(self : SerialMode) -> Int {
  match self {
    Output => 1
    Input => 0
  }
}

///|
pub struct ControlA {
  /// Bit 0:  Start Timer A (1=start, 0=stop)
  mut start : Bool
  /// Bit 1:  Select Timer A output on Port B (1=Timer A output appears on Bit 6 of
  ///         Port B)
  mut output : Bool
  /// Bit 2:  Port B output mode (1=toggle Bit 6, 0=pulse Bit 6 for one cycle)
  mut outputMode : Bool
  /// Bit 3:  Timer A run mode (1=one-shot, 0=continuous)
  mut runMode : RunMode
  /// Bit 4:  Force latched value to be loaded to Timer A counter (1=force load
  ///         strobe)
  mut forceLoad : Bool
  /// Bit 5:  Timer A input mode (1=count microprocessor cycles, 0=count signals on
  ///         CNT line at pin 4 of User Port)
  mut inputMode : TimerAInputMode
  /// Bit 6:  Serial Port (56332, $DC0C) mode (1=output, 0=input)
  mut serialMode : SerialMode
  /// Bit 7:  Time of Day Clock frequency (1=50 Hz required on TOD pin, 0=60 Hz)
  mut clockFrequency : Bool
} derive(Show, Eq)

///|
enum TimerAInputMode {
  CountCycles
  CountSignals
} derive(Show, Eq)

///|
fn ControlA::default() -> ControlA {
  {
    start: Bool::default(),
    output: Bool::default(),
    outputMode: Bool::default(),
    runMode: RunMode::Continuous,
    forceLoad: Bool::default(),
    inputMode: TimerAInputMode::CountCycles,
    serialMode: SerialMode::Input,
    clockFrequency: Bool::default(),
  }
}

///|
pub struct ControlB {
  /// Bit 0:  Start Timer B (1=start, 0=stop)
  mut start : Bool
  /// Bit 1:  Select Timer B output on Port B (1=Timer B output appears on
  ///         Bit 7 of Port B)
  mut output : Bool
  /// Bit 2:  Port B output mode (1=toggle Bit 7, 0=pulse Bit 7 for one
  ///         cycle)
  mut outputMode : Bool
  /// Bit 3:  Timer B run mode (1=one-shot, 0=continuous)
  mut runMode : RunMode
  /// Bit 4:  Force latched value to be loaded to Timer B counter (1=force
  ///         load strobe)
  mut forceLoad : Bool
  /// Bits 5-6:  Timer B input mode
  ///            00 = Timer B counts microprocessor cycles
  ///            01 = Count signals on CNT line at pin 4 of User Port
  ///            10 = Count each time that Timer A counts down to 0
  ///            11 = Count Timer A 0's when CNT pulses are also present
  mut inputMode : TimerBInputMode
  /// Bit 7:  Select Time of Day write (0=writing to TOD registers sets
  ///         alarm, 1=writing to TOD registers sets clock)
  mut writeMode : Bool
} derive(Show)

///|
enum TimerBInputMode {
  CountCycles
  CountSignals
  CountTimerA
  CountZero
} derive(Show)

///|
fn ControlB::default() -> ControlB {
  {
    start: Bool::default(),
    output: Bool::default(),
    outputMode: Bool::default(),
    runMode: RunMode::Continuous,
    forceLoad: Bool::default(),
    inputMode: TimerBInputMode::CountCycles,
    writeMode: Bool::default(),
  }
}

///|
pub struct CIAInterruptControl {
  mut timerA : Bool
  mut timerB : Bool
  alarm : Bool
  serial : Bool
  flag : Bool
  mut interrupt : Bool
} derive(Show, Default)

///|
pub struct CIAInterruptEnable {
  mut timerA : Bool
  mut timerB : Bool
  mut alarm : Bool
  mut serial : Bool
  mut flag : Bool
} derive(Show, Default)

///|
pub struct CIARegister {
  /// 56320-56335   $DC00-$DC0F
  /// Complex Interface Adapter (CIA) #1 Registers

  /// Location Range: 56320-56321 ($DC00-$DC01)
  /// CIA #1 Data Ports A and B

  /// 56320         $DC00          CIAPRA
  /// Data Port Register A
  portA : FixedArray[Bool]

  /// 56321         $DC01          CIAPRB
  /// Data Port Register B
  portB : FixedArray[Bool]

  /// Location Range: 56322-56323 ($DC02-$DC03)
  /// CIA #1 Data Direction Registers A and B

  /// 56322         $DC02          CIDDRA
  /// Data Direction Register A
  directionA : FixedArray[Bool]

  /// 56323         $DC03          CIDDRB
  /// Data Direction Register B
  directionB : FixedArray[Bool]

  /// Location Range: 56324-56327 ($DC04-$DC07)
  /// Timers A and B Low and High Bytes

  /// 56324         $DC04          TIMALO
  /// Timer A (low byte)
  ///
  /// 56325         $DC05          TIMAHI
  /// Timer A (high byte)
  // mut timerA : UInt16

  /// 56326         $DC06          TIMBLO
  /// Timer B (low byte)
  ///
  /// 56327         $DC07          TIMBHI
  /// Timer B (high byte)
  // mut timerB : UInt16

  /// Location Range: 56328-56331 ($DC08-$DC0B)
  /// Time of Day Clock (TOD)

  /// 56328         $DC08          TODTEN
  /// Time of Day Clock Tenths of Seconds
  timeOfDay : TimeOfDay

  /// 56332         $DC0C          CIASDR
  /// Serial Data Port
  mut serialData : UInt8

  /// 56333         $DC0D          CIAICR
  /// Interrupt Control Register
  mut interruptControl : CIAInterruptControl
  interruptEnable : CIAInterruptEnable

  /// 56334         $DC0E          CIACRA
  /// Control Register A
  controlA : ControlA

  /// 56335         $DC0F          CIACRB
  /// Control Register B
  controlB : ControlB
} derive(Show)

///|
fn CIARegister::default() -> CIARegister {
  {
    portA: FixedArray::make(8, false),
    portB: FixedArray::make(8, false),
    directionA: FixedArray::make(8, false),
    directionB: FixedArray::make(8, false),
    //
    // timerA: Int::default(),
    // timerB: Int::default(),
    //
    timeOfDay: TimeOfDay::default(),
    //
    serialData: Int::default(),
    //
    interruptControl: CIAInterruptControl::default(),
    interruptEnable: CIAInterruptEnable::default(),
    //
    controlA: ControlA::default(),
    controlB: ControlB::default(),
  }
}

///|
pub enum CIAregister {
  PRA
  PRB
  DDRA
  DDRB
  TA_LO
  TA_HI
  TB_LO
  TB_HI
  TOD_10TH
  TOD_SEC
  TOD_MIN
  TOD_HR
  SDR
  ICR
  CRA
  CRB
} derive(Show, Eq)

///|
fn cia(register : CIAregister) -> Int {
  match register {
    PRA => 0x00
    PRB => 0x01
    DDRA => 0x02
    DDRB => 0x03
    TA_LO => 0x04
    TA_HI => 0x05
    TB_LO => 0x06
    TB_HI => 0x07
    TOD_10TH => 0x08
    TOD_SEC => 0x09
    TOD_MIN => 0x0A
    TOD_HR => 0x0B
    SDR => 0x0C
    ICR => 0x0D
    CRA => 0x0E
    CRB => 0x0F
  }
}

///|
fn CIAregister::from_int(value : Int) -> CIAregister! {
  match value {
    0x00 => PRA
    0x01 => PRB
    0x02 => DDRA
    0x03 => DDRB
    0x04 => TA_LO
    0x05 => TA_HI
    0x06 => TB_LO
    0x07 => TB_HI
    0x08 => TOD_10TH
    0x09 => TOD_SEC
    0x0A => TOD_MIN
    0x0B => TOD_HR
    0x0C => SDR
    0x0D => ICR
    0x0E => CRA
    0x0F => CRB

    ///
    _ => raise UnknownRegister("CIA", value)
  }
}
