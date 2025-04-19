// https://github.com/pmonta/FPGA-netlist-tools/blob/master/6502-test-code/AllSuiteA.asm

///|
test {
  let data = @fs.read_file_to_bytes?("lib/cpu/AllSuiteA.bin")
  assert_eq!(data.is_ok(), true)
  match data {
    Ok(data) => {
      let cpu = CPU::new!(pc=0x4000, data~, debug=false)
      let mut cycles = 0
      while cpu.pc() != 0x45C0 {
        cycles += cpu.step()
        if cycles > 10000 {
          break // safety check to avoid infinite loop
        }
      }
      assert_eq!(cpu[0x0210], 0xFF)
    }
    Err(error) => println(error)
  }
}
