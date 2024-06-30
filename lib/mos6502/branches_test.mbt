// Tests

test "BEQCanBranchForwardsWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BEQ,

    //
    c: false,
    z: true,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: true,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BEQDoesNotBranchForwardsWhenZeroIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BEQ,

    //
    c: false,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF02,
    expectCycles: 2,

    // Flags
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BEQCanBranchForwardsIntoANewPageWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFEFD,
    op: 1,
    ins: INS_BEQ,

    //
    c: false,
    z: true,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF00,
    expectCycles: 4,

    //
    expectC: false,
    expectZ: true,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BEQCanBranchBackwardsWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFFCC,
    op: -2,
    ins: INS_BEQ,

    //
    c: false,
    z: true,
    v: false,
    n: false,

    // Output
    expectPC: 0xFFCC,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: true,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BEQCanBranchBackwardsWhenZeroIsSetFromAssembleCode" {
  let t = {
    // Input
    pc: 0xFFCC,
    op: 0x00,
    ins: INS_BEQ,

    //
    c: false,
    z: true,
    v: false,
    n: false,

    // Output
    expectPC: 0xFFCC,
    expectCycles: 2 + 3,

    //
    expectC: false,
    expectZ: true,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BNECanBranchForwardsWhenZeroIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BNE,

    //
    c: false,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BCSCanBranchForwardsWhenCarryFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BCS,

    //
    c: true,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: true,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BCCCanBranchForwardsWhenCarryFlagIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BCC,

    //
    c: false,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BMICanBranchForwardsWhenNegativeFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BMI,

    //
    c: false,
    z: false,
    v: false,
    n: true,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: true,
  }
  testBEQ(t)?
}

test "BPLCanBranchForwardsWhenCarryNegativeIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BPL,

    //
    c: false,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

test "BVSCanBranchForwardsWhenOverflowFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BVS,

    //
    c: false,
    z: false,
    v: true,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: true,
    expectN: false,
  }
  testBEQ(t)?
}

test "BVCCanBranchForwardsWhenOverflowNegativeIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: INS_BVC,

    //
    c: false,
    z: false,
    v: false,
    n: false,

    // Output
    expectPC: 0xFF03,
    expectCycles: 3,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: false,
  }
  testBEQ(t)?
}

// Test

struct BEQTestData {
  // Input
  pc : UInt16
  op : UInt8
  ins : Instruction

  //
  c : Bool
  z : Bool
  v : Bool
  n : Bool

  // Output
  expectPC : UInt16
  expectCycles : Int

  //
  expectC : Bool
  expectZ : Bool
  expectV : Bool
  expectN : Bool
}

fn testBEQ(t : BEQTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  // let v = cpu.v
  // let n = cpu.n
  //

  cpu.c = t.c
  cpu.z = t.z
  cpu.v = t.v
  cpu.n = t.n
  //

  if t.expectCycles == 5 {
    cpu.write(t.pc + 0, U8::u8(INS_LDA_IM))
    cpu.write(t.pc + 1, t.op)
    cpu.write(t.pc + 2, U8::u8(t.ins))
    cpu.write(t.pc + 3, -4)

    //
    let mut cycles = cpu.step()
    cycles += cpu.step()

    //
    @assertion.assert_eq(cycles, t.expectCycles)?
  } else {
    cpu.write(t.pc + 0, U8::u8(t.ins))
    cpu.write(t.pc + 1, t.op)

    //
    @assertion.assert_eq(cpu.step(), t.expectCycles)?
  }

  //
  @assertion.assert_eq(cpu.pc, t.expectPC)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, t.expectV)?
  @assertion.assert_eq(cpu.n, t.expectN)
}
