///|
fn to_hex(v : UInt) -> Char {
  let v = v.reinterpret_as_int()
  if v < 10 {
    Int::unsafe_to_char(v + b'0'.to_int())
  } else {
    Int::unsafe_to_char(v - 10 + b'A'.to_int())
  }
}

///|
test "to_hex/digits" {
  inspect(to_hex(0), content="0")
  inspect(to_hex(1), content="1")
  inspect(to_hex(5), content="5")
  inspect(to_hex(9), content="9")
}

///|
test "to_hex/letters" {
  inspect(to_hex(10), content="A")
  inspect(to_hex(11), content="B")
  inspect(to_hex(13), content="D")
  inspect(to_hex(15), content="F")
}

///|
test "to_hex/boundary" {
  inspect(to_hex(9), content="9")
  inspect(to_hex(10), content="A")
}
