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

pub fn IOPort::from_int(value : UInt8) -> IOPort {
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

pub enum C64register {
  /// 6510 On-Chip I/O Data Direction Register
  D6510
  /// 6510 On-Chip I/O Port Register
  R6510

  /// Unused. Free for user programs.
  UNUSED

  /// Vector: Routine to Convert a Number from Floating Point to Signed Integer
  /// ($B1AA).
  ADRAY1
  /// Vector: Routine to Convert a Number from Integer to Floating Point
  /// ($B391).
  ADRAY2

  /// Search Character for Scanning BASIC Text Input
  CHARAC
  /// Search Character for Statement Termination or Quote
  ENDCHR
  /// Temporary Integer during OR/AND. (CHARAC+ENDCHR)
  INTEGR
  /// Column position of the Cursor before the Last TAB or SPC
  TRMPOS
  /// Flag: LOAD or VERIFY
  VERCK
  /// Index into the Text Input Buffer/Number of Array Subscripts
  COUNT
  /// Flags for the Routines That Locate or Build an Array
  DIMFLG
  /// Flag: Type of Data (String or Numeric)
  VALTYP
  /// Flat: Type of Numeric Data (Integer or Floating Point)
  INTFLG
  /// Flag for LIST, Garbage Collection, and Program Tokenization
  GARBFL
  /// Flag: Subscript Reference to an Array or User-Defined Function Call (FN)
  SUBFLG
  /// Flag: Is Data Input to GET, READ or INPUT?
  INPFLG
  /// Flag: Sign of the Result of the TAN or SIN Function
  TANSGN
  /// Current I/O Channel (CMD Logical File) Number
  CHANNL
  /// Integer Line Number Value
  LINNUM
  /// Pointer to the Next Available Space in the Temporary String Stack
  TEMPPT
  /// Pointer to the Address of the Last String in the Temporary String Stack
  LASTPT
  /// Descriptor Stack for Temporary Strings
  TEMPST
  /// Miscellaneous Temporary Pointers and Save Area
  INDEX
  /// Floating Point Multiplication Work Area
  RESHO
  /// Pointer to the Start of BASIC Program Text
  TXTTAB
  /// Pointer to the Start of the BASIC Variable Storage Area
  VARTAB
  /// Pointer to the Start of the BASIC Array Storage Area
  ARYTAB
  /// Pointer to End of the BASIC Array Storage Area (+1), and the Start of Free RAM
  STREND
  /// Pointer to the Bottom of the String Text Storage Area
  FRETOP
  /// Temporary Pointer for Strings
  FRESPC
  /// Pointer to the Highest Address Used by BASIC
  MEMSIZ
  /// Current BASIC Line Number
  CURLIN
  /// Previous BASIC Line Number
  OLDLIN
  /// Pointer to the Address of the Current BASIC Statement
  OLDTXT
  /// Current DATA Line Number
  DATLIN
  /// Pointer to the Address of the Current DATA Item
  DATPTR
  /// Pointer in the Source of GET, READ, or INPUT Information
  INPPTR
  /// Current BASIC Variable Name
  VARNAM
  /// Pointer to the Current BASIC Variable Value
  VARPNT
  /// Temporary Pointer to the Index Variable Used by FOR
  FORPNT

  /// Math Operator Table Displacement
  OPPTR // VARTXT
  /// Mask for Comparison Operation
  OPMASK

  /// Pointer to the Current FN Descriptor
  DEFPNT
  /// Temporary Pointer to the Current String Descriptor
  DSCPNT
  /// Constant for Garbage Collection
  FOUR6
  /// Jump to Function Instruction
  JMPER

  /// BASIC Numeric Work Area
  // TEMPF1
  // TEMPF2

  /// Floating Point Accumulator #1
  FAC1
  /// Floating Point Accumulator #1: Exponent
  FACEXP
  /// Floating Point Accumulator #1: Mantissa
  FACHO
  /// Floating Point Accumulator #1: Sign
  FACSGN
  /// Number of Terms in a Series Evaluation
  SGNFLG
  /// Floating Point Accumulator #1: Overflow Digit
  BITS

  /// Floating Point Accumulator #2
  AFAC
  /// Floating Point Accumulator #2: Exponent
  ARGEXP
  /// Floating Point Accumulator #2: Mantissa
  ARGHO
  /// Floating Point Accumulator #2: Sign
  ARGSGN
  /// Result of a Signed Comparison of Accumulator #1 to Accumulator #2
  ARISGN
  /// Low Order Mantissa Byte of Floating Point Accumulator #1 (For Rounding)
  FACOV

  /// Series Evaluation Pointer

  FBUFPT

  ///
  /// Subroutine: Get Next BASIC Text Character
  ///

  CHRGET
  CHRGOT
  TXTPTR

  /// RND Function Seed Value
  RNDX

  ///
  /// Kernal Work Storage Area
  ///

  /// Kernal I/O Status Word (ST)
  STATUS
  /// Flag: Was STOP Key Pressed?
  STKEY
  /// Timing Constant for Tape Reads
  SVXT
  /// Flag for Load Routine: 0=LOAD, 1=VERIFY
  VERCKK
  /// Flag: Serial Bus--Output Character Was Buffered
  C3PO
  /// Buffered Character for Serial Bus
  BSOUR
  /// Cassette Block Synchronization Number
  SYNO
  /// Temporary .X Register Save Area
  XSAV
  /// Number of Open I/O Files/Index to the End of File Tables
  LDTND
  /// Default Input Device (Set to 0 for Keyboard)
  DFLTN
  /// Default Output (CMD) Device (Set to 3 for the Screen)
  DFLTO
  /// Tape Character Parity
  PRTY
  /// Flag: Tape Byte Received
  DPSW
  /// Flag: Kernal Message Control
  MSGFLG
  FNMIDX // FIXME

  /// Tape Pass 1 Error Log Index
  PTR1
  /// Tape Pass 2 Error Log Correction Index
  PTR2

  /// Software Jiffy Clock
  TIME

  ///
  /// Temporary Data Storage Area
  ///

  TSFCNT // FIXME
  TBTCNT // FIXME

  /// Cassette Synchronization Character Countdown
  CNTDN
  /// Count of Characters in Tape I/O Buffer
  BUFPNT
  /// RS-232 Input Bits/Cassette Temporary Storage Area
  INBIT
  /// RS-232 Input Bit Count/Cassete Temporary Storage
  BITC1
  /// RS-232 Flag: Check for Start Bit
  RINONE
  /// RS-232 Input Byte Buffer/Cassette Temporary Storage
  RIDATA
  /// RS-232 Input Parity/Cassete Leader Counter
  RIPRTY

  /// Pointer to the Starting Address of a Load/Screen Scrolling
  SAL
  /// Pointer to Ending Address of Load (End of Program)
  EAL

  /// Tape Timing
  CMPO
  /// Pointer: Start of Tape Buffer
  TAPE1
  /// RS-232 Output Bit Count/Cassette Temporary Storage
  BITTS
  /// RS-232 Next Bit to Send/Tape EOT Flag
  NXTBIT
  /// RS-232 Output Byte Buffer
  RODATA
  /// Length of Current Filename
  FNLEN

  /// Current Logical File Number
  LA
  /// Current Secondary Address
  SA
  /// Current Device Number
  FA
  /// Pointer: Current Filename
  FNADR
  /// RS-232 Output Parity/Cassette Temporary Storage
  ROPRTY
  /// Cassette Read/Write Block Count
  FSBLK
  /// Tape Input Byte Buffer
  MYCH
  /// Tape Motor Interlock
  CAS1
  /// I/O Start Address
  STAL
  ///

  MEMUSS // FIXME

  /// Matrix Coordinate of Last Key Pressed, 64=None Pressed
  LSTX
  /// Number of Characters in Keyboard Buffer (Queue)
  NDX
  /// Flag: Print Reverse Characters? 0=No
  RVS
  /// Pointer: End of Logical Line for Input
  INDX
  /// Cursor X,Y Position at Start of Input
  LXSP
  /// Matrix Coordinate of Current Key Pressed
  SFDX
  /// Cursor Blink Enable: 0=Flash Cursor
  BLNSW
  /// Timer: Countdown to Blink Cursor
  BLNCT
  /// Character Under Cursor
  GDBLN
  /// Flag: Was Last Curson Blink on or off?
  BLNON
  /// Flag: Input from Keyboard or Screen
  CRSW
  /// Pointer to the Address of the Current Screen Line
  PNT
  /// Cursor Column on Current Line
  PNTR
  /// Flag: Editor in Quote Mode? 0=No
  QTSW
  /// Maximum Length of Physical Screen Line
  LNMX
  /// Current Cursor Physical Line Number
  TBLX
  /// Temporary Storage Area for ASCII Value of Last Character Printed
  SCHAR
  /// Flag: Insert Mode (Any Number Greater Than 0 Is the Number of Inserts)
  INSRT
  /// Screen Line Link Table/Editor Temporary Storage
  LDTB1
  /// Pointer to the Address of the Current Screen Color RAM Location
  USER
  /// Vector: Keyboard Decode Table
  KEYTAB
  /// Pointer: RS-232 Input Buffer
  RIBUF
  /// Pointer: RS-232 Output Buffer
  ROBUF
  /// Four Free Bytes of Zero Page for User Programs
  FREKZP
  /// BASIC Temporary Data for Floating Point to ASCII Conversion
  BASZPT

  ///
  /// $100-$1FF
  /// Microprocessor Stack Area
  ///

  ///
  /// $100-$10A
  /// Work Area for Floating Point to String Conversions
  ///

  ASCWRK // FIXME

  /// Tape Input Error Log
  BAD
  STACK
  BSTACK

  ///
  /// $200-$258      BUF
  /// BASIC Line Editor Input Buffer
  ///
  BUF

  ///
  /// ($259-$276)
  /// Tables for File Numbers, Device Numbers, and Secondary Addresses
  ///

  /// Kernal Table of Active Logical File Numbers
  LAT
  /// Kernal Table of Device Numbers for Each Logical File
  FAT
  /// Kernal Table of Secondary Addresses for Each Logical File
  SAT

  /// Keyboard Buffer (Queue)
  KEYD

  /// Pointer: O.S. Start of Memory
  MEMSTR
  /// Pointer: O.S. End of Memory
  MEMEND

  /// Flag: Kernal Variable for IEEE Time-Out
  TIMOUT
  /// Current Foreground Color for Text
  COLOR
  /// Color of Character under Cursor
  GDCOL
  /// Top Page of Screen Memory
  HIBASE
  /// Maximum Keyboard Buffer Size
  XMAX
  /// Flag: Which Keys Will Repeat?
  RPTFLG
  /// Counter for Timing the Delay Between Key Repeats
  KOUNT
  /// Counter for Timing the Delay Until the First Key Repeat Begins
  DELAY
  /// Flag: SHIFT/CTRL/Logo Keypress
  SHFLAG
  /// Last Pattern of SHIFT/CTRL/Logo Keypress
  LSTSHF
  /// Vector to Keyboard Table Setup Routine
  KEYLOG
  /// Flag: Enable or Disable Changing Character Sets with SHIFT/Logo Keypress
  MODE
  /// Flag: Screen Scrolling Enabled
  AUTODN

  /// RS-232: Mock 6551 Control Register
  M51CTR
  /// RS-232: Mock 6551 Command Register
  M51CDR
  /// RS-232: Nonstandard Bit Timing
  M51AJB
  /// RS-232: Mock 6551 Status Register
  RSSTAT
  /// RS-232: Number of Bits Left to be Sent/Received
  BITNUM
  /// Time Required to Send a Bit
  BAUDOF
  /// RS-232: Index to End of Receive Buffer
  RIDBE
  /// RS-232: Index to Start of Receive Buffer
  RIDBS
  /// RS-232: Index to Start of Transmit Buffer
  RODBS
  /// RS-232: Index to End of Transmit Buffer
  RODBE

  /// Save Area for IRQ Vector During Cassette I/O
  IRQTMP
  /// RS-232 Interrupts Enabled
  ENABL
  /// Indicator of CIA #1 Control Register B Activity During Cassette I/O
  TODSNS
  /// Save Area for CIA #1 Interrupt Control Register During Cassette Read
  TRDTMP
  /// Save Area for CIA #1 Control Register A During Cassette Read
  TD1IRQ
  /// Temporary Index to the Next 40-Column Line for Screen Scrolling
  TLNIDX
  /// PAL/NTSC Flag
  TVSFLG

  /// $2A7-$2FF
  /// Unused
  // TEMP

  ///
  /// ($300-$30B)
  /// BASIC Indirect Vector Table
  ///

  SPR11 // FIXME

  /// Vector to the Print BASIC Error Message Routine
  IERROR
  IMAIN
  ICRNCH
  IQPLOP
  IGONE
  IEVAL
  SAREG
  SXREG
  SYREG
  SPREG
  USRPOK
  USRADD
  // TEMP
  CINV
  CNBINV
  NMINV
  IOPEN
  ICLOSE
  ICHKIN
  ICKOUT
  ICLRCH
  IBASIN
  IBSOUT
  ISTOP
  IGETIN
  ICLALL
  USRCMD
  ILOAD
  ISAVE
  // TEMP
  TBUFFR
  SPR13
  SPR14
  SPR15
  // TEMP
  VICSCN
  // TEMP
  SPNTRS

  /// Autostart ROM Cartridge
  CARTROM
  ///
  BASICROM
  ///
  KERNALROM

  /// Cold Start Vector
  COLD
  /// Warm Start Vector
  WARM

  /// Print READY
  READY

  /// (via 806 ($326) to 61898, $F1CA) output a character
  CHROUT
  /// (via 810 ($32A) to 61758, $F13E) get a character
  GETIN

  ///
  NMI
  RESET
  /// Maskable Interrupt Request and Break Hardware Vectors
  IRQ
} derive(Show, Eq)

fn c64(register : C64register) -> Int {
  match register {
    /// Page 0

    D6510 => 0x0000
    R6510 => 0x0001
    UNUSED => 0x0002
    ADRAY1 => 0x0003 // WORD
    ADRAY2 => 0x0005 // WORD
    CHARAC => 0x0007
    // INTEGR => 0x0007
    ENDCHR => 0x0008
    TRMPOS => 0x0009
    VERCK => 0x000A
    COUNT => 0x000B
    DIMFLG => 0x000C
    VALTYP => 0x000D
    INTFLG => 0x000E
    GARBFL => 0x000F
    SUBFLG => 0x0010
    INPFLG => 0x0011
    TANSGN => 0x0012
    CHANNL => 0x0013
    LINNUM => 0x0014 // WORD
    TEMPPT => 0x0016
    LASTPT => 0x0017 // WORD
    TEMPST => 0x0019 // ARRAY [3*3]
    INDEX => 0x0022 // ARRAY [4]
    RESHO => 0x0026 // ARRAY [5]
    TXTTAB => 0x002B // WORD
    VARTAB => 0x002D // WORD
    ARYTAB => 0x002F // WORD
    STREND => 0x0031 // WORD
    FRETOP => 0x0033 // WORD
    FRESPC => 0x0035 // WORD
    MEMSIZ => 0x0037 // WORD
    CURLIN => 0x0039 // WORD
    OLDLIN => 0x003B // WORD
    OLDTXT => 0x003D // WORD
    DATLIN => 0x003F // WORD
    DATPTR => 0x0041 // WORD
    INPPTR => 0x0043 // WORD
    VARNAM => 0x0045 // WORD
    VARPNT => 0x0047 // WORD
    FORPNT => 0x0049 // WORD
    OPPTR => 0x004B // WORD
    OPMASK => 0x004D
    DEFPNT => 0x004E // WORD
    DSCPNT => 0x0050 // PTR + LEN
    FOUR6 => 0x0053
    JMPER => 0x0054 // OP + PTR
    // TEMPF1 => 0x0057
    // TEMPF2 => 0x005C
    FAC1 => 0x0061 // FP
    FACEXP => 0x0061 // Exponent
    FACHO => 0x0062 // Mantissa
    FACSGN => 0x0066 // Sign
    SGNFLG => 0x0067
    BITS => 0x0068
    AFAC => 0x0069 // FP
    ARGEXP => 0x0069 // Exponent
    ARGHO => 0x006A // Mantissa
    ARGSGN => 0x006E // Sign
    ARISGN => 0x006F
    FACOV => 0x0070
    FBUFPT => 0x0071 // WORD
    CHRGET => 0x0073 // FN
    CHRGOT => 0x0079 // FN
    TXTPTR => 0x007A // FN
    RNDX => 0x008B // ARRAY[5]
    STATUS => 0x0090
    STKEY => 0x0091
    SVXT => 0x0092
    VERCKK => 0x0093
    C3PO => 0x0094
    BSOUR => 0x0095
    SYNO => 0x0096
    XSAV => 0x0097
    LDTND => 0x0098
    DFLTN => 0x0099
    DFLTO => 0x009A
    PRTY => 0x009B
    DPSW => 0x009C
    MSGFLG => 0x009D
    FNMIDX => 0x009E
    PTR1 => 0x009E
    PTR2 => 0x009F
    TIME => 0x00A0 // ARRAY[3]
    TSFCNT => 0x00A3
    TBTCNT => 0x00A4
    CNTDN => 0x00A5
    BUFPNT => 0x00A6
    INBIT => 0x00A7
    BITC1 => 0x00A8
    RINONE => 0x00A9
    RIDATA => 0x00AA
    RIPRTY => 0x00AB
    SAL => 0x00AC // WORD
    EAL => 0x00AE // WORD
    CMPO => 0x00B0 // WORD
    TAPE1 => 0x00B2 // WORD
    BITTS => 0x00B4
    NXTBIT => 0x00B5
    RODATA => 0x00B6
    FNLEN => 0x00B7
    LA => 0x00B8
    SA => 0x00B9
    FA => 0x00BA
    FNADR => 0x00BB // WORD
    ROPRTY => 0x00BD
    FSBLK => 0x00BE
    MYCH => 0x00BF
    CAS1 => 0x00C0
    STAL => 0x00C1 // WORD
    MEMUSS => 0x00C3 // WORD
    LSTX => 0x00C5
    NDX => 0x00C6
    RVS => 0x00C7
    INDX => 0x00C8
    LXSP => 0x00C9 // WORD
    SFDX => 0x00CB
    BLNSW => 0x00CC
    BLNCT => 0x00CD
    GDBLN => 0x00CE
    BLNON => 0x00CF
    CRSW => 0x00D0
    PNT => 0x00D1 // WORD
    PNTR => 0x00D3
    QTSW => 0x00D4
    LNMX => 0x00D5
    TBLX => 0x00D6
    SCHAR => 0x00D7
    INSRT => 0x00D8
    LDTB1 => 0x00D9 // ARRAY[25]
    USER => 0x00F3 // WORD
    KEYTAB => 0x00F5 // WORD
    RIBUF => 0x00F7 // WORD
    ROBUF => 0x00F9 // WORD
    FREKZP => 0x00FB // ARRAY[4]
    BASZPT => 0x00FF
    ASCWRK => 0x00FF // FIXME

    /// Page 1

    // _ => 0x100 // ARRAY[10]
    BAD => 0x0100 // ARRAY[62]
    STACK => 0x0100 // ARRAY[256]
    BSTACK => 0x013F // ARRAY[192]

    /// Page 2

    BUF => 0x0200 // ARRAY[88]
    LAT => 0x0259 // ARRAY[9]
    FAT => 0x0263 // ARRAY[9]
    SAT => 0x026D // ARRAY[9]
    KEYD => 0x0277 // ARRAY[9]
    MEMSTR => 0x0281 // WORD
    MEMEND => 0x0283 // WORD
    TIMOUT => 0x0285
    COLOR => 0x0286
    GDCOL => 0x0287
    HIBASE => 0x0288
    XMAX => 0x0289
    RPTFLG => 0x028A
    KOUNT => 0x028B
    DELAY => 0x028C
    SHFLAG => 0x028D
    LSTSHF => 0x028E
    KEYLOG => 0x028F // WORD
    MODE => 0x0291
    AUTODN => 0x0292
    M51CTR => 0x0293
    M51CDR => 0x0294
    M51AJB => 0x0295 // WORD
    RSSTAT => 0x0297
    BITNUM => 0x0298
    BAUDOF => 0x0299 // WORD
    RIDBE => 0x029B
    RIDBS => 0x029C
    RODBS => 0x029D
    RODBE => 0x029E
    IRQTMP => 0x029F // WORD
    ENABL => 0x02A1
    TODSNS => 0x02A2
    TRDTMP => 0x02A3
    TD1IRQ => 0x02A4
    TLNIDX => 0x02A5
    TVSFLG => 0x02A6
    // UNUSED => 0x02A7 // ARRAY[88]
    // SPR11 => 0x02C0 // FIXME

    /// Page 3

    IERROR => 0x0300 // WORD
    IMAIN => 0x0302 // WORD
    ICRNCH => 0x0304 // WORD
    IQPLOP => 0x0306 // WORD
    IGONE => 0x0308 // WORD
    IEVAL => 0x030A // WORD
    SAREG => 0x030C
    SXREG => 0x030D
    SYREG => 0x030E
    SPREG => 0x030F
    USRPOK => 0x0310
    USRADD => 0x0311 // WORD
    // UNUSED => 0x0313
    CINV => 0x0314 // WORD
    CNBINV => 0x0316 // WORD
    NMINV => 0x0318 // WORD
    IOPEN => 0x031A // WORD
    ICLOSE => 0x031C // WORD
    ICHKIN => 0x031E // WORD
    ICKOUT => 0x0320 // WORD
    ICLRCH => 0x0322 // WORD
    IBASIN => 0x0324 // WORD
    IBSOUT => 0x0326 // WORD
    ISTOP => 0x0328 // WORD
    IGETIN => 0x032A // WORD
    ICLALL => 0x032C // WORD
    USRCMD => 0x032E // WORD
    ILOAD => 0x0330 // WORD
    ISAVE => 0x0332 // WORD
    // UNUSED => 0x0334 // ARRAY[7]
    TBUFFR => 0x033C // ARRAY[192]
    // SPR13 => 0x0340 // FIXME
    // SPR14 => 0x0380 // FIXME
    // SPR15 => 0x03C0 // FIXME
    // UNUSED => 0x03FC // ARRAY[4]

    /// Page 4

    VICSCN => 0x0400 // ARRAY[1024]
    // UNUSED => 0x07E8
    // SPNTRS => 0x07F8 // FIXME

    ///
    COLD => 0xA000 // WORD
    WARM => 0xA002 // WORD

    ///
    READY => 0xA474 // ARRAY[12]

    ///
    CHROUT => 0xFFD2 // JMP
    GETIN => 0xFFE4 // JMP

    ///
    NMI => 0xFFFA // WORD
    RESET => 0xFFFC // WORD
    IRQ => 0xFFFE // WORD

    ///
    CARTROM => 0x8000
    BASICROM => 0xA000
    KERNALROM => 0xE000
  }
}

fn C64register::from_int(value : Int) -> C64register! {
  match value {
    /// Page 0

    0x0000 => D6510
    0x0001 => R6510
    0x0002 => UNUSED
    0x0003 => ADRAY1 // WORD
    0x0004 => ADRAY1 // WORD
    0x0005 => ADRAY2 // WORD
    0x0006 => ADRAY2 // WORD
    0x0007 => CHARAC
    // 0x0007 => INTEGR
    0x0008 => ENDCHR
    0x0009 => TRMPOS
    0x000A => VERCK
    0x000B => COUNT
    0x000C => DIMFLG
    0x000D => VALTYP
    0x000E => INTFLG
    0x000F => GARBFL
    0x0010 => SUBFLG
    0x0011 => INPFLG
    0x0012 => TANSGN
    0x0013 => CHANNL
    0x0014 => LINNUM // WORD
    0x0015 => LINNUM // WORD
    0x0016 => TEMPPT
    0x0017 => LASTPT // WORD
    0x0018 => LASTPT // WORD
    0x0019 => TEMPST // ARRAY [3*3]
    0x0022 => INDEX // ARRAY [4]
    0x0023 => INDEX // ARRAY [4]
    0x0024 => INDEX // ARRAY [4]
    0x0025 => INDEX // ARRAY [4]
    0x0026 => RESHO // ARRAY [5]
    0x0027 => RESHO // ARRAY [5]
    0x0028 => RESHO // ARRAY [5]
    0x0029 => RESHO // ARRAY [5]
    0x002A => RESHO // ARRAY [5]
    0x002B => TXTTAB // WORD
    0x002C => TXTTAB // WORD
    0x002D => VARTAB // WORD
    0x002E => VARTAB // WORD
    0x002F => ARYTAB // WORD
    0x0030 => ARYTAB // WORD
    0x0031 => STREND // WORD
    0x0032 => STREND // WORD
    0x0033 => FRETOP // WORD
    0x0034 => FRETOP // WORD
    0x0035 => FRESPC // WORD
    0x0036 => FRESPC // WORD
    0x0037 => MEMSIZ // WORD
    0x0038 => MEMSIZ // WORD
    0x0039 => CURLIN // WORD
    0x003A => CURLIN // WORD
    0x003B => OLDLIN // WORD
    0x003D => OLDTXT // WORD
    0x003E => OLDTXT // WORD
    0x003F => DATLIN // WORD
    0x0040 => DATLIN // WORD
    0x0041 => DATPTR // WORD
    0x0043 => INPPTR // WORD
    0x0044 => INPPTR // WORD
    0x0045 => VARNAM // WORD
    0x0046 => VARNAM // WORD
    0x0047 => VARPNT // WORD
    0x0048 => VARPNT // WORD
    0x0049 => FORPNT // WORD
    0x004A => FORPNT // WORD
    0x004B => OPPTR // WORD
    0x004C => OPPTR // WORD
    0x004D => OPMASK
    0x004E => DEFPNT // WORD
    0x004F => DEFPNT // WORD
    0x0050 => DSCPNT // PTR + LEN
    0x0051 => DSCPNT // PTR + LEN
    0x0052 => DSCPNT // PTR + LEN
    0x0053 => FOUR6
    0x0054 => JMPER // OP + PTR
    0x0055 => JMPER // OP + PTR
    0x0056 => JMPER // OP + PTR
    // 0x0057 => TEMPF1
    // 0x005C => TEMPF2
    0x0061 => FAC1 // FP
    0x0061 => FACEXP // Exponent
    0x0062 => FACHO // Mantissa
    0x0066 => FACSGN // Sign
    0x0067 => SGNFLG
    0x0068 => BITS
    0x0069 => AFAC // FP
    0x0069 => ARGEXP // Exponent
    0x006A => ARGHO // Mantissa
    0x006E => ARGSGN // Sign
    0x006F => ARISGN
    0x0070 => FACOV
    0x0071 => FBUFPT // WORD
    0x0073 => CHRGET // FN
    0x0079 => CHRGOT // FN
    0x007A => TXTPTR // FN
    0x008B => RNDX // ARRAY[5]
    0x0090 => STATUS
    0x0091 => STKEY
    0x0092 => SVXT
    0x0093 => VERCKK
    0x0094 => C3PO
    0x0095 => BSOUR
    0x0096 => SYNO
    0x0097 => XSAV
    0x0098 => LDTND
    0x0099 => DFLTN
    0x009A => DFLTO
    0x009B => PRTY
    0x009C => DPSW
    0x009D => MSGFLG
    0x009E => FNMIDX
    0x009E => PTR1
    0x009F => PTR2
    0x00A0 => TIME // ARRAY[3]
    0x00A1 => TIME // ARRAY[3]
    0x00A2 => TIME // ARRAY[3]
    0x00A3 => TSFCNT
    0x00A4 => TBTCNT
    0x00A5 => CNTDN
    0x00A6 => BUFPNT
    0x00A7 => INBIT
    0x00A8 => BITC1
    0x00A9 => RINONE
    0x00AA => RIDATA
    0x00AB => RIPRTY
    0x00AC => SAL // WORD
    0x00AD => SAL // WORD
    0x00AE => EAL // WORD
    0x00AF => EAL // WORD
    0x00B0 => CMPO // WORD
    0x00B1 => CMPO // WORD
    0x00B2 => TAPE1 // WORD
    0x00B3 => TAPE1 // WORD
    0x00B4 => BITTS
    0x00B5 => NXTBIT
    0x00B6 => RODATA
    0x00B7 => FNLEN
    0x00B8 => LA
    0x00B9 => SA
    0x00BA => FA
    0x00BB => FNADR // WORD
    0x00BC => FNADR // WORD
    0x00BD => ROPRTY
    0x00BE => FSBLK
    0x00BF => MYCH
    0x00C0 => CAS1
    0x00C1 => STAL // WORD
    0x00C2 => STAL // WORD
    0x00C3 => MEMUSS // WORD
    0x00C4 => MEMUSS // WORD
    0x00C5 => LSTX
    0x00C6 => NDX
    0x00C7 => RVS
    0x00C8 => INDX
    0x00C9 => LXSP // WORD
    0x00CA => LXSP // WORD
    0x00CB => SFDX
    0x00CC => BLNSW
    0x00CD => BLNCT
    0x00CE => GDBLN
    0x00CF => BLNON
    0x00D0 => CRSW
    0x00D1 => PNT // WORD
    0x00D2 => PNT // WORD
    0x00D3 => PNTR
    0x00D4 => QTSW
    0x00D5 => LNMX
    0x00D6 => TBLX
    0x00D7 => SCHAR
    0x00D8 => INSRT
    0x00D9 => LDTB1 // ARRAY[25]
    0x00F3 => USER // WORD
    0x00F4 => USER // WORD
    0x00F5 => KEYTAB // WORD
    0x00F6 => KEYTAB // WORD
    0x00F7 => RIBUF // WORD
    0x00F8 => RIBUF // WORD
    0x00F9 => ROBUF // WORD
    0x00FA => ROBUF // WORD
    0x00FB => FREKZP // ARRAY[4]
    0x00FC => FREKZP // ARRAY[4]
    0x00FD => FREKZP // ARRAY[4]
    0x00FE => FREKZP // ARRAY[4]
    0x00FF => BASZPT
    // 0x00FF => ASCWRK // FIXME

    /// Page 1

    // 0x0100 => STACK // ARRAY[256]
    0x013F => BSTACK // ARRAY[192]

    /// Page 2

    0x0200 => BUF // ARRAY[88]
    0x0259 => LAT // ARRAY[9]
    0x0263 => FAT // ARRAY[9]
    0x026D => SAT // ARRAY[9]
    0x0277 => KEYD // ARRAY[9]
    0x0281 => MEMSTR // WORD
    0x0283 => MEMEND // WORD
    0x0285 => TIMOUT
    0x0286 => COLOR
    0x0287 => GDCOL
    0x0288 => HIBASE
    0x0289 => XMAX
    0x028A => RPTFLG
    0x028B => KOUNT
    0x028C => DELAY
    0x028D => SHFLAG
    0x028E => LSTSHF
    0x028F => KEYLOG // WORD
    0x0291 => MODE
    0x0292 => AUTODN
    0x0293 => M51CTR
    0x0294 => M51CDR
    0x0295 => M51AJB // WORD
    0x0297 => RSSTAT
    0x0298 => BITNUM
    0x0299 => BAUDOF // WORD
    0x029B => RIDBE
    0x029C => RIDBS
    0x029D => RODBS
    0x029E => RODBE
    0x029F => IRQTMP // WORD
    0x02A1 => ENABL
    0x02A2 => TODSNS
    0x02A3 => TRDTMP
    0x02A4 => TD1IRQ
    0x02A5 => TLNIDX
    0x02A6 => TVSFLG
    // 0x02A7 => UNUSED // ARRAY[88]
    // 0x02C0 => SPR11 // FIXME

    /// Page 3

    0x0300 => IERROR // WORD
    0x0302 => IMAIN // WORD
    0x0304 => ICRNCH // WORD
    0x0306 => IQPLOP // WORD
    0x0308 => IGONE // WORD
    0x030A => IEVAL // WORD
    0x030C => SAREG
    0x030D => SXREG
    0x030E => SYREG
    0x030F => SPREG
    0x0310 => USRPOK
    0x0311 => USRADD // WORD
    // 0x0313 => UNUSED
    0x0314 => CINV // WORD
    0x0316 => CNBINV // WORD
    0x0318 => NMINV // WORD
    0x031A => IOPEN // WORD
    0x031C => ICLOSE // WORD
    0x031E => ICHKIN // WORD
    0x0320 => ICKOUT // WORD
    0x0322 => ICLRCH // WORD
    0x0324 => IBASIN // WORD
    0x0326 => IBSOUT // WORD
    0x0328 => ISTOP // WORD
    0x032A => IGETIN // WORD
    0x032C => ICLALL // WORD
    0x032E => USRCMD // WORD
    0x0330 => ILOAD // WORD
    0x0332 => ISAVE // WORD
    // 0x0334 => UNUSED // ARRAY[7]
    0x033C => TBUFFR // ARRAY[192]
    // 0x0340 => SPR13 // FIXME
    // 0x0380 => SPR14 // FIXME
    // 0x03C0 => SPR15 // FIXME
    // 0x03FC => UNUSED // ARRAY[4]

    /// Page 4

    0x0400 => VICSCN // ARRAY[1024]
    // 0x07E8 => UNUSED
    // 0x07F8 => SPNTRS // FIXME

    ///
    0xA000 => COLD // WORD
    0xA001 => COLD // WORD
    0xA002 => WARM // WORD
    0xA003 => WARM // WORD

    ///
    0xA474 => READY // ARRAY[12]

    ///
    0xFFD2 => CHROUT // JMP
    0xFFE4 => GETIN // JMP

    ///
    0xFFFA => NMI // WORD
    0xFFFB => NMI // WORD
    0xFFFC => RESET // WORD
    0xFFFD => RESET // WORD
    0xFFFE => IRQ // WORD
    0xFFFF => IRQ // WORD

    ///
    0x8000 => CARTROM
    0xA000 => BASICROM
    0xE000 => KERNALROM

    ///
    _ => {
      if value >= 0x0100 && value < 0x0200 {
        return STACK
      }
      if value >= 0x8000 && value < 0xA000 {
        return CARTROM
      }
      if value >= 0xA000 && value < 0xC000 {
        return BASICROM
      }
      if value >= 0xE000 && value < 0x10000 {
        return KERNALROM
      }
      raise UnknownRegister("C64", value)
    }
  }
}
