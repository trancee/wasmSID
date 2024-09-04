// https://www.zimmers.net/cbmpics/cbm/c64/

let c64_mem_start = 0x0000

let c64_mem_end = 0xFFFF

let c64_mem_size = 0xFFFF

let c64_basic_mem_start = 0xA000

let c64_basic_mem_end = 0xDFFF

let c64_basic_mem_size = 0x2000

let c64_kernal_mem_start = 0xE000

let c64_kernal_mem_end = 0xFFFF

let c64_kernal_mem_size = 0x2000

let c64_characters_mem_start = 0xD000

let c64_characters_mem_end = 0xDFFF

let c64_characters_mem_size = 0x1000

struct Hook {
  start : Int
  end : Int
  // mem : FixedArray[Int]
  read : (UInt16, Bool) -> UInt8
  write : (UInt16, UInt8, Bool) -> Unit
}

fn Hook::new(
  start : Int,
  end : Int,
  // mem : FixedArray[Int],
  read : (UInt16, Bool) -> UInt8,
  write : (UInt16, UInt8, Bool) -> Unit
) -> Hook {
  { start, end, read, write }
}

let memory : Array[Hook] = []

pub struct C64 {
  baseaddress : UInt16
  mem : @cpu.Memory
  //
  bank : FixedArray[Bank]
  // memory : Array[Hook]
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
  mut highQuality : Bool
  mut stereo : Bool
  mut playbackSpeed : Int
  mut paused : Bool
  //
  // C64-machine related:
  //
  mut videoStandard : VideoStandard
  mut cpuFrequency : CPUClock
  mut sampleClockRatio : Int //ratio of CPU-clock and samplerate
  mut selectedModel : Model
  mut mainVolume : Double
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
  mut returned : Bool
  //
  mut irq : Bool //collected IRQ line from devices
  mut nmi : Bool //collected NMI line from devices
  //
  mut prevNMI : Bool //used for NMI leading edge detection
  //
  mut debug : Bool
}

let defaultSampleRate = 44100

pub fn C64::new(
  ~baseaddress : Int = 0x0000,
  ~mem? : @cpu.Memory,
  ~data : FixedArray[Int] = [],
  ~addr : Int = 0x0000,
  ~length : Int = data.length(),
  ~sampleRate : Int = defaultSampleRate,
  ~model : FixedArray[Model] = [MOS6581],
  ~videoStandard : VideoStandard = VideoStandard::PAL,
  ~realSID : Bool = false,
  ~debug : Bool = false
) -> C64 {
  let cpu = @cpu.CPU::new(
    pc=baseaddress,
    mem=mem.or(@cpu.Memory::new()),
    ~debug,
  )
  let _ = cpu.load(addr, data, ~length)

  //
  let mem = cpu.mem()
  // mem.set_read(
  //   fn(address : Int, dummy : Bool) -> Int { mem.read_direct(address)._ },
  // )
  // mem.set_write(
  //   fn(address : Int, value : Int, dummy : Bool) -> Unit {
  //     mem.write_direct(address, value)
  //   },
  // )
  // mem.setROM()

  // BASIC
  memory.push(
    Hook::new(
      c64_basic_mem_start,
      c64_basic_mem_start + c64_basic_mem_size,
      // c64_basic,
      fn(address : UInt16, dummy : Bool) {
        /// 6510 On-Chip I/O Port Register
        let port = mem.read(0x0001, dummy=true)

        /// Bit 0.  This bit controls the LORAM signal.  A 0 in this bit position
        /// switches the BASIC ROM out, and replaces it with RAM at addresses
        /// 40960-49151 ($A000-$BFFF).  The default value of this bit is 1.
        if port.bit(0) {
          c64_basic[address._ - c64_basic_mem_start]
        } else {
          mem.read_direct(address._)._
        }
      },
      fn(address : UInt16, value : UInt8, dummy : Bool) {
        /// 6510 On-Chip I/O Data Direction Register
        let ddr = mem.read(0x0000, dummy=true)
        /// 6510 On-Chip I/O Port Register
        let port = mem.read(0x0001, dummy=true)

        /// Bit 0.  This bit controls the LORAM signal.  A 0 in this bit position
        /// switches the BASIC ROM out, and replaces it with RAM at addresses
        /// 40960-49151 ($A000-$BFFF).  The default value of this bit is 1.
        if port.bit(0) {

        } else {
          mem.write_direct(address._, value._)
        }
      },
    ),
  )

  // KERNAL
  memory.push(
    Hook::new(
      c64_kernal_mem_start,
      c64_kernal_mem_start + c64_kernal_mem_size,
      // c64_kernal,
      fn(address : UInt16, dummy : Bool) {
        /// 6510 On-Chip I/O Port Register
        let port = mem.read(0x0001, dummy=true)

        /// Bit 1.  Bit 1 controls the HIRAM signal.  A 0 in this bit position
        /// switches the Kernal ROM out, and replaces it with RAM at 57344-65535
        /// ($E000-$FFFF).  As the BASIC interpreter uses the Kernal, it is also
        /// switched out and replaced by RAM.  The default value of this bit is 1.
        if port.bit(1) {
          c64_kernal[address._ - c64_kernal_mem_start]
        } else {
          mem.read_direct(address._)._
        }
      },
      fn(address : UInt16, value : UInt8, dummy : Bool) {
        mem.write_direct(address._, value._)
      },
    ),
  )

  // CHARACTERS
  memory.push(
    Hook::new(
      c64_characters_mem_start,
      c64_characters_mem_start + c64_characters_mem_size,
      // c64_characters,
      fn(address : UInt16, dummy : Bool) {
        /// 6510 On-Chip I/O Port Register
        let port = mem.read(0x0001, dummy=true)

        /// Bit 2.  This bit controls the CHAREN signal.  A 0 in this position
        /// switches the character generator ROM in, so that it can be read by the
        /// 6510 at addresses 53248-57343 ($D000-$DFFF).  Normally, this bit is
        /// set to 1, so that while the VIC-II chip has access to the character
        /// generator ROM for purposes of creating the screen display, the user
        /// cannot PEEK into it.  Since this ROM is switched into the system in
        /// the same location as the I/O devices (SID chip, VIC-II chip, and 6526
        /// CIA's), o I/O can occur when this ROM is switched in.
        if port.bit(2) {
          c64_characters[address._ - c64_characters_mem_start]
        } else {
          mem.read_direct(address._)._
        }
      },
      fn(address : UInt16, value : UInt8, dummy : Bool) {
        mem.write_direct(address._, value._)
      },
    ),
  )

  //default C64 setup with only 1 SID and 2 CIAs and 1 VIC
  let sid = [SID::new(sid1_mem_start, ~videoStandard, ~debug)]
  let cia = [
    CIA::new(cia1_mem_start, ~videoStandard, ~debug),
    CIA::new(cia2_mem_start, ~videoStandard, ~debug),
  ]
  let vic = VIC::new(vic_mem_start, ~videoStandard, ~debug)
  //

  let c64 : C64 = {
    baseaddress,
    mem,
    //
    bank: FixedArray::make(8, Bank::RAM),
    // memory: hooks,
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
    debug,
  }

  // c64.initC64()

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

fn set_bank(self : C64, port : IOPort) -> Unit {
  if port.hiram {
    self.bank[bank_kernal] = ROM
  }
  if port.loram && port.hiram {
    self.bank[bank_basic] = ROM
  }
  if port.charen && (port.loram || port.hiram) {
    self.bank[bank_characters] = IO
  } else if port.charen && not(port.loram) && not(port.hiram) {
    self.bank[bank_characters] = RAM
  } else {
    self.bank[bank_characters] = ROM
  }
}

//set hardware-parameters (Models, SIDs) for playback of loaded SID-tune
pub fn reset(self : C64) -> Unit! {
  println(">> C64::reset")

  //
  if self.sampleRate == 0 {
    self.sampleRate = 44100
  }
  self.cpuFrequency = CPUClock(self.videoStandard)
  self.sampleClockRatio = (self.cpuFrequency << 4) / self.sampleRate //shifting (multiplication) enhances SampleClockRatio precision
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
  self[0x0000] = 0xEF

  /// Zero page
  /// Processor port data direction register.
  self[0x0000] = 0x2F // %00101111
  /// Processor port.
  self[0x0001] = 0x37 // %00110111

  /// Execution address of routine converting floating point to integer.
  self[0x0003] = 0xAA
  self[0x0004] = 0xB1
  /// Execution address of routine converting integer to floating point.
  self[0x0005] = 0x91
  self[0x0006] = 0xB3

  /// Current I/O device number.
  self[0x0013] = 0x00 // Keyboard for input and screen for output.
  /// Pointer to next expression in string stack.
  /// Values: $19; $1C; $1F; $22.
  self[0x0016] = 0x19

  /// Pointer to beginning of BASIC area.
  self[0x002B] = 0x01
  self[0x002C] = 0x08
  /// Pointer to end of BASIC area.
  self[0x0037] = 0x00
  self[0x0038] = 0xA0

  /// Current input device number.
  self[0x0099] = 0x00 // Keyboard.
  /// Current output device number.
  self[0x009A] = 0x03 // Screen.

  /// Pointer to datasette buffer.
  self[0x00B2] = 0x3C
  self[0x00B3] = 0x03

  /// Pointer to beginning of BASIC area after memory test.
  self[0x0281] = 0x00
  self[0x0282] = 0x08
  /// Pointer to end of BASIC area after memory test.
  self[0x0283] = 0x00
  self[0x0284] = 0xA0

  /// High byte of pointer to screen memory for screen input/output.
  self[0x0288] = 0x04

  /// Execution address of routine that, based on the status of shift keys, sets the pointer at memory address $00F5-$00F6 to the appropriate conversion table for converting keyboard matrix codes to PETSCII codes.
  self[0x028F] = 0x48
  self[0x0290] = 0xEB

  /// Execution address of warm reset, displaying optional BASIC error message and entering BASIC idle loop.
  self[0x0300] = 0x8B
  self[0x0301] = 0xE3
  /// Execution address of BASIC idle loop.
  self[0x0302] = 0x83
  self[0x0303] = 0xA4
  /// Execution address of BASIC line tokenizater routine.
  self[0x0304] = 0x7C
  self[0x0305] = 0xA5
  /// Execution address of BASIC token decoder routine.
  self[0x0306] = 0x1A
  self[0x0307] = 0xA7
  /// Execution address of BASIC instruction executor routine.
  self[0x0308] = 0xE4
  self[0x0309] = 0xA7
  /// Execution address of routine reading next item of BASIC expression.
  self[0x030A] = 0x86
  self[0x030B] = 0xAE

  /// Execution address of interrupt service routine.
  self[0x0314] = 0x31
  self[0x0315] = 0xEA
  /// Execution address of BRK service routine.
  self[0x0316] = 0x66
  self[0x0317] = 0xFE
  /// Execution address of non-maskable interrupt service routine.
  self[0x0318] = 0x47
  self[0x0319] = 0xFE
  /// Execution address of OPEN, routine opening files.
  self[0x031A] = 0x4A
  self[0x031B] = 0xF3
  /// Execution address of CLOSE, routine closing files.
  self[0x031C] = 0x91
  self[0x031D] = 0xF2
  /// Execution address of CHKIN, routine defining file as default input.
  self[0x031E] = 0x0E
  self[0x031F] = 0xF2
  /// Execution address of CHKOUT, routine defining file as default output.
  self[0x0320] = 0x50
  self[0x0321] = 0xF2
  /// Execution address of CLRCHN, routine initializating input/output.
  self[0x0322] = 0x33
  self[0x0323] = 0xF3
  /// Execution address of CHRIN, data input routine, except for keyboard and RS232 input.
  self[0x0324] = 0x57
  self[0x0325] = 0xF1
  /// Execution address of CHROUT, general purpose data output routine.
  self[0x0326] = 0xCA
  self[0x0327] = 0xF1
  /// Execution address of STOP, routine checking the status of Stop key indicator, at memory address $0091.
  self[0x0328] = 0xED
  self[0x0329] = 0xF6
  /// Execution address of GETIN, general purpose data input routine.
  self[0x032A] = 0x3E
  self[0x032B] = 0xF1
  /// Execution address of CLALL, routine initializing input/output and clearing all file assignment tables.
  self[0x032C] = 0x2F
  self[0x032D] = 0xF3
  /// Unused.
  self[0x032E] = 0x66
  self[0x032F] = 0xFE
  /// Execution address of LOAD, routine loading files.
  self[0x0330] = 0xA5
  self[0x0331] = 0xF4
  /// Execution address of SAVE, routine saving files.
  self[0x0332] = 0xED
  self[0x0333] = 0xF5

  /// VIC-II; video display
  /// Screen control register #1.
  self[0xD011] = 0x1B // %00011011
  /// Screen control register #2.
  self[0xD016] = 0xC8 // %11001000

  /// Hardware vectors
  /// Execution address of non-maskable interrupt service routine.
  self.cpu.setNMI(0xFE43)
  /// Execution address of cold reset.
  self.cpu.setRESET(0xFCE2)
  /// Execution address of interrupt service routine.
  self.cpu.setIRQ(0xFF48)

  //
  println("<< C64::reset")
}

pub fn initCPU(self : C64, ~baseaddress? : Int) -> Unit {
  // println(">> C64::initCPU")

  //
  self.cpu.reset(~baseaddress?)
  //
  self.prevNMI = false

  //
  // println("<< C64::initCPU")
}

//C64 Reset
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
  self[0x0001] = 0x37

  /// Vector to IRQ Interrupt Routine
  /// 788-789       $314-$315      CINV
  ///
  /// This vector points to the address of the routine that is executed when
  /// an IRQ interrupt occurs (normally 59953 ($FA31)).

  //IRQ
  self[0x0314] = 0x31
  self[0x0315] = 0xEA

  /// Vector: Non-Maskable Interrupt
  /// 792-793       $318-$319      NMINV
  ///
  /// This vector points to the address of the routine that will be executed
  /// when a Non-Maskable Interrupt (NMI) occurs (currently at 65095
  /// ($FE47)).

  //NMI
  self[0x0318] = 0x81
  self[0x0319] = 0xEA

  //
  println("<< C64::initC64")
}

pub fn emulate(self : C64) -> Output {
  // println(">> C64::emulate")
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
          // FIXME: self.initCPU(baseaddress=self.psid.playAddress) //(PSID docs say bank-register should always be set for each call's region)
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
    self.sid.each(
      fn(sid) {
        sid.nonFiltedSample = 0
        sid.filterInputSample = 0
      },
    )

    //
    while self.overSampleCycleCnt <= self.sampleClockRatio {
      self.sid.each(
        fn(sid) {
          let output = sid.emulateHQWaves(oversamplingCycles)
          sid.nonFiltedSample += output.nonFilted
          sid.filterInputSample += output.filterInput
        },
      )
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
      self.sid.each(
        fn(sid) {
          let tmp = sid.emulateWaves(
            self.sampleClockRatio,
            self.attenuation,
            self.realSID,
          )
          output.left = tmp
          output.right = tmp
        },
      )
    } else {
      let mut tmp = 0
      output.left = tmp
      output.right = tmp
      self.sid.each(
        fn(sid) {
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
        },
      )
    }
  } else {
    //SID output-stages and mono/stereo handling for High-Quality SID-emulation
    self.sid.each(
      fn(sid) {
        sid.nonFiltedSample /= hqSampleCount
        sid.filterInputSample /= hqSampleCount
      },
    )
    if not(self.stereo) || self.sid.length() == 1 {
      let mut tmp = 0
      self.sid.each(
        fn(sid) {
          tmp += sid.emulateSIDoutputStage(self.attenuation, self.realSID)
        },
      )
      output.left = tmp
      output.right = tmp
    } else {
      let mut tmp = 0
      output.left = tmp
      output.right = tmp
      self.sid.each(
        fn(sid) {
          tmp = sid.emulateSIDoutputStage(self.attenuation, self.realSID)
          match sid.channel {
            Left => output.left += tmp * 2
            Right => output.right += tmp * 2
            _ => {
              output.left += tmp
              output.right += tmp
            }
          }
        },
      )
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
  output
}

pub fn load(
  self : C64,
  data : FixedArray[Int],
  ~offset : Int = 0,
  ~length : Int = data.length(),
  ~has_load_address : Bool = false
) -> Int {
  self.cpu.load(offset, data, ~length, ~has_load_address)
}

fn step(self : C64) -> Int {
  self.cpu.step()
}

pub fn hook(self : C64, address : Int, hook : (Int) -> Unit) -> Unit {
  self.cpu.hook(address, hook)
}

pub fn pc(self : C64) -> Int {
  self.cpu.pc()
}

pub fn clear_registers(self : C64) -> Unit {
  self.cpu.clear_registers()
}

pub fn get_registers(self : C64) -> @cpu.Registers {
  self.cpu.get_registers()
}

pub fn clear_flags(self : C64) -> Unit {
  self.cpu.clear_flags()
}

pub fn get_flags(self : C64) -> @cpu.Flags {
  self.cpu.get_flags()
}

pub fn set_flags(self : C64, flags : @cpu.UInt8) -> Unit {
  self.cpu.set_flags(flags)
}

pub fn set_interrupt_flag(self : C64) -> Unit {
  self.cpu.set_interrupt()
}

pub fn setA(self : C64, value : Int) -> Unit {
  self.cpu.register(@cpu.A, value)
}

pub fn push(self : C64, value : @cpu.UInt8) -> Unit {
  self.cpu.push(value)
}

pub fn push16(self : C64, value : @cpu.UInt16) -> Unit {
  self.cpu.push16(value)
}

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

pub fn read(self : C64, address : UInt16, ~dummy : Bool = false) -> UInt8 {
  if self.debug {
    println(
      "C64 $" +
      address.to_hex() +
      " → $" +
      self.mem.read(address._, dummy=true).to_hex(),
    )
  }

  //
  if address < c64_mem_start || address > c64_mem_end {
    // self.dump()
    println("C64::get out of bounds")
    abort("C64::get out of bounds")
  }

  //
  for i = 0; i < memory.length(); i = i + 1 {
    println("MEMORY[\{i}] \{memory[i].start}")
    if address >= memory[i].start && address <= memory[i].end {
      return (memory[i].read)(address, dummy)
    }
  }

  // VIC-II DMA or Character ROM
  if address >= vic_mem_start && address <= vic_mem_end {
    match self.bank[bank_characters] {
      ROM => return c64_characters[address._ - vic_mem_start]
      RAM => return self.mem.read_direct(address._)._
    }
  }
  // BASIC or RAM
  if address >= c64_basic_mem_start && address <= c64_basic_mem_end {
    match self.bank[bank_basic] {
      ROM => return c64_basic[address._ - c64_basic_mem_start]
      RAM => return self.mem.read_direct(address._)._
    }
  }

  //
  self.read_direct(address)
}

pub fn read_direct(self : C64, address : UInt16) -> UInt8 {
  // println("C64::read_direct $" + UInt16(addr).to_hex())
  //

  self.mem.read(address._)._
}

fn op_get(self : C64, address : UInt16) -> UInt8 {
  // println("C64::op_get $" + UInt16(addr).to_hex())
  //

  self.read(address)
}

pub fn write(
  self : C64,
  address : UInt16,
  value : UInt8,
  ~dummy : Bool = false
) -> Unit {
  if self.debug {
    println("C64 $" + address.to_hex() + " ← #$" + value.to_hex())
  }
  //

  if address < c64_mem_start || address > c64_mem_end {
    // self.dump()
    println("C64::set out of bounds")
    abort("C64::set out of bounds")
  }

  //
  let page = (address & 0xFF00) >> 8
  if page == 0x00 {
    // Zero Page
    if address == 0x0001 {
      // bank switching
      return self.set_bank(IOPort::from_int(value))
    }
  } else if page >= 0xD0 && page <= 0xD3 {
    // VIC-II DMA or Character ROM
    if self.bank[bank_characters] != IO {
      return self.mem.write_direct(address._, value._)
    }
  } else if page == 0xDC {
    // CIA1
    if self.bank[bank_characters] != IO {
      return self.mem.write_direct(address._, value._)
    }
  } else if page == 0xDD {
    // CIA2
    if self.bank[bank_characters] != IO {
      return self.mem.write_direct(address._, value._)
    }
  }

  //
  self.write_direct(address, value)
}

pub fn write_direct(self : C64, address : UInt16, value : UInt8) -> Unit {
  self.mem.write(address._, value._)
}

pub fn op_set(self : C64, address : UInt16, value : UInt8) -> Unit {
  // println("C64::op_set $" + address.to_hex() + " = " + value.to_hex())

  //
  self.write(address, value)
}
