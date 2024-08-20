//0:NTSC, 1:PAL (based on the SID-header field)
enum VideoStandard {
  Unknown
  NTSC
  PAL
  Both
} derive(Show, Eq)

fn VideoStandard::from_int(value : Int) -> VideoStandard! {
  match value {
    0b00 => Unknown
    0b01 => PAL
    0b10 => NTSC
    0b11 => Both
    _ => raise UnknownVideoStandard
  }
}

fn to_int(self : VideoStandard) -> Int! {
  match self {
    NTSC => 0
    PAL => 1
    _ => raise UnknownVideoStandard
  }
}

fn op_get(self : VideoStandard, value : VideoStandard) -> Int! {
  value.to_int!()
}

///

type CPUClock VideoStandard derive(Show, Eq)

fn to_int(self : CPUClock) -> Int! {
  match self.0 {
    Unknown => 0
    NTSC => 1022727
    PAL => 985248
    _ => raise UnknownCPUClock
  }
}

fn op_get(self : CPUClock, value : VideoStandard) -> Int! {
  value.to_int!()
}

fn op_shl(self : CPUClock, bits : Int) -> Int {
  try {
    self.to_int!() << bits
  } catch {
    // Do nothing

  }
}

test "CPUClock::None" {
  let value = CPUClock(Unknown)
  assert_eq!(value, Unknown)
  inspect!(value.to_int!(), content="0")
}

test "CPUClock::NTSC" {
  let value = CPUClock(NTSC)
  assert_eq!(value, NTSC)
  inspect!(value.to_int!(), content="1022727")
}

test "CPUClock::PAL" {
  let value = CPUClock(PAL)
  assert_eq!(value, PAL)
  inspect!(value.to_int!(), content="985248")
}

test "error CPUClock::Both" {
  let value = CPUClock(Both)
  assert_eq!(value, Both)
  inspect!(value.to_int?(), content="Err(unknown CPU clock)")
}

test "CPUClock::NTSC shift left" {
  let value = CPUClock(NTSC)
  assert_eq!(value, NTSC)
  inspect!(value << 4, content="16363632")
}

test "CPUClock::PAL shift left" {
  let value = CPUClock(PAL)
  assert_eq!(value, PAL)
  inspect!(value << 4, content="15763968")
}

///

type ScanLines VideoStandard derive(Show, Eq)

fn to_int(self : ScanLines) -> Int! {
  match self.0 {
    NTSC => 263
    PAL => 312
    _ => raise UnknownScanLines
  }
}

fn op_get(self : ScanLines, value : VideoStandard) -> Int! {
  value.to_int!()
}

test "error ScanLines::None" {
  let value = ScanLines(Unknown)
  assert_eq!(value, Unknown)
  inspect!(value.to_int?(), content="Err(unknown scan lines)")
}

test "ScanLines::NTSC" {
  let value = ScanLines(NTSC)
  assert_eq!(value, NTSC)
  inspect!(value.to_int!(), content="263")
}

test "ScanLines::PAL" {
  let value = ScanLines(PAL)
  assert_eq!(value, PAL)
  inspect!(value.to_int!(), content="312")
}

test "error ScanLines::Both" {
  let value = ScanLines(Both)
  assert_eq!(value, Both)
  inspect!(value.to_int?(), content="Err(unknown scan lines)")
}

///

type ScanLineCycles VideoStandard derive(Show, Eq)

fn to_int(self : ScanLineCycles) -> Int! {
  match self.0 {
    NTSC => 65
    PAL => 63
    _ => raise UnknownScanLineCycles
  }
}

fn op_get(self : ScanLineCycles, value : VideoStandard) -> Int! {
  value.to_int!()
}

test "error ScanLineCycles::None" {
  let value = ScanLineCycles(Unknown)
  assert_eq!(value, Unknown)
  inspect!(value.to_int?(), content="Err(unknown scan line cycles)")
}

test "ScanLineCycles::NTSC" {
  let value = ScanLineCycles(NTSC)
  assert_eq!(value, NTSC)
  inspect!(value.to_int!(), content="65")
}

test "ScanLineCycles::PAL" {
  let value = ScanLineCycles(PAL)
  assert_eq!(value, PAL)
  inspect!(value.to_int!(), content="63")
}

test "error ScanLineCycles::Both" {
  let value = ScanLineCycles(Both)
  assert_eq!(value, Both)
  inspect!(value.to_int?(), content="Err(unknown scan line cycles)")
}

///

type FrameRate VideoStandard derive(Show, Eq)

fn to_int(self : FrameRate) -> Int! {
  match self.0 {
    NTSC => 60
    PAL => 50
    _ => raise UnknownFrameRate
  }
}

fn op_get(self : FrameRate, value : VideoStandard) -> Int! {
  value.to_int!()
}

test "error FrameRate::None" {
  let value = FrameRate(Unknown)
  assert_eq!(value, Unknown)
  inspect!(value.to_int?(), content="Err(unknown frame rate)")
}

test "FrameRate::NTSC" {
  let value = FrameRate(NTSC)
  assert_eq!(value, NTSC)
  inspect!(value.to_int!(), content="60")
}

test "FrameRate::PAL" {
  let value = FrameRate(PAL)
  assert_eq!(value, PAL)
  inspect!(value.to_int!(), content="50")
}

test "error FrameRate::Both" {
  let value = FrameRate(Both)
  assert_eq!(value, Both)
  inspect!(value.to_int?(), content="Err(unknown frame rate)")
}
