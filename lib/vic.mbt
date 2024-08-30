/// MOS 6566 VIDEO INTERFACE CONTROLLER (VIC)
///
/// $D000-$D02E
/// VIC-II Chip Registers
///
/// All of the graphics abilities of the Commodore 64 come from the 6567
/// Video Interface Chip (also known as the VIC-II chip). This chip gives a
/// variety of graphics modes, including a 40 column by 25 line text display,
/// a 320 by 200 dot high resolution display, and SPRITES, small movable
/// objects which make writing games simple. And if this weren't enough,
/// many of the graphics modes can be mixed on the same screen. It is
/// possible, for example, to define the top half of the screen to be in
/// high resolution mode, while the bottom half is in text mode. And SPRITES
/// will combine with anything! More on sprites later. First the other
/// graphics modes.

/// ($D02F-$D03F)
/// Not Connected
///
/// The VIC-II chip has only 47 registers for 64 bytes of possible address
/// space.  Therefore, the remaining 17 addresses do not access any
/// memory.  When read, they will always give a value of 255 ($FF).  This
/// value will not change after writing to them.

/// ($D040-$D3FF)
/// VIC-II Register Images
///
/// Since the VIC-II requires only enough addressing lines to handle 64
/// locations (the minimum possible for its 47 registers), none of the
/// higher bits are decoded when addressing this 1K area.  The result is
/// that every 64 byte area in this 1K block is a mirror of every other.

pub let vic_mem_start = 0xD000

let vic_mem_end = 0xD3FF

let vic_mem_size = 0x03FF

struct VIC {
  mem : FixedArray[Int]
  baseaddress : Int

  //
  mut rowCycleCount : Int
  mut rasterRowCycles : Int
  mut rasterLines : Int

  //
  mut rasterCompare : Int

  //
  register : VICRegister

  //
  mut debug : Bool
}

pub fn VIC::new(
  cpu : @cpu.CPU,
  baseaddress : Int,
  ~videoStandard : VideoStandard = Unknown,
  ~debug : Bool = false
) -> VIC {
  println("VIC::new")
  let mem = FixedArray::make(vic_mem_size + 1, 0x00)
  let vic : VIC = {
    mem,
    baseaddress,

    //
    rowCycleCount: 0,
    rasterRowCycles: 0,
    rasterLines: 0,

    //
    rasterCompare: 0,

    //
    register: VICRegister::default(),

    //
    debug,
  }
  cpu
  .mem()
  .hook(
    baseaddress,
    baseaddress + vic_mem_size,
    mem,
    fn(address : Int, debug : Bool?) {
      let register = try {
        VICregister::from_int!(address - baseaddress)
      } catch {
        err => {
          println(err)
          panic()
        }
      }
      vic[register].0
    },
    fn(address : Int, value : Int, debug : Bool?) {
      let register = try {
        VICregister::from_int!(address - baseaddress)
      } catch {
        err => {
          println(err)
          panic()
        }
      }
      vic[register] = value
    },
  )
  try {
    vic.reset!(~videoStandard)
  } catch {
    err => {
      println(err)
      panic()
    }
  }
  vic
}

/// These registers are all intialized to 0 at power-up.
pub fn reset(self : VIC, ~videoStandard : VideoStandard = Unknown) -> Unit! {
  // self.mem.reset(offset=self.baseaddress, length=vic_mem_length)
  for i = 0; i < self.mem.length(); i = i + 1 {
    self.mem[i] = 0x00
  }

  // realSID
  // self[SCROLY] = 0x8B
  // self[RASTER] = 0x37

  /// Control Register #1
  /// Bit#0-#2: Screen Soft Scroll Vertical
  /// Bit#3: Switch to 25 visible rows
  /// Bit#4: Switch VIC-II output on
  /// Bit#5: Turn Bitmap Mode off
  /// Bit#6: Turn Extended Color Mode off
  /// Bit#7: 9th Bit for $D012 Rasterline counter
  self[SCROLY] = 0b10011011

  /// Control Register 2
  /// Bit#0-#2: Screen Soft Scroll Horizontal
  /// Bit#3: Switch to 40 visible columns
  /// Bit#4: Turn Multicolor Mode off
  /// Bit#5-#7: not used
  self[SCROLX] = 0b00001000

  /// VIC-II base addresses
  /// Bit#0: not used
  /// Bit#1-#3: Address Bits 11-13 of the Character Set (*2048)
  /// Bit#4-#7: Address Bits 10-13 of the Screen RAM (*1024)
  self[VMCSB] = 0b00010100

  /// Interrupt Request Register
  /// Bit#0: Interrupt by Rasterline triggered when high
  /// Bit#1: Interrupt by Spite-Background collision triggered when high
  /// Bit#2: Interrupt by Sprite-Sprite collision triggered when high
  /// Bit#3: Interrupt by Lightpen impulse triggered when high
  /// Bit#4-#6: not used
  /// Bit#7: If set high at least one of the Interrupts above were triggered
  self[VICIRQ] = 0b00001111

  /// Interrupt Mask Register
  /// Bit#0: Request Interrupt by Rasterline by setting high
  /// Bit#1: Request Interrupt by Spite-Background collision by setting high
  /// Bit#2: Request Interrupt by Sprite-Sprite collision by setting high
  /// Bit#3: Request Interrupt by Lightpen impulse by setting high
  /// Bit#4-#7: not used
  self[IRQMASK] = 0b00000000

  /// ($D02F-$D03F)
  /// Not Connected
  ///
  /// The VIC-II chip has only 47 registers for 64 bytes of possible address
  /// space.  Therefore, the remaining 17 addresses do not access any
  /// memory.  When read, they will always give a value of 255 ($FF).  This
  /// value will not change after writing to them.
  for i = 0xD02F - self.baseaddress; i <= 0xD03F - 0xD02F; i = i + 1 {
    self.mem[i] = 0xFF
  }

  //
  self.rasterLines = ScanLines(videoStandard).to_int!() // HINT: should be inferred
  self.rasterRowCycles = ScanLineCycles(videoStandard).to_int!() // HINT: should be inferred
}

pub fn emulate(self : VIC, cycles : Int) -> Bool {
  // if self.debug {
  //   println(">> VIC::emulate [\{cycles}]")
  // }
  //

  //
  self.rowCycleCount += cycles

  // did we complete one raster row (horizontal beam)?
  if self.rowCycleCount >= self.rasterRowCycles {
    self.rowCycleCount -= self.rasterRowCycles

    //
    // let mut rasterRow = self.register.rasterScanLine + 1
    // if rasterRow >= self.rasterCompare {
    //   rasterRow = 0
    // }
    // self[SCROLY] = self[SCROLY] | ((rasterRow & 0x0100) >> 1)
    // self[RASTER] = rasterRow & 0xFF
    self.register.rasterScanLine += 1
    println(
      "VIC RASTER \{self.register.rasterScanLine} >= \{self.rasterCompare}",
    )
    if self.register.rasterScanLine >= self.rasterLines {
      self.register.rasterScanLine = 0
    }

    //
    // if self.register.irqMask.interruptEnable {
    //   println("IRQMASK::InterruptEnable")
    if self.register.rasterScanLine == self.rasterCompare &&
      self.register.irqMask.rasterCompare {
      self.register.interruptFlag.rasterCompare = true
      println("VICIRQ::RasterScan \{self.register.interruptFlag}")
    }
    // }
  }
  self.register.interruptFlag.vicIRQ = self.register.interruptFlag.rasterCompare

  //
  // if self.debug {
  //   println("<< VIC::emulate [\{cycles}]")
  // }

  //
  self.register.interruptFlag.vicIRQ
}

// pub fn acknowledgeVICrasterIRQ(self : VIC) -> Unit {
//   self[VICIRQ] = self[VICIRQ].clr(irqMask(InterruptEnabled))
//   self[VICIRQ] = self[VICIRQ].clr(
//     irqFlag(SetAnyEnabledVICIRQCondition) | irqMask(InterruptEnabled),
//   )
// }

fn op_get(self : VIC, register : VICregister) -> UInt8 {
  // VIC-II Register Images
  let address = vic(register) % 0x40 // (repeated every $40, 64 bytes)
  if self.debug {
    println(
      "💻 VIC $" +
      UInt16(self.baseaddress + address).to_hex() +
      " → #$" +
      UInt8(self.mem[address]).to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < vic_mem_start ||
    self.baseaddress + address > vic_mem_end {
    // self.dump()
    println(
      "VIC \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " → #$" +
      UInt8(self.mem[address]).to_hex(),
    )
    abort("out of bounds")
  }
  fn msbX(value : Int, bit : Int) -> Int {
    ((value >> 8) & 1) << bit
  }

  match register {
    /// Sprite Horizontal and Vertical Position Registers
    SP0X => u8(self.register.spritePosition[0].x)
    SP0Y => u8(self.register.spritePosition[0].y)
    SP1X => u8(self.register.spritePosition[1].x)
    SP1Y => u8(self.register.spritePosition[1].y)
    SP2X => u8(self.register.spritePosition[2].x)
    SP2Y => u8(self.register.spritePosition[2].y)
    SP3X => u8(self.register.spritePosition[3].x)
    SP3Y => u8(self.register.spritePosition[3].y)
    SP4X => u8(self.register.spritePosition[4].x)
    SP4Y => u8(self.register.spritePosition[4].y)
    SP5X => u8(self.register.spritePosition[5].x)
    SP5Y => u8(self.register.spritePosition[5].y)
    SP6X => u8(self.register.spritePosition[6].x)
    SP6Y => u8(self.register.spritePosition[6].y)
    SP7X => u8(self.register.spritePosition[7].x)
    SP7Y => u8(self.register.spritePosition[7].y)

    /// Most Significant Bits of Sprites 0-7 Horizontal Position
    MSIGX =>
      /// Bit 0:  Most significant bit of Sprite 0 horizontal position
      msbX(self.register.spritePosition[0].x, 0) |
      /// Bit 1:  Most significant bit of Sprite 1 horizontal position
      msbX(self.register.spritePosition[1].x, 1) |
      /// Bit 2:  Most significant bit of Sprite 2 horizontal position
      msbX(self.register.spritePosition[2].x, 2) |
      /// Bit 3:  Most significant bit of Sprite 3 horizontal position
      msbX(self.register.spritePosition[3].x, 3) |
      /// Bit 4:  Most significant bit of Sprite 4 horizontal position
      msbX(self.register.spritePosition[4].x, 4) |
      /// Bit 5:  Most significant bit of Sprite 5 horizontal position
      msbX(self.register.spritePosition[5].x, 5) |
      /// Bit 6:  Most significant bit of Sprite 6 horizontal position
      msbX(self.register.spritePosition[6].x, 6) |
      /// Bit 7:  Most significant bit of Sprite 7 horizontal position
      msbX(self.register.spritePosition[7].x, 7)

    /// Vertical Fine Scrolling and Control Register
    SCROLY =>
      /// Bits 0-2:  Fine scroll display vertically by X scan lines (0-7)
      ((self.register.scroll.y & 0x08) << 0) |
      /// Bit 3:  Select a 24-row or 25-row text display (1=25 rows, 0=24 rows)
      (self.register.controlRegister.rowDisplay.to_int() << 3) |
      /// Bit 4:  Blank the entire screen to the same color as the background (0=blank)
      (self.register.controlRegister.blankScreen.to_int() << 4) |
      /// Bit 5:  Enable bitmap graphics mode (1=enable)
      (self.register.controlRegister.bitmapMode.to_int() << 5) |
      /// Bit 6:  Enable extended color text mode (1=enable)
      (self.register.controlRegister.extendedColorMode.to_int() << 6) |
      /// Bit 7:  High bit (Bit 8) of raster compare register at 53266 ($D012)
      msbX(self.register.rasterScanLine, 7)

    /// Read Current Raster Scan Line
    ///
    /// The Raster Compare register has two different functions, depending on
    /// whether you are reading from it or writing to it.  When this register
    /// is read, it tells which screen line the electron beam is currently
    /// scanning.
    RASTER => self.register.rasterScanLine

    /// Light Pen Horizontal Position
    LPENX => self.register.lightPen.x
    /// Light Pen Vertical Position
    LPENY => self.register.lightPen.y

    /// Sprite Enable Register
    SPENA =>
      /// Bit 0:  Enable Sprite 0 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[0].to_int() << 0) |
      /// Bit 1:  Enable Sprite 1 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[1].to_int() << 1) |
      /// Bit 2:  Enable Sprite 2 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[2].to_int() << 2) |
      /// Bit 3:  Enable Sprite 3 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[3].to_int() << 3) |
      /// Bit 4:  Enable Sprite 4 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[4].to_int() << 4) |
      /// Bit 5:  Enable Sprite 5 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[5].to_int() << 5) |
      /// Bit 6:  Enable Sprite 6 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[6].to_int() << 6) |
      /// Bit 7:  Enable Sprite 7 (1=sprite is on, 0=sprite is off)
      (self.register.spriteEnable[7].to_int() << 7)

    /// Horizontal Fine Scrolling and Control Register
    SCROLX =>
      /// Bits 0-2:  Fine scroll display horizontally by X dot positions (0-7)
      ((self.register.scroll.x & 0x08) << 0) |
      /// Bit 3:  Select a 38-column or 40-column text display (1=40 columns, 0=38 columns)
      (self.register.controlRegister.columnDisplay.to_int() << 3) |
      /// Bit 4:  Enable multicolor text or multicolor bitmap mode (1=multicolor on, 0=multicolor off)
      (self.register.controlRegister.multicolorMode.to_int() << 4) |
      /// Bit 5:  Video chip reset (0=normal operations, 1=video completely off)
      (self.register.controlRegister.videoChipReset.to_int() << 5)
    /// Bits 6-7:  Unused

    /// Sprite Horizontal Expansion Register
    XXPAND =>
      /// Bit 0:  Expand Sprite 0 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[0].to_int() << 0) |
      /// Bit 1:  Expand Sprite 1 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[1].to_int() << 1) |
      /// Bit 2:  Expand Sprite 2 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[2].to_int() << 2) |
      /// Bit 3:  Expand Sprite 3 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[3].to_int() << 3) |
      /// Bit 4:  Expand Sprite 4 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[4].to_int() << 4) |
      /// Bit 5:  Expand Sprite 5 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[5].to_int() << 5) |
      /// Bit 6:  Expand Sprite 6 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[6].to_int() << 6) |
      /// Bit 7:  Expand Sprite 7 horizontally (1=double-width sprite, 0=normal width)
      (self.register.spriteExpandX[7].to_int() << 7)

    /// Sprite Vertical Expansion Register
    YXPAND =>
      /// Bit 0:  Expand Sprite 0 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[0].to_int() << 0) |
      /// Bit 1:  Expand Sprite 1 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[1].to_int() << 1) |
      /// Bit 2:  Expand Sprite 2 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[2].to_int() << 2) |
      /// Bit 3:  Expand Sprite 3 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[3].to_int() << 3) |
      /// Bit 4:  Expand Sprite 4 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[4].to_int() << 4) |
      /// Bit 5:  Expand Sprite 5 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[5].to_int() << 5) |
      /// Bit 6:  Expand Sprite 6 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[6].to_int() << 6) |
      /// Bit 7:  Expand Sprite 7 vertically (1=double height, 0=normal height)
      (self.register.spriteExpandY[7].to_int() << 7)

    /// VIC-II Chip Memory Control Register
    VMCSB =>
      /// Bit 0:  Unused; it is always set to 1.
      (1 << 0) |
      /// Bits 1-3:  Text character dot-data base address within VIC-II address space
      ((self.register.characterDataArea & 0x08) << 1) |
      /// Bits 4-7:  Video matrix base address within VIC-II address space
      ((self.register.videoMatrixArea & 0x08) << 4)

    /// VIC Interrupt Flag Register
    VICIRQ =>
      /// Bit 0:  Flag:  Is the Raster Compare a possible source of an IRQ? (1=yes)
      (self.register.interruptFlag.rasterCompare.to_int() << 0) |
      /// Bit 1:  Flag:  Is a collision between a sprite and the normal graphics display a possible source of an IRQ?  (1=yes)
      (self.register.interruptFlag.spriteCollide.to_int() << 1) |
      /// Bit 2:  Flag:  Is a collision between two sprites a possible source of an IRQ?  (1=yes)
      (self.register.interruptFlag.spritesCollide.to_int() << 2) |
      /// Bit 3:  Flag:  Is the light pen trigger a possible source of an IRQ? (1=yes)
      (self.register.interruptFlag.lightPenTrigger.to_int() << 3) |
      /// Bits 4-6:  Not used
      /// Bit 7:  Flag:  Is there any VIC-II chip IRQ source which could cause an IRQ?  (1=yes)
      (self.register.interruptFlag.vicIRQ.to_int() << 7)

    /// IRQ Mask Register
    IRQMASK =>
      /// Bit 0:  Enable Raster Compare IRQ (1=interrupt enabled)
      (self.register.irqMask.rasterCompare.to_int() << 0) |
      /// Bit 1:  Enable IRQ to occure when sprite collides with display of normal graphics data (1=interrupt enabled)
      (self.register.irqMask.spriteCollide.to_int() << 1) |
      /// Bit 2:  Enable IRQ to occur when two sprites collide (1=interrupt enabled)
      (self.register.irqMask.spritesCollide.to_int() << 2) |
      /// Bit 3:  Enable light pen to trigger an IRQ (1=interrupt enabled)
      (self.register.irqMask.lightPenTrigger.to_int() << 3)
    /// Bits 4-7:  Not used

    /// Sprite to Foreground Display Priority Register
    SPBGPR =>
      /// Bit 0:  Select display priority of Sprite 0 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[0].to_int() << 0) |
      /// Bit 1:  Select display priority of Sprite 1 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[1].to_int() << 1) |
      /// Bit 2:  Select display priority of Sprite 2 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[2].to_int() << 2) |
      /// Bit 3:  Select display priority of Sprite 3 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[3].to_int() << 3) |
      /// Bit 4:  Select display priority of Sprite 4 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[4].to_int() << 4) |
      /// Bit 5:  Select display priority of Sprite 5 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[5].to_int() << 5) |
      /// Bit 6:  Select display priority of Sprite 6 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[6].to_int() << 6) |
      /// Bit 7:  Select display priority of Sprite 7 to foreground (0=sprite appears in front of foreground)
      (self.register.spritePriority[7].to_int() << 7)

    /// Sprite Multicolor Registers
    SPMC =>
      /// Bit 0:  Select multicolor mode for Sprite 0 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[0].to_int() << 0) |
      /// Bit 1:  Select multicolor mode for Sprite 1 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[1].to_int() << 1) |
      /// Bit 2:  Select multicolor mode for Sprite 2 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[2].to_int() << 2) |
      /// Bit 3:  Select multicolor mode for Sprite 3 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[3].to_int() << 3) |
      /// Bit 4:  Select multicolor mode for Sprite 4 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[4].to_int() << 4) |
      /// Bit 5:  Select multicolor mode for Sprite 5 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[5].to_int() << 5) |
      /// Bit 6:  Select multicolor mode for Sprite 6 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[6].to_int() << 6) |
      /// Bit 7:  Select multicolor mode for Sprite 7 (1=multicolor, 0=hi-res)
      (self.register.spriteMode[7].to_int() << 7)

    /// Sprite to Foreground Collision Register
    SPBGCL =>
      /// Bit 0:  Did Sprite 0 collide with the foreground display?  (1=yes)
      (self.register.spriteCollide[0].to_int() << 0) |
      /// Bit 1:  Did Sprite 1 collide with the foreground display?  (1=yes)
      (self.register.spriteCollide[1].to_int() << 1) |
      /// Bit 2:  Did Sprite 2 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[2].to_int() << 2) |
      /// Bit 3:  Did Sprite 3 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[3].to_int() << 3) |
      /// Bit 4:  Did Sprite 4 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[4].to_int() << 4) |
      /// Bit 5:  Did Sprite 5 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[5].to_int() << 5) |
      /// Bit 6:  Did Sprite 6 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[6].to_int() << 6) |
      /// Bit 7:  Did Sprite 7 collide with the foreground display?  (1=yes)
      (self.register.spritesCollide[7].to_int() << 7)

    /// Sprite to Sprite Collision Register
    SPSPCL =>
      /// Bit 0:  Did Sprite 0 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[0].to_int() << 0) |
      /// Bit 1:  Did Sprite 1 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[1].to_int() << 1) |
      /// Bit 2:  Did Sprite 2 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[2].to_int() << 2) |
      /// Bit 3:  Did Sprite 3 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[3].to_int() << 3) |
      /// Bit 4:  Did Sprite 4 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[4].to_int() << 4) |
      /// Bit 5:  Did Sprite 5 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[5].to_int() << 5) |
      /// Bit 6:  Did Sprite 6 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[6].to_int() << 6) |
      /// Bit 7:  Did Sprite 7 collide with another sprite?  (1=yes)
      (self.register.spritesCollide[7].to_int() << 7)

    /// Border Color Register
    EXTCOL => self.register.borderColor.to_int()

    /// Background Color 0
    BGCOL0 => self.register.backgroundColor[0].to_int()
    /// Background Color 1
    BGCOL1 => self.register.backgroundColor[1].to_int()
    /// Background Color 2
    BGCOL2 => self.register.backgroundColor[2].to_int()
    /// Background Color 3
    BGCOL3 => self.register.backgroundColor[3].to_int()

    /// Sprite Multicolor Register 0
    SPMC0 => self.register.spriteMulticolor[0].to_int()
    /// Sprite Multicolor Register 1
    SPMC1 => self.register.spriteMulticolor[1].to_int()

    /// Sprite 0 Color Register
    SP0COL => self.register.spriteColor[0].to_int()
    /// Sprite 1 Color Register
    SP1COL => self.register.spriteColor[1].to_int()
    /// Sprite 2 Color Register
    SP2COL => self.register.spriteColor[2].to_int()
    /// Sprite 3 Color Register
    SP3COL => self.register.spriteColor[3].to_int()
    /// Sprite 4 Color Register
    SP4COL => self.register.spriteColor[4].to_int()
    /// Sprite 5 Color Register
    SP5COL => self.register.spriteColor[5].to_int()
    /// Sprite 6 Color Register
    SP6COL => self.register.spriteColor[6].to_int()
    /// Sprite 7 Color Register
    SP7COL => self.register.spriteColor[7].to_int()

    /// The VIC-II chip has only 47 registers for 64 bytes of possible address
    /// space.  Therefore, the remaining 17 addresses do not access any
    /// memory.  When read, they will always give a value of 255 ($FF).  This
    /// value will not change after writing to them.
    // _ => 0xFF
  }
}

fn op_set(self : VIC, register : VICregister, value : UInt8) -> Unit {
  // VIC-II Register Images
  let address = vic(register) % 0x40 // (repeated every $40, 64 bytes)
  if self.debug {
    println(
      "💻 VIC $" +
      UInt16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex() +
      " | \{register}",
    )
  }
  if self.baseaddress + address < vic_mem_start ||
    self.baseaddress + address > vic_mem_end {
    // self.dump()
    println(
      "VIC \{register} $" +
      UInt16(self.baseaddress + address).to_hex() +
      " ← #$" +
      value.to_hex(),
    )
    abort("out of bounds")
  }
  fn msbX(value : Int) -> Unit {
    let position = self.register.spritePosition
    /// Bit 0:  Most significant bit of Sprite 0 horizontal position
    position[0].x = position[0].x | (((value >> 0) & 1) << 8)
    /// Bit 1:  Most significant bit of Sprite 1 horizontal position
    position[1].x = position[1].x | (((value >> 1) & 1) << 8)
    /// Bit 2:  Most significant bit of Sprite 2 horizontal position
    position[2].x = position[2].x | (((value >> 2) & 1) << 8)
    /// Bit 3:  Most significant bit of Sprite 3 horizontal position
    position[3].x = position[3].x | (((value >> 3) & 1) << 8)
    /// Bit 4:  Most significant bit of Sprite 4 horizontal position
    position[4].x = position[4].x | (((value >> 4) & 1) << 8)
    /// Bit 5:  Most significant bit of Sprite 5 horizontal position
    position[5].x = position[5].x | (((value >> 5) & 1) << 8)
    /// Bit 6:  Most significant bit of Sprite 6 horizontal position
    position[6].x = position[6].x | (((value >> 6) & 1) << 8)
    /// Bit 7:  Most significant bit of Sprite 7 horizontal position
    position[7].x = position[7].x | (((value >> 7) & 1) << 8)
  }

  try {
    match register {
      /// Sprite Horizontal and Vertical Position Registers
      SP0X => self.register.spritePosition[0].x = value.0
      SP0Y => self.register.spritePosition[0].y = value.0
      SP1X => self.register.spritePosition[1].x = value.0
      SP1Y => self.register.spritePosition[1].y = value.0
      SP2X => self.register.spritePosition[2].x = value.0
      SP2Y => self.register.spritePosition[2].y = value.0
      SP3X => self.register.spritePosition[3].x = value.0
      SP3Y => self.register.spritePosition[3].y = value.0
      SP4X => self.register.spritePosition[4].x = value.0
      SP4Y => self.register.spritePosition[4].y = value.0
      SP5X => self.register.spritePosition[5].x = value.0
      SP5Y => self.register.spritePosition[5].y = value.0
      SP6X => self.register.spritePosition[6].x = value.0
      SP6Y => self.register.spritePosition[6].y = value.0
      SP7X => self.register.spritePosition[7].x = value.0
      SP7Y => self.register.spritePosition[7].y = value.0

      /// Most Significant Bits of Sprites 0-7 Horizontal Position
      MSIGX => msbX(value.0)

      /// Vertical Fine Scrolling and Control Register
      SCROLY => {
        /// Bits 0-2:  Fine scroll display vertically by X scan lines (0-7)
        self.register.scroll.y = value.0 & 0x08
        /// Bit 3:  Select a 24-row or 25-row text display (1=25 rows, 0=24 rows)
        self.register.controlRegister.rowDisplay = value.bit(3)
        /// Bit 4:  Blank the entire screen to the same color as the background (0=blank)
        self.register.controlRegister.blankScreen = value.bit(4)
        /// Bit 5:  Enable bitmap graphics mode (1=enable)
        self.register.controlRegister.bitmapMode = value.bit(5)
        /// Bit 6:  Enable extended color text mode (1=enable)
        self.register.controlRegister.extendedColorMode = value.bit(6)
        /// Bit 7:  High bit (Bit 8) of raster compare register at 53266 ($D012)
        self.rasterCompare = (self.rasterCompare & 0x00FF) |
          (value.bit(7).to_int() << 8)
      }

      /// Write Current Raster Scan Line to Compare for Raster IRQ
      ///
      /// Writing to this register designates the comparison value for the
      /// Raster Compare Interrupt.  When that interrupt is enabled, a maskable
      /// interrupt request will be issued every time the electron beam scan
      /// reaches the scan line whose number was written here.
      RASTER => self.rasterCompare = (self.rasterCompare & 0x0100) | value.0

      /// Light Pen Horizontal Position
      LPENX => self.register.lightPen.x = value.0
      /// Light Pen Vertical Position
      LPENY => self.register.lightPen.y = value.0

      /// Sprite Enable Register
      SPENA => {
        /// Bit 0:  Enable Sprite 0 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[0] = value.bit(0)
        /// Bit 1:  Enable Sprite 1 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[1] = value.bit(1)
        /// Bit 2:  Enable Sprite 2 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[2] = value.bit(2)
        /// Bit 3:  Enable Sprite 3 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[3] = value.bit(3)
        /// Bit 4:  Enable Sprite 4 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[4] = value.bit(4)
        /// Bit 5:  Enable Sprite 5 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[5] = value.bit(5)
        /// Bit 6:  Enable Sprite 6 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[6] = value.bit(6)
        /// Bit 7:  Enable Sprite 7 (1=sprite is on, 0=sprite is off)
        self.register.spriteEnable[7] = value.bit(7)
      }

      /// Horizontal Fine Scrolling and Control Register
      SCROLX => {
        /// Bits 0-2:  Fine scroll display horizontally by X dot positions (0-7)
        self.register.scroll.x = value.0 & 0x08
        /// Bit 3:  Select a 38-column or 40-column text display (1=40 columns, 0=38 columns)
        self.register.controlRegister.columnDisplay = value.bit(3)
        /// Bit 4:  Enable multicolor text or multicolor bitmap mode (1=multicolor on, 0=multicolor off)
        self.register.controlRegister.multicolorMode = value.bit(4)
        /// Bit 5:  Video chip reset (0=normal operations, 1=video completely off)
        self.register.controlRegister.videoChipReset = value.bit(5)
        /// Bits 6-7:  Unused
      }

      /// Sprite Horizontal Expansion Register
      XXPAND => {
        /// Bit 0:  Expand Sprite 0 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[0] = value.bit(0)
        /// Bit 1:  Expand Sprite 1 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[1] = value.bit(1)
        /// Bit 2:  Expand Sprite 2 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[2] = value.bit(2)
        /// Bit 3:  Expand Sprite 3 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[3] = value.bit(3)
        /// Bit 4:  Expand Sprite 4 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[4] = value.bit(4)
        /// Bit 5:  Expand Sprite 5 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[5] = value.bit(5)
        /// Bit 6:  Expand Sprite 6 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[6] = value.bit(6)
        /// Bit 7:  Expand Sprite 7 horizontally (1=double-width sprite, 0=normal width)
        self.register.spriteExpandX[7] = value.bit(7)
      }

      /// Sprite Vertical Expansion Register
      YXPAND => {
        /// Bit 0:  Expand Sprite 0 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[0] = value.bit(0)
        /// Bit 1:  Expand Sprite 1 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[1] = value.bit(1)
        /// Bit 2:  Expand Sprite 2 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[2] = value.bit(2)
        /// Bit 3:  Expand Sprite 3 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[3] = value.bit(3)
        /// Bit 4:  Expand Sprite 4 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[4] = value.bit(4)
        /// Bit 5:  Expand Sprite 5 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[5] = value.bit(5)
        /// Bit 6:  Expand Sprite 6 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[6] = value.bit(6)
        /// Bit 7:  Expand Sprite 7 vertically (1=double height, 0=normal height)
        self.register.spriteExpandY[7] = value.bit(7)
      }

      /// VIC-II Chip Memory Control Register
      VMCSB => {
        /// Bit 0:  Unused
        /// Bits 1-3:  Text character dot-data base address within VIC-II address space
        self.register.characterDataArea = (value.0 >> 1) & 0x08
        /// Bits 4-7:  Video matrix base address within VIC-II address space
        self.register.videoMatrixArea = (value.0 >> 4) & 0x08
      }

      /// VIC Interrupt Flag Register
      VICIRQ => {
        /// Bit 0:  Flag:  Is the Raster Compare a possible source of an IRQ? (1=yes)
        self.register.interruptFlag.rasterCompare = value.bit(0)
        /// Bit 1:  Flag:  Is a collision between a sprite and the normal graphics display a possible source of an IRQ?  (1=yes)
        self.register.interruptFlag.spriteCollide = value.bit(1)
        /// Bit 2:  Flag:  Is a collision between two sprites a possible source of an IRQ?  (1=yes)
        self.register.interruptFlag.spritesCollide = value.bit(2)
        /// Bit 3:  Flag:  Is the light pen trigger a possible source of an IRQ? (1=yes)
        self.register.interruptFlag.lightPenTrigger = value.bit(3)
        /// Bits 4-6:  Not used
        /// Bit 7:  Flag:  Is there any VIC-II chip IRQ source which could cause an IRQ?  (1=yes)
        self.register.interruptFlag.vicIRQ = value.bit(7)
      }

      /// IRQ Mask Register
      IRQMASK => {
        /// Bit 0:  Enable Raster Compare IRQ (1=interrupt enabled)
        self.register.irqMask.rasterCompare = value.bit(0)
        /// Bit 1:  Enable IRQ to occure when sprite collides with display of normal graphics data (1=interrupt enabled)
        self.register.irqMask.spriteCollide = value.bit(1)
        /// Bit 2:  Enable IRQ to occur when two sprites collide (1=interrupt enabled)
        self.register.irqMask.spritesCollide = value.bit(2)
        /// Bit 3:  Enable light pen to trigger an IRQ (1=interrupt enabled)
        self.register.irqMask.lightPenTrigger = value.bit(3)
        /// Bits 4-7:  Not used
        self.register.irqMask.interruptEnable = value.bit(7)
      }

      /// Sprite to Foreground Display Priority Register
      SPBGPR => {
        /// Bit 0:  Select display priority of Sprite 0 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[0] = value.bit(0)
        /// Bit 1:  Select display priority of Sprite 1 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[1] = value.bit(1)
        /// Bit 2:  Select display priority of Sprite 2 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[2] = value.bit(2)
        /// Bit 3:  Select display priority of Sprite 3 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[3] = value.bit(3)
        /// Bit 4:  Select display priority of Sprite 4 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[4] = value.bit(4)
        /// Bit 5:  Select display priority of Sprite 5 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[5] = value.bit(5)
        /// Bit 6:  Select display priority of Sprite 6 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[6] = value.bit(6)
        /// Bit 7:  Select display priority of Sprite 7 to foreground (0=sprite appears in front of foreground)
        self.register.spritePriority[7] = value.bit(7)
      }

      /// Sprite Multicolor Registers
      SPMC => {
        /// Bit 0:  Select multicolor mode for Sprite 0 (1=multicolor, 0=hi-res)
        self.register.spriteMode[0] = value.bit(0)
        /// Bit 1:  Select multicolor mode for Sprite 1 (1=multicolor, 0=hi-res)
        self.register.spriteMode[1] = value.bit(1)
        /// Bit 2:  Select multicolor mode for Sprite 2 (1=multicolor, 0=hi-res)
        self.register.spriteMode[2] = value.bit(2)
        /// Bit 3:  Select multicolor mode for Sprite 3 (1=multicolor, 0=hi-res)
        self.register.spriteMode[3] = value.bit(3)
        /// Bit 4:  Select multicolor mode for Sprite 4 (1=multicolor, 0=hi-res)
        self.register.spriteMode[4] = value.bit(4)
        /// Bit 5:  Select multicolor mode for Sprite 5 (1=multicolor, 0=hi-res)
        self.register.spriteMode[5] = value.bit(5)
        /// Bit 6:  Select multicolor mode for Sprite 6 (1=multicolor, 0=hi-res)
        self.register.spriteMode[6] = value.bit(6)
        /// Bit 7:  Select multicolor mode for Sprite 7 (1=multicolor, 0=hi-res)
        self.register.spriteMode[7] = value.bit(7)
      }

      /// Sprite to Foreground Collision Register
      SPBGCL => {
        /// Bit 0:  Did Sprite 0 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[0] = value.bit(0)
        /// Bit 1:  Did Sprite 1 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[1] = value.bit(1)
        /// Bit 2:  Did Sprite 2 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[2] = value.bit(2)
        /// Bit 3:  Did Sprite 3 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[3] = value.bit(3)
        /// Bit 4:  Did Sprite 4 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[4] = value.bit(4)
        /// Bit 5:  Did Sprite 5 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[5] = value.bit(5)
        /// Bit 6:  Did Sprite 6 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[6] = value.bit(6)
        /// Bit 7:  Did Sprite 7 collide with the foreground display?  (1=yes)
        self.register.spriteCollide[7] = value.bit(7)
      }

      /// Sprite to Sprite Collision Register
      SPSPCL => {
        /// Bit 0:  Did Sprite 0 collide with another sprite?  (1=yes)
        self.register.spritesCollide[0] = value.bit(0)
        /// Bit 1:  Did Sprite 1 collide with another sprite?  (1=yes)
        self.register.spritesCollide[1] = value.bit(1)
        /// Bit 2:  Did Sprite 2 collide with another sprite?  (1=yes)
        self.register.spritesCollide[2] = value.bit(2)
        /// Bit 3:  Did Sprite 3 collide with another sprite?  (1=yes)
        self.register.spritesCollide[3] = value.bit(3)
        /// Bit 4:  Did Sprite 4 collide with another sprite?  (1=yes)
        self.register.spritesCollide[4] = value.bit(4)
        /// Bit 5:  Did Sprite 5 collide with another sprite?  (1=yes)
        self.register.spritesCollide[5] = value.bit(5)
        /// Bit 6:  Did Sprite 6 collide with another sprite?  (1=yes)
        self.register.spritesCollide[6] = value.bit(6)
        /// Bit 7:  Did Sprite 7 collide with another sprite?  (1=yes)
        self.register.spritesCollide[7] = value.bit(7)
      }

      /// Border Color Register
      EXTCOL => self.register.borderColor = Color::from_int!(value.0)

      /// Background Color 0
      BGCOL0 => self.register.backgroundColor[0] = Color::from_int!(value.0)
      /// Background Color 1
      BGCOL1 => self.register.backgroundColor[1] = Color::from_int!(value.0)
      /// Background Color 2
      BGCOL2 => self.register.backgroundColor[2] = Color::from_int!(value.0)
      /// Background Color 3
      BGCOL3 => self.register.backgroundColor[3] = Color::from_int!(value.0)

      /// Sprite Multicolor Register 0
      SPMC0 => self.register.spriteMulticolor[0] = Color::from_int!(value.0)
      /// Sprite Multicolor Register 1
      SPMC1 => self.register.spriteMulticolor[1] = Color::from_int!(value.0)

      /// Sprite 0 Color Register
      SP0COL => self.register.spriteColor[0] = Color::from_int!(value.0)
      /// Sprite 1 Color Register
      SP1COL => self.register.spriteColor[1] = Color::from_int!(value.0)
      /// Sprite 2 Color Register
      SP2COL => self.register.spriteColor[2] = Color::from_int!(value.0)
      /// Sprite 3 Color Register
      SP3COL => self.register.spriteColor[3] = Color::from_int!(value.0)
      /// Sprite 4 Color Register
      SP4COL => self.register.spriteColor[4] = Color::from_int!(value.0)
      /// Sprite 5 Color Register
      SP5COL => self.register.spriteColor[5] = Color::from_int!(value.0)
      /// Sprite 6 Color Register
      SP6COL => self.register.spriteColor[6] = Color::from_int!(value.0)
      /// Sprite 7 Color Register
      SP7COL => self.register.spriteColor[7] = Color::from_int!(value.0)
    }
  } catch {
    err => {
      println(err)
      panic()
    }
  }
}
