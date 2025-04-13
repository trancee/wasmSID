///|
/// This program is designed to test all opcodes of a 6502 emulator using all
/// addressing modes with focus on propper setting of the processor status
/// register bits.
/// 
/// https://github.com/Klaus2m5/6502_65C02_functional_tests/tree/master
///
pub fn dormann() -> Unit {
  dormann_functional()
  println("")
  dormann_interrupt()
  println("")
  dormann_decimal()
  // println("")
  // dormann_extended_opcodes()
}

///|
fn dormann_functional() -> Unit {
  let test_name = "6502_functional_test"
  let start_address = 0x0400
  let end_address = 0x3469 // 05-jan-2020
  let test_case_address = 0x0200
  let exact_cycles = 95340970

  //
  println("--- \{test_name}")

  //
  let content = match
    @fs.read_file_to_bytes?("tests/dormann/" + test_name + ".bin") {
    Ok(content) => content
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let cpu = CPU::new(
    pc=start_address,

    //
    address=0x0000,
    //
    data=content,

    //
    debug=DEBUG,
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
  let mut last_test = U8::u8(0xFF)

  //
  let mut cycles = 0
  while cpu.pc() != end_address {
    let last_pc = cpu.pc()

    //
    if cpu.mem[test_case_address] != last_test {
      if cpu.debug && last_test == 0x00 {
        println("")
      }
      last_test = cpu.mem[test_case_address]
      println("test case #$\{last_test.to_hex()} at $\{cpu.pc().to_hex()}")
    }

    //
    cycles += cpu.step()

    //
    if cycles > exact_cycles {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }

    //
    if cpu.pc() == last_pc {
      break
    }
  }

  //
  println("---")
  if cpu.pc() == end_address {
    println("test passed")
  } else {
    println("test failed at $\{cpu.pc().to_hex()}")
    // cpu.dump()
  }

  //
  // println("cycles: \{cycles}")
}

///|
fn dormann_interrupt() -> Unit {
  let test_name = "6502_interrupt_test"
  let start_address = 0x0400
  let end_address = 0x06F5 // 15-aug-2014
  let feedback_address = 0xBFFC
  let irq_bit = 1 << 0
  let nmi_bit = 1 << 1
  let nmi_count_address = 0x0200
  let irq_count_address = 0x0201
  let brk_count_address = 0x0202
  let exact_cycles = 2929

  //
  println("--- \{test_name}")

  //
  let content = match
    @fs.read_file_to_bytes?("tests/dormann/" + test_name + ".bin") {
    Ok(content) => content
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let cpu = CPU::new(
    pc=start_address,

    //
    address=0x0000,
    //
    data=content,

    //
    debug=DEBUG,
  )

  //
  cpu.trap(cpu.read16(@cpu.RESET), fn(_) {
    println("\u{1B}[31;1;6mRESET\u{1B}[0m")
    abort("RESET")
  })
  // cpu.trap(cpu.read16(@cpu.NMI), fn(_) {
  //   println("\u{1B}[31;1;6mNMI\u{1B}[0m")
  //   abort("NMI")
  // })
  // cpu.trap(cpu.read16(@cpu.IRQ), fn(_) {
  //   println("\u{1B}[31;1;6mIRQ\u{1B}[0m")
  //   abort("IRQ")
  // })

  //
  cpu.mem[feedback_address] = 0x00

  //
  let mut cycles = 0
  while cpu.pc() != end_address {
    let last_feedback = cpu.mem[feedback_address]
    let last_pc = cpu.pc()

    //
    cycles += cpu.step()

    //
    if cycles > exact_cycles {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }

    //
    let feedback = cpu.mem[feedback_address]
    if (feedback.clr(last_feedback) & nmi_bit) != 0 {
      cpu.nmi()
    } else if (feedback & irq_bit) != 0 {
      cpu.irq()
    }

    //
    if cpu.pc() == last_pc {
      break
    }
  }

  //
  println("---")
  println("NMI count: #$\{cpu.mem[nmi_count_address].to_hex()}")
  println("IRQ count: #$\{cpu.mem[irq_count_address].to_hex()}")
  println("BRK count: #$\{cpu.mem[brk_count_address].to_hex()}")
  println("---")
  if cpu.pc() == end_address {
    println("test passed")
  } else {
    println("test failed at $\{cpu.pc().to_hex()}")
    // cpu.dump()
  }

  //
  // println("cycles: \{cycles}")
}

///|
fn dormann_decimal() -> Unit {
  let test_name = "6502_decimal_test"
  let start_address = 0x0200
  let end_address = 0x024B
  let error_address = 0x000B
  let exact_cycles = 46089505

  //
  println("--- \{test_name}")

  //
  let content = match
    @fs.read_file_to_bytes?("tests/dormann/" + test_name + ".bin") {
    Ok(content) => content
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let cpu = CPU::new(
    pc=start_address,

    //
    address=start_address,
    //
    data=content,

    //
    debug=DEBUG,
  )

  //
  // cpu.trap(cpu.read16(@cpu.RESET), fn(_) {
  //   println("\u{1B}[31;1;6mRESET\u{1B}[0m")
  //   abort("RESET")
  // })
  cpu.trap(cpu.read16(@cpu.NMI), fn(_) {
    println("\u{1B}[31;1;6mNMI\u{1B}[0m")
    abort("NMI")
  })
  cpu.trap(cpu.read16(@cpu.IRQ), fn(_) {
    println("\u{1B}[31;1;6mIRQ\u{1B}[0m")
    abort("IRQ")
  })

  //
  let mut cycles = 0
  while cpu.pc() != end_address {
    let last_pc = cpu.pc()

    //
    cycles += cpu.step()

    //
    if cycles > exact_cycles {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }

    //
    if cpu.pc() == last_pc {
      break
    }
  }

  //
  println("---")
  println("error: #$\{cpu.mem[error_address].to_hex()}")
  println("---")
  if cpu.mem[error_address] == 0x00 {
    println("test passed")
    // cpu.dump()
  } else {
    println("test failed")
  }

  //
  // println("cycles: \{cycles}")
}

///|
fn dormann_extended_opcodes() -> Unit {
  let test_name = "65C02_extended_opcodes_test"
  let start_address = 0x0400
  let end_address = 0x24F1 // 04-dec-2017
  let test_case_address = 0x0202
  let exact_cycles = 95340970

  //
  println("--- \{test_name}")

  //
  let content = match
    @fs.read_file_to_bytes?("tests/dormann/" + test_name + ".bin") {
    Ok(content) => content
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("file not found")
    }
  }

  //
  let cpu = CPU::new(
    pc=start_address,

    //
    address=0x0000,
    //
    data=content,

    //
    debug=DEBUG,
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
  cpu.trap(cpu.read16(@cpu.IRQ), fn(_) {
    println("\u{1B}[31;1;6mIRQ\u{1B}[0m")
    abort("IRQ")
  })

  //
  let mut last_pc = U16::u16(0xFFFF)
  let mut last_test = U8::u8(0xFF)

  //
  let mut cycles = 0
  while cpu.pc() != end_address && cpu.pc() != last_pc {
    last_pc = cpu.pc()

    //
    if cpu.mem[test_case_address] != last_test {
      if cpu.debug && last_test == 0x00 {
        println("")
      }
      last_test = cpu.mem[test_case_address]
      println("test case #$\{last_test.to_hex()} at $\{cpu.pc().to_hex()}")
    }

    //
    cycles += cpu.step()

    //
    if cycles > exact_cycles {
      println("\u{1B}[31;1;6mcycles overflow\u{1B}[0m")
      abort("test failed")
    }
  }

  //
  println("---")
  if cpu.pc() == end_address {
    println("test passed")
  } else {
    println("test failed at $\{cpu.pc().to_hex()}")
    // cpu.dump()
  }

  //
  println("cycles: \{cycles}")
}
