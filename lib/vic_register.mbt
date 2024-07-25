/// MOS 6566 VIDEO INTERFACE CONTROLLER (VIC)

enum VICregister {
  Sprite0XPos
  Sprite0YPos
  Sprite1XPos
  Sprite1YPos
  Sprite2XPos
  Sprite2YPos
  Sprite3XPos
  Sprite3YPos
  Sprite4XPos
  Sprite4YPos
  Sprite5XPos
  Sprite5YPos
  Sprite6XPos
  Sprite6YPos
  Sprite7XPos
  Sprite7YPos
  SpritesXPos
  //
  ControlRegisterVertical
  //
  ///  RASTER REGISTER
  ///
  ///    The raster register is found in the VIC-II chip at location 53266
  ///  ($D012). The raster register is a dual purpose register. When you read
  ///  this register it returns the lower 8 bits of the current raster position.
  ///  The raster position of the most significant bit is in register location
  ///  53265 ($D011). You use the raster register to set up timing changes in
  ///  your display so that you can get rid of screen flicker. The changes on
  ///  your screen should be made when the raster is not in the visible display
  ///  area, which is when your dot positions fall between 51 and 251.
  ///    When the raster register is written to (including the MSB) the number
  ///  written to is saved for use with the raster compare function. When the
  ///  actual raster value becomes the same as the number written to the raster
  ///  register, a bit in the VIC-II chip interrupt register 53273 ($D019) is
  ///  turned ON by setting it to 1.
  ///
  ///  +-----------------------------------------------------------------------+
  ///  | NOTE: If the proper interrupt bit is enabled (turned on), an interrupt|
  ///  | (IRQ) will occur.                                                     |
  ///  +-----------------------------------------------------------------------+
  ///
  ReadRasterWriteRasterValue
  LightPenLatchXPos
  LightPenLatchYPos
  SpriteDisplayEnable
  //
  ControlRegisterHorizontal
  //
  SpritesExpand2xVertical
  //
  MemoryControlRegister
  //
  ///  INTERRUPT STATUS REGISTER
  ///
  ///    The interrupt status register shows the current status of any interrupt
  ///  source. The current status of bit 2 of the interrupt register will be a 1
  ///  when two sprites hit each other. The same is true, in a corresponding 1
  ///  to 1 relationship, for bits 0-3 listed in the chart below. Bit 7 is also
  ///  set with a 1, whenever an interrupt occurs.
  ///    The interrupt status register is located at 53273 ($D019) and is as
  ///  follows:
  ///
  ///    LATCH  BIT#             DESCRIPTION
  ///  -------------------------------------------------------------------------
  ///    IRST    0   Set when current raster count = stored raster count
  ///    IMDC    1   Set by SPRITE-DATA collision (1st one only, until reset)
  ///    IMMC    2   Set by SPRITE-SPRITE collision (1st one only, until reset)
  ///     ILP    3   Set by negative transition of light pen (1 per frame)
  ///     IRQ    7   Set by latch set and enabled
  ///  -------------------------------------------------------------------------
  ///
  InterruptFlagRegister
  //
  IRQMaskRegister
  SpriteBackgroundDisplayPriority
  SpritesMultiColorModeSelect
  SpritesExpand2xHorizontal
  //
  SpriteSpriteCollisionDetect
  SpriteBackgroundCollisionDetect
  BorderColor
  BackgroundColor0
  BackgroundColor1
  BackgroundColor2
  BackgroundColor3
  SpriteMultiColorRegister0
  SpriteMultiColorRegister1
  //
  Sprite0Color
  Sprite1Color
  Sprite2Color
  Sprite3Color
  Sprite4Color
  Sprite5Color
  Sprite6Color
  Sprite7Color
} derive(Show, Compare, Eq)

fn vic(register : VICregister) -> Int {
  match register {
    Sprite0XPos => 0x00 /// Sprite 0 X Pos
    Sprite0YPos => 0x01 /// Sprite 0 Y Pos
    Sprite1XPos => 0x02 /// Sprite 1 X Pos
    Sprite1YPos => 0x03 /// Sprite 1 Y Pos
    Sprite2XPos => 0x04 /// Sprite 2 X Pos
    Sprite2YPos => 0x05 /// Sprite 2 Y Pos
    Sprite3XPos => 0x06 /// Sprite 3 X Pos
    Sprite3YPos => 0x07 /// Sprite 3 Y Pos
    Sprite4XPos => 0x08 /// Sprite 4 X Pos
    Sprite4YPos => 0x09 /// Sprite 4 Y Pos
    Sprite5XPos => 0x0A /// Sprite 5 X Pos
    Sprite5YPos => 0x0B /// Sprite 5 Y Pos
    Sprite6XPos => 0x0C /// Sprite 6 X Pos
    Sprite6YPos => 0x0D /// Sprite 6 Y Pos
    Sprite7XPos => 0x0E /// Sprite 7 X Pos
    Sprite7YPos => 0x0F /// Sprite 7 Y Pos
    SpritesXPos => 0x10 /// Sprites 0-7 X Pos (msb of X coord.)
    //
    ControlRegisterVertical => 0x11 /// VIC Control Register
    //
    ReadRasterWriteRasterValue => 0x12 /// Read Raster / Write Raster Value for Compare IRQ
    LightPenLatchXPos => 0x13 /// Light-Pen Latch X Pos
    LightPenLatchYPos => 0x14 /// Light-Pen Latch Y Pos
    SpriteDisplayEnable => 0x15 /// Sprite display Enable: 1 = Enable
    //
    ControlRegisterHorizontal => 0x16 /// VIC Control Register
    //
    SpritesExpand2xVertical => 0x17 /// Sprites 0-7 Expand 2x Vertical (Y)
    //
    MemoryControlRegister => 0x18 /// VIC Memory Control Register
    //
    InterruptFlagRegister => 0x19 /// VIC Interrupt Flag Register (Bit = 1: IRQ	Occurred)
    //
    IRQMaskRegister => 0x1A /// IRQ Mask Register: 1 = Interrupt Enabled
    SpriteBackgroundDisplayPriority => 0x1B ///	Sprite to Background Display Priority: 1 = Sprite
    SpritesMultiColorModeSelect => 0x1C ///	Sprites 0-7 Multi-Color Mode Select: 1 = M.C.M.
    SpritesExpand2xHorizontal => 0x1D ///	Sprites 0-7 Expand 2x Horizontal (X)
    //
    SpriteSpriteCollisionDetect => 0x1E /// Sprite to Sprite Collision Detect
    SpriteBackgroundCollisionDetect => 0x1F ///	Sprite to Background Collision Detect
    BorderColor => 0x20 /// Border Color
    BackgroundColor0 => 0x21 /// Background Color 0
    BackgroundColor1 => 0x22 /// Background Color 1
    BackgroundColor2 => 0x23 /// Background Color 2
    BackgroundColor3 => 0x24 /// Background Color 3
    SpriteMultiColorRegister0 => 0x25 /// Sprite Multi-Color Register 0
    SpriteMultiColorRegister1 => 0x26 /// Sprite Multi-Color Register 1
    //
    Sprite0Color => 0x27 /// Sprite 0 Color
    Sprite1Color => 0x28 /// Sprite 1 Color
    Sprite2Color => 0x29 /// Sprite 2 Color
    Sprite3Color => 0x2A /// Sprite 3 Color
    Sprite4Color => 0x2B /// Sprite 4 Color
    Sprite5Color => 0x2C /// Sprite 5 Color
    Sprite6Color => 0x2D /// Sprite 6 Color
    Sprite7Color => 0x2E /// Sprite 7 Color
  }
}

enum ControlRegisterVertical {
  RasterCompare
  ExtendedColorTextMode
  BitMapMode
  BlankScreenBorderColor
  SelectRowTextDisplay
  SmoothScrollYDotPosition
}

fn op_get(
  self : ControlRegisterVertical,
  flag : ControlRegisterVertical
) -> Int {
  match flag {
    /// Raster Compare: (Bit 8)	See $D012
    RasterCompare => 1 << 7
    /// Extended Color Text Mode 1 = Enable
    ExtendedColorTextMode => 1 << 6
    /// Bit Map Mode. 1 = Enable
    BitMapMode => 1 << 5
    /// Blank Screen to Border Color: 0 = Blank
    BlankScreenBorderColor => 1 << 4
    /// Select 24/25 Row Text Display: 1 = 25 Rows
    SelectRowTextDisplay => 1 << 3
    /// Smooth Scroll to Y Dot-Position (0-7)
    SmoothScrollYDotPosition => (1 << 2) | (1 << 1) | (1 << 0)
  }
}

fn cr(flag : ControlRegisterVertical) -> Int {
  flag[flag]
}

enum ControlRegisterHorizontal {
  Unused /// 	7-6	Unused
  MultiColorMode /// 	4	  Multi-Color Mode: 1 = Enable (Text or Bit-Map)
  SelectColumnTextDisplay /// 	3	  Select 38/40 Column Text Display: 1 = 40 Cols
  SmoothScrollXPos /// 	2-0	Smooth Scroll to X Pos
}

enum MemoryControlRegister {
  VideoMatrixBaseAddress /// 	7-4	Video Matrix Base Address (inside VIC)
  CharacterDotDataBaseAddress /// 	3-1	Character Dot-Data Base	Address (inside VIC)
  SelectCharacterSet /// 	0	  Select upper/lower Character Set
}

enum InterruptFlagRegister {
  SetAnyEnabledVICIRQCondition /// 	7	  Set on Any Enabled VIC IRQ Condition
  LightPenTriggeredIRQFlag /// 	3	  Light-Pen Triggered IRQ Flag
  SpriteSpriteCollisionIRQFlag /// 	2	  Sprite to Sprite Collision IRQ Flag
  SpriteBackgroundCollisionIRQFlag /// 	1	  Sprite to Background Collision IRQ Flag
  RasterCompareIRQFlag /// 	0	  Raster Compare IRQ Flag
}

fn op_get(self : InterruptFlagRegister, flag : InterruptFlagRegister) -> Int {
  match flag {
    /// VIC Interrupt Flag Register (Bit = 1: IRQ	Occurred)
    SetAnyEnabledVICIRQCondition => 1 << 7
  }
}

fn irqFlag(flag : InterruptFlagRegister) -> Int {
  flag[flag]
}

enum IRQMaskRegister {
  InterruptEnabled
}

fn op_get(self : IRQMaskRegister, flag : IRQMaskRegister) -> Int {
  match flag {
    /// IRQ Mask Register: 1 = Interrupt Enabled
    InterruptEnabled => 1 << 0
  }
}

fn irqMask(flag : IRQMaskRegister) -> Int {
  flag[flag]
}
