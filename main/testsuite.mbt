let irq : FixedArray[Int] = [
  0x48, 0x8A, 0x48, 0x98, 0x48, 0xBA, 0xBD, 0x04, 0x01, 0x29, 0x10, 0xF0, 0x03, 0x6C,
  0x16, 0x03, 0x6C, 0x14, 0x03,
]

let testcases : Map[String, FixedArray[Int]] = {
  // LOAD
  "LDAB": @testsuite.ldab,
  "LDAZ": @testsuite.ldaz,
  "LDAZX": @testsuite.ldazx,
  "LDAA": @testsuite.ldaa,
  "LDAAX": @testsuite.ldaax,
  "LDAAY": @testsuite.ldaay,
  "LDAIX": @testsuite.ldaix,
  "LDAIY": @testsuite.ldaiy,

  // STORE
  "STAZ": @testsuite.staz,
  "STAZX": @testsuite.stazx,
  "STAA": @testsuite.staa,
  "STAAX": @testsuite.staax,
  "STAAY": @testsuite.staay,
  "STAIX": @testsuite.staix,
  "STAIY": @testsuite.staiy,
}

pub fn testsuite() -> Unit {
  let c64 = @lib.C64::new()
  c64.load(irq, offset=0xFF48)

  //
  let data = @testsuite._start
  let addr = load(c64, data)

  //
  let mut i = 0
  while c64.pc() != 0x0000 && i >= 0 {
    let _ = c64.emulate()
    i += 1
  }
}

fn load(c64 : @lib.C64, data : FixedArray[Int]) -> Int {
  let mut output = ""
  let addr = data[0] + (data[1] << 8)

  //
  c64.load(data, has_load_address=true)

  //
  c64[0x0002] = 0x00
  c64[0xA002] = 0x00
  c64[0xA003] = 0x80 // Docs say put zero here, but this works better.

  //
  c64[0x01FE] = 0xFF
  c64[0x01FF] = 0x7F

  // Put RTSes in some of the stubbed calls
  c64[0xFFD2] = 0x60
  c64[0x8000] = 0x60
  c64[0xA474] = 0x60

  // NOP the loading routine
  c64[0xE16F] = 0xEA

  // scan keyboard is LDA #3: RTS
  c64[0xFFE4] = 0xA9
  c64[0xFFE5] = 0x03
  c64[0xFFE6] = 0x60
  c64[0xFFFE] = 0x48
  c64[0xFFFF] = 0xFF

  //
  c64.clear_flags()
  c64.set_interrupt_flag()

  //
  c64.initCPU(baseaddress=Some(addr))

  //
  c64.hook(
    0xE16F,
    fn(pc) {
      // let addr = c64[0xBB].0 + (c64[0xBC].0 << 8)
      // let len = c64[0xB7].0
      // let mut testcase = ""
      // for i = 0; i < len; i = i + 1 {
      //   testcase += Char::from_int(c64[addr + i].0).to_string()
      // }
      let testcase = output
      match testcases[testcase] {
        Some(data) => {
          let addr = data[0] + (data[1] << 8)
          c64.load(data, has_load_address=true)

          //
          c64.clear_flags()
          c64.set_interrupt_flag()

          //
          c64.initCPU(baseaddress=Some(addr))
        }
        _ => {
          println("\n\x1b[31;1;6m\{output} not found\x1b[0m\n")
          abort("test not found")
        }
      }
    },
  )
  c64.hook(
    0xFFD2,
    fn(pc) {
      let a = c64.cpu.a().0
      match a {
        0x0D => {
          println("\n\x1b[33;1;6m\{output}\x1b[0m\n")
          output = ""
        }
        _ => output += Char::from_int(a).to_string()
      }
      c64[0x030C] = 0x00
    },
  )
  c64.hook(
    0x8000,
    fn(pc) {
      println("\n\x1b[31;1;6m\{output}\x1b[0m\n")
      abort("test failed")
    },
  )
  c64.hook(
    0xA474,
    fn(pc) {
      println("\n\x1b[31;1;6m\{output}\x1b[0m\n")
      abort("test failed")
    },
  )

  //
  addr
}

// const processor = fake6502();
// const irqRoutine = [
//     0x48, 0x8a, 0x48, 0x98, 0x48, 0xba, 0xbd, 0x04, 0x01, 0x29, 0x10, 0xf0, 0x03, 0x6c, 0x16, 0x03, 0x6c, 0x14, 0x03,
// ];

// function setup(filename) {
//     for (let i = 0x0000; i < 0xffff; ++i) processor.writemem(i, 0x00);
//     return utils.loadData("tests/suite/bin/" + filename).then(function (data) {
//         const addr = data[0] + (data[1] << 8);
//         console.log(">> Loading test '" + filename + "' at " + utils.hexword(addr));
//         for (let i = 2; i < data.length; ++i) processor.writemem(addr + i - 2, data[i]);
//         for (let i = 0; i < irqRoutine.length; ++i) processor.writemem(0xff48 + i, irqRoutine[i]);

//         processor.writemem(0x0002, 0x00);
//         processor.writemem(0xa002, 0x00);
//         processor.writemem(0xa003, 0x80); // Docs say put zero here, but this works better.
//         processor.writemem(0x01fe, 0xff);
//         processor.writemem(0x01ff, 0x7f);

//         // Put RTSes in some of the stubbed calls
//         processor.writemem(0xffd2, 0x60);
//         processor.writemem(0x8000, 0x60);
//         processor.writemem(0xa474, 0x60);
//         // NOP the loading routine
//         processor.writemem(0xe16f, 0xea);
//         // scan keyboard is LDA #3: RTS
//         processor.writemem(0xffe4, 0xa9);
//         processor.writemem(0xffe5, 0x03);
//         processor.writemem(0xffe6, 0x60);
//         processor.writemem(0xfffe, 0x48);
//         processor.writemem(0xffff, 0xff);

//         processor.s = 0xfd;
//         processor.p.reset();
//         processor.p.i = true;
//         processor.pc = 0x0801;
//     });
// }

// let curLine = "";

// function petToAscii(char) {
//     if (char === 14) return ""; // text mode
//     if (char === 145) return ""; // up arrow
//     if (char === 147) return "\n-------\n"; // Clear
//     if (char >= 0xc1 && char <= 0xda) char = char - 0xc1 + 65;
//     else if (char >= 0x41 && char <= 0x5a) char = char - 0x41 + 97;
//     else if (char < 32 || char >= 127) {
//         char = 46;
//     }
//     return String.fromCharCode(char);
// }

// processor.debugInstruction.add(function (addr) {
//     switch (addr) {
//         case 0xffd2:
//             if (processor.a === 13) {
//                 console.log(curLine);
//                 curLine = "";
//             } else {
//                 curLine += petToAscii(processor.a);
//             }
//             processor.writemem(0x030c, 0x00);
//             break;
//         case 0xe16f: {
//             const filenameAddr = processor.readmem(0xbb) | (processor.readmem(0xbc) << 8);
//             const filenameLen = processor.readmem(0xb7);
//             let filename = "";
//             for (let i = 0; i < filenameLen; ++i) filename += petToAscii(processor.readmem(filenameAddr + i));
//             if (filename === "trap17") {
//                 console.log("All tests complete");
//                 process.exit(0);
//             }

//             setup(filename).then(anIter);
//             processor.pc--; // Account for the instruction fetch
//             return true; // Break out of the 'anIter' loop
//         }
//         case 0x8000:
//         case 0xa474: // Fail
//             if (curLine.length) console.log(curLine);
//             throw "Test failed";

//         default:
//             break;
//     }
//     return false;
