pub struct PSID {
  mem : @cpu.Memory
  data : Array[Int]
  //
  mut version : Version
  //
  mut realSID : Bool
  mut digiMode : Bool
  //
  mut loadAddress : UInt16
  mut initAddress : UInt16
  mut playAddress : UInt16
  mut endAddress : UInt16
  //
  mut title : String
  mut author : String
  mut info : String
  //
  mut subtune : UInt16
  mut subtuneAmount : UInt16
  //
  mut modelFormatStandard : ModelFormatStandard
  mut model : Array[SIDModel]
  //
  mut sid2Flags : SIDFlags
  mut sid3Flags : SIDFlags
  mut sid4Flags : SIDFlags
  //
  mut sid2BaseAddress : UInt8
  mut sid3BaseAddress : UInt8
  mut sid4BaseAddress : UInt8
}

pub fn PSID::new(mem : @cpu.Memory, data : Array[Int]) -> PSID {
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
    subtune: 0,
    subtuneAmount: 0,
    //
    modelFormatStandard: ModelFormatStandard::default(),
    model: [],
    //
    sid2Flags: SIDFlags::default(),
    sid3Flags: SIDFlags::default(),
    sid4Flags: SIDFlags::default(),
    //
    sid2BaseAddress: 0x00,
    sid3BaseAddress: 0x00,
    sid4BaseAddress: 0x00,
  }
  //
  psid
}

pub fn process(self : PSID) -> Bool {
  // println(">> PSID::process")

  //
  let magic = self.readString(Magic)
  if magic != "PSID" && magic != "RSID" {
    return false
  }
  self.realSID = magic[0] == 'R'

  //
  let mut offset = self.readWord(HeaderSize)
  // println("HeaderSize = $" + offset.to_hex())

  //
  self.version = Version::from_int(self.readWord(Version))

  //load-adress taken from SID-header
  self.loadAddress = self.readWord(LoadAddress)
  if self.loadAddress == 0 {
    //load-address taken from first 2 bytes of the C64 PRG
    self.loadAddress = (self[offset + 1].0 << 8) | self[offset].0
    offset += 2
  }
  let mut j = 0
  for i = offset; i < self.data.length(); i = i + 1 {
    self[self.loadAddress + j] = self[i]
    j = j + 1
  }
  self.endAddress = (self.loadAddress + j) & 0xFFFF

  //
  self.modelFormatStandard = ModelFormatStandard::from_int(
    self.readWord(ModelFormatStandard),
    self.realSID,
  )

  //
  self.digiMode = self.modelFormatStandard.mode == Digi

  //
  self.initAddress = self.readWord(InitAddress)
  self.playAddress = self.readWord(PlayAddress)

  //
  self.title = self.readString(Title)
  self.author = self.readString(Author)
  self.info = self.readString(ReleaseInfo)

  //
  self.subtune = self.readWord(DefaultSubtune)
  self.subtuneAmount = self.readWord(SubtuneAmount)

  //
  if self.version == WebSID {
    self.sid2BaseAddress = self.readByte(SID2BaseAddress)
    self.sid3BaseAddress = self.readByte(SID3BaseAddress)
    self.sid4BaseAddress = self.readByte(SID4BaseAddress)
  } else {
    self.sid2Flags = SIDFlags::from_int(self.readWord(SID2Flags))
    self.sid3Flags = SIDFlags::from_int(self.readWord(SID3Flags))
    self.sid4Flags = SIDFlags::from_int(self.readWord(SID4Flags))
  }

  //
  // println("<< PSID::process")

  //
  true
}

fn readByte(self : PSID, header : SIDheader) -> UInt8 {
  match header {
    RelocStartPage => self[0x78]
    RelocFreePages => self[0x79]
    //
    SID2BaseAddress => self[0x7A]
    SID3BaseAddress => self[0x7B]
    SID4BaseAddress => self[0x7E]
    //
    _ => {
      println("unknown SID header: \(header)")
      abort("unknown SID header: \(header)")
    }
  }
}

fn readWord(self : PSID, header : SIDheader) -> UInt16 {
  match header {
    Version => self.makeWord(0x04)
    HeaderSize => self.makeWord(0x06)
    LoadAddress => self.makeWord(0x08)
    InitAddress => self.makeWord(0x0A)
    PlayAddress => self.makeWord(0x0C)
    SubtuneAmount => self.makeWord(0x0E)
    DefaultSubtune => self.makeWord(0x10)
    //
    ModelFormatStandard => self.makeWord(0x76)
    //
    SID2Flags => self.makeWord(0x7A)
    SID3Flags => self.makeWord(0x7C)
    SID4Flags => self.makeWord(0x7E)
    //
    _ => {
      println("unknown SID header: \(header)")
      abort("unknown SID header: \(header)")
    }
  }
}

fn makeWord(self : PSID, offset : Int) -> UInt16 {
  (self[offset] << 8).0 | self[offset + 1].0
}

fn readString(self : PSID, header : SIDheader) -> String {
  match header {
    Magic => self.makeString(0x00, 4)
    //
    Title => self.makeString(0x16, 32)
    Author => self.makeString(0x36, 32)
    ReleaseInfo => self.makeString(0x56, 32)
    //
    _ => {
      println("unknown SID header: \(header)")
      abort("unknown SID header: \(header)")
    }
  }
}

fn makeString(self : PSID, offset : Int, length : Int) -> String {
  let bytes : Bytes = Bytes::new(length << 1)
  for i = 0; i < length; i = i + 1 {
    bytes[i << 1] = self[offset + i].to_byte()
  }
  bytes.to_string()
}

fn op_get(self : PSID, address : UInt16) -> UInt8 {
  if address < 0 || address > self.data.length() {
    // self.dump()
    println("PSID::get out of bounds")
    abort("PSID::get out of bounds")
  }
  // println(
  //   "PSID $" + address.to_hex() + " → #$" + (self.data[address.0] |> u8).to_hex(),
  // )
  self.data[address.0]
}

fn op_set(self : PSID, address : UInt16, value : UInt8) -> Unit {
  if address < 0 || address > 0xFFFF {
    // self.dump()
    println("PSID::set out of bounds")
    abort("PSID::set out of bounds")
  }
  // println("PSID $" + address.to_hex() + " ← #$" + value.to_hex())
  self.mem[address.0] = value.0
}
