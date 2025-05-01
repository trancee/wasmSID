///| 
/// clear; moon run main | diff -y nestest/nestest.log -
/// 
pub fn nestest() -> Unit! {
  let data = match @fs.read_file_to_bytes?("tests/nestest/nestest.nes") {
    Ok(data) => data
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("test not found")
    }
  }

  //
  let nes = NES::new!(
    pc=0xC000,

    //
    data~,
    //
    address=0x8000,
    length=0x4000,
    offset=0x10, // 0x10 iNES Header

    //
    debug=true,
  )

  //
  nes.set_flags(@cpu.UNUSED | @cpu.INTERRUPT)

  //
  nes.load!(
    data,
    //
    address=0xC000,
    length=0x4000,
    offset=0x10, // 0x10 iNES Header
  )
  |> ignore

  //
  nes.load!(
    [
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
    ],
    address=0x4000,
  )
  |> ignore

  // nes.load([0x20, 0x00, 0xC0], offset=0x0800)
  nes.push16(0x07FF)

  //
  let mut cycles = 0
  while nes.pc() != 0x0800 {
    cycles += nes.step()

    //
    if cycles > 26553 {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }
  }

  //
  // println("cycles: \{cycles}")

  //
  println("---")
  println(
    "$02 #" +
    nes.mem.read(0x02, dummy=true).to_hex() +
    " " +
    (if nes.mem.read(0x02) == 0x00 { "OK" } else { "FAIL" }),
  )
  println(
    "$03 #" +
    nes.mem.read(0x03, dummy=true).to_hex() +
    " " +
    (if nes.mem.read(0x03) == 0x00 { "OK" } else { "FAIL" }),
  )
}
