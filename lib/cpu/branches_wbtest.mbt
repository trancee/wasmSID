// Tests

///|
test "BEQCanBranchForwardsWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BEQ,

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
  testBEQ!(t)
}

///|
test "BEQDoesNotBranchForwardsWhenZeroIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BEQ,

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
  testBEQ!(t)
}

///|
test "BEQCanBranchForwardsIntoANewPageWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFEFD,
    op: 1,
    ins: BEQ,

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
  testBEQ!(t)
}

///|
test "BEQCanBranchBackwardsWhenZeroIsSet" {
  let t = {
    // Input
    pc: 0xFFCC,
    op: 0xFE, // -2,
    ins: BEQ,

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
  testBEQ!(t)
}

///|
test "BEQCanBranchBackwardsWhenZeroIsSetFromAssembleCode" {
  let t = {
    // Input
    pc: 0xFFCC,
    op: 0x00,
    ins: BEQ,

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
  testBEQ!(t)
}

///|
test "BNECanBranchForwardsWhenZeroIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BNE,

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
  testBEQ!(t)
}

///|
test "BCSCanBranchForwardsWhenCarryFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BCS,

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
  testBEQ!(t)
}

///|
test "BCCCanBranchForwardsWhenCarryFlagIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BCC,

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
  testBEQ!(t)
}

///|
test "BMICanBranchForwardsWhenNegativeFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BMI,

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
  testBEQ!(t)
}

///|
test "BPLCanBranchForwardsWhenCarryNegativeIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BPL,

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
  testBEQ!(t)
}

///|
test "BVSCanBranchForwardsWhenOverflowFlagIsSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BVS,

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
  testBEQ!(t)
}

///|
test "BVCCanBranchForwardsWhenOverflowNegativeIsNotSet" {
  let t = {
    // Input
    pc: 0xFF00,
    op: 1,
    ins: BVC,

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
  testBEQ!(t)
}

// Test

///|
struct BEQTestData {
  // Input
  pc : Int
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

///|
fn testBEQ(t : BEQTestData) -> Unit!Error {
  let cpu = CPU::new!(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = t.z
  cpu.flags[V] = t.v
  cpu.flags[N] = t.n

  //
  if t.expectCycles == 5 {
    cpu.write(t.pc + 0, LDA_IM.to_int() |> u8)
    cpu.write(t.pc + 1, t.op)
    cpu.write(t.pc + 2, t.ins.to_int() |> u8)
    cpu.write(t.pc + 3, 0xFC) // -4)

    //
    let mut cycles = cpu.step()
    cycles += cpu.step()

    //
    assert_eq!(cycles, t.expectCycles)
  } else {
    cpu.write(t.pc + 0, t.ins.to_int() |> u8)
    cpu.write(t.pc + 1, t.op)

    //
    assert_eq!(cpu.step(), t.expectCycles)
  }

  //
  assert_eq!(cpu.pc, t.expectPC)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], t.expectV)
  assert_eq!(cpu.flags[N], t.expectN)
}
