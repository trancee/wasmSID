///| Memory Map
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
pub struct Hook {
  start : UInt16
  end : UInt16
  //
  read : (UInt16, Bool) -> UInt8
  write : (UInt16, UInt8, Bool) -> Unit
}

///|
fn Hook::new(
  start : UInt16,
  end : UInt16,
  //
  read : (UInt16, Bool) -> UInt8,
  write : (UInt16, UInt8, Bool) -> Unit
) -> Hook {
  { start, end, read, write }
}

// let memory : Array[Hook] = []

///|
struct Memory {
  mut mem : FixedArray[UInt8]
  //
  // mut read : (UInt16, Bool) -> UInt8
  // mut write : (UInt16, UInt8, Bool) -> Unit
  //
  hooks : Array[Hook]
}

///|
pub fn Memory::new(length~ : Int = 0xFFFF, value~ : Int = 0x00) -> Memory {
  { mem: FixedArray::make(length + 1, value), hooks: [] }
}

///|
pub fn hook(
  self : Memory,
  //
  start : UInt16,
  end : UInt16,
  //
  read : (UInt16, Bool) -> UInt8,
  write : (UInt16, UInt8, Bool) -> Unit
) -> Unit {
  self.hooks.push(Hook::new(start, end, read, write))
}

///|
pub fn clear(self : Memory) -> Unit {
  self.mem = FixedArray::make(self.mem.length(), 0x00)
}

// pub fn set_read(self : Memory, read : (UInt16, Bool) -> UInt8) -> Unit {
//   self.read = read
// }

// pub fn set_write(self : Memory, write : (UInt16, UInt8, Bool) -> Unit) -> Unit {
//   self.write = write
// }

// pub fn reset(
//   self : Memory,
//   ~offset : Int = 0,
//   ~length : Int = self.mem.length(),
//   ~value : Int = 0x00
// ) -> Unit {
//   println(
//     "Memory::reset $" +
//     UInt16(offset).to_hex() +
//     " - $" +
//     UInt16(offset + length).to_hex() +
//     " = #$" +
//     UInt8(value).to_hex(),
//   )
//   for i = 0; i < length; i = i + 1 {
//     self[offset + i] = value
//   }
// }

// //fill KERNAL/BASIC-ROM areas with content needed for SID-playback
// pub fn setROM(self : Memory) -> Unit {
//   let rom_IRQreturnCode = [0xAD, 0x0D, 0xDC, 0x68, 0xA8, 0x68, 0xAA, 0x68, 0x40] //CIA1-acknowledge IRQ-return
//   let rom_NMIstartCode = [0x78, 0x6c, 0x18, 0x03, 0x40] //SEI and jmp($0318)
//   let rom_IRQBRKstartCode = [ //Full IRQ-return (handling BRK with the same RAM vector as IRQ)
//     0x48, 0x8A, 0x48, 0x98, 0x48, 0xBA, 0xBD, 0x04, 0x01, 0x29, 0x10, 0xEA, 0xEA,
//     0xEA, 0xEA, 0xEA, 0x6C, 0x14, 0x03,
//   ]
//   for i = 0xA000; i < 0x10000; i = i + 1 {
//     self[i] = 0x60 //RTS (at least return if some unsupported call is made to ROM)
//   }
//   for i = 0xEA31; i < 0xEA7E; i = i + 1 {
//     self[i] = 0xEA //NOP (full IRQ-return leading to simple IRQ-return without other tasks)
//   }
//   for i = 0; i < rom_IRQreturnCode.length(); i = i + 1 {
//     self[0xEA7E + i] = rom_IRQreturnCode[i]
//   }
//   for i = 0; i < rom_NMIstartCode.length(); i = i + 1 {
//     self[0xFE43 + i] = rom_NMIstartCode[i]
//   }
//   for i = 0; i < rom_IRQBRKstartCode.length(); i = i + 1 {
//     self[0xFF48 + i] = rom_IRQBRKstartCode[i]
//   }
//   self[0xFFFB] = 0xFE
//   self[0xFFFA] = 0x43 //ROM NMI-vector
//   self[0xFFFF] = 0xFF
//   self[0xFFFE] = 0x48 //ROM IRQ-vector
//   //copy KERNAL & BASIC ROM contents into the RAM under them? (So PSIDs that don't select bank correctly will work better.)
// }

///|
pub fn dump(
  self : Memory,
  addr~ : UInt16 = 0x0000,
  cols~ : Int = 0x10,
  rows~ : Int = 0x10
) -> Unit {
  let mut i = 0
  let mut str = ""
  if rows > 1 {
    str = "     "
    while i < cols {
      str += u8(i).to_hex() + " "
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
    str += self.mem[(addr + i)._].to_hex() + " "
    i = i + 1
  }
}

///|
pub fn read(self : Memory, address : UInt16, dummy~ : Bool = false) -> UInt8 {
  // let _dummy = if dummy { "🔍" } else { "" }
  // println("Memory::read $\{u16(addr).to_hex()} \{_dummy}")

  //
  if address > 0xFFFF {
    self.dump()
    println("Memory::get out of bounds")
    panic()
  }

  //
  for i = 0; i < self.hooks.length(); i = i + 1 {
    if address >= self.hooks[i].start && address <= self.hooks[i].end {
      return (self.hooks[i].read)(address, dummy)
    }
  }

  //
  self.read_direct(address)
}

///|
pub fn read_direct(self : Memory, address : UInt16) -> UInt8 {
  // println("Memory::read_direct $" + UInt16(addr).to_hex())
  //

  // match self.read {
  //   Some(_) => self.read(addr)
  //   None => self.mem[addr._]
  // }

  self.mem[address._]
}

// fn op_get(self : Memory, addr : UInt16) -> UInt8 {
//   // println("Memory::op_get $" + UInt16(addr).to_hex())
//   //

//   self.read(addr)
// }

///|
pub fn write(
  self : Memory,
  //
  address : UInt16,
  value : UInt8,
  //
  dummy~ : Bool = false
) -> Unit {
  // let _dummy = if dummy { "🔍" } else { "" }
  // println(
  //   "Memory::write $\{u16(addr).to_hex()} = #$\{u8(value).to_hex()} \{_dummy}",
  // )

  //
  if address > 0xFFFF {
    self.dump()
    println("Memory::set out of bounds")
    panic()
  }

  //
  for i = 0; i < self.hooks.length(); i = i + 1 {
    if address >= self.hooks[i].start && address <= self.hooks[i].end {
      return (self.hooks[i].write)(address, value, dummy)
    }
  }

  //
  self.write_direct(address, value)
}

///|
pub fn write_direct(self : Memory, address : UInt16, value : UInt8) -> Unit {
  // match self.write {
  //   Some(_) => self.write(addr, value)
  //   None => self.mem[addr._] = value._ |> u8
  // }

  self.mem[address._] = value
}

// fn op_set(self : Memory, addr : UInt16, value : UInt8) -> Unit {
//   // println(
//   //   "Memory::op_set $" + UInt16(addr).to_hex() + " = " + UInt8(value).to_hex(),
//   // )

//   //
//   self.write(addr, value)
// }
