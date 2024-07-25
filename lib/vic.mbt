/// $D000-$D02E
/// VIC-II Chip Registers
///
/// The Video Interface Controller (VIC-II chip) is a specially designed
/// processor that is in charge of the 64's video display.  It is this
/// chip which makes possible the 64's wide range of graphics
/// capabilities.

// https://www.zimmers.net/cbmpics/cbm/c64/vic-ii.txt

/// 6567 (NTSC)
/// 6569 (PAL)

struct VIC {
  mem : @cpu.Memory
  baseaddress : Int // VIC-baseaddress location in C64-memory (IO)
  //
  mut rasterLines : Int
  mut rasterRowCycles : Int
  mut rowCycleCount : Int
}

pub fn VIC::new(mem : @cpu.Memory, baseaddress : Int) -> VIC {
  let vic : VIC = {
    mem,
    baseaddress,
    //
    rasterLines: 0,
    rasterRowCycles: 0,
    rowCycleCount: 0,
  }
  vic.reset()
  vic
}

/// These registers are all intialized to 0 at power-up.
pub fn reset(self : VIC) -> Unit {
  for i = 0; i < 0x3F; i = i + 1 {
    self[Sprite0XPos] = 0x00
    self[Sprite0YPos] = 0x00
    self[Sprite1XPos] = 0x00
    self[Sprite1YPos] = 0x00
    self[Sprite2XPos] = 0x00
    self[Sprite2YPos] = 0x00
    self[Sprite3XPos] = 0x00
    self[Sprite3YPos] = 0x00
    self[Sprite4XPos] = 0x00
    self[Sprite4YPos] = 0x00
    self[Sprite5XPos] = 0x00
    self[Sprite5YPos] = 0x00
    self[Sprite6XPos] = 0x00
    self[Sprite6YPos] = 0x00
    self[Sprite7XPos] = 0x00
    self[Sprite7YPos] = 0x00
    self[SpritesXPos] = 0x00
    //
    self[ControlRegisterVertical] = 0x00
    //
    self[ReadRasterWriteRasterValue] = 0x00
    self[LightPenLatchXPos] = 0x00
    self[LightPenLatchYPos] = 0x00
    self[SpriteDisplayEnable] = 0x00
    //
    self[ControlRegisterHorizontal] = 0x00
    //
    self[SpritesExpand2xVertical] = 0x00
    //
    self[MemoryControlRegister] = 0x00
    //
    self[InterruptFlagRegister] = 0x00
    //
    self[IRQMaskRegister] = 0x00
    self[SpriteBackgroundDisplayPriority] = 0x00
    self[SpritesMultiColorModeSelect] = 0x00
    self[SpritesExpand2xHorizontal] = 0x00
    //
    self[SpriteSpriteCollisionDetect] = 0x00
    self[SpriteBackgroundCollisionDetect] = 0x00
    self[BorderColor] = 0x00
    self[BackgroundColor0] = 0x00
    self[BackgroundColor1] = 0x00
    self[BackgroundColor2] = 0x00
    self[BackgroundColor3] = 0x00
    self[SpriteMultiColorRegister0] = 0x00
    self[SpriteMultiColorRegister1] = 0x00
    //
    self[Sprite0Color] = 0x00
    self[Sprite1Color] = 0x00
    self[Sprite2Color] = 0x00
    self[Sprite3Color] = 0x00
    self[Sprite4Color] = 0x00
    self[Sprite5Color] = 0x00
    self[Sprite6Color] = 0x00
    self[Sprite7Color] = 0x00
  }
}

pub fn emulate(self : VIC, cycles : Int) -> Bool {
  let mut rasterRow : UInt8 = 0
  self.rowCycleCount += cycles
  if self.rowCycleCount >= self.rasterRowCycles {
    self.rowCycleCount -= self.rasterRowCycles
    rasterRow = ((self[ControlRegisterVertical] & cr(RasterCompare)) << 1) + self[ReadRasterWriteRasterValue]
    rasterRow += 1
    if rasterRow >= self.rasterLines {
      rasterRow = 0
    }
    self[ControlRegisterVertical] = (self[ControlRegisterVertical] & (self[ControlRegisterVertical] ^
      cr(RasterCompare))) | ((rasterRow & 0x0100) >> 1)
    self[ReadRasterWriteRasterValue] = rasterRow & 0xFF

    //
    if (self[IRQMaskRegister] & irqMask(InterruptEnabled)) != 0 {
      if rasterRow == ((self[ControlRegisterVertical] & self[ControlRegisterVertical]) <<
      1) + self[ReadRasterWriteRasterValue] {
        self[InterruptFlagRegister] = self[InterruptFlagRegister] | irqFlag(
            SetAnyEnabledVICIRQCondition,
          ) | irqMask(InterruptEnabled)
      }
    }
  }
  (self[InterruptFlagRegister] & irqFlag(SetAnyEnabledVICIRQCondition)) != 0
}

pub fn acknowledgeVICrasterIRQ(self : VIC) -> Unit {
  self[InterruptFlagRegister] = self[InterruptFlagRegister] & (self[InterruptFlagRegister] ^
    irqMask(InterruptEnabled))
  self[InterruptFlagRegister] = self[InterruptFlagRegister] & (self[InterruptFlagRegister] ^
    (irqFlag(SetAnyEnabledVICIRQCondition) | irqMask(InterruptEnabled)))
}

fn op_get(self : VIC, register : VICregister) -> UInt8 {
  let address = self.baseaddress + vic(register) % 0x40 // (repeated every $40, 64 bytes)
  // VIC-II Register Images
  if address < 0xD000 || address > 0xD3FF {
    // self.dump()
    println("VIC \(register) → $" + self.mem[address].to_hex())
    abort("out of bounds")
  }
  println("VIC \(register) → $" + self.mem[address].to_hex())
  self.mem[address].0
}

fn op_set(self : VIC, register : VICregister, value : UInt8) -> Unit {
  let address = self.baseaddress + vic(register) % 0x40 // (repeated every $40, 64 bytes)
  // VIC-II Register Images
  if address < 0xD000 || address > 0xD3FF {
    // self.dump()
    println("VIC \(register) ← $" + value.to_hex())
    abort("out of bounds")
  }
  println("VIC \(register) ← $" + value.to_hex())
  self.mem[address] = value.0
}
