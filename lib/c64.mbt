// https://www.zimmers.net/cbmpics/cbm/c64/

///|
const C64_MEM_START : Int = 0x0000

///|
const C64_MEM_END : Int = C64_MEM_START + C64_MEM_SIZE

///|
const C64_MEM_SIZE : Int = 0xFFFF

///|
const C64_BASIC_MEM_START : Int = 0xA000

///|
const C64_BASIC_MEM_END : Int = C64_BASIC_MEM_START + C64_BASIC_MEM_SIZE

///|
const C64_BASIC_MEM_SIZE : Int = 0x1FFF

///|
const C64_KERNAL_MEM_START : Int = 0xE000

///|
const C64_KERNAL_MEM_END : Int = C64_KERNAL_MEM_START + C64_KERNAL_MEM_SIZE

///|
const C64_KERNAL_MEM_SIZE : Int = 0x1FFF

///|
const C64_CHARACTERS_MEM_START : Int = 0xD000

///|
const C64_CHARACTERS_MEM_END : Int = C64_CHARACTERS_MEM_START +
  C64_CHARACTERS_MEM_SIZE

///|
const C64_CHARACTERS_MEM_SIZE : Int = 0x0FFF

///|
pub struct C64 {
  pc : UInt16
  mem : Memory
  //
  basic : Bytes
  characters : Bytes
  kernal : Bytes
  //
  bank : FixedArray[Bank]
  //
  cpu : @cpu.CPU
  sid : Array[SID]
  cia : Array[CIA]
  vic : VIC
  //
  model : FixedArray[Model]
  realSID : Bool
  //
  mut sampleRate : Int
  highQuality : Bool
  stereo : Bool
  playbackSpeed : Int
  paused : Bool
  //
  // C64-machine related:
  //
  videoStandard : VideoStandard
  mut cpuFrequency : CPUClock
  mut sampleClockRatio : Int //ratio of CPU-clock and samplerate
  selectedModel : Model
  mainVolume : Double
  //
  // SID-file related:
  //
  mut attenuation : Int
  timerSource : Int //for current subtune, 0:VIC, 1:CIA (as in SID-header)
  //
  // PSID-playback related:
  //
  mut frameCycles : Int
  mut frameCycleCnt : Int //this is a substitution in PSID-mode for CIA/VIC counters
  mut prevRasterLine : Int
  mut sampleCycleCnt : Int
  mut overSampleCycleCnt : Int
  //
  mut finished : Bool
  returned : Bool
  //
  mut irq : Bool //collected IRQ line from devices
  mut nmi : Bool //collected NMI line from devices
  //
  mut prevNMI : Bool //used for NMI leading edge detection
  //
  mut cycles : Int
  //
  mut debug : Bool
}

///|
let defaultSampleRate = 44100

///|
pub fn C64::new(
  pc~ : UInt16 = 0x0000,
  mem? : Memory,
  //
  data~ : Bytes = [],
  address~ : UInt16 = 0x0000,
  length~ : Int = data.length(),
  //
  sampleRate~ : Int = defaultSampleRate,
  model~ : FixedArray[Model] = [MOS6581],
  videoStandard~ : VideoStandard = VideoStandard::PAL,
  //
  realSID~ : Bool = false,
  //
  debug~ : Bool = false
) -> C64 {
  let mem = mem.or(Memory::new())

  //
  let cpu = @cpu.CPU::new(
    pc~,
    //
    debug~,
  )

  //
  let basic = match @fs.read_file_to_bytes?("files/ROM/basic.901226-01.bin") {
    Ok(basic) => basic
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }
  let characters = match
    @fs.read_file_to_bytes?("files/ROM/characters.906143-02.bin") {
    Ok(characters) => characters
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }
  let kernal = match @fs.read_file_to_bytes?("files/ROM/kernal.901227-03.bin") {
    Ok(kernal) => kernal
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  // mem.setROM()

  //default C64 setup with only 1 SID and 2 CIAs and 1 VIC
  let sid = [SID::new(mem~, SID_MEM_START, videoStandard~, debug~)]
  let cia = [
    CIA::new(mem~, CIA1_MEM_START, videoStandard~, debug~),
    CIA::new(mem~, CIA2_MEM_START, videoStandard~, debug~),
  ]
  let vic = VIC::new(mem~, VIC_MEM_START, videoStandard~, debug~)
  //

  let c64 : C64 = {
    pc,
    mem,
    //
    basic,
    characters,
    kernal,
    //
    bank: FixedArray::make(8, Bank::RAM),
    //
    cpu,
    sid,
    cia,
    vic,
    //
    model,
    realSID,
    //
    sampleRate,
    highQuality: false,
    stereo: false,
    playbackSpeed: 0,
    paused: false,
    //
    videoStandard,
    cpuFrequency: Unknown,
    sampleClockRatio: 0,
    selectedModel: Unknown,
    mainVolume: 0.0,
    //
    attenuation: 26,
    timerSource: 0,
    //
    frameCycles: 0,
    frameCycleCnt: 0,
    prevRasterLine: 0,
    sampleCycleCnt: 0,
    overSampleCycleCnt: 0,
    //
    finished: false,
    returned: false,
    //
    irq: false,
    nmi: false,
    //
    prevNMI: false,
    //
    cycles: 0,
    //
    debug,
  }

  // c64.initC64()

  cpu.set_read(fn(address : UInt16, dummy : Bool) -> UInt8 {
    c64.read(address, dummy~)
  })
  cpu.set_write(fn(address : UInt16, value : UInt8, dummy : Bool) -> Unit {
    c64.write(address, value, dummy~)
  })

  // must happen after read/write functions set
  cpu.load(address, data, length~) |> ignore

  //
  try {
    c64.reset!()
  } catch {
    err => {
      println(err)
      panic()
    }
  }

  //
  c64
}

///|
pub fn set_debug(self : C64, debug : Bool) -> Unit {
  self.debug = debug
  self.cpu.set_debug(debug)
}

///|
fn clear_bank(self : C64) -> Unit {
  self.bank[BANK_BASIC] = RAM
  self.bank[BANK_KERNAL] = RAM
  self.bank[BANK_CHARACTERS] = RAM
}

///|
pub fn set_bank(self : C64, port : IOPort) -> Unit {
  self.clear_bank()
  if port.hiram {
    self.bank[BANK_KERNAL] = ROM
  }
  if port.loram && port.hiram {
    self.bank[BANK_BASIC] = ROM
  }
  if port.charen && (port.loram || port.hiram) {
    self.bank[BANK_CHARACTERS] = IO
  } else if port.charen && not(port.loram) && not(port.hiram) {
    self.bank[BANK_CHARACTERS] = RAM
  } else {
    self.bank[BANK_CHARACTERS] = ROM
  }
}

//set hardware-parameters (Models, SIDs) for playback of loaded SID-tune
///|
pub fn C64::reset(self : C64) -> Unit! {
  println(">> C64::reset")

  //
  if self.sampleRate == 0 {
    self.sampleRate = 44100
  }
  self.cpuFrequency = CPUClock(self.videoStandard)
  self.sampleClockRatio = (self.cpuFrequency.to_int!() << 4) / self.sampleRate //shifting (multiplication) enhances SampleClockRatio precision
  //
  self.vic.rasterCompare = ScanLines(self.videoStandard).to_int!() // HINT: should be inferred
  self.vic.rasterRowCycles = ScanLineCycles(self.videoStandard).to_int!() // HINT: should be inferred
  self.frameCycles = self.vic.rasterCompare * self.vic.rasterRowCycles ///C64->SampleRate / PAL_FRAMERATE; //1x speed tune with VIC Vertical-blank timing
  //
  self.prevRasterLine = -1 //so if $d012 is set once only don't disturb FrameCycleCnt
  //

  let model = self.model[0]
  self.sid[0].model = if self.selectedModel != Unknown {
    self.selectedModel
  } else {
    model
  }

  //
  self.sid[0].channel = Channel::Both

  // // SID #2
  // let mut model = self.psid.flags.model[1]
  // if model == Unknown {
  //   model = self.sid[0].model
  // }
  // if self.selectedModel != Unknown {
  //   model = self.selectedModel
  // }
  // self.sid[1] = SID::new(
  //   self.cpu,
  //   0xD000 + (self.psid.sid2Address << 4).0,
  //   ~model,
  //   channel=Channel::Right,
  // )

  // // SID #3
  // let mut model = self.psid.flags.model[2]
  // if model == Unknown {
  //   model = self.sid[0].model
  // }
  // if self.selectedModel != Unknown {
  //   model = self.selectedModel
  // }
  // self.sid[2] = SID::new(
  //   self.cpu,
  //   0xD000 + (self.psid.sid3Address << 4).0,
  //   ~model,
  //   channel=Channel::Both,
  // )

  //
  if self.sid.length() > 1 {
    self.sid[0].channel = Channel::Left
  }

  //
  self.attenuation = match self.sid.length() {
    0 => 0
    1 => 26
    2 => 43 //increase for 2SID (to 43)
    3 => 137 //increase for 3SID (to 137)
    _ => raise UnsupportedNoSIDs("SID", self.sid.length())
  }

  // https://sta.c64.org/cbm64mem.html

  /// 0             $0             D6510
  /// 6510 On-Chip I/O DATA Direction Register
  ///
  /// Bit 0: Direction of Bit 0 I/O on port at next address.  Default = 1 (output)
  /// Bit 1: Direction of Bit 1 I/O on port at next address.  Default = 1 (output)
  /// Bit 2: Direction of Bit 2 I/O on port at next address.  Default = 1 (output)
  /// Bit 3: Direction of Bit 3 I/O on port at next address.  Default = 1 (output)
  /// Bit 4: Direction of Bit 4 I/O on port at next address.  Default = 0 (input)
  /// Bit 5: Direction of Bit 5 I/O on port at next address.  Default = 1 (output)
  /// Bit 6: Direction of Bit 6 I/O on port at next address.  Not used.
  /// Bit 7: Direction of Bit 7 I/O on port at next address.  Not used.
  self[D6510] = 0xEF

  /// Zero page
  /// Processor port data direction register.
  // self[D6510] = 0x2F // %00101111
  /// Processor port.
  self[R6510] = 0x37 // %00110111

  /// Execution address of routine converting floating point to integer.
  // self[ADRAY1] = 0xAA
  // self[ADRAY1] = 0xB1
  self.write_word(ADRAY1, 0xB1AA)
  /// Execution address of routine converting integer to floating point.
  // self[ADRAY2] = 0x91
  // self[ADRAY2] = 0xB3
  self.write_word(ADRAY2, 0xB391)

  /// Current I/O device number.
  self[CHANNL] = 0x00 // Keyboard for input and screen for output.
  /// Pointer to next expression in string stack.
  /// Values: $19; $1C; $1F; $22.
  self[TEMPPT] = 0x19

  /// Pointer to beginning of BASIC area.
  // self[TXTTAB] = 0x01
  // self[TXTTAB] = 0x08
  self.write_word(TXTTAB, 0x0801)
  /// Pointer to end of BASIC area.
  // self[MEMSIZ] = 0x00
  // self[MEMSIZ] = 0xA0
  self.write_word(MEMSIZ, 0xA000)

  /// Current input device number.
  self[DFLTN] = 0x00 // Keyboard.
  /// Current output device number.
  self[DFLTO] = 0x03 // Screen.

  /// Pointer to datasette buffer.
  // self[TAPE1] = 0x3C
  // self[TAPE1] = 0x03
  self.write_word(TAPE1, 0x033C)

  /// Pointer to beginning of BASIC area after memory test.
  // self[MEMSTR] = 0x00
  // self[MEMSTR] = 0x08
  self.write_word(MEMSTR, 0x0800)
  /// Pointer to end of BASIC area after memory test.
  // self[MEMEND] = 0x00
  // self[MEMEND] = 0xA0
  self.write_word(MEMEND, 0xA000)

  /// High byte of pointer to screen memory for screen input/output.
  self[HIBASE] = 0x04

  /// Execution address of routine that, based on the status of shift keys, sets the pointer at memory address $00F5-$00F6 to the appropriate conversion table for converting keyboard matrix codes to PETSCII codes.
  // self[KEYLOG] = 0x48
  // self[KEYLOG] = 0xEB
  self.write_word(KEYLOG, 0xEB48)

  /// Execution address of warm reset, displaying optional BASIC error message and entering BASIC idle loop.
  // self[IERROR] = 0x8B
  // self[IERROR] = 0xE3
  self.write_word(IERROR, 0xE38B)
  /// Execution address of BASIC idle loop.
  // self[IMAIN] = 0x83
  // self[IMAIN] = 0xA4
  self.write_word(IMAIN, 0xA483)
  /// Execution address of BASIC line tokenizater routine.
  // self[ICRNCH] = 0x7C
  // self[ICRNCH] = 0xA5
  self.write_word(ICRNCH, 0xA57C)
  /// Execution address of BASIC token decoder routine.
  // self[IQPLOP] = 0x1A
  // self[IQPLOP] = 0xA7
  self.write_word(IQPLOP, 0xA71A)
  /// Execution address of BASIC instruction executor routine.
  // self[IGONE] = 0xE4
  // self[IGONE] = 0xA7
  self.write_word(IGONE, 0xA7E4)
  /// Execution address of routine reading next item of BASIC expression.
  // self[IEVAL] = 0x86
  // self[IEVAL] = 0xAE
  self.write_word(IEVAL, 0xAE86)

  /// Execution address of interrupt service routine.
  // self[CINV] = 0x31
  // self[CINV] = 0xEA
  self.write_word(CINV, 0xEA31)
  /// Execution address of BRK service routine.
  // self[CNBINV] = 0x66
  // self[CNBINV] = 0xFE
  self.write_word(CNBINV, 0xFE66)
  /// Execution address of non-maskable interrupt service routine.
  // self[NMINV] = 0x47
  // self[NMINV] = 0xFE
  self.write_word(NMINV, 0xFE47)
  /// Execution address of OPEN, routine opening files.
  // self[IOPEN] = 0x4A
  // self[IOPEN] = 0xF3
  self.write_word(IOPEN, 0xF34A)
  /// Execution address of CLOSE, routine closing files.
  // self[ICLOSE] = 0x91
  // self[ICLOSE] = 0xF2
  self.write_word(ICLOSE, 0xF291)
  /// Execution address of CHKIN, routine defining file as default input.
  // self[ICHKIN] = 0x0E
  // self[ICHKIN] = 0xF2
  self.write_word(ICHKIN, 0xF20E)
  /// Execution address of CHKOUT, routine defining file as default output.
  // self[ICKOUT] = 0x50
  // self[ICKOUT] = 0xF2
  self.write_word(ICKOUT, 0xF250)
  /// Execution address of CLRCHN, routine initializating input/output.
  // self[ICLRCH] = 0x33
  // self[ICLRCH] = 0xF3
  self.write_word(ICLRCH, 0xF333)
  /// Execution address of CHRIN, data input routine, except for keyboard and RS232 input.
  // self[IBASIN] = 0x57
  // self[IBASIN] = 0xF1
  self.write_word(IBASIN, 0xF157)
  /// Execution address of CHROUT, general purpose data output routine.
  // self[IBSOUT] = 0xCA
  // self[IBSOUT] = 0xF1
  self.write_word(IBSOUT, 0xF1CA)
  /// Execution address of STOP, routine checking the status of Stop key indicator, at memory address $0091.
  // self[ISTOP] = 0xED
  // self[ISTOP] = 0xF6
  self.write_word(ISTOP, 0xF6ED)
  /// Execution address of GETIN, general purpose data input routine.
  // self[IGETIN] = 0x3E
  // self[IGETIN] = 0xF1
  self.write_word(IGETIN, 0xF13E)
  /// Execution address of CLALL, routine initializing input/output and clearing all file assignment tables.
  // self[ICLALL] = 0x2F
  // self[ICLALL] = 0xF3
  self.write_word(ICLALL, 0xF32F)
  /// Unused.
  // self[USRCMD] = 0x66
  // self[USRCMD] = 0xFE
  self.write_word(USRCMD, 0xFE66)
  /// Execution address of LOAD, routine loading files.
  // self[ILOAD] = 0xA5
  // self[ILOAD] = 0xF4
  self.write_word(ILOAD, 0xF4A5)
  /// Execution address of SAVE, routine saving files.
  // self[ISAVE] = 0xED
  // self[ISAVE] = 0xF5
  self.write_word(ISAVE, 0xF5ED)

  // /// VIC-II; video display
  // /// Screen control register #1.
  // self[0xD011] = 0x1B // %00011011
  // /// Screen control register #2.
  // self[0xD016] = 0xC8 // %11001000

  /// Hardware vectors
  /// Execution address of non-maskable interrupt service routine.
  self.write_word(NMI, 0xFE43)
  /// Execution address of cold reset.
  self.write_word(RESET, 0xFCE2)
  /// Execution address of interrupt service routine.
  self.write_word(IRQ, 0xFF48)

  //
  println("<< C64::reset")
}

///|
pub fn initCPU(self : C64, pc? : UInt16) -> Unit {
  // println(">> C64::initCPU")

  //
  self.cpu.reset(pc?)
  //
  self.prevNMI = false

  //
  // println("<< C64::initCPU")
}

//C64 Reset
///|
pub fn initC64(self : C64) -> Unit! {
  println(">> C64::initC64")

  //
  self.sid.each(fn(sid) { sid.reset(videoStandard=self.videoStandard) })
  self.cia.each(fn(cia) { cia.reset(videoStandard=self.videoStandard) })
  self.vic.reset!(videoStandard=self.videoStandard)

  // self.mem.reset()

  self.initCPU()
  self.irq = false
  self.nmi = false
  if self.highQuality {
    // FIXME
    // self.sid[0].nonFiltedSample = 0
    // self.sid[0].filterInputSample = 0
    // self.sid[0].prevNonFiltedSample = 0
    // self.sid[0].prevFilterInputSample = 0
  }
  self.sampleCycleCnt = 0
  self.overSampleCycleCnt = 0

  /// 6510 On-Chip I/O DATA Direction Register
  /// 0             $0             D6510
  /// 1             $1             R6510
  ///
  /// Bit 0: LORAM signal.  Selects ROM or RAM at 40960 ($A000).  1=BASIC, 0=RAM
  /// Bit 1: HIRAM signal.  Selects ROM or RAM at 57344 ($E000).  1=Kernal, 0=RAM
  /// Bit 2: CHAREN signal.  Selects character ROM or I/O devices.  1=I/O, 0=ROM
  /// Bit 3: Cassette Data Output line.
  /// Bit 4: Cassette Switch Sense.  Reads 0 if a button is pressed, 1 if not.
  /// Bit 5: Cassette Motor Switch Control.  A 1 turns the motor on, 0 turns it off.
  /// Bits 6-7: Not connected--no function presently defined.

  //initialize bank-reg. (ROM-banks and IO enabled)
  self[R6510] = 0x37

  /// Vector to IRQ Interrupt Routine
  /// 788-789       $314-$315      CINV
  ///
  /// This vector points to the address of the routine that is executed when
  /// an IRQ interrupt occurs (normally 59953 ($FA31)).

  //IRQ
  self.write_word(CINV, 0xEA31)

  /// Vector: Non-Maskable Interrupt
  /// 792-793       $318-$319      NMINV
  ///
  /// This vector points to the address of the routine that will be executed
  /// when a Non-Maskable Interrupt (NMI) occurs (currently at 65095
  /// ($FE47)).

  //NMI
  self.write_word(NMINV, 0xEA81)

  //
  println("<< C64::initC64")
}

///|
pub fn C64::emulate(self : C64) -> Int {
  // println(">> C64::emulate")
  //

  //
  let cpuClock = try {
    self.cpuFrequency.to_int!()
  } catch {
    err => {
      println(err)
      panic()
    }
  }
  let oversamplingRatio = 7
  let oversamplingCycles = cpuClock / defaultSampleRate / oversamplingRatio
  //

  let mut instructionCycles = 0

  //
  //Cycle-based part of emulations:
  //
  while self.sampleCycleCnt <= self.sampleClockRatio {
    //
    if not(self.realSID) {
      if self.frameCycleCnt >= self.frameCycles {
        self.frameCycleCnt -= self.frameCycles
        if self.finished { //some tunes (e.g. Barbarian, A-Maze-Ing) doesn't always finish in 1 frame
          // FIXME: self.initCPU(pc=self.psid.playAddress) //(PSID docs say bank-register should always be set for each call's region)
          self.finished = false
          // if self.timerSource == 0 {
          //   self[0xD019] = 0x81 //always simulate to player-calls that VIC-IRQ happened
          // } else {
          //   self[0xDC0D] = 0x83 //always simulate to player-calls that CIA TIMERA/TIMERB-IRQ happened
          // }
        }
      }
      if not(self.finished) {
        instructionCycles = self.step()
        if self.pc() == 0x0000 {
          instructionCycles = 6
          self.finished = true
        }
      } else {
        instructionCycles = 7 //idle between player-calls
      }
      self.frameCycleCnt += instructionCycles
      // FIXME: self[0xDC04] += instructionCycles //very simple CIA1 TimerA simulation for PSID (e.g. Delta-Mix_E-Load_loader)
      //RealSID emulations:
      // } else if self.interrupts() {
      //   self.finished = false
      //   instructionCycles = 7
    } else if not(self.finished) {
      instructionCycles = self.step()
      if self.pc() == 0x0000 {
        instructionCycles = 6
        self.finished = true
      }
    } else {
      instructionCycles = 7 //idle between IRQ-calls
    }

    //
    self.irq = false //prepare for collecting IRQ sources
    self.nmi = false //prepare for collecting NMI sources
    //
    self.irq = self.cia[0].emulate(instructionCycles) || self.irq
    self.nmi = self.cia[1].emulate(instructionCycles) || self.nmi
    self.irq = self.vic.emulate(instructionCycles) || self.irq
    // println("IRQ:" + self.irq.to_string())

    self.cpu.set_irq(state=self.irq)
    self.cpu.set_nmi(state=self.nmi)

    //
    self.sampleCycleCnt += instructionCycles << 4

    //
    self.sid.each(fn(sid) { sid.emulateADSR(instructionCycles) })
  }
  self.sampleCycleCnt -= self.sampleClockRatio

  //
  let mut hqSampleCount = 0
  if self.highQuality { //oversampled waveform-generation
    hqSampleCount = 0
    self.sid.each(fn(sid) {
      sid.nonFiltedSample = 0
      sid.filterInputSample = 0
    })

    //
    while self.overSampleCycleCnt <= self.sampleClockRatio {
      self.sid.each(fn(sid) {
        let output = sid.emulateHQWaves(oversamplingCycles)
        sid.nonFiltedSample += output.nonFilted
        sid.filterInputSample += output.filterInput
      })
      hqSampleCount += 1
      self.overSampleCycleCnt += oversamplingCycles << 4
    }
    self.overSampleCycleCnt -= self.sampleClockRatio
  }

  //
  //Samplerate-based part of emulations:
  //
  let output = Output::default()
  if not(self.highQuality) {
    if not(self.stereo) || self.sid.length() == 1 {
      self.sid.each(fn(sid) {
        let tmp = sid.emulateWaves(
          self.sampleClockRatio,
          self.attenuation,
          self.realSID,
        )
        output.left = tmp
        output.right = tmp
      })
    } else {
      let mut tmp = 0
      output.left = tmp
      output.right = tmp
      self.sid.each(fn(sid) {
        tmp = sid.emulateWaves(
          self.sampleClockRatio,
          self.attenuation,
          self.realSID,
        )
        match sid.channel {
          Left => output.left += tmp * 2
          Right => output.right += tmp * 2
          _ => {
            output.left += tmp
            output.right += tmp
          }
        }
      })
    }
  } else {
    //SID output-stages and mono/stereo handling for High-Quality SID-emulation
    self.sid.each(fn(sid) {
      sid.nonFiltedSample /= hqSampleCount
      sid.filterInputSample /= hqSampleCount
    })
    if not(self.stereo) || self.sid.length() == 1 {
      let mut tmp = 0
      self.sid.each(fn(sid) {
        tmp += sid.emulateSIDoutputStage(self.attenuation, self.realSID)
      })
      output.left = tmp
      output.right = tmp
    } else {
      let mut tmp = 0
      output.left = tmp
      output.right = tmp
      self.sid.each(fn(sid) {
        tmp = sid.emulateSIDoutputStage(self.attenuation, self.realSID)
        match sid.channel {
          Left => output.left += tmp * 2
          Right => output.right += tmp * 2
          _ => {
            output.left += tmp
            output.right += tmp
          }
        }
      })
    }
  }

  //average level (for VU-meter)
  self.sid.each(fn(sid) { sid.level += ((sid.output >> 4) - sid.level) >> 32 })
  // println(
  //   "<< C64::emulate [" +
  //   output.left.to_string() +
  //   ", " +
  //   output.right.to_string() +
  //   "]",
  // )

  //
  // output

  self.cycles += instructionCycles
  instructionCycles
}

///|
pub fn C64::load(
  self : C64,
  //
  data : Bytes,
  //
  offset~ : Int = 0,
  length~ : Int = data.length(),
  //
  has_load_address~ : Bool = false
) -> UInt16 {
  self.cpu.load(offset, data, length~, has_load_address~)
}

///|
fn C64::step(self : C64) -> Int {
  self.cpu.step()
}

///|
pub fn C64::trap(
  self : C64,
  address : UInt16,
  handler : (@cpu.CPU) -> Unit
) -> Unit {
  self.cpu.trap(address, handler)
}

///|
pub fn C64::pc(self : C64) -> UInt16 {
  self.cpu.pc()
}

///|
pub fn clear_registers(self : C64) -> Unit {
  self.cpu.clear_registers()
}

///|
pub fn get_registers(self : C64) -> @cpu.Registers {
  self.cpu.get_registers()
}

///|
pub fn clear_flags(self : C64) -> Unit {
  self.cpu.clear_flags()
}

///|
pub fn get_flags(self : C64) -> @cpu.Flags {
  self.cpu.get_flags()
}

///|
pub fn C64::set_flags(self : C64, flags : UInt8) -> Unit {
  self.cpu.set_flags(flags)
}

///|
pub fn set_interrupt_flag(self : C64) -> Unit {
  self.cpu.set_interrupt()
}

///|
pub fn setA(self : C64, value : Int) -> Unit {
  self.cpu.register(@cpu.A, value)
}

///|
pub fn C64::push(self : C64, value : UInt8) -> Unit {
  self.cpu.push(value)
}

///|
pub fn C64::push16(self : C64, value : UInt16) -> Unit {
  self.cpu.push16(value)
}

///|
fn interrupts(self : C64) -> Bool {
  // println(
  //   "*** IRQ:" +
  //   self.irq.to_string() +
  //   " I:" +
  //   self.cpu.has_interrupt().to_string(),
  // )
  if self.nmi != self.prevNMI { //if IRQ and NMI at the same time, NMI is serviced first
    self.cpu.nmi() //NMI-vector
    self.prevNMI = self.nmi
    return true
  } else if self.irq && not(self.cpu.has_interrupt()) {
    self.cpu.irq() //maskable IRQ-vector
    self.prevNMI = self.nmi
    return true
  }
  self.prevNMI = self.nmi //prepare for NMI edge-detection
  false
}

// /* memory addresses  */
// static const uint16_t kBaseAddrBasic  = 0xa000;
// static const uint16_t kBaseAddrKernal = 0xe000;
// static const uint16_t kBaseAddrStack  = 0x0100;
// static const uint16_t kBaseAddrScreen = 0x0400;
// static const uint16_t kBaseAddrChars  = 0xd000;
// static const uint16_t kBaseAddrBitmap = 0x0000;
// static const uint16_t kBaseAddrColorRAM = 0xd800;
// static const uint16_t kAddrResetVector = 0xfffc;
// static const uint16_t kAddrIRQVector = 0xfffe;
// static const uint16_t kAddrNMIVector = 0xfffa;
// static const uint16_t kAddrDataDirection = 0x0000;
// static const uint16_t kAddrMemoryLayout  = 0x0001;
// static const uint16_t kAddrColorRAM = 0xd800;
// /* memory layout */
// static const uint16_t kAddrZeroPage     = 0x0000;
// static const uint16_t kAddrVicFirstPage = 0xd000;
// static const uint16_t kAddrVicLastPage  = 0xd300;
// static const uint16_t kAddrCIA1Page = 0xdc00;
// static const uint16_t kAddrCIA2Page = 0xdd00;
// static const uint16_t kAddrBasicFirstPage = 0xa000;
// static const uint16_t kAddrBasicLastPage  = 0xbf00;
// static const uint16_t kAddrKernalFirstPage = 0xe000;
// static const uint16_t kAddrKernalLastPage = 0xff00;

///|
pub fn C64::read(self : C64, address : UInt16, dummy~ : Bool = false) -> UInt8 {
  if self.debug && not(dummy) {
    let register = try {
      " | \{C64register::from_int!(address._)}"
    } catch {
      _ =>
        // println(err)
        ""
    }
    println(
      "\t\t\t\t\t\t\t\t\t\t" +
      "$" +
      address.to_hex() +
      " → #$" +
      self.mem.read(address, dummy=true).to_hex() +
      register,
    )
  }

  //
  if address < C64_MEM_START || address > C64_MEM_END {
    // self.dump()
    println("C64::get out of bounds")
    abort("C64::get out of bounds")
  }

  // VIC-II DMA or Character ROM
  if address >= VIC_MEM_START && address <= VIC_MEM_END {
    match self.bank[BANK_CHARACTERS] {
      ROM => return self.characters[address._ - VIC_MEM_START].to_int()
      RAM => return self.read_direct(address)
      IO => if self.debug {  }
    }
  }
  // BASIC or RAM
  if address >= C64_BASIC_MEM_START && address <= C64_BASIC_MEM_END {
    match self.bank[BANK_BASIC] {
      ROM => return self.basic[address._ - C64_BASIC_MEM_START].to_int()
      RAM => return self.read_direct(address)
      IO => if self.debug {  }
    }
  }
  // KERNAL
  if address >= C64_KERNAL_MEM_START && address <= C64_KERNAL_MEM_END {
    match self.bank[BANK_KERNAL] {
      ROM => return self.kernal[address._ - C64_KERNAL_MEM_START].to_int()
      RAM => return self.read_direct(address)
      IO => if self.debug {  }
    }
  }
  // CHARACTERS
  if address >= C64_CHARACTERS_MEM_START && address <= C64_CHARACTERS_MEM_END {
    match self.bank[BANK_CHARACTERS] {
      ROM =>
        return self.characters[address._ - C64_CHARACTERS_MEM_START].to_int()
      RAM => return self.read_direct(address)
      IO => if self.debug {  }
    }
  }

  // //
  // for i = 0; i < self.mem.hooks.length(); i = i + 1 {
  //   if address >= self.mem.hooks[i].start && address <= self.mem.hooks[i].end {
  //     // println(
  //     //   "MEMORY[\{i}] \{UInt16(self.mem[i].start).to_hex()} - \{UInt16(self.mem[i].end).to_hex()}",
  //     // )
  //     return (self.mem.hooks[i].read)(address, dummy)._
  //   }
  // }

  //
  self.read_direct(address)
}

///|
fn C64::read_direct(self : C64, address : UInt16) -> UInt8 {
  // println("C64::read_direct $" + UInt16(addr).to_hex())
  //

  self.mem.read(address)
}

///|
fn C64::op_get(self : C64, register : C64register) -> UInt8 {
  // println("C64::op_get $" + UInt16(addr).to_hex())
  //

  let address = c64(register)
  //

  self.read(address)
}

///|
pub fn C64::write(
  self : C64,
  //
  address : UInt16,
  value : UInt8,
  //
  dummy~ : Bool = false
) -> Unit {
  if self.debug && not(dummy) {
    let register = try {
      " | \{C64register::from_int!(address._)}"
    } catch {
      _ =>
        // println(err)
        ""
    }
    println(
      "\t\t\t\t\t\t\t\t\t\t" +
      "$" +
      address.to_hex() +
      " ← #$" +
      value.to_hex() +
      register,
    )
  }
  //

  if address < C64_MEM_START || address > C64_MEM_END {
    // self.dump()
    println("C64::set out of bounds")
    abort("C64::set out of bounds")
  }

  //
  if address == 0x0001 {
    // bank switching
    return self.set_bank(IOPort::from_int(value))
  } else if address >= VIC_MEM_START && address <= VIC_MEM_END {
    // VIC-II DMA or Character ROM
    match self.bank[BANK_CHARACTERS] {
      ROM => return self.write_direct(address, value)
      RAM => return self.write_direct(address, value)
      IO => if self.debug {  }
    }
  } else if address >= C64_BASIC_MEM_START && address <= C64_BASIC_MEM_END {
    // BASIC or RAM
    match self.bank[BANK_BASIC] {
      ROM => return self.write_direct(address, value)
      RAM => return self.write_direct(address, value)
      IO => if self.debug {  }
    }
  } else if address >= C64_KERNAL_MEM_START && address <= C64_KERNAL_MEM_END {
    // KERNAL
    match self.bank[BANK_KERNAL] {
      ROM => return self.write_direct(address, value)
      RAM => return self.write_direct(address, value)
      IO => if self.debug {  }
    }
  } else if address >= C64_CHARACTERS_MEM_START &&
    address <= C64_CHARACTERS_MEM_END {
    // CHARACTERS
    match self.bank[BANK_CHARACTERS] {
      ROM => return self.write_direct(address, value)
      RAM => return self.write_direct(address, value)
      IO => if self.debug {  }
    }
  }

  //
  self.write_direct(address, value)
}

///|
fn C64::write_direct(self : C64, address : UInt16, value : UInt8) -> Unit {
  self.mem.write(address, value)
}

///|
pub fn C64::write_word(
  self : C64,
  register : C64register,
  value : UInt16
) -> Unit {
  let address = c64(register)
  match register {
    ADRAY1
    | ADRAY2
    | CINV
    | CNBINV
    | COLD
    | KEYLOG
    | MEMEND
    | MEMSIZ
    | MEMSTR
    | TAPE1
    | IBASIN
    | IBSOUT
    | ICHKIN
    | ICLALL
    | ICLOSE
    | ICLRCH
    | ICKOUT
    | ICRNCH
    | IERROR
    | IEVAL
    | IGETIN
    | IGONE
    | ILOAD
    | IMAIN
    | IOPEN
    | IQPLOP
    | ISAVE
    | ISTOP
    | IRQ
    | NMI
    | NMINV
    | RESET
    | TXTTAB
    | USRCMD
    | WARM
    | PC => {
      self.write(address + 1, u8(value._ >> 8)) // lo
      self.write(address, u8(value._)) // hi
    }
    _ => {
      println("unknown C64 register \{register}")
      panic()
    }
  }
}

///|
pub fn write_array(
  self : C64,
  //
  register : C64register,
  values : Array[UInt8]
) -> Unit {
  let address = c64(register)
  match register {
    CARTROM | READY | GETIN =>
      values.eachi(fn(i, value) { self.write_direct(address + i, value) })
    _ => panic()
  }
}

///|
pub fn C64::op_set(self : C64, register : C64register, value : UInt8) -> Unit {
  // println("C64::op_set $" + address.to_hex() + " = " + value.to_hex())

  let address = c64(register)

  //
  self.write(address, value)
}
