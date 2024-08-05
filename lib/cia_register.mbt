/// 6526 FUNCTIONAL DESCRIPTION
///
/// REGISTER MAP
///
/// PRA      | PERIPHERAL DATA REG A
/// PRB      | PERIPHERAL DATA REG B
/// DDRA     | DATA DIRECTION REG A
/// DDRB     | DATA DIRECTION REG B
/// TA LO    | TIMER A LOW REGISTER
/// TA HI    | TIMER A HIGH REGISTER
/// TB LO    | TIMER B LOW REGISTER
/// TB HI    | TIMER B HIGH REGISTER
/// TOD 10TH | 10THS OF SECONDS REGISTER
/// TOD SEC  | SECONDS REGISTER
/// TOD MIN  | MINUTES REGISTER
/// TOD HR   | HOURS - AM/PM REGISTER
/// SDR      | SERIAL DATA REGISTER
/// ICR      | INTERRUPT CONTROL REGISTER
/// CRA      | CONTROL REG A
/// CRB      | CONTROL REG B

enum Register {
  PRA
  PRB
  DDRA
  DDRB
  TA_LO
  TA_HI
  TB_LO
  TB_HI
  TOD_10TH
  TOD_SEC
  TOD_MIN
  TOD_HR
  SDR
  ICR
  CRA
  CRB

  // Read
  RD_PRA
  RD_PRB
  RD_DDRA
  RD_DDRB
  RD_TA_LO
  RD_TA_HI
  RD_TB_LO
  RD_TB_HI
  RD_TOD_10TH
  RD_TOD_SEC
  RD_TOD_MIN
  RD_TOD_HR
  RD_SDR
  RD_ICR
  RD_CRA
  RD_CRB

  // Write
  WR_PRA
  WR_PRB
  WR_DDRA
  WR_DDRB
  WR_TA_LO
  WR_TA_HI
  WR_TB_LO
  WR_TB_HI
  WR_TOD_10TH
  WR_TOD_SEC
  WR_TOD_MIN
  WR_TOD_HR
  WR_SDR
  WR_ICR
  WR_CRA
  WR_CRB
} derive(Show, Eq)

fn op_get(self : Register, register : Register) -> Int {
  match register {
    PRA => 0x00
    PRB => 0x01
    DDRA => 0x02
    DDRB => 0x03
    TA_LO => 0x04
    TA_HI => 0x05
    TB_LO => 0x06
    TB_HI => 0x07
    TOD_10TH => 0x08
    TOD_SEC => 0x09
    TOD_MIN => 0x0A
    TOD_HR => 0x0B
    SDR => 0x0C
    ICR => 0x0D
    CRA => 0x0E
    CRB => 0x0F

    // Read
    RD_PRA => 0x00
    RD_PRB => 0x01
    RD_DDRA => 0x02
    RD_DDRB => 0x03
    RD_TA_LO => 0x04
    RD_TA_HI => 0x05
    RD_TB_LO => 0x06
    RD_TB_HI => 0x07
    RD_TOD_10TH => 0x08
    RD_TOD_SEC => 0x09
    RD_TOD_MIN => 0x0A
    RD_TOD_HR => 0x0B
    RD_SDR => 0x0C
    RD_ICR => 0x0D
    RD_CRA => 0x0E
    RD_CRB => 0x0F

    // Write
    WR_PRA => 0x10
    WR_PRB => 0x11
    WR_DDRA => 0x12
    WR_DDRB => 0x13
    WR_TA_LO => 0x14
    WR_TA_HI => 0x15
    WR_TB_LO => 0x16
    WR_TB_HI => 0x17
    WR_TOD_10TH => 0x18
    WR_TOD_SEC => 0x19
    WR_TOD_MIN => 0x1A
    WR_TOD_HR => 0x1B
    WR_SDR => 0x1C
    WR_ICR => 0x1D
    WR_CRA => 0x1E
    WR_CRB => 0x1F
  }
}
