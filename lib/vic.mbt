struct VIC {
  // chipModel: Unit
  baseaddress : UInt16
  // mut rd : Array[UInt8]
  // mut wr : Array[UInt8]
}

pub fn VIC::new(~baseaddress : UInt16) -> VIC {
  let vic : VIC = { baseaddress, }
  vic
}
