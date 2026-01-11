///|
let subtune = 1

///|
pub fn sidtest(file? : String = "files/Ikari_Union.sid") -> Unit raise {
  let mem = Memory::new()

  //
  let siddata = @fs.read_file_to_bytes(file) catch {
    error => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let psid = PSID::new(mem, siddata) catch {
    err => {
      println(err)
      panic()
    }
  }

  //
  psid.process() catch {
    err => {
      println(err)
      panic()
    }
  }

  //
  println("---")

  //
  let c64 = C64::new(
    mem~,
    model=psid.flags.model,
    videoStandard=psid.videoStandard(),
    realSID=psid.realSID,
    debug=true,
  )

  //
  initSIDtune(c64, psid, subtune)
  println("---")

  //
  let author = psid.author
  let title = psid.title
  let info = psid.info
  println("Author: \{author} , Title: \{title} , Info: \{info}")
  println(
    "Load-address:$" +
    u16(psid.loadAddress).to_hex() +
    ", End-address:$" +
    u16(psid.endAddress).to_hex() +
    ", Size:" +
    (psid.endAddress - psid.loadAddress).to_string() +
    " bytes",
  )
  println("Init-address:$" + u16(psid.initAddress).to_hex())
  let mut s = ""
  if not(psid.realSID) {
    s += "Play-address:$" + u16(psid.playAddress).to_hex() + ", "
    if psid.playAddress == 0 {
      s += "(IRQ), "
    }
  }
  let song = psid.defaultSong.0
  let songs = psid.songs.0
  s += "Subtune:\{song} (of \{songs})"
  if psid.realSID {
    s += ", RealSID"
  } else if psid.digiMode {
    s += ", PSID-digi"
  }
  println(s)
  println("---")

  //
  c64.push16(0xFFFF)

  //
  let mut i = 0
  while c64.pc() != 0x0000 && i < 1000 {
    c64.emulate() |> ignore
    i += 1
  }
}

///|
fn initSIDtune(c64 : C64, psid : PSID, subtune : Int) -> Unit {
  let mut subtune = subtune
  if subtune == 0 {
    subtune = 1
  } else if subtune > psid.songs.0 {
    subtune = psid.songs.0
  }

  //determine init-address:
  c64.initCPU(pc=psid.initAddress)
  c64.setA(subtune - 1)
  c64.push16(0xFFFF)
  let mut i = 0
  while c64.pc() != 0x0000 && i < 1000 {
    c64.emulate() |> ignore
    i += 1
  }

  //determine playaddress:
  let playAddress = psid.playAddress
  if playAddress > 0 {
    //normal play-address called with JSR
  }
  c64.initCPU(pc=playAddress) //point CPU to play-routine
}
