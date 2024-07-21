enum SIDheader {
  Magic // 0x00 String[4]
  //
  Version // 0x04 Word
  HeaderSize // 0x06 Word
  LoadAddress // 0x08 Word
  InitAddress // 0x0A Word
  PlayAddress // 0x0C Word
  SubtuneAmount // 0x0E Word
  DefaultSubtune // 0x10 Word
  //
  SubtuneTimeSources // 0x12 Byte[4]
  //
  Title // 0x16 String[32]
  Author // 0x36 String[32]
  ReleaseInfo // 0x56 String[32]
  //
  ModelFormatStandard // 0x76 Word
  //
  RelocStartPage // 0x78 Byte
  RelocFreePages // 0x79 Byte
  //
  SID2Flags // 0x7A Word
  SID3Flags // 0x7C Word (the same address/flag-layout for SID3 as with SID2)
  SID4Flags // 0x7E Word (the same address/flag-layout for SID4 as with SID2)
  //
  // WebSID
  SID2BaseAddress // 0x7A Byte
  SID3BaseAddress // 0x7B Byte
  SID4BaseAddress // 0x7E Byte
} derive(Show)

// 1 for PSID v1, 2..4 for PSID v2..4 or RSID v2..4 (3/4 has 2SID/3SID support), 0x4E for 4SID (WebSID-format)
enum Version {
  Unknown
  PSIDv1
  PSIDv2
  PSIDv3
  PSIDv4
  WebSID
} derive(Debug, Eq)

fn Version::from_int(value : UInt16) -> Version {
  match value.0 {
    0x00 => Unknown
    0x01 => PSIDv1
    0x02 => PSIDv2
    0x03 => PSIDv3
    0x04 => PSIDv4
    0x4E => WebSID
    _ => {
      println("unknown version")
      abort("unknown version")
    }
  }
}

fn op_get(self : Version, value : Version) -> Int {
  match value {
    Unknown => 0x00
    PSIDv1 => 0x01
    PSIDv2 => 0x02
    PSIDv3 => 0x03
    PSIDv4 => 0x04
    WebSID => 0x4E
  }
}

// bit9&8/7&6/5&4: SID3/2/1 model (00:?,01:6581,10:8580,11:both) (4SID:bit6=SID1-channel)
// bit3&2:VideoStandard (01:PAL,10:NTSC,11:both)
// bit1:(0:C64,1:PlaySIDsamples/RSID_BASICflag)
// bit0:(0:builtin-player,1:MUS)

enum Mode {
  Unknown
  C64
  Digi
  BASIC
} derive(Debug, Eq)

fn Mode::from_int(value : Int, realSID : Bool) -> Mode {
  if realSID {
    match value {
      0x00 => C64
      0x01 => Digi
      _ => {
        println("unknown mode")
        abort("unknown mode")
      }
    }
  } else {
    match value {
      0x00 => C64
      0x01 => BASIC
      _ => {
        println("unknown mode")
        abort("unknown mode")
      }
    }
  }
}

// flags for WebSID-format,
// bit7 should be 'middle' channel-flag (overriding bit6 left/right)
// bit6: output-channel (0(default):left, 1:right, ?:both?),
// bit5..4:SIDmodel(00:setting,01:6581,10:8580,11:both)
struct SIDFlags {
  channel : Channel
  model : SIDModel
} derive(Debug, Eq)

fn SIDFlags::default() -> SIDFlags {
  SIDFlags::from_int(0x0000)
}

fn SIDFlags::from_int(value : UInt16) -> SIDFlags {
  {
    channel: Channel::from_int((value.0 >> 6) & 0b11),
    model: SIDModel::from_int((value.0 >> 4) & 0b11),
  }
}

struct ModelFormatStandard {
  player : Int
  mode : Mode
  videoStandard : VideoStandard
  model : Array[SIDModel]
} derive(Debug, Eq)

fn ModelFormatStandard::default() -> ModelFormatStandard {
  ModelFormatStandard::from_int(0x0000, false)
}

fn ModelFormatStandard::from_int(
  value : UInt16,
  realSID : Bool
) -> ModelFormatStandard {
  {
    player: (value.0 >> 0) & 0b01,
    mode: Mode::from_int((value.0 >> 1) & 0b01, realSID),
    videoStandard: VideoStandard::from_int((value.0 >> 2) & 0b11),
    model: [
      SIDModel::from_int((value.0 >> 4) & 0b11),
      SIDModel::from_int((value.0 >> 6) & 0b11),
      SIDModel::from_int((value.0 >> 8) & 0b11),
    ],
  }
}

fn land(self : ModelFormatStandard, bits : Int) -> Int {
  self & bits
}

fn asr(self : ModelFormatStandard, bits : Int) -> Int {
  self >> bits
}
