//0:NTSC, 1:PAL (based on the SID-header field)
enum VideoStandard {
  Unknown
  NTSC
  PAL
  Both
} derive(Debug, Eq)

fn VideoStandard::from_int(value : Int) -> VideoStandard {
  match value {
    0b00 => Unknown
    0b01 => PAL
    0b10 => NTSC
    0b11 => Both
    _ => {
      println("unknown video standard")
      abort("unknown video standard")
    }
  }
}

fn to_int(self : VideoStandard) -> Int {
  self[self]
}

fn op_get(self : VideoStandard, value : VideoStandard) -> Int {
  match value {
    NTSC => 0
    PAL => 1
    _ => {
      println("unknown video standard")
      abort("unknown video standard")
    }
  }
}

///

type CPUClock VideoStandard derive(Debug, Eq)

fn to_int(self : CPUClock) -> Int {
  self[self.0]
}

fn op_get(self : CPUClock, value : VideoStandard) -> Int {
  match value {
    Unknown => 0
    NTSC => 1022727
    PAL => 985248
    _ => {
      println("unknown CPU clock")
      abort("unknown CPU clock")
    }
  }
}

fn lsl(self : CPUClock, bits : Int) -> Int {
  self[self.0] << bits
}

test "CPUClock::None" {
  let value = CPUClock(Unknown)
  @test.eq!(value, Unknown)
  @test.eq!(value.to_int(), 0)
}

test "CPUClock::NTSC" {
  let value = CPUClock(NTSC)
  @test.eq!(value, NTSC)
  @test.eq!(value.to_int(), 1022727)
}

test "CPUClock::PAL" {
  let value = CPUClock(PAL)
  @test.eq!(value, PAL)
  @test.eq!(value.to_int(), 985248)
}

test "panic CPUClock::Both" {
  let value = CPUClock(Both)
  @test.eq!(value, Both)
  @test.eq!(value.to_int(), 0)
}

test "CPUClock::NTSC shift left" {
  let value = CPUClock(NTSC)
  @test.eq!(value, NTSC)
  @test.eq!(value << 4, 16363632)
}

test "CPUClock::PAL shift left" {
  let value = CPUClock(PAL)
  @test.eq!(value, PAL)
  @test.eq!(value << 4, 15763968)
}

///

type ScanLines VideoStandard derive(Debug, Eq)

fn to_int(self : ScanLines) -> Int {
  self[self.0]
}

fn op_get(self : ScanLines, value : VideoStandard) -> Int {
  match value {
    NTSC => 263
    PAL => 312
    _ => {
      println("unknown scan lines")
      abort("unknown scan lines")
    }
  }
}

test "panic ScanLines::None" {
  let value = ScanLines(Unknown)
  @test.eq!(value, Unknown)
  @test.eq!(value.to_int(), 0)
}

test "ScanLines::NTSC" {
  let value = ScanLines(NTSC)
  @test.eq!(value, NTSC)
  @test.eq!(value.to_int(), 263)
}

test "ScanLines::PAL" {
  let value = ScanLines(PAL)
  @test.eq!(value, PAL)
  @test.eq!(value.to_int(), 312)
}

test "panic ScanLines::Both" {
  let value = ScanLines(Both)
  @test.eq!(value, Both)
  @test.eq!(value.to_int(), 0)
}

///

type ScanLineCycles VideoStandard derive(Debug, Eq)

fn to_int(self : ScanLineCycles) -> Int {
  self[self.0]
}

fn op_get(self : ScanLineCycles, value : VideoStandard) -> Int {
  match value {
    NTSC => 65
    PAL => 63
    _ => {
      println("unknown scan line cycles")
      abort("unknown scan line cycles")
    }
  }
}

test "panic ScanLineCycles::None" {
  let value = ScanLineCycles(Unknown)
  @test.eq!(value, Unknown)
  @test.eq!(value.to_int(), 0)
}

test "ScanLineCycles::NTSC" {
  let value = ScanLineCycles(NTSC)
  @test.eq!(value, NTSC)
  @test.eq!(value.to_int(), 65)
}

test "ScanLineCycles::PAL" {
  let value = ScanLineCycles(PAL)
  @test.eq!(value, PAL)
  @test.eq!(value.to_int(), 63)
}

test "panic ScanLineCycles::Both" {
  let value = ScanLineCycles(Both)
  @test.eq!(value, Both)
  @test.eq!(value.to_int(), 0)
}

///

type FrameRate VideoStandard derive(Debug, Eq)

fn to_int(self : FrameRate) -> Int {
  self[self.0]
}

fn op_get(self : FrameRate, value : VideoStandard) -> Int {
  match value {
    NTSC => 60
    PAL => 50
    _ => {
      println("unknown frame rate")
      abort("unknown frame rate")
    }
  }
}

test "panic FrameRate::None" {
  let value = FrameRate(Unknown)
  @test.eq!(value, Unknown)
  @test.eq!(value.to_int(), 0)
}

test "FrameRate::NTSC" {
  let value = FrameRate(NTSC)
  @test.eq!(value, NTSC)
  @test.eq!(value.to_int(), 60)
}

test "FrameRate::PAL" {
  let value = FrameRate(PAL)
  @test.eq!(value, PAL)
  @test.eq!(value.to_int(), 50)
}

test "panic FrameRate::Both" {
  let value = FrameRate(Both)
  @test.eq!(value, Both)
  @test.eq!(value.to_int(), 0)
}
