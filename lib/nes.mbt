pub struct NES {
  baseaddress : UInt16
  mem : @cpu.Memory
  cpu : @cpu.CPU
}

pub fn NES::new(
  ~baseaddress : Int = 0x0000,
  ~data : FixedArray[Int] = [],
  ~offset : Int = 0x0000,
  ~length : Int = data.length()
) -> NES {
  let cpu = @cpu.CPU::new(pc=baseaddress, decimal_mode=false)
  let mem = cpu.mem()
  cpu.load(offset, data, ~length)
  let nes : NES = { baseaddress, mem, cpu }
  nes
}

pub fn load(
  self : NES,
  data : FixedArray[Int],
  ~offset : Int = 0,
  ~length : Int = data.length()
) -> Unit {
  self.cpu.load(offset, data, ~length)
}

pub fn step(self : NES) -> Int {
  self.cpu.step()
}

pub fn pc(self : NES) -> Int {
  self.cpu.pc()
}

// pub fn get_flags(self : NES) -> @cpu.UInt8 {
//   self.cpu.get_flags()
// }

pub fn set_flags(self : NES, flags : @cpu.UInt8) -> Unit {
  self.cpu.set_flags(flags)
}

pub fn push(self : NES, value : @cpu.UInt8) -> Unit {
  self.cpu.push(value)
}

pub fn push16(self : NES, value : @cpu.UInt16) -> Unit {
  self.cpu.push16(value)
}

// pub fn op_get(self : NES, addr : Int) -> UInt8 {
//   self.cpu.read(addr)
// }

// pub fn op_set(self : NES, addr : Int, value : Int) -> Unit {
//   self.cpu.write(addr, value)
// }
