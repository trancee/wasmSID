struct Memory {
  mut mem : Array[UInt8]
}

fn Memory::new() -> Memory {
  { mem: Array::make(0x10000, 0) }
}

fn op_get(self : Memory, addr : Int) -> UInt8 {
  // if addr.0 >= 0x0000 && addr.0 <= 0x1FFF {
  self.mem[addr % 0x0800]
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

fn op_set(self : Memory, addr : Int, value : UInt8) -> Unit {
  // if addr.0 >= 0x0000 && addr.0 <= 0x1FFF {
  self.mem[addr % 0x0800] = value
  // } else if addr.0 >= 0x2000 && addr.0 <= 0x3FFF {
  //   n.ppu.writeRegister((0x2000 |> to_u16) + (addr.0 % 8 |> to_u16), value)
  // } else if addr.0 == 0x4014 {
  //   n.ppu.writeRegister(addr, value)
  // } else if addr.0 >= 0x4000 && addr.0 <= 0x4013 || addr.0 == 0x4015 || addr.0 == 0x4017 {
  //   n.apu.writeRegister(addr, value)
  // } else if addr.0 == 0x4016 {
  //   n.controllers[0].write(value)
  //   n.controllers[1].write(value)
  // } else if addr.0 >= 0x6000 && addr.0 <= 0xFFFF {
  //   let m = n.mapper.unwrap()
  //   m[addr] = value
  // }
}

fn dump(self : Memory, offset : UInt16, length : Int) -> String {
  for i = 0, output = offset.to_hex()
      i < length
      i = i + 1, output = output + " " + self.mem[offset + i].to_hex() {

  } else {
    output
  }
}
