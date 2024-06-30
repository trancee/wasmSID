// Tests

// ADC Absolute

test "ADCAbsCanAddZeroToZeroAndGetZero" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 0,

    //
    expectC: false,
    expectZ: true,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsCanAddCarryAndZeroToZeroAndGetOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 0,

    // Output
    expectA: 1,

    //
    expectC: false,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsCanAddTwoUnsignedNumbers" {
  let t = {
    // Input
    c: true,
    a: 20,
    op: 17,

    // Output
    expectA: 38,

    //
    expectC: false,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsCanAddAPositiveAndNegativeNumber" {
  // A: 00010100 20
  // O: 11101111 -17
  // =: 00000011
  // C:1 N:0 V:0 Z:0

  let t = {
    // Input
    c: true,
    a: 20,
    op: -17,

    // Output
    expectA: 4,

    //
    expectC: false, //true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsCanAddOneToFFAndItWillCauseACarry" {
  let t = {
    // Input
    c: false,
    a: 0xFF,
    op: 1,

    // Output
    expectA: 0,

    //
    expectC: true,
    expectZ: true,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsWillSetTheNegativeFlagWhenTheResultIsNegative" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: -1,

    // Output
    expectA: 0xFF,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: true,
  }
  testADCAbsolute(t)?
}

test "ADCAbsWillSetTheOverflowFlagWhenSignedNegativeAddtionFails" {
  // A: 10000000 -128
  // O: 11111111 -1
  // =: 01111111 127
  // C:1 N:0 V:1 Z:0

  let t = {
    // Input
    c: false,
    a: -128,
    op: -1,

    // Output
    expectA: 127,

    //
    expectC: false, //true,
    expectZ: false,
    expectV: true,
    expectN: false,
  }
  testADCAbsolute(t)?
}

test "ADCAbsWillSetTheOverflowFlagWhenSignedNegativeAddtionPassedDueToInitalCarryFlag" {
  // C: 00000001
  // A: 10000000 -128
  // O: 11111111 -1
  // =: 10000000 -128
  // C:1 N:1 V:0 Z:0

  let t = {
    // Input
    c: true,
    a: -128,
    op: -1,

    // Output
    expectA: 0x80,

    //
    expectC: false, //true,
    expectZ: false,
    expectV: false,
    expectN: true,
  }
  testADCAbsolute(t)?
}

test "ADCAbsWillSetTheOverflowFlagWhenSignedPositiveAddtionFails" {
  // A: 01111111 127
  // O: 00000001 1
  // =: 10000000 128
  // C:0 N:1 V:1 Z:0

  let t = {
    // Input
    c: false,
    a: 127,
    op: 1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectV: true,
    expectN: true,
  }
  testADCAbsolute(t)?
}

// ADC Immediate

test "ADCImmediateCanAddTwoUnsignedNumbers" {
  let t = {
    // Input
    c: true,
    a: 20,
    op: 17,

    // Output
    expectA: 38,

    //
    expectC: false,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCImmediate(t)?
}

// SBC Absolute

test "SBCAbsCanSubtractZeroFromZeroAndGetZero" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 0,

    // Output
    expectA: 0,

    //
    expectC: true,
    expectZ: true,
    expectN: false,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: -129, // 127,

    //
    expectC: false, // true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: true, // false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractTwoUnsignedNumbers" {
  let t = {
    // Input
    c: true,
    a: 20,
    op: 17,

    // Output
    expectA: 3,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

test "SBCAbsCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)?
}

// Test

struct ADCTestData {
  // Input
  c : Bool
  a : UInt8
  op : UInt8

  // Output
  expectA : UInt8

  //
  expectC : Bool
  expectZ : Bool
  expectV : Bool
  expectN : Bool
}

fn testADCAbsolute(
  t : ADCTestData,
  ~ins : Instruction = INS_ADC_ABS
) -> Result[Unit, String] {
  let cpu = cpu_new(pc=0xFF00)

  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  // let v = cpu.v
  // let n = cpu.n

  cpu.c = t.c
  cpu.z = not(t.expectZ)
  cpu.v = not(t.expectV)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.a

  //
  cpu.write(0xFF00, U8::u8(ins))
  cpu.write(0xFF01, 0x00)
  cpu.write(0xFF02, 0x80)
  cpu.write(0x8000, t.op)

  //
  @assertion.assert_eq(cpu.step(), 4)?

  //
  @assertion.assert_eq(cpu.a, t.expectA)?

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

fn testSBCAbsolute(t : ADCTestData) -> Result[Unit, String] {
  testADCAbsolute(t, ins=INS_SBC_ABS)
}

fn testADCImmediate(t : ADCTestData) -> Result[Unit, String] {
  let cpu = cpu_new(pc=0xFF00)

  // let c = cpu.c
  // let z = cpu.z
  let i = cpu.i
  let d = cpu.d
  let b = cpu.b
  let u = cpu.u
  // let v = cpu.v
  // let n = cpu.n

  cpu.c = t.c
  cpu.z = not(t.expectZ)
  cpu.v = not(t.expectV)
  cpu.n = not(t.expectN)

  //
  cpu.a = t.a

  //
  cpu.write(0xFF00, U8::u8(INS_ADC))
  cpu.write(0xFF01, t.op)

  //
  @assertion.assert_eq(cpu.step(), 2)?

  //
  @assertion.assert_eq(cpu.a, t.expectA)?

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
