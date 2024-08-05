//0:NTSC, 1:PAL (based on the SID-header field)
enum VideoStandard {
  Unknown
  NTSC
  PAL
  Both
} derive(Show, Eq)

fn VideoStandard::from_int(value : Int) -> VideoStandard!String {
  match value {
    0b00 => Unknown
    0b01 => PAL
    0b10 => NTSC
    0b11 => Both
    _ => raise "unknown video standard"
  }
}

fn to_int(self : VideoStandard) -> Int!String {
  match self {
    NTSC => 0
    PAL => 1
    _ => raise "unknown video standard"
  }
}

fn op_get(self : VideoStandard, value : VideoStandard) -> Int!String {
  value.to_int!()
}

///

type CPUClock VideoStandard derive(Show, Eq)

fn to_int(self : CPUClock) -> Int!String {
  match self.0 {
    Unknown => 0
    NTSC => 1022727
    PAL => 985248
    _ => raise "unknown CPU clock"
  }
}

fn op_get(self : CPUClock, value : VideoStandard) -> Int!String {
  value.to_int!()
}

fn lsl(self : CPUClock, bits : Int) -> Int!String {
  self.to_int!() << bits
}

test "CPUClock::None" {
  let value = CPUClock(Unknown)
  @test.eq!(value, Unknown)
  // @test.eq!(value.to_int!(), 0)
}

test "CPUClock::NTSC" {
  let value = CPUClock(NTSC)
  @test.eq!(value, NTSC)
  // @test.eq!(value.to_int!(), 1022727)
}

test "CPUClock::PAL" {
  let value = CPUClock(PAL)
  @test.eq!(value, PAL)
  // @test.eq!(value.to_int(), 985248)
}

test "panic CPUClock::Both" {
  let value = CPUClock(Both)
  @test.eq!(value, Both)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown CPU clock")
      panic()
    }
  }

}

test "CPUClock::NTSC shift left" {
  let value = CPUClock(NTSC)
  @test.eq!(value, NTSC)
  // @test.eq!(value.lsl!(4), 16363632)
}

test "CPUClock::PAL shift left" {
  let value = CPUClock(PAL)
  @test.eq!(value, PAL)
  // @test.eq!(value.lsl!(4), 15763968)
}

///

type ScanLines VideoStandard derive(Show, Eq)

fn to_int(self : ScanLines) -> Int!String {
  match self.0 {
    NTSC => 263
    PAL => 312
    _ => raise "unknown scan lines"
  }
}

fn op_get(self : ScanLines, value : VideoStandard) -> Int!String {
  value.to_int!()
}

test "panic ScanLines::None" {
  let value = ScanLines(Unknown)
  @test.eq!(value, Unknown)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown scan lines")
      panic()
    }
  }

}

test "ScanLines::NTSC" {
  let value = ScanLines(NTSC)
  @test.eq!(value, NTSC)
  // @test.eq!(value.to_int!(), 263)
}

test "ScanLines::PAL" {
  let value = ScanLines(PAL)
  @test.eq!(value, PAL)
  // @test.eq!(value.to_int!(), 312)
}

test "panic ScanLines::Both" {
  let value = ScanLines(Both)
  @test.eq!(value, Both)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown scan lines")
      panic()
    }
  }

}

///

type ScanLineCycles VideoStandard derive(Show, Eq)

fn to_int(self : ScanLineCycles) -> Int!String {
  match self.0 {
    NTSC => 65
    PAL => 63
    _ => raise "unknown scan line cycles"
  }
}

fn op_get(self : ScanLineCycles, value : VideoStandard) -> Int!String {
  value.to_int!()
}

test "panic ScanLineCycles::None" {
  let value = ScanLineCycles(Unknown)
  @test.eq!(value, Unknown)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown scan line cycles")
      panic()
    }
  }

}

test "ScanLineCycles::NTSC" {
  let value = ScanLineCycles(NTSC)
  @test.eq!(value, NTSC)
  // @test.eq!(value.to_int!(), 65)
}

test "ScanLineCycles::PAL" {
  let value = ScanLineCycles(PAL)
  @test.eq!(value, PAL)
  // @test.eq!(value.to_int(), 63)
}

test "panic ScanLineCycles::Both" {
  let value = ScanLineCycles(Both)
  @test.eq!(value, Both)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown scan line cycles")
      panic()
    }
  }

}

///

type FrameRate VideoStandard derive(Show, Eq)

fn to_int(self : FrameRate) -> Int!String {
  match self.0 {
    NTSC => 60
    PAL => 50
    _ => raise "unknown frame rate"
  }
}

fn op_get(self : FrameRate, value : VideoStandard) -> Int!String {
  value.to_int!()
}

test "panic FrameRate::None" {
  let value = FrameRate(Unknown)
  @test.eq!(value, Unknown)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown frame rate")
      panic()
    }
  }

}

test "FrameRate::NTSC" {
  let value = FrameRate(NTSC)
  @test.eq!(value, NTSC)
  // @test.eq!(value.to_int!(), 60)
}

test "FrameRate::PAL" {
  let value = FrameRate(PAL)
  @test.eq!(value, PAL)
  // @test.eq!(value.to_int!(), 50)
}

test "panic FrameRate::Both" {
  let value = FrameRate(Both)
  @test.eq!(value, Both)
  let _ = try {
    value.to_int!()
  } catch {
    msg => {
      @test.eq!(msg, "unknown frame rate")
      panic()
    }
  }

}
