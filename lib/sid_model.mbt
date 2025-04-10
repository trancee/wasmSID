//values: 8580 / 6581
///|
enum Model {
  Unknown
  MOS6581
  MOS8580
  Both
} derive(Show, Eq)

///|
fn Model::from_int(value : Int) -> Model! {
  match value {
    0b00 => Unknown
    0b01 => MOS6581
    0b10 => MOS8580
    0b11 => Both
    _ => raise UnknownModel("SID")
  }
}

///|
fn Model::to_int(self : Model) -> Int! {
  match self {
    MOS6581 => 6581
    MOS8580 => 8580
    _ => raise UnknownModel("SID")
  }
}

///|
fn Model::op_get(self : Model, value : Model) -> Int! {
  value.to_int!()
}

//1:left, 2:right, 3:both(middle)
///|
enum Channel {
  Unknown
  Left
  Right
  Both
} derive(Show, Eq)

///|
fn Channel::from_int(value : Int) -> Channel! {
  match value {
    0 => Unknown
    1 => Left
    2 => Right
    3 => Both
    _ => raise UnknownChannel
  }
}

///|
fn Channel::to_int(self : Channel) -> Int! {
  match self {
    Left => 1
    Right => 2
    Both => 3
    _ => raise UnknownChannel
  }
}

///|
fn Channel::op_get(self : Channel, value : Channel) -> Int! {
  value.to_int!()
}
