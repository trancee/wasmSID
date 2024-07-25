//values: 8580 / 6581
enum Model {
  Unknown
  MOS6581
  MOS8580
  Both
} derive(Show, Eq)

fn Model::from_int(value : Int) -> Model!String {
  match value {
    0b00 => Unknown
    0b01 => MOS6581
    0b10 => MOS8580
    0b11 => Both
    _ => {
      raise "unknown SID model"
    }
  }
}

fn to_int(self : Model) -> Int!String {
  self[self]!
}

fn op_get(self : Model, value : Model) -> Int!String {
  match value {
    MOS6581 => 6581
    MOS8580 => 8580
    _ => {
      raise "unknown SID model"
    }
  }
}

//1:left, 2:right, 3:both(middle)
enum Channel {
  Unknown
  Left
  Right
  Both
} derive(Show, Eq)

fn Channel::from_int(value : Int) -> Channel!String {
  match value {
    0 => Unknown
    1 => Left
    2 => Right
    3 => Both
    _ => {
      raise "unknown channel"
    }
  }
}

fn to_int(self : Channel) -> Int!String {
  self[self]!
}

fn op_get(self : Channel, value : Channel) -> Int!String {
  match value {
    Left => 1
    Right => 2
    Both => 3
    _ => {
      raise "unknown channel"
    }
  }
}
