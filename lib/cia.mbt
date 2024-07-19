/// 6526
///
/// CONTROL REGISTERS
/// There are two control registers in the 6526, CRA and CRB. CRA is associated with TIMER A and CRB
/// is associated with TIMER B. The register format is as follows:
///
/// CRA
/// Bit  Name    Function
///  0   START   1 = START TIMER A
///              0 = STOP TIMER A
///              (This bit is automatically reset when underflow occurs during one-shot mode).
///  1   PBON    1 = TIMER A output appears on PB6.
///              0 = PB6 normal operation.
///  2   OUTMODE 1 = TOGGLE
///              0 = PULSE
///  3   RUNMODE 1 = ONE-SHOT
///              0 = CONTINUOUS
///  4   LOAD    1 = FORCE LOAD
///              (This is a STROBE input, there is no data storage, bit 4 will always read back a zero and writing a zero has no effect).
///  5   INMODE  1 = TIMER A counts positive CNT transitions.
///              0 = TIMER A counts phi2 pulses.
///  6   SPMODE  1 = SERIAL PORT output (CNT sources shift clock).
///              0 = SERIAL PORT input (external shift clock required).
///  7   TODIN   1 = 50Hz clock required on TOD pin for accurate time.
///              0 = 60Hz clock required on TOD pin for accurate time.
///
/// CRB
/// Bit  Name    Function
///              (Bits CRB0-4 are identical to CRA0-4 for TIMER B with the exception that bit 1 controls the ouput of TIMER B on PB7).
///  5   INMODE  1 = TIMER B counts positive CNT transitions.
///              0 = TIMER B counts phi2 pulses.
///  6   INMODE  1 = TIMER B counts TIMER A underflow pulses while CNT is high.
///              0 = TIMER B counts TIMER A underflow pulses.
///  7   ALARM   1 = writing to TOD registers sets ALARM.
///              0 = writing to TOD registers sets TOD clock.

/// $DC10-$DCFF CIA#1 register images (repeated every $10, 16 bytes).

struct CIA {
  mem : @cpu.Memory
  baseaddress : Int // CIA-baseaddress location in C64-memory (IO)
}

pub fn CIA::new(mem : @cpu.Memory, baseaddress : Int) -> CIA {
  let cia : CIA = { mem, baseaddress }
  cia
}

pub fn reset(self : CIA) -> Unit {
  self[PRA] = 0x00
  self[PRB] = 0x00
  self[DDRA] = 0x00
  self[DDRB] = 0x00
  self[TA_LO] = 0x00
  self[TA_HI] = 0x00
  self[TB_LO] = 0x00
  self[TB_HI] = 0x00
  self[TOD_10TH] = 0x00
  self[TOD_SEC] = 0x00
  self[TOD_MIN] = 0x00
  self[TOD_HR] = 0x00
  self[SDR] = 0x00
  self[ICR] = 0x00
  self[CRA] = 0x00
  self[CRB] = 0x00
}

pub fn emulate(self : CIA, cycles : Int) -> Int {
  // Timer A
  if (self[CRA] |> CRA::CRA).has(FORCELOADA_STROBE) {
    // force latch into counter (strobe-input)
    self[TA_HI] = self[TA_HI]
    self[TA_LO] = self[TA_LO]
  } else if ((self[CRA] |> CRA::CRA) & (ENABLE_TIMERA | TIMERA_FROM_CNT)).has(
    ENABLE_TIMERA,
  ) { // Enabled, counts Phi2
    //count timer
    let mut tmp = (self[TA_HI] << 8) + self[TA_LO] - cycles
    if tmp <= 0 { // Timer counted down
      tmp += (self[TA_HI] << 8) + self[TA_LO] //reload timer
      if (self[CRA] |> CRA::CRA).has(ONESHOT_TIMERA) { //disable if one-shot
        self[CRA] = (self[CRA] |> CRA::CRA).clear(ENABLE_TIMERA).0
      }
      self[ICR] = (self[ICR] |> ICR::ICR) | TIMER_A
      if (self[ICR] |> ICR::ICR).has(TIMER_A) { //generate interrupt if mask allows
        self[ICR] = (self[ICR] |> ICR::ICR) | IR
      }
    }
    self[TA_HI] = tmp >> 8
    self[TA_LO] = tmp & 0xFF
  }
  self[CRA] = (self[CRA] |> CRA::CRA).clear(FORCELOADA_STROBE).0 //strobe is edge-sensitive
  self[CRA] = self[CRA] //control-registers are readable

  // TimerB

  ((self[ICR] |> ICR::ICR) & IR).to_int()
}

/// The `MASK` register provides convenient control of individual mask bits.
/// When writing to the `MASK` register, if bit 7 (`SET`/`CLEAR`) of data written is a
/// `ZERO`, any mask bit written with a on will be cleared, while those mask bits written with a zero will be unaffected.
/// If bit 7 of the data written is a `ONE`, any mask bit written with a one will be set, while those mask bits written with a zero will be unaffected.
/// In order for an interrupt flag to set `IR` and generate an Interrupt Request, the corresponding `MASK` bit must be set.
pub fn writeCIAIRQmask(self : CIA, mask : Mask) -> Unit {
  match mask.has(SET_CLEAR) {
    true => self[ICR] = self[ICR] | (mask & 0x1F) // SET
    false => self[ICR] = self[ICR] ^ (mask & 0x1F) // CLEAR
  }
}

pub fn acknowledgeCIAIRQ(self : CIA) -> Unit {
  self[ICR] = 0x00 // reading a CIA interrupt-register clears its read-part and IRQ-flag
}

fn op_get(self : CIA, register : Register) -> UInt8 {
  let address = self.baseaddress + register[register]
  if address < 0xDC00 || address > 0xDDFF {
    // self.dump()
    abort("CIA::get out of bounds")
  }
  self.mem[address].0
}

fn op_set(self : CIA, register : Register, value : UInt8) -> Unit {
  let address = self.baseaddress + register[register]
  if address < 0xDC00 || address > 0xDDFF {
    // self.dump()
    abort("CIA::set out of bounds")
  }
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
