//values: 8580 / 6581
enum SIDModel {
  Unknown
  MOS6581
  MOS8580
  Both
} derive(Debug, Eq)

fn SIDModel::from_int(value : Int) -> SIDModel {
  match value {
    0b00 => Unknown
    0b01 => MOS6581
    0b10 => MOS8580
    0b11 => Both
    _ => {
      println("unknown SID model")
      abort("unknown SID model")
    }
  }
}

fn to_int(self : SIDModel) -> Int {
  self[self]
}

fn op_get(self : SIDModel, value : SIDModel) -> Int {
  match value {
    MOS6581 => 6581
    MOS8580 => 8580
    _ => {
      println("unknown SID model")
      abort("unknown SID model")
    }
  }
}

//1:left, 2:right, 3:both(middle)
enum Channel {
  Unknown
  Left
  Right
  Both
} derive(Debug, Eq)

fn Channel::from_int(value : Int) -> Channel {
  match value {
    0 => Unknown
    1 => Left
    2 => Right
    3 => Both
    _ => {
      println("unknown channel")
      abort("unknown channel")
    }
  }
}

fn to_int(self : Channel) -> Int {
  self[self]
}

fn op_get(self : Channel, value : Channel) -> Int {
  match value {
    Left => 1
    Right => 2
    Both => 3
    _ => {
      println("unknown channel")
      abort("unknown channel")
    }
  }
}
