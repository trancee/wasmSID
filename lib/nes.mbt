///|
pub struct NES {
  pc : UInt16
  mem : Memory
  cpu : @cpu.CPU
}

///|
pub fn NES::new(
  pc~ : UInt16 = 0x0000,
  //
  data~ : Bytes = [],
  //
  address~ : UInt16 = 0x0000,
  length~ : Int = data.length(),
  offset~ : Int = 0,
  //
  debug~ : Bool = false
) -> NES! {
  let cpu = @cpu.CPU::new!(
    pc~,
    //
    address~,
    //
    data~,
    length~,
    offset~,
    //
    decimal_mode=false,
    //
    debug~,
  )

  //
  let mem = Memory::new()

  //
  { pc, mem, cpu }
}

///|
pub fn NES::load(
  self : NES,
  //
  data : Bytes,
  //
  address~ : UInt16 = 0x0000,
  length~ : Int = data.length(),
  offset~ : Int = 0
) -> UInt16! {
  self.cpu.load!(address, data, length~, offset~)
}

///|
pub fn NES::step(self : NES) -> Int {
  self.cpu.step()
}

///|
pub fn NES::pc(self : NES) -> UInt16 {
  self.cpu.pc()
}

///|
pub fn NES::set_flags(self : NES, flags : @cpu.Flags) -> Unit {
  self.cpu.set_flags(flags)
}

///|
pub fn NES::push16(self : NES, value : UInt16) -> Unit {
  self.cpu.push16(value)
}
