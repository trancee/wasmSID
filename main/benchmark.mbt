///|
let testcases : Array[Test] = [
  /// Logic

  // ORA A ∨ M → A [NZ]
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01110111,
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0b00000000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b00000000), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01110111,
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // ORA ($nn),Y
  Test::new(
    "ORA ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0b00000000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x11), // ORA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b00000000), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),

  // EOR A ⊻ M → A [NZ]
  // EOR #$nn
  Test::new(
    "EOR #$nn",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x49), // EOR #$nn
      (0x1001, 0b01010101), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // EOR #$nn
  Test::new(
    "EOR #$nn N",
    initial=State::new(pc=0x1000, a=0b10000000, p=@cpu.ALL, ram=[
      (0x1000, 0x49), // EOR #$nn
      (0x1001, 0b01010101), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // EOR #$nn
  Test::new(
    "EOR #$nn Z",
    initial=State::new(pc=0x1000, a=0b01010101, p=@cpu.ALL, ram=[
      (0x1000, 0x49), // EOR #$nn
      (0x1001, 0b01010101), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),

  // EOR $nnnn
  Test::new(
    "EOR $nnnn",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x4D), // EOR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // EOR $nnnn
  Test::new(
    "EOR $nnnn N",
    initial=State::new(pc=0x1000, a=0b10000000, p=@cpu.ALL, ram=[
      (0x1000, 0x4D), // EOR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // EOR $nnnn
  Test::new(
    "EOR $nnnn Z",
    initial=State::new(pc=0x1000, a=0b01010101, p=@cpu.ALL, ram=[
      (0x1000, 0x4D), // EOR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),

  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X",
    initial=State::new(pc=0x1000, a=0b00110011, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b01100110,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X N",
    initial=State::new(pc=0x1000, a=0b10000000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11010101,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X Z",
    initial=State::new(pc=0x1000, a=0b01010101, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X",
    initial=State::new(pc=0x1000, a=0b00110011, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b01100110,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X N",
    initial=State::new(pc=0x1000, a=0b10000000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11010101,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // EOR $nnnn,X
  Test::new(
    "EOR $nnnn,X Z",
    initial=State::new(pc=0x1000, a=0b01010101, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x5D), // EOR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y Z",
    initial=State::new(pc=0x1000, a=0b01010101, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // EOR $nnnn,Y
  Test::new(
    "EOR $nnnn,Y Z",
    initial=State::new(pc=0x1000, a=0b01010101, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x59), // EOR $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // EOR $nn
  Test::new(
    "EOR $nn",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x45), // EOR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // EOR $nn
  Test::new(
    "EOR $nn N",
    initial=State::new(pc=0x1000, a=0b10000000, p=@cpu.ALL, ram=[
      (0x1000, 0x45), // EOR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // EOR $nn
  Test::new(
    "EOR $nn Z",
    initial=State::new(pc=0x1000, a=0b01010101, p=@cpu.ALL, ram=[
      (0x1000, 0x45), // EOR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),

  // EOR $nn,X
  Test::new(
    "EOR $nn,X",
    initial=State::new(pc=0x1000, a=0b00110011, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x55), // EOR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // EOR $nn,X
  Test::new(
    "EOR $nn,X N",
    initial=State::new(pc=0x1000, a=0b10000000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x55), // EOR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // EOR $nn,X
  Test::new(
    "EOR $nn,X Z",
    initial=State::new(pc=0x1000, a=0b01010101, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x55), // EOR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),

  // EOR ($nn,X)
  Test::new(
    "EOR ($nn,X)",
    initial=State::new(pc=0x1000, a=0b00110011, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x41), // EOR ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0b01010101),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // EOR ($nn,X)
  Test::new(
    "EOR ($nn,X) N",
    initial=State::new(pc=0x1000, a=0b10000000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x41), // EOR ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0b01010101),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // EOR ($nn,X)
  Test::new(
    "EOR ($nn,X) Z",
    initial=State::new(pc=0x1000, a=0b01010101, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x41), // EOR ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0b01010101),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),

  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0b01010101, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y",
    initial=State::new(pc=0x1000, a=0b00110011, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y N",
    initial=State::new(pc=0x1000, a=0b10000000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11010101,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // EOR ($nn),Y
  Test::new(
    "EOR ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0b01010101, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x51), // EOR ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0b01010101), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),

  // BIT A ∧ M, M7 → N, M6 → V [NVZ]
  // BIT $nn
  Test::new(
    "BIT $nn",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.OVERFLOW ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn N",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.OVERFLOW ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn V",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.OVERFLOW,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn Z",
    initial=State::new(pc=0x1000, a=0b11000000, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b11000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.OVERFLOW) | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn NV",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b11111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.OVERFLOW,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn NZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.OVERFLOW) | @cpu.NEGATIVE | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn VZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.OVERFLOW | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),
  // BIT $nn
  Test::new(
    "BIT $nn NVZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x24), // BIT $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b11111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=@cpu.ALL | @cpu.NEGATIVE | @cpu.OVERFLOW | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),

  // BIT $nnnn
  Test::new(
    "BIT $nnnn",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.OVERFLOW ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn N",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.OVERFLOW ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn V",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.OVERFLOW,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn Z",
    initial=State::new(pc=0x1000, a=0b11000000, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b11000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.OVERFLOW) | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn NV",
    initial=State::new(pc=0x1000, a=0b00110011, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b11111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.OVERFLOW,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn NZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.OVERFLOW) | @cpu.NEGATIVE | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn VZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.OVERFLOW | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // BIT $nnnn
  Test::new(
    "BIT $nnnn NVZ",
    initial=State::new(pc=0x1000, a=0b00000000, p=@cpu.ALL, ram=[
      (0x1000, 0x2C), // BIT $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b11111111), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=@cpu.ALL | @cpu.NEGATIVE | @cpu.OVERFLOW | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),

  // AND A ∧ M → A [NZ]
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y N",
    initial=State::new(pc=0x1000, a=0x80, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0xFF), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0x00, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y N",
    initial=State::new(pc=0x1000, a=0x81, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // AND ($nn),Y
  Test::new(
    "AND ($nn),Y Z",
    initial=State::new(pc=0x1000, a=0x00, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x31), // AND ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),

  // AND ($nn,X)
  Test::new(
    "AND ($nn,X)",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x21), // AND ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0xEE),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // AND ($nn,X)
  Test::new(
    "AND ($nn,X) N",
    initial=State::new(pc=0x1000, a=0x81, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x21), // AND ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0xEE),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // AND ($nn,X)
  Test::new(
    "AND ($nn,X) Z",
    initial=State::new(pc=0x1000, a=0x00, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x21), // AND ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0xEE),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),

  // AND $nn,X
  Test::new(
    "AND $nn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x35), // AND $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // AND $nn,X
  Test::new(
    "AND $nn,X N",
    initial=State::new(pc=0x1000, a=0x81, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x35), // AND $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // AND $nn,X
  Test::new(
    "AND $nn,X Z",
    initial=State::new(pc=0x1000, a=0x00, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x35), // AND $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),

  // AND $nn
  Test::new(
    "AND $nn",
    initial=State::new(pc=0x1000, a=0x69, p=@cpu.ALL, ram=[
      (0x1000, 0x25), // AND $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // AND $nn
  Test::new(
    "AND $nn N",
    initial=State::new(pc=0x1000, a=0x81, p=@cpu.ALL, ram=[
      (0x1000, 0x25), // AND $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // AND $nn
  Test::new(
    "AND $nn Z",
    initial=State::new(pc=0x1000, a=0x00, p=@cpu.ALL, ram=[
      (0x1000, 0x25), // AND $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=3,
  ),

  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y N",
    initial=State::new(pc=0x1000, a=0x81, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y Z",
    initial=State::new(pc=0x1000, a=0x00, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y N",
    initial=State::new(pc=0x1000, a=0x81, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // AND $nnnn,Y
  Test::new(
    "AND $nnnn,Y Z",
    initial=State::new(pc=0x1000, a=0x00, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x39), // AND $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x68,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X N",
    initial=State::new(pc=0x1000, a=0x81, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x80,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X Z",
    initial=State::new(pc=0x1000, a=0x00, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x68,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X N",
    initial=State::new(pc=0x1000, a=0x81, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x80,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // AND $nnnn,X
  Test::new(
    "AND $nnnn,X Z",
    initial=State::new(pc=0x1000, a=0x00, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x3D), // AND $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // AND $nnnn
  Test::new(
    "AND $nnnn",
    initial=State::new(pc=0x1000, a=0x69, p=@cpu.ALL, ram=[
      (0x1000, 0x2D), // AND $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),
  // AND $nnnn
  Test::new(
    "AND $nnnn N",
    initial=State::new(pc=0x1000, a=0x81, p=@cpu.ALL, ram=[
      (0x1000, 0x2D), // AND $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // AND $nnnn
  Test::new(
    "AND $nnnn Z",
    initial=State::new(pc=0x1000, a=0x00, p=@cpu.ALL, ram=[
      (0x1000, 0x2D), // AND $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=4,
  ),

  // AND #$nn
  Test::new(
    "AND #$nn",
    initial=State::new(pc=0x1000, a=0x69, p=@cpu.ALL, ram=[
      (0x1000, 0x29), // AND #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x68,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // AND #$nn
  Test::new(
    "AND #$nn N",
    initial=State::new(pc=0x1000, a=0x81, p=@cpu.ALL, ram=[
      (0x1000, 0x29), // AND #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // AND #$nn
  Test::new(
    "AND #$nn Z",
    initial=State::new(pc=0x1000, a=0x00, p=@cpu.ALL, ram=[
      (0x1000, 0x29), // AND #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),

  /// Shift

  // ROR C → /M7...M0/ → C [NZC]
  // ROR $nn,X → C
  Test::new(
    "ROR $nn,X → C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0087, 0b10110011)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X → C
  Test::new(
    "ROR $nn,X N → C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0087, 0b11000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X → C
  Test::new(
    "ROR $nn,X C → C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0087, 0b10000001)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X → C
  Test::new(
    "ROR $nn,X NC → C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0087, 0b11000000)], // M
    ),
    cycle=6,
  ),

  // ROR $nn → C
  Test::new(
    "ROR $nn → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0088, 0b10110011)], // M
    ),
    cycle=5,
  ),
  // ROR $nn → C
  Test::new(
    "ROR $nn N → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0088, 0b11000000)], // M
    ),
    cycle=5,
  ),
  // ROR $nn → C
  Test::new(
    "ROR $nn C → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0088, 0b10000001)], // M
    ),
    cycle=5,
  ),
  // ROR $nn → C
  Test::new(
    "ROR $nn NC → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0088, 0b11000000)], // M
    ),
    cycle=5,
  ),

  // ROR $nnnn,X → C
  Test::new(
    "ROR $nnnn,X → C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAE, 0b10110011)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X → C
  Test::new(
    "ROR $nnnn,X N → C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAE, 0b11000000)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X → C
  Test::new(
    "ROR $nnnn,X C → C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAE, 0b10000001)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X → C
  Test::new(
    "ROR $nnnn,X NC → C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAE, 0b11000000)], // M
    ),
    cycle=7,
  ),

  // ROR $nnnn → C
  Test::new(
    "ROR $nnnn → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAD, 0b10110011)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn → C
  Test::new(
    "ROR $nnnn N → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAD, 0b11000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn → C
  Test::new(
    "ROR $nnnn C → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAD, 0b10000001)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn → C
  Test::new(
    "ROR $nnnn NC → C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAD, 0b11000000)], // M
    ),
    cycle=6,
  ),

  // ROR A → C
  Test::new(
    "ROR A → C",
    initial=State::new(
      pc=0x1000,
      a=0b01100110,
      p=@cpu.ALL,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10110011,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A → C
  Test::new(
    "ROR A N → C",
    initial=State::new(
      pc=0x1000,
      a=0b10000000,
      p=@cpu.ALL,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b11000000,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A → C
  Test::new(
    "ROR A C → C",
    initial=State::new(
      pc=0x1000,
      a=0b00000011,
      p=@cpu.ALL,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10000001,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A → C
  Test::new(
    "ROR A NC → C",
    initial=State::new(
      pc=0x1000,
      a=0b10000001,
      p=@cpu.ALL,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b11000000,
      x=0x00,
      y=0x00,
      // carry makes it always negative
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // ROR $nn,X
  Test::new(
    "ROR $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b00110011)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X
  Test::new(
    "ROR $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X
  Test::new(
    "ROR $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X
  Test::new(
    "ROR $nn,X C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b00000001)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X
  Test::new(
    "ROR $nn,X NC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nn,X
  Test::new(
    "ROR $nn,X ZC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x76), // ROR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // ROR $nn
  Test::new(
    "ROR $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b00110011)], // M
    ),
    cycle=5,
  ),
  // ROR $nn
  Test::new(
    "ROR $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b01000000)], // M
    ),
    cycle=5,
  ),
  // ROR $nn
  Test::new(
    "ROR $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),
  // ROR $nn
  Test::new(
    "ROR $nn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b00000001)], // M
    ),
    cycle=5,
  ),
  // ROR $nn
  Test::new(
    "ROR $nn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b01000000)], // M
    ),
    cycle=5,
  ),
  // ROR $nn
  Test::new(
    "ROR $nn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x66), // ROR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),

  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b00110011)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b01000000)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000001)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X NC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b01000000)], // M
    ),
    cycle=7,
  ),
  // ROR $nnnn,X
  Test::new(
    "ROR $nnnn,X ZC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x7E), // ROR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),

  // ROR $nnnn
  Test::new(
    "ROR $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b00110011)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn
  Test::new(
    "ROR $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn
  Test::new(
    "ROR $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn
  Test::new(
    "ROR $nnnn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000001)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn
  Test::new(
    "ROR $nnnn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // ROR $nnnn
  Test::new(
    "ROR $nnnn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x6E), // ROR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // ROR A
  Test::new(
    "ROR A",
    initial=State::new(
      pc=0x1000,
      a=0b01100110,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A
  Test::new(
    "ROR A N",
    initial=State::new(
      pc=0x1000,
      a=0b10000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01000000,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A
  Test::new(
    "ROR A Z",
    initial=State::new(
      pc=0x1000,
      a=0b00000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A
  Test::new(
    "ROR A C",
    initial=State::new(
      pc=0x1000,
      a=0b00000011,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000001,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A
  Test::new(
    "ROR A NC",
    initial=State::new(
      pc=0x1000,
      a=0b10000001,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01000000,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROR A
  Test::new(
    "ROR A ZC",
    initial=State::new(
      pc=0x1000,
      a=0b00000001,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x6A)], // ROR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // ROL C ← /M7...M0/ ← C [NZC]
  // ROL $nn,X ← C
  Test::new(
    "ROL $nn,X ← C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b01100111)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X ← C
  Test::new(
    "ROL $nn,X N ← C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0087, 0b10000001)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X ← C
  Test::new(
    "ROL $nn,X C ← C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b00000011)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X ← C
  Test::new(
    "ROL $nn,X NC ← C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0087, 0b10000001)], // M
    ),
    cycle=6,
  ),

  // ROL $nn ← C
  Test::new(
    "ROL $nn ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b01100111)], // M
    ),
    cycle=5,
  ),
  // ROL $nn ← C
  Test::new(
    "ROL $nn N ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0088, 0b10000001)], // M
    ),
    cycle=5,
  ),
  // ROL $nn ← C
  Test::new(
    "ROL $nn C ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b00000011)], // M
    ),
    cycle=5,
  ),
  // ROL $nn ← C
  Test::new(
    "ROL $nn NC ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0088, 0b10000001)], // M
    ),
    cycle=5,
  ),

  // ROL $nnnn,X ← C
  Test::new(
    "ROL $nnnn,X ← C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b01100111)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X ← C
  Test::new(
    "ROL $nnnn,X N ← C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAE, 0b10000001)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X ← C
  Test::new(
    "ROL $nnnn,X C ← C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000011)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X ← C
  Test::new(
    "ROL $nnnn,X NC ← C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAE, 0b10000001)], // M
    ),
    cycle=7,
  ),

  // ROL $nnnn ← C
  Test::new(
    "ROL $nnnn ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b01100111)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn ← C
  Test::new(
    "ROL $nnnn N ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAD, 0b10000001)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn ← C
  Test::new(
    "ROL $nnnn C ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000011)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn ← C
  Test::new(
    "ROL $nnnn NC ← C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAD, 0b10000001)], // M
    ),
    cycle=6,
  ),

  // ROL A ← C
  Test::new(
    "ROL A ← C",
    initial=State::new(
      pc=0x1000,
      a=0b00110011,
      p=@cpu.ALL,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01100111,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A ← C
  Test::new(
    "ROL A N ← C",
    initial=State::new(
      pc=0x1000,
      a=0b01000000,
      p=@cpu.ALL,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10000001,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A ← C
  Test::new(
    "ROL A C ← C",
    initial=State::new(
      pc=0x1000,
      a=0b10000001,
      p=@cpu.ALL,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000011,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A ← C
  Test::new(
    "ROL A NC ← C",
    initial=State::new(
      pc=0x1000,
      a=0b11000000,
      p=@cpu.ALL,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10000001,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // ROL $nn,X
  Test::new(
    "ROL $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b01100110)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X
  Test::new(
    "ROL $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0087, 0b10000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X
  Test::new(
    "ROL $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X
  Test::new(
    "ROL $nn,X C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b00000010)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X
  Test::new(
    "ROL $nn,X NC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0087, 0b10000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nn,X
  Test::new(
    "ROL $nn,X ZC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x36), // ROL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // ROL $nn
  Test::new(
    "ROL $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b01100110)], // M
    ),
    cycle=5,
  ),
  // ROL $nn
  Test::new(
    "ROL $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0088, 0b10000000)], // M
    ),
    cycle=5,
  ),
  // ROL $nn
  Test::new(
    "ROL $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),
  // ROL $nn
  Test::new(
    "ROL $nn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b00000010)], // M
    ),
    cycle=5,
  ),
  // ROL $nn
  Test::new(
    "ROL $nn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0088, 0b10000000)], // M
    ),
    cycle=5,
  ),
  // ROL $nn
  Test::new(
    "ROL $nn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x26), // ROL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),

  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b01100110)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAE, 0b10000000)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000010)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X NC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAE, 0b10000000)], // M
    ),
    cycle=7,
  ),
  // ROL $nnnn,X
  Test::new(
    "ROL $nnnn,X ZC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x3E), // ROL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),

  // ROL $nnnn
  Test::new(
    "ROL $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00110011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b01100110)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn
  Test::new(
    "ROL $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAD, 0b10000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn
  Test::new(
    "ROL $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn
  Test::new(
    "ROL $nnnn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000010)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn
  Test::new(
    "ROL $nnnn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b11000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAD, 0b10000000)], // M
    ),
    cycle=6,
  ),
  // ROL $nnnn
  Test::new(
    "ROL $nnnn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL ^ @cpu.CARRY, ram=[
      (0x1000, 0x2E), // ROL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // ROL A
  Test::new(
    "ROL A",
    initial=State::new(
      pc=0x1000,
      a=0b00110011,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01100110,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A
  Test::new(
    "ROL A N",
    initial=State::new(
      pc=0x1000,
      a=0b01000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A
  Test::new(
    "ROL A Z",
    initial=State::new(
      pc=0x1000,
      a=0b00000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A
  Test::new(
    "ROL A C",
    initial=State::new(
      pc=0x1000,
      a=0b10000001,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000010,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A
  Test::new(
    "ROL A NC",
    initial=State::new(
      pc=0x1000,
      a=0b11000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b10000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ROL A
  Test::new(
    "ROL A ZC",
    initial=State::new(
      pc=0x1000,
      a=0b10000000,
      p=@cpu.ALL ^ @cpu.CARRY,
      ram=[(0x1000, 0x2A)], // ROL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // LSR 0 → /M7...M0/ → C [0ZC]
  // LSR $nn,X
  Test::new(
    "LSR $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b00110011)], // M
    ),
    cycle=6,
  ),
  // LSR $nn,X
  Test::new(
    "LSR $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nn,X
  Test::new(
    "LSR $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nn,X
  Test::new(
    "LSR $nn,X C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b00000001)], // M
    ),
    cycle=6,
  ),
  // LSR $nn,X
  Test::new(
    "LSR $nn,X NC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nn,X
  Test::new(
    "LSR $nn,X ZC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x56), // LSR $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0087, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // LSR $nn
  Test::new(
    "LSR $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b00110011)], // M
    ),
    cycle=5,
  ),
  // LSR $nn
  Test::new(
    "LSR $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0b01000000)], // M
    ),
    cycle=5,
  ),
  // LSR $nn
  Test::new(
    "LSR $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),
  // LSR $nn
  Test::new(
    "LSR $nn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b00000001)], // M
    ),
    cycle=5,
  ),
  // LSR $nn
  Test::new(
    "LSR $nn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0b01000000)], // M
    ),
    cycle=5,
  ),
  // LSR $nn
  Test::new(
    "LSR $nn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x46), // LSR $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0088, 0b00000000)], // M
    ),
    cycle=5,
  ),

  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b00110011)], // M
    ),
    cycle=7,
  ),
  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0b01000000)], // M
    ),
    cycle=7,
  ),
  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),
  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000001)], // M
    ),
    cycle=7,
  ),
  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X NC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0b01000000)], // M
    ),
    cycle=7,
  ),
  // LSR $nnnn,X
  Test::new(
    "LSR $nnnn,X ZC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x5E), // LSR $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAE, 0b00000000)], // M
    ),
    cycle=7,
  ),

  // LSR $nnnn
  Test::new(
    "LSR $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b01100110),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b00110011)], // M
    ),
    cycle=6,
  ),
  // LSR $nnnn
  Test::new(
    "LSR $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nnnn
  Test::new(
    "LSR $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000000),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nnnn
  Test::new(
    "LSR $nnnn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000011),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000001)], // M
    ),
    cycle=6,
  ),
  // LSR $nnnn
  Test::new(
    "LSR $nnnn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b10000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0b01000000)], // M
    ),
    cycle=6,
  ),
  // LSR $nnnn
  Test::new(
    "LSR $nnnn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x4E), // LSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0b00000001),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAD, 0b00000000)], // M
    ),
    cycle=6,
  ),

  // LSR A
  Test::new(
    "LSR A",
    initial=State::new(
      pc=0x1000,
      a=0b01100110,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00110011,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // LSR A
  Test::new(
    "LSR A N",
    initial=State::new(
      pc=0x1000,
      a=0b10000000,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01000000,
      x=0x00,
      y=0x00,
      // can never be negative
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // LSR A
  Test::new(
    "LSR A Z",
    initial=State::new(
      pc=0x1000,
      a=0b00000000,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // LSR A
  Test::new(
    "LSR A C",
    initial=State::new(
      pc=0x1000,
      a=0b00000011,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000001,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // LSR A
  Test::new(
    "LSR A NC",
    initial=State::new(
      pc=0x1000,
      a=0b10000001,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b01000000,
      x=0x00,
      y=0x00,
      // can never be negative
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // LSR A
  Test::new(
    "LSR A ZC",
    initial=State::new(
      pc=0x1000,
      a=0b00000001,
      p=@cpu.ALL,
      ram=[(0x1000, 0x4A)], // LSR A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0b00000000,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // ASL C ← /M7...M0/ ← 0 [NZC]
  // ASL $nn,X
  Test::new(
    "ASL $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x33),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0087, 0x66)], // M
    ),
    cycle=6,
  ),
  // ASL $nn,X
  Test::new(
    "ASL $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0087, 0xD2)], // M
    ),
    cycle=6,
  ),
  // ASL $nn,X
  Test::new(
    "ASL $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0087, 0x00)], // M
    ),
    cycle=6,
  ),
  // ASL $nn,X
  Test::new(
    "ASL $nn,X C",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x81),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0087, 0x02)], // M
    ),
    cycle=6,
  ),
  // ASL $nn,X
  Test::new(
    "ASL $nn,X NC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xC0),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0087, 0x80)], // M
    ),
    cycle=6,
  ),
  // ASL $nn,X
  Test::new(
    "ASL $nn,X ZC",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0x16), // ASL $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x80),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0087, 0x00)], // M
    ),
    cycle=6,
  ),

  // ASL $nn
  Test::new(
    "ASL $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x33),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0x0088, 0x66)], // M
    ),
    cycle=5,
  ),
  // ASL $nn
  Test::new(
    "ASL $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0x0088, 0xD2)], // M
    ),
    cycle=5,
  ),
  // ASL $nn
  Test::new(
    "ASL $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0x0088, 0x00)], // M
    ),
    cycle=5,
  ),
  // ASL $nn
  Test::new(
    "ASL $nn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x81),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0x0088, 0x02)], // M
    ),
    cycle=5,
  ),
  // ASL $nn
  Test::new(
    "ASL $nn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xC0),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0x0088, 0x80)], // M
    ),
    cycle=5,
  ),
  // ASL $nn
  Test::new(
    "ASL $nn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x06), // ASL $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x80),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0x0088, 0x00)], // M
    ),
    cycle=5,
  ),

  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x33),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAE, 0x66)], // M
    ),
    cycle=7,
  ),
  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAE, 0xD2)], // M
    ),
    cycle=7,
  ),
  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAE, 0x00)], // M
    ),
    cycle=7,
  ),
  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X C",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x81),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAE, 0x02)], // M
    ),
    cycle=7,
  ),
  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X NC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xC0),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAE, 0x80)], // M
    ),
    cycle=7,
  ),
  // ASL $nnnn,X
  Test::new(
    "ASL $nnnn,X ZC",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0x1E), // ASL $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x80),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAE, 0x00)], // M
    ),
    cycle=7,
  ),

  // ASL $nnnn
  Test::new(
    "ASL $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x33),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[(0xDEAD, 0x66)], // M
    ),
    cycle=6,
  ),
  // ASL $nnnn
  Test::new(
    "ASL $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[(0xDEAD, 0xD2)], // M
    ),
    cycle=6,
  ),
  // ASL $nnnn
  Test::new(
    "ASL $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[(0xDEAD, 0x00)], // M
    ),
    cycle=6,
  ),
  // ASL $nnnn
  Test::new(
    "ASL $nnnn C",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x81),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[(0xDEAD, 0x02)], // M
    ),
    cycle=6,
  ),
  // ASL $nnnn
  Test::new(
    "ASL $nnnn NC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xC0),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[(0xDEAD, 0x80)], // M
    ),
    cycle=6,
  ),
  // ASL $nnnn
  Test::new(
    "ASL $nnnn ZC",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0x0E), // ASL $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x80),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[(0xDEAD, 0x00)], // M
    ),
    cycle=6,
  ),

  // ASL A
  Test::new(
    "ASL A",
    initial=State::new(
      pc=0x1000,
      a=0x33,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x66,
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO ^ @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ASL A
  Test::new(
    "ASL A N",
    initial=State::new(
      pc=0x1000,
      a=0x69,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0xD2,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO ^ @cpu.CARRY) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // ASL A
  Test::new(
    "ASL A Z",
    initial=State::new(
      pc=0x1000,
      a=0x00,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.CARRY) | @cpu.ZERO,
      ram=[],
    ),
    cycle=2,
  ),
  // ASL A
  Test::new(
    "ASL A C",
    initial=State::new(
      pc=0x1000,
      a=0x81,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x02,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE ^ @cpu.ZERO) | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ASL A
  Test::new(
    "ASL A NC",
    initial=State::new(
      pc=0x1000,
      a=0xC0,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x80,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // ASL A
  Test::new(
    "ASL A ZC",
    initial=State::new(
      pc=0x1000,
      a=0x80,
      p=@cpu.ALL,
      ram=[(0x1000, 0x0A)], // ASL A
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.NEGATIVE) | @cpu.ZERO | @cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  /// Stack

  // PHA A↓
  // PHA
  Test::new(
    "PHA",
    initial=State::new(
      pc=0x1000,
      a=0x69,
      ram=[(0x1000, 0x48)], // PHA
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFE,
      a=0x69,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[
        // Stack
        (0x01FF, 0x69),
      ],
    ),
    cycle=3,
  ),

  // PHP P↓
  // PHP
  Test::new(
    "PHP",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0x08)], // PHP
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFE,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[
        // Stack
        (0x01FF, @cpu.NONE),
      ],
    ),
    cycle=3,
  ),
  // PHP
  Test::new(
    "PHP Z",
    initial=State::new(
      pc=0x1000,
      p=@cpu.ZERO,
      ram=[(0x1000, 0x08)], // PHP
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFE,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ZERO,
      ram=[
        // Stack
        (0x01FF, @cpu.ZERO),
      ],
    ),
    cycle=3,
  ),

  // PLA A↑ [NZ]
  // PLA
  Test::new(
    "PLA",
    initial=State::new(pc=0x1000, s=0xFE, ram=[
      (0x1000, 0x68), // PLA
      (0x01FF, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=4,
  ),
  // PLA
  Test::new(
    "PLA N",
    initial=State::new(pc=0x1000, s=0xFE, ram=[
      (0x1000, 0x68), // PLA
      (0x01FF, -1),
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=-1,
      x=0x00,
      y=0x00,
      p=@cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // PLA
  Test::new(
    "PLA Z",
    initial=State::new(pc=0x1000, s=0xFE, ram=[
      (0x1000, 0x68), // PLA
      (0x01FF, 0),
    ]),
    final=State::new(pc=0x1000 + 1, s=0xFF, a=0, x=0x00, y=0x00, p=@cpu.ZERO, ram=[]),
    cycle=4,
  ),

  // PLP P↑ [NVDIZC]
  // PLP
  Test::new(
    "PLP",
    initial=State::new(pc=0x1000, s=0xFE, p=@cpu.ALL, ram=[
      (0x1000, 0x28), // PLP
      (0x01FF, @cpu.NONE),
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=4,
  ),
  // PLP
  Test::new(
    "PLP *",
    initial=State::new(pc=0x1000, s=0xFE, ram=[
      (0x1000, 0x28), // PLP
      (0x01FF, @cpu.ALL),
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ALL,
      ram=[],
    ),
    cycle=4,
  ),

  /// Transfer

  // TXS X → S
  // TXS $nn
  Test::new(
    "TXS $nn",
    initial=State::new(
      pc=0x1000,
      s=0xFF,
      x=0x69,
      ram=[(0x1000, 0x9A)], // TXS $nn
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0x69,
      a=0x00,
      x=0x69,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),

  // TSX S → X [NZ]
  // TSX $nn
  Test::new(
    "TSX $nn",
    initial=State::new(pc=0x1000, s=0x69, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBA), // TSX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0x69,
      a=0x00,
      x=0x69,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TSX $nn
  Test::new(
    "TSX $nn Z",
    initial=State::new(pc=0x1000, s=0x00, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBA), // TSX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0x00,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TSX $nn
  Test::new(
    "TSX $nn N",
    initial=State::new(pc=0x1000, s=0xEE, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBA), // TSX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xEE,
      a=0x00,
      x=0xEE,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // TYA Y → A [NZ]
  // TYA $nn
  Test::new(
    "TYA $nn",
    initial=State::new(pc=0x1000, a=0xFF, y=0x69, p=@cpu.ALL, ram=[
      (0x1000, 0x98), // TYA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x69,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TYA $nn
  Test::new(
    "TYA $nn Z",
    initial=State::new(pc=0x1000, a=0xFF, y=0x00, p=@cpu.ALL, ram=[
      (0x1000, 0x98), // TYA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TYA $nn
  Test::new(
    "TYA $nn N",
    initial=State::new(pc=0x1000, a=0xFF, y=0xEE, p=@cpu.ALL, ram=[
      (0x1000, 0x98), // TYA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0xEE,
      x=0x00,
      y=0xEE,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // TXA X → A [NZ]
  // TXA $nn
  Test::new(
    "TXA $nn",
    initial=State::new(pc=0x1000, a=0xFF, x=0x69, p=@cpu.ALL, ram=[
      (0x1000, 0x8A), // TXA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x69,
      x=0x69,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TXA $nn
  Test::new(
    "TXA $nn Z",
    initial=State::new(pc=0x1000, a=0xFF, x=0x00, p=@cpu.ALL, ram=[
      (0x1000, 0x8A), // TXA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TXA $nn
  Test::new(
    "TXA $nn N",
    initial=State::new(pc=0x1000, a=0xFF, x=0xEE, p=@cpu.ALL, ram=[
      (0x1000, 0x8A), // TXA $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0xEE,
      x=0xEE,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // TAY A → Y [NZ]
  // TAY $nn
  Test::new(
    "TAY $nn",
    initial=State::new(pc=0x1000, a=0x69, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA8), // TAY $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x69,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TAY $nn
  Test::new(
    "TAY $nn Z",
    initial=State::new(pc=0x1000, a=0x00, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA8), // TAY $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TAY $nn
  Test::new(
    "TAY $nn N",
    initial=State::new(pc=0x1000, a=0xEE, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA8), // TAY $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0xEE,
      x=0x00,
      y=0xEE,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // TAX A → X [NZ]
  // TAX $nn
  Test::new(
    "TAX $nn",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xAA), // TAX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x69,
      x=0x69,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TAX $nn
  Test::new(
    "TAX $nn Z",
    initial=State::new(pc=0x1000, a=0x00, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xAA), // TAX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // TAX $nn
  Test::new(
    "TAX $nn N",
    initial=State::new(pc=0x1000, a=0xEE, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xAA), // TAX $nn
    ]),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0xEE,
      x=0xEE,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // SHS A ∧ X → S, S ∧ (H + 1) → M
  // SHS $nnnn,Y
  Test::new(
    "SHS $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0x01, ram=[
      (0x1000, 0x9B), // SHS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x69, // S
      a=0x69,
      x=0xFF,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x49)], // M
    ),
    cycle=5,
  ),
  // SHS $nnnn,Y
  Test::new(
    "SHS $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0xFF, ram=[
      (0x1000, 0x9B), // SHS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0x49AC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x69,
      a=0x69,
      x=0xFF,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0x49AC, 0x49)], // M
    ),
    cycle=5,
  ),

  /// Store

  // STY Y → M
  // STY $nnnn
  Test::new(
    "STY $nnnn",
    initial=State::new(pc=0x1000, y=0x69, ram=[
      (0x1000, 0x8C), // STY $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x69,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=4,
  ),

  // STY #$nn
  Test::new(
    "STY #$nn",
    initial=State::new(pc=0x1000, y=0x69, ram=[
      (0x1000, 0x84), // STY #$nn
      (0x1001, 0x88), // #$nn
      (0x0088, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x69,
      p=@cpu.NONE,
      ram=[(0x0088, 0x69)], // M
    ),
    cycle=3,
  ),

  // STY $nn,X
  Test::new(
    "STY $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, y=0x69, ram=[
      (0x1000, 0x94), // STY $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x69,
      p=@cpu.NONE,
      ram=[(0x0087, 0x69)], // M
    ),
    cycle=4,
  ),

  // STX X → M
  //  $nnnn
  Test::new(
    "STX $nnnn",
    initial=State::new(pc=0x1000, x=0x69, ram=[
      (0x1000, 0x8E), // STX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x69,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=4,
  ),

  // STX #$nn
  Test::new(
    "STX #$nn",
    initial=State::new(pc=0x1000, x=0x69, ram=[
      (0x1000, 0x86), // STX #$nn
      (0x1001, 0x88), // #$nn
      (0x0088, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x69,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0x0088, 0x69)], // M
    ),
    cycle=3,
  ),

  // STX $nn,Y
  Test::new(
    "STX $nn,Y",
    initial=State::new(pc=0x1000, x=0x69, y=0xFF, ram=[
      (0x1000, 0x96), // STX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x69,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0x0087, 0x69)], // M
    ),
    cycle=4,
  ),

  // STA A → M
  // STA $nnnn
  Test::new(
    "STA $nnnn",
    initial=State::new(pc=0x1000, a=0x69, ram=[
      (0x1000, 0x8D), // STA $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=4,
  ),

  // STA $nnnn,X
  Test::new(
    "STA $nnnn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0x01, ram=[
      (0x1000, 0x9D), // STA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0x01,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x69)], // M
    ),
    cycle=5,
  ),
  // STA $nnnn,X
  Test::new(
    "STA $nnnn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, ram=[
      (0x1000, 0x9D), // STA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDFAC, 0x69)], // M
    ),
    cycle=5,
  ),

  // STA $nnnn,Y
  Test::new(
    "STA $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, y=0x01, ram=[
      (0x1000, 0x99), // STA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x69)], // M
    ),
    cycle=5,
  ),
  // STA $nnnn,Y
  Test::new(
    "STA $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, y=0xFF, ram=[
      (0x1000, 0x99), // STA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0xDFAC, 0x69)], // M
    ),
    cycle=5,
  ),

  // STA #$nn
  Test::new(
    "STA #$nn",
    initial=State::new(pc=0x1000, a=0x69, ram=[
      (0x1000, 0x85), // STA #$nn
      (0x1001, 0x88), // #$nn
      (0x0088, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0x0088, 0x69)], // M
    ),
    cycle=3,
  ),

  // STA $nn,X
  Test::new(
    "STA $nn,X",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, ram=[
      (0x1000, 0x95), // STA $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0x0087, 0x69)], // M
    ),
    cycle=4,
  ),

  // STA ($nn,X)
  Test::new(
    "STA ($nn,X)",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, ram=[
      (0x1000, 0x81), // STA ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=6,
  ),

  // STA ($nn),Y
  Test::new(
    "STA ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, y=0x01, ram=[
      (0x1000, 0x91), // STA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x69)], // M
    ),
    cycle=6,
  ),
  // STA ($nn),Y
  Test::new(
    "STA ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, y=0xFF, ram=[
      (0x1000, 0x91), // STA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0x00,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0xDFAC, 0x69)], // M
    ),
    cycle=6,
  ),

  // SHY Y ∧ (H + 1) → M
  // SHY $nnnn,X
  Test::new(
    "SHY $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, y=0xFF, ram=[
      (0x1000, 0x9C), // SHY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0xDF)], // M
    ),
    cycle=5,
  ),
  // SHY $nnnn,X
  Test::new(
    "SHY $nnnn,X",
    initial=State::new(pc=0x1000, x=0xFF, y=0xFF, ram=[
      (0x1000, 0x9C), // SHY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0xDFAC, 0xDF)], // M
    ),
    cycle=5,
  ),

  // SHX X ∧ (H + 1) → M
  // SHX $nnnn,Y
  Test::new(
    "SHX $nnnn,Y",
    initial=State::new(pc=0x1000, x=0xFF, y=0x01, ram=[
      (0x1000, 0x9E), // SHX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0xDF)], // M
    ),
    cycle=5,
  ),
  // SHX $nnnn,Y
  Test::new(
    "SHX $nnnn,Y",
    initial=State::new(pc=0x1000, x=0xFF, y=0xFF, ram=[
      (0x1000, 0x9E), // SHX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0xDFAC, 0xDF)], // M
    ),
    cycle=5,
  ),

  // SHA A ∧ X ∧ V → M
  // SHA $nnnn,Y
  Test::new(
    "SHA $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0x01, ram=[
      (0x1000, 0x9F), // SHA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x49)], // M
    ),
    cycle=5,
  ),
  // SHA $nnnn,Y
  Test::new(
    "SHA $nnnn,Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0xFF, ram=[
      (0x1000, 0x9F), // SHA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0x49AC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0x49AC, 0x49)], // M
    ),
    cycle=5,
  ),

  // SHA ($nn),Y
  Test::new(
    "SHA ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0x01, ram=[
      (0x1000, 0x93), // SHA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x01,
      p=@cpu.NONE,
      ram=[(0xDEAE, 0x49)], // M
    ),
    cycle=6,
  ),
  // SHA ($nn),Y
  Test::new(
    "SHA ($nn),Y",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, y=0xFF, ram=[
      (0x1000, 0x93), // SHA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0x49AC, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0x49AC, 0x49)], // M
    ),
    cycle=6,
  ),

  // SAX A ∧ X → M
  // SAX $nnnn
  Test::new(
    "SAX $nnnn",
    initial=State::new(pc=0x1000, a=0xFF, x=0x69, ram=[
      (0x1000, 0x8F), // SAX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xFF,
      x=0x69,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=4,
  ),

  // SAX #$nn
  Test::new(
    "SAX #$nn",
    initial=State::new(pc=0x1000, a=0xFF, x=0x69, ram=[
      (0x1000, 0x87), // SAX #$nn
      (0x1001, 0x88), // #$nn
      (0x0088, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xFF,
      x=0x69,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0x0088, 0x69)], // M
    ),
    cycle=3,
  ),

  // SAX $nn,Y
  Test::new(
    "SAX $nn,Y",
    initial=State::new(pc=0x1000, a=0xFF, x=0x69, y=0xFF, ram=[
      (0x1000, 0x97), // SAX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xFF,
      x=0x69,
      y=0xFF,
      p=@cpu.NONE,
      ram=[(0x0087, 0x69)], // M
    ),
    cycle=4,
  ),

  // SAX ($nn,X)
  Test::new(
    "SAX ($nn,X)",
    initial=State::new(pc=0x1000, a=0x69, x=0xFF, ram=[
      (0x1000, 0x83), // SAX ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, -1),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69,
      x=0xFF,
      y=0x00,
      p=@cpu.NONE,
      ram=[(0xDEAD, 0x69)], // M
    ),
    cycle=6,
  ),

  /// Load

  // LDY M → Y [NZ]
  // LDY #$nn
  Test::new(
    "LDY #$nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA0), // LDY #$nn
      (0x1001, 0x69), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDY #$nn
  Test::new(
    "LDY #$nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA0), // LDY #$nn
      (0x1001, 0x00), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDY #$nn
  Test::new(
    "LDY #$nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA0), // LDY #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // LDY $nnnn
  Test::new(
    "LDY $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAC), // LDY $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDY $nnnn
  Test::new(
    "LDY $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAC), // LDY $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDY $nnnn
  Test::new(
    "LDY $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAC), // LDY $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x01,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDY $nnnn,X
  Test::new(
    "LDY $nnnn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBC), // LDY $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // LDY $nn
  Test::new(
    "LDY $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA4), // LDY $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDY $nn
  Test::new(
    "LDY $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA4), // LDY $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDY $nn
  Test::new(
    "LDY $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA4), // LDY $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),

  // LDY $nn,X
  Test::new(
    "LDY $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB4), // LDY $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x69, // M 
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDY $nn,X
  Test::new(
    "LDY $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB4), // LDY $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0x00, // M 
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDY $nn,X
  Test::new(
    "LDY $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB4), // LDY $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xFF,
      y=0xEE, // M 
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDX M → X [NZ]
  // LDX #$nn
  Test::new(
    "LDX #$nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA2), // LDX #$nn
      (0x1001, 0x69), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDX #$nn
  Test::new(
    "LDX #$nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA2), // LDX #$nn
      (0x1001, 0x00), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDX #$nn
  Test::new(
    "LDX #$nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA2), // LDX #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // LDX $nnnn
  Test::new(
    "LDX $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAE), // LDX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDX $nnnn
  Test::new(
    "LDX $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAE), // LDX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDX $nnnn
  Test::new(
    "LDX $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAE), // LDX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDX $nnnn,Y
  Test::new(
    "LDX $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBE), // LDX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // LDX $nn
  Test::new(
    "LDX $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA6), // LDX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDX $nn
  Test::new(
    "LDX $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA6), // LDX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDX $nn
  Test::new(
    "LDX $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA6), // LDX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),

  // LDX $nn,Y
  Test::new(
    "LDX $nn,Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB6), // LDX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x69, // M 
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDX $nn,Y
  Test::new(
    "LDX $nn,Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB6), // LDX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0x00, // M 
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDX $nn,Y
  Test::new(
    "LDX $nn,Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB6), // LDX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00,
      x=0xEE, // M 
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDA M → A [NZ]
  // LDA #$nn
  Test::new(
    "LDA #$nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA9), // LDA #$nn
      (0x1001, 0x69), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDA #$nn
  Test::new(
    "LDA #$nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA9), // LDA #$nn
      (0x1001, 0x00), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LDA #$nn
  Test::new(
    "LDA #$nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA9), // LDA #$nn
      (0x1001, 0xEE), // #$nn
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // LDA $nnnn
  Test::new(
    "LDA $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAD), // LDA $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDA $nnnn
  Test::new(
    "LDA $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAD), // LDA $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDA $nnnn
  Test::new(
    "LDA $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAD), // LDA $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x01,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x01,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X N",
    initial=State::new(pc=0x1000, x=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0x01,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDA $nnnn,X
  Test::new(
    "LDA $nnnn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBD), // LDA $nnnn,X
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LDA $nnnn,Y
  Test::new(
    "LDA $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB9), // LDA $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // LDA $nn
  Test::new(
    "LDA $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA5), // LDA $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDA $nn
  Test::new(
    "LDA $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA5), // LDA $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LDA $nn
  Test::new(
    "LDA $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA5), // LDA $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),

  // LDA $nn,X
  Test::new(
    "LDA $nn,X",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB5), // LAX $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDA $nn,X
  Test::new(
    "LDA $nn,X Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB5), // LDA $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LDA $nn,X
  Test::new(
    "LDA $nn,X N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB5), // LDA $nn,X
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LDA ($nn,X)
  Test::new(
    "LDA ($nn,X)",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA1), // LDA ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0xFF,
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // LDA ($nn,X)
  Test::new(
    "LDA ($nn,X) Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA1), // LDA ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // LDA ($nn,X)
  Test::new(
    "LDA ($nn,X) N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA1), // LDA ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0xEE),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xFF,
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),

  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y Z",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y N",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x00,
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // LDA ($nn),Y
  Test::new(
    "LDA ($nn),Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB1), // LDA ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0x00,
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),

  // LAS $nnnn,Y
  Test::new(
    "LAS $nnnn,Y",
    initial=State::new(pc=0x1000, s=0x11, a=0x69, y=0x01, ram=[
      (0x1000, 0xBB), // LAS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x01), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x01, // M ∧ S 
      a=0x01, // M ∧ S 
      x=0x01, // M ∧ S 
      y=0x01,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LAS $nnnn,Y
  Test::new(
    "LAS $nnnn,Y",
    initial=State::new(pc=0x1000, s=0x11, a=0x69, y=0xFF, ram=[
      (0x1000, 0xBB), // LAS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x01), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x01, // M ∧ S 
      a=0x01, // M ∧ S 
      x=0x01, // M ∧ S 
      y=0xFF,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LAS $nnnn,Y
  Test::new(
    "LAS $nnnn,Y Z",
    initial=State::new(pc=0x1000, s=0x11, a=0x69, y=0x01, ram=[
      (0x1000, 0xBB), // LAS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x00, // M ∧ S 
      a=0x00, // M ∧ S 
      x=0x00, // M ∧ S 
      y=0x01,
      p=@cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LAS $nnnn,Y
  Test::new(
    "LAS $nnnn,Y N",
    initial=State::new(pc=0x1000, s=0x81, a=0x69, y=0x01, ram=[
      (0x1000, 0xBB), // LAS $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xF0), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0x80, // M ∧ S 
      a=0x80, // M ∧ S 
      x=0x80, // M ∧ S 
      y=0x01,
      p=@cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),

  // LAX M → A, X [NZ]
  // LAX #$nn
  Test::new(
    "LAX #$nn",
    initial=State::new(pc=0x1000, a=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xAB), // LAX #$nn
      (0x1001, 0x69), // #$nn | MAGIC
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LAX #$nn
  Test::new(
    "LAX #$nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAB), // LAX #$nn
      (0x1001, 0x00), // #$nn | MAGIC
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),
  // LAX #$nn
  Test::new(
    "LAX #$nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAB), // LAX #$nn
      (0x1001, 0xEE), // #$nn | MAGIC
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=2,
  ),

  // LAX $nnnn
  Test::new(
    "LAX $nnnn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAF), // LAX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LAX $nnnn
  Test::new(
    "LAX $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAF), // LAX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LAX $nnnn
  Test::new(
    "LAX $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xAF), // LAX $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAD, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4, // 4 + p
  ),
  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),
  // LAX $nnnn,Y
  Test::new(
    "LAX $nnnn,Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xBF), // LAX $nnnn,Y
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 3,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=4 + 1, // 4 + p
  ),

  // LAX $nn
  Test::new(
    "LAX $nn",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA7), // LAX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LAX $nn
  Test::new(
    "LAX $nn Z",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA7), // LAX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),
  // LAX $nn
  Test::new(
    "LAX $nn N",
    initial=State::new(pc=0x1000, p=@cpu.ALL, ram=[
      (0x1000, 0xA7), // LAX $nn
      (0x1001, 0x88), // $nn
      (0x0088, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=3,
  ),

  // LAX $nn,Y
  Test::new(
    "LAX $nn,Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB7), // LAX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LAX $nn,Y
  Test::new(
    "LAX $nn,Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB7), // LAX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),
  // LAX $nn,Y
  Test::new(
    "LAX $nn,Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB7), // LAX $nn,Y
      (0x1001, 0x88), // $nn
      (0x0087, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=4,
  ),

  // LAX ($nn,X)
  Test::new(
    "LAX ($nn,X)",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA3), // LAX ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0x69),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x00,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // LAX ($nn,X)
  Test::new(
    "LAX ($nn,X) Z",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA3), // LAX ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0x00),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x00,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),
  // LAX ($nn,X)
  Test::new(
    "LAX ($nn,X) N",
    initial=State::new(pc=0x1000, x=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xA3), // LAX ($nn,X)
      (0x1001, 0x88), // $nn
      (0x0087, 0xAD), // ($nn,X)
      (0x0088, 0xDE), // ($nn,X)
      (0xDEAD, 0xEE),
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x00,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    cycle=6,
  ),

  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0x01,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y Z",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0x01,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y N",
    initial=State::new(pc=0x1000, y=0x01, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDEAE, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0x01,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5, // 5 + p
  ),
  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0x69), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x69, // M 
      x=0x69, // M 
      y=0xFF,
      p=@cpu.ALL ^ @cpu.ZERO ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y Z",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0x00), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0x00, // M 
      x=0x00, // M 
      y=0xFF,
      p=(@cpu.ALL | @cpu.ZERO) ^ @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),
  // LAX ($nn),Y
  Test::new(
    "LAX ($nn),Y N",
    initial=State::new(pc=0x1000, y=0xFF, p=@cpu.ALL, ram=[
      (0x1000, 0xB3), // LAX ($nn),Y
      (0x1001, 0x88), // $nn
      (0x0088, 0xAD), // ($nn,Y)
      (0x0089, 0xDE), // ($nn,Y)
      (0xDFAC, 0xEE), // M
    ]),
    final=State::new(
      pc=0x1000 + 2,
      s=0xFF,
      a=0xEE, // M 
      x=0xEE, // M 
      y=0xFF,
      p=(@cpu.ALL ^ @cpu.ZERO) | @cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    cycle=5 + 1, // 5 + p
  ),

  /// Flags
  // CLC
  Test::new(
    "CLC",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0x18)], // CLC
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),
  // CLC
  Test::new(
    "CLC C",
    initial=State::new(
      pc=0x1000,
      p=@cpu.CARRY,
      ram=[(0x1000, 0x18)], // CLC
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),

  // CLD
  Test::new(
    "CLD",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0xD8)], // CLD
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),
  // CLD
  Test::new(
    "CLD D",
    initial=State::new(
      pc=0x1000,
      p=@cpu.DECIMAL,
      ram=[(0x1000, 0xD8)], // CLD
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),

  // CLI
  Test::new(
    "CLI",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0x58)], // CLI
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),
  // CLI
  Test::new(
    "CLI I",
    initial=State::new(
      pc=0x1000,
      p=@cpu.INTERRUPT,
      ram=[(0x1000, 0x58)], // CLI
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),

  // CLV
  Test::new(
    "CLV",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0xB8)], // CLV
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),
  // CLV
  Test::new(
    "CLV V",
    initial=State::new(
      pc=0x1000,
      p=@cpu.OVERFLOW,
      ram=[(0x1000, 0xB8)], // CLV
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=2,
  ),

  // SEC
  Test::new(
    "SEC",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0x38)], // SEC
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),
  // SEC
  Test::new(
    "SEC C",
    initial=State::new(
      pc=0x1000,
      p=@cpu.CARRY,
      ram=[(0x1000, 0x38)], // SEC
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.CARRY,
      ram=[],
    ),
    cycle=2,
  ),

  // SED
  Test::new(
    "SED",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0xF8)], // SED
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.DECIMAL,
      ram=[],
    ),
    cycle=2,
  ),
  // SED
  Test::new(
    "SED D",
    initial=State::new(
      pc=0x1000,
      p=@cpu.DECIMAL,
      ram=[(0x1000, 0xF8)], // SED
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.DECIMAL,
      ram=[],
    ),
    cycle=2,
  ),

  // SEI
  Test::new(
    "SEI",
    initial=State::new(
      pc=0x1000,
      ram=[(0x1000, 0x78)], // SEI
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.INTERRUPT,
      ram=[],
    ),
    cycle=2,
  ),
  // SEI
  Test::new(
    "SEI I",
    initial=State::new(
      pc=0x1000,
      p=@cpu.INTERRUPT,
      ram=[(0x1000, 0x78)], // SEI
    ),
    final=State::new(
      pc=0x1000 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.INTERRUPT,
      ram=[],
    ),
    cycle=2,
  ),

  /// Branch
  // BCC $nnnn
  Test::new(
    "BCC $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x90), // BCC $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BCC $nnnn
  Test::new(
    "BCC $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x90), // BCC $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),
  // BCC $nnnn
  Test::new(
    "BCC $nnnn C",
    initial=State::new(pc=0x1000, p=@cpu.CARRY, ram=[
      (0x1000, 0x90), // BCC $nnnn
      (0x1001, 0x01), // $00nn
    ]),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.CARRY, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2
  ),

  // BCS $nnnn
  Test::new(
    "BCS $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0xB0), // BCS $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2 
  ),
  // BCS $nnnn
  Test::new(
    "BCS $nnnn C",
    initial=State::new(
      pc=0x1000,
      p=@cpu.CARRY,
      ram=[
        (0x1000, 0xB0), // BCS $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.CARRY,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BCS $nnnn
  Test::new(
    "BCS $nnnn C",
    initial=State::new(
      pc=0x1000,
      p=@cpu.CARRY,
      ram=[
        (0x1000, 0xB0), // BCS $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.CARRY,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),

  // BEQ $nnnn
  Test::new(
    "BEQ $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0xF0), // BEQ $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2 
  ),
  // BEQ $nnnn
  Test::new(
    "BEQ $nnnn Z",
    initial=State::new(
      pc=0x1000,
      p=@cpu.ZERO,
      ram=[
        (0x1000, 0xF0), // BEQ $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BEQ $nnnn
  Test::new(
    "BEQ $nnnn Z",
    initial=State::new(
      pc=0x1000,
      p=@cpu.ZERO,
      ram=[
        (0x1000, 0xF0), // BEQ $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.ZERO,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),

  // BMI $nnnn
  Test::new(
    "BMI $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x30), // BBMIEQ $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2 
  ),
  // BMI $nnnn
  Test::new(
    "BMI $nnnn Z",
    initial=State::new(
      pc=0x1000,
      p=@cpu.NEGATIVE,
      ram=[
        (0x1000, 0x30), // BMI $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BMI $nnnn
  Test::new(
    "BMI $nnnn N",
    initial=State::new(
      pc=0x1000,
      p=@cpu.NEGATIVE,
      ram=[
        (0x1000, 0x30), // BMI $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),

  // BNE $nnnn
  Test::new(
    "BNE $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0xD0), // BNE $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BNE $nnnn
  Test::new(
    "BNE $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0xD0), // BNE $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),
  // BNE $nnnn
  Test::new(
    "BNE $nnnn Z",
    initial=State::new(pc=0x1000, p=@cpu.ZERO, ram=[
      (0x1000, 0xD0), // BNE $nnnn
      (0x1001, 0x01), // $00nn
    ]),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.ZERO, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2
  ),

  // BPL $nnnn
  Test::new(
    "BPL $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x10), // BPL $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BPL $nnnn
  Test::new(
    "BPL $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x10), // BPL $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),
  // BPL $nnnn
  Test::new(
    "BPL $nnnn N",
    initial=State::new(pc=0x1000, p=@cpu.NEGATIVE, ram=[
      (0x1000, 0x10), // BPL $nnnn
      (0x1001, 0x01), // $00nn
    ]),
    final=State::new(
      pc=0x1002,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NEGATIVE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2
  ),

  // BVC $nnnn
  Test::new(
    "BVC $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x50), // BVC $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BVC $nnnn
  Test::new(
    "BVC $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x50), // BVC $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),
  // BVC $nnnn
  Test::new(
    "BVC $nnnn V",
    initial=State::new(pc=0x1000, p=@cpu.OVERFLOW, ram=[
      (0x1000, 0x50), // BVC $nnnn
      (0x1001, 0x01), // $00nn
    ]),
    final=State::new(
      pc=0x1002,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.OVERFLOW,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2
  ),

  // BVS $nnnn
  Test::new(
    "BVS $nnnn",
    initial=State::new(
      pc=0x1000,
      ram=[
        (0x1000, 0x70), // BVS $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(pc=0x1002, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2, // 2 
  ),
  // BVS $nnnn
  Test::new(
    "BVS $nnnn V",
    initial=State::new(
      pc=0x1000,
      p=@cpu.OVERFLOW,
      ram=[
        (0x1000, 0x70), // BVS $nnnn
        (0x1001, 0x01),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.OVERFLOW,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1, // 2 + t
  ),
  // BVS $nnnn
  Test::new(
    "BVS $nnnn V",
    initial=State::new(
      pc=0x1000,
      p=@cpu.OVERFLOW,
      ram=[
        (0x1000, 0x70), // BVS $nnnn
        (0x1001, 0xFD),
      ], // $00nn
    ),
    final=State::new(
      pc=0x1002 - 3,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.OVERFLOW,
      ram=[],
    ),
    // p: =1 if page is crossed.
    // t: =1 if branch is taken.
    cycle=2 + 1 + 1, // 2 + t + p
  ),

  /// Control
  // BRK
  Test::new(
    "BRK",
    initial=State::new(pc=0x1000, ram=[
      (0x1000, 0x00), // BRK
      (@cpu.IRQ + 1, 0xDE),
      (@cpu.IRQ + 0, 0xAD),
    ]),
    final=State::new(
      pc=0xDEAD,
      s=0xFC,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.INTERRUPT,
      ram=[
        // Stack
        (0x01FD, 0x30),
        (0x01FE, 0x02),
        (0x01FF, 0x10),
      ],
    ),
    cycle=7,
  ),

  // JMP $nnnn
  Test::new(
    "JMP $nnnn",
    initial=State::new(pc=0x1000, ram=[
      (0x1000, 0x4C), // JMP $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
    ]),
    final=State::new(pc=0xDEAD, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    cycle=3,
  ),
  // JMP ($nnnn)
  Test::new(
    "JMP ($nnnn)",
    initial=State::new(pc=0x1000, ram=[
      (0x1000, 0x6C), // JMP ($nnnn)
      (0x1001, 0x34), // $00nn
      (0x1002, 0x12), // $nn00
      (0x1234, 0xAD),
      (0x1235, 0xDE),
    ]),
    final=State::new(pc=0xDEAD, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[]),
    cycle=5,
  ),

  // JSR $nnnn
  Test::new(
    "JSR $nnnn",
    initial=State::new(pc=0x1000, ram=[
      (0x1000, 0x20), // JSR $nnnn
      (0x1001, 0xAD), // $00nn
      (0x1002, 0xDE), // $nn00
    ]),
    final=State::new(pc=0xDEAD, s=0xFD, a=0x00, x=0x00, y=0x00, p=@cpu.NONE, ram=[
      // Stack
      (0x01FE, 0x02),
      (0x01FF, 0x10),
    ]),
    cycle=6,
  ),

  // RTI
  Test::new(
    "RTI",
    initial=State::new(pc=0x1000, s=0xFC, ram=[
      (0x1000, 0x40), // RTI
      // Stack
      (0x01FD, 0x30),
      (0x01FE, 0xAD),
      (0x01FF, 0xDE),
    ]),
    final=State::new(pc=0xDEAD, s=0xFF, a=0x00, x=0x00, y=0x00, p=@cpu.UNUSED, ram=[]),
    cycle=6,
  ),

  // RTS
  Test::new(
    "RTS",
    initial=State::new(pc=0x1000, s=0xFD, ram=[
      (0x1000, 0x60), // RTS
      // Stack
      (0x01FE, 0xAD),
      (0x01FF, 0xDE),
    ]),
    final=State::new(
      pc=0xDEAD + 1,
      s=0xFF,
      a=0x00,
      x=0x00,
      y=0x00,
      p=@cpu.NONE,
      ram=[],
    ),
    cycle=6,
  ),
]

///|
fn benchmark() -> Unit! {
  // let path = "tests/65x02/6502/v1/"
  // let testcases : Array[Test] = match
  //   @fs.read_file_to_string?(path + "00.json") {
  //   Ok(data) => @json.from_json!(@json.parse!(data))
  //   Err(error) => {
  //     println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
  //     abort("file not found")
  //   }
  // }
  for i, testcase in testcases {
    println("\{testcase.name}" + "\u{1B}[s\u{1B}[1A")
    // println("[\{testcase.name}]" + " " + "#\{i}" + "\u{1B}[s\u{1B}[1A")
    let cpu = CPU::new!(debug~)
    let mut cycles = 0
    let summary = @bench.single_bench(name=testcase.name, fn() {
      benchmark_setup(cpu, testcase)
      cycles = cpu.step()
      // cpu.reset()
    }).to_json()
    match testcase.final {
      None => ignore(testcase.final)
      Some(final) => {
        verify!("PC", testcase, final.pc, cpu.pc)
        match final.s {
          None => ignore(final.s)
          Some(s) => verify!("SP", testcase, s, cpu.registers[SP])
        }
        match final.a {
          None => ignore(final.a)
          Some(a) => verify!("A", testcase, a, cpu.registers[A])
        }
        match final.x {
          None => ignore(final.x)
          Some(x) => verify!("X", testcase, x, cpu.registers[X])
        }
        match final.y {
          None => ignore(final.y)
          Some(y) => verify!("Y", testcase, y, cpu.registers[Y])
        }
        match final.p {
          None => ignore(final.p)
          Some(p) => verify!("P", testcase, p, cpu.flags.get())
        }

        //
        match final.ram {
          None => ignore(final.ram)
          Some(ram) =>
            for data in ram {
              let (address, value) = data
              verify!("\{address}", testcase, value, cpu.mem[address._])
            }
        }
      }
    }

    //
    match testcase.cycle {
      None => ignore(testcase.cycle)
      Some(cycle) => verify!("CYC", testcase, cycle, cycles)
    }

    //
    benchmark_summary(summary)
  }
}

///|
fn benchmark_setup(cpu : CPU, testcase : Test) -> Unit {
  match testcase.initial {
    None => ignore(testcase.initial)
    Some(initial) => {
      cpu.set_pc(initial.pc)

      //
      cpu.set_registers(Registers::new())
      match initial.s {
        None => ignore(initial.s)
        Some(s) => cpu.registers[SP] = s
      }
      match initial.a {
        None => ignore(initial.a)
        Some(a) => cpu.registers[A] = a
      }
      match initial.x {
        None => ignore(initial.x)
        Some(x) => cpu.registers[X] = x
      }
      match initial.y {
        None => ignore(initial.y)
        Some(y) => cpu.registers[Y] = y
      }

      //
      cpu.set_flags(Flags::new(initial.p))

      //
      match initial.ram {
        None => ignore(initial.ram)
        Some(ram) =>
          for data in ram {
            let (address, value) = data
            cpu.mem[address._] = value
          }
      }
    }
  }
}

///|
fn benchmark_summary(summary : Json) -> Unit {
  let fixed = fn(a : Double) -> String {
    let a = a.to_string()
    match a.find(".") {
      None => a
      Some(i) =>
        a.substring(start=0, end=i).pad_start(1, ' ') +
        a.substring(start=i, end=i + 5).pad_end(5, '0') +
        "µs"
    }
  }
  let obj = summary.as_object().unwrap()
  let name = obj["name"].unwrap().as_string().unwrap()
  let runs = obj["runs"].unwrap().as_number().unwrap()
  let batches = obj["batch_size"].unwrap().as_number().unwrap()
  let mean = obj["mean"].unwrap().as_number().unwrap()
  let std_dev = obj["std_dev"].unwrap().as_number().unwrap()
  let median = obj["median"].unwrap().as_number().unwrap()
  let median_abs_dev = obj["median_abs_dev"].unwrap().as_number().unwrap()
  println("\{name}" + " " + "\u{1B}[32;1m✔️\u{1B}[0m")
  println("\{runs} × \{batches}")
  println("\{fixed(mean)} ±\{fixed(std_dev)}")
  println("\{fixed(median)} ±\{fixed(median_abs_dev)}")
}
