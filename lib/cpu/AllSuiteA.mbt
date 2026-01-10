// https://github.com/pmonta/FPGA-netlist-tools/blob/master/6502-test-code/AllSuiteA.asm

///|
test {
  let data = @fs.read_file_to_bytes("lib/cpu/AllSuiteA.bin") catch {
    error => {
      println(error)
      abort("file not found")
    }
  }
  let cpu = CPU::new(pc=0x4000, data~, debug=false)
  let mut cycles = 0
  while cpu.pc() != 0x45C0 {
    cycles += cpu.step()
    if cycles > 10000 {
      break // safety check to avoid infinite loop
    }
  }
  // EXPECTED FINAL RESULTS: $0210 = FF
  // (any other number will be the 
  //  test that failed)
  assert_eq(cpu[0x0210], 0xFF)
}

///|
test (b : @bench.T) {
  let data = @fs.read_file_to_bytes("lib/cpu/AllSuiteA.bin") catch {
    error => {
      println(error)
      abort("file not found")
    }
  }
  let cpu = CPU::new(pc=0x4000, data~, debug=false)
  b.bench(fn() {
    cpu.reset()
    while cpu.pc() != 0x45C0 {
      b.keep(cpu.step())
    }
  })
}
