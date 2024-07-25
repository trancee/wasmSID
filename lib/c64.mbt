// https://www.zimmers.net/cbmpics/cbm/c64/

pub struct C64 {
  baseaddress : UInt16
  mem : @cpu.Memory
  //
  cpu : @cpu.CPU
  sid : Array[SID]
  cia : Array[CIA]
  vic : VIC
  //
  psid : PSID
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
  mut irq : Int //collected IRQ line from devices
  mut nmi : Int //collected NMI line from devices
  //
  mut prevNMI : Int //used for NMI leading edge detection
}

let default_samplerate = 44100

pub fn C64::new(
  ~baseaddress : Int = 0x0000,
  ~mem : @cpu.Memory? = None,
  ~data : Array[Int] = [],
  ~offset : Int = 0x0000,
  ~length : Int = data.length(),
  ~sampleRate : Int = default_samplerate,
  ~psid : PSID
) -> C64 {
  let cpu = @cpu.CPU::new(pc=baseaddress, ~mem)
  cpu.load(offset, data, ~length)
  let mem = cpu.mem()
  mem.setROM()
  //default C64 setup with only 1 SID and 2 CIAs and 1 VIC
  let sid = [SID::new(mem, 0xD400)]
  let cia = [CIA::new(mem, 0xDC00), CIA::new(mem, 0xDD00)]
  let vic = VIC::new(mem, 0xD000)
  //
  let c64 : C64 = {
    baseaddress,
    mem,
    //
    cpu,
    sid,
    cia,
    vic,
    //
    psid,
    //
    sampleRate,
    highQuality: false,
    stereo: false,
    playbackSpeed: 0,
    paused: false,
    //
    videoStandard: Unknown,
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
    irq: 0,
    nmi: 0,
    //
    prevNMI: 0,
  }
  c64.initC64()
  c64
}

//set hardware-parameters (Models, SIDs) for playback of loaded SID-tune
pub fn reset(self : C64) -> Unit!String {
  println(">> C64::reset")

  //
  self.videoStandard = self.psid.flags.videoStandard
  if self.sampleRate == 0 {
    self.sampleRate = 44100
  }
  self.cpuFrequency = CPUClock(self.videoStandard)
  self.sampleClockRatio = (self.cpuFrequency << 4)! / self.sampleRate //shifting (multiplication) enhances SampleClockRatio precision
  //
  self.vic.rasterLines = ScanLines(self.videoStandard).to_int!() // HINT: should be inferred
  self.vic.rasterRowCycles = ScanLineCycles(self.videoStandard).to_int!() // HINT: should be inferred
  self.frameCycles = self.vic.rasterLines * self.vic.rasterRowCycles ///C64->SampleRate / PAL_FRAMERATE; //1x speed tune with VIC Vertical-blank timing
  //
  self.prevRasterLine = -1 //so if $d012 is set once only don't disturb FrameCycleCnt
  //
  let model = self.psid.flags.model[0]
  self.sid[0].model = if self.selectedModel != Unknown {
    self.selectedModel
  } else {
    model
  }

  //
  self.sid[0].channel = Channel::Left

  // SID #2
  let mut model = self.psid.flags.model[1]
  if model == Unknown {
    model = self.sid[0].model
  }
  if self.selectedModel != Unknown {
    model = self.selectedModel
  }
  self.sid[1] = SID::new(
    self.mem,
    0xD000 + (self.psid.sid2Address << 4).0,
    ~model,
    channel=Channel::Right,
  )

  // SID #3
  let mut model = self.psid.flags.model[2]
  if model == Unknown {
    model = self.sid[0].model
  }
  if self.selectedModel != Unknown {
    model = self.selectedModel
  }
  self.sid[2] = SID::new(
    self.mem,
    0xD000 + (self.psid.sid3Address << 4).0,
    ~model,
    channel=Channel::Both,
  )

  //
  if self.sid.length() == 1 {
    self.sid[0].channel = Channel::Both
  }
  self.attenuation = match self.sid.length() {
    0 => 0
    1 => 26
    2 => 43 //increase for 2SID (to 43)
    3 => 137 //increase for 3SID (to 137)
    4 => 200 //increase for 4SID (to 200)
    _ => {
      raise "unsupported number of SIDs"
    }
  }

  //
  println("<< C64::reset")
}

pub fn initCPU(self : C64, ~baseaddress : Int? = None) -> Unit {
  // println(">> C64::initCPU")

  //
  self.cpu.reset(~baseaddress)
  //
  self.prevNMI = 0

  //
  // println("<< C64::initCPU")
}

//C64 Reset
pub fn initC64(self : C64) -> Unit {
  // println(">> C64::initC64")

  //
  self.sid.each(fn(sid) { sid.reset() })
  self.cia.each(fn(cia) { cia.reset() })
  // self.mem.reset()
  self.initCPU()
  self.irq = 0
  self.nmi = 0
  if self.highQuality {
    // FIXME
    // self.sid[0].nonFiltedSample = 0
    // self.sid[0].filterInputSample = 0
    // self.sid[0].prevNonFiltedSample = 0
    // self.sid[0].prevFilterInputSample = 0
  }
  self.sampleCycleCnt = 0
  self.overSampleCycleCnt = 0

  //
  // println("<< C64::initC64")
}

pub fn emulate(self : C64) -> (Int, Int) {
  let mut instructionCycles = 0
  //
  //Cycle-based part of emulations:
  //
  while self.sampleCycleCnt <= self.sampleClockRatio {
    if self.psid.realSID.not() {
      if self.frameCycleCnt >= self.frameCycles {
        self.frameCycleCnt -= self.frameCycles
        if self.finished { //some tunes (e.g. Barbarian, A-Maze-Ing) doesn't always finish in 1 frame
          self.initCPU(baseaddress=Some(self.psid.playAddress.0)) //(PSID docs say bank-register should always be set for each call's region)
          self.finished = false
          // FIXME
          // if self.timerSource == 0 {
          //   self[0xD019] = 0x81 //always simulate to player-calls that VIC-IRQ happened
          // } else {
          //   self[0xDC0D] = 0x83 //always simulate to player-calls that CIA TIMERA/TIMERB-IRQ happened
          // }
        }
      }
      if self.finished.not() {
        instructionCycles = self.cpu.step()
        if instructionCycles >= 0xFE {
          instructionCycles = 6
          self.finished = true
        }
      } else {
        instructionCycles = 7 //idle between player-calls
      }
      self.frameCycleCnt += instructionCycles
      // FIXME
      // self[0xDC04] += instructionCycles //very simple CIA1 TimerA simulation for PSID (e.g. Delta-Mix_E-Load_loader)

    } else { //RealSID emulations:
      if self.interrupts() {
        self.finished = false
        instructionCycles = 7
      } else if self.finished.not() {
        instructionCycles = self.cpu.step()
        if instructionCycles >= 0xFE {
          instructionCycles = 6
          self.finished = true
        }
      } else {
        instructionCycles = 7 //idle between IRQ-calls
      }
      self.irq = 0 //prepare for collecting IRQ sources
      self.nmi = 0 //prepare for collecting NMI sources
      self.irq += if self.cia[0].emulate(instructionCycles) { 1 } else { 0 }
      self.nmi += if self.cia[1].emulate(instructionCycles) { 1 } else { 0 }
      self.irq += if self.vic.emulate(instructionCycles) { 1 } else { 0 }
    }
    self.sampleCycleCnt += instructionCycles << 4
    // self.sid.emulateADSRs(instructionCycles)
    // if ( C64->SID[2].BaseAddress != 0 ) cRSID_emulateADSRs (&C64->SID[2], InstructionCycles);
    // if ( C64->SID[3].BaseAddress != 0 ) cRSID_emulateADSRs (&C64->SID[3], InstructionCycles);
    // if ( C64->SID[4].BaseAddress != 0 ) cRSID_emulateADSRs (&C64->SID[4], InstructionCycles);
  }
  self.sampleCycleCnt -= self.sampleClockRatio
  //
  //Samplerate-based part of emulations:
  //
  (0, 0)
}

pub fn load(
  self : C64,
  data : Array[Int],
  ~offset : Int = 0,
  ~length : Int = data.length()
) -> Unit {
  self.cpu.load(offset, data, ~length)
}

pub fn step(self : C64) -> Int {
  self.cpu.step()
}

pub fn pc(self : C64) -> Int {
  self.cpu.pc()
}

pub fn get_flags(self : C64) -> @cpu.UInt8 {
  self.cpu.get_flags()
}

pub fn set_flags(self : C64, flags : @cpu.UInt8) -> Unit {
  self.cpu.set_flags(flags)
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
  if self.nmi > self.prevNMI { //if IRQ and NMI at the same time, NMI is serviced first
    self.cpu.nmi() //NMI-vector
    self.prevNMI = self.nmi
    return true
  } else if self.irq != 0 && self.cpu.has_interrupt().not() {
    self.cpu.irq() //maskable IRQ-vector
    self.prevNMI = self.nmi
    return true
  }
  self.prevNMI = self.nmi //prepare for NMI edge-detection
  false
}

// pub fn op_get(self : C64, addr : Int) -> UInt8 {
//   self.cpu.read(addr)
// }

// pub fn op_set(self : C64, addr : Int, value : Int) -> Unit {
//   self.cpu.write(addr, value)
// }
