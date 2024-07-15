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
  self.mem[addr.0]
  // if addr.0 >= 0x0000 && addr.0 <= 0x1FFF {
  // self.mem[addr % 0x0800]
  // } else if addr >= (0x2000 |> to_u16) && addr <= (0x3FFF |> to_u16) {
  //   n.ppu.readRegister((0x2000 |> to_u16) + (addr.0 % 8 |> to_u16))
  // } else if addr.0 == 0x4014 {
  //   n.ppu.readRegister(addr)
  // } else if addr.0 == 0x4015 {
  //   n.apu.readRegister(addr)
  // } else if addr.0 == 0x4016 {
  //   n.controllers[0].read()
  // } else if addr.0 == 0x4017 {
  //   n.controllers[1].read()
  // } else if addr.0 >= 0x6000 && addr.0 <= 0xFFFF {
  //   let m = n.mapper.unwrap()
  //   m[addr]
  // } else {
  //   0 |> to_u8()
  // }
}

fn op_set(self : Memory, addr : UInt16, value : Int) -> Unit {
  if addr > 0xFFFF {
    self.dump()
    abort("Memory::set out of bounds")
  }
  self.mem[addr.0] = value |> u8
  // if addr >= 0x0000 && addr <= 0x1FFF {
  // self.mem[addr % 0x0800] = value
  // } else if addr >= 0x2000 && addr <= 0x3FFF {
  //   // n.ppu.writeRegister((0x2000 |> to_u16) + (addr.0 % 8 |> to_u16), value)
  // } else if addr == 0x4014 {
  //   // n.ppu.writeRegister(addr, value)
  // } else if addr >= 0x4000 && addr <= 0x4013 || addr == 0x4015 || addr == 0x4017 {
  //   //   n.apu.writeRegister(addr, value)
  // } else if addr == 0x4016 {
  //   //   n.controllers[0].write(value)
  //   //   n.controllers[1].write(value)
  // } else if addr >= 0x6000 && addr <= 0xFFFF {
  //   let m = n.mapper.unwrap()
  //   m[addr] = value
  // }
}
