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

pub fn op_get(self : Memory, addr : UInt16) -> UInt8 {
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
  self.mem[addr.0]
}

fn op_set(self : Memory, addr : UInt16, value : Int) -> Unit {
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
  self.mem[addr.0] = value |> u8
}
