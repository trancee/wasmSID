///| MOS 6581 SOUND INTERFACE DEVICE (SID)
pub enum SIDspecs {
  CHANNELS
  VOLUME_MAX
  D418_DIGI_VOLUME
}

///|
fn sidSpecs(value : SIDspecs) -> Int {
  match value {
    CHANNELS => 3 + 1
    VOLUME_MAX => 0x0F
    D418_DIGI_VOLUME => 2
  }
}

// fn op_get(self : SIDspecs, value : SIDspecs) -> Int {
//   match value {
//     CHANNELS => 3 + 1
//     VOLUME_MAX => 0x0F
//     D418_DIGI_VOLUME => 2
//   }
// }

///|
pub struct Output {
  mut left : Int
  mut right : Int
} derive(Default)

///|
pub struct SIDwavOutput {
  mut nonFilted : Int
  mut filterInput : Int
} derive(Default)

///| 54295         $D417          RESON
/// Filter Resonance Control Register
pub struct FilterResonanceControl {
  /// Bits 0-3 are used to control which of the voices will be altered by
  /// the filters.  If one of these bits is set to 1, the corresponding
  /// voice will be processed through the filter, and its harmonic content
  /// will be changed accordingly.  If the bit is set to 0, the voice will
  /// pass directly to the audio output.  Note that there is also a
  /// provision for processing an external audio signal which is brought
  /// through pin 5 of the Audio/Video Port.
  ///
  voice : FixedArray[Bool]

  /// Bit 3:  Filter the output from the external input?  1=yes
  external : Bool

  /// Bits 4-7 control the resonance of the filter.  By placing a number
  /// from 0 to 15 in these four bits, you may peak the volume of those
  /// frequencies nearest the cutoff.  This creates an even sharper
  /// filtering effect.  A setting of 0 causes no resonance, while a setting
  /// of 15 gives maximum resonance.
  ///
  /// Bits 4-7:  Select filter resonance 0-15
  resonance : UInt8
} derive(Show)

///|
fn FilterResonanceControl::default() -> FilterResonanceControl {
  {
    voice: [Bool::default(), Bool::default(), Bool::default()],
    external: Bool::default(),
    resonance: UInt8::default(),
  }
}

///|
fn FilterResonanceControl::from_u8(value : UInt8) -> FilterResonanceControl {
  {
    voice: [
      /// Bit 0:  Filter the output of voice 1?  1=yes
      (value & u8(1 << 0)) != 0,
      /// Bit 1:  Filter the output of voice 2?  1=yes
      (value & u8(1 << 1)) != 0,
      /// Bit 2:  Filter the output of voice 3?  1=yes
      (value & u8(1 << 2)) != 0,
    ],
    /// Bit 3:  Filter the output from the external input?  1=yes
    external: (value & u8(1 << 3)) != 0,
    /// Bits 4-7:  Select filter resonance 0-15
    resonance: (value & 0xF0) >> 4,
  }
}

///|
fn to_u8(self : FilterResonanceControl) -> UInt8 {
  /// Bit 0:  Filter the output of voice 1?  1=yes
  u8(self.voice[0].to_int() << 0) |
  /// Bit 1:  Filter the output of voice 2?  1=yes
  u8(self.voice[1].to_int() << 1) |
  /// Bit 2:  Filter the output of voice 3?  1=yes
  u8(self.voice[2].to_int() << 2) |
  /// Bit 3:  Filter the output from the external input?  1=yes
  u8(self.external.to_int() << 3) |
  /// Bits 4-7:  Select filter resonance 0-15
  u8(self.resonance << 4)
}

///|
pub struct Envelope {
  /// 54277         $D405          ATDCY1
  /// Bits 4-7:  Select attack cycle duration (0-15)
  mut attack : UInt8
  /// Bits 0-3:  Select decay cycle duration (0-15)
  mut decay : UInt8

  /// 54278         $D406          SUREL1
  /// Bits 4-7:  Select sustain volume level (0-15)
  mut sustain : UInt8
  /// Bits 0-3:  Select release cycle duration (0-15)
  mut release : UInt8
} derive(Show, Default)

///|
pub struct Voice {
  /// 54272         $D400          FRELO1
  /// 54273         $D401          FREHI1
  /// Voice Frequency Control
  mut frequency : UInt16

  /// 54274         $D402          PWLO1
  /// 54275         $D403          PWHI1
  /// Voice Pulse Waveform Width
  mut pulseWidth : UInt16

  /// 54276         $D404          VCREG1
  /// Voice Control Register
  mut control : VoiceControl

  /// 54277         $D405          ATDCY1
  /// 54278         $D406          SUREL1
  /// Voice Attack/Decay/Sustain/Release Control Register
  envelope : Envelope
} derive(Show, Default)

///|
pub struct FilterSelect {
  /// Select Filter Low-Pass Mode: 1 = On
  mut lowPass : Bool
  /// Select Filter Band-Pass Mode: 1 = On
  mut bandPass : Bool
  /// Select Filter High-Pass Mode: 1 = On
  mut highPass : Bool
} derive(Show, Default)

///|
pub struct SIDRegister {
  /// $00 - $01
  /// Voice Frequency Control
  ///
  /// $02 - $03
  /// Voice Pulse Waveform Width Control
  ///
  /// $04
  /// Voice Control Register
  ///
  /// $05 - $06
  /// Voice Envelope (ADSR) Control
  voice : FixedArray[Voice]

  /// $15 - $18
  /// Filter Controls
  ///
  /// $15 - $16
  /// Filter Cutoff Frequency
  mut cutoffFrequency : UInt16
  /// $17
  /// Filter Resonance Control Register
  mut filterResonanceControl : FilterResonanceControl
  ///
  /// $18
  /// Volume and Filter Select Register
  ///
  /// Bits 0-3:  Select Output Volume: 0-15
  mut volume : UInt8
  /// Bit 4:  Select Filter High-Pass Mode: 1 = On
  /// Bit 5:  Select Filter Band-Pass Mode: 1 = On
  /// Bit 6:  Select Filter Low-Pass Mode: 1 = On
  filterSelect : FilterSelect
  /// Bit 7:  Cut-Off Voice 3 Output: 1 = Off, 0 = On
  mut disconnectVoice : Bool

  /// $19 - $1A
  /// Game Paddle Inputs
  ///
  /// $19
  /// $1A
  /// Read Game Paddle Position
  input : FixedArray[UInt8]

  /// $1B
  /// Read Oscillator 3/Random Number Generator
  mut random : UInt8
  // oscillator : UInt8

  /// $1C
  /// Envelope Generator 3 Output
  mut envelope : UInt8
} derive(Show)

///|
fn SIDRegister::default() -> SIDRegister {
  {
    voice: [Voice::default(), Voice::default(), Voice::default()],
    //
    cutoffFrequency: Int::default(),
    filterResonanceControl: FilterResonanceControl::default(),
    //
    volume: 0,
    filterSelect: FilterSelect::default(),
    disconnectVoice: Bool::default(),
    //
    input: [UInt8::default(), UInt8::default()],
    //
    random: UInt8::default(),
    // oscillator: UInt8::default(),
    //
    envelope: UInt8::default(),
  }
}

///|
pub enum SIDregister {
  /// Voice 1 Frequency Control (low byte)
  FRELO1
  /// Voice 1 Frequency Control (high byte)
  FREHI1
  /// Voice 1 Pulse Waveform Width (low byte)
  PWLO1
  /// Voice 1 Pulse Waveform Width (high nybble)
  PWHI1
  /// Voice 1 Control Register
  VCREG1
  /// Voice 1 Attack/Decay Register
  ATDCY1
  /// Voice 1 Sustain/Release Control Register
  SUREL1

  /// Voice 2 Frequency Control (low byte)
  FRELO2
  /// Voice 2 Frequency Control (high byte)
  FREHI2
  /// Voice 2 Pulse Waveform Width (low byte)
  PWLO2
  /// Voice 2 Pulse Waveform Width (high nybble)
  PWHI2
  /// Voice 2 Control Register
  VCREG2
  /// Voice 2 Attack/Decay Register
  ATDCY2
  /// Voice 2 Sustain/Release Control Register
  SUREL2

  /// Voice 3 Frequency Control (low byte)
  FRELO3
  /// Voice 3 Frequency Control (high byte)
  FREHI3
  /// Voice 3 Pulse Waveform Width (low byte)
  PWLO3
  /// Voice 3 Pulse Waveform Width (high nybble)
  PWHI3
  /// Voice 3 Control Register
  VCREG3
  /// Voice 3 Attack/Decay Register
  ATDCY3
  /// Voice 3 Sustain/Release Control Register
  SUREL3

  /// Filter Cutoff Frequency: Low-Nybble
  CUTLO
  /// Filter Cutoff Frequency: High-Byte
  CUTHI
  /// Filter Resonance Control / Voice Input Control
  RESON
  /// Volume and Filter Select Register
  SIGVOL

  /// Read Game Paddle 1 (or 3) Position
  POTX
  /// Read Game Paddle 2 (or 4) Position
  POTY
  /// Read Oscillator 3/Random Number Generator
  RANDOM

  /// Envelope Generator 3 Output
  ENV3

  /// Not Connected
  // UNUSED
} derive(Show, Compare, Eq)

///|
fn sid(register : SIDregister) -> Int {
  match register {
    /// Voice 1
    FRELO1 => 0x00
    FREHI1 => 0x01
    PWLO1 => 0x02
    PWHI1 => 0x03
    VCREG1 => 0x04
    ATDCY1 => 0x05
    SUREL1 => 0x06

    /// Voice 2
    FRELO2 => 0x07
    FREHI2 => 0x08
    PWLO2 => 0x09
    PWHI2 => 0x0A
    VCREG2 => 0x0B
    ATDCY2 => 0x0C
    SUREL2 => 0x0D

    /// Voice 3
    FRELO3 => 0x0E
    FREHI3 => 0x0F
    PWLO3 => 0x10
    PWHI3 => 0x11
    VCREG3 => 0x12
    ATDCY3 => 0x13
    SUREL3 => 0x14

    ///
    CUTLO => 0x15
    CUTHI => 0x16
    RESON => 0x17
    SIGVOL => 0x18

    ///
    POTX => 0x19
    POTY => 0x1A
    RANDOM => 0x1B

    ///
    ENV3 => 0x1C

    ///
    // UNUSED => 0x1D
  }
}

///|
fn SIDregister::from_int(value : Int) -> SIDregister! {
  match value {
    /// Voice 1
    0x00 => FRELO1
    0x01 => FREHI1
    0x02 => PWLO1
    0x03 => PWHI1
    0x04 => VCREG1
    0x05 => ATDCY1
    0x06 => SUREL1

    /// Voice 2
    0x07 => FRELO2
    0x08 => FREHI2
    0x09 => PWLO2
    0x0A => PWHI2
    0x0B => VCREG2
    0x0C => ATDCY2
    0x0D => SUREL2

    /// Voice 3
    0x0E => FRELO3
    0x0F => FREHI3
    0x10 => PWLO3
    0x11 => PWHI3
    0x12 => VCREG3
    0x13 => ATDCY3
    0x14 => SUREL3

    ///
    0x15 => CUTLO
    0x16 => CUTHI
    0x17 => RESON
    0x18 => SIGVOL

    ///
    0x19 => POTX
    0x1A => POTY
    0x1B => RANDOM

    ///
    0x1C => ENV3

    ///
    // 0x1D => UNUSED

    ///
    _ => raise UnknownRegister("SID", value)
  }
}

// fn op_get(self : SIDregister, register : SIDregister) -> Int {
//   self[register]
// }

// fn op_set(self : SIDregister, register : SIDregister, value : Int) -> Unit {
//   self[register] = value
// }

///| Bit 0:  Gate Bit:  1=Start attack/decay/sustain, 0=Start release
/// Bit 1:  Sync Bit:  1=Synchronize Oscillator with Oscillator 3 frequency
/// Bit 2:  Ring Modulation:  1=Ring modulate Oscillators 1 and 3
/// Bit 3:  Test Bit:  1=Disable Oscillator 1
/// Bit 4:  Select triangle waveform
/// Bit 5:  Select sawtooth waveform
/// Bit 6:  Select pulse waveform
/// Bit 7:  Select random noise waveform
struct VoiceControl {
  /// Bit 0.  Bit 0 is used to gate the sound.  Setting this bit to a 1
  /// while selecting one of the four waveforms will start the
  /// attack/decay/sustain part of the cycle.  Setting this bit back to 0
  /// (while keeping the same waveform setting) anytime after a note has
  /// started playing will begin the release cycle of the note.  Of course,
  /// in order for the gate bit to have an effect, the frequency and
  /// attack/decay/sustain/release (ADSR) registers must be set, as well as
  /// the pulse width, if necessary, and the volume control set to a nonzero
  /// value.
  gateBit : Bool

  /// Bit 1.  This bit is used to synchronize the fundamental frequency of
  /// Oscillator 1 with the fundamental frequency of Oscillator 3, allowing
  /// you to create a wide range of complex harmonic structures from voice
  /// 1.  Synchronization occurs when this bit is set to 1.  Oscillator 3
  /// must be set to some frequency other than zero, but no other voice 3
  /// parameters will affect the output from voice 1.
  syncBit : Bool

  /// Bit 2.  When Bit 2 is set to 1, the triangle waveform output of voice
  /// 1 is replaced with a ring modulated combination of Oscillators 1 and
  /// 3.  This ring modulation produces nonharmonic overtone structures that
  /// are useful for creating bell or gong effects.
  ringModulation : Bool

  /// Bit 3.  Bit 3 is the test bit.  When set to 1, it disables the output
  /// of the oscillator.  This can be useful in generating very complex
  /// waveforms (even speech synthesis) under software control.
  testBit : Bool

  /// Bit 4.  When set to 1, Bit 4 selects the triangle waveform output of
  /// Oscillator 1.  Bit 0 must also be set for the note to be sounded.
  triangleWaveform : Bool

  /// Bit 5.  This bit selects the sawtooth waveform when set to 1.  Bit 0
  /// must also be set for the sound to begin.
  sawtoothWaveform : Bool

  /// Bit 6.  Bit 6 chooses the pulse waveform when set to 1.  The harmonic
  /// content of sound produced using this waveform may be varied using the
  /// Pulse Width Registers.  Bit 0 must be set to begin the sound.
  pulseWaveform : Bool

  /// Bit 7.  When Bit 7 is set to 1, the noise output waveform for
  /// Oscillator 1 is set.  This creates a random sound output whose
  /// waveform varies with a frequency proportionate to that of Oscillator
  /// 1.  It can be used to imitate the sound of explosions, drums, and
  /// other unpitched noises.
  noiseWaveform : Bool

  /// One of the four waveforms must be chosed in order to create a sound.
  /// Setting more than one of these bits will result in a logical ANDing of
  /// the waveforms.  Particularly, the combination of the noise waveform
  /// and another is not recommended.
} derive(Show, Default)

///|
fn VoiceControl::from_u8(value : UInt8) -> VoiceControl {
  {
    gateBit: (value & u8(1 << 0)) != 0,
    syncBit: (value & u8(1 << 1)) != 0,
    ringModulation: (value & u8(1 << 2)) != 0,
    testBit: (value & u8(1 << 3)) != 0,
    triangleWaveform: (value & u8(1 << 4)) != 0,
    sawtoothWaveform: (value & u8(1 << 5)) != 0,
    pulseWaveform: (value & u8(1 << 6)) != 0,
    noiseWaveform: (value & u8(1 << 7)) != 0,
  }
}

///|
fn VoiceControl::to_u8(self : VoiceControl) -> UInt8 {
  /// Bit 0:  Gate Bit:  1=Start attack/decay/sustain, 0=Start release
  u8(self.gateBit.to_int() << 0) |
  /// Bit 1:  Sync Bit:  1=Synchronize Oscillator with Oscillator 3 frequency
  u8(self.syncBit.to_int() << 1) |
  /// Bit 2:  Ring Modulation:  1=Ring modulate Oscillators 1 and 3
  u8(self.ringModulation.to_int() << 2) |
  /// Bit 3:  Test Bit:  1=Disable Oscillator 1
  u8(self.testBit.to_int() << 3) |
  /// Bit 4:  Select triangle waveform
  u8(self.triangleWaveform.to_int() << 4) |
  /// Bit 5:  Select sawtooth waveform
  u8(self.sawtoothWaveform.to_int() << 5) |
  /// Bit 6:  Select pulse waveform
  u8(self.pulseWaveform.to_int() << 6) |
  /// Bit 7:  Select random noise waveform
  u8(self.noiseWaveform.to_int() << 7)
}

// fn waveform(self : VoiceControl) -> Int {
//   (self.triangleWaveform.to_int() << 4) | (self.sawtoothWaveform.to_int() << 5) |
//   (self.pulseWaveform.to_int() << 6) | (self.noiseWaveform.to_int() << 7)
// }

///|
fn hasWaveform(self : VoiceControl) -> Bool {
  self.triangleWaveform ||
  self.sawtoothWaveform ||
  self.pulseWaveform ||
  self.noiseWaveform
}
