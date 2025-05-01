///|
fn get_address_by_mode(
  self : CPU,
  mode : Mode
) -> (UInt16, (UInt16, UInt8)?, Bool?) {
  // println(mode)
  match mode {
    Implied => {
      let offset = self.read_instruction(prefetch=true)
      (self.pc |> u16, Some((self.pc, offset)), None)
    }
    Immediate => {
      let offset = self.read_instruction()
      (self.pc |> u16, Some((self.pc, offset)), None)
    }
    Accumulator => {
      let offset = self.read_instruction(prefetch=true)
      (self.pc |> u16, Some((self.pc, offset)), None)
    }

    //
    Absolute => {
      let offset = self.read_instruction_word()
      (offset |> u16, None, None)
    }
    AbsoluteSP => {
      let offset = self.read_instruction()
      (offset |> u16, None, None)
    }
    AbsoluteX => {
      let value = self.read_instruction_word()
      (
        value + self.registers[X].to_u16() |> u16,
        Some(((value & 0xFF00) | u16(u8(value) + self.registers[X]), -1)),
        Some(page_boundary(value, value + self.registers[X]._)),
      )
    }
    AbsoluteY => {
      let value = self.read_instruction_word()
      (
        value + self.registers[Y].to_u16() |> u16,
        Some(((value & 0xFF00) | u16(u8(value) + self.registers[Y]), -1)),
        Some(page_boundary(value, value + self.registers[Y]._)),
      )
    }

    //
    ZeroPage => {
      let offset = self.read_instruction()
      // (offset |> u16, Some((self.pc, self.read_zeropage(offset))), None)
      (offset |> u16, None, None) // 0x44
      // (offset |> u16, Some((offset._, 0)), None) // 0x05
    }
    ZeroPageX => {
      let offset = self.read_instruction()
      let value = self.read_zeropage(offset)
      (
        offset + self.registers[X] |> u16,
        None, // Some((self.pc, self.read_zeropage(offset))),
        None,
      )
    }
    ZeroPageY => {
      let offset = self.read_instruction()
      let value = self.read_zeropage(offset)
      (
        offset + self.registers[Y] |> u16,
        None, // Some((self.pc, self.read_zeropage(offset))),
        None,
      )
    }

    // X-Indexed Zero Page Indirect
    IndexedIndirect => {
      let offset = self.read_instruction()
      let byte = self.read_zeropage(offset) // |> ignore // FIXME: pre-fetch
      let value = self.read_zeropage_word(offset + self.registers[X])
      (
        value |> u16,
        None,
        Some(page_boundary(offset._, u16(offset + self.registers[X]))),
      )
    }
    // Zero Page Indirect Y-Indexed
    IndirectIndexed => {
      let offset = self.read_instruction()
      let value = self.read_zeropage_word(offset)
      (
        value + self.registers[Y].to_int() |> u16,
        Some(((value & 0xFF00) | u16(u8(value) + self.registers[Y]), -1)),
        Some(page_boundary(value, value + self.registers[Y].to_int())),
      )
    }
    Indirect => {
      let address = self.read_address_word(self.pc)
      let value = self.read_zeropage_address_word(address)
      (value |> u16, None, None)
    }
    Relative => {
      let offset = self.read_instruction().to_signed()
      (
        self.pc + offset |> u16,
        Some(((self.pc & 0xFF00) | u16(u8(self.pc + offset)), offset)),
        Some(page_boundary(self.pc, self.pc + offset)),
      )
    }
    _ => panic()
  }
}
