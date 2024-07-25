/// MOS 6581 SOUND INTERFACE DEVICE (SID)

enum SIDregister {
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
} derive(Show, Compare, Eq)

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
  }
}

enum VoiceControlRegister {
  /// Bit 0.  Bit 0 is used to gate the sound.  Setting this bit to a 1
  /// while selecting one of the four waveforms will start the
  /// attack/decay/sustain part of the cycle.  Setting this bit back to 0
  /// (while keeping the same waveform setting) anytime after a note has
  /// started playing will begin the release cycle of the note.  Of course,
  /// in order for the gate bit to have an effect, the frequency and
  /// attack/decay/sustain/release (ADSR) registers must be set, as well as
  /// the pulse width, if necessary, and the volume control set to a nonzero
  /// value.
  GateBit

  /// Bit 1.  This bit is used to synchronize the fundamental frequency of
  /// Oscillator 1 with the fundamental frequency of Oscillator 3, allowing
  /// you to create a wide range of complex harmonic structures from voice
  /// 1.  Synchronization occurs when this bit is set to 1.  Oscillator 3
  /// must be set to some frequency other than zero, but no other voice 3
  /// parameters will affect the output from voice 1.
  SyncBit

  /// Bit 2.  When Bit 2 is set to 1, the triangle waveform output of voice
  /// 1 is replaced with a ring modulated combination of Oscillators 1 and
  /// 3.  This ring modulation produces nonharmonic overtone structures that
  /// are useful for creating bell or gong effects.
  RingModulation

  /// Bit 3.  Bit 3 is the test bit.  When set to 1, it disables the output
  /// of the oscillator.  This can be useful in generating very complex
  /// waveforms (even speech synthesis) under software control.
  TestBit

  /// Bit 4.  When set to 1, Bit 4 selects the triangle waveform output of
  /// Oscillator 1.  Bit 0 must also be set for the note to be sounded.
  SelectTriangleWaveform

  /// Bit 5.  This bit selects the sawtooth waveform when set to 1.  Bit 0
  /// must also be set for the sound to begin.
  SelectSawtoothWaveform

  /// Bit 6.  Bit 6 chooses the pulse waveform when set to 1.  The harmonic
  /// content of sound produced using this waveform may be varied using the
  /// Pulse Width Registers.  Bit 0 must be set to begin the sound.
  SelectPulseWaveform

  /// Bit 7.  When Bit 7 is set to 1, the noise output waveform for
  /// Oscillator 1 is set.  This creates a random sound output whose
  /// waveform varies with a frequency proportionate to that of Oscillator
  /// 1.  It can be used to imitate the sound of explosions, drums, and
  /// other unpitched noises.
  SelectRandomNoiseWaveform

  /// One of the four waveforms must be chosed in order to create a sound.
  /// Setting more than one of these bits will result in a logical ANDing of
  /// the waveforms.  Particularly, the combination of the noise waveform
  /// and another is not recommended.
}

fn op_get(self : VoiceControlRegister, flag : VoiceControlRegister) -> Int {
  match flag {
    /// Gate Bit: 1 = Start Attack/Decay/Sustain
    ///           0 = Start Release
    GateBit => 1 << 0
    /// Sync Bit: 1 = Synchronize Oscillator with Oscillator 3 Frequency
    SyncBit => 1 << 1
    /// Ring Modulation: 1 = Ring modulate Oscillators 1 and 3
    RingModulation => 1 << 2
    /// Test Bit: 1 = Disable Oscillator 1
    TestBit => 1 << 3
    SelectTriangleWaveform => 1 << 4
    SelectSawtoothWaveform => 1 << 5
    SelectPulseWaveform => 1 << 6
    SelectRandomNoiseWaveform => 1 << 7
  }
}

enum AttackDecayCycleControl {
  SelectAttackCycleDuration
  SelectDecayCycleDuration
}

fn op_get(
  self : AttackDecayCycleControl,
  flag : AttackDecayCycleControl
) -> Int {
  match flag {
    SelectAttackCycleDuration => (1 << 7) | (1 << 6) | (1 << 5) | (1 << 4)
    SelectDecayCycleDuration => (1 << 3) | (1 << 2) | (1 << 1) | (1 << 0)
  }
}

enum SustainReleaseCycleControl {
  SelectSustainCycleDuration
  SelectReleaseCycleDuration
}

fn op_get(
  self : SustainReleaseCycleControl,
  flag : SustainReleaseCycleControl
) -> Int {
  match flag {
    SelectSustainCycleDuration => (1 << 7) | (1 << 6) | (1 << 5) | (1 << 4)
    SelectReleaseCycleDuration => (1 << 3) | (1 << 2) | (1 << 1) | (1 << 0)
  }
}

enum FilterResonanceControlRegister {
  /// Bits 0-3 are used to control which of the voices will be altered by
  /// the filters.  If one of these bits is set to 1, the corresponding
  /// voice will be processed through the filter, and its harmonic content
  /// will be changed accordingly.  If the bit is set to 0, the voice will
  /// pass directly to the audio output.  Note that there is also a
  /// provision for processing an external audio signal which is brought
  /// through pin 5 of the Audio/Video Port.
  FilterVoice1Output
  FilterVoice2Output
  FilterVoice3Output
  FilterExternalInput

  /// Bits 4-7 control the resonance of the filter.  By placing a number
  /// from 0 to 15 in these four bits, you may peak the volume of those
  /// frequencies nearest the cutoff.  This creates an even sharper
  /// filtering effect.  A setting of 0 causes no resonance, while a setting
  /// of 15 gives maximum resonance.
  SelectFilterResonance
}

fn op_get(
  self : FilterResonanceControlRegister,
  flag : FilterResonanceControlRegister
) -> Int {
  match flag {
    FilterVoice1Output => 1 << 0
    FilterVoice2Output => 1 << 1
    FilterVoice3Output => 1 << 2
    FilterExternalInput => 1 << 3
    SelectFilterResonance => (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)
  }
}

enum VolumeFilterSelectRegister {
  /// Bits 0-3 control the volume of all outputs.  The possible volume
  /// levels range from 0 (no volume) to 15 (maximum volume).  Some level of
  /// volume must be set here before any sound can be heard.
  SelectOutputVolume

  /// Bits 4-6 control the selection of the low-pass, band-pass, or
  /// high-pass filter.  A 1 in any of these bits turns the corresponding
  /// filter on.  These filters can be combined, although only one cutoff
  /// frequency can be chosen.  In order for the filter to have any effect,
  /// at least one of the voices must be routed through it using the Filter
  /// Resonance Control Register at 54295 ($D417).
  SelectFilterLowPassMode
  SelectFilterBandPassMode
  SelectFilterHighPassMode

  /// When Bit 7 is set to 1,  it disconnects the output of voice 3.  This
  /// allows you to use the output of the oscillator for modulating the
  /// frequency of the other voices, or for generating random number,
  /// without any undesired audio output.
  CutOffVoice3Output
}

fn op_get(
  self : VolumeFilterSelectRegister,
  flag : VolumeFilterSelectRegister
) -> Int {
  match flag {
    SelectOutputVolume => (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3)
    //
    SelectFilterLowPassMode => 1 << 4
    SelectFilterBandPassMode => 1 << 5
    SelectFilterHighPassMode => 1 << 6
    //
    CutOffVoice3Output => 1 << 7
  }
}
