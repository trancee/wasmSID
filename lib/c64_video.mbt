//0:NTSC, 1:PAL (based on the SID-header field)

///|
enum VideoStandard {
  Unknown
  NTSC
  PAL
  Both
} derive(Show, Eq)

///|
test "VideoStandard/basic_values" {
  // Test that all enum variants can be created and are distinct
  let unknown = VideoStandard::Unknown
  let ntsc = VideoStandard::NTSC
  let pal = VideoStandard::PAL
  let both = VideoStandard::Both

  // Test Show trait implementation
  inspect(unknown, content="Unknown")
  inspect(ntsc, content="NTSC")
  inspect(pal, content="PAL")
  inspect(both, content="Both")
}

///|
test "VideoStandard/pattern_matching" {
  // Test that all variants can be properly matched
  fn classify_standard(standard : VideoStandard) -> String {
    match standard {
      Unknown => "unspecified"
      NTSC => "american"
      PAL => "european"
      Both => "compatible"
    }
  }

  inspect(classify_standard(VideoStandard::Unknown), content="unspecified")
  inspect(classify_standard(VideoStandard::NTSC), content="american")
  inspect(classify_standard(VideoStandard::PAL), content="european")
  inspect(classify_standard(VideoStandard::Both), content="compatible")
}

///|
fn VideoStandard::from_int(value : Int) -> VideoStandard raise {
  match value {
    0b00 => Unknown
    0b01 => PAL
    0b10 => NTSC
    0b11 => Both
    _ => raise UnknownVideoStandard
  }
}

///|
fn VideoStandard::to_int(self : VideoStandard) -> Int raise {
  match self {
    NTSC => 0
    PAL => 1
    _ => raise UnknownVideoStandard
  }
}

///|
fn VideoStandard::op_get(_ : VideoStandard, value : VideoStandard) -> Int raise {
  value.to_int()
}

///|
test "VideoStandard::op_get/valid_standards" {
  let dummy = VideoStandard::Unknown // The first parameter doesn't matter
  inspect(dummy.op_get(NTSC), content="0")
  inspect(dummy.op_get(PAL), content="1")
}

///|
test "panic VideoStandard::op_get/unknown_standard" {
  let dummy = VideoStandard::Unknown
  ignore(dummy.op_get(Unknown))
}

///|
test "panic VideoStandard::op_get/both_standard" {
  let dummy = VideoStandard::Unknown
  ignore(dummy.op_get(Both))
}

///|
struct CPUClock(VideoStandard) derive(Show, Eq)

///|
fn CPUClock::to_int(self : CPUClock) -> Int raise {
  match self.0 {
    Unknown => 0
    NTSC => 1022727
    PAL => 985248
    _ => raise UnknownCPUClock
  }
}

///|
fn CPUClock::op_get(_ : CPUClock, value : VideoStandard) -> Int raise {
  value.to_int()
}

///|
test "CPUClock::op_get/valid_standards" {
  let dummy = CPUClock(Unknown) // The CPUClock instance doesn't matter
  inspect(dummy.op_get(NTSC), content="0")
  inspect(dummy.op_get(PAL), content="1")
}

///|
test "panic CPUClock::op_get/unknown_standard" {
  let dummy = CPUClock(Unknown)
  ignore(dummy.op_get(Unknown))
}

///|
test "panic CPUClock::op_get/both_standard" {
  let dummy = CPUClock(Unknown)
  ignore(dummy.op_get(Both))
}

///|
test "CPUClock::None" {
  let value = CPUClock(Unknown)
  assert_eq(value, Unknown)
  inspect(value.to_int(), content="0")
}

///|
test "CPUClock::NTSC" {
  let value = CPUClock(NTSC)
  assert_eq(value, NTSC)
  inspect(value.to_int(), content="1022727")
}

///|
test "CPUClock::PAL" {
  let value = CPUClock(PAL)
  assert_eq(value, PAL)
  inspect(value.to_int(), content="985248")
}

///|
test "error CPUClock::Both" {
  let value = CPUClock(Both)
  assert_eq(value, Both)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown CPU clock)
    ),
  )
}

///|
test "CPUClock::NTSC shift left" {
  let value = CPUClock(NTSC)
  assert_eq(value, NTSC)
  inspect(value.to_int() << 4, content="16363632")
}

///|
test "CPUClock::PAL shift left" {
  let value = CPUClock(PAL)
  assert_eq(value, PAL)
  inspect(value.to_int() << 4, content="15763968")
}

///|
pub struct ScanLines(VideoStandard) derive(Show, Eq)

///|
fn ScanLines::to_int(self : ScanLines) -> Int raise {
  match self.0 {
    NTSC => 262
    PAL => 312
    _ => raise UnknownScanLines
  }
}

///|
fn ScanLines::op_get(_ : ScanLines, value : VideoStandard) -> Int raise {
  value.to_int()
}

///|
test "ScanLines::op_get/valid_standards" {
  let scan_lines = ScanLines(Unknown) // The ScanLines instance doesn't matter
  inspect(scan_lines.op_get(NTSC), content="0")
  inspect(scan_lines.op_get(PAL), content="1")
}

///|
test "panic ScanLines::op_get/unknown_standard" {
  let scan_lines = ScanLines(Unknown)
  ignore(scan_lines.op_get(Unknown))
}

///|
test "panic ScanLines::op_get/both_standard" {
  let scan_lines = ScanLines(Unknown)
  ignore(scan_lines.op_get(Both))
}

///|
test "error ScanLines::None" {
  let value = ScanLines(Unknown)
  assert_eq(value, Unknown)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown scan lines)
    ),
  )
}

///|
test "ScanLines::NTSC" {
  let value = ScanLines(NTSC)
  assert_eq(value, NTSC)
  inspect(value.to_int(), content="262")
}

///|
test "ScanLines::PAL" {
  let value = ScanLines(PAL)
  assert_eq(value, PAL)
  inspect(value.to_int(), content="312")
}

///|
test "error ScanLines::Both" {
  let value = ScanLines(Both)
  assert_eq(value, Both)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown scan lines)
    ),
  )
}

///|
pub struct ScanLineCycles(VideoStandard) derive(Show, Eq)

///|
fn ScanLineCycles::to_int(self : ScanLineCycles) -> Int raise {
  match self.0 {
    NTSC => 65
    PAL => 63
    _ => raise UnknownScanLineCycles
  }
}

///|
fn ScanLineCycles::op_get(
  _ : ScanLineCycles,
  value : VideoStandard,
) -> Int raise {
  value.to_int()
}

///|
test "ScanLineCycles::op_get/valid_standards" {
  let scan_line_cycles = ScanLineCycles(Unknown) // The ScanLineCycles instance doesn't matter
  inspect(scan_line_cycles.op_get(NTSC), content="0")
  inspect(scan_line_cycles.op_get(PAL), content="1")
}

///|
test "panic ScanLineCycles::op_get/unknown_standard" {
  let scan_line_cycles = ScanLineCycles(Unknown)
  ignore(scan_line_cycles.op_get(Unknown))
}

///|
test "panic ScanLineCycles::op_get/both_standard" {
  let scan_line_cycles = ScanLineCycles(Unknown)
  ignore(scan_line_cycles.op_get(Both))
}

///|
test "error ScanLineCycles::None" {
  let value = ScanLineCycles(Unknown)
  assert_eq(value, Unknown)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown scan line cycles)
    ),
  )
}

///|
test "ScanLineCycles::NTSC" {
  let value = ScanLineCycles(NTSC)
  assert_eq(value, NTSC)
  inspect(value.to_int(), content="65")
}

///|
test "ScanLineCycles::PAL" {
  let value = ScanLineCycles(PAL)
  assert_eq(value, PAL)
  inspect(value.to_int(), content="63")
}

///|
test "error ScanLineCycles::Both" {
  let value = ScanLineCycles(Both)
  assert_eq(value, Both)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown scan line cycles)
    ),
  )
}

///|
pub struct FrameRate(VideoStandard) derive(Show, Eq)

///|
fn FrameRate::to_int(self : FrameRate) -> Int raise {
  match self.0 {
    NTSC => 60
    PAL => 50
    _ => raise UnknownFrameRate
  }
}

///|
fn FrameRate::op_get(_ : FrameRate, value : VideoStandard) -> Int raise {
  value.to_int()
}

///|
test "FrameRate::op_get/valid_standards" {
  let frame_rate = FrameRate(Unknown) // The FrameRate instance doesn't matter
  inspect(frame_rate.op_get(NTSC), content="0")
  inspect(frame_rate.op_get(PAL), content="1")
}

///|
test "panic FrameRate::op_get/unknown_standard" {
  let frame_rate = FrameRate(Unknown)
  ignore(frame_rate.op_get(Unknown))
}

///|
test "panic FrameRate::op_get/both_standard" {
  let frame_rate = FrameRate(Unknown)
  ignore(frame_rate.op_get(Both))
}

///|
test "error FrameRate::None" {
  let value = FrameRate(Unknown)
  assert_eq(value, Unknown)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown frame rate)
    ),
  )
}

///|
test "FrameRate::NTSC" {
  let value = FrameRate(NTSC)
  assert_eq(value, NTSC)
  inspect(value.to_int(), content="60")
}

///|
test "FrameRate::PAL" {
  let value = FrameRate(PAL)
  assert_eq(value, PAL)
  inspect(value.to_int(), content="50")
}

///|
test "error FrameRate::Both" {
  let value = FrameRate(Both)
  assert_eq(value, Both)
  inspect(
    try? value.to_int(),
    content=(
      #|Err(unknown frame rate)
    ),
  )
}
