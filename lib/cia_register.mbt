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
}

fn register(register : Register) -> Int {
  register[register]
}

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
  }
}
