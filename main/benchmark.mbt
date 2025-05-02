///|
let testcases : Array[Test] = [
  Test::new(
    "BRK",
    initial=State::new(pc=0x1000, ram=[
      (0x1000, 0x00), // BRK
      (@cpu.IRQ + 1, 0xBA),
      (@cpu.IRQ + 0, 0xBE),
    ]),
    final=State::new(pc=0xBABE, s=0xFC, p=0x34, ram=[
      (0x01FD, 0x30),
      (0x01FE, 0x02),
      (0x01FF, 0x10),
    ]),
  ),
]

///|
fn benchmark() -> Unit! {
  for i, testcase in testcases {
    println("\{testcase.name}\u{1B}[1A")
    let cpu = benchmark_setup!(testcase, debug=false)
    let mut cycles = 0
    let summary = @bench.single_bench(name=testcase.name, fn() {
      cpu.reset()
      cycles = cpu.step()
    }).to_json()
    match testcase.final {
      None => ignore(testcase.final)
      Some(final) => {
        verify!("PC", testcase, final.pc, cpu.pc)
        verify!("S", testcase, final.s, Some(cpu.registers[SP]))
        match final.a {
          None => ignore(final.a)
          Some(a) => verify!("A", testcase, a, cpu.registers[A])
        }
        match final.x {
          None => ignore(final.x)
          Some(x) => verify!("X", testcase, x, cpu.registers[X])
        }
        match final.y {
          None => ignore(final.y)
          Some(y) => verify!("Y", testcase, y, cpu.registers[Y])
        }
        match final.p {
          None => ignore(final.p)
          Some(p) => verify!("P", testcase, p, cpu.flags.get())
        }

        //
        match final.ram {
          None => ignore(final.ram)
          Some(ram) =>
            for data in ram {
              let (address, value) = data
              verify!("\{address}", testcase, value, cpu.mem[address._])
            }
        }
      }
    }
    benchmark_summary(summary)
  }
}

///|
fn benchmark_summary(summary : Json) -> Unit {
  let fixed = fn(a : Double) -> String {
    let a = a.to_string()
    match a.find(".") {
      None => a
      Some(i) =>
        a.substring(start=0, end=i).pad_start(1, ' ') +
        a.substring(start=i, end=i + 5).pad_end(5, '0') +
        "µs"
    }
  }
  let obj = summary.as_object().unwrap()
  let name = obj["name"].unwrap().as_string().unwrap()
  let runs = obj["runs"].unwrap().as_number().unwrap()
  let batches = obj["batch_size"].unwrap().as_number().unwrap()
  let mean = obj["mean"].unwrap().as_number().unwrap()
  let std_dev = obj["std_dev"].unwrap().as_number().unwrap()
  let median = obj["median"].unwrap().as_number().unwrap()
  let median_abs_dev = obj["median_abs_dev"].unwrap().as_number().unwrap()
  println("\{name} \{runs} × \{batches}")
  println("\{fixed(mean)} ±\{fixed(std_dev)}")
  println("\{fixed(median)} ±\{fixed(median_abs_dev)}")
}

///|
fn benchmark_setup(
  testcase : Test,
  decimal_mode~ : Bool = true,
  debug~ : Bool = false
) -> @cpu.CPU! {
  let mut pc : UInt16 = 0x0000
  let registers = @cpu.Registers::new()
  let mut flags = @cpu.Flags::new()
  match testcase.initial {
    None => ignore(testcase.initial)
    Some(initial) => {
      pc = initial.pc
      match initial.s {
        None => ignore(initial.s)
        Some(s) => registers[SP] = s
      }
      match initial.a {
        None => ignore(initial.a)
        Some(a) => registers[A] = a
      }
      match initial.x {
        None => ignore(initial.x)
        Some(x) => registers[X] = x
      }
      match initial.y {
        None => ignore(initial.y)
        Some(y) => registers[Y] = y
      }
      match initial.p {
        None => ignore(initial.p)
        Some(p) => flags = @cpu.Flags::new(flags=p)
      }
    }
  }
  let cpu = CPU::new!(
    pc~,

    //
    registers~,
    flags~,

    //
    decimal_mode~,

    //
    debug~,
  )
  match testcase.initial {
    None => ignore(testcase.initial)
    Some(initial) =>
      for data in initial.ram.or_default() {
        let (address, value) = data
        cpu.mem[address._] = value
      }
  }
  cpu
}
