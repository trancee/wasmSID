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

let sid_mem_start = 0xD400

let sid1_mem_start = 0xD400

let sid_mem_end = 0xD7FF

let sid_mem_size = 0x03FF

struct SID {
  mem : FixedArray[Int]
  baseaddress : Int

  //
  mut model : Model
  mut channel : Channel

  //
  adsr : FixedArray[ADSR]
  wave : FixedArray[Wave]

  //Filter-related:
  mut prevLowPass : Int
  mut prevBandPass : Int

  //Output-stage:
  mut nonFiltedSample : Int
  mut filterInputSample : Int
  mut prevNonFiltedSample : Int
  mut prevFilterInputSample : Int
  //
  mut prevVolume : Int //lowpass-filtered version of Volume-band register
  mut output : Int //not attenuated (range:0.._xFFFFF depending on SID's main-volume)
  mut level : Int //filtered version, good for VU-meter display

  //
  register : SIDRegister

  //
  mut debug : Bool
}

pub fn SID::new(
  mem? : Memory,
  baseaddress : Int,
  //

  model~ : Model = Unknown,
  channel~ : Channel = Unknown,
  videoStandard~ : VideoStandard = Unknown,
  debug~ : Bool = false
) -> SID {
  println("SID::new")
  //

  let sid : SID = {
    mem: FixedArray::make(sid_mem_size + 1, 0x00),
    baseaddress,

    //
    model,
    channel,

    //
    adsr: [ADSR::new(), ADSR::new(), ADSR::new()],
    wave: [Wave::new(), Wave::new(), Wave::new()],

    //Filter-related:
    prevLowPass: 0,
    prevBandPass: 0,

    //Output-stage:
    nonFiltedSample: 0,
    filterInputSample: 0,
    prevNonFiltedSample: 0,
    prevFilterInputSample: 0,
    //
    prevVolume: 0,
    output: 0,
    level: 0,

    //
    register: SIDRegister::default(),

    //
    debug,
  }

  //
  match mem {
    Some(mem) =>
      mem.hook(
        baseaddress,
        baseaddress + sid_mem_size,
        // mem,
        fn(address : UInt16, dummy : Bool) -> UInt8 {
          let register = try {
            SIDregister::from_int!(address._ - baseaddress)
          } catch {
            err => {
              println(err)
              panic()
            }
          }
          sid[register]._
        },
        fn(address : UInt16, value : UInt8, dummy : Bool) {
          let register = try {
            SIDregister::from_int!(address._ - baseaddress)
          } catch {
            err => {
              println(err)
              panic()
            }
          }
          sid[register] = value
        },
      )
  }

  //
  sid.reset()

  //
  sid
}

pub fn reset(self : SID, videoStandard~ : VideoStandard = Unknown) -> Unit {
  // self.mem.reset(offset=self.baseaddress, length=sid_mem_length)
  for i = 0; i < self.mem.length(); i = i + 1 {
    self.mem[i] = 0x00
  }

  /// ($D41D-$D41F)
  /// Not Connected
  ///
  /// The SID chip has been provided with enough addresses for 32 different
  /// registers, but as it has only 29, the remaining three addresses are
  /// not used.  Reading them will always return a value of 255 ($FF), and
  /// writing to them will have no effect.
  for i = 0xD41D - self.baseaddress; i <= 0xD41D - 0xD41F; i = i + 1 {
    self.mem[i] = 0xFF
  }
}

fn emulateADSR(self : SID, cycles : Int) -> Unit {
  let mut prescalePeriod : UInt16 = 0
  for channel = 0; channel < 3; channel = channel + 1 {
    let voice = self.register.voice[channel]
    let adsr = self.adsr[channel]
    let prevGate = adsr.state.gate
    if prevGate != voice.control.gateBit { //gatebit-change?
      if prevGate {
        //falling edge
        self.adsr[channel].state.gate = false
        self.adsr[channel].state.attack = false
        self.adsr[channel].state.decaySustain = false
      } else {
        //rising edge
        self.adsr[channel].state.gate = false
        self.adsr[channel].state.attack = false
        self.adsr[channel].state.decaySustain = false
        self.adsr[channel].state.holdZeroN = false
      }
    }
    //
    if adsr.state.attack {
      prescalePeriod = adsrPrescalePeriods[voice.envelope.attack]
    } else if adsr.state.decaySustain {
      prescalePeriod = adsrPrescalePeriods[voice.envelope.decay]
    } else {
      prescalePeriod = adsrPrescalePeriods[voice.envelope.release]
    }
    //
    adsr.rateCounter += cycles
    if adsr.rateCounter >= 0x8000 {
      //can wrap around (ADSR delay-bug: short 1st frame)
      adsr.rateCounter -= 0x8000
    }
    //
    if prescalePeriod <= adsr.rateCounter &&
      adsr.rateCounter < prescalePeriod + cycles { //ratecounter shot (matches rateperiod) (in genuine SID ratecounter is LFSR)
      adsr.rateCounter -= prescalePeriod //reset rate-counter on period-match
      adsr.exponentCounter += 1
      if adsr.state.attack ||
        adsr.exponentCounter == adsrExponentPeriods[adsr.envelopeCounter] {
        adsr.exponentCounter = 0
        if adsr.state.holdZeroN {
          if adsr.state.attack {
            adsr.envelopeCounter += 1
            if adsr.envelopeCounter == 0xFF {
              adsr.state.attack = false
            }
          } else if not(adsr.state.decaySustain) ||
            adsr.envelopeCounter != voice.envelope.sustain { // FIXME: (SR&0xF0)+(SR>>4)
            adsr.envelopeCounter -= 1
            if adsr.envelopeCounter == 0 {
              adsr.state.holdZeroN = false
            }
          }
        }
      }
    }
  }
}

fn emulateWaves(
  self : SID,
  sampleClockRatio : Int,
  attenuation : Int,
  realSID : Bool
) -> Int {
  // println(">> SID::emulateWaves")
  //

  self.nonFiltedSample = 0
  self.filterInputSample = 0
  let filterSwitchReso = self.register.filterResonanceControl
  // let volumeBand = self.register.outputVolume
  let mut wavGenOut = 0
  //
  //Waveform-generator //(phase accumulator and waveform-selector)
  //
  for channel = 0; channel < 3; channel = channel + 1 {
    let voice = self.register.voice[channel]
    let adsr = self.adsr[channel]
    let wave = self.wave[channel]
    //

    fn combinedWF(wfArray : Waveform, oscval : Int) -> Int {
      let mut oscval = oscval
      if self.model == MOS6581 && wfArray != PulseTriangle {
        oscval = oscval & 0x7FFF
      }
      let pitch = voice.frequency
      let filt = 0x7777 + 0x8888 / pitch._
      wave.prevWavData = (
          wfArray[oscval >> 4] * filt + wave.prevWavData * (0xFFFF - filt)
        ) >>
        16
      wave.prevWavData._ << 8
    }

    //
    let mut utmp = 0
    let mut msb = 0
    let mut pw = 0

    //
    let mut tmp = 0
    let mut envelope = 0
    let mut feedback = false
    let mut steepness = 0
    let mut pulsePeak = 0

    //
    let voiceControl = voice.control
    let testBit = voiceControl.testBit
    let mut phaseAccuPtr = wave.phaseAccu // FIXME: better direct access instead of Ptr?

    //
    let phaseAccuStep = voice.frequency._ * sampleClockRatio
    if testBit || (voiceControl.syncBit && wave.syncSourceMSBrise) {
      phaseAccuPtr = 0
    } else { //stepping phase-accumulator (oscillator)
      phaseAccuPtr += phaseAccuStep
      if phaseAccuPtr >= 0x10000000 {
        phaseAccuPtr -= 0x10000000
      }
      phaseAccuPtr = phaseAccuPtr & 0xFFFFFFF
      msb = phaseAccuPtr & 0x8000000
      wave.syncSourceMSBrise = msb > (wave.prevPhaseAccu & 0x8000000)
    }

    //
    if voiceControl.noiseWaveform {
      tmp = wave.noiseLFSR //clock LFSR all time if clockrate exceeds observable at given samplerate (last term):
      if (phaseAccuPtr & 0x1000000) != (wave.prevPhaseAccu & 0x1000000) ||
        phaseAccuStep >= 0x1000000 {
        feedback = ((tmp & 0x400000) ^ ((tmp & 0x20000) << 5)) != 0
        tmp = ((tmp << 1) | feedback.to_int() | testBit.to_int()) & 0x7FFFFF //TEST-bit turns all bits in noise LFSR to 1 (on real SID slowly, in approx. 8000 microseconds ~ 300 samples)
        wave.noiseLFSR = tmp
      } //we simply zero output when other waveform is mixed with noise. On real SID LFSR continuously gets filled by zero and locks up. ($C1 waveform with pw<8 can keep it for a while.)
      wavGenOut = if voiceControl.triangleWaveform ||
        voiceControl.sawtoothWaveform ||
        voiceControl.pulseWaveform {
        0
      } else {
        ((tmp & 0x100000) >> 5) |
        ((tmp & 0x40000) >> 4) |
        ((tmp & 0x4000) >> 1) |
        ((tmp & 0x800) << 1) |
        ((tmp & 0x200) << 2) |
        ((tmp & 0x20) << 5) |
        ((tmp & 0x04) << 7) |
        ((tmp & 0x01) << 8)
      }
    } else if voiceControl.pulseWaveform { //simple pulse
      pw = voice.pulseWidth._ //PW=0000..FFF0 from SID-register
      utmp = phaseAccuStep >> 13
      if 0 < pw && pw < utmp {
        pw = utmp //Too thin pulsewidth? Correct...
      }
      utmp = utmp ^ 0xFFFF
      if pw > utmp {
        pw = utmp //Too thin pulsewidth? Correct it to a value representable at the current samplerate
      }
      utmp = phaseAccuPtr >> 12
      //
      if not(voiceControl.triangleWaveform) &&
        not(voiceControl.sawtoothWaveform) &&
        not(voiceControl.noiseWaveform) { //simple pulse, most often used waveform, make it sound as clean as possible (by making it trapezoid)
        steepness = if phaseAccuStep >= 4096 { //rising/falling-edge steepness (add/sub at samples)
          0xFFFFFFF / phaseAccuStep
        } else {
          0xFFFF
        }
        if testBit {
          wavGenOut = 0xFFFF
        } else if utmp < pw { //rising edge (interpolation)
          pulsePeak = (0xFFFF - pw) * steepness //very thin pulses don't make a full swing between 0 and max but make a little spike
          if pulsePeak > 0xFFFF { //but adequately thick trapezoid pulses reach the maximum level
            pulsePeak = 0xFFFF
          }
          tmp = pulsePeak - (pw - utmp) * steepness //draw the slope from the peak
          wavGenOut = if tmp < 0 { 0 } else { tmp } //but stop at 0-level
        } else { //falling edge (interpolation)
          pulsePeak = pw * steepness //very thin pulses don't make a full swing between 0 and max but make a little spike
          if pulsePeak > 0xFFFF { //adequately thick trapezoid pulses reach the maximum level
            pulsePeak = 0xFFFF
          }
          tmp = (0xFFFF - utmp) * steepness - pulsePeak //draw the slope from the peak
          wavGenOut = if tmp >= 0 { 0xFFFF } else { tmp } //but stop at max-level
        }
      } else { //combined pulse
        wavGenOut = if utmp >= pw || testBit { 0xFFFF } else { 0 }
        if voiceControl.triangleWaveform {
          if voiceControl.sawtoothWaveform { //pulse+saw+triangle (waveform nearly identical to tri+saw)
            if wavGenOut > 0 {
              wavGenOut = combinedWF(PulseSawTriangle, utmp)
            }
          } else { //pulse+triangle
            tmp = phaseAccuPtr ^
              (if voiceControl.ringModulation { wave.ringSourceMSB } else { 0 })
            if wavGenOut > 0 {
              wavGenOut = combinedWF(PulseTriangle, tmp >> 12)
            }
          }
        } else if voiceControl.sawtoothWaveform { //pulse+saw
          if wavGenOut > 0 {
            wavGenOut = combinedWF(PulseSawtooth, utmp)
          }
        }
      }
    } else if voiceControl.sawtoothWaveform { //sawtooth
      wavGenOut = phaseAccuPtr >> 12 //saw (this row would be enough for simple but aliased-at-high-pitch saw)
      if voiceControl.triangleWaveform {
        wavGenOut = combinedWF(SawTriangle, wavGenOut)
      } else { //saw+triangle
        //simple cleaned (bandlimited) saw
        steepness = (phaseAccuStep >> 4) / 288
        if steepness == 0 { //avoid division by zero in next steps
          steepness = 1
        }
        wavGenOut += (wavGenOut * steepness) >> 16 //1st half (rising edge) of asymmetric triangle-like saw waveform
        if wavGenOut > 0xFFFF {
          wavGenOut = 0xFFFF - ((wavGenOut - 0x10000) << 16) / steepness //2nd half (falling edge, reciprocal steepness)
        }
      }
    } else if voiceControl.triangleWaveform { //triangle (this waveform has no harsh edges, so it doesn't suffer from strong aliasing at high pitches)
      tmp = phaseAccuPtr ^
        (if voiceControl.ringModulation { wave.ringSourceMSB } else { 0 })
      wavGenOut = (tmp ^ (if (tmp & 0x8000000) > 0 { 0xFFFFFFF } else { 0 })) >>
        11
    }

    //
    wavGenOut = wavGenOut & 0xFFFF
    if voiceControl.hasWaveform() {
      wave.prevWavGenOut = wavGenOut //emulate waveform 00 floating wave-DAC (utilized by SounDemon digis)
    } else {
      wavGenOut = wave.prevWavGenOut //(on real SID waveform00 decays, we just simply keep the value to avoid clicks)
    }
    wave.prevPhaseAccu = phaseAccuPtr
    wave.ringSourceMSB = msb

    //routing the channel signal to either the filter or the unfiltered master output depending on filter-switch SID-registers
    envelope = if self.model == MOS8580 {
      adsr.envelopeCounter
    } else {
      adsrDAC_6581[adsr.envelopeCounter]._
    }
    if filterSwitchReso.voice[channel] {
      self.filterInputSample += ((wavGenOut - 0x8000) * envelope) >> 8 // FIXME: (int) clamping?
    } else if channel != 2 || not(self.register.disconnectVoice) {
      self.nonFiltedSample += ((wavGenOut - 0x8000) * envelope) >> 8 // FIXME: (int) clamping?
    }
  }

  // //update readable SID1-registers (some SID tunes might use 3rd channel ENV3/OSC3 value as control)
  // self[RANDOM] = wavGenOut >> 8 //OSC3, ENV3 (some players rely on it, unfortunately even for timing)
  // self[ENV3] = self.adsr[2].envelopeCounter //Envelope

  //
  // println("<< SID::emulateWaves")

  //
  self.emulateSIDoutputStage(attenuation, realSID)
}

fn emulateSIDoutputStage(self : SID, attenuation : Int, realSID : Bool) -> Int {
  // println(
  //   ">> SID::emulateSIDoutputStage attenuation[\{attenuation}] realSID[\{realSID}]",
  // )
  //

  let mut mainVolume = 0
  //
  let mut tmp = 0
  let mut nonFilted = 0
  let mut filterInput = 0
  let mut filterOutput = 0

  //
  let filterSwitchReso = self.register.filterResonanceControl
  let filterSelect = self.register.filterSelect
  let mut cutoff = self.register.cutoffFrequency // (SID->BasePtr[0x16] << 3) + (SID->BasePtr[0x15] & 7);
  let mut resonance = filterSwitchReso.resonance
  //

  nonFilted = self.nonFiltedSample
  filterInput = self.filterInputSample

  //Filter

  match self.model {
    MOS8580 => {
      cutoff = cutoffMul8580_44100Hz[cutoff._]
      resonance = resonances8580[resonance]._
    }
    MOS6581 => {
      //MOSFET-VCR control-voltage calculation
      cutoff += (filterInput * 105) >> 16
      if cutoff > 0x7FF {
        cutoff = 0x7FF
      } else if cutoff < 0 {
        cutoff = 0
      }
      cutoff = cutoffMul6581_44100Hz[cutoff._] //(resistance-modulation aka 6581 filter distortion) emulation
      resonance = resonances6581[resonance]._
    }
    _ => {
      println("unknown SID model")
      abort("unknown SID model")
    }
  }

  //
  filterOutput = 0
  tmp = filterInput + ((self.prevBandPass * resonance) >> 12) + self.prevLowPass
  if filterSelect.highPass {
    filterOutput -= tmp
  }
  tmp = self.prevBandPass - ((tmp * cutoff._) >> 12)
  self.prevBandPass = tmp
  if filterSelect.bandPass {
    filterOutput -= tmp
  }
  tmp = self.prevLowPass + ((tmp * cutoff._) >> 12)
  self.prevLowPass = tmp
  if filterSelect.lowPass {
    filterOutput += tmp
  }

  //Output-mixing stage

  //For $D418 volume-register digi playback: an AC / DC separation for $D418 value at low (20Hz or so) cutoff-frequency,
  //sending AC (highpass) value to a 4th 'digi' channel mixed to the master output, and set ONLY the DC (lowpass) value to the volume-control.
  //This solved 2 issues: Thanks to the lowpass filtering of the volume-control, SID tunes where digi is played together with normal SID channels,
  //won't sound distorted anymore, and the volume-clicks disappear when setting SID-volume. (This is useful for fade-in/out tunes like Hades Nebula, where clicking ruins the intro.)
  if realSID {
    tmp = self.register.volume.to_signed() << 12 // FIXME: (signed int) clamping?
    nonFilted += (tmp - self.prevVolume) * sidSpecs(D418_DIGI_VOLUME) //highpass is digi, adding it to output must be before digifilter-code
    self.prevVolume += (tmp - self.prevVolume) >> 10 //arithmetic shift amount determines digi lowpass-frequency
    mainVolume = self.prevVolume >> 12
  } else { //lowpass is main volume
    mainVolume = self.register.volume._
  }

  //
  // println("<< SID::emulateSIDoutputStage")

  //
  self.output = (nonFilted + filterOutput) * mainVolume
  self.output / (sidSpecs(CHANNELS) * sidSpecs(VOLUME_MAX) + attenuation) // master output of a SID
}

//----------------------- High-quality (oversampled) waveform-generation --------------------------

fn emulateHQWaves(self : SID, cycles : Int) -> SIDwavOutput {
  self.nonFiltedSample = 0
  self.filterInputSample = 0
  //
  let wavOutput = { nonFilted: 0, filterInput: 0 }
  let filterSwitchReso = self.register.filterResonanceControl
  let mut wavGenOut = 0
  //
  //Waveform-generator //(phase accumulator and waveform-selector)
  //
  for channel = 0; channel < 3; channel = channel + 1 {
    let voice = self.register.voice[channel]
    let adsr = self.adsr[channel]
    let wave = self.wave[channel]
    //
    fn combinedHQWF(wfArray : Waveform, oscval : Int) -> Int {
      let mut oscval = oscval
      if self.model == MOS6581 && wfArray != PulseTriangle {
        oscval = oscval & 0x7FFF
      }
      return wfArray[oscval >> 4]._ << 8
    }

    let mut utmp = 0
    let mut msb = 0
    let mut pw = 0
    let mut tmp = 0
    let mut envelope = 0
    let mut feedback = false
    //
    //
    //
    let voiceControl = voice.control
    let testBit = voiceControl.testBit
    let mut phaseAccuPtr = wave.phaseAccu // FIXME: better direct access instead of Ptr?
    //
    let phaseAccuStep = voice.frequency._ * cycles
    if testBit || (voiceControl.syncBit && wave.syncSourceMSBrise) {
      phaseAccuPtr = 0
    } else { //stepping phase-accumulator (oscillator)
      phaseAccuPtr += phaseAccuStep
      if phaseAccuPtr >= 0x10000000 {
        phaseAccuPtr -= 0x10000000
      }
      phaseAccuPtr = phaseAccuPtr & 0xFFFFFFF
      msb = phaseAccuPtr & 0x8000000
      wave.syncSourceMSBrise = msb > (wave.prevPhaseAccu & 0x8000000)
    }

    //
    if voiceControl.noiseWaveform {
      tmp = wave.noiseLFSR //clock LFSR all time if clockrate exceeds observable at given samplerate (last term):
      //
      if (phaseAccuPtr & 0x100000) != (wave.prevPhaseAccu & 0x100000) {
        feedback = ((tmp & 0x400000) ^ ((tmp & 0x20000) << 5)) != 0
        tmp = ((tmp << 1) | feedback.to_int() | testBit.to_int()) & 0x7FFFFF //TEST-bit turns all bits in noise LFSR to 1 (on real SID slowly, in approx. 8000 microseconds ~ 300 samples)
        wave.noiseLFSR = tmp
      } //we simply zero output when other waveform is mixed with noise. On real SID LFSR continuously gets filled by zero and locks up. ($C1 waveform with pw<8 can keep it for a while.)
      wavGenOut = if voiceControl.triangleWaveform ||
        voiceControl.sawtoothWaveform ||
        voiceControl.pulseWaveform {
        0
      } else {
        ((tmp & 0x100000) >> 5) |
        ((tmp & 0x40000) >> 4) |
        ((tmp & 0x4000) >> 1) |
        ((tmp & 0x800) << 1) |
        ((tmp & 0x200) << 2) |
        ((tmp & 0x20) << 5) |
        ((tmp & 0x04) << 7) |
        ((tmp & 0x01) << 8)
      }
    } else if voiceControl.pulseWaveform { //simple pulse or pulse+combined
      pw = voice.pulseWidth._ //PW=0000..FFF0 from SID-register
      utmp = phaseAccuStep >> 8
      wavGenOut = if utmp >= pw || testBit { 0xFFFF } else { 0 }
      //
      if voiceControl.triangleWaveform ||
        voiceControl.sawtoothWaveform ||
        voiceControl.noiseWaveform { //combined pulse
        if voiceControl.triangleWaveform {
          if voiceControl.sawtoothWaveform { //pulse+saw+triangle (waveform nearly identical to tri+saw)
            if wavGenOut != 0 {
              wavGenOut = combinedHQWF(PulseSawTriangle, utmp)
            }
          } else { //pulse+triangle
            tmp = phaseAccuPtr ^
              (if voiceControl.ringModulation { wave.ringSourceMSB } else { 0 })
            if wavGenOut != 0 {
              wavGenOut = combinedHQWF(PulseTriangle, tmp >> 8)
            }
          }
        } else if voiceControl.sawtoothWaveform { //pulse+saw
          if wavGenOut != 0 {
            wavGenOut = combinedHQWF(PulseSawtooth, utmp)
          }
        }
      }
    } else if voiceControl.sawtoothWaveform { //sawtooth
      wavGenOut = phaseAccuPtr >> 8
      if voiceControl.triangleWaveform {
        wavGenOut = combinedHQWF(SawTriangle, wavGenOut) //saw+triangle
      } else if voiceControl.triangleWaveform { //triangle (this waveform has no harsh edges, so it doesn't suffer from strong aliasing at high pitches)
        tmp = phaseAccuPtr ^
          (if voiceControl.ringModulation { wave.ringSourceMSB } else { 0 })
        wavGenOut = (tmp ^ (if (tmp & 0x800000) > 0 { 0xFFFFFF } else { 0 })) >>
          7
      }

      //
      wavGenOut = wavGenOut & 0xFFFF
      if voiceControl.hasWaveform() {
        wave.prevWavGenOut = wavGenOut //emulate waveform 00 floating wave-DAC (utilized by SounDemon digis)
      } else {
        wavGenOut = wave.prevWavGenOut //(on real SID waveform00 decays, we just simply keep the value to avoid clicks)
      }
      wave.prevPhaseAccu = phaseAccuPtr
      wave.ringSourceMSB = msb

      //routing the channel signal to either the filter or the unfiltered master output depending on filter-switch SID-registers
      envelope = if self.model == MOS8580 {
        adsr.envelopeCounter
      } else {
        adsrDAC_6581[adsr.envelopeCounter]._
      }
      if filterSwitchReso.voice[channel] {
        wavOutput.filterInput += ((wavGenOut - 0x8000) * envelope) >> 8 // FIXME: (int) clamping?
      } else if channel != 2 || not(self.register.disconnectVoice) {
        wavOutput.nonFilted += ((wavGenOut - 0x8000) * envelope) >> 8 // FIXME: (int) clamping?
      }
    }
  }

  //update readable SID1-registers (some SID tunes might use 3rd channel ENV3/OSC3 value as control)
  self[RANDOM] = wavGenOut >> 8 //OSC3, ENV3 (some players rely on it, unfortunately even for timing)
  self[ENV3] = self.adsr[2].envelopeCounter //Envelope

  //
  wavOutput
}

fn op_get(self : SID, register : SIDregister) -> UInt8 {
  /// SID Register Images
  let address = sid(register) % 0x20 // (repeated every $20, 32 bytes)
  if self.debug {
    println(
      "\t\t\t\t\t\t\t\t\t " +
      "🎵 SID $" +
      UInt16(self.baseaddress + address).to_hex() +
      " → #$" +
      UInt8(self.mem[address]).to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < sid_mem_start ||
    self.baseaddress + address > sid_mem_end {
    // self.dump()
    println(
      "SID \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " → #$" +
      UInt8(self.mem[address]).to_hex(),
    )
    abort("out of bounds")
  }
  fn voice(voice : Voice) -> UInt8 {
    match register {
      /// Voice 1 Frequency Control (low byte)
      /// 54272         $D400          FRELO1
      FRELO1 | FRELO2 | FRELO3 => u8(voice.frequency)

      /// Voice 1 Frequency Control (high byte)
      /// 54273         $D401          FREHI1
      FREHI1 | FREHI2 | FREHI3 => u8(voice.frequency >> 8)

      /// Voice 1 Pulse Waveform Width (low byte)
      /// 54274         $D402          PWLO1
      PWLO1 | PWLO2 | PWLO3 => u8(voice.pulseWidth)

      /// Voice 1 Pulse Waveform Width (high nybble)
      /// 54275         $D403          PWHI1
      PWHI1 | PWHI2 | PWHI3 => u8(voice.pulseWidth >> 8)

      /// Voice 1 Control Register
      /// 54276         $D404          VCREG1
      VCREG1 | VCREG2 | VCREG3 => voice.control.to_u8()

      /// Voice 1 Attack/Decay Register
      /// 54277         $D405          ATDCY1
      ///
      /// Bits 4-7:  Select attack cycle duration (0-15)
      /// Bits 0-3:  Select decay cycle duration (0-15)
      ATDCY1 | ATDCY2 | ATDCY3 =>
        (voice.envelope.attack << 4) | voice.envelope.decay

      /// Voice 1 Sustain/Release Control Register
      /// 54278         $D406          SUREL1
      ///
      /// Bits 4-7:  Select sustain volume level (0-15)
      /// Bits 0-3:  Select release cycle duration (0-15)
      SUREL1 | SUREL2 | SUREL3 =>
        (voice.envelope.sustain << 4) | voice.envelope.release
    }
  }

  match register {
    FRELO1 | FREHI1 | PWLO1 | PWHI1 | VCREG1 | ATDCY1 | SUREL1 =>
      voice(self.register.voice[0])
    FRELO2 | FREHI2 | PWLO2 | PWHI2 | VCREG2 | ATDCY2 | SUREL2 =>
      voice(self.register.voice[1])
    FRELO3 | FREHI3 | PWLO3 | PWHI3 | VCREG3 | ATDCY3 | SUREL3 =>
      voice(self.register.voice[2])
    //
    CUTLO => u8(self.register.cutoffFrequency)
    CUTHI => u8(self.register.cutoffFrequency >> 8)

    /// Filter Resonance Control Register
    /// 54295         $D417          RESON
    ///
    /// Bit 0:  Filter the output of voice 1?  1=yes
    /// Bit 1:  Filter the output of voice 2?  1=yes
    /// Bit 2:  Filter the output of voice 3?  1=yes
    /// Bit 3:  Filter the output from the external input?  1=yes
    /// Bits 4-7:  Select filter resonance 0-15
    RESON => self.register.filterResonanceControl.to_u8()

    /// Volume and Filter Select Register
    /// 54296         $D418          SIGVOL
    ///
    /// Bits 0-3:  Select output volume (0-15)
    /// Bit 4:  Select low-pass filter, 1=low-pass on
    /// Bit 5:  Select band-pass filter, 1=band-pass on
    /// Bit 6:  Select high-pass filter, 1=high-pass on
    /// Bit 7:  Disconnect output of voice 4, 1=voice 3 off
    SIGVOL =>
      self.register.volume |
      (self.register.filterSelect.lowPass.to_int() << 4) |
      (self.register.filterSelect.bandPass.to_int() << 5) |
      (self.register.filterSelect.highPass.to_int() << 6) |
      (self.register.disconnectVoice.to_int() << 7)
  }
}

fn op_set(self : SID, register : SIDregister, value : UInt8) -> Unit {
  /// SID Register Images
  let address = sid(register) % 0x20 // (repeated every $20, 32 bytes)
  if self.debug {
    println(
      "\t\t\t\t\t\t\t\t\t " +
      "🎵 SID $" +
      UInt16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < sid_mem_start ||
    self.baseaddress + address > sid_mem_end {
    // self.dump()
    println(
      "SID \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex(),
    )
    abort("out of bounds")
  }
  fn voice(voice : Voice) -> Unit {
    match register {
      /// Voice 1 Frequency Control (low byte)
      /// 54272         $D400          FRELO1
      FRELO1 | FRELO2 | FRELO3 => voice.frequency = voice.frequency | u16(value)

      /// Voice 1 Frequency Control (high byte)
      /// 54273         $D401          FREHI1
      FREHI1 | FREHI2 | FREHI3 =>
        voice.frequency = voice.frequency | (u16(value) << 8)

      /// Voice 1 Pulse Waveform Width (low byte)
      /// 54274         $D402          PWLO1
      PWLO1 | PWLO2 | PWLO3 => voice.pulseWidth = voice.pulseWidth | u16(value)

      /// Voice 1 Pulse Waveform Width (high nybble)
      /// 54275         $D403          PWHI1
      PWHI1 | PWHI2 | PWHI3 =>
        voice.pulseWidth = voice.pulseWidth | (u16(value) << 8)

      // /// Voice 1 Control Register
      // /// 54276         $D404          VCREG1
      VCREG1 | VCREG2 | VCREG3 => voice.control = VoiceControl::from_u8(value)

      // /// Voice 1 Attack/Decay Register
      // /// 54277         $D405          ATDCY1
      // /// Bits 4-7:  Select attack cycle duration (0-15)
      // /// Bits 0-3:  Select decay cycle duration (0-15)
      ATDCY1 | ATDCY2 | ATDCY3 => {
        voice.envelope.attack = (value._ & 0xF0) >> 4
        voice.envelope.decay = value._ & 0x0F
      }

      // /// Voice 1 Sustain/Release Control Register
      // /// 54278         $D406          SUREL1
      // /// Bits 4-7:  Select sustain volume level (0-15)
      // /// Bits 0-3:  Select release cycle duration (0-15)
      SUREL1 | SUREL2 | SUREL3 => {
        voice.envelope.sustain = (value._ & 0xF0) >> 4
        voice.envelope.release = value._ & 0x0F
      }
    }
  }

  match register {
    FRELO1 | FREHI1 | PWLO1 | PWHI1 | VCREG1 | ATDCY1 | SUREL1 =>
      voice(self.register.voice[0])
    FRELO2 | FREHI2 | PWLO2 | PWHI2 | VCREG2 | ATDCY2 | SUREL2 =>
      voice(self.register.voice[1])
    FRELO3 | FREHI3 | PWLO3 | PWHI3 | VCREG3 | ATDCY3 | SUREL3 =>
      voice(self.register.voice[2])
    //
    CUTLO =>
      self.register.cutoffFrequency = self.register.cutoffFrequency | u16(value)
    CUTHI =>
      self.register.cutoffFrequency = self.register.cutoffFrequency |
        (u16(value) << 8)

    /// Filter Resonance Control Register
    /// 54295         $D417          RESON
    RESON =>
      self.register.filterResonanceControl = FilterResonanceControl::from_u8(
        value,
      )

    /// Volume and Filter Select Register
    /// 54296         $D418          SIGVOL
    SIGVOL => {
      self.register.volume = value & 0x0F
      self.register.filterSelect.lowPass = (value & (1 << 4)) != 0
      self.register.filterSelect.bandPass = (value & (1 << 5)) != 0
      self.register.filterSelect.highPass = (value & (1 << 6)) != 0
      self.register.disconnectVoice = (value & (1 << 7)) != 0
    }

    /// Read Game Paddle 1 (or 3) Position
    /// 54297         $D419          POTX
    POTX => self.register.input[0] = value
    /// Read Game Paddle 2 (or 4) Position
    /// 54298         $D41A          POTY
    POTY => self.register.input[1] = value

    /// Read Oscillator 3/Random Number Generator
    /// 54299         $D41B          RANDOM
    RANDOM => self.register.random = value

    /// Envelope Generator 3 Output
    /// 54300         $D41C          ENV3
    ENV3 => self.register.envelope = value
  }
}
