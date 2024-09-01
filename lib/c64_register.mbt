/// 1             $1             R6510
/// 6510 On-Chip I/O Port Register
///
/// Bit 0: LORAM signal.  Selects ROM or RAM at 40960 ($A000).  1=BASIC, 0=RAM
/// Bit 1: HIRAM signal.  Selects ROM or RAM at 57344 ($E000).  1=Kernal, 0=RAM
/// Bit 2: CHAREN signal.  Selects character ROM or I/O devices.  1=I/O, 0=ROM
/// Bit 3: Cassette Data Output line.
/// Bit 4: Cassette Switch Sense.  Reads 0 if a button is pressed, 1 if not.
/// Bit 5: Cassette Motor Switch Control.  A 1 turns the motor on, 0 turns it off.
/// Bits 6-7: Not connected--no function presently defined.
struct IOPort {
  /// Bit 0.  This bit controls the LORAM signal.  A 0 in this bit position
  /// switches the BASIC ROM out, and replaces it with RAM at addresses
  /// 40960-49151 ($A000-$BFFF).  The default value of this bit is 1.
  mut loram : Bool

  /// Bit 1.  Bit 1 controls the HIRAM signal.  A 0 in this bit position
  /// switches the Kernal ROM out, and replaces it with RAM at 57344-65535
  /// ($E000-$FFFF).  As the BASIC interpreter uses the Kernal, it is also
  /// switched out and replaced by RAM.  The default value of this bit is 1.
  mut hiram : Bool

  /// Bit 2.  This bit controls the CHAREN signal.  A 0 in this position
  /// switches the character generator ROM in, so that it can be read by the
  /// 6510 at addresses 53248-57343 ($D000-$DFFF).  Normally, this bit is
  /// set to 1, so that while the VIC-II chip has access to the character
  /// generator ROM for purposes of creating the screen display, the user
  /// cannot PEEK into it.  Since this ROM is switched into the system in
  /// the same location as the I/O devices (SID chip, VIC-II chip, and 6526
  /// CIA's), o I/O can occur when this ROM is switched in.
  mut charen : Bool

  /// Bits 3-5 of this register have functions connected with the Datasette
  /// recorder.  These are as follows:
  ///
  /// Bit 3.  This is the Cassette Data Output line.  This line is connected
  /// to the Cassette Data Write line on the cassette port, and is used to
  /// send the data which is written to tape.
  mut cassette_data_output : Bool

  /// Bit 4.  This bit is the Cassette Switch Sense line.  This bit enables
  /// a program to tell whether or not one of the buttons that moves the
  /// recorder is pressed down.  If the switch on the recorder is down, this
  /// bit will have a value of 1.  Remember that Bit 4 of the data direction
  /// register at location 0 must contain a 0 for this bit to properly
  /// reflect the status of the switch.
  mut cassette_switch_sense : Bool

  /// Bit 5.  Bit 5 is the Cassette Motor Control.  Setting this bit to zero
  /// allows the motor to turn when you press one of the buttons on the
  /// recorder, while setting it to one disables it from turning.
  mut cassette_motor_switch_control : Bool
} derive(Show, Default)

fn IOPort::from_int(value : UInt8) -> IOPort {
  {
    /// Bit 0: LORAM signal.  Selects ROM or RAM at 40960 ($A000).  1=BASIC, 0=RAM
    loram: value.bit(0),
    /// Bit 1: HIRAM signal.  Selects ROM or RAM at 57344 ($E000).  1=Kernal, 0=RAM
    hiram: value.bit(1),
    /// Bit 2: CHAREN signal.  Selects character ROM or I/O devices.  1=I/O, 0=ROM
    charen: value.bit(2),

    /// Bit 3: Cassette Data Output line.
    cassette_data_output: value.bit(3),
    /// Bit 4: Cassette Switch Sense.  Reads 0 if a button is pressed, 1 if not.
    cassette_switch_sense: value.bit(4),
    /// Bit 5: Cassette Motor Switch Control.  A 1 turns the motor on, 0 turns it off.
    cassette_motor_switch_control: value.bit(5),

    /// Bits 6-7: Not connected--no function presently defined.
  }
}
