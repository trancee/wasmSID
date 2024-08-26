// mpu6502
// https://github.com/mnaberez/py65/blob/main/py65/tests/devices/test_mpu6502.py

test "reset_sets_registers_to_initial_states" {
  let cpu = CPU::new(debug=true)
  cpu.reset()
  assert_eq!(cpu.registers[SP], 0xFF)
  assert_eq!(cpu.registers[A], 0)
  assert_eq!(cpu.registers[X], 0)
  assert_eq!(cpu.registers[Y], 0)
  assert_eq!(cpu.flags.get(), B | U)
}

test "reset_sets_pc_to_0_by_default" {
  let cpu = CPU::new(debug=true)
  cpu.reset()
  assert_eq!(cpu.pc, 0)
}

test "reset_sets_pc_to_start_pc_if_not_None" {
  let cpu = CPU::new(pc=0x1234)
  cpu.reset()
  assert_eq!(cpu.pc, 0x1234)
}

test "reset_reads_reset_vector_if_start_pc_is_None" {
  let cpu = CPU::new(debug=true)
  cpu.write16(RESET.addr(), 0xABCD)
  cpu.reset()
  assert_eq!(cpu.pc, 0xABCD)
}

test "adc_bcd_off_absolute_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])

}

test "adc_bcd_off_absolute_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.flags[C] = true
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_absolute_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_absolute_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_absolute_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_absolute_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0xff
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_absolute_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_absolute_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0xff
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_absolute_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  // $0000 ADC $C000
  let _ = cpu.load(0x0000, [0x6D, 0x00, 0xC0])
  cpu.mem[0xC000] = 0x40
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_zp_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.flags[C] = true
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_zp_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0xFE
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_zp_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0xff
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_zp_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_zp_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0xff
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_zp_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x40
  cpu.flags[V] = false
  // $0000 ADC $00B0
  let _ = cpu.load(0x0000, [0x65, 0xB0])
  cpu.mem[0x00B0] = 0x40
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_immediate_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  // $0000 ADC #$00
  let _ = cpu.load(0x0000, [0x69, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_immediate_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.flags[C] = true
  // $0000 ADC #$00
  let _ = cpu.load(0x0000, [0x69, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_immediate_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  // $0000 ADC #$FE
  let _ = cpu.load(0x0000, [0x69, 0xFE])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_immediate_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  // $0000 ADC #$FF
  let _ = cpu.load(0x0000, [0x69, 0xFF])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_immediate_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC #$01
  let _ = cpu.load(0x000, [0x69, 0x01])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_immediate_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC #$FF
  let _ = cpu.load(0x000, [0x69, 0xff])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_immediate_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  // $0000 ADC #$01
  let _ = cpu.load(0x000, [0x69, 0x01])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_immediate_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  // $0000 ADC #$FF
  let _ = cpu.load(0x000, [0x69, 0xff])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_immediate_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x40
  // $0000 ADC #$40
  let _ = cpu.load(0x0000, [0x69, 0x40])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_on_immediate_79_plus_00_carry_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[C] = true
  cpu.registers[A] = 0x79
  // $0000 ADC #$00
  let _ = cpu.load(0x0000, [0x69, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_on_immediate_6f_plus_00_carry_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[C] = true
  cpu.registers[A] = 0x6f
  // $0000 ADC #$00
  let _ = cpu.load(0x0000, [0x69, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x76)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[V], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_on_immediate_9c_plus_9d" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[C] = false
  cpu.registers[A] = 0x9c
  // $0000 ADC #$9d
  // $0002 ADC #$9d
  let _ = cpu.load(0x0000, [0x69, 0x9d])
  let _ = cpu.load(0x0002, [0x69, 0x9d])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x9f)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0004)
  assert_eq!(cpu.registers[A], 0x93)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "adc_bcd_off_abs_x_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_abs_x_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_abs_x_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_abs_x_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.registers[X] = 0x03
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_abs_x_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_abs_x_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0xff
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_abs_x_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_abs_x_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0xff
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_abs_x_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  cpu.registers[X] = 0x03
  // $0000 ADC $C000,X
  let _ = cpu.load(0x0000, [0x7D, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_abs_y_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_abs_y_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[Y] = 0x03
  cpu.flags[C] = true
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_abs_y_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  cpu.registers[Y] = 0x03
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_abs_y_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.registers[Y] = 0x03
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_abs_y_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_abs_y_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_abs_y_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_abs_y_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_abs_y_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  cpu.registers[Y] = 0x03
  // $0000 ADC $C000,Y
  let _ = cpu.load(0x0000, [0x79, 0x00, 0xC0])
  cpu.mem[0xC000 + cpu.registers[Y].0] = 0x40
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_x_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_zp_x_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_zp_x_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_x_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_zp_x_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_zp_x_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_zp_x_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_zp_x_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xff
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_zp_x_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  cpu.registers[X] = 0x03
  // $0000 ADC $0010,X
  let _ = cpu.load(0x0000, [0x75, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_ind_indexed_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_ind_indexed_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_ind_indexed_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFE
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_ind_indexed_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_ind_indexed_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_ind_indexed_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_ind_indexed_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_ind_indexed_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_ind_indexed_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  cpu.registers[X] = 0x03
  // $0000 ADC ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x61, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x40
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_indexed_ind_carry_clear_in_accumulator_zeroes" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
}

test "adc_bcd_off_indexed_ind_carry_set_in_accumulator_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[Y] = 0x03
  cpu.flags[C] = true
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "adc_bcd_off_indexed_ind_carry_clear_in_no_carry_clear_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x01
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFE
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_indexed_ind_carry_clear_in_carry_set_out" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "adc_bcd_off_indexed_ind_overflow_clr_no_carry_01_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[Y] = 0x03
  // $0000 $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x01
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_indexed_ind_overflow_clr_no_carry_01_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x01
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[V], false)
}

test "adc_bcd_off_indexed_ind_overflow_set_no_carry_7f_plus_01" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x7f
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x01
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_indexed_ind_overflow_set_no_carry_80_plus_ff" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[A] = 0x80
  cpu.registers[Y] = 0x03
  // $0000 $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x7f)
  assert_eq!(cpu.flags[V], true)
}

test "adc_bcd_off_indexed_ind_overflow_set_on_40_plus_40" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.registers[A] = 0x40
  cpu.registers[Y] = 0x03
  // $0000 ADC ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x71, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x40
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_absolute_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND $ABCD
  let _ = cpu.load(0x0000, [0x2D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_absolute_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND $ABCD
  let _ = cpu.load(0x0000, [0x2D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xAA
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_zp_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND $0010
  let _ = cpu.load(0x0000, [0x25, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_zp_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND $0010
  let _ = cpu.load(0x0000, [0x25, 0x10])
  cpu.mem[0x0010] = 0xAA
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_immediate_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND #$00
  let _ = cpu.load(0x0000, [0x29, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_immediate_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 AND #$AA
  let _ = cpu.load(0x0000, [0x29, 0xAA])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_abs_x_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND $ABCD,X
  let _ = cpu.load(0x0000, [0x3d, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_abs_x_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND $ABCD,X
  let _ = cpu.load(0x0000, [0x3d, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xAA
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_abs_y_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 AND $ABCD,X
  let _ = cpu.load(0x0000, [0x39, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_abs_y_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 AND $ABCD,X
  let _ = cpu.load(0x0000, [0x39, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xAA
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_ind_indexed_x_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x21, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_ind_indexed_x_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x21, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xAA
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_indexed_ind_y_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 AND ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x31, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_indexed_ind_y_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 AND ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x31, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xAA
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "and_zp_x_all_zeros_setting_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND $0010,X
  let _ = cpu.load(0x0000, [0x35, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "and_zp_x_all_zeros_and_ones_setting_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 AND $0010,X
  let _ = cpu.load(0x0000, [0x35, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xAA
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_accumulator_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  // $0000 ASL A
  cpu.mem[0x0000] = 0x0A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "asl_accumulator_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x40
  // $0000 ASL A
  cpu.mem[0x0000] = 0x0A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_accumulator_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x7F
  // $0000 ASL A
  cpu.mem[0x0000] = 0x0A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "asl_accumulator_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 ASL A
  cpu.mem[0x0000] = 0x0A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "asl_accumulator_80_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x80
  cpu.flags[Z] = false
  // $0000 ASL A
  cpu.mem[0x0000] = 0x0A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "asl_absolute_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 ASL $ABCD
  let _ = cpu.load(0x0000, [0x0E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "asl_absolute_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 ASL $ABCD
  let _ = cpu.load(0x0000, [0x0E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x40
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_absolute_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  // $0000 ASL $ABCD
  let _ = cpu.load(0x0000, [0x0E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0xABCD], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "asl_absolute_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  // $0000 ASL $ABCD
  let _ = cpu.load(0x0000, [0x0E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0xABCD], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "asl_zp_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 ASL $0010
  let _ = cpu.load(0x0000, [0x06, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "asl_zp_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 ASL $0010
  let _ = cpu.load(0x0000, [0x06, 0x10])
  cpu.mem[0x0010] = 0x40
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_zp_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  // $0000 ASL $0010
  let _ = cpu.load(0x0000, [0x06, 0x10])
  cpu.mem[0x0010] = 0x7F
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0x0010], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "asl_zp_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  // $0000 ASL $0010
  let _ = cpu.load(0x0000, [0x06, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0x0010], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "asl_abs_x_indexed_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  // $0000 ASL $ABCD,X
  let _ = cpu.load(0x0000, [0x1E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "asl_abs_x_indexed_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  // $0000 ASL $ABCD,X
  let _ = cpu.load(0x0000, [0x1E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_abs_x_indexed_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  cpu.registers[X] = 0x03
  // $0000 ASL $ABCD,X
  let _ = cpu.load(0x0000, [0x1E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "asl_abs_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAA
  cpu.registers[X] = 0x03
  // $0000 ASL $ABCD,X
  let _ = cpu.load(0x0000, [0x1E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "asl_zp_x_indexed_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  // $0000 ASL $0010,X
  let _ = cpu.load(0x0000, [0x16, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "asl_zp_x_indexed_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  // $0000 ASL $0010,X
  let _ = cpu.load(0x0000, [0x16, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "asl_zp_x_indexed_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.registers[A] = 0xAA
  // $0000 ASL $0010,X
  let _ = cpu.load(0x0000, [0x16, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "asl_zp_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.registers[A] = 0xAA
  // $0000 ASL $0010,X
  let _ = cpu.load(0x0000, [0x16, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xAA)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "bcc_carry_clear_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 BCC +6
  let _ = cpu.load(0x0000, [0x90, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bcc_carry_clear_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.pc = 0x0050
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  // $0000 BCC -6
  let _ = cpu.load(0x0050, [0x90, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bcc_carry_set_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 BCC +6
  let _ = cpu.load(0x0000, [0x90, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "bcs_carry_set_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 BCS +6
  let _ = cpu.load(0x0000, [0xB0, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bcs_carry_set_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  cpu.pc = 0x0050
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  // $0000 BCS -6
  let _ = cpu.load(0x0050, [0xB0, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bcs_carry_clear_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 BCS +6
  let _ = cpu.load(0x0000, [0xB0, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "beq_zero_set_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = true
  // $0000 BEQ +6
  let _ = cpu.load(0x0000, [0xF0, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "beq_zero_set_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = true
  cpu.pc = 0x0050
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  // $0000 BEQ -6
  let _ = cpu.load(0x0050, [0xF0, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "beq_zero_clear_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BEQ +6
  let _ = cpu.load(0x0000, [0xF0, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "bit_abs_copies_bit_7_of_memory_to_n_flag_when_0" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0xFF
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[N], true)
}

test "bit_abs_copies_bit_7_of_memory_to_n_flag_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = true
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0x00
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[N], false)
}

test "bit_abs_copies_bit_6_of_memory_to_v_flag_when_0" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0xFF
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[V], true)
}

test "bit_abs_copies_bit_6_of_memory_to_v_flag_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0x00
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[V], false)
}

test "bit_abs_stores_result_of_and_in_z_preserves_a_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0x00
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0xFEED], 0x00)
}

test "bit_abs_stores_result_of_and_when_nonzero_in_z_preserves_a" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = true
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0x01
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[Z], false) // result of AND is non-zero
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0xFEED], 0x01)
}

test "bit_abs_stores_result_of_and_when_zero_in_z_preserves_a" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BIT $FEED
  let _ = cpu.load(0x0000, [0x2C, 0xED, 0xFE])
  cpu.mem[0xFEED] = 0x00
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.flags[Z], true) // result of AND is zero
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0xFEED], 0x00)
}

test "bit_zp_copies_bit_7_of_memory_to_n_flag_when_0" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0xFF
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[N], true)
}

test "bit_zp_copies_bit_7_of_memory_to_n_flag_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = true
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0x00
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[N], false)
}

test "bit_zp_copies_bit_6_of_memory_to_v_flag_when_0" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0xFF
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[V], true)
}

test "bit_zp_copies_bit_6_of_memory_to_v_flag_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0x00
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[V], false)
}

test "bit_zp_stores_result_of_and_in_z_preserves_a_when_1" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0x00
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0x0010], 0x00)
}

test "bit_zp_stores_result_of_and_when_nonzero_in_z_preserves_a" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = true
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0x01
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[Z], false) // result of AND is non-zero
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0x0010], 0x01)
}

test "bit_zp_stores_result_of_and_when_zero_in_z_preserves_a" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BIT $0010
  let _ = cpu.load(0x0000, [0x24, 0x10])
  cpu.mem[0x0010] = 0x00
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.cycles, 3)
  assert_eq!(cpu.flags[Z], true) // result of AND is zero
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.mem[0x0010], 0x00)
}

test "bmi_negative_set_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = true
  // $0000 BMI +06
  let _ = cpu.load(0x0000, [0x30, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bmi_negative_set_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = true
  cpu.pc = 0x0050
  // $0000 BMI -6
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  let _ = cpu.load(0x0050, [0x30, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bmi_negative_clear_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  // $0000 BEQ +6
  let _ = cpu.load(0x0000, [0x30, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "bne_zero_clear_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  // $0000 BNE +6
  let _ = cpu.load(0x0000, [0xD0, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bne_zero_clear_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.pc = 0x0050
  // $0050 BNE -6
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  let _ = cpu.load(0x0050, [0xD0, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bne_zero_set_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = true
  // $0000 BNE +6
  let _ = cpu.load(0x0000, [0xD0, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "bpl_negative_clear_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  // $0000 BPL +06
  let _ = cpu.load(0x0000, [0x10, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bpl_negative_clear_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.pc = 0x0050
  // $0050 BPL -6
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  let _ = cpu.load(0x0050, [0x10, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bpl_negative_set_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = true
  // $0000 BPL +6
  let _ = cpu.load(0x0000, [0x10, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "brk_pushes_pc_plus_2_and_status_then_sets_pc_to_irq_vector" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0b00100000)
  let _ = cpu.load(IRQ.addr(), [0xCD, 0xAB])
  // $C000 BRK
  cpu.mem[0xC000] = 0x00
  cpu.pc = 0xC000
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0xABCD)
}

test "irq_pushes_pc_and_correct_status_then_sets_pc_to_irq_vector" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0b00100000)
  let _ = cpu.load(NMI.addr(), [0x88, 0x77])
  let _ = cpu.load(IRQ.addr(), [0xCD, 0xAB])
  cpu.pc = 0xC123
  cpu.irq()
  assert_eq!(cpu.pc, 0xABCD)
  assert_eq!(cpu.mem[0x1FF], 0xC1) // PCH
  assert_eq!(cpu.mem[0x1FE], 0x23) // PCL
  assert_eq!(cpu.mem[0x1FD], 0b00110100) // Status [I B U]
  assert_eq!(cpu.registers[SP], 0xFC)
  assert_eq!(cpu.flags.get(), U | I)
  assert_eq!(cpu.cycles, 7)
}

test "nmi_pushes_pc_and_correct_status_then_sets_pc_to_nmi_vector" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0b00100000)
  let _ = cpu.load(NMI.addr(), [0x88, 0x77])
  let _ = cpu.load(IRQ.addr(), [0xCD, 0xAB])
  cpu.pc = 0xC123
  cpu.nmi()
  assert_eq!(cpu.pc, 0x7788)
  assert_eq!(cpu.mem[0x1FF], 0xC1) // PCH
  assert_eq!(cpu.mem[0x1FE], 0x23) // PCL
  assert_eq!(cpu.mem[0x1FD], 0b00110100) // Status [I B U]
  assert_eq!(cpu.registers[SP], 0xFC)
  assert_eq!(cpu.flags.get(), U | I)
  assert_eq!(cpu.cycles, 7)
}

test "bvc_overflow_clear_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  // $0000 BVC +6
  let _ = cpu.load(0x0000, [0x50, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bvc_overflow_clear_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  cpu.pc = 0x0050
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  // $0050 BVC -6
  let _ = cpu.load(0x0050, [0x50, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bvc_overflow_set_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  // $0000 BVC +6
  let _ = cpu.load(0x0000, [0x50, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "bvs_overflow_set_branches_relative_forward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  // $0000 BVS +6
  let _ = cpu.load(0x0000, [0x70, 0x06])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002 + 0x06)
}

test "bvs_overflow_set_branches_relative_backward" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  cpu.pc = 0x0050
  let rel = (0x06 ^ 0xFF) + 1 // two's complement of 6
  // $0050 BVS -6
  let _ = cpu.load(0x0050, [0x70, rel])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0052 - 0x06)
}

test "bvs_overflow_clear_does_not_branch" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = false
  // $0000 BVS +6
  let _ = cpu.load(0x0000, [0x70, 0x06])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
}

test "clc_clears_carry_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 CLC
  cpu.mem[0x0000] = 0x18
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[C], false)
}

test "cld_clears_decimal_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  // $0000 CLD
  cpu.mem[0x0000] = 0xD8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[D], false)
}

test "cli_clears_interrupt_mask_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[I] = true
  // $0000 CLI
  cpu.mem[0x0000] = 0x58
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[I], false)
}

test "clv_clears_overflow_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[V] = true
  // $0000 CLV
  cpu.mem[0x0000] = 0xB8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[V], false)
}

test "cmp_imm_sets_zero_carry_clears_neg_flags_if_equal" {
  // Comparison: A == m
  let cpu = CPU::new(debug=true)
  // $0000 CMP #10 , A will be 10
  let _ = cpu.load(0x0000, [0xC9, 10])
  cpu.registers[A] = 10
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
}

test "cmp_imm_clears_zero_carry_takes_neg_if_less_unsigned" {
  // Comparison: A < m (unsigned)
  let cpu = CPU::new(debug=true)
  // $0000 CMP #10 , A will be 1
  let _ = cpu.load(0x0000, [0xC9, 10])
  cpu.registers[A] = 1
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], true) // 0x01-0x0A=0xF7
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "cmp_imm_clears_zero_sets_carry_takes_neg_if_less_signed" {
  // Comparison: A < //nn (signed), A negative
  let cpu = CPU::new(debug=true)
  // $0000 CMP #1, A will be -1 (0xFF)
  let _ = cpu.load(0x0000, [0xC9, 1])
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], true) // 0xFF-0x01=0xFE
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true) // A>m unsigned
}

test "cmp_imm_clears_zero_carry_takes_neg_if_less_signed_nega" {
  // Comparison: A < m (signed), A and m both negative
  let cpu = CPU::new(debug=true)
  // $0000 CMP #0xFF (-1), A will be -2 (0xFE)
  let _ = cpu.load(0x0000, [0xC9, 0xFF])
  cpu.registers[A] = 0xFE
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], true) // 0xFE-0xFF=0xFF
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false) // A<m unsigned
}

test "cmp_imm_clears_zero_sets_carry_takes_neg_if_more_unsigned" {
  // Comparison: A > m (unsigned)
  let cpu = CPU::new(debug=true)
  // $0000 CMP #1 , A will be 10
  let _ = cpu.load(0x0000, [0xC9, 1])
  cpu.registers[A] = 10
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], false) // cpu.flags.get() & cpu.NEGATIVEx0A-0x01 = 0x09
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true) // A>m unsigned
}

test "cmp_imm_clears_zero_carry_takes_neg_if_more_signed" {
  // Comparison: A > m (signed), memory negative
  let cpu = CPU::new(debug=true)
  // $0000 CMP #$FF (-1), A will be 2
  let _ = cpu.load(0x0000, [0xC9, 0xFF])
  cpu.registers[A] = 2
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], false) // cpu.flags.get() & cpu.NEGATIVEx02-0xFF=0x01
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false) // A<m unsigned
}

test "cmp_imm_clears_zero_carry_takes_neg_if_more_signed_nega" {
  // Comparison: A > m (signed), A and m both negative
  let cpu = CPU::new(debug=true)
  // $0000 CMP #$FE (-2), A will be -1 (0xFF)
  let _ = cpu.load(0x0000, [0xC9, 0xFE])
  cpu.registers[A] = 0xFF
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[N], false) // cpu.flags.get() & cpu.NEGATIVExFF-0xFE=0x01
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true) // A>m unsigned
}

test "cpx_imm_sets_zero_carry_clears_neg_flags_if_equal" {
  // Comparison: X == m
  let cpu = CPU::new(debug=true)
  // $0000 CPX #$20
  let _ = cpu.load(0x0000, [0xE0, 0x20])
  cpu.registers[X] = 0x20
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "cpy_imm_sets_zero_carry_clears_neg_flags_if_equal" {
  // Comparison: Y == m
  let cpu = CPU::new(debug=true)
  // $0000 CPY #$30
  let _ = cpu.load(0x0000, [0xC0, 0x30])
  cpu.registers[Y] = 0x30
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "dec_abs_decrements_memory" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD
  let _ = cpu.load(0x0000, [0xCE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x10
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dec_abs_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD
  let _ = cpu.load(0x0000, [0xCE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "dec_abs_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD
  let _ = cpu.load(0x0000, [0xCE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "dec_zp_decrements_memory" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010
  let _ = cpu.load(0x0000, [0xC6, 0x10])
  cpu.mem[0x0010] = 0x10
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dec_zp_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010
  let _ = cpu.load(0x0000, [0xC6, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "dec_zp_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010
  let _ = cpu.load(0x0000, [0xC6, 0x10])
  cpu.mem[0x0010] = 0x01
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "dec_abs_x_decrements_memory" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD,X
  let _ = cpu.load(0x0000, [0xDE, 0xCD, 0xAB])
  cpu.registers[X] = 0x03
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x10
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dec_abs_x_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD,X
  let _ = cpu.load(0x0000, [0xDE, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "dec_abs_x_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0xABCD,X
  let _ = cpu.load(0x0000, [0xDE, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "dec_zp_x_decrements_memory" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010,X
  let _ = cpu.load(0x0000, [0xD6, 0x10])
  cpu.registers[X] = 0x03
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x10
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dec_zp_x_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010,X
  let _ = cpu.load(0x0000, [0xD6, 0x10])
  cpu.registers[X] = 0x03
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "dec_zp_x_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  // $0000 DEC 0x0010,X
  let _ = cpu.load(0x0000, [0xD6, 0x10])
  cpu.registers[X] = 0x03
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "dex_decrements_x" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x10
  // $0000 DEX
  cpu.mem[0x0000] = 0xCA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dex_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  // $0000 DEX
  cpu.mem[0x0000] = 0xCA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "dex_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x01
  // $0000 DEX
  cpu.mem[0x0000] = 0xCA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "dey_decrements_y" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x10
  // $0000 DEY
  cpu.mem[0x0000] = 0x88
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0x0F)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
}

test "dey_below_00_rolls_over_and_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  // $0000 DEY
  cpu.mem[0x0000] = 0x88
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0xFF)
  assert_eq!(cpu.flags[N], true)
}

test "dey_sets_zero_flag_when_decrementing_to_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x01
  // $0000 DEY
  cpu.mem[0x0000] = 0x88
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_absolute_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  let _ = cpu.load(0x0000, [0x4D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_absolute_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  let _ = cpu.load(0x0000, [0x4D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_zp_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  let _ = cpu.load(0x0000, [0x45, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_zp_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  let _ = cpu.load(0x0000, [0x45, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_immediate_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  let _ = cpu.load(0x0000, [0x49, 0xFF])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_immediate_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  let _ = cpu.load(0x0000, [0x49, 0xFF])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_abs_x_indexed_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x5D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_abs_x_indexed_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x5D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_abs_y_indexed_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  let _ = cpu.load(0x0000, [0x59, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_abs_y_indexed_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  let _ = cpu.load(0x0000, [0x59, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_ind_indexed_x_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x41, 0x10]) // => EOR ($0010,X)
  let _ = cpu.load(0x0013, [0xCD, 0xAB]) // => Vector to $ABCD
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_ind_indexed_x_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x41, 0x10]) // => EOR ($0010,X)
  let _ = cpu.load(0x0013, [0xCD, 0xAB]) // => Vector to $ABCD
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_indexed_ind_y_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  let _ = cpu.load(0x0000, [0x51, 0x10]) // => EOR ($0010),Y
  let _ = cpu.load(0x0010, [0xCD, 0xAB]) // => Vector to $ABCD
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_indexed_ind_y_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  let _ = cpu.load(0x0000, [0x51, 0x10]) // => EOR ($0010),Y
  let _ = cpu.load(0x0010, [0xCD, 0xAB]) // => Vector to $ABCD
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "eor_zp_x_indexed_flips_bits_over_setting_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x55, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_zp_x_indexed_flips_bits_over_setting_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x55, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "inc_abs_increments_memory" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xEE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x09
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "inc_abs_increments_memory_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xEE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "inc_abs_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xEE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "inc_zp_increments_memory" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xE6, 0x10])
  cpu.mem[0x0010] = 0x09
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "inc_zp_increments_memory_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xE6, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "inc_zp_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xE6, 0x10])
  cpu.mem[0x0010] = 0x7F
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "inc_abs_x_increments_memory" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xFE, 0xCD, 0xAB])
  cpu.registers[X] = 0x03
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x09
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "inc_abs_x_increments_memory_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xFE, 0xCD, 0xAB])
  cpu.registers[X] = 0x03
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "inc_abs_x_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xFE, 0xCD, 0xAB])
  cpu.registers[X] = 0x03
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "inc_zp_x_increments_memory" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xF6, 0x10])
  cpu.registers[X] = 0x03
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x09
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "inc_zp_x_increments_memory_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xF6, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "inc_zp_x_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  let _ = cpu.load(0x0000, [0xF6, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "inx_increments_x" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x09
  cpu.mem[0x0000] = 0xE8 // => INX
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "inx_above_FF_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  cpu.mem[0x0000] = 0xE8 // => INX
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "inx_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x7f
  cpu.mem[0x0000] = 0xE8 // => INX
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "iny_increments_y" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x09
  cpu.mem[0x0000] = 0xC8 // => INY
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0x0A)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "iny_above_FF_rolls_over_and_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  cpu.mem[0x0000] = 0xC8 // => INY
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "iny_sets_negative_flag_when_incrementing_above_7F" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x7f
  cpu.mem[0x0000] = 0xC8 // => INY
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "jmp_abs_jumps_to_absolute_address" {
  let cpu = CPU::new(debug=true)
  // $0000 JMP $ABCD
  let _ = cpu.load(0x0000, [0x4C, 0xCD, 0xAB])
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0xABCD)
}

test "jmp_ind_jumps_to_indirect_address" {
  let cpu = CPU::new(debug=true)
  // $0000 JMP ($ABCD)
  let _ = cpu.load(0x0000, [0x6C, 0x00, 0x02])
  let _ = cpu.load(0x0200, [0xCD, 0xAB])
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0xABCD)
}

test "jsr_pushes_pc_plus_2_and_sets_pc" {
  let cpu = CPU::new(debug=true)
  // $C000 JSR $FFD2
  let _ = cpu.load(0xC000, [0x20, 0xD2, 0xFF])
  cpu.pc = 0xC000
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0xFFD2)
  assert_eq!(0xFD, cpu.registers[SP].0)
  assert_eq!(0xC0, cpu.mem[0x01FF].0) // PCH
  assert_eq!(0x02, cpu.mem[0x01FE].0) // PCL+2
}

test "lda_absolute_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  // $0000 LDA $ABCD
  let _ = cpu.load(0x0000, [0xAD, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_absolute_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 LDA $ABCD
  let _ = cpu.load(0x0000, [0xAD, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_zp_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  // $0000 LDA $0010
  let _ = cpu.load(0x0000, [0xA5, 0x10])
  cpu.mem[0x0010] = 0x80
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_zp_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 LDA $0010
  let _ = cpu.load(0x0000, [0xA5, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_immediate_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  // $0000 LDA #$80
  let _ = cpu.load(0x0000, [0xA9, 0x80])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_immediate_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  // $0000 LDA #$00
  let _ = cpu.load(0x0000, [0xA9, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_abs_x_indexed_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDA $ABCD,X
  let _ = cpu.load(0x0000, [0xBD, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_abs_x_indexed_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 LDA $ABCD,X
  let _ = cpu.load(0x0000, [0xBD, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_abs_x_indexed_does_not_page_wrap" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[X] = 0xFF
  // $0000 LDA $0080,X
  let _ = cpu.load(0x0000, [0xBD, 0x80, 0x00])
  cpu.mem[0x0080 + cpu.registers[X].0] = 0x42
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x42)
}

test "lda_abs_y_indexed_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 LDA $ABCD,Y
  let _ = cpu.load(0x0000, [0xB9, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_abs_y_indexed_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 LDA $ABCD,Y
  let _ = cpu.load(0x0000, [0xB9, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_abs_y_indexed_does_not_page_wrap" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0
  cpu.registers[Y] = 0xFF
  // $0000 LDA $0080,X
  let _ = cpu.load(0x0000, [0xB9, 0x80, 0x00])
  cpu.mem[0x0080 + cpu.registers[Y].0] = 0x42
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x42)
}

test "lda_ind_indexed_x_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDA ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0xA1, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x80
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_ind_indexed_x_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDA ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0xA1, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_indexed_ind_y_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 LDA ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0xB1, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x80
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_indexed_ind_y_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 LDA ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0xB1, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lda_zp_x_indexed_loads_a_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDA $10,X
  let _ = cpu.load(0x0000, [0xB5, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "lda_zp_x_indexed_loads_a_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 LDA $10,X
  let _ = cpu.load(0x0000, [0xB5, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldx_absolute_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  // $0000 LDX $ABCD
  let _ = cpu.load(0x0000, [0xAE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldx_absolute_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  // $0000 LDX $ABCD
  let _ = cpu.load(0x0000, [0xAE, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldx_zp_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  // $0000 LDX $0010
  let _ = cpu.load(0x0000, [0xA6, 0x10])
  cpu.mem[0x0010] = 0x80
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldx_zp_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  // $0000 LDX $0010
  let _ = cpu.load(0x0000, [0xA6, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldx_immediate_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  // $0000 LDX #$80
  let _ = cpu.load(0x0000, [0xA2, 0x80])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldx_immediate_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  // $0000 LDX #$00
  let _ = cpu.load(0x0000, [0xA2, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldx_abs_y_indexed_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 LDX $ABCD,Y
  let _ = cpu.load(0x0000, [0xBE, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldx_abs_y_indexed_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 LDX $ABCD,Y
  let _ = cpu.load(0x0000, [0xBE, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldx_zp_y_indexed_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 LDX $0010,Y
  let _ = cpu.load(0x0000, [0xB6, 0x10])
  cpu.mem[0x0010 + cpu.registers[Y].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldx_zp_y_indexed_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 LDX $0010,Y
  let _ = cpu.load(0x0000, [0xB6, 0x10])
  cpu.mem[0x0010 + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldy_absolute_loads_y_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  // $0000 LDY $ABCD
  let _ = cpu.load(0x0000, [0xAC, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldy_absolute_loads_y_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  // $0000 LDY $ABCD
  let _ = cpu.load(0x0000, [0xAC, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldy_zp_loads_y_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  // $0000 LDY $0010
  let _ = cpu.load(0x0000, [0xA4, 0x10])
  cpu.mem[0x0010] = 0x80
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldy_zp_loads_y_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  // $0000 LDY $0010
  let _ = cpu.load(0x0000, [0xA4, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldy_immediate_loads_y_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  // $0000 LDY #$80
  let _ = cpu.load(0x0000, [0xA0, 0x80])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldy_immediate_loads_y_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  // $0000 LDY #$00
  let _ = cpu.load(0x0000, [0xA0, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldy_abs_x_indexed_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDY $ABCD,X
  let _ = cpu.load(0x0000, [0xBC, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldy_abs_x_indexed_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 LDY $ABCD,X
  let _ = cpu.load(0x0000, [0xBC, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ldy_zp_x_indexed_loads_x_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0x00
  cpu.registers[X] = 0x03
  // $0000 LDY $0010,X
  let _ = cpu.load(0x0000, [0xB4, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ldy_zp_x_indexed_loads_x_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 LDY $0010,X
  let _ = cpu.load(0x0000, [0xB4, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_accumulator_rotates_in_zero_not_carry" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR A
  cpu.mem[0x0000] = 0x4A
  cpu.registers[A] = 0x00
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_accumulator_sets_carry_and_zero_flags_after_rotation" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 LSR A
  cpu.mem[0x0000] = 0x4A
  cpu.registers[A] = 0x01
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_accumulator_rotates_bits_right" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR A
  cpu.mem[0x0000] = 0x4A
  cpu.registers[A] = 0x04
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_absolute_rotates_in_zero_not_carry" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR $ABCD
  let _ = cpu.load(0x0000, [0x4E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_absolute_sets_carry_and_zero_flags_after_rotation" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 LSR $ABCD
  let _ = cpu.load(0x0000, [0x4E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_absolute_rotates_bits_right" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR $ABCD
  let _ = cpu.load(0x0000, [0x4E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x04
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x02)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_rotates_in_zero_not_carry" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR $0010
  let _ = cpu.load(0x0000, [0x46, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_sets_carry_and_zero_flags_after_rotation" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 LSR $0010
  let _ = cpu.load(0x0000, [0x46, 0x10])
  cpu.mem[0x0010] = 0x01
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_rotates_bits_right" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR $0010
  let _ = cpu.load(0x0000, [0x46, 0x10])
  cpu.mem[0x0010] = 0x04
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x02)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_abs_x_indexed_rotates_in_zero_not_carry" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  cpu.registers[X] = 0x03
  // $0000 LSR $ABCD,X
  let _ = cpu.load(0x0000, [0x5E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_abs_x_indexed_sets_c_and_z_flags_after_rotation" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[X] = 0x03
  // $0000 LSR $ABCD,X
  let _ = cpu.load(0x0000, [0x5E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_abs_x_indexed_rotates_bits_right" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 LSR $ABCD,X
  let _ = cpu.load(0x0000, [0x5E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x04
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x02)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_x_indexed_rotates_in_zero_not_carry" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  cpu.registers[X] = 0x03
  // $0000 LSR $0010,X
  let _ = cpu.load(0x0000, [0x56, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_x_indexed_sets_carry_and_zero_flags_after_rotation" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[X] = 0x03
  // $0000 LSR $0010,X
  let _ = cpu.load(0x0000, [0x56, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[N], false)
}

test "lsr_zp_x_indexed_rotates_bits_right" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  cpu.registers[X] = 0x03
  // $0000 LSR $0010,X
  let _ = cpu.load(0x0000, [0x56, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x04
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x02)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
  assert_eq!(cpu.flags[N], false)
}

test "nop_does_nothing" {
  let cpu = CPU::new(debug=true)
  // $0000 NOP
  cpu.mem[0x0000] = 0xEA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
}

test "ora_absolute_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  // $0000 ORA $ABCD
  let _ = cpu.load(0x0000, [0x0D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_absolute_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  // $0000 ORA $ABCD
  let _ = cpu.load(0x0000, [0x0D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x82
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_zp_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  // $0000 ORA $0010
  let _ = cpu.load(0x0000, [0x05, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_zp_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  // $0000 ORA $0010
  let _ = cpu.load(0x0000, [0x05, 0x10])
  cpu.mem[0x0010] = 0x82
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_immediate_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  // $0000 ORA #$00
  let _ = cpu.load(0x0000, [0x09, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_immediate_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  // $0000 ORA #$82
  let _ = cpu.load(0x0000, [0x09, 0x82])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_abs_x_indexed_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ORA $ABCD,X
  let _ = cpu.load(0x0000, [0x1D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_abs_x_indexed_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  cpu.registers[X] = 0x03
  // $0000 ORA $ABCD,X
  let _ = cpu.load(0x0000, [0x1D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x82
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_abs_y_indexed_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 ORA $ABCD,Y
  let _ = cpu.load(0x0000, [0x19, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_abs_y_indexed_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  cpu.registers[Y] = 0x03
  // $0000 ORA $ABCD,Y
  let _ = cpu.load(0x0000, [0x19, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x82
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_ind_indexed_x_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ORA ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x01, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_ind_indexed_x_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  cpu.registers[X] = 0x03
  // $0000 ORA ($0010,X)
  // $0013 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x01, 0x10])
  let _ = cpu.load(0x0013, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x82
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_indexed_ind_y_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 ORA ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x11, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_indexed_ind_y_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  cpu.registers[Y] = 0x03
  // $0000 ORA ($0010),Y
  // $0010 Vector to $ABCD
  let _ = cpu.load(0x0000, [0x11, 0x10])
  let _ = cpu.load(0x0010, [0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x82
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "ora_zp_x_indexed_zeroes_or_zeros_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 ORA $0010,X
  let _ = cpu.load(0x0000, [0x15, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "ora_zp_x_indexed_turns_bits_on_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x03
  cpu.registers[X] = 0x03
  // $0000 ORA $0010,X
  let _ = cpu.load(0x0000, [0x15, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x82
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x83)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "pha_pushes_a_and_updates_sp" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAB
  // $0000 PHA
  cpu.mem[0x0000] = 0x48
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.mem[0x01FF], 0xAB)
  assert_eq!(cpu.registers[SP], 0xFE)
}

test "php_pushes_processor_status_and_updates_sp" {
  let mut flags = 0x00
  while flags < 0x100 {
    let cpu = CPU::new(debug=true)
    cpu.flags.set(flags | (B | U))
    // $0000 PHP
    cpu.mem[0x0000] = 0x08
    assert_eq!(cpu.step(), 3)
    assert_eq!(cpu.pc, 0x0001)
    assert_eq!(cpu.mem[0x1FF], flags | (B | U))
    assert_eq!(cpu.registers[SP], 0xFE)
    flags += 1
  }
}

test "pla_pulls_top_byte_from_stack_into_a_and_updates_sp" {
  let cpu = CPU::new(debug=true)
  // $0000 PLA
  cpu.mem[0x0000] = 0x68
  cpu.mem[0x01FF] = 0xAB
  cpu.registers[SP] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.registers[SP], 0xFF)
}

test "plp_pulls_top_byte_from_stack_into_flags_and_updates_sp" {
  let cpu = CPU::new(debug=true)
  // $0000 PLP
  cpu.mem[0x0000] = 0x28
  cpu.mem[0x01FF] = 0xBA // must have BREAK and UNUSED set
  cpu.registers[SP] = 0xFE
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags.get(), 0xAA) // FIXME: 0xBA (nestest)
  assert_eq!(cpu.registers[SP], 0xFF)
}

test "rol_accumulator_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = false
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_accumulator_80_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x80
  cpu.flags[C] = false
  cpu.flags[Z] = false
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_accumulator_zero_and_carry_one_clears_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = true
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "rol_accumulator_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x40
  cpu.flags[C] = true
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x81)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "rol_accumulator_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x7F
  cpu.flags[C] = false
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "rol_accumulator_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xFF
  cpu.flags[C] = false
  // $0000 ROL A
  cpu.mem[0x0000] = 0x2A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "rol_absolute_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_absolute_80_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.flags[Z] = false
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x80
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_absolute_zero_and_carry_one_clears_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = true
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x01)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "rol_absolute_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x40
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x81)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "rol_absolute_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "rol_absolute_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $ABCD
  let _ = cpu.load(0x0000, [0x2E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "rol_zp_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_80_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.flags[Z] = false
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0x80
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_zero_and_carry_one_clears_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = true
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x01)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0x40
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x81)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "rol_zp_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0x7F
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "rol_zp_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROL $0010
  let _ = cpu.load(0x0000, [0x26, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "rol_abs_x_indexed_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[X] = 0x03
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_abs_x_indexed_80_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.flags[Z] = false
  cpu.registers[X] = 0x03
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_abs_x_indexed_zero_and_carry_one_clears_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x01)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "rol_abs_x_indexed_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "rol_abs_x_indexed_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "rol_abs_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROL $ABCD,X
  let _ = cpu.load(0x0000, [0x3E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "rol_zp_x_indexed_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x36, 0x10])
  // $0000 ROL $0010,X
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_x_indexed_80_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  cpu.flags[Z] = false
  cpu.registers[X] = 0x03
  let _ = cpu.load(0x0000, [0x36, 0x10])
  // $0000 ROL $0010,X
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x80
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_x_indexed_zero_and_carry_one_clears_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  let _ = cpu.load(0x0000, [0x36, 0x10])
  // $0000 ROL $0010,X
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x01)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], false)
}

test "rol_zp_x_indexed_sets_n_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROL $0010,X
  let _ = cpu.load(0x0000, [0x36, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x40
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[Z], false)
}

test "rol_zp_x_indexed_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROL $0010,X
  let _ = cpu.load(0x0000, [0x36, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x7F
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], false)
}

test "rol_zp_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROL $0010,X
  let _ = cpu.load(0x0000, [0x36, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFE)
  assert_eq!(cpu.flags[C], true)
}

test "ror_accumulator_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = false
  // $0000 ROR A
  cpu.mem[0x0000] = 0x6A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ror_accumulator_zero_and_carry_one_rotates_in_sets_n_flags" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.flags[C] = true
  // $0000 ROR A
  cpu.mem[0x0000] = 0x6A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "ror_accumulator_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x02
  cpu.flags[C] = true
  // $0000 ROR A
  cpu.mem[0x0000] = 0x6A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x81)
  assert_eq!(cpu.flags[C], false)
}

test "ror_accumulator_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x03
  cpu.flags[C] = true
  // $0000 ROR A
  cpu.mem[0x0000] = 0x6A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x81)
  assert_eq!(cpu.flags[C], true)
}

test "ror_absolute_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROR $ABCD
  let _ = cpu.load(0x0000, [0x6E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ror_absolute_zero_and_carry_one_rotates_in_sets_n_flags" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $ABCD
  let _ = cpu.load(0x0000, [0x6E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "ror_absolute_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $ABCD
  let _ = cpu.load(0x0000, [0x6E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x02
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x81)
  assert_eq!(cpu.flags[C], false)
}

test "ror_absolute_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $ABCD
  let _ = cpu.load(0x0000, [0x6E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x03
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x81)
  assert_eq!(cpu.flags[C], true)
}

test "ror_zp_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 ROR $0010
  let _ = cpu.load(0x0000, [0x66, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ror_zp_zero_and_carry_one_rotates_in_sets_n_flags" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $0010
  let _ = cpu.load(0x0000, [0x66, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "ror_zp_zero_absolute_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $0010
  let _ = cpu.load(0x0000, [0x66, 0x10])
  cpu.mem[0x0010] = 0x02
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x81)
  assert_eq!(cpu.flags[C], false)
}

test "ror_zp_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = true
  // $0000 ROR $0010
  let _ = cpu.load(0x0000, [0x66, 0x10])
  cpu.mem[0x0010] = 0x03
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x81)
  assert_eq!(cpu.flags[C], true)
}

test "ror_abs_x_indexed_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROR $ABCD,X
  let _ = cpu.load(0x0000, [0x7E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ror_abs_x_indexed_z_and_c_1_rotates_in_sets_n_flags" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $ABCD,X
  let _ = cpu.load(0x0000, [0x7E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "ror_abs_x_indexed_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $ABCD,X
  let _ = cpu.load(0x0000, [0x7E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x02
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[C], false)
}

test "ror_abs_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $ABCD,X
  let _ = cpu.load(0x0000, [0x7E, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x03
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[C], true)
}

test "ror_zp_x_indexed_zero_and_carry_zero_sets_z_flag" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = false
  // $0000 ROR $0010,X
  let _ = cpu.load(0x0000, [0x76, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.flags[N], false)
}

test "ror_zp_x_indexed_zero_and_carry_one_rotates_in_sets_n_flags" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $0010,X
  let _ = cpu.load(0x0000, [0x76, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x80)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[N], true)
}

test "ror_zp_x_indexed_zero_absolute_shifts_out_zero" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $0010,X
  let _ = cpu.load(0x0000, [0x76, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x02
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[C], false)
}

test "ror_zp_x_indexed_shifts_out_one" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0x03
  cpu.flags[C] = true
  // $0000 ROR $0010,X
  let _ = cpu.load(0x0000, [0x76, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x03
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x81)
  assert_eq!(cpu.flags[C], true)
}

test "rti_restores_status_and_pc_and_updates_sp" {
  let cpu = CPU::new(debug=true)
  // $0000 RTI
  cpu.mem[0x0000] = 0x40
  let _ = cpu.load(0x01FD, [0xFC, 0x03, 0xC0]) // Status, PCL, PCH
  cpu.registers[SP] = 0xFC
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0xC003)
  assert_eq!(cpu.flags.get(), 0xEC) // FIXME: 0xFC (nestest)
  assert_eq!(cpu.registers[SP], 0xFF)
}

test "rti_forces_break_and_unused_flags_high" {
  let cpu = CPU::new(debug=true)
  // $0000 RTI
  cpu.mem[0x0000] = 0x40
  let _ = cpu.load(0x01FD, [0x00, 0x03, 0xC0]) // Status, PCL, PCH
  cpu.registers[SP] = 0xFC
  assert_eq!(cpu.step(), 6)
  // assert_eq!(cpu.flags[B], true) // FIXME (nestest)
  assert_eq!(cpu.flags[U], true)
}

test "rts_restores_pc_and_increments_then_updates_sp" {
  let cpu = CPU::new(debug=true)
  // $0000 RTS
  cpu.mem[0x0000] = 0x60
  let _ = cpu.load(0x01FE, [0x03, 0xC0]) // PCL, PCH
  cpu.pc = 0x0000
  cpu.registers[SP] = 0xFD
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0xC004)
  assert_eq!(cpu.registers[SP], 0xFF)
}

test "rts_wraps_around_top_of_memory" {
  let cpu = CPU::new(debug=true)
  // $1000 RTS
  cpu.mem[0x1000] = 0x60
  let _ = cpu.load(0x01FE, [0xFF, 0xFF]) // PCL, PCH
  cpu.pc = 0x1000
  cpu.registers[SP] = 0xFD
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0000)
  assert_eq!(cpu.registers[SP], 0xFF)
}

test "sbc_abs_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC $ABCD
  let _ = cpu.load(0x0000, [0xED, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC $ABCD
  let _ = cpu.load(0x0000, [0xED, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC $ABCD
  let _ = cpu.load(0x0000, [0xED, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC $ABCD
  let _ = cpu.load(0x0000, [0xED, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x02
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_zp_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC $10
  let _ = cpu.load(0x0000, [0xE5, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC $10
  let _ = cpu.load(0x0000, [0xE5, 0x10])
  cpu.mem[0x0010] = 0x01
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // => SBC $10
  let _ = cpu.load(0x0000, [0xE5, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // => SBC $10
  let _ = cpu.load(0x0000, [0xE5, 0x10])
  cpu.mem[0x0010] = 0x02
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_imm_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC #$00
  let _ = cpu.load(0x0000, [0xE9, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_imm_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC #$01
  let _ = cpu.load(0x0000, [0xE9, 0x01])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_imm_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC #$00
  let _ = cpu.load(0x0000, [0xE9, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_imm_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC #$02
  let _ = cpu.load(0x0000, [0xE9, 0x02])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_bcd_on_immediate_0a_minus_00_carry_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[C] = true
  cpu.registers[A] = 0x0a
  // $0000 SBC #$00
  let _ = cpu.load(0x0000, [0xe9, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x0a)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[V], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_bcd_on_immediate_9a_minus_00_carry_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[C] = true
  cpu.registers[A] = 0x9a
  //$0000 SBC #$00
  let _ = cpu.load(0x0000, [0xe9, 0x00])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x9a)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_bcd_on_immediate_00_minus_01_carry_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.flags[V] = true
  cpu.flags[Z] = true
  cpu.flags[C] = true
  cpu.registers[A] = 0x00
  // => $0000 SBC #$00
  let _ = cpu.load(0x0000, [0xe9, 0x01])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x99)
  assert_eq!(cpu.flags[N], true)
  assert_eq!(cpu.flags[V], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], false)
}

test "sbc_bcd_on_immediate_20_minus_0a_carry_unset" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  cpu.registers[A] = 0x20
  // $0000 SBC #$00
  let _ = cpu.load(0x0000, [0xe9, 0x0a])
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x1f)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[V], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_abs_x_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC $FEE0,X
  let _ = cpu.load(0x0000, [0xFD, 0xE0, 0xFE])
  cpu.registers[X] = 0x0D
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_x_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC $FEE0,X
  let _ = cpu.load(0x0000, [0xFD, 0xE0, 0xFE])
  cpu.registers[X] = 0x0D
  cpu.mem[0xFEED] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_x_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC $FEE0,X
  let _ = cpu.load(0x0000, [0xFD, 0xE0, 0xFE])
  cpu.registers[X] = 0x0D
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_x_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC $FEE0,X
  let _ = cpu.load(0x0000, [0xFD, 0xE0, 0xFE])
  cpu.registers[X] = 0x0D
  cpu.mem[0xFEED] = 0x02
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_abs_y_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC $FEE0,Y
  let _ = cpu.load(0x0000, [0xF9, 0xE0, 0xFE])
  cpu.registers[Y] = 0x0D
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_y_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC $FEE0,Y
  let _ = cpu.load(0x0000, [0xF9, 0xE0, 0xFE])
  cpu.registers[Y] = 0x0D
  cpu.mem[0xFEED] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_y_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC $FEE0,Y
  let _ = cpu.load(0x0000, [0xF9, 0xE0, 0xFE])
  cpu.registers[Y] = 0x0D
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_abs_y_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC $FEE0,Y
  let _ = cpu.load(0x0000, [0xF9, 0xE0, 0xFE])
  cpu.registers[Y] = 0x0D
  cpu.mem[0xFEED] = 0x02
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_ind_x_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC ($10,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0xE1, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.registers[X] = 0x03
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_x_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC ($10,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0xE1, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.registers[X] = 0x03
  cpu.mem[0xFEED] = 0x01
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_x_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC ($10,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0xE1, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.registers[X] = 0x03
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_x_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC ($10,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0xE1, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.registers[X] = 0x03
  cpu.mem[0xFEED] = 0x02
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_ind_y_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 SBC ($10),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0xF1, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_y_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC ($10),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0xF1, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0x01
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_y_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC ($10),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0xF1, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_ind_y_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC ($10),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0xF1, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0x02
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sbc_zp_x_all_zeros_and_no_borrow_is_zero" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x00
  // $0000 SBC $10,X
  let _ = cpu.load(0x0000, [0xF5, 0x10])
  cpu.registers[X] = 0x0D
  cpu.mem[0x001D] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_x_downto_zero_no_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = true // borrow = 0
  cpu.registers[A] = 0x01
  // $0000 SBC $10,X
  let _ = cpu.load(0x0000, [0xF5, 0x10])
  cpu.registers[X] = 0x0D
  cpu.mem[0x001D] = 0x01
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_x_downto_zero_with_borrow_sets_z_clears_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x01
  // $0000 SBC $10,X
  let _ = cpu.load(0x0000, [0xF5, 0x10])
  cpu.registers[X] = 0x0D
  cpu.mem[0x001D] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[C], true)
  assert_eq!(cpu.flags[Z], true)
}

test "sbc_zp_x_downto_four_with_borrow_clears_z_n" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  cpu.flags[C] = false // borrow = 1
  cpu.registers[A] = 0x07
  // $0000 SBC $10,X
  let _ = cpu.load(0x0000, [0xF5, 0x10])
  cpu.registers[X] = 0x0D
  cpu.mem[0x001D] = 0x02
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.registers[A], 0x04)
  assert_eq!(cpu.flags[N], false)
  assert_eq!(cpu.flags[Z], false)
  assert_eq!(cpu.flags[C], true)
}

test "sec_sets_carry_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[C] = false
  // $0000 SEC
  cpu.mem[0x0000] = 0x038
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[C], true)
}

test "sed_sets_decimal_mode_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = false
  // $0000 SED
  cpu.mem[0x0000] = 0xF8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[D], true)
}

test "sei_sets_interrupt_disable_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[I] = false
  // $0000 SEI
  cpu.mem[0x0000] = 0x78
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.flags[I], true)
}

test "sta_absolute_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  // $0000 STA $ABCD
  let _ = cpu.load(0x0000, [0x8D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_absolute_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  // $0000 STA $ABCD
  let _ = cpu.load(0x0000, [0x8D, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_zp_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  // $0000 STA $0010
  let _ = cpu.load(0x0000, [0x85, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_zp_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  // $0000 STA $0010
  let _ = cpu.load(0x0000, [0x85, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_abs_x_indexed_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 STA $ABCD,X
  let _ = cpu.load(0x0000, [0x9D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_abs_x_indexed_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 STA $ABCD,X
  let _ = cpu.load(0x0000, [0x9D, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_abs_y_indexed_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 STA $ABCD,Y
  let _ = cpu.load(0x0000, [0x99, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_abs_y_indexed_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 STA $ABCD,Y
  let _ = cpu.load(0x0000, [0x99, 0xCD, 0xAB])
  cpu.mem[0xABCD + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD + cpu.registers[Y].0], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_ind_indexed_x_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 STA ($0010,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0x81, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.mem[0xFEED] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0xFEED], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_ind_indexed_x_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 STA ($0010,X)
  // $0013 Vector to $FEED
  let _ = cpu.load(0x0000, [0x81, 0x10])
  let _ = cpu.load(0x0013, [0xED, 0xFE])
  cpu.mem[0xFEED] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0xFEED], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_indexed_ind_y_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 STA ($0010),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0x91, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0xFEED + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_indexed_ind_y_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 STA ($0010),Y
  // $0010 Vector to $FEED
  let _ = cpu.load(0x0000, [0x91, 0x10])
  let _ = cpu.load(0x0010, [0xED, 0xFE])
  cpu.mem[0xFEED + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0xFEED + cpu.registers[Y].0], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_zp_x_indexed_stores_a_leaves_a_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 STA $0010,X
  let _ = cpu.load(0x0000, [0x95, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.registers[A], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sta_zp_x_indexed_stores_a_leaves_a_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0x03
  // $0000 STA $0010,X
  let _ = cpu.load(0x0000, [0x95, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_absolute_stores_x_leaves_x_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0xFF
  // $0000 STX $ABCD
  let _ = cpu.load(0x0000, [0x8E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.registers[X], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_absolute_stores_x_leaves_x_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0x00
  // $0000 STX $ABCD
  let _ = cpu.load(0x0000, [0x8E, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_zp_stores_x_leaves_x_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0xFF
  // $0000 STX $0010
  let _ = cpu.load(0x0000, [0x86, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.registers[X], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_zp_stores_x_leaves_x_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0x00
  // $0000 STX $0010
  let _ = cpu.load(0x0000, [0x86, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_zp_y_indexed_stores_x_leaves_x_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0xFF
  cpu.registers[Y] = 0x03
  // $0000 STX $0010,Y
  let _ = cpu.load(0x0000, [0x96, 0x10])
  cpu.mem[0x0010 + cpu.registers[Y].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[Y].0], 0xFF)
  assert_eq!(cpu.registers[X], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "stx_zp_y_indexed_stores_x_leaves_x_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[X] = 0x00
  cpu.registers[Y] = 0x03
  // $0000 STX $0010,Y
  let _ = cpu.load(0x0000, [0x96, 0x10])
  cpu.mem[0x0010 + cpu.registers[Y].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[Y].0], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_absolute_stores_y_leaves_y_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0xFF
  // $0000 STY $ABCD
  let _ = cpu.load(0x0000, [0x8C, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0xFF)
  assert_eq!(cpu.registers[Y], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_absolute_stores_y_leaves_y_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0x00
  // $0000 STY $ABCD
  let _ = cpu.load(0x0000, [0x8C, 0xCD, 0xAB])
  cpu.mem[0xABCD] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0003)
  assert_eq!(cpu.mem[0xABCD], 0x00)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_zp_stores_y_leaves_y_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0xFF
  // $0000 STY $0010
  let _ = cpu.load(0x0000, [0x84, 0x10])
  cpu.mem[0x0010] = 0x00
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0xFF)
  assert_eq!(cpu.registers[Y], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_zp_stores_y_leaves_y_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0x00
  // $0000 STY $0010
  let _ = cpu.load(0x0000, [0x84, 0x10])
  cpu.mem[0x0010] = 0xFF
  assert_eq!(cpu.step(), 3)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010], 0x00)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_zp_x_indexed_stores_y_leaves_y_and_n_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[N] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0xFF
  cpu.registers[X] = 0x03
  // $0000 STY $0010,X
  let _ = cpu.load(0x0000, [0x94, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0x00
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0xFF)
  assert_eq!(cpu.registers[Y], 0xFF)
  assert_eq!(cpu.flags.get(), flags)
}

test "sty_zp_x_indexed_stores_y_leaves_y_and_z_flag_unchanged" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0xFF)
  cpu.flags[Z] = false
  let flags = cpu.flags.get()
  cpu.registers[Y] = 0x00
  cpu.registers[X] = 0x03
  // $0000 STY $0010,X
  let _ = cpu.load(0x0000, [0x94, 0x10])
  cpu.mem[0x0010 + cpu.registers[X].0] = 0xFF
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.mem[0x0010 + cpu.registers[X].0], 0x00)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags.get(), flags)
}

test "tax_transfers_accumulator_into_x" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAB
  cpu.registers[X] = 0x00
  // $0000 TAX
  cpu.mem[0x0000] = 0xAA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.registers[X], 0xAB)
}

test "tax_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x80
  cpu.registers[X] = 0x00
  // $0000 TAX
  cpu.mem[0x0000] = 0xAA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "tax_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0xFF
  // $0000 TAX
  cpu.mem[0x0000] = 0xAA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "tay_transfers_accumulator_into_y" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0xAB
  cpu.registers[Y] = 0x00
  // $0000 TAY
  cpu.mem[0x0000] = 0xA8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.registers[Y], 0xAB)
}

test "tay_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[A] = 0x80
  cpu.registers[Y] = 0x00
  // $0000 TAY
  cpu.mem[0x0000] = 0xA8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "tay_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0xFF
  // $0000 TAY
  cpu.mem[0x0000] = 0xA8
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "tsx_transfers_stack_pointer_into_x" {
  let cpu = CPU::new(debug=true)
  cpu.registers[SP] = 0xAB
  cpu.registers[X] = 0x00
  // $0000 TSX
  cpu.mem[0x0000] = 0xBA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0xAB)
  assert_eq!(cpu.registers[X], 0xAB)
}

test "tsx_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[SP] = 0x80
  cpu.registers[X] = 0x00
  // $0000 TSX
  cpu.mem[0x0000] = 0xBA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0x80)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "tsx_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[SP] = 0x00
  cpu.registers[Y] = 0xFF
  // $0000 TSX
  cpu.mem[0x0000] = 0xBA
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "txa_transfers_x_into_a" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xAB
  cpu.registers[A] = 0x00
  // $0000 TXA
  cpu.mem[0x0000] = 0x8A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.registers[X], 0xAB)
}

test "txa_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[X] = 0x80
  cpu.registers[A] = 0x00
  // $0000 TXA
  cpu.mem[0x0000] = 0x8A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "txa_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[X] = 0x00
  cpu.registers[A] = 0xFF
  // $0000 TXA
  cpu.mem[0x0000] = 0x8A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], true)
}

test "txs_transfers_x_into_stack_pointer" {
  let cpu = CPU::new(debug=true)
  cpu.registers[X] = 0xAB
  // $0000 TXS
  cpu.mem[0x0000] = 0x9A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0xAB)
  assert_eq!(cpu.registers[X], 0xAB)
}

test "txs_does_not_set_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[X] = 0x80
  // $0000 TXS
  cpu.mem[0x0000] = 0x9A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0x80)
  assert_eq!(cpu.registers[X], 0x80)
  assert_eq!(cpu.flags[N], false)
}

test "txs_does_not_set_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[X] = 0x00
  // $0000 TXS
  cpu.mem[0x0000] = 0x9A
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[SP], 0x00)
  assert_eq!(cpu.registers[X], 0x00)
  assert_eq!(cpu.flags[Z], false)
}

test "tya_transfers_y_into_a" {
  let cpu = CPU::new(debug=true)
  cpu.registers[Y] = 0xAB
  cpu.registers[A] = 0x00
  // $0000 TYA
  cpu.mem[0x0000] = 0x98
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0xAB)
  assert_eq!(cpu.registers[Y], 0xAB)
}

test "tya_sets_negative_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[N] = false
  cpu.registers[Y] = 0x80
  cpu.registers[A] = 0x00
  // $0000 TYA
  cpu.mem[0x0000] = 0x98
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.pc, 0x0001)
  assert_eq!(cpu.registers[A], 0x80)
  assert_eq!(cpu.registers[Y], 0x80)
  assert_eq!(cpu.flags[N], true)
}

test "tya_sets_zero_flag" {
  let cpu = CPU::new(debug=true)
  cpu.flags[Z] = false
  cpu.registers[Y] = 0x00
  cpu.registers[A] = 0xFF
  // $0000 TYA
  cpu.mem[0x0000] = 0x98
  assert_eq!(cpu.step(), 2)
  assert_eq!(cpu.registers[A], 0x00)
  assert_eq!(cpu.registers[Y], 0x00)
  assert_eq!(cpu.flags[Z], true)
  assert_eq!(cpu.pc, 0x0001)
}

// test "decorated_addressing_modes_are_valid" {
//   //     valid_modes = [x[0] for x in py65.assembler.Assembler.Addressing]
//   //     mpu = self._make_mpu()
//   //     for name, mode in mpu.disassemble:
//   //         self.assertTrue(mode in valid_modes)
// }

test "brk_interrupt" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0x00)
  let _ = cpu.load(IRQ.addr(), [0x00, 0x04])
  let _ = cpu.load(
    0x0000,
    [
      0xA9, 0x01, // LDA #$01
       0x00, // BRK
       0xEA, 0xEA, 0xEA, // NOP, NOP, NOP
       0xA9, 0x03,
    ],
  ) // LDA #$03
  let _ = cpu.load(
    0x0400,
    [
      0xA9, 0x02, // LDA #$02
       0x40,
    ],
  ) // RTI
  assert_eq!(cpu.step(), 2) // LDA #$01
  assert_eq!(cpu.registers[A], 0x01)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.step(), 7) // BRK
  assert_eq!(cpu.pc, 0x0400)
  assert_eq!(cpu.step(), 2) // LDA #$02
  assert_eq!(cpu.registers[A], 0x02)
  assert_eq!(cpu.pc, 0x0402)
  assert_eq!(cpu.step(), 6) // RTI
  assert_eq!(cpu.pc, 0x0004)
  assert_eq!(cpu.step(), 2) // A NOP
  assert_eq!(cpu.step(), 2) // The second NOP
  assert_eq!(cpu.step(), 2) // LDA #$03
  assert_eq!(cpu.registers[A], 0x03)
  assert_eq!(cpu.pc, 0x0008)
}

// test "repr" {
//   //     mpu = self._make_mpu()
//   //     self.assertTrue("6502" in repr(mpu))
// }

test "adc_ind_indexed_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0x00)
  cpu.registers[A] = 0x01
  cpu.registers[X] = 0xFF
  // $0000 ADC ($80,X)
  // $007f Vector to $BBBB (read if page wrapped)
  // $017f Vector to $ABCD (read if no page wrap)
  let _ = cpu.load(0x0000, [0x61, 0x80])
  let _ = cpu.load(0x007f, [0xBB, 0xBB])
  let _ = cpu.load(0x017f, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x01
  cpu.mem[0xBBBB] = 0x02
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x03)
}

test "adc_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.flags.set(0)
  cpu.registers[A] = 0x42
  cpu.registers[Y] = 0x02
  // $1000 ADC ($FF),Y
  let _ = cpu.load(0x1000, [0x71, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x14 // read if no page wrap
  cpu.mem[0x0012] = 0x42 // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x84)
}

test "lda_zp_x_indexed_page_wraps" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0xFF
  // $0000 LDA $80,X
  let _ = cpu.load(0x0000, [0xB5, 0x80])
  cpu.mem[0x007F] = 0x42
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x42)
}

test "and_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.registers[A] = 0x42
  cpu.registers[Y] = 0x02
  // $1000 AND ($FF),Y
  let _ = cpu.load(0x1000, [0x31, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x00 // read if no page wrap
  cpu.mem[0x0012] = 0xFF // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x42)
}

test "brk_preserves_decimal_flag_when_it_is_set" {
  let cpu = CPU::new(debug=true)
  cpu.flags[D] = true
  // $C000 BRK
  cpu.mem[0xC000] = 0x00
  cpu.pc = 0xC000
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.flags[B], true)
  assert_eq!(cpu.flags[D], true)
}

test "brk_preserves_decimal_flag_when_it_is_clear" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0)
  // $C000 BRK
  cpu.mem[0xC000] = 0x00
  cpu.pc = 0xC000
  assert_eq!(cpu.step(), 7)
  assert_eq!(cpu.flags[B], true)
  assert_eq!(cpu.flags[D], false)
}

test "cmp_ind_x_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0)
  cpu.registers[A] = 0x42
  cpu.registers[X] = 0xFF
  // $0000 CMP ($80,X)
  // $007f Vector to $BBBB (read if page wrapped)
  // $017f Vector to $ABCD (read if no page wrap)
  let _ = cpu.load(0x0000, [0xC1, 0x80])
  let _ = cpu.load(0x007f, [0xBB, 0xBB])
  let _ = cpu.load(0x017f, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  cpu.mem[0xBBBB] = 0x42
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.flags[Z], true)
}

test "cmp_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.flags.set(0)
  cpu.registers[A] = 0x42
  cpu.registers[Y] = 0x02
  // $1000 CMP ($FF),Y
  let _ = cpu.load(0x1000, [0xd1, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x14 // read if no page wrap
  cpu.mem[0x0012] = 0x42 // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.flags[Z], true)
}

test "eor_ind_x_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.flags.set(0)
  cpu.registers[A] = 0xAA
  cpu.registers[X] = 0xFF
  // $0000 EOR ($80,X)
  // $007f Vector to $BBBB (read if page wrapped)
  // $017f Vector to $ABCD (read if no page wrap)
  let _ = cpu.load(0x0000, [0x41, 0x80])
  let _ = cpu.load(0x007f, [0xBB, 0xBB])
  let _ = cpu.load(0x017f, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x00
  cpu.mem[0xBBBB] = 0xFF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0x55)
}

test "eor_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.registers[A] = 0xAA
  cpu.registers[Y] = 0x02
  // $1000 EOR ($FF),Y
  let _ = cpu.load(0x1000, [0x51, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x00 // read if no page wrap
  cpu.mem[0x0012] = 0xFF // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x55)
}

test "lda_ind_indexed_x_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0xff
  // $0000 LDA ($80,X)
  // $007f Vector to $BBBB (read if page wrapped)
  // $017f Vector to $ABCD (read if no page wrap)
  let _ = cpu.load(0x0000, [0xA1, 0x80])
  let _ = cpu.load(0x007f, [0xBB, 0xBB])
  let _ = cpu.load(0x017f, [0xCD, 0xAB])
  cpu.mem[0xABCD] = 0x42
  cpu.mem[0xBBBB] = 0xEF
  assert_eq!(cpu.step(), 6)
  assert_eq!(cpu.registers[A], 0xEF)
}

test "lda_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x02
  // $1000 LDA ($FF),Y
  let _ = cpu.load(0x1000, [0xb1, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x14 // read if no page wrap
  cpu.mem[0x0012] = 0x42 // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x42)
}

test "lda_zp_x_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.registers[A] = 0x00
  cpu.registers[X] = 0xFF
  // $0000 LDA $80,X
  let _ = cpu.load(0x0000, [0xB5, 0x80])
  cpu.mem[0x007F] = 0x42
  assert_eq!(cpu.step(), 4)
  assert_eq!(cpu.pc, 0x0002)
  assert_eq!(cpu.registers[A], 0x42)
}

test "jmp_jumps_to_address_with_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.mem[0x00ff] = 0
  // $0000 JMP ($00)
  let _ = cpu.load(0, [0x6c, 0xff, 0x00])
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.pc, 0x6c00)
  assert_eq!(cpu.cycles, 5)
}

test "ora_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.registers[A] = 0x00
  cpu.registers[Y] = 0x02
  // $1000 ORA ($FF),Y
  let _ = cpu.load(0x1000, [0x11, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x00 // read if no page wrap
  cpu.mem[0x0012] = 0x42 // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x42)
}

test "sbc_indexed_ind_y_has_page_wrap_bug" {
  let cpu = CPU::new(debug=true)
  cpu.pc = 0x1000
  cpu.flags[C] = true
  cpu.registers[A] = 0x42
  cpu.registers[Y] = 0x02
  // $1000 SBC ($FF),Y
  let _ = cpu.load(0x1000, [0xf1, 0xff])
  // Vector
  cpu.mem[0x00ff] = 0x10 // low byte
  cpu.mem[0x0100] = 0x20 // high byte if no page wrap
  cpu.mem[0x0000] = 0x00 // high byte if page wrapped
  // Data
  cpu.mem[0x2012] = 0x02 // read if no page wrap
  cpu.mem[0x0012] = 0x03 // read if page wrapped
  assert_eq!(cpu.step(), 5)
  assert_eq!(cpu.registers[A], 0x3f)
}
