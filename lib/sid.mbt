// https://www.oxyron.de/html/registers_sid.html

struct SID {
  mem : @cpu.Memory
  baseaddress : Int // VIC-baseaddress location in C64-memory (IO)
  //
  mut model : SIDModel
  mut channel : Channel
}

pub fn SID::new(
  mem : @cpu.Memory,
  baseaddress : Int,
  ~model : SIDModel = Unknown,
  ~channel : Channel = Unknown
) -> SID {
  let sid : SID = { mem, baseaddress, model, channel }
  sid.reset()
  sid
}

pub fn reset(self : SID) -> Unit {
  for i = 0; i < 0x3F; i = i + 1 {
    self[i] = 0x00
  }
}

fn op_get(self : SID, addr : Int) -> Int {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    println("SID::get out of bounds")
    abort("SID::get out of bounds")
  }
  self.mem[address].0
}

fn op_set(self : SID, addr : Int, value : Int) -> Unit {
  let address = addr + self.baseaddress
  if address > 0xFFFF {
    // self.dump()
    println("SID::set out of bounds")
    abort("SID::set out of bounds")
  }
  self.mem[address] = value
}
