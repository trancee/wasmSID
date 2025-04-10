///|
enum SIDheader {
  Magic // 0x00 String[4]
  //
  Version // 0x04 Word
  DataOffset // 0x06 Word
  //
  LoadAddress // 0x08 Word
  InitAddress // 0x0A Word
  PlayAddress // 0x0C Word
  //
  Songs // 0x0E Word
  DefaultSong // 0x10 Word
  //
  Speed // 0x12 Byte[4]
  //
  Title // 0x16 String[32]
  Author // 0x36 String[32]
  ReleaseInfo // 0x56 String[32]
  //
  Flags // 0x76 Word
  //
  StartPage // 0x78 Byte
  PageLength // 0x79 Byte
  //
  SID2Address // 0x7A Byte
  SID3Address // 0x7B Byte
} derive(Show)

///| Valid values:
/// - 0x0001
/// - 0x0002 (PSID V2NG, RSID)
/// - 0x0003 (PSID V2NG, RSID)
/// - 0x0004 (PSID V2NG, RSID)
///
/// Available version number can be 0001, 0002, 0003 or 0004. Headers of version 2,
/// 3 and 4 provide additional fields. RSID and PSID v2NG files must have 0002,
/// 0003 or 0004 here.
///
/// 0x4E for 4SID (WebSID-format)
enum Version {
  Unknown
  PSIDv1
  PSIDv2
  PSIDv3
  PSIDv4
  RSIDv2
  RSIDv3
  RSIDv4
} derive(Show, Eq)

///|
fn Version::from_int(value : UInt16, realSID : Bool) -> Version! {
  if realSID {
    match value._ {
      // 0x00 => Unknown
      0x02 => RSIDv2
      0x03 => RSIDv3
      0x04 => RSIDv4
      _ => raise UnknownVersion
    }
  } else {
    match value._ {
      // 0x00 => Unknown
      0x01 => PSIDv1
      0x02 => PSIDv2
      0x03 => PSIDv3
      0x04 => PSIDv4
      _ => raise UnknownVersion
    }
  }
}

// fn op_get(self : Version, value : Version) -> Int {
//   match value {
//     Unknown => 0x00
//     //
//     PSIDv1 => 0x01
//     PSIDv2 => 0x02
//     PSIDv3 => 0x03
//     PSIDv4 => 0x04
//     //
//     RSIDv2 => 0x02
//     RSIDv3 => 0x03
//     RSIDv4 => 0x04
//   }
// }

// bit9&8/7&6/5&4: SID3/2/1 model (00:?,01:6581,10:8580,11:both) (4SID:bit6=SID1-channel)
// bit3&2:VideoStandard (01:PAL,10:NTSC,11:both)
// bit1:(0:C64,1:PlaySIDsamples/RSID_BASICflag)
// bit0:(0:builtin-player,1:MUS)

///|
enum Mode {
  // Unknown
  C64
  Digi
  BASIC
} derive(Show, Eq)

///|
fn Mode::from_int(value : Int, realSID : Bool) -> Mode! {
  if realSID {
    match value {
      0x00 => C64
      0x01 => Digi
      _ => raise UnknownMode
    }
  } else {
    match value {
      0x00 => C64
      0x01 => BASIC
      _ => raise UnknownMode
    }
  }
}

// flags for WebSID-format,
// bit7 should be 'middle' channel-flag (overriding bit6 left/right)
// bit6: output-channel (0(default):left, 1:right, ?:both?),
// bit5..4:SIDmodel(00:setting,01:6581,10:8580,11:both)
///|
struct SIDFlags {
  channel : Channel
  model : Model
} derive(Show, Eq)

///|
fn SIDFlags::default() -> SIDFlags! {
  SIDFlags::from_int!(0x0000)
}

///|
fn SIDFlags::from_int(value : UInt16) -> SIDFlags! {
  {
    channel: Channel::from_int!((value._ >> 6) & 0b11),
    model: Model::from_int!((value._ >> 4) & 0b11),
  }
}

///|
pub struct Flags {
  player : Int
  mode : Mode
  videoStandard : VideoStandard
  model : FixedArray[Model]
} derive(Show, Eq)

///|
fn Flags::default() -> Flags! {
  Flags::from_int!(0x0000, false)
}

///|
fn Flags::from_int(value : UInt16, realSID : Bool) -> Flags! {
  {
    player: (value._ >> 0) & 0b01,
    mode: Mode::from_int!((value._ >> 1) & 0b01, realSID),
    videoStandard: VideoStandard::from_int!((value._ >> 2) & 0b11),
    model: [
      Model::from_int!((value._ >> 4) & 0b11),
      Model::from_int!((value._ >> 6) & 0b11),
      Model::from_int!((value._ >> 8) & 0b11),
    ],
  }
}

///|
fn op_shr(self : Flags, bits : Int) -> Int {
  self >> bits
}

///|
fn land(self : Flags, bits : Int) -> Int {
  self & bits
}
