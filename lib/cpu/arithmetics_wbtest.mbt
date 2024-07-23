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
  testADCAbsolute(t)!
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
  testADCAbsolute(t)!
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
  testADCAbsolute(t)!
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)!
}

test "ADCAbsCanAddOneToFFAndItWillCauseACarry" {
  let t = {
    // Input
    c: false,
    a: -1,
    op: 1,

    // Output
    expectA: 0,

    //
    expectC: true,
    expectZ: true,
    expectN: false,
    expectV: false,
  }
  testADCAbsolute(t)!
}

test "ADCAbsWillSetTheNegativeFlagWhenTheResultIsNegative" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: -1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectV: false,
    expectN: true,
  }
  testADCAbsolute(t)!
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
    expectC: true,
    expectZ: false,
    expectV: true,
    expectN: false,
  }
  testADCAbsolute(t)!
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
    expectA: 128, // -128,

    //
    expectC: true,
    expectZ: false,
    expectV: false,
    expectN: true,
  }
  testADCAbsolute(t)!
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
  testADCAbsolute(t)!
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
  testADCImmediate(t)!
}

test "ADCImmediateCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCImmediate(t)!
}

// ADC Zero Page

test "ADCZeroPageCanAddTwoUnsignedNumbers" {
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
  testADCZeroPage(t)!
}

test "ADCZeroPageCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCZeroPage(t)!
}

// ADC Zero Page, X

test "ADCZeroPageXCanAddTwoUnsignedNumbers" {
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
  testADCZeroPageX(t)!
}

test "ADCZeroPageXCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCZeroPageX(t)!
}

// ADC Absolute, X

test "ADCAbsXCanAddTwoUnsignedNumbers" {
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
  testADCAbsoluteX(t)!
}

test "ADCAbsXCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsoluteX(t)!
}

// ADC Absolute, Y

test "ADCAbsYCanAddTwoUnsignedNumbers" {
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
  testADCAbsoluteY(t)!
}

test "ADCAbsYCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCAbsoluteY(t)!
}

// ADC Indirect, X

test "ADCIndXCanAddTwoUnsignedNumbers" {
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
  testADCIndirectX(t)!
}

test "ADCIndXCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCIndirectX(t)!
}

// ADC Indirect, Y

test "ADCIndYCanAddTwoUnsignedNumbers" {
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
  testADCIndirectY(t)!
}

test "ADCIndYCanAddAPositiveAndNegativeNumber" {
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
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: false,
  }
  testADCIndirectY(t)!
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
  testSBCAbsolute(t)!
}

test "SBCAbsCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)!
}

test "SBCAbsCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)!
}

test "SBCAbsCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)!
}

test "SBCAbsCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCAbsolute(t)!
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
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCAbsolute(t)!
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
  testSBCAbsolute(t)!
}

test "SBCAbsCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsolute(t)!
}

// SBC Zero Page

test "SBCZeroPageCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractTwoUnsignedNumbers" {
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
  testSBCZeroPage(t)!
}

test "SBCZeroPageCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }

  // Output

  //
  testSBCZeroPage(t)!
}

// SBC Immediate

test "SBCImmediateCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractTwoUnsignedNumbers" {
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
  testSBCImmediate(t)!
}

test "SBCImmediateCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCImmediate(t)!
}

// SBC Zero Page, X

test "SBCZeroPageXCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractTwoUnsignedNumbers" {
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
  testSBCZeroPageX(t)!
}

test "SBCZeroPageXCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCZeroPageX(t)!
}

// SBC Absolute, X

test "SBCAbsoluteXCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractTwoUnsignedNumbers" {
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
  testSBCAbsoluteX(t)!
}

test "SBCAbsoluteXCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteX(t)!
}

// SBC Absolute, Y

test "SBCAbsoluteYCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractTwoUnsignedNumbers" {
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
  testSBCAbsoluteY(t)!
}

test "SBCAbsoluteYCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCAbsoluteY(t)!
}

// SBC Indirect, X

test "SBCIndirectXCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractTwoUnsignedNumbers" {
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
  testSBCIndirectX(t)!
}

test "SBCIndirectXCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectX(t)!
}

// SBC Indirect, Y

test "SBCIndirectYCanSubtractZeroFromZeroAndGetZero" {
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
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractZeroFromZeroAndCarryAndGetMinusOne" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 0,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractOneFromZeroAndGetMinusOne" {
  let t = {
    // Input
    c: true,
    a: 0,
    op: 1,

    // Output
    expectA: 255, // -1,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractOneFromZeroWithCarryAndGetMinusTwo" {
  let t = {
    // Input
    c: false,
    a: 0,
    op: 1,

    // Output
    expectA: 254, // -2,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractTwoNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: -128,
    op: 1,

    // Output
    expectA: 127,

    //
    expectC: true,
    expectZ: false,
    expectN: false,
    expectV: true,
  }
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractAPostitiveAndNegativeNumbersAndGetSignedOverflow" {
  let t = {
    // Input
    c: true,
    a: 127,
    op: -1,

    // Output
    expectA: 128,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: true,
  }
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractTwoUnsignedNumbers" {
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
  testSBCIndirectY(t)!
}

test "SBCIndirectYCanSubtractTwoNegativeNumbers" {
  let t = {
    // Input
    c: true,
    a: -20,
    op: -17,

    // Output
    expectA: 253, // -3,

    //
    expectC: false,
    expectZ: false,
    expectN: true,
    expectV: false,
  }
  testSBCIndirectY(t)!
}

// Test

struct ADCTestData {
  // Input
  c : Bool
  a : UInt8
  op : UInt8

  // Output
  expectA : Int

  //
  expectC : Bool
  expectZ : Bool
  expectV : Bool
  expectN : Bool
}

fn testADCAbsolute(
  t : ADCTestData,
  ~ins : Instruction = ADC_ABS
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x00)
  cpu.write(0xFF02, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  @test.eq(cpu.step(), 4)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCAbsolute(t : ADCTestData) -> Unit!String {
  testADCAbsolute(t, ins=SBC_ABS)!
}

fn testADCImmediate(t : ADCTestData, ~ins : Instruction = ADC) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, t.op)

  //
  @test.eq(cpu.step(), 2)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCImmediate(t : ADCTestData) -> Unit!String {
  testADCImmediate(t, ins=SBC)!
}

fn testADCZeroPage(t : ADCTestData, ~ins : Instruction = ADC_ZP) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x42)

  //
  cpu.write(0x0042, t.op)

  //
  @test.eq(cpu.step(), 3)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCZeroPage(t : ADCTestData) -> Unit!String {
  testADCZeroPage(t, ins=SBC_ZP)!
}

fn testADCZeroPageX(
  t : ADCTestData,
  ~ins : Instruction = ADC_ZPX
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a
  cpu.registers[X] = 0x10

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x42)

  //
  cpu.write(0x0042 + cpu.registers[X].0, t.op)

  //
  @test.eq(cpu.step(), 4)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCZeroPageX(t : ADCTestData) -> Unit!String {
  testADCZeroPageX(t, ins=SBC_ZPX)!
}

fn testADCAbsoluteX(
  t : ADCTestData,
  ~ins : Instruction = ADC_ABSX
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a
  cpu.registers[X] = 0x10

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x00)
  cpu.write(0xFF02, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[X].0, t.op)

  //
  @test.eq(cpu.step(), 4)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCAbsoluteX(t : ADCTestData) -> Unit!String {
  testADCAbsoluteX(t, ins=SBC_ABSX)!
}

fn testADCAbsoluteY(
  t : ADCTestData,
  ~ins : Instruction = ADC_ABSY
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a
  cpu.registers[Y] = 0x10

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x00)
  cpu.write(0xFF02, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[Y].0, t.op)

  //
  @test.eq(cpu.step(), 4)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCAbsoluteY(t : ADCTestData) -> Unit!String {
  testADCAbsoluteY(t, ins=SBC_ABSY)!
}

fn testADCIndirectX(
  t : ADCTestData,
  ~ins : Instruction = ADC_INDX
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a
  cpu.registers[X] = 0x04

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x02)

  //
  cpu.write(0x0002 + cpu.registers[X].0, 0x00)
  cpu.write(0x0003 + cpu.registers[X].0, 0x80)

  //
  cpu.write(0x8000, t.op)

  //
  @test.eq(cpu.step(), 6)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCIndirectX(t : ADCTestData) -> Unit!String {
  testADCIndirectX(t, ins=SBC_INDX)!
}

fn testADCIndirectY(
  t : ADCTestData,
  ~ins : Instruction = ADC_INDY
) -> Unit!String {
  let cpu = CPU::new(pc=0xFF00)

  // let c = cpu.flags[C]
  // let z = cpu.flags[Z]
  let i = cpu.flags[I]
  let d = cpu.flags[D]
  let b = cpu.flags[B]
  let u = cpu.flags[U]
  // let v = cpu.flags[V]
  // let n = cpu.flags[N]

  cpu.flags[C] = t.c
  cpu.flags[Z] = not(t.expectZ)
  cpu.flags[V] = not(t.expectV)
  cpu.flags[N] = not(t.expectN)

  //
  cpu.registers[A] = t.a
  cpu.registers[Y] = 0x04

  //
  cpu.write(0xFF00, ins.to_int())
  cpu.write(0xFF01, 0x02)

  //
  cpu.write(0x0002, 0x00)
  cpu.write(0x0003, 0x80)

  //
  cpu.write(0x8000 + cpu.registers[Y].0, t.op)

  //
  @test.eq(cpu.step(), 5)!

  //
  @test.eq(cpu.registers[A], t.expectA)!

  //
  @test.eq(cpu.flags[C], t.expectC)!
  @test.eq(cpu.flags[Z], t.expectZ)!
  @test.eq(cpu.flags[I], i)!
  @test.eq(cpu.flags[D], d)!
  @test.eq(cpu.flags[B], b)!
  @test.eq(cpu.flags[U], u)!
  @test.eq(cpu.flags[V], t.expectV)!
  @test.eq(cpu.flags[N], t.expectN)!
}

fn testSBCIndirectY(t : ADCTestData) -> Unit!String {
  testADCIndirectY(t, ins=SBC_INDY)!
}
