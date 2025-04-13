///|
const PATH = "tests/lorenz/"

///|
const TESTCASE = "sbxb" // "start" // "sbxb"

///|
pub fn lorenz() -> Unit {
  //
  let c64 = C64::new(realSID=true, debug=false)

  //
  setup(c64)

  //
  load_testcase(c64, TESTCASE)

  //
  let mut cycles = 0
  while c64.pc() != 0x0000 {
    // c64.set_debug(cycles >= 104100 && cycles < 104300)
    cycles += c64.emulate()
    // println(cycles)
    if cycles > 1000000000 {
      println("\u{1B}[31;1;6mBREAK LOOP\u{1B}[0m")
      break // safety check to avoid infinite loop
    }
  }
}

///|
fn load_testcase(c64 : C64, testcase : String, pc? : UInt16) -> Unit {
  let content = @fs.read_file_to_bytes?(PATH + testcase)
  match content {
    Ok(content) => reset(c64, content, pc?)
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("test not found")
    }
  }
}

///|
fn setup(c64 : C64) -> Unit {
  let builder = StringBuilder::new()

  // Print Character
  c64.trap(0xFFD2, fn(cpu) {
    // Set $030C = 0
    // Print PETSCII character corresponding to value of A
    // Pop return address from stack
    // Set PC to return address
    // Re-start the CPU

    c64[R6510] = 0x00
    c64[SAREG] = 0x00 // Storage for 6502 .A Register

    //
    let a = cpu.a()._
    match a {
      13 => {
        println("\u{1B}[33m\{builder}\u{1B}[0m")
        builder.reset()
      }
      14 => builder.write_string("") // text mode
      145 => builder.write_string("\u{1B}[1A\u{1B}[1m") // ↑ up arrow
      147 => builder.write_string("\u{1B}c") // clear
      _ => {
        let a = if a >= 0xC1 && a <= 0xDA {
          a - 0xC1 + 65
        } else if a >= 0x41 && a <= 0x5A {
          a - 0x41 + 97
        } else if a < 32 || a >= 127 {
          46
        } else {
          a
        }
        builder.write_char(Char::from_int(a))
      }
    }
  })

  // Load
  c64.trap(0xE16F, fn(_) {
    // $BB is PETSCII filename address, low byte
    // $BC is PETSCII filename address, high byte
    // $B7 is PETSCII filename length
    // Load the file
    // Pop return address from stack
    // Set PC to $0816
    // Re-start the CPU

    let testcase = builder.to_string()
    load_testcase(c64, testcase, pc=0x0816)
  })

  // Scan Keyboard
  // c64.trap(0xFFE4, fn(cpu) {
  //   // Set A to 3
  //   // Pop return address from stack
  //   // Set PC to return address
  //   // Re-start the CPU

  //   cpu.registers[A] = 0x03
  //   println("\u{1B}[31;1;6mSCAN KEYBOARD\u{1B}[0m")
  //   // println("scan keyboard")
  //   // abort("scan keyboard")
  // })

  // Exit
  c64.trap(0x8000, fn(_) {
    println("{\{c64.cycles}} \u{1B}[31;1;6mWARM \{builder}\u{1B}[0m")
    abort("test failed")
  })
  c64.trap(0xA474, fn(_) {
    println("{\{c64.cycles}} \u{1B}[31;1;6m[READY \{builder}\u{1B}[0m")
    abort("test failed")
  })
}

///|
fn reset(c64 : C64, data : Bytes, pc? : UInt16) -> Unit {
  let addr = c64.load(data, has_load_address=true)

  //
  let irq : Bytes = [
    // FF48  48        PHA
    0x48,

    // FF49  8A        TXA
     0x8A,
    // FF4A  48        PHA 
     0x48,

    // FF4B  98        TYA
     0x98,
    // FF4C  48        PHA 
     0x48,

    // FF4D  BA        TSX
     0xBA,
    // FF4E  BD 04 01  LDA $0104,X
     0xBD, 0x04, 0x01,

    // FF51  29 10     AND #$10   
     0x29, 0x10,

    // FF53  F0 03     BEQ $FF58
     0xF0, 0x03,
    // FF55  6C 16 03  JMP ($0316)
     0x6C, 0x16, 0x03,
    // FF58  6C 14 03  JMP ($0314)
     0x6C, 0x14, 0x03,
  ]
  let _ = c64.load(irq, offset=0xFF48)

  //
  c64[R6510] = 0x00

  //
  c64[UNUSED] = 0x00

  //
  c64.write_word(WARM, 0x8000) // 0xA002
  c64.write_word(PC, 0x7FFF) // 0x01FE
  c64.write_word(IRQ, 0xFF48) // 0xFFFE

  // Put RTSes in some of the stubbed calls
  c64[CHROUT] = 0x60 // 0xFFD2
  c64[CARTROM] = 0x60 // 0x8000
  c64[READY] = 0x60 // 0xA474

  // NOP the loading routine
  c64.write(0xE16F, 0xEA)

  // scan keyboard is LDA #3: RTS
  c64.write_array(GETIN, [0xA9, 0x03, 0x60]) // 0xFFE4

  //
  // c64.initCPU(pc=pc.or(addr))
  c64.initCPU(pc=addr)

  //
  c64.clear_flags()
  c64.set_interrupt_flag()
}
