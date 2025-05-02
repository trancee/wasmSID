//
// UInt8
//

///|
pub fn UInt8::bit(self : UInt8, bit : Int) -> Bool {
  self.bitn(bit) == 1
}

///|
pub fn UInt8::bitn(self : UInt8, bit : Int) -> Int {
  (self.to_int() >> bit) & 1
}

///|
pub fn UInt8::clr(self : UInt8, mask : UInt8) -> UInt8 {
  u8(self.to_int() & (-mask.to_int() - 1))
}

///|
pub fn UInt8::clrb(self : UInt8, bit : Int) -> UInt8 {
  self.clr(1 << bit |> u8)
}

///|
pub fn UInt8::set(self : UInt8, mask : UInt8) -> UInt8 {
  u8(self.to_int() | mask.to_int())
}

///|
pub fn UInt8::setb(self : UInt8, bit : Int) -> UInt8 {
  self.set(1 << bit |> u8)
}

///|
pub fn UInt8::has(self : UInt8, mask : UInt8) -> Bool {
  u8(self.to_int() & mask.to_int()) != 0
}

///|
pub fn UInt8::is_neg(self : UInt8) -> Bool {
  self.bit(7)
}

///|
pub fn UInt8::is_not_neg(self : UInt8) -> Bool {
  not(self.bit(7))
}

///|
pub fn UInt8::is_pos(self : UInt8) -> Bool {
  not(self.bit(7))
}

///|
pub fn UInt8::is_not_pos(self : UInt8) -> Bool {
  self.bit(7)
}

///|
test "UInt8::bit/normal" {
  let num = UInt8::new(0b01010101)
  inspect!(num.bit(0), content="true")
  inspect!(num.bit(1), content="false")
  inspect!(num.bit(2), content="true")
  inspect!(num.bit(7), content="false")
}

///|
test "UInt8::bitn/basic" {
  let value = UInt8::new(5) // binary: 0000 0101
  inspect!(value.bitn(0), content="1") // rightmost bit is 1
  inspect!(value.bitn(1), content="0") // second bit from right is 0
  inspect!(value.bitn(2), content="1") // third bit from right is 1
  inspect!(value.bitn(3), content="0") // fourth bit from right is 0
}

///|
test "UInt8::clr/basic" {
  let value = UInt8::new(0xFF) // 11111111
  let mask = UInt8::new(0x0F) // 00001111
  inspect!(value.clr(mask), content="F0") // Should clear lower 4 bits
  let value2 = UInt8::new(0xAA) // 10101010
  let mask2 = UInt8::new(0x55) // 01010101
  inspect!(value2.clr(mask2), content="AA") // Should clear alternating bits
}

///|
test "UInt8::clrb/normal" {
  // Test clearing different bits in a byte with all bits set
  let value = UInt8::new(0xFF) // 11111111
  inspect!(value.clrb(0), content="FE") // Clear bit 0: 11111110
  inspect!(value.clrb(4), content="EF") // Clear bit 4: 11101111
  inspect!(value.clrb(7), content="7F") // Clear bit 7: 01111111
}

///|
test "UInt8::set/basic" {
  let initial = UInt8::new(0x00) // 00000000
  let mask = UInt8::new(0x01) // 00000001
  inspect!(initial.set(mask), content="01")
  let initial2 = UInt8::new(0x0F) // 00001111
  let mask2 = UInt8::new(0xF0) // 11110000
  inspect!(initial2.set(mask2), content="FF")
}

///|
test "UInt8::setb/basic" {
  // Test setting different bits in a zero byte
  let zero = UInt8::new(0x00)
  inspect!(zero.setb(0), content="01") // Set bit 0
  inspect!(zero.setb(3), content="08") // Set bit 3
  inspect!(zero.setb(7), content="80") // Set bit 7 (highest bit)
}

///|
test "UInt8::has/basic" {
  // Test basic bit patterns
  let value = UInt8::new(0b10101010)
  inspect!(value.has(UInt8::new(0b10000000)), content="true") // Check highest bit
  inspect!(value.has(UInt8::new(0b00000010)), content="true") // Check a set bit
  inspect!(value.has(UInt8::new(0b00000001)), content="false") // Check an unset bit
}

///|
test "UInt8::is_neg/zero_and_positive" {
  // Test zero and positive numbers (0-127, which have MSB of 0)
  inspect!(UInt8::new(0).is_neg(), content="false")
  inspect!(UInt8::new(64).is_neg(), content="false")
  inspect!(UInt8::new(127).is_neg(), content="false")
}

///|
test "UInt8::is_not_neg/positive" {
  // Test positive numbers (0-127)
  inspect!(UInt8::new(0).is_not_neg(), content="true")
  inspect!(UInt8::new(64).is_not_neg(), content="true")
  inspect!(UInt8::new(127).is_not_neg(), content="true")
}

///|
test "UInt8::is_pos/positive_numbers" {
  // Test positive numbers (0-127)
  inspect!(UInt8::new(0).is_pos(), content="true")
  inspect!(UInt8::new(64).is_pos(), content="true")
  inspect!(UInt8::new(127).is_pos(), content="true")
}

///|
test "UInt8::is_not_pos/basic" {
  // Test positive numbers (0-127)
  inspect!(UInt8::new(0).is_not_pos(), content="false")
  inspect!(UInt8::new(64).is_not_pos(), content="false")
  inspect!(UInt8::new(127).is_not_pos(), content="false")
}

///|
test "UInt8::is_not_pos/boundary" {
  // Test boundary values where sign bit changes
  inspect!(UInt8::new(127).is_not_pos(), content="false") // 01111111
  inspect!(UInt8::new(128).is_not_pos(), content="true") // 10000000
  inspect!(UInt8::new(255).is_not_pos(), content="true") // 11111111
}

///|
test "UInt8::is_not_pos/overflow" {
  // Test overflow behavior
  inspect!(UInt8::new(256).is_not_pos(), content="false") // wraps to 0
  inspect!(UInt8::new(-1).is_not_pos(), content="true") // wraps to 255
  inspect!(UInt8::new(-128).is_not_pos(), content="true") // wraps to 128
}

///|
test "UInt8::is_pos/negative_numbers" {
  // Test negative numbers (128-255)
  inspect!(UInt8::new(128).is_pos(), content="false")
  inspect!(UInt8::new(192).is_pos(), content="false")
  inspect!(UInt8::new(255).is_pos(), content="false")
}

///|
test "UInt8::is_pos/boundary" {
  // Test boundary values where the sign bit changes
  inspect!(UInt8::new(127).is_pos(), content="true") // Largest positive number
  inspect!(UInt8::new(128).is_pos(), content="false") // Smallest negative number
}

///|
test "UInt8::is_not_neg/negative" {
  // Test negative numbers (128-255)
  inspect!(UInt8::new(128).is_not_neg(), content="false")
  inspect!(UInt8::new(192).is_not_neg(), content="false")
  inspect!(UInt8::new(255).is_not_neg(), content="false")
}

///|
test "UInt8::is_not_neg/boundary" {
  // Test boundary cases
  inspect!(UInt8::new(127).is_not_neg(), content="true") // Largest positive
  inspect!(UInt8::new(128).is_not_neg(), content="false") // Smallest negative
}

///|
test "UInt8::is_neg/negative" {
  // Test negative numbers (128-255, which have MSB of 1)
  inspect!(UInt8::new(128).is_neg(), content="true")
  inspect!(UInt8::new(192).is_neg(), content="true")
  inspect!(UInt8::new(255).is_neg(), content="true")
}

///|
test "UInt8::is_neg/boundary" {
  // Test boundary values where the sign bit changes
  inspect!(UInt8::new(127).is_neg(), content="false") // Largest positive
  inspect!(UInt8::new(128).is_neg(), content="true") // Smallest negative
  inspect!(UInt8::new(255).is_neg(), content="true") // Largest negative
}

///|
test "UInt8::has/boundary" {
  // Test boundary values
  let zero = UInt8::new(0)
  let all_ones = UInt8::new(0xFF)
  inspect!(zero.has(zero), content="false") // Zero with zero mask
  inspect!(all_ones.has(all_ones), content="true") // All bits set with all bits mask
  inspect!(zero.has(all_ones), content="false") // Zero with all bits mask
}

///|
test "UInt8::has/multiple_bits" {
  // Test multiple bits in mask
  let value = UInt8::new(0b00001111)
  inspect!(value.has(UInt8::new(0b00001001)), content="true") // Multiple bits, all present
  inspect!(value.has(UInt8::new(0b11110000)), content="false") // Multiple bits, none present
  inspect!(value.has(UInt8::new(0b10001111)), content="true") // Multiple bits, some present
}

///|
test "UInt8::setb/existing" {
  // Test setting bits in a byte that already has bits set
  let value = UInt8::new(0x0F) // 00001111
  inspect!(value.setb(4), content="1F") // Set bit 4
  inspect!(value.setb(7), content="8F") // Set bit 7
  inspect!(value.setb(0), content="0F") // Set bit that's already set
}

///|
test "UInt8::set/boundary" {
  let initial = UInt8::new(0xFF) // 11111111
  let mask = UInt8::new(0xFF) // 11111111
  inspect!(initial.set(mask), content="FF")
  let initial2 = UInt8::new(0x00) // 00000000
  let mask2 = UInt8::new(0x00) // 00000000
  inspect!(initial2.set(mask2), content="00")
}

///|
test "UInt8::set/alternating" {
  let initial = UInt8::new(0xAA) // 10101010
  let mask = UInt8::new(0x55) // 01010101
  inspect!(initial.set(mask), content="FF")
  let initial2 = UInt8::new(0x55) // 01010101
  let mask2 = UInt8::new(0xAA) // 10101010
  inspect!(initial2.set(mask2), content="FF")
}

///|
test "UInt8::clrb/boundary" {
  // Test clearing bits when they're already cleared
  let value = UInt8::new(0x00) // 00000000
  inspect!(value.clrb(0), content="00") // Clear bit 0: still 00000000
  inspect!(value.clrb(7), content="00") // Clear bit 7: still 00000000
}

///|
test "UInt8::clr/edge_cases" {
  let value = UInt8::new(0xFF)
  // Clear with mask 0 (should not change anything)
  inspect!(value.clr(UInt8::new(0x00)), content="FF")
  // Clear with mask FF (should clear everything)
  inspect!(value.clr(UInt8::new(0xFF)), content="00")
}

///|
test "UInt8::clr/overflow" {
  let value = UInt8::new(0x42)
  // Using mask larger than 8 bits
  let big_mask = UInt8::new(0xFF + 1) // Should wrap to 0x00
  inspect!(value.clr(big_mask), content="42")

  // Using negative mask
  let neg_mask = UInt8::new(-1) // Should wrap to 0xFF
  inspect!(value.clr(neg_mask), content="00")
}

///|
test "UInt8::bitn/boundary" {
  let value = UInt8::new(0xFF) // all bits set
  inspect!(value.bitn(7), content="1") // leftmost bit (highest)
  inspect!(value.bitn(0), content="1") // rightmost bit (lowest)
}

///|
test "UInt8::bit/boundary" {
  // Test all bits set
  let all_ones = UInt8::new(0xFF)
  inspect!(all_ones.bit(0), content="true")
  inspect!(all_ones.bit(7), content="true")

  // Test no bits set
  let all_zeros = UInt8::new(0x00)
  inspect!(all_zeros.bit(0), content="false")
  inspect!(all_zeros.bit(7), content="false")
}
