// Tests

test "CanJumpToASubroutineAndJumpBackAgain" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let a = cpu.registers[A]
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, U8::u8(JSR))
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  cpu.write(0x8000, U8::u8(RTS))

  //
  cpu.write(0xFF00 + 3, U8::u8(LDA_IM))
  cpu.write(0xFF00 + 4, 0x42)

  //
  let mut cycles = cpu.step()

  //
  @test.eq(cycles, 6)!
  @test.eq(cpu.pc, 0x8000)!
  @test.eq(cpu.registers[A], a)!
  @test.eq(cpu.registers[SP], sp - 2)!
  @test.eq(cpu.flags, p)!

  //
  cycles += cpu.step()

  //
  @test.eq(cycles, 6 + 6)!
  @test.eq(cpu.pc, 0xFF00 + 3)!
  @test.eq(cpu.registers[A], a)!
  @test.eq(cpu.registers[SP], sp)!
  @test.eq(cpu.flags, p)!

  //
  cycles += cpu.step()

  //
  @test.eq(cycles, 6 + 6 + 2)!
  @test.eq(cpu.pc, 0xFF00 + 5)!
  @test.eq(cpu.registers[A], 0x42)!
  @test.eq(cpu.registers[SP], sp)!
  @test.eq(cpu.flags, p)!
}

test "JumpAbsoluteCanJumpToAnNewLocationInTheProgram" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, U8::u8(JMP_ABS))
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  let cycles = cpu.step()

  //
  @test.eq(cycles, 3)!
  @test.eq(cpu.pc, 0x8000)!
  @test.eq(cpu.registers[SP], sp)!
  @test.eq(cpu.flags, p)!
}

test "JumpIndirectCanJumpToAnNewLocationInTheProgram" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, U8::u8(JMP_IND))
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  cpu.write(0x8000 + 0, 0x00)
  cpu.write(0x8000 + 1, 0x90)

  //
  let cycles = cpu.step()

  //
  @test.eq(cycles, 5)!
  @test.eq(cpu.pc, 0x9000)!
  @test.eq(cpu.registers[SP], sp)!
  @test.eq(cpu.flags, p)!
}
