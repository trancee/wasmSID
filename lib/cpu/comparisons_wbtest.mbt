// Tests

// Immediate

///|
test "CMPImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate!(t)
}

///|
test "CMPImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate!(t)
}

///|
test "CMPImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate!(t)
}

///|
test "CMPImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate!(t)
}

// Zero Page

///|
test "CMPZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage!(t)
}

///|
test "CMPZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage!(t)
}

///|
test "CMPZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage!(t)
}

///|
test "CMPZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage!(t)
}

// Zero Page X

///|
test "CMPZeroPageXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPageX!(t)
}

///|
test "CMPZeroPageXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPageX!(t)
}

///|
test "CMPZeroPageXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPageX!(t)
}

///|
test "CMPZeroPageXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPageX!(t)
}

// Absolute

///|
test "CMPAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute!(t)
}

///|
test "CMPAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute!(t)
}

///|
test "CMPAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute!(t)
}

///|
test "CMPAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute!(t)
}

// Absolute X

///|
test "CMPAbsoluteXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsoluteX!(t)
}

///|
test "CMPAbsoluteXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsoluteX!(t)
}

///|
test "CMPAbsoluteXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsoluteX!(t)
}

///|
test "CMPAbsoluteXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsoluteX!(t)
}

// Absolute Y

///|
test "CMPAbsoluteYCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsoluteY!(t)
}

///|
test "CMPAbsoluteYCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsoluteY!(t)
}

///|
test "CMPAbsoluteYCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsoluteY!(t)
}

///|
test "CMPAbsoluteYCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsoluteY!(t)
}

// Indirect X

///|
test "CMPIndirectXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareIndirectX!(t)
}

///|
test "CMPIndirectXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareIndirectX!(t)
}

///|
test "CMPIndirectXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareIndirectX!(t)
}

///|
test "CMPIndirectXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareIndirectX!(t)
}

// Indirect Y

///|
test "CMPIndirectYCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareIndirectY!(t)
}

///|
test "CMPIndirectYCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareIndirectY!(t)
}

///|
test "CMPIndirectYCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareIndirectY!(t)
}

///|
test "CMPIndirectYCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareIndirectY!(t)
}

// CPX Immediate

///|
test "CPXImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate!(t, r=X)
}

///|
test "CPXImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate!(t, r=X)
}

///|
test "CPXImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate!(t, r=X)
}

///|
test "CPXImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate!(t, r=X)
}

// CPY Immediate

///|
test "CPYImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate!(t, r=Y)
}

///|
test "CPYImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate!(t, r=Y)
}

///|
test "CPYImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate!(t, r=Y)
}

///|
test "CPYImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate!(t, r=Y)
}

// CPX Zero Page

///|
test "CPXZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage!(t, r=X)
}

///|
test "CPXZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage!(t, r=X)
}

///|
test "CPXZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage!(t, r=X)
}

///|
test "CPXZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage!(t, r=X)
}

// CPY Zero Page

///|
test "CPYZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage!(t, r=Y)
}

///|
test "CPYZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage!(t, r=Y)
}

///|
test "CPYZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage!(t, r=Y)
}

///|
test "CPYZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage!(t, r=Y)
}

// CPX Absolute

///|
test "CPXAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute!(t, r=X)
}

///|
test "CPXAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute!(t, r=X)
}

///|
test "CPXAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute!(t, r=X)
}

///|
test "CPXAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute!(t, r=X)
}

// CPY Absolute

///|
test "CPYAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute!(t, r=Y)
}

///|
test "CPYAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute!(t, r=Y)
}

///|
test "CPYAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute!(t, r=Y)
}

///|
test "CPYAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute!(t, r=Y)
}

// Test Cases

///|
fn testCompareTwoIdenticalValues() -> CMPTestData {
  {
    // Input
    pc: 0xFF00,
    r: 26,
    op: 26,

    // Output
    expectR: 26,
    expectC: true,
    expectZ: true,
    expectN: false,
  }
}

///|
fn testCompareALargePositiveToASmallPositive() -> CMPTestData {
  {
    // Input
    pc: 0xFF00,
    r: 48,
    op: 26,

    // Output
    expectR: 48,
    expectC: true,
    expectZ: false,
    expectN: false,
  }
}

///|
fn testCompareANegativeNumberToAPositive() -> CMPTestData {
  {
    // Input
    pc: 0xFF00,
    r: -126, // 0x82
    op: 26,

    // Output
    expectR: 0x82,
    expectC: true,
    expectZ: false,
    expectN: false,
  }
}

///|
fn testCompareTwoValuesThatResultInANegativeFlagSet() -> CMPTestData {
  {
    // Input
    pc: 0xFF00,
    r: 8,
    op: 26,

    // Output
    expectR: 8,
    expectC: false,
    expectZ: false,
    expectN: true,
  }
}

// Test

// enum Register {
//   A
//   X
//   Y
// }

///|
struct CMPTestData {
  // Input
  pc : Int
  r : UInt8 // a, x, y
  op : UInt8

  // Output
  expectR : UInt8 // a, x, y
  expectC : Bool
  expectZ : Bool
  expectN : Bool
}

///|
fn testCompareImmediate(t : CMPTestData, r~ : Register = A) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[r] = t.r
  // match r {
  //   A => cpu.registers[A] = t.r
  //   X => cpu.registers[X] = t.r
  //   Y => cpu.registers[Y] = t.r
  // }

  //
  match r {
    A => cpu.write(t.pc + 0, CMP.to_int())
    X => cpu.write(t.pc + 0, CPX.to_int())
    Y => cpu.write(t.pc + 0, CPY.to_int())
    SP => fail!("SP")
  }
  cpu.write(t.pc + 1, t.op)

  //
  assert_eq!(cpu.step(), 2)

  //
  assert_eq!(cpu.pc, t.pc + 2)

  //
  assert_eq!(cpu.registers[r], t.expectR._)
  // match r {
  //   A => assert_eq!(cpu.a, t.expectR)?
  //   X => assert_eq!(cpu.x, t.expectR)?
  //   Y => assert_eq!(cpu.y, t.expectR)?
  // }

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareZeroPage(t : CMPTestData, r~ : Register = A) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[r] = t.r
  // match r {
  //   A => cpu.a = t.r
  //   X => cpu.x = t.r
  //   Y => cpu.y = t.r
  // }

  //
  match r {
    A => cpu.write(t.pc + 0, CMP_ZP.to_int())
    X => cpu.write(t.pc + 0, CPX_ZP.to_int())
    Y => cpu.write(t.pc + 0, CPY_ZP.to_int())
    SP => fail!("SP")
  }
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x0042, t.op)

  //
  assert_eq!(cpu.step(), 3)

  //
  assert_eq!(cpu.pc, t.pc + 2)

  //
  assert_eq!(cpu.registers[r], t.expectR._)
  // match r {
  //   A => assert_eq!(cpu.a, t.expectR)?
  //   X => assert_eq!(cpu.x, t.expectR)?
  //   Y => assert_eq!(cpu.y, t.expectR)?
  // }

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareZeroPageX(t : CMPTestData) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.r
  cpu.registers[X] = 0x04

  //
  cpu.write(t.pc + 0, CMP_ZPX.to_int())
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x0042 + cpu.registers[X]._, t.op)

  //
  assert_eq!(cpu.step(), 4)

  //
  assert_eq!(cpu.pc, t.pc + 2)

  //
  assert_eq!(cpu.registers[A], t.expectR._)
  assert_eq!(cpu.registers[X], 0x04)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareAbsolute(t : CMPTestData, r~ : Register = A) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[r] = t.r
  // match r {
  //   A => cpu.a = t.r
  //   X => cpu.x = t.r
  //   Y => cpu.y = t.r
  // }

  //
  match r {
    A => cpu.write(t.pc + 0, CMP_ABS.to_int())
    X => cpu.write(t.pc + 0, CPX_ABS.to_int())
    Y => cpu.write(t.pc + 0, CPY_ABS.to_int())
    SP => fail!("SP")
  }
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  assert_eq!(cpu.step(), 4)

  //
  assert_eq!(cpu.pc, t.pc + 3)

  //
  assert_eq!(cpu.registers[r], t.expectR._)
  // match r {
  //   A => assert_eq!(cpu.a, t.expectR)?
  //   X => assert_eq!(cpu.x, t.expectR)?
  //   Y => assert_eq!(cpu.y, t.expectR)?
  // }

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareAbsoluteX(t : CMPTestData) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.r
  cpu.registers[X] = 0x04

  //
  cpu.write(t.pc + 0, CMP_ABSX.to_int())
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[X]._, t.op)

  //
  assert_eq!(cpu.step(), 4)

  //
  assert_eq!(cpu.pc, t.pc + 3)

  //
  assert_eq!(cpu.registers[A], t.expectR._)
  assert_eq!(cpu.registers[X], 0x04)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareAbsoluteY(t : CMPTestData) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.r
  cpu.registers[Y] = 0x04

  //
  cpu.write(t.pc + 0, CMP_ABSY.to_int())
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[Y]._, t.op)

  //
  assert_eq!(cpu.step(), 4)

  //
  assert_eq!(cpu.pc, t.pc + 3)

  //
  assert_eq!(cpu.registers[A], t.expectR._)
  assert_eq!(cpu.registers[Y], 0x04)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareIndirectX(t : CMPTestData) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.r
  cpu.registers[X] = 0x04

  //
  cpu.write(t.pc + 0, CMP_INDX.to_int())
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x42 + cpu.registers[X]._ + 0, 0x00)
  cpu.write(0x42 + cpu.registers[X]._ + 1, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  assert_eq!(cpu.step(), 6)

  //
  assert_eq!(cpu.pc, t.pc + 2)

  //
  assert_eq!(cpu.registers[A], t.expectR._)
  assert_eq!(cpu.registers[X], 0x04)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}

///|
fn testCompareIndirectY(t : CMPTestData) -> Unit!Error {
  let cpu = CPU::new(pc=t.pc)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  let v = cpu.flags[V]
  // let n = cpu.flags[N]

  //
  cpu.flags[C] = not(t.expectC)
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.r
  cpu.registers[Y] = 0x04

  //
  cpu.write(t.pc + 0, CMP_INDY.to_int())
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x42 + cpu.registers[X]._ + 0, 0x00)
  cpu.write(0x42 + cpu.registers[X]._ + 1, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[Y]._, t.op)

  //
  assert_eq!(cpu.step(), 5)

  //
  assert_eq!(cpu.pc, t.pc + 2)

  //
  assert_eq!(cpu.registers[A], t.expectR._)
  assert_eq!(cpu.registers[Y], 0x04)

  //
  assert_eq!(cpu.flags[C], t.expectC)
  assert_eq!(cpu.flags[Z], t.expectZ)
  assert_eq!(cpu.flags[I], i)
  assert_eq!(cpu.flags[D], d)
  assert_eq!(cpu.flags[B], b)
  assert_eq!(cpu.flags[U], u)
  assert_eq!(cpu.flags[V], v)
  assert_eq!(cpu.flags[N], t.expectN)
}
