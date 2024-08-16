/// MOS 6566 VIDEO INTERFACE CONTROLLER (VIC)

/// VIC Interrupt Flag Register
///
/// The VIC-II chip is capable of generating a maskable request (IRQ) when
/// certain conditions relating to the video display are fulfilled.
struct VICInterruptFlag {
  /// Bit 0:  Flag:  Is the Raster Compare a possible source of an IRQ? (1=yes)
  mut rasterCompare : Bool
  /// Bit 1:  Flag:  Is a collision between a sprite and the normal graphics display a possible source of an IRQ?  (1=yes)
  mut spriteCollide : Bool
  /// Bit 2:  Flag:  Is a collision between two sprites a possible source of an IRQ?  (1=yes)
  mut spritesCollide : Bool
  /// Bit 3:  Flag:  Is the light pen trigger a possible source of an IRQ? (1=yes)
  mut lightPenTrigger : Bool
  /// Bits 4-6:  Not used
  /// Bit 7:  Flag:  Is there any VIC-II chip IRQ source which could cause an IRQ?  (1=yes)
  mut vicIRQ : Bool
} derive(Default)

/// IRQ Mask Register
///
/// This register is used to enable an IRQ request to occur when one of
/// the VIC-II chip interrupt conditions is met.
struct IRQMask {
  /// Bit 0:  Enable Raster Compare IRQ (1=interrupt enabled)
  mut rasterCompare : Bool
  /// Bit 1:  Enable IRQ to occure when sprite collides with display of normal graphics data (1=interrupt enabled)
  mut spriteCollide : Bool
  /// Bit 2:  Enable IRQ to occur when two sprites collide (1=interrupt enabled)
  mut spritesCollide : Bool
  /// Bit 3:  Enable light pen to trigger an IRQ (1=interrupt enabled)
  mut lightPenTrigger : Bool
  /// Bits 4-7:  Not used
} derive(Default)

struct ControlRegister {
  /// SCROLY
  mut rowDisplay : Bool
  mut blankScreen : Bool
  mut bitmapMode : Bool
  mut extendedColorMode : Bool

  /// SCROLX
  mut columnDisplay : Bool
  mut multicolorMode : Bool
  mut videoChipReset : Bool
} derive(Default)

struct Coordinate {
  mut x : Int
  mut y : Int
} derive(Default)

struct VICRegister {
  spritePosition : FixedArray[Coordinate]
  spriteEnable : FixedArray[Bool]
  spriteExpandX : FixedArray[Bool]
  spriteExpandY : FixedArray[Bool]
  spritePriority : FixedArray[Bool]
  spriteMode : FixedArray[Bool]
  spriteCollide : FixedArray[Bool]
  spritesCollide : FixedArray[Bool]

  ///
  mut borderColor : Color
  backgroundColor : FixedArray[Color]
  spriteMulticolor : FixedArray[Color]
  spriteColor : FixedArray[Color]

  ///
  scroll : Coordinate

  ///
  controlRegister : ControlRegister
  interruptFlag : VICInterruptFlag
  irqMask : IRQMask

  ///
  mut rasterScanLine : Int

  ///
  lightPen : Coordinate

  ///
  mut characterDataArea : Int
  mut videoMatrixArea : Int
}

fn VICRegister::default() -> VICRegister {
  {
    spritePosition: FixedArray::make(8, Coordinate::default()),
    /// In order for any sprite to be displayed, the corresponding bit in this
    /// register must be set to 1 (the default for this location is 0).
    spriteEnable: FixedArray::make(8, false),
    spriteExpandX: FixedArray::make(8, false),
    spriteExpandY: FixedArray::make(8, false),
    spritePriority: FixedArray::make(8, false),
    spriteMode: FixedArray::make(8, false),
    spriteCollide: FixedArray::make(8, false),
    spritesCollide: FixedArray::make(8, false),

    ///
    borderColor: LightBlue,
    backgroundColor: [Blue, White, Red, Cyan],
    spriteMulticolor: [Purple, Black],
    spriteColor: [White, Red, Cyan, Purple, Green, Blue, Yellow, MediumGray],

    ///
    scroll: Coordinate::default(),

    ///
    controlRegister: ControlRegister::default(),
    interruptFlag: VICInterruptFlag::default(),
    irqMask: IRQMask::default(),

    ///
    rasterScanLine: Int::default(),

    ///
    lightPen: Coordinate::default(),

    ///
    characterDataArea: Int::default(),
    videoMatrixArea: Int::default(),
  }
}

enum VICregister {
  /// Location Range: 53248-53264 ($D000-$D010)
  /// Sprite Horizontal and Vertical Position Registers

  /// $00 - $01
  /// Sprite 0 Horizontal Position
  SP0X
  /// Sprite 0 Vertical Position
  SP0Y

  /// $02 - $03
  /// Sprite 1 Horizontal Position
  SP1X
  /// Sprite 1 Vertical Position
  SP1Y

  /// $04 - $05
  /// Sprite 2 Horizontal Position
  SP2X
  /// Sprite 2 Vertical Position
  SP2Y

  /// $06 - $07
  /// Sprite 3 Horizontal Position
  SP3X
  /// Sprite 3 Vertical Position
  SP3Y

  /// $08 - $09
  /// Sprite 4 Horizontal Position
  SP4X
  /// Sprite 4 Vertical Position
  SP4Y

  /// $0A - $0B
  /// Sprite 5 Horizontal Position
  SP5X
  /// Sprite 5 Vertical Position
  SP5Y

  /// $0C - $0D
  /// Sprite 6 Horizontal Position
  SP6X
  /// Sprite 6 Vertical Position
  SP6Y

  /// $0E - $0F
  /// Sprite 7 Horizontal Position
  SP7X
  /// Sprite 7 Vertical Position
  SP7Y

  /// $10
  /// Most Significant Bits of Sprites 0-7 Horizontal Position
  MSIGX

  /// $11
  /// Vertical Fine Scrolling and Control Register
  SCROLY

  /// $12
  /// Read Current Raster Scan Line/Write Line to Compare for Raster IRQ
  RASTER

  /// Location Range: 53267-53268 ($D013-$D014)
  /// Light Pen Registers

  /// $13 - $14
  /// Light Pen Horizontal Position
  LPENX
  /// Light Pen Vertical Position
  LPENY

  /// $15
  /// Sprite Enable Register
  SPENA

  /// $16
  /// Horizontal Fine Scrolling and Control Register
  SCROLX

  /// $17
  /// Sprite Vertical Expansion Register
  YXPAND

  /// $18
  /// VIC-II Chip Memory Control Register
  VMCSB

  /// $19
  /// VIC Interrupt Flag Register
  VICIRQ
  /// $1A
  /// IRQ Mask Register
  IRQMASK

  /// $1B
  /// Sprite to Foreground Display Priority Register
  SPBGPR
  /// $1C
  /// Sprite Multicolor Registers
  SPMC

  /// $1D
  /// Sprite Horizontal Expansion Register
  XXPAND

  /// Location Range: 53278-53279 ($D01E-$D01F)
  /// Sprite Collision Detection Registers

  /// $1E
  /// Sprite to Sprite Collision Register
  SPSPCL
  /// $1F
  /// Sprite to Foreground Collision Register
  SPBGCL

  /// Location Range: 53280-53294 ($D020-$D02E)
  /// VIC-II Color Register

  /// $20
  /// Border Color Register
  EXTCOL
  /// Background Color 0
  BGCOL0
  /// Background Color 1
  BGCOL1
  /// Background Color 2
  BGCOL2
  /// Background Color 3
  BGCOL3
  /// Sprite Multicolor Register 0
  SPMC0
  /// Sprite Multicolor Register 1
  SPMC1

  /// Location Range: 53287-53294 ($D027-$D02E)
  /// Sprite Color Registers

  /// Sprite 0 Color Register (the default color value is 1, white)
  SP0COL
  /// Sprite 1 Color Register (the default color value is 2, red)
  SP1COL
  /// Sprite 2 Color Register (the default color value is 3, cyan)
  SP2COL
  /// Sprite 3 Color Register (the default color value is 4, purple)
  SP3COL
  /// Sprite 4 Color Register (the default color value is 5, green)
  SP4COL
  /// Sprite 5 Color Register (the default color value is 6, blue)
  SP5COL
  /// Sprite 6 Color Register (the default color value is 7, yellow)
  SP6COL
  /// Sprite 7 Color Register (the default color value is 12, medium gray)
  SP7COL
} derive(Show, Compare, Eq)

fn vic(register : VICregister) -> Int {
  match register {
    SP0X => 0x00
    SP0Y => 0x01
    SP1X => 0x02
    SP1Y => 0x03
    SP2X => 0x04
    SP2Y => 0x05
    SP3X => 0x06
    SP3Y => 0x07
    SP4X => 0x08
    SP4Y => 0x09
    SP5X => 0x0A
    SP5Y => 0x0B
    SP6X => 0x0C
    SP6Y => 0x0D
    SP7X => 0x0E
    SP7Y => 0x0F
    MSIGX => 0x10
    //
    SCROLY => 0x11
    RASTER => 0x12
    //
    LPENX => 0x13
    LPENY => 0x14
    SPENA => 0x15
    //
    SCROLX => 0x16
    YXPAND => 0x17
    //
    VMCSB => 0x18
    //
    VICIRQ => 0x19
    IRQMASK => 0x1A
    //
    SPBGPR => 0x1B
    SPMC => 0x1C
    XXPAND => 0x1D
    //
    SPSPCL => 0x1E
    SPBGCL => 0x1F
    //
    EXTCOL => 0x20
    BGCOL0 => 0x21
    BGCOL1 => 0x22
    BGCOL2 => 0x23
    BGCOL3 => 0x24
    SPMC0 => 0x25
    SPMC1 => 0x26
    //
    SP0COL => 0x27
    SP1COL => 0x28
    SP2COL => 0x29
    SP3COL => 0x2A
    SP4COL => 0x2B
    SP5COL => 0x2C
    SP6COL => 0x2D
    SP7COL => 0x2E
  }
}

fn VICregister::from_int(value : Int) -> VICregister! {
  match value {
    0x00 => SP0X
    0x01 => SP0Y
    0x02 => SP1X
    0x03 => SP1Y
    0x04 => SP2X
    0x05 => SP2Y
    0x06 => SP3X
    0x07 => SP3Y
    0x08 => SP4X
    0x09 => SP4Y
    0x0A => SP5X
    0x0B => SP5Y
    0x0C => SP6X
    0x0D => SP6Y
    0x0E => SP7X
    0x0F => SP7Y
    0x10 => MSIGX

    //
    0x11 => SCROLY
    0x12 => RASTER
    //
    0x13 => LPENX
    0x14 => LPENY
    0x15 => SPENA
    //
    0x16 => SCROLX
    0x17 => YXPAND
    //
    0x18 => VMCSB
    //
    0x19 => VICIRQ
    0x1A => IRQMASK
    //
    0x1B => SPBGPR
    0x1C => SPMC
    0x1D => XXPAND
    //
    0x1E => SPSPCL
    0x1F => SPBGCL
    //
    0x20 => EXTCOL
    0x21 => BGCOL0
    0x22 => BGCOL1
    0x23 => BGCOL2
    0x24 => BGCOL3
    0x25 => SPMC0
    0x26 => SPMC1
    //
    0x27 => SP0COL
    0x28 => SP1COL
    0x29 => SP2COL
    0x2A => SP3COL
    0x2B => SP4COL
    0x2C => SP5COL
    0x2D => SP6COL
    0x2E => SP7COL

    ///
    _ => raise UnknownRegister("VIC", value)
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
