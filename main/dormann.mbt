///|
/// This program is designed to test all opcodes of a 6502 emulator using all
/// addressing modes with focus on propper setting of the processor status
/// register bits.
/// 
/// https://github.com/Klaus2m5/6502_65C02_functional_tests/tree/master
/// 
const START_ADDRESS = 0x0400

///|
// const END_ADDRESS = 0x3399 // 16-aug-2013
const END_ADDRESS = 0x3469 // 04-dec-2017

///|
const TEST_CASE = 0x0200

///|
pub fn dormann() -> Unit {
  let content = match
    @fs.read_file_to_bytes?("tests/6502_functional_test.bin") {
    Ok(content) => content
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let cpu = CPU::new(
    pc=START_ADDRESS,

    //
    address=0x0000,
    //
    data=content,

    //
    debug=false,
  )

  //
  cpu.trap(cpu.read16(@cpu.RESET), fn(_) {
    println("\u{1B}[31;1;6mRESET\u{1B}[0m")
    abort("RESET")
  })
  cpu.trap(cpu.read16(@cpu.NMI), fn(_) {
    println("\u{1B}[31;1;6mNMI\u{1B}[0m")
    abort("NMI")
  })
  // cpu.trap(cpu.read16(@cpu.IRQ), fn(_) {
  //   println("\u{1B}[31;1;6mIRQ\u{1B}[0m")
  //   abort("IRQ")
  // })

  //
  let mut last_pc = U16::u16(0xFFFF)
  let mut last_test = U8::u8(0xFF)

  //
  let mut cycles = 0
  while cpu.pc() != END_ADDRESS && cpu.pc() != last_pc {
    last_pc = cpu.pc()

    //
    if cpu.mem[TEST_CASE] != last_test {
      last_test = cpu.mem[TEST_CASE]
      println("test case #$\{last_test.to_hex()} at $\{cpu.pc().to_hex()}")
    }

    //
    cycles += cpu.step()

    //
    if cycles > 95334912 {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }
  }

  //
  println("---")
  if cpu.pc() == END_ADDRESS {
    println("test passed")
  } else {
    println("test failed at $\{cpu.pc().to_hex()}")
    // cpu.dump()
  }

  //
  // println("cycles: \{cycles}")
}
