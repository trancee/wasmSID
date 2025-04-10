///|
pub enum Color {
  Black
  White
  Red
  Cyan
  Purple
  Green
  Blue
  Yellow
  Orange
  Brown
  LightRed
  DarkGray
  MediumGray
  LightGreen
  LightBlue
  LightGray
}

///|
fn Color::to_int(self : Color) -> Int {
  match self {
    Black => 0
    White => 1
    Red => 2
    Cyan => 3
    Purple => 4
    Green => 5
    Blue => 6
    Yellow => 7
    Orange => 8
    Brown => 9
    LightRed => 10
    DarkGray => 11
    MediumGray => 12
    LightGreen => 13
    LightBlue => 14
    LightGray => 15
  }
}

///|
fn Color::from_int(value : Int) -> Color! {
  match value & 0x0F {
    0 => Black
    1 => White
    2 => Red
    3 => Cyan
    4 => Purple
    5 => Green
    6 => Blue
    7 => Yellow
    8 => Orange
    9 => Brown
    10 => LightRed
    11 => DarkGray
    12 => MediumGray
    13 => LightGreen
    14 => LightBlue
    15 => LightGray
    _ => raise UnknownColor(value)
  }
}
