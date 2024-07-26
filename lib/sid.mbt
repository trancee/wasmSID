/// MOS 6581 SOUND INTERFACE DEVICE (SID)
///
/// $D400-$D41C
/// Sound Interface Device (SID) Registers
///
/// SID is a custom music synthesizer and sound effects generator chip
/// that gives the 64 its impressive musical capabilities.  It provides
/// three separate music channels, or voices, as they are called.  Each
/// voice has 16-bit frequency resolution, waveform control, envelope
/// shaping, oscillator synchronization, and ring modulation.  In
/// addition, programmable high-pass, low-pass, and band-pass filters can
/// be set and enabled or disabled for each sound channel.

/// ($D400-$D401)
/// Voice 1 Frequency Control
///
/// Together, these two locations control the frequency or pitch of the
/// musical output of voice 1.  Some frequency must be selected in order
/// for voice 1 to be heard.  This frequency may be changed in the middle
/// of a note to achieve special effects.  The 16-bit range of the
/// Frequency Control Register covers over eight full octaves, and allows
/// you to vary the pitch from 0 (very low) to about 4000 Hz (very high),
/// in 65536 steps.  The exact frequency of the output can be determined
/// by the equation

/// ($D402-$D403)
/// Voice 1 Pulse Waveform Width Control
///
/// As you will see below under the description of the Control Register at
/// 54276 ($D404), you can select one of four different waveforms for the
/// output of each voice.  If the pulse waveform is selected, these
/// registers must be set to establish the pulse width.

/// ($D405-$D406)
/// Voice 1 Envelop (ADSR) Control
///
/// When a note is played on a musical instrument, the volume does not
/// suddenly rise to a peak and then cut off to zero.  Rather, the volume
/// builds to a peak, levels off to an intermediate value, and then fades
/// away.  This creates what is known as a volume envelope.

/// ($D407-$D414)
/// Voice 2 and Voice 3 Controls
///
/// The various control registers for these two voices correspond almost
/// exactly to those of voice 1.  The one exception is that the sync and
/// ring-modulation bits of voice 2 operate on Oscillators 1 and 2, while
/// the same bits of the Control Register for voice 3 uses Oscillators 2
/// and 3.

/// ($D415-$D418)
/// Filter Controls
///
/// In addition to the controls detailed above for each voice, the SID
/// chip also provides a filtering capability which allows you to
/// attenuate (make quieter) certain ranges of frequencies.  Any one or
/// all three voices can be filtered, and there is even a provision for
/// filtering an external signal that is input through pin 5 of the
/// monitor jack.

/// ($D419-$D41A)
/// Game Paddle Inputs
///
/// These registers allow you to read the game paddles that plug into
/// joystick Controller Ports 1 and 2.  Each paddle uses a variable
/// resistor (also known as a potentiometer or pot), whose resistance is
/// controlled by turning a knob.  The varying resistance is used to vary
/// the voltage to two pins of the SID chip between 0 and +5 volts.
/// Analog-to-digital (A/D) converters in the chip interpret these voltage
/// levels as binary values and store the values in these registers.
/// These registers return a number from 0 (minumum resistance) to 255
/// (maximum resistance) for each paddle in either of the ports, depending
/// on the position of the paddle knob.

/// ($D41D-$D41F)
/// Not Connected
///
/// The SID chip has been provided with enough addresses for 32 different
/// registers, but as it has only 29, the remaining three addresses are
/// not used.  Reading them will always return a value of 255 ($FF), and
/// writing to them will have no effect.

/// ($D420-$D7FF)
/// SID Register Images
///
/// Since the SID chip requires enough addressing lines for only 32
/// locations (the minimum possible for its 29 registers), none of the
/// higher bits are decoded when addressing the 1K area that has been
/// assigned to it.  The result is that every 32-byte area in this 1K
/// block is a mirror of every other.  For the sake of clarity in your
/// programs, it is advisable not to use these addresses at all.

// https://www.oxyron.de/html/registers_sid.html

let sid_mem_upper = 0xD400

let sid_mem_lower = 0xD7FF

let sid_mem_length = 0x03FF

struct SID {
  mem : @cpu.Memory
  baseaddress : Int
  //
  mut model : Model
  mut channel : Channel
}

pub fn SID::new(
  cpu : @cpu.CPU,
  baseaddress : Int,
  ~model : Model = Unknown,
  ~channel : Channel = Unknown,
  ~videoStandard : VideoStandard = Unknown
) -> SID {
  println("SID::new")
  let mem = @cpu.Memory::new(length=sid_mem_length)
  let sid : SID = { mem, baseaddress, model, channel }
  cpu.mem().hook(
    sid_mem_lower,
    sid_mem_upper,
    fn(address : Int) {
      println("SID::r")
      sid.r(address).0
    },
    fn(address : Int, value : Int) {
      println("SID::w")
      sid.w(address, value)
    },
  )
  sid.reset()
  sid
}

pub fn reset(self : SID, ~videoStandard : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=sid_mem_length)
  self.mem.reset()

  /// ($D41D-$D41F)
  /// Not Connected
  ///
  /// The SID chip has been provided with enough addresses for 32 different
  /// registers, but as it has only 29, the remaining three addresses are
  /// not used.  Reading them will always return a value of 255 ($FF), and
  /// writing to them will have no effect.

  self.mem.reset(
    offset=0xD41D - self.baseaddress,
    length=3, // $D41D-$D41F
    value=0xFF,
  )
}

fn r(self : SID, address : UInt16) -> UInt8 {
  println("SID $" + address.to_hex() + " → $" + self.mem[address.0].to_hex())
  self.mem[address.0].0
}

fn w(self : SID, address : UInt16, value : UInt8) -> Unit {
  println("SID $" + address.to_hex() + " ← $" + self.mem[address.0].to_hex())
  self.mem[address.0] = value.0
}

fn op_get(self : SID, register : SIDregister) -> UInt8 {
  let address = self.baseaddress + sid(register) % 0x20 // (repeated every $20, 32 bytes)
  /// SID Register Images
  if address < sid_mem_upper || address > sid_mem_lower {
    // self.dump()
    println("SID \(register) → $" + self.mem[address].to_hex())
    abort("out of bounds")
  }
  // println("SID \(register) → $" + self.mem[address].to_hex())
  // self.mem[address].0
  self.r(address)
}

fn op_set(self : SID, register : SIDregister, value : UInt8) -> Unit {
  let address = self.baseaddress + sid(register) % 0x20 // (repeated every $20, 32 bytes)
  /// SID Register Images
  if address < sid_mem_upper || address > sid_mem_lower {
    // self.dump()
    println("SID \(register) ← $" + value.to_hex())
    abort("out of bounds")
  }
  // println("SID \(register) ← $" + value.to_hex())
  // self.mem[address] = value.0
  self.w(address, value)
}
