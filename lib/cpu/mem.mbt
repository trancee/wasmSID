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

enum Address {
  D6510
  R6510
  ADRAY1 // Vector: Routine to Convert a Number from Floating Point to Signed Integer
  ADRAY2 // Vector: Routine to Convert a Number from Integer to Floating Point
  CHARAC // Search Character for Scanning BASIC Text Input
  ENDCHR // Search Character for Statement Termination or Quote
  TRMPOS // Column position of the Cursor before the Last TAB or SPC
  VERCK // Flag: LOAD or VERIFY
  COUNT // Index into the Text Input Buffer/Number of Array Subscripts
  DIMFLG // Flags for the Routines That Locate or Build an Array
  VALTYP // Flag: Type of Data (String or Numeric)
}

struct Memory {
  mut mem : Array[UInt8]
}

fn Memory::new() -> Memory {
  { mem: Array::make(0x10000, 0x00) }
}

fn clear(self : Memory) -> Unit {
  self.mem = Array::make(0x10000, 0x00)
}

fn dump(
  self : Memory,
  ~addr : UInt16 = 0x0000,
  ~cols : Int = 0x10,
  ~rows : Int = 0x10
) -> Unit {
  let mut i = 0
  let mut str = "     "
  while i < cols {
    str += UInt8(i).to_hex() + " "
    i = i + 1
  }
  i = 0
  while i <= cols * rows {
    if i % cols == 0 {
      println(str)
      str = (addr + i).to_hex() + "|"
    }
    str += self.mem[(addr + i).0].to_hex() + " "
    i = i + 1
  }
}

pub fn op_get(self : Memory, addr : Int) -> UInt8 {
  if addr > 0xFFFF {
    self.dump()
    abort("Memory::get out of bounds")
  }
  // VIC-II
  if addr >= 0xD000 && addr <= 0xD3FF {
    // return vic2.onReadByte(address);
  }

  // SID
  if addr >= 0xD400 && addr <= 0xD7FF {

  }

  // Color ram
  if addr >= 0xD800 && addr <= 0xDBFF {
    // return memoryManager.ram.onReadByte(address);
  }

  // CIA 1
  if addr >= 0xDC00 && addr <= 0xDCFF {
    // return memoryManager.cia1.onReadByte(address);
  }

  // CIA 2
  if addr >= 0xDD00 && addr <= 0xDDFF {
    // return memoryManager.cia2.onReadByte(address);
  }
  self.mem[addr]
}

pub fn op_set(self : Memory, addr : Int, value : Int) -> Unit {
  if addr > 0xFFFF {
    self.dump()
    abort("Memory::set out of bounds")
  }
  // VIC-II
  if addr >= 0xD000 && addr <= 0xD3FF {
    // vic2.onWriteByte(address, data)
  }
  // SID
  if addr >= 0xD400 && addr <= 0xD7FF {
    // sid.play()
    // sidPlayer.synth.poke(address & 0x1f, data);
    if addr > 0xD418 {
      // console.log("attempted digi poke:", address, data);
      // sidPlayer.synth.pokeDigi(address, data);
      // println("attempted digi poke")
      // abort("digi")
    }
  }
  // Color ram
  if addr >= 0xD800 && addr <= 0xDBFF {
    // memoryManager.ram.onWriteByte(address, data);
  }

  // CIA 1
  if addr >= 0xDC00 && addr <= 0xDCFF {
    // memoryManager.cia1.onWriteByte(address, data);
  }

  // CIA 2
  if addr >= 0xDD00 && addr <= 0xDDFF {
    // memoryManager.cia2.onWriteByte(address, data);
  }
  self.mem[addr] = value |> u8
}
