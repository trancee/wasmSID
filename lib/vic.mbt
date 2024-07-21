/// 6567 (NTSC)
/// 6569 (PAL)
///
/// $D000-$D3FF VIC-II
/// $D000-$D02E         VIC-II Chip Registers
/// $D02F-$D03F         Not Connected           When read, they will always give a value of 255 ($FF).  This value will not change after writing to them.
/// $D040-$D3FF         VIC-II Register Images

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

pub fn reset(self : VIC) -> Unit {
  for i = 0; i < 0x3F; i = i + 1 {
    self[i] = 0x00
  }
}

pub fn emulate(self : VIC, cycles : Int) -> Bool {
  let mut rasterRow = 0
  self.rowCycleCount += cycles
  if self.rowCycleCount >= self.rasterRowCycles {
    self.rowCycleCount -= self.rasterRowCycles
    rasterRow = ((self[CONTROL[CONTROL]] & RASTERROWMSB[RASTERROWMSB]) << 1) + self[RASTERROWL[RASTERROWL]]
    rasterRow += 1
    if rasterRow >= self.rasterLines {
      rasterRow = 0
    }
    self[CONTROL[CONTROL]] = (self[CONTROL[CONTROL]] & (self[CONTROL[CONTROL]] ^
      RASTERROWMSB[RASTERROWMSB])) | ((rasterRow & 0x0100) >> 1)
    self[RASTERROWL[RASTERROWL]] = rasterRow & 0xFF

    //
    if (self[INTERRUPT_ENABLE[INTERRUPT_ENABLE]] & RASTERROW_MATCH_IRQ[RASTERROW_MATCH_IRQ]) !=
    0 {
      if rasterRow == ((self[CONTROL[CONTROL]] & RASTERROWMSB[RASTERROWMSB]) << 1) +
      self[RASTERROWL[RASTERROWL]] {
        self[INTERRUPT[INTERRUPT]] = self[INTERRUPT[INTERRUPT]] | VIC_IRQ[VIC_IRQ] |
          RASTERROW_MATCH_IRQ[RASTERROW_MATCH_IRQ]
      }
    }
  }
  (self[INTERRUPT[INTERRUPT]] & VIC_IRQ[VIC_IRQ]) != 0
}

pub fn acknowledgeVICrasterIRQ(self : VIC) -> Unit {
  self[INTERRUPT[INTERRUPT]] = self[INTERRUPT[INTERRUPT]] & (self[INTERRUPT[INTERRUPT]] ^
    RASTERROW_MATCH_IRQ[RASTERROW_MATCH_IRQ])
  self[INTERRUPT[INTERRUPT]] = self[INTERRUPT[INTERRUPT]] & (self[INTERRUPT[INTERRUPT]] ^
    (VIC_IRQ[VIC_IRQ] | RASTERROW_MATCH_IRQ[RASTERROW_MATCH_IRQ]))
}

fn op_get(self : VIC, addr : Int) -> Int {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    println("VIC::get out of bounds")
    abort("VIC::get out of bounds")
  }
  self.mem[address].0
}

fn op_set(self : VIC, addr : Int, value : Int) -> Unit {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    println("VIC::set out of bounds")
    abort("VIC::set out of bounds")
  }
  self.mem[address] = value
}

enum VICregisters {
  CONTROL
  RASTERROWL
  SPRITE_ENABLE
  INTERRUPT
  INTERRUPT_ENABLE
}

fn op_get(self : VICregisters, value : VICregisters) -> Int {
  match value {
    CONTROL => 0x11
    RASTERROWL => 0x12
    SPRITE_ENABLE => 0x15
    INTERRUPT => 0x19
    INTERRUPT_ENABLE => 0x1A
  }
}

enum ControlBitVal {
  RASTERROWMSB
  DISPLAY_ENABLE
  ROWS
  YSCROLL_MASK
}

fn op_get(self : ControlBitVal, value : ControlBitVal) -> Int {
  match value {
    RASTERROWMSB => 0x80
    DISPLAY_ENABLE => 0x10
    ROWS => 0x08
    YSCROLL_MASK => 0x07
  }
}

enum InterruptBitVal {
  VIC_IRQ
  RASTERROW_MATCH_IRQ
}

fn op_get(self : InterruptBitVal, value : InterruptBitVal) -> Int {
  match value {
    VIC_IRQ => 0x80
    RASTERROW_MATCH_IRQ => 0x01
  }
}
