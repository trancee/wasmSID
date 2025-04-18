///|
type! Exception {
  InvalidAddressV2
  InvalidAddressV3
  InvalidAddressV3Even
  InvalidAddressV4Even
  InvalidVersionOffset(String)
  UnknownChannel
  UnknownColor(Int)
  UnknownCPUClock
  UnknownFile
  UnknownFrameRate
  UnknownHeader(String)
  UnknownMode
  UnknownModel(String)
  UnknownRegister(String, Int)
  UnknownScanLineCycles
  UnknownScanLines
  UnknownVersion
  UnknownVersionPSID
  UnknownVideoStandard
  UnsupportedNoSIDs(String, Int)
}

///|
pub fn to_string(self : Exception) -> String {
  match self {
    InvalidAddressV2 => "address must not be set for PSID v2NG"
    InvalidAddressV3 => "address must not be set for PSID v3"
    InvalidAddressV3Even => "address must be set and an even number for PSID v3"
    InvalidAddressV4Even => "address must be set and an even number for PSID v4"
    InvalidVersionOffset(value) => "invalid data offset for version #\{value}"
    UnknownChannel => "unknown channel"
    UnknownColor(value) => "unknown color #\{value}"
    UnknownCPUClock => "unknown CPU clock"
    UnknownFile => "no PSID or RSID file"
    UnknownFrameRate => "unknown frame rate"
    UnknownHeader(header) => "unknown SID header: \{header}"
    UnknownMode => "unknown mode"
    UnknownModel(scope) => "unknown \{scope} model"
    UnknownRegister(scope, value) =>
      "unknown \{scope} register #$\{u16(value).to_hex()}"
    UnknownScanLineCycles => "unknown scan line cycles"
    UnknownScanLines => "unknown scan lines"
    UnknownVersion => "unknown version"
    UnknownVersionPSID => "unknown PSID or RSID version"
    UnknownVideoStandard => "unknown video standard"
    UnsupportedNoSIDs(scope, value) =>
      "unsupported number of \{scope}s: #\{value}"
  }
}

///|
pub impl Show for Exception with output(self, logger) {
  logger.write_string(self.to_string())
}
