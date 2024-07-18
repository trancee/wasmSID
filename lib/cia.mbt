struct CIA {
  mem : @cpu.Memory
  baseaddress : Int // CIA-baseaddress location in C64-memory (IO)
}

pub fn CIA::new(mem : @cpu.Memory, baseaddress : Int) -> CIA {
  let cia : CIA = { mem, baseaddress }
  cia
}

pub fn reset(self : CIA) -> Unit {
  for i = 0; i < 0x10; i = i + 1 {
    self[i] = 0x00
  }
}

pub fn writeCIAIRQmask(self : CIA, value : Int) -> Unit {
  if (value & 0x80) != 0 {
    self[0x0D] = self[0x0D] | (value & 0x1F)
  } else {
    self[0x0D] = self[0x0D] ^ (value & 0x1F)
  }
}

pub fn acknowledgeCIAIRQ(self : CIA) -> Unit {
  self[0x0D] = 0x00 // reading a CIA interrupt-register clears its read-part and IRQ-flag
}

fn op_get(self : CIA, addr : Int) -> Int {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    abort("CIA::get out of bounds")
  }
  self.mem[address].0
}

fn op_set(self : CIA, addr : Int, value : Int) -> Unit {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    abort("CIA::set out of bounds")
  }
  self.mem[address] = value
}
