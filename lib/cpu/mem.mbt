/// Memory Map
/// https://sta.c64.org/cbm64mem.html
///
/// $0000-$00FF         Zero Page
///
/// $0100-$01FF         Processor Stack
///
/// $0200-$0258 BUF     BASIC Line Editor Input Buffer
/// $0259-$0276         Tables for File Numbers, Device Numbers, and Secondary Addresses
/// $0259-$0262 LAT     Kernal Table of Active Logical File Numbers
/// $0263-$026C FAT     Kernal Table of Device Numbers for Each Logical File
/// $026D-$0276 SAT     Kernal Table of Secondary Addresses for Each Logical File
/// $0277-$0280 KEYD    Keyboard Buffer (Queue)
///
/// $0400-$07FF VICSCN  Video Screen Memory Area
/// $0400-$07E7         Video Matrix: 25 Lines by 40 Columns
/// $07F8-$07FF         Sprite Shape Data Pointers
///
/// $0800-$9FFF BASIC RAM
/// $1000-$1FFF         Character ROM Image for VIC-II Chip When Using Memory Bank 0 (Default)
/// $8000-$9FFF Cartridge ROM
/// $9000-$9FFF         Character ROM Image for VIC-II Chip When Using Memory Bank 2
///
/// $A000-$BFFF BASIC ROM / Cartridge ROM
/// $C000-$CFFF RAM
///
/// $D000-$DFFF I/O
/// $D000-$DFFF Character ROM
/// $D000-$D3FF VIC-II
/// $D000-$D02E         VIC-II Chip Registers
/// $D02F-$D03F         Not Connected           When read, they will always give a value of 255 ($FF).  This value will not change after writing to them.
/// $D040-$D3FF         VIC-II Register Images
/// $D400-$D7FF SID
/// $D400-$D41C         Sound Interface Device (SID) Registers
/// $D41D-$D41F         Not Connected           Reading them will always return a value of 255 ($FF), and writing to them will have no effect.
/// $D420-$D7FF         SID Register Images     The result is that every 32-byte area in this 1K block is a mirror of every other.
/// $D800-$DBFF Color RAM
/// $DC00-$DCFF CIA #1
/// $DC00-$DC0F         Complex Interface Adapter (CIA) #1 Registers
/// $DD00-$DDFF CIA #2
/// $DD00-$DD0F         Complex Interface Adapter (CIA) #2 Registers
/// $DD10-$DDFF         CIA #2 Register Images  The result is that every 16-byte area in this 256-byte block is a mirror of every other.
/// $DE00-$DEFF I/O #1  Reserved for I/O Expansion
/// $DF00-$DFFF I/O #2  CIA #2 Register Images
///
/// $E000-$FFFF KERNAL ROM / Cartridge ROM
/// $FF81-$FFF5         Kernal Jump Table
/// $FFFA-$FFFF Hardware Vectors
///       $FFFA         Non-Maskable Interrupt Hardware Vector
///       $FFFC         System Reset (RES) Hardware Vector
///       $FFFE         Maskable Interrupt Request and Break Hardware Vectors

// enum Address {
//   D6510
//   R6510
//   ADRAY1 // Vector: Routine to Convert a Number from Floating Point to Signed Integer
//   ADRAY2 // Vector: Routine to Convert a Number from Integer to Floating Point
//   CHARAC // Search Character for Scanning BASIC Text Input
//   ENDCHR // Search Character for Statement Termination or Quote
//   TRMPOS // Column position of the Cursor before the Last TAB or SPC
//   VERCK // Flag: LOAD or VERIFY
//   COUNT // Index into the Text Input Buffer/Number of Array Subscripts
//   DIMFLG // Flags for the Routines That Locate or Build an Array
//   VALTYP // Flag: Type of Data (String or Numeric)
//   //
//   TVSFLG // 02A6        678     Flag: TV Standard: $00 = NTSC, $01 = PAL.
// }

// fn op_get(self : Address, map : Address) -> UInt16 {
//   self[map]
// }

struct MemoryHook {
  start : Int
  end : Int
  mem : FixedArray[Int]
  r : (Int) -> Int
  w : (Int, Int) -> Unit
}

fn MemoryHook::new(
  start : Int,
  end : Int,
  mem : FixedArray[Int],
  r : (Int) -> Int,
  w : (Int, Int) -> Unit
) -> MemoryHook {
  { start, end, mem, r, w }
}

struct Memory {
  mut mem : FixedArray[UInt8]
  //
  hooks : Array[MemoryHook]
}

pub fn Memory::new(~length : Int = 0xFFFF, ~value : Int = 0x00) -> Memory {
  { mem: FixedArray::make(length + 1, value), hooks: [] }
}

pub fn hook(
  self : Memory,
  start : Int,
  end : Int,
  mem : FixedArray[Int],
  r : (Int) -> Int,
  w : (Int, Int) -> Unit
) -> Unit {
  self.hooks.push(MemoryHook::new(start, end, mem, r, w))
}

pub fn clear(self : Memory) -> Unit {
  self.mem = FixedArray::make(self.mem.length(), 0x00)
}

pub fn reset(
  self : Memory,
  ~offset : Int = 0,
  ~length : Int = self.mem.length(),
  ~value : Int = 0x00
) -> Unit {
  println(
    "Memory::reset $" +
    UInt16(offset).to_hex() +
    " - $" +
    UInt16(offset + length).to_hex() +
    " = #$" +
    UInt8(value).to_hex(),
  )
  for i = 0; i < length; i = i + 1 {
    self[offset + i] = value
  }
}

//fill KERNAL/BASIC-ROM areas with content needed for SID-playback
pub fn setROM(self : Memory) -> Unit {
  let rom_IRQreturnCode = [0xAD, 0x0D, 0xDC, 0x68, 0xA8, 0x68, 0xAA, 0x68, 0x40] //CIA1-acknowledge IRQ-return
  let rom_NMIstartCode = [0x78, 0x6c, 0x18, 0x03, 0x40] //SEI and jmp($0318)
  let rom_IRQBRKstartCode = [ //Full IRQ-return (handling BRK with the same RAM vector as IRQ)
    0x48, 0x8A, 0x48, 0x98, 0x48, 0xBA, 0xBD, 0x04, 0x01, 0x29, 0x10, 0xEA, 0xEA,
    0xEA, 0xEA, 0xEA, 0x6C, 0x14, 0x03,
  ]
  for i = 0xA000; i < 0x10000; i = i + 1 {
    self[i] = 0x60 //RTS (at least return if some unsupported call is made to ROM)
  }
  for i = 0xEA31; i < 0xEA7E; i = i + 1 {
    self[i] = 0xEA //NOP (full IRQ-return leading to simple IRQ-return without other tasks)
  }
  for i = 0; i < rom_IRQreturnCode.length(); i = i + 1 {
    self[0xEA7E + i] = rom_IRQreturnCode[i]
  }
  for i = 0; i < rom_NMIstartCode.length(); i = i + 1 {
    self[0xFE43 + i] = rom_NMIstartCode[i]
  }
  for i = 0; i < rom_IRQBRKstartCode.length(); i = i + 1 {
    self[0xFF48 + i] = rom_IRQBRKstartCode[i]
  }
  self[0xFFFB] = 0xFE
  self[0xFFFA] = 0x43 //ROM NMI-vector
  self[0xFFFF] = 0xFF
  self[0xFFFE] = 0x48 //ROM IRQ-vector
  //copy KERNAL & BASIC ROM contents into the RAM under them? (So PSIDs that don't select bank correctly will work better.)
}

fn dump(
  self : Memory,
  ~addr : UInt16 = 0x0000,
  ~cols : Int = 0x10,
  ~rows : Int = 0x10
) -> Unit {
  let mut i = 0
  let mut str = ""
  if rows > 1 {
    str = "     "
    while i < cols {
      str += UInt8(i).to_hex() + " "
      i = i + 1
    }
    i = 0
  }
  while i <= cols * rows {
    if i % cols == 0 {
      if str.length() > 0 {
        println(str)
      }
      str = (addr + i).to_hex() + "|"
    }
    str += self.mem[(addr + i).0].to_hex() + " "
    i = i + 1
  }
}

pub fn op_get(self : Memory, addr : Int) -> UInt8 {
  // println("Memory::op_get $" + UInt16(addr).to_hex())
  if addr > 0xFFFF {
    self.dump()
    println("Memory::get out of bounds")
    panic()
  }

  //
  for i = 0; i < self.hooks.length(); i = i + 1 {
    if addr >= self.hooks[i].start && addr <= self.hooks[i].end {
      println(
        "R:HOOK $" +
        UInt16(self.hooks[i].start).to_hex() +
        " - $" +
        UInt16(self.hooks[i].end).to_hex() +
        " | $" +
        UInt16(addr).to_hex(),
      )
      return (self.hooks[i].r)(addr)
    }
  }

  // // VIC-II
  // if addr >= 0xD000 && addr <= 0xD3FF {
  //   if addr >= 0xD02F && addr <= 0xD03F {
  //     /// When read, they will always give a value of 255 ($FF).
  //     /// This value will not change after writing to them.
  //     return 0xFF
  //   }
  //   println(
  //     "vic2 read $" + u16(addr).to_hex() + " = #$" + self.mem[addr].to_hex(),
  //   )
  //   abort("")
  //   // return vic2.onReadByte(address);
  // }

  // // SID
  // if addr >= 0xD400 && addr <= 0xD7FF {
  //   if addr >= 0xD41D && addr <= 0xD41F {
  //     /// Reading them will always return a value of 255 ($FF),
  //     /// and writing to them will have no effect.
  //     return 0xFF
  //   }
  //   println(
  //     "sid read $" + u16(addr).to_hex() + " = #$" + self.mem[addr].to_hex(),
  //   )
  //   abort("")
  // }

  // // Color ram
  // if addr >= 0xD800 && addr <= 0xDBFF {
  //   println(
  //     "color ram read $" + u16(addr).to_hex() + " = #$" + self.mem[addr].to_hex(),
  //   )
  //   abort("")
  //   // return memoryManager.ram.onReadByte(address);
  // }

  // // CIA 1
  // if addr >= 0xDC00 && addr <= 0xDCFF {
  //   println(
  //     "cia1 read $" + u16(addr).to_hex() + " = #$" + self.mem[addr].to_hex(),
  //   )
  //   abort("")
  //   // return memoryManager.cia1.onReadByte(address);
  // }

  // // CIA 2
  // if addr >= 0xDD00 && addr <= 0xDDFF {
  //   println(
  //     "cia2 read $" + u16(addr).to_hex() + " = #$" + self.mem[addr].to_hex(),
  //   )
  //   abort("")
  //   // return memoryManager.cia2.onReadByte(address);
  // }
  self.mem[addr]
}

pub fn op_set(self : Memory, addr : Int, value : Int) -> Unit {
  // println(
  //   "Memory::op_set $" + UInt16(addr).to_hex() + " = " + UInt8(value).to_hex(),
  // )
  if addr > 0xFFFF {
    self.dump()
    println("Memory::set out of bounds")
    panic()
  }

  //
  for i = 0; i < self.hooks.length(); i = i + 1 {
    if addr >= self.hooks[i].start && addr <= self.hooks[i].end {
      println(
        "W:HOOK $" +
        UInt16(self.hooks[i].start).to_hex() +
        " - $" +
        UInt16(self.hooks[i].end).to_hex() +
        " | $" +
        UInt16(addr).to_hex(),
      )
      return (self.hooks[i].w)(addr, value)
    }
  }

  // // VIC-II
  // if addr >= 0xD000 && addr <= 0xD3FF {
  //   println("vic2 write $" + u16(addr).to_hex())
  //   abort("")
  //   // vic2.onWriteByte(address, data)
  // }

  // // SID
  // if addr >= 0xD400 && addr <= 0xD7FF {
  //   println("sid write $" + u16(addr).to_hex())
  //   abort("")
  //   // sid.play()
  //   // sidPlayer.synth.poke(address & 0x1f, data);
  //   if addr > 0xD418 {
  //     // console.log("attempted digi poke:", address, data);
  //     // sidPlayer.synth.pokeDigi(address, data);
  //     // println("attempted digi poke")
  //     // abort("digi")
  //   }
  // }
  // // Color ram
  // if addr >= 0xD800 && addr <= 0xDBFF {
  //   println("color ram write $" + u16(addr).to_hex())
  //   abort("")
  //   // memoryManager.ram.onWriteByte(address, data);
  // }

  // // CIA 1
  // if addr >= 0xDC00 && addr <= 0xDCFF {
  //   println("cia1 write $" + u16(addr).to_hex())
  //   abort("")
  //   // memoryManager.cia1.onWriteByte(address, data);
  // }

  // // CIA 2
  // if addr >= 0xDD00 && addr <= 0xDDFF {
  //   println("cia2 write $" + u16(addr).to_hex())
  //   abort("")
  //   // memoryManager.cia2.onWriteByte(address, data);
  // }

  // println(
  //   "OK $" + UInt16(addr).to_hex() + " ($" + UInt16(self.mem.length()).to_hex() +
  //   ")",
  // )
  // println("OK $" + UInt16(addr).to_hex() + " #$" + self.mem[addr].to_hex())
  self.mem[addr] = value |> u8
}
