// Tests

test "CanJumpToASubroutineAndJumpBackAgain" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let a = cpu.registers[A]
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, JSR.to_int())
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  cpu.write(0x8000, RTS.to_int())

  //
  cpu.write(0xFF00 + 3, LDA_IM.to_int())
  cpu.write(0xFF00 + 4, 0x42)

  //
  let mut cycles = cpu.step()

  //
  assert_eq!(cycles, 6)
  assert_eq!(cpu.pc, 0x8000)
  assert_eq!(cpu.registers[A], a)
  assert_eq!(cpu.registers[SP], sp - 2)
  assert_eq!(cpu.flags, p)

  //
  cycles += cpu.step()

  //
  assert_eq!(cycles, 6 + 6)
  assert_eq!(cpu.pc, 0xFF00 + 3)
  assert_eq!(cpu.registers[A], a)
  assert_eq!(cpu.registers[SP], sp)
  assert_eq!(cpu.flags, p)

  //
  cycles += cpu.step()

  //
  assert_eq!(cycles, 6 + 6 + 2)
  assert_eq!(cpu.pc, 0xFF00 + 5)
  assert_eq!(cpu.registers[A], 0x42)
  assert_eq!(cpu.registers[SP], sp)
  assert_eq!(cpu.flags, p)
}

test "JumpAbsoluteCanJumpToAnNewLocationInTheProgram" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, JMP_ABS.to_int())
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  let cycles = cpu.step()

  //
  assert_eq!(cycles, 3)
  assert_eq!(cpu.pc, 0x8000)
  assert_eq!(cpu.registers[SP], sp)
  assert_eq!(cpu.flags, p)
}

test "JumpIndirectCanJumpToAnNewLocationInTheProgram" {
  let cpu = CPU::new(pc=0xFF00)

  //
  let sp = cpu.registers[SP]
  let p = cpu.flags

  //
  cpu.write(0xFF00 + 0, JMP_IND.to_int())
  cpu.write(0xFF00 + 1, 0x00)
  cpu.write(0xFF00 + 2, 0x80)

  //
  cpu.write(0x8000 + 0, 0x00)
  cpu.write(0x8000 + 1, 0x90)

  //
  let cycles = cpu.step()

  //
  assert_eq!(cycles, 5)
  assert_eq!(cpu.pc, 0x9000)
  assert_eq!(cpu.registers[SP], sp)
  assert_eq!(cpu.flags, p)
}
