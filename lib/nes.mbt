///|
pub struct NES {
  baseaddress : UInt16
  mem : Memory
  cpu : @cpu.CPU
}

///|
pub fn NES::new(
  baseaddress~ : Int = 0x0000,
  data~ : FixedArray[Byte] = [],
  addr~ : Int = 0x0000,
  length~ : Int = data.length()
) -> NES {
  let cpu = @cpu.CPU::new(pc=baseaddress, decimal_mode=false)
  let mem = Memory::new()
  let _ = cpu.load(addr, data, length~)
  let nes : NES = { baseaddress, mem, cpu }
  nes
}

///|
pub fn NES::load(
  self : NES,
  data : FixedArray[Byte],
  addr~ : Int = 0,
  length~ : Int = data.length()
) -> Unit {
  let _ = self.cpu.load(addr, data, length~)

}

///|
pub fn NES::step(self : NES) -> Int {
  self.cpu.step()
}

///|
pub fn NES::pc(self : NES) -> Int {
  self.cpu.pc()
}

// pub fn get_flags(self : NES) -> @cpu.UInt8 {
//   self.cpu.get_flags()
// }

///|
pub fn NES::set_flags(self : NES, flags : UInt8) -> Unit {
  self.cpu.set_flags(flags)
}

///|
pub fn NES::push(self : NES, value : UInt8) -> Unit {
  self.cpu.push(value)
}

///|
pub fn NES::push16(self : NES, value : UInt16) -> Unit {
  self.cpu.push16(value)
}

// pub fn op_get(self : NES, addr : Int) -> UInt8 {
//   self.cpu.read(addr)
// }

// pub fn op_set(self : NES, addr : Int, value : Int) -> Unit {
//   self.cpu.write(addr, value)
// }
