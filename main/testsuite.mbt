///|
const PATH = "testsuite/bin/"

///|
// let testcases : Map[String, FixedArray[Byte]] = {
//   "start": @testsuite._start

//   /// LDA
//   ,
//   "ldab": @testsuite.ldab,
//   "ldaz": @testsuite.ldaz,
//   "ldazx": @testsuite.ldazx,
//   "ldaa": @testsuite.ldaa,
//   "ldaax": @testsuite.ldaax,
//   "ldaay": @testsuite.ldaay,
//   "ldaix": @testsuite.ldaix,
//   "ldaiy": @testsuite.ldaiy

//   // STA
//   ,
//   "staz": @testsuite.staz,
//   "stazx": @testsuite.stazx,
//   "staa": @testsuite.staa,
//   "staax": @testsuite.staax,
//   "staay": @testsuite.staay,
//   "staix": @testsuite.staix,
//   "staiy": @testsuite.staiy

//   // LDX
//   ,
//   "ldxb": @testsuite.ldxb,
//   "ldxz": @testsuite.ldxz,
//   "ldxzy": @testsuite.ldxzy,
//   "ldxa": @testsuite.ldxa,
//   "ldxay": @testsuite.ldxay

//   // STX
//   ,
//   "stxz": @testsuite.stxz,
//   "stxzy": @testsuite.stxzy,
//   "stxa": @testsuite.stxa

//   // LDY
//   ,
//   "ldyb": @testsuite.ldyb,
//   "ldyz": @testsuite.ldyz,
//   "ldyzx": @testsuite.ldyzx,
//   "ldya": @testsuite.ldya,
//   "ldyax": @testsuite.ldyax

//   // STY
//   ,
//   "styz": @testsuite.styz,
//   "styzx": @testsuite.styzx,
//   "stya": @testsuite.stya

//   // Transfer
//   ,
//   "taxn": @testsuite.taxn,
//   "tayn": @testsuite.tayn,
//   "txan": @testsuite.txan,
//   "tyan": @testsuite.tyan,
//   "tsxn": @testsuite.tsxn,
//   "txsn": @testsuite.txsn

//   // Push & Pull
//   ,
//   "phan": @testsuite.phan,
//   "plan": @testsuite.plan,
//   "phpn": @testsuite.phpn,
//   "plpn": @testsuite.plpn

//   // Increment
//   ,
//   "inxn": @testsuite.inxn,
//   "inyn": @testsuite.inyn

//   // Decrement
//   ,
//   "dexn": @testsuite.dexn,
//   "deyn": @testsuite.deyn

//   // Increment
//   ,
//   "incz": @testsuite.incz,
//   "inczx": @testsuite.inczx,
//   "inca": @testsuite.inca,
//   "incax": @testsuite.incax

//   // Decrement
//   ,
//   "decz": @testsuite.decz,
//   "deczx": @testsuite.deczx,
//   "deca": @testsuite.deca,
//   "decax": @testsuite.decax

//   // Arithmetic Shift
//   ,
//   "asln": @testsuite.asln,
//   "aslz": @testsuite.aslz,
//   "aslzx": @testsuite.aslzx,
//   "asla": @testsuite.asla,
//   "aslax": @testsuite.aslax

//   // Logical Shift
//   ,
//   "lsrn": @testsuite.lsrn,
//   "lsrz": @testsuite.lsrz,
//   "lsrzx": @testsuite.lsrzx,
//   "lsra": @testsuite.lsra,
//   "lsrax": @testsuite.lsrax

//   // Rotate Left
//   ,
//   "roln": @testsuite.roln,
//   "rolz": @testsuite.rolz,
//   "rolzx": @testsuite.rolzx,
//   "rola": @testsuite.rola,
//   "rolax": @testsuite.rolax

//   // Rotate Right
//   ,
//   "rorn": @testsuite.rorn,
//   "rorz": @testsuite.rorz,
//   "rorzx": @testsuite.rorzx,
//   "rora": @testsuite.rora,
//   "rorax": @testsuite.rorax

//   // AND
//   ,
//   "andb": @testsuite.andb,
//   "andz": @testsuite.andz,
//   "andzx": @testsuite.andzx,
//   "anda": @testsuite.anda,
//   "andax": @testsuite.andax,
//   "anday": @testsuite.anday,
//   "andix": @testsuite.andix,
//   "andiy": @testsuite.andiy

//   // OR
//   ,
//   "orab": @testsuite.orab,
//   "oraz": @testsuite.oraz,
//   "orazx": @testsuite.orazx,
//   "oraa": @testsuite.oraa,
//   "oraax": @testsuite.oraax,
//   "oraay": @testsuite.oraay,
//   "oraix": @testsuite.oraix,
//   "oraiy": @testsuite.oraiy

//   // Exclusive OR
//   ,
//   "eorb": @testsuite.eorb,
//   "eorz": @testsuite.eorz,
//   "eorzx": @testsuite.eorzx,
//   "eora": @testsuite.eora,
//   "eorax": @testsuite.eorax,
//   "eoray": @testsuite.eoray,
//   "eorix": @testsuite.eorix,
//   "eoriy": @testsuite.eoriy

//   // Clear & Set
//   ,
//   "clcn": @testsuite.clcn,
//   "secn": @testsuite.secn,
//   "cldn": @testsuite.cldn,
//   "sedn": @testsuite.sedn,
//   "clin": @testsuite.clin,
//   "sein": @testsuite.sein,
//   "clvn": @testsuite.clvn

//   // Addition
//   ,
//   "adcb": @testsuite.adcb,
//   "adcz": @testsuite.adcz,
//   "adczx": @testsuite.adczx,
//   "adca": @testsuite.adca,
//   "adcax": @testsuite.adcax,
//   "adcay": @testsuite.adcay,
//   "adcix": @testsuite.adcix,
//   "adciy": @testsuite.adciy

//   // Subtraction
//   ,
//   "sbcb": @testsuite.sbcb,
//   "sbcz": @testsuite.sbcz,
//   "sbczx": @testsuite.sbczx,
//   "sbca": @testsuite.sbca,
//   "sbcax": @testsuite.sbcax,
//   "sbcay": @testsuite.sbcay,
//   "sbcix": @testsuite.sbcix,
//   "sbciy": @testsuite.sbciy

//   // Comparison
//   ,
//   "cmpb": @testsuite.cmpb,
//   "cmpz": @testsuite.cmpz,
//   "cmpzx": @testsuite.cmpzx,
//   "cmpa": @testsuite.cmpa,
//   "cmpax": @testsuite.cmpax,
//   "cmpay": @testsuite.cmpay,
//   "cmpix": @testsuite.cmpix,
//   "cmpiy": @testsuite.cmpiy

//   // Copy
//   ,
//   "cpxb": @testsuite.cpxb,
//   "cpxz": @testsuite.cpxz,
//   "cpxa": @testsuite.cpxa,
//   "cpyb": @testsuite.cpyb,
//   "cpyz": @testsuite.cpyz,
//   "cpya": @testsuite.cpya

//   // Bit
//   ,
//   "bitz": @testsuite.bitz,
//   "bita": @testsuite.bita

//   // Break / Return / Jump
//   ,
//   "brkn": @testsuite.brkn,
//   "rtin": @testsuite.rtin,
//   "jsrw": @testsuite.jsrw,
//   "rtsn": @testsuite.rtsn,
//   "jmpw": @testsuite.jmpw,
//   "jmpi": @testsuite.jmpi

//   // Branch
//   ,
//   "beqr": @testsuite.beqr,
//   "bner": @testsuite.bner,
//   "bmir": @testsuite.bmir,
//   "bplr": @testsuite.bplr,
//   "bcsr": @testsuite.bcsr,
//   "bccr": @testsuite.bccr,
//   "bvsr": @testsuite.bvsr,
//   "bvcr": @testsuite.bvcr

//   // No Operation
//   ,
//   "nopn": @testsuite.nopn,
//   "nopb": @testsuite.nopb,
//   "nopz": @testsuite.nopz,
//   "nopzx": @testsuite.nopzx,
//   "nopa": @testsuite.nopa,
//   "nopax": @testsuite.nopax

//   // Arithmetic Shift
//   ,
//   "asoz": @testsuite.asoz,
//   "asozx": @testsuite.asozx,
//   "asoa": @testsuite.asoa,
//   "asoax": @testsuite.asoax,
//   "asoay": @testsuite.asoay,
//   "asoix": @testsuite.asoix,
//   "asoiy": @testsuite.asoiy

//   // Rotate Left
//   ,
//   "rlaz": @testsuite.rlaz,
//   "rlazx": @testsuite.rlazx,
//   "rlaa": @testsuite.rlaa,
//   "rlaax": @testsuite.rlaax,
//   "rlaay": @testsuite.rlaay,
//   "rlaix": @testsuite.rlaix,
//   "rlaiy": @testsuite.rlaiy

//   // Logical Shift
//   ,
//   "lsez": @testsuite.lsez,
//   "lsezx": @testsuite.lsezx,
//   "lsea": @testsuite.lsea,
//   "lseax": @testsuite.lseax,
//   "lseay": @testsuite.lseay,
//   "lseix": @testsuite.lseix,
//   "lseiy": @testsuite.lseiy

//   // Rotate Right
//   ,
//   "rraz": @testsuite.rraz,
//   "rrazx": @testsuite.rrazx,
//   "rraa": @testsuite.rraa,
//   "rraax": @testsuite.rraax,
//   "rraay": @testsuite.rraay,
//   "rraix": @testsuite.rraix,
//   "rraiy": @testsuite.rraiy

//   // Decrement
//   ,
//   "dcmz": @testsuite.dcmz,
//   "dcmzx": @testsuite.dcmzx,
//   "dcma": @testsuite.dcma,
//   "dcmax": @testsuite.dcmax,
//   "dcmay": @testsuite.dcmay,
//   "dcmix": @testsuite.dcmix,
//   "dcmiy": @testsuite.dcmiy

//   // Increment
//   ,
//   "insz": @testsuite.insz,
//   "inszx": @testsuite.inszx,
//   "insa": @testsuite.insa,
//   "insax": @testsuite.insax,
//   "insay": @testsuite.insay,
//   "insix": @testsuite.insix,
//   "insiy": @testsuite.insiy

//   // Load
//   ,
//   "laxz": @testsuite.laxz,
//   "laxzy": @testsuite.laxzy,
//   "laxa": @testsuite.laxa,
//   "laxay": @testsuite.laxay,
//   "laxix": @testsuite.laxix,
//   "laxiy": @testsuite.laxiy

//   // AXS
//   ,
//   "axsz": @testsuite.axsz,
//   "axszy": @testsuite.axszy,
//   "axsa": @testsuite.axsa,
//   "axsix": @testsuite.axsix

//   // Arithmetic Left
//   ,
//   "alrb": @testsuite.alrb
//   // Arithmetic Right
//   ,
//   "arrb": @testsuite.arrb
//   // ANE
//   ,
//   "aneb": @testsuite.aneb

//   // Load
//   ,
//   "lxab": @testsuite.lxab
//   // Store
//   ,
//   "sbxb": @testsuite.sbxb

//   // Store A
//   ,
//   "shaay": @testsuite.shaay,
//   "shaiy": @testsuite.shaiy

//   // Store X
//   ,
//   "shxay": @testsuite.shxay
//   // Store Y
//   ,
//   "shyax": @testsuite.shyax
//   // Store S
//   ,
//   "shsay": @testsuite.shsay

//   // ANC
//   ,
//   "ancb": @testsuite.ancb

//   // LAS
//   ,
//   "lasay": @testsuite.lasay

//   // SBC
//   ,
//   "sbcb(eb)": @testsuite.sbcbeb

//   // Trap
//   ,
//   "trap1": @testsuite.trap1 // FIXME
//   ,
//   "branchwrap": @testsuite.branchwrap,
//   "mmufetch": @testsuite.mmufetch // FIXME
//   ,
//   "mmu____": @testsuite.mmu // FIXME
//   ,
//   "cpuport": @testsuite.cpuport // FIXME
//   ,
//   "cputiming": @testsuite.cputiming // FIXME
//   ,
//   "irq": @testsuite.irq,
// }

///|
pub fn testsuite() -> Unit {
  //
  let c64 = @lib.C64::new(realSID=true, debug=false)

  //
  let irq : FixedArray[Byte] = [
    0x48, 0x8A, 0x48, 0x98, 0x48, 0xBA, 0xBD, 0x04, 0x01, 0x29, 0x10, 0xF0, 0x03,
    0x6C, 0x16, 0x03, 0x6C, 0x14, 0x03,
  ]
  let _ = c64.load(irq, offset=0xFF48)

  //
  load_testcase(c64, " start")

  //
  setup(c64)

  //
  let mut i = 0
  while c64.pc() != 0x0000 && i < 1000000 { // safety check to avoid infinite loop
    let _ = c64.emulate()
    i += 1
  }
}

///|
fn load_testcase(c64 : @lib.C64, testcase : String) -> Unit {
  let content = @fs.read_file_to_bytes?(PATH + testcase)
  match content {
    Ok(content) => reset(c64, content)
    Err(error) => {
      println("\u{1B}[31;1;6m\{error}\u{1B}[0m")
      abort("test not found")
    }
  }
}

///|
fn setup(c64 : @lib.C64) -> Unit {
  let mut output = ""

  //
  c64.hook(0xE16F, fn(_) {
    let testcase = output
    load_testcase(c64, testcase)
  })
  c64.hook(0xFFD2, fn(cpu) {
    let a = cpu.a()._
    match a {
      13 => {
        println("\u{1B}[33m\{output}\u{1B}[0m")
        output = ""
      }
      14 => output += "" // text mode
      145 => output += "\u{1B}[1A\u{1B}[1m" // ↑ up arrow
      147 => output += "\u{1B}c" // clear
      _ => {
        let a = if a >= 0xC1 && a <= 0xDA {
          a - 0xC1 + 65
        } else if a >= 0x41 && a <= 0x5A {
          a - 0x41 + 97
        } else if a < 32 || a >= 127 {
          46
        } else {
          a
        }
        output += Char::from_int(a).to_string()
      }
    }
    c64[SAREG] = 0x00 // Storage for 6502 .A Register
  })
  c64.hook(0x8000, fn(_) {
    println("\u{1B}[31;1;6m\{output}\u{1B}[0m")
    abort("test failed")
  })
  c64.hook(0xA474, fn(_) {
    println("\u{1B}[31;1;6m\{output}\u{1B}[0m")
    abort("test failed")
  })
}

///|
fn reset(c64 : @lib.C64, data : Bytes) -> Unit {
  let addr = c64.load(data.to_fixedarray(), has_load_address=true)

  //
  c64.set_bank(@lib.IOPort::from_int(0x00))

  //
  c64[UNUSED] = 0x00
  // c64[0xA002] = 0x00
  // c64[0xA003] = 0x80 // Docs say put zero here, but this works better.
  c64.write_word(WARM, 0x8000)

  //
  // c64[0x01FE] = 0xFF
  // c64[0x01FF] = 0x7F
  c64.push16(0x7FFF)

  // Put RTSes in some of the stubbed calls
  c64[CHROUT] = 0x60
  // c64[0x8000] = 0x60
  c64.write_array(CARTROM, [0x60])
  // c64[0xA474] = 0x60
  c64.write_array(READY, [0x60])

  // NOP the loading routine
  // c64[0xE16F] = 0xEA
  c64.write(0xE16F, 0xEA)

  // scan keyboard is LDA #3: RTS
  // c64[0xFFE4] = 0xA9
  // c64[0xFFE5] = 0x03
  // c64[0xFFE6] = 0x60
  c64.write_array(GETIN, [0xA9, 0x03, 0x60])
  // c64[0xFFFE] = 0x48
  // c64[0xFFFF] = 0xFF
  c64.write_word(IRQ, 0xFF48)

  //
  c64.initCPU(baseaddress=addr)

  //
  c64.clear_flags()
  c64.set_interrupt_flag()
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
