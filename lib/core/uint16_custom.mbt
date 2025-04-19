//
// UInt16
//

///|
pub fn UInt16::bit(self : UInt16, bit : Int) -> Bool {
  self.bitn(bit) == 1
}

///|
pub fn UInt16::bitn(self : UInt16, bit : UInt16) -> Int {
  (self.to_int() >> bit.to_int()) & 1
}

///|
pub fn UInt16::clr(self : UInt16, mask : UInt16) -> UInt16 {
  u16(self.to_int() & (-mask.to_int() - 1))
}

///|
pub fn UInt16::clrb(self : UInt16, bit : UInt16) -> UInt16 {
  self.clr(1 << bit.to_int())
}

///|
pub fn UInt16::set(self : UInt16, mask : UInt16) -> UInt16 {
  u16(self.to_int() | mask.to_int())
}

///|
pub fn UInt16::setb(self : UInt16, bit : UInt16) -> UInt16 {
  self.set(1 << bit.to_int())
}

///|
pub fn UInt16::has(self : UInt16, mask : UInt16) -> Bool {
  u16(self.to_int() & mask.to_int()) != 0
}

///|
pub fn UInt16::is_neg(self : UInt16) -> Bool {
  self.bit(15)
}

///|
pub fn UInt16::is_not_neg(self : UInt16) -> Bool {
  not(self.bit(15))
}

///|
pub fn UInt16::is_pos(self : UInt16) -> Bool {
  not(self.bit(15))
}

///|
pub fn UInt16::is_not_pos(self : UInt16) -> Bool {
  self.bit(15)
}

///|
test "UInt16::bit/normal" {
  let num = UInt16::new(0b0101010101010101)
  inspect!(num.bit(0), content="true")
  inspect!(num.bit(1), content="false")
  inspect!(num.bit(2), content="true")
  inspect!(num.bit(14), content="true")
  inspect!(num.bit(15), content="false")
}

///|
test "UInt16::bitn/basic" {
  let value = UInt16::new(0b0101) // Test basic bit pattern
  inspect!(value.bitn(0), content="1") // Rightmost bit
  inspect!(value.bitn(1), content="0") // Second bit
  inspect!(value.bitn(2), content="1") // Third bit
  inspect!(value.bitn(3), content="0") // Fourth bit
}

///|
test "UInt16::clr/basic" {
  // Test basic bit masking
  let value = UInt16::new(0xFFFF) // all bits set
  let mask = UInt16::new(0x00FF) // clear lower byte
  inspect!(value.clr(mask), content="FF00")
  let value2 = UInt16::new(0xAAAA) // alternating bits
  let mask2 = UInt16::new(0x5555) // clear alternating bits
  inspect!(value2.clr(mask2), content="AAAA")
}

///|
test "UInt16::clrb/basic" {
  let value = UInt16::new(0xFFFF) // All bits set
  // Clear bits at different positions
  inspect!(value.clrb(0), content="FFFE") // Clear least significant bit
  inspect!(value.clrb(8), content="FEFF") // Clear middle bit
  inspect!(value.clrb(15), content="7FFF") // Clear most significant bit
}

///|
test "UInt16::set/basic" {
  // Test basic bit setting operations
  let val = UInt16::new(0x0000)
  let mask = UInt16::new(0x0001)
  inspect!(val.set(mask), content="0001")
  let val2 = UInt16::new(0x0F0F)
  let mask2 = UInt16::new(0xF0F0)
  inspect!(val2.set(mask2), content="FFFF")
}

///|
test "UInt16::setb/basic" {
  // Test setting different bits in a zero value
  let value = UInt16::new(0x0000)
  inspect!(value.setb(0), content="0001") // Set least significant bit
  inspect!(value.setb(8), content="0100") // Set middle bit
  inspect!(value.setb(15), content="8000") // Set most significant bit
}

///|
test "UInt16::has/basic" {
  // Test if each bit position is correctly checked
  let value = UInt16::new(0b0101010101010101)
  inspect!(value.has(UInt16::new(0b0100000000000000)), content="true") // Check bit 14 (set)
  inspect!(value.has(UInt16::new(0b1000000000000000)), content="false") // Check bit 15 (unset)
  inspect!(value.has(UInt16::new(0b0000000000000001)), content="true") // Check bit 0 (set)
}

///|
test "UInt16::is_neg/zero_and_positive" {
  // Test zero and positive numbers (0-32767, which have MSB of 0)
  inspect!(UInt16::new(0).is_neg(), content="false")
  inspect!(UInt16::new(16384).is_neg(), content="false")
  inspect!(UInt16::new(32767).is_neg(), content="false")
}

///|
test "UInt16::is_not_neg/positive" {
  // Test positive numbers (0 to 32767)
  inspect!(UInt16::new(0).is_not_neg(), content="true")
  inspect!(UInt16::new(16383).is_not_neg(), content="true")
  inspect!(UInt16::new(32767).is_not_neg(), content="true")
}

///|
test "UInt16::is_pos/zero_and_positive" {
  // Test positive numbers (0 to 32767, which have bit 15 as 0)
  inspect!(UInt16::new(0).is_pos(), content="true")
  inspect!(UInt16::new(16383).is_pos(), content="true")
  inspect!(UInt16::new(32767).is_pos(), content="true")
}

///|
test "UInt16::is_not_pos/basic" {
  // Test numbers at and around the sign bit boundary
  inspect!(UInt16::new(0x7FFF).is_not_pos(), content="false") // 32767, largest positive
  inspect!(UInt16::new(0x8000).is_not_pos(), content="true") // 32768, smallest negative
  inspect!(UInt16::new(0xFFFF).is_not_pos(), content="true") // 65535, -1
}

///|
test "UInt16::is_not_pos/zero" {
  // Test special case: zero
  inspect!(UInt16::new(0x0000).is_not_pos(), content="false") // 0 is considered positive
}

///|
test "UInt16::is_not_pos/overflow" {
  // Test overflow behavior
  inspect!(UInt16::new(0x10000).is_not_pos(), content="false") // Wraps to 0
  inspect!(UInt16::new(-1).is_not_pos(), content="true") // Wraps to 0xFFFF
}

///|
test "UInt16::is_pos/negative" {
  // Test negative numbers (32768 to 65535, which have bit 15 as 1)
  inspect!(UInt16::new(32768).is_pos(), content="false")
  inspect!(UInt16::new(49152).is_pos(), content="false")
  inspect!(UInt16::new(65535).is_pos(), content="false")
}

///|
test "UInt16::is_pos/boundary" {
  // Test boundary values where bit 15 changes
  inspect!(UInt16::new(32767).is_pos(), content="true") // Largest positive number
  inspect!(UInt16::new(32768).is_pos(), content="false") // Smallest negative number
  inspect!(UInt16::new(65535).is_pos(), content="false") // Largest negative number
}

///|
test "UInt16::is_not_neg/negative" {
  // Test negative numbers (32768 to 65535)
  inspect!(UInt16::new(32768).is_not_neg(), content="false")
  inspect!(UInt16::new(49152).is_not_neg(), content="false")
  inspect!(UInt16::new(65535).is_not_neg(), content="false")
}

///|
test "UInt16::is_not_neg/boundary" {
  // Test boundary cases where the sign bit (bit 15) changes
  inspect!(UInt16::new(32767).is_not_neg(), content="true") // 0x7FFF - largest positive
  inspect!(UInt16::new(32768).is_not_neg(), content="false") // 0x8000 - smallest negative
  inspect!(UInt16::new(65535).is_not_neg(), content="false") // 0xFFFF - largest negative
}

///|
test "UInt16::is_neg/negative" {
  // Test negative numbers (32768-65535, which have MSB of 1)
  inspect!(UInt16::new(32768).is_neg(), content="true")
  inspect!(UInt16::new(49152).is_neg(), content="true")
  inspect!(UInt16::new(65535).is_neg(), content="true")
}

///|
test "UInt16::is_neg/boundary" {
  // Test boundary values where the sign bit changes
  inspect!(UInt16::new(32767).is_neg(), content="false") // Largest positive
  inspect!(UInt16::new(32768).is_neg(), content="true") // Smallest negative
  inspect!(UInt16::new(65535).is_neg(), content="true") // Largest negative
}

///|
test "UInt16::has/boundary" {
  // Test edge cases with all bits set/unset
  let all_set = UInt16::new(0xFFFF)
  let none_set = UInt16::new(0x0000)
  inspect!(all_set.has(UInt16::new(0xFFFF)), content="true") // All bits masked
  inspect!(none_set.has(UInt16::new(0xFFFF)), content="false") // No bits present
  inspect!(all_set.has(UInt16::new(0x0000)), content="false") // Empty mask
}

///|
test "UInt16::has/multiple_bits" {
  // Test with multiple bits in the mask
  let value = UInt16::new(0xF0F0)
  inspect!(value.has(UInt16::new(0x8080)), content="true") // Some bits match
  inspect!(value.has(UInt16::new(0x0F0F)), content="false") // No bits match
  inspect!(value.has(UInt16::new(0xFFFF)), content="true") // Some bits match in full mask
}

///|
test "UInt16::setb/existing" {
  // Test setting bits that are already set
  let value = UInt16::new(0x0F0F) // 0000111100001111
  inspect!(value.setb(0), content="0F0F") // Setting already set bit
  inspect!(value.setb(8), content="0F0F") // Setting bit in zero region
  inspect!(value.setb(15), content="8F0F") // Setting highest bit
}

///|
test "UInt16::set/boundary" {
  // Test boundary values for both value and mask
  let max_val = UInt16::new(0xFFFF)
  let zero_mask = UInt16::new(0x0000)
  inspect!(max_val.set(zero_mask), content="FFFF")
  let zero_val = UInt16::new(0x0000)
  let max_mask = UInt16::new(0xFFFF)
  inspect!(zero_val.set(max_mask), content="FFFF")
}

///|
test "UInt16::set/alternating" {
  // Test with alternating bit patterns
  let val = UInt16::new(0xAAAA) // 1010 1010 1010 1010
  let mask = UInt16::new(0x5555) // 0101 0101 0101 0101
  inspect!(val.set(mask), content="FFFF")
  let val2 = UInt16::new(0x5555) // 0101 0101 0101 0101
  let mask2 = UInt16::new(0xAAAA) // 1010 1010 1010 1010
  inspect!(val2.set(mask2), content="FFFF")
}

///|
test "UInt16::clrb/already_clear" {
  let value = UInt16::new(0x0000) // All bits clear
  // Clearing already clear bits should have no effect
  inspect!(value.clrb(0), content="0000")
  inspect!(value.clrb(8), content="0000")
  inspect!(value.clrb(15), content="0000")
}

///|
test "UInt16::clr/boundary" {
  let value = UInt16::new(0xFFFF)
  // Clear with zero mask (should not change anything)
  inspect!(value.clr(UInt16::new(0x0000)), content="FFFF")
  // Clear with all bits mask (should clear everything)
  inspect!(value.clr(UInt16::new(0xFFFF)), content="0000")
}

///|
test "UInt16::bitn/boundary" {
  let max_value = UInt16::new(0xFFFF) // All bits set
  inspect!(max_value.bitn(0), content="1") // Lowest bit
  inspect!(max_value.bitn(15), content="1") // Highest bit
  inspect!(max_value.bitn(8), content="1") // Middle bit
}

///|
test "UInt16::bit/boundary" {
  // Test highest and lowest bits
  let max = UInt16::new(0xFFFF) // all bits set
  let min = UInt16::new(0x0000) // no bits set
  inspect!(max.bit(15), content="true") // highest bit
  inspect!(max.bit(0), content="true") // lowest bit
  inspect!(min.bit(15), content="false") // highest bit
  inspect!(min.bit(0), content="false") // lowest bit
}
