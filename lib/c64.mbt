pub struct C64 {
  baseaddress : UInt16
  mem : @cpu.Memory
  cpu : @cpu.CPU
  vic : VIC
}

pub fn C64::new(
  ~baseaddress : Int = 0x0000,
  ~data : Array[Int] = [],
  ~offset : Int = 0x0000,
  ~length : Int = data.length()
) -> C64 {
  let cpu = @cpu.CPU::new(pc=baseaddress)
  let mem = cpu.mem()
  cpu.load(data, ~offset, ~length)
  let vic = VIC::new(~baseaddress)
  let c64 : C64 = { baseaddress, mem, cpu, vic }
  c64
}

pub fn load(
  self : C64,
  data : Array[Int],
  ~offset : Int = 0,
  ~length : Int = data.length()
) -> Unit {
  self.cpu.load(data, ~offset, ~length)
}

pub fn step(self : C64) -> Int {
  self.cpu.step()
}

pub fn pc(self : C64) -> Int {
  self.cpu.pc()
}

pub fn push(self : C64, value : @cpu.UInt8) -> Unit {
  self.cpu.push(value)
}

pub fn push16(self : C64, value : @cpu.UInt16) -> Unit {
  self.cpu.push16(value)
}

// pub fn op_get(self : C64, addr : Int) -> UInt8 {
//   self.cpu.read(addr)
// }

// pub fn op_set(self : C64, addr : Int, value : Int) -> Unit {
//   self.cpu.write(addr, value)
// }
