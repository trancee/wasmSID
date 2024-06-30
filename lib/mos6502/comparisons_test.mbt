// Tests

// Immediate

test "CMPImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate(t)?
}

test "CMPImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate(t)?
}

test "CMPImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate(t)?
}

test "CMPImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate(t)?
}

// Zero Page

test "CMPZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage(t)?
}

test "CMPZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage(t)?
}

test "CMPZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage(t)?
}

test "CMPZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage(t)?
}

// Zero Page X

test "CMPZeroPageXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPageX(t)?
}

test "CMPZeroPageXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPageX(t)?
}

test "CMPZeroPageXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPageX(t)?
}

test "CMPZeroPageXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPageX(t)?
}

// Absolute

test "CMPAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute(t)?
}

test "CMPAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute(t)?
}

test "CMPAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute(t)?
}

test "CMPAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute(t)?
}

// Absolute X

test "CMPAbsoluteXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsoluteX(t)?
}

test "CMPAbsoluteXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsoluteX(t)?
}

test "CMPAbsoluteXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsoluteX(t)?
}

test "CMPAbsoluteXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsoluteX(t)?
}

// Absolute Y

test "CMPAbsoluteYCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsoluteY(t)?
}

test "CMPAbsoluteYCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsoluteY(t)?
}

test "CMPAbsoluteYCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsoluteY(t)?
}

test "CMPAbsoluteYCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsoluteY(t)?
}

// Indirect X

test "CMPIndirectXCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareIndirectX(t)?
}

test "CMPIndirectXCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareIndirectX(t)?
}

test "CMPIndirectXCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareIndirectX(t)?
}

test "CMPIndirectXCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareIndirectX(t)?
}

// Indirect Y

test "CMPIndirectYCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareIndirectY(t)?
}

test "CMPIndirectYCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareIndirectY(t)?
}

test "CMPIndirectYCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareIndirectY(t)?
}

test "CMPIndirectYCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareIndirectY(t)?
}

// CPX Immediate

test "CPXImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate(t, r=X)?
}

test "CPXImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate(t, r=X)?
}

test "CPXImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate(t, r=X)?
}

test "CPXImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate(t, r=X)?
}

// CPY Immediate

test "CPYImmediateCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareImmediate(t, r=Y)?
}

test "CPYImmediateCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareImmediate(t, r=Y)?
}

test "CPYImmediateCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareImmediate(t, r=Y)?
}

test "CPYImmediateCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareImmediate(t, r=Y)?
}

// CPX Zero Page

test "CPXZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage(t, r=X)?
}

test "CPXZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage(t, r=X)?
}

test "CPXZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage(t, r=X)?
}

test "CPXZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage(t, r=X)?
}

// CPY Zero Page

test "CPYZeroPageCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareZeroPage(t, r=Y)?
}

test "CPYZeroPageCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareZeroPage(t, r=Y)?
}

test "CPYZeroPageCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareZeroPage(t, r=Y)?
}

test "CPYZeroPageCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareZeroPage(t, r=Y)?
}

// CPX Absolute

test "CPXAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute(t, r=X)?
}

test "CPXAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute(t, r=X)?
}

test "CPXAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute(t, r=X)?
}

test "CPXAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute(t, r=X)?
}

// CPY Absolute

test "CPYAbsoluteCanCompareTwoIdenticalValues" {
  let t = testCompareTwoIdenticalValues()
  testCompareAbsolute(t, r=Y)?
}

test "CPYAbsoluteCanCompareALargePositiveToASmallPositive" {
  let t = testCompareALargePositiveToASmallPositive()
  testCompareAbsolute(t, r=Y)?
}

test "CPYAbsoluteCanCompareANegativeNumberToAPositive" {
  let t = testCompareANegativeNumberToAPositive()
  testCompareAbsolute(t, r=Y)?
}

test "CPYAbsoluteCanCompareTwoValuesThatResultInANegativeFlagSet" {
  let t = testCompareTwoValuesThatResultInANegativeFlagSet()
  testCompareAbsolute(t, r=Y)?
}

// Test Cases

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

fn testCompareANegativeNumberToAPositive() -> CMPTestData {
  {
    // Input
    pc: 0xFF00,
    r: u8(-126), // 0x82
    op: 26,

    // Output
    expectR: 0x82,
    expectC: true,
    expectZ: false,
    expectN: false,
  }
}

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

enum Register {
  A
  X
  Y
}

struct CMPTestData {
  // Input
  pc : UInt16
  r : UInt8 // a, x, y
  op : UInt8

  // Output
  expectR : UInt8 // a, x, y
  expectC : Bool
  expectZ : Bool
  expectN : Bool
}

fn testCompareImmediate(
  t : CMPTestData,
  ~r : Register = A
) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  match r {
    A => cpu.a = t.r
    X => cpu.x = t.r
    Y => cpu.y = t.r
  }

  //
  match r {
    A => cpu.write(t.pc + 0, U8::u8(INS_CMP))
    X => cpu.write(t.pc + 0, U8::u8(INS_CPX))
    Y => cpu.write(t.pc + 0, U8::u8(INS_CPY))
  }
  cpu.write(t.pc + 1, t.op)

  //
  @assertion.assert_eq(cpu.step(), 2)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 2)?

  //
  match r {
    A => @assertion.assert_eq(cpu.a, t.expectR)?
    X => @assertion.assert_eq(cpu.x, t.expectR)?
    Y => @assertion.assert_eq(cpu.y, t.expectR)?
  }

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareZeroPage(
  t : CMPTestData,
  ~r : Register = A
) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  match r {
    A => cpu.a = t.r
    X => cpu.x = t.r
    Y => cpu.y = t.r
  }

  //
  match r {
    A => cpu.write(t.pc + 0, U8::u8(INS_CMP_ZP))
    X => cpu.write(t.pc + 0, U8::u8(INS_CPX_ZP))
    Y => cpu.write(t.pc + 0, U8::u8(INS_CPY_ZP))
  }
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x0042, t.op)

  //
  @assertion.assert_eq(cpu.step(), 3)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 2)?

  //
  match r {
    A => @assertion.assert_eq(cpu.a, t.expectR)?
    X => @assertion.assert_eq(cpu.x, t.expectR)?
    Y => @assertion.assert_eq(cpu.y, t.expectR)?
  }

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareZeroPageX(t : CMPTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.r
  cpu.x = 0x04

  //
  cpu.write(t.pc + 0, U8::u8(INS_CMP_ZPX))
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x0042 + cpu.x.0, t.op)

  //
  @assertion.assert_eq(cpu.step(), 4)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 2)?

  //
  @assertion.assert_eq(cpu.a, t.expectR)?
  @assertion.assert_eq(cpu.x, 0x04)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareAbsolute(
  t : CMPTestData,
  ~r : Register = A
) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  match r {
    A => cpu.a = t.r
    X => cpu.x = t.r
    Y => cpu.y = t.r
  }

  //
  match r {
    A => cpu.write(t.pc + 0, U8::u8(INS_CMP_ABS))
    X => cpu.write(t.pc + 0, U8::u8(INS_CPX_ABS))
    Y => cpu.write(t.pc + 0, U8::u8(INS_CPY_ABS))
  }
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  @assertion.assert_eq(cpu.step(), 4)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 3)?

  //
  match r {
    A => @assertion.assert_eq(cpu.a, t.expectR)?
    X => @assertion.assert_eq(cpu.x, t.expectR)?
    Y => @assertion.assert_eq(cpu.y, t.expectR)?
  }

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareAbsoluteX(t : CMPTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.r
  cpu.x = 0x04

  //
  cpu.write(t.pc + 0, U8::u8(INS_CMP_ABSX))
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000 + cpu.x.0, t.op)

  //
  @assertion.assert_eq(cpu.step(), 4)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 3)?

  //
  @assertion.assert_eq(cpu.a, t.expectR)?
  @assertion.assert_eq(cpu.x, 0x04)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareAbsoluteY(t : CMPTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.r
  cpu.y = 0x04

  //
  cpu.write(t.pc + 0, U8::u8(INS_CMP_ABSY))
  cpu.write(t.pc + 1, 0x00)
  cpu.write(t.pc + 2, 0x80)

  //
  cpu.write(0x8000 + cpu.y.0, t.op)

  //
  @assertion.assert_eq(cpu.step(), 4)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 3)?

  //
  @assertion.assert_eq(cpu.a, t.expectR)?
  @assertion.assert_eq(cpu.y, 0x04)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareIndirectX(t : CMPTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.r
  cpu.x = 0x04

  //
  cpu.write(t.pc + 0, U8::u8(INS_CMP_INDX))
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x42 + cpu.x.0 + 0, 0x00)
  cpu.write(0x42 + cpu.x.0 + 1, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  @assertion.assert_eq(cpu.step(), 6)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 2)?

  //
  @assertion.assert_eq(cpu.a, t.expectR)?
  @assertion.assert_eq(cpu.x, 0x04)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}

fn testCompareIndirectY(t : CMPTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=t.pc)

  //
  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  let v = cpu.v
  // let n = cpu.n

  //
  cpu.c = not(t.expectC)
  cpu.z = not(t.expectZ)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.r
  cpu.y = 0x04

  //
  cpu.write(t.pc + 0, U8::u8(INS_CMP_INDY))
  cpu.write(t.pc + 1, 0x42)

  //
  cpu.write(0x42 + cpu.x.0 + 0, 0x00)
  cpu.write(0x42 + cpu.x.0 + 1, 0x80)

  //
  cpu.write(0x8000 + cpu.y.0, t.op)

  //
  @assertion.assert_eq(cpu.step(), 5)?

  //
  @assertion.assert_eq(cpu.pc, t.pc + 2)?

  //
  @assertion.assert_eq(cpu.a, t.expectR)?
  @assertion.assert_eq(cpu.y, 0x04)?

  //
  @assertion.assert_eq(cpu.c, t.expectC)?
  @assertion.assert_eq(cpu.z, t.expectZ)?
  @assertion.assert_eq(cpu.i, i)?
  @assertion.assert_eq(cpu.d, d)?
  @assertion.assert_eq(cpu.b, b)?
  @assertion.assert_eq(cpu.u, u)?
  @assertion.assert_eq(cpu.v, v)?
  @assertion.assert_eq(cpu.n, t.expectN)
}
