pub struct PSID {
  mem : @cpu.Memory
  data : FixedArray[Int]
  //
  mut version : Version
  //
  mut realSID : Bool
  mut digiMode : Bool
  //
  mut loadAddress : Int
  mut initAddress : Int
  mut playAddress : Int
  mut endAddress : Int
  //
  mut title : String
  mut author : String
  mut info : String
  //
  mut songs : UInt16
  mut defaultSong : UInt16
  //
  mut flags : Flags
  //
  mut sid2Flags : SIDFlags
  mut sid3Flags : SIDFlags
  mut sid4Flags : SIDFlags
  //
  mut sid2Address : UInt8
  mut sid3Address : UInt8
}

pub fn PSID::new(mem : @cpu.Memory, data : FixedArray[Int]) -> PSID! {
  let psid : PSID = {
    mem,
    data,
    //
    version: Unknown,
    //
    realSID: false,
    digiMode: false,
    //
    loadAddress: 0x0000,
    initAddress: 0x0000,
    playAddress: 0x0000,
    endAddress: 0x0000,
    //
    title: "",
    author: "",
    info: "",
    //
    songs: 0,
    defaultSong: 0,
    //
    flags: Flags::default!(),
    //
    sid2Flags: SIDFlags::default!(),
    sid3Flags: SIDFlags::default!(),
    sid4Flags: SIDFlags::default!(),
    //
    sid2Address: 0x00,
    sid3Address: 0x00,
  }
  //
  psid
}

pub fn process(self : PSID) -> Unit! {
  println(">> PSID::process")

  /// Valid values:
  /// - PSID (0x50534944)
  /// - RSID (0x52534944)
  ///
  /// This is a four byte long ASCII character string containing the value 0x50534944
  /// (PSID) or 0x52534944 (RSID). 'RSID' (Real SID) denotes that the file strictly
  /// requires a true Commodore-64 environment to run properly. 'PSID' files will
  /// generally run trouble-free on older PlaySID and libsidplay1 based emulators,
  /// too.
  let magic = self.readString!(Magic)
  if magic != "PSID" && magic != "RSID" {
    raise UnknownFile
  }
  self.realSID = magic[0] == 'R'

  /// Valid values:
  /// - 0x0001
  /// - 0x0002 (PSID V2NG, RSID)
  /// - 0x0003 (PSID V2NG, RSID)
  /// - 0x0004 (PSID V2NG, RSID)
  ///
  /// Available version number can be 0001, 0002, 0003 or 0004. Headers of version 2,
  /// 3 and 4 provide additional fields. RSID and PSID v2NG files must have 0002,
  /// 0003 or 0004 here.
  self.version = Version::from_int!(self.readWord!(Version), self.realSID)

  /// Valid values:
  /// - 0x0076 (Version 1)
  /// - 0x007C (Version 2+)
  ///
  /// This is the offset from the start of the file to the C64 binary data area.
  /// Because of the fixed size of the header, this is either 0x0076 for version 1
  /// and 0x007C for version 2, 3 and 4.
  ///
  /// WebSID: for a 1-SID file the offset would be 0x7C, for a 2-SID file the offset would be 0x7E, etc.
  let mut offset = self.readWord!(DataOffset)

  //
  let _ = match self.version {
    PSIDv1 => offset == 0x0076
    PSIDv2 | PSIDv3 | PSIDv4 => offset == 0x007C
    RSIDv2 | RSIDv3 | RSIDv4 => offset == 0x007C
    _ => raise InvalidVersionOffset(self.version.to_string())
  }

  /// Valid values:
  /// - $0000 - $FFFF
  /// - $07E8 - $FFFF (RSID)
  ///
  /// The C64 memory location where to put the C64 data. 0 means the data are in
  /// original C64 binary file format, i.e. the first two bytes of the data contain
  /// the little-endian load address (low byte, high byte). This must always be true
  /// for RSID files. Furthermore, the actual load address must NOT be less than
  /// $07E8 in RSID files.
  self.loadAddress = self.readWord!(LoadAddress)

  //
  if self.loadAddress == 0 {
    self.loadAddress = (self[offset + 1] << 8) | self[offset]
    offset += 2
  }

  /// Valid values:
  /// - $0000 - $FFFF
  /// - $07E8 - $9FFF, $C000 - $CFFF (RSID)
  ///
  /// The start address of the machine code subroutine that initializes a song,
  /// accepting the contents of the 8-bit 6510 Accumulator as the song number
  /// parameter. 0 means the address is equal to the effective load address.
  self.initAddress = self.readWord!(InitAddress)

  /// Valid values:
  /// - $0000 - $FFFF
  /// - $0000 (RSID)
  ///
  /// The start address of the machine code subroutine that can be called frequently
  /// to produce a continuous sound. 0 means the initialization subroutine is
  /// expected to install an interrupt handler, which then calls the music player at
  /// some place. This must always be true for RSID files.
  self.playAddress = self.readWord!(PlayAddress)

  /// Valid values:
  /// - 0x0001 - 0x0100
  ///
  /// The number of songs (or sound effects) that can be initialized by calling the
  /// init address. The minimum is 1. The maximum is 256.
  self.songs = self.readWord!(Songs)

  /// Valid values:
  /// - 1 - songs
  ///
  /// The song number to be played by default. This value is optional. It often
  /// specifies the first song you would hear upon starting the program is has been
  /// taken from. It has a default of 1.
  self.defaultSong = self.readWord!(DefaultSong)

  /// Valid values:
  /// - 0x00000000 - 0xFFFFFFFF
  /// - 0x00000000 (RSID)
  ///
  /// This is a 32 bit big endian number.
  // self.speed = []

  /// These are 32 byte long Extended ASCII encoded (Windows-1252 code page) character
  /// strings. Upon evaluating the header, these fields may hold a character string of
  /// 32 bytes which is not zero terminated. For less than 32 characters the string
  /// should be zero terminated. The maximum number of available free characters is
  /// 32.
  self.title = self.readString!(Title)
  self.author = self.readString!(Author)
  self.info = self.readString!(ReleaseInfo)

  /// Version 1 of the SID header is complete at this point. The binary C64 data
  /// starts here.
  match self.version {
    // PSIDv1 =>
    PSIDv2 | RSIDv2 => {
      /// This is a v3 specific field.
      self.sid2Address = self.readByte!(SID2Address)
      /// For v2NG, it should be set to 0.
      if self.sid2Address != 0x00 {
        raise InvalidAddressV2
      }

      /// This is a v4 specific field.
      self.sid3Address = self.readByte!(SID3Address)
      /// For v2NG and v3, it should be set to 0.
      if self.sid3Address != 0x00 {
        raise InvalidAddressV2
      }
    }
    PSIDv3 | RSIDv3 => {
      /// This is a v3 specific field.
      self.sid2Address = self.readByte!(SID2Address)
      if (self.sid2Address < 0x42 || self.sid2Address > 0x7F) &&
        (self.sid2Address < 0xE0 || self.sid2Address > 0xFE) &&
        (self.sid2Address & 1) == 1 {
        raise InvalidAddressV3Even
      }

      /// This is a v4 specific field.
      self.sid3Address = self.readByte!(SID3Address)
      /// For v2NG and v3, it should be set to 0.
      if self.sid3Address != 0x00 {
        raise InvalidAddressV3
      }
    }
    PSIDv4 | RSIDv4 => {
      /// This is a v3 specific field.
      self.sid2Address = self.readByte!(SID2Address)
      if (self.sid2Address < 0x42 || self.sid2Address > 0x7F) &&
        (self.sid2Address < 0xE0 || self.sid2Address > 0xFE) &&
        (self.sid2Address & 1) == 1 {
        raise InvalidAddressV4Even
      }

      /// This is a v4 specific field.
      self.sid3Address = self.readByte!(SID3Address)
      if (self.sid3Address < 0x42 || self.sid3Address > 0x7F) &&
        (self.sid3Address < 0xE0 || self.sid3Address > 0xFE) &&
        (self.sid3Address & 1) == 1 {
        raise InvalidAddressV4Even
      }
    }
    _ => raise UnknownVersionPSID
  }

  /// Valid values:
  /// - 0x0000 - 0x03FF
  ///
  /// This is a 16 bit big endian number containing the following bitfields:
  self.flags = Flags::from_int!(self.readWord!(Flags), self.realSID)

  //
  self.digiMode = self.flags.mode == Digi

  /// Before the data of a SID file is loaded in memory of a C64, certain addresses
  /// and chips must be initialized in order to play the SID tune correctly.
  ///
  /// $02A6 : depending on the PAL/NTSC flag in the SID file header, it is set to
  ///         0x01 for PAL and set to 0x00 for NTSC.
  self[0x02A6] = match self.flags.videoStandard {
    NTSC => 0x00
    PAL => 0x01
  }

  //
  let mut j = 0
  for i = offset; i < self.data.length(); i = i + 1 {
    self[self.loadAddress + j] = self[i]
    j = j + 1
  }
  self.endAddress = (self.loadAddress + j) & 0xFFFF

  //
  println("<< PSID::process")
}

fn readByte(self : PSID, header : SIDheader) -> Int! {
  match header {
    StartPage => self[0x78]
    PageLength => self[0x79]
    //
    SID2Address => self[0x7A]
    SID3Address => self[0x7B]
    //
    _ => raise UnknownHeader(header.to_string())
  }
}

fn readWord(self : PSID, header : SIDheader) -> Int! {
  match header {
    Version => self.makeWord(0x04)
    DataOffset => self.makeWord(0x06)
    LoadAddress => self.makeWord(0x08)
    InitAddress => self.makeWord(0x0A)
    PlayAddress => self.makeWord(0x0C)
    Songs => self.makeWord(0x0E)
    DefaultSong => self.makeWord(0x10)
    //
    Flags => self.makeWord(0x76)
    //
    _ => raise UnknownHeader(header.to_string())
  }
}

fn makeWord(self : PSID, offset : Int) -> Int {
  (self[offset] << 8) | self[offset + 1]
}

fn readString(self : PSID, header : SIDheader) -> String! {
  match header {
    Magic => self.makeString(0x00, 4)
    //
    Title => self.makeString(0x16, 32)
    Author => self.makeString(0x36, 32)
    ReleaseInfo => self.makeString(0x56, 32)
    //
    _ => raise UnknownHeader(header.to_string())
  }
}

fn makeString(self : PSID, offset : Int, length : Int) -> String {
  let bytes : Bytes = Bytes::new(length << 1)
  for i = 0; i < length; i = i + 1 {
    bytes[i << 1] = self[offset + i].to_byte()
  }
  bytes.to_string()
}

pub fn videoStandard(self : PSID) -> VideoStandard {
  self.flags.videoStandard
}

fn op_get(self : PSID, address : Int) -> Int {
  if address < 0x0000 || address > self.data.length() {
    // self.dump()
    println("PSID::get out of bounds")
    abort("PSID::get out of bounds")
  }
  // println(
  //   "PSID $" + address.to_hex() + " → #$" + (self.data[address.0] |> u8).to_hex(),
  // )
  self.data[address]
}

fn op_set(self : PSID, address : Int, value : Int) -> Unit {
  if address < 0x0000 || address > 0xFFFF {
    // self.dump()
    println("PSID::set out of bounds")
    abort("PSID::set out of bounds")
  }
  // println("PSID $" + address.to_hex() + " ← #$" + value.to_hex())
  self.mem[address] = value
}
