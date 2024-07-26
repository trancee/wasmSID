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

// https://www.zimmers.net/cbmpics/cbm/c64/vic-ii.txt

let vic_mem_upper = 0xD000

let vic_mem_lower = 0xD3FF

let vic_mem_length = 0x03FF

struct VIC {
  mem : @cpu.Memory
  baseaddress : Int
  //
  mut rasterLines : Int
  mut rasterRowCycles : Int
  mut rowCycleCount : Int
}

pub fn VIC::new(
  mem : @cpu.Memory,
  baseaddress : Int,
  ~videoStandard : VideoStandard = Unknown
) -> VIC {
  println("VIC::new")
  let vic : VIC = {
    mem,
    baseaddress,
    //
    rasterLines: 0,
    rasterRowCycles: 0,
    rowCycleCount: 0,
  }
  mem.hook(
    vic_mem_upper,
    vic_mem_lower,
    fn(address : Int) { vic.r(address).0 },
    fn(address : Int, value : Int) { vic.w(address, value) },
  )
  vic.reset()
  vic
}

/// These registers are all intialized to 0 at power-up.
pub fn reset(self : VIC, ~videoStandard : VideoStandard = Unknown) -> Unit {
  self.mem.reset(offset=self.baseaddress, length=vic_mem_length)

  //
  self[ControlRegisterVertical] = 0x8B
  self[ReadRasterWriteRasterValue] = 0x37

  /// ($D02F-$D03F)
  /// Not Connected
  ///
  /// The VIC-II chip has only 47 registers for 64 bytes of possible address
  /// space.  Therefore, the remaining 17 addresses do not access any
  /// memory.  When read, they will always give a value of 255 ($FF).  This
  /// value will not change after writing to them.

  self.mem.reset(offset=0xD02F, length=0x0010, value=0xFF)
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
    self[ControlRegisterVertical] = self[ControlRegisterVertical].clr(
        cr(RasterCompare),
      ) | ((rasterRow & 0x0100) >> 1)
    self[ReadRasterWriteRasterValue] = rasterRow & 0xFF

    //
    if self[IRQMaskRegister].has(irqMask(InterruptEnabled)) {
      if rasterRow == ((self[ControlRegisterVertical] & self[ControlRegisterVertical]) <<
      1) + self[ReadRasterWriteRasterValue] {
        self[InterruptFlagRegister] = self[InterruptFlagRegister] | irqFlag(
            SetAnyEnabledVICIRQCondition,
          ) | irqMask(InterruptEnabled)
      }
    }
  }
  self[InterruptFlagRegister].has(irqFlag(SetAnyEnabledVICIRQCondition))
}

pub fn acknowledgeVICrasterIRQ(self : VIC) -> Unit {
  self[InterruptFlagRegister] = self[InterruptFlagRegister].clr(
    irqMask(InterruptEnabled),
  )
  self[InterruptFlagRegister] = self[InterruptFlagRegister].clr(
    irqFlag(SetAnyEnabledVICIRQCondition) | irqMask(InterruptEnabled),
  )
}

fn r(self : VIC, address : UInt16) -> UInt8 {
  println("VIC $" + address.to_hex() + " → $" + self.mem[address.0].to_hex())
  self.mem[address.0].0
}

fn w(self : VIC, address : UInt16, value : UInt8) -> Unit {
  println("VIC $" + address.to_hex() + " ← $" + self.mem[address.0].to_hex())
  self.mem[address.0] = value.0
}

fn op_get(self : VIC, register : VICregister) -> UInt8 {
  let address = self.baseaddress + vic(register) % 0x40 // (repeated every $40, 64 bytes)
  // VIC-II Register Images
  if address < vic_mem_upper || address > vic_mem_lower {
    // self.dump()
    println("VIC \(register) → $" + self.mem[address].to_hex())
    abort("out of bounds")
  }
  // println("VIC \(register) → $" + self.mem[address].to_hex())
  // self.mem[address].0
  self.r(address)
}

fn op_set(self : VIC, register : VICregister, value : UInt8) -> Unit {
  let address = self.baseaddress + vic(register) % 0x40 // (repeated every $40, 64 bytes)
  // VIC-II Register Images
  if address < vic_mem_upper || address > vic_mem_lower {
    // self.dump()
    println("VIC \(register) ← $" + value.to_hex())
    abort("out of bounds")
  }
  // println("VIC \(register) ← $" + value.to_hex())
  // match register {
  //   /// FIXME: depends on memory bank?
  //   InterruptFlagRegister => self.acknowledgeVICrasterIRQ()
  //   _ => self.mem[address] = value.0
  // }
  self.w(address, value)
}
