///| https://github.com/SingleStepTests/65x02
const TEST_PATH = "tests/65x02/6502/v1/"

///|
pub fn instructions() -> Unit! {
  // BRK, JMP, JSR
  // for test_opcode in [0x00, 0x4C, 0x6C, 0x20] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // RTI, RTS
  // for test_opcode in [0x40, 0x60] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
  // for test_opcode in [0x90, 0xB0, 0xF0, 0x30, 0xD0, 0x10, 0x50, 0x70] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ORA
  // for test_opcode in [0x09, 0x0D, 0x1D, 0x19, 0x05, 0x15, 0x01, 0x11] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // JAM
  // for
  //   test_opcode in [
  //     0x02, 0x12, 0x22, 0x32, 0x42, 0x52, 0x62, 0x72, 0x92, 0xB2, 0xD2, 0xF2,
  //   ] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // SLO
  // for test_opcode in [0x0F, 0x1F, 0x1B, 0x07, 0x17, 0x03, 0x13] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // NOP
  // for
  //   test_opcode in [
  //     0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA, 0x80, 0x82, 0x89, 0xC2, 0xE2, 0x0C,
  //     0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC, 0x04, 0x44, 0x64, 0x14, 0x34, 0x54, 0x74,
  //     0xD4, 0xF4,
  //   ] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ASL
  // for test_opcode in [0x0A, 0x0E, 0x1E, 0x06, 0x16] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // PHP, PLP, PHA, PLA
  // for test_opcode in [0x08, 0x28, 0x48, 0x68] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ANC
  // for test_opcode in [0x0B, 0x2B] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // CLC, SEC, CLI, SEI, CLV, CLD, SED
  // for test_opcode in [0x18, 0x38, 0x58, 0x78, 0xB8, 0xD8, 0xF8] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // AND
  // for test_opcode in [0x29, 0x2D, 0x3D, 0x39, 0x25, 0x35, 0x21, 0x31] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // RLA
  // for test_opcode in [0x2F, 0x3F, 0x3B, 0x27, 0x37, 0x23, 0x33] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // RRA
  // for test_opcode in [0x6F, 0x7F, 0x7B, 0x67, 0x77, 0x63, 0x73] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // BIT
  // for test_opcode in [0x2C, 0x24] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ROL
  // for test_opcode in [0x2A, 0x2E, 0x3E, 0x26, 0x36] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // EOR
  // for test_opcode in [0x49, 0x4D, 0x5D, 0x59, 0x45, 0x55, 0x41, 0x51] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // SRE
  // for test_opcode in [0x4F, 0x5F, 0x5B, 0x47, 0x57, 0x43, 0x53] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // LSR
  // for test_opcode in [0x4A, 0x4E, 0x5E, 0x46, 0x56] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ASR
  // for test_opcode in [0x4B] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ADC
  // for test_opcode in [0x69, 0x6D, 0x7D, 0x79, 0x65, 0x75, 0x61, 0x71] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ROR
  // for test_opcode in [0x6A, 0x6E, 0x7E, 0x66, 0x76] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ARR
  // for test_opcode in [0x6B] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // STA
  // for test_opcode in [0x8D, 0x9D, 0x99, 0x85, 0x95, 0x81, 0x91] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // SAX
  // for test_opcode in [0x8F, 0x87, 0x97, 0x83] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // STY
  // for test_opcode in [0x8C, 0x84, 0x94] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // DEY
  // for test_opcode in [0x88] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // TAX, TAY, TSX, TXA, TXS, TYA
  // for test_opcode in [0xAA, 0xA8, 0xBA, 0x8A, 0x9A, 0x98] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // XAA
  // for test_opcode in [0x8B] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // SHA, SHS, SHX, SHY
  // for test_opcode in [0x9F, 0x93, 0x9B, 0x9E, 0x9C] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // LAS, LAX, LDA, LDX, LDY
  // for
  //   test_opcode in [
  //     0xBB, 0xAB, 0xAF, 0xBF, 0xA7, 0xB7, 0xA3, 0xB3, 0xA9, 0xAD, 0xBD, 0xB9, 0xA5,
  //     0xB5, 0xA1, 0xB1, 0xA2, 0xAE, 0xBE, 0xA6, 0xB6, 0xA0, 0xAC, 0xBC, 0xA4, 0xB4,
  //   ] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // CMP, CPX, CPY
  // for
  //   test_opcode in [
  //     0xC9, 0xCD, 0xDD, 0xD9, 0xC5, 0xD5, 0xC1, 0xD1, 0xE0, 0xEC, 0xE4,
  //   ] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // DCP, DEC, DEX, DEY
  // for
  //   test_opcode in [
  //     0xCF, 0xDF, 0xDB, 0xC7, 0xD7, 0xC3, 0xD3, 0xCE, 0xDE, 0xC6, 0xD6, 0xCA, 0x88,
  //   ] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // INC, INX, INY
  // for test_opcode in [0xEE, 0xFE, 0xE6, 0xF6, 0xE8, 0xC8] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // SBC, SBX
  // for
  //   test_opcode in [0xE9, 0xEB, 0xED, 0xFD, 0xF9, 0xE5, 0xF5, 0xE1, 0xF1, 0xCB] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }
  // ISC
  // for test_opcode in [0xEF, 0xFF, 0xFB, 0xE7, 0xF7, 0xE3, 0xF3] {
  //   instruction_test!(u8(test_opcode).to_hex().to_lower())
  // }

  for test_opcode in 0x00..<0x100 {
    instruction_test!(test_opcode)
  }
}

///|
fn instruction_test(test_opcode : Int) -> Unit! {
  let opcode = @cpu.instructions[test_opcode]
  let test_opcode = u8(test_opcode)
  let testname = "#$\{test_opcode} \{opcode.0}"
  println(testname + "\u{1B}[1A")

  //
  let tests : Array[Test] = match
    @fs.read_file_to_string?(
      TEST_PATH + "\{test_opcode.to_hex().to_lower()}.json",
    ) {
    Ok(data) => @json.from_json!(@json.parse!(data))
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  for i, testcase in tests {
    println(
      testname +
      " " +
      "[\{testcase.name}]" +
      " " +
      "#\{i}" +
      "\u{1B}[s\u{1B}[1A",
    )

    // println(testcase.initial)
    // println(testcase.final)
    // println(testcase.cycles)
    run!(testcase)
  }

  //
  println("\u{1B}[u" + " " + "\u{1B}[32;1m✔️\u{1B}[0m")
}

///|
fn run(testcase : Test) -> Unit! {
  //
  let cycles : Array[(UInt16, UInt8, String)] = []

  //
  let cpu = CPU::new!(
    pc=testcase.initial.pc,

    //
    registers=@cpu.Registers::new(
      sp=testcase.initial.s,
      a=testcase.initial.a,
      x=testcase.initial.x,
      y=testcase.initial.y,
    ),
    flags=@cpu.Flags::new(flags=testcase.initial.p),

    //
    debug~,
  )
  for data in testcase.initial.ram {
    cpu.mem[data.0._] = data.1
  }
  cpu.set_read(fn(address : UInt16, _ : Bool) -> UInt8 {
    // println("(\{address}, \{cpu.mem[address._]}, \"read\")")
    cycles.push((address, cpu.mem[address._], "read"))

    //
    cpu.mem[address._]
  })
  cpu.set_write(fn(address : UInt16, value : UInt8, _ : Bool) -> Unit {
    // println("(\{address}, \{value}, \"write\")")
    cycles.push((address, value, "write"))

    //
    cpu.mem[address._] = value
  })

  //
  let cycle = cpu.step()

  //
  verify!("cycles", testcase, testcase.cycles.length(), cycles.length(), cycles)
  verify!("cycle", testcase, cycle, cycles.length(), cycles)

  //
  for i in 0..<testcase.cycles.length() {
    // println("\{i} \{testcase.cycles.length()} \{cycles.length()}")
    // let ok = testcase.cycles[i] == cycles[i]
    // let result = match ok {
    //   true => "\u{1B}[32;1m✔️\u{1B}[0m"
    //   false => "\u{1B}[31;1;6m❌\u{1B}[0m"
    // }
    // println("\{testcase.cycles[i]} \t \{cycles[i]} \t \{result}")
    verify!("cycles", testcase, testcase.cycles[i], cycles[i], cycles)
  }

  //
  verify!("PC", testcase, testcase.final.pc, cpu.pc, cycles)
  verify!("S", testcase, testcase.final.s, cpu.registers[SP], cycles)
  verify!("A", testcase, testcase.final.a, cpu.registers[A], cycles)
  verify!("X", testcase, testcase.final.x, cpu.registers[X], cycles)
  verify!("Y", testcase, testcase.final.y, cpu.registers[Y], cycles)
  verify!("P", testcase, testcase.final.p, cpu.flags.get(), cycles)
  for data in testcase.final.ram {
    let (address, value) = data
    verify!("\{address}", testcase, value, cpu.mem[address._], cycles)
  }

  //
  // println("")
}

///|
fn verify[T : Eq + Show](
  name : String,
  testcase : Test,
  a : T,
  b : T,
  cycles : Array[(UInt16, UInt8, String)],
  loc~ : SourceLoc = _
) -> Unit! {
  if a != b {
    println("\u{1B}[u" + " " + "\u{1B}[31;1m❌ \{name} → $\{a} ≠ $\{b}\u{1B}[0m")
    println("--")
    println(testcase.initial)
    println(testcase.final)
    println("--")
    println(testcase.cycles)
    println(cycles)
    println("--")
    raise Failure("\{loc}")
  }

  //
  assert_eq!(a, b, loc~)
}

///|
struct State {
  pc : UInt16
  s : UInt8
  a : UInt8
  x : UInt8
  y : UInt8
  p : UInt8
  ram : Array[(UInt16, UInt8)]
} derive(FromJson, Show, Eq)

///|
struct Test {
  name : String
  initial : State
  final : State
  cycles : Array[(UInt16, UInt8, String)]
} derive(FromJson, Show, Eq)
