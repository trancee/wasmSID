let irq : FixedArray[Int] = [
  0x48, 0x8A, 0x48, 0x98, 0x48, 0xBA, 0xBD, 0x04, 0x01, 0x29, 0x10, 0xF0, 0x03, 0x6C,
  0x16, 0x03, 0x6C, 0x14, 0x03,
]

let testcases : Map[String, FixedArray[Int]] = {
  "start": @testsuite._start

  /// LDA
  ,
  "ldab": @testsuite.ldab,
  "ldaz": @testsuite.ldaz,
  "ldazx": @testsuite.ldazx,
  "ldaa": @testsuite.ldaa,
  "ldaax": @testsuite.ldaax,
  "ldaay": @testsuite.ldaay,
  "ldaix": @testsuite.ldaix,
  "ldaiy": @testsuite.ldaiy

  // STA
  ,
  "staz": @testsuite.staz,
  "stazx": @testsuite.stazx,
  "staa": @testsuite.staa,
  "staax": @testsuite.staax,
  "staay": @testsuite.staay,
  "staix": @testsuite.staix,
  "staiy": @testsuite.staiy

  // LDX
  ,
  "ldxb": @testsuite.ldxb,
  "ldxz": @testsuite.ldxz,
  "ldxzy": @testsuite.ldxzy,
  "ldxa": @testsuite.ldxa,
  "ldxay": @testsuite.ldxay

  // STX
  ,
  "stxz": @testsuite.stxz,
  "stxzy": @testsuite.stxzy,
  "stxa": @testsuite.stxa

  // LDY
  ,
  "ldyb": @testsuite.ldyb,
  "ldyz": @testsuite.ldyz,
  "ldyzx": @testsuite.ldyzx,
  "ldya": @testsuite.ldya,
  "ldyax": @testsuite.ldyax

  // STY
  ,
  "styz": @testsuite.styz,
  "styzx": @testsuite.styzx,
  "stya": @testsuite.stya

  // Transfer
  ,
  "taxn": @testsuite.taxn,
  "tayn": @testsuite.tayn,
  "txan": @testsuite.txan,
  "tyan": @testsuite.tyan,
  "tsxn": @testsuite.tsxn,
  "txsn": @testsuite.txsn

  // Push & Pull
  ,
  "phan": @testsuite.phan,
  "plan": @testsuite.plan,
  "phpn": @testsuite.phpn,
  "plpn": @testsuite.plpn

  // Increment
  ,
  "inxn": @testsuite.inxn,
  "inyn": @testsuite.inyn

  // Decrement
  ,
  "dexn": @testsuite.dexn,
  "deyn": @testsuite.deyn

  // Increment
  ,
  "incz": @testsuite.incz,
  "inczx": @testsuite.inczx,
  "inca": @testsuite.inca,
  "incax": @testsuite.incax

  // Decrement
  ,
  "decz": @testsuite.decz,
  "deczx": @testsuite.deczx,
  "deca": @testsuite.deca,
  "decax": @testsuite.decax

  // Arithmetic Shift
  ,
  "asln": @testsuite.asln,
  "aslz": @testsuite.aslz,
  "aslzx": @testsuite.aslzx,
  "asla": @testsuite.asla,
  "aslax": @testsuite.aslax

  // Logical Shift
  ,
  "lsrn": @testsuite.lsrn,
  "lsrz": @testsuite.lsrz,
  "lsrzx": @testsuite.lsrzx,
  "lsra": @testsuite.lsra,
  "lsrax": @testsuite.lsrax

  // Rotate Left
  ,
  "roln": @testsuite.roln,
  "rolz": @testsuite.rolz,
  "rolzx": @testsuite.rolzx,
  "rola": @testsuite.rola,
  "rolax": @testsuite.rolax

  // Rotate Right
  ,
  "rorn": @testsuite.rorn,
  "rorz": @testsuite.rorz,
  "rorzx": @testsuite.rorzx,
  "rora": @testsuite.rora,
  "rorax": @testsuite.rorax

  // AND
  ,
  "andb": @testsuite.andb,
  "andz": @testsuite.andz,
  "andzx": @testsuite.andzx,
  "anda": @testsuite.anda,
  "andax": @testsuite.andax,
  "anday": @testsuite.anday,
  "andix": @testsuite.andix,
  "andiy": @testsuite.andiy

  // OR
  ,
  "orab": @testsuite.orab,
  "oraz": @testsuite.oraz,
  "orazx": @testsuite.orazx,
  "oraa": @testsuite.oraa,
  "oraax": @testsuite.oraax,
  "oraay": @testsuite.oraay,
  "oraix": @testsuite.oraix,
  "oraiy": @testsuite.oraiy

  // Exclusive OR
  ,
  "eorb": @testsuite.eorb,
  "eorz": @testsuite.eorz,
  "eorzx": @testsuite.eorzx,
  "eora": @testsuite.eora,
  "eorax": @testsuite.eorax,
  "eoray": @testsuite.eoray,
  "eorix": @testsuite.eorix,
  "eoriy": @testsuite.eoriy

  // Clear & Set
  ,
  "clcn": @testsuite.clcn,
  "secn": @testsuite.secn,
  "cldn": @testsuite.cldn,
  "sedn": @testsuite.sedn,
  "clin": @testsuite.clin,
  "sein": @testsuite.sein,
  "clvn": @testsuite.clvn

  // Addition
  ,
  "adcb": @testsuite.adcb,
  "adcz": @testsuite.adcz,
  "adczx": @testsuite.adczx,
  "adca": @testsuite.adca,
  "adcax": @testsuite.adcax,
  "adcay": @testsuite.adcay,
  "adcix": @testsuite.adcix,
  "adciy": @testsuite.adciy

  // Subtraction
  ,
  "sbcb": @testsuite.sbcb,
  "sbcz": @testsuite.sbcz,
  "sbczx": @testsuite.sbczx,
  "sbca": @testsuite.sbca,
  "sbcax": @testsuite.sbcax,
  "sbcay": @testsuite.sbcay,
  "sbcix": @testsuite.sbcix,
  "sbciy": @testsuite.sbciy

  // Comparison
  ,
  "cmpb": @testsuite.cmpb,
  "cmpz": @testsuite.cmpz,
  "cmpzx": @testsuite.cmpzx,
  "cmpa": @testsuite.cmpa,
  "cmpax": @testsuite.cmpax,
  "cmpay": @testsuite.cmpay,
  "cmpix": @testsuite.cmpix,
  "cmpiy": @testsuite.cmpiy

  // Copy
  ,
  "cpxb": @testsuite.cpxb,
  "cpxz": @testsuite.cpxz,
  "cpxa": @testsuite.cpxa,
  "cpyb": @testsuite.cpyb,
  "cpyz": @testsuite.cpyz,
  "cpya": @testsuite.cpya

  // Bit
  ,
  "bitz": @testsuite.bitz,
  "bita": @testsuite.bita

  // Break / Return / Jump
  ,
  "brkn": @testsuite.brkn,
  "rtin": @testsuite.rtin,
  "jsrw": @testsuite.jsrw,
  "rtsn": @testsuite.rtsn,
  "jmpw": @testsuite.jmpw,
  "jmpi": @testsuite.jmpi

  // Branch
  ,
  "beqr": @testsuite.beqr,
  "bner": @testsuite.bner,
  "bmir": @testsuite.bmir,
  "bplr": @testsuite.bplr,
  "bcsr": @testsuite.bcsr,
  "bccr": @testsuite.bccr,
  "bvsr": @testsuite.bvsr,
  "bvcr": @testsuite.bvcr

  // No Operation
  ,
  "nopn": @testsuite.nopn,
  "nopb": @testsuite.nopb,
  "nopz": @testsuite.nopz,
  "nopzx": @testsuite.nopzx,
  "nopa": @testsuite.nopa,
  "nopax": @testsuite.nopax

  // Arithmetic Shift
  ,
  "asoz": @testsuite.asoz,
  "asozx": @testsuite.asozx,
  "asoa": @testsuite.asoa,
  "asoax": @testsuite.asoax,
  "asoay": @testsuite.asoay,
  "asoix": @testsuite.asoix,
  "asoiy": @testsuite.asoiy

  // Rotate Left
  ,
  "rlaz": @testsuite.rlaz,
  "rlazx": @testsuite.rlazx,
  "rlaa": @testsuite.rlaa,
  "rlaax": @testsuite.rlaax,
  "rlaay": @testsuite.rlaay,
  "rlaix": @testsuite.rlaix,
  "rlaiy": @testsuite.rlaiy

  // Logical Shift
  ,
  "lsez": @testsuite.lsez,
  "lsezx": @testsuite.lsezx,
  "lsea": @testsuite.lsea,
  "lseax": @testsuite.lseax,
  "lseay": @testsuite.lseay,
  "lseix": @testsuite.lseix,
  "lseiy": @testsuite.lseiy

  // Rotate Right
  ,
  "rraz": @testsuite.rraz,
  "rrazx": @testsuite.rrazx,
  "rraa": @testsuite.rraa,
  "rraax": @testsuite.rraax,
  "rraay": @testsuite.rraay,
  "rraix": @testsuite.rraix,
  "rraiy": @testsuite.rraiy

  // Decrement
  ,
  "dcmz": @testsuite.dcmz,
  "dcmzx": @testsuite.dcmzx,
  "dcma": @testsuite.dcma,
  "dcmax": @testsuite.dcmax,
  "dcmay": @testsuite.dcmay,
  "dcmix": @testsuite.dcmix,
  "dcmiy": @testsuite.dcmiy

  // Increment
  ,
  "insz": @testsuite.insz,
  "inszx": @testsuite.inszx,
  "insa": @testsuite.insa,
  "insax": @testsuite.insax,
  "insay": @testsuite.insay,
  "insix": @testsuite.insix,
  "insiy": @testsuite.insiy

  // Load
  ,
  "laxz": @testsuite.laxz,
  "laxzy": @testsuite.laxzy,
  "laxa": @testsuite.laxa,
  "laxay": @testsuite.laxay,
  "laxix": @testsuite.laxix,
  "laxiy": @testsuite.laxiy

  // AXS
  ,
  "axsz": @testsuite.axsz,
  "axszy": @testsuite.axszy,
  "axsa": @testsuite.axsa,
  "axsix": @testsuite.axsix

  // Arithmetic Left
  ,
  "alrb": @testsuite.alrb
  // Arithmetic Right
  ,
  "arrb": @testsuite.arrb
  // ANE
  ,
  "aneb": @testsuite.aneb

  // Load
  ,
  "lxab": @testsuite.lxab
  // Store
  ,
  "sbxb": @testsuite.sbxb

  // Store A
  ,
  "shaay": @testsuite.shaay,
  "shaiy": @testsuite.shaiy

  // Store X
  ,
  "shxay": @testsuite.shxay
  // Store Y
  ,
  "shyax": @testsuite.shyax
  // Store S
  ,
  "shsay": @testsuite.shsay

  // ANC
  ,
  "ancb": @testsuite.ancb

  // LAS
  ,
  "lasay": @testsuite.lasay

  // SBC
  ,
  "sbcb(eb)": @testsuite.sbcbeb

  // Trap
  ,
  "trap1": @testsuite.trap1 // FIXME
  ,
  "branchwrap": @testsuite.branchwrap,
  "mmufetch": @testsuite.mmufetch // FIXME
  ,
  "mmu": @testsuite.mmu // FIXME
  ,
  "cpuport": @testsuite.cpuport // FIXME
  ,
  "cputiming": @testsuite.cputiming // FIXME
  ,
  "irq": @testsuite.irq,
}

/// IRQ
/// $DC0E <= #$19
/// $DC0D => #$00

/// 088D  A9 19     LDA #$19                        A:00 X:FF Y:00 P:B4 SP:FD
/// 088F  8D 0E DC  STA $DC0E = 00                  A:19 X:FF Y:00 P:34 SP:FD # CIACRA: START / FORCELOAD / ONESHOT (NONE)
/// TimerA Force Load
/// 0892  60        RTS                             A:19 X:FF Y:00 P:34 SP:FD
/// 0C66  AD 0D DC  LDA $DC0D = 00                  A:19 X:FF Y:00 P:34 SP:FF # CIAICR
/// TimerA OneShot
/// 0C69  C9 00     CMP #$00                        A:00 X:FF Y:00 P:36 SP:FF
/// 0C6B  D0 CC     BNE $0C39                       A:00 X:FF Y:00 P:37 SP:FF
/// 0C6D  A9 04     LDA #$04                        A:00 X:FF Y:00 P:37 SP:FF
/// 0C6F  20 61 08  JSR $0861                       A:04 X:FF Y:00 P:35 SP:FF
/// 0861  48        PHA                             A:04 X:FF Y:00 P:35 SP:FD
/// 0862  A9 00     LDA #$00                        A:04 X:FF Y:00 P:35 SP:FC
/// 0864  8D 0E DC  STA $DC0E = 08                  A:00 X:FF Y:00 P:37 SP:FC # CIACRA: NONE (FORCELOAD)
/// 0867  18        CLC                             A:00 X:FF Y:00 P:37 SP:FC
/// 0868  68        PLA                             A:00 X:FF Y:00 P:36 SP:FC
/// 0869  69 03     ADC #$03                        A:04 X:FF Y:00 P:34 SP:FD
/// 086B  8D 04 DC  STA $DC04 = 06                  A:07 X:FF Y:00 P:34 SP:FD # TIMALO: #$07
/// 086E  A9 00     LDA #$00                        A:07 X:FF Y:00 P:34 SP:FD
/// 0870  8D 05 DC  STA $DC05 = 00                  A:00 X:FF Y:00 P:36 SP:FD # TIMAHI: #$00
/// 0873  A9 93     LDA #$93                        A:00 X:FF Y:00 P:36 SP:FD
/// 0875  8D FE FF  STA $FFFE = 93                  A:93 X:FF Y:00 P:B4 SP:FD # PCL: #$93
/// 0878  A9 08     LDA #$08                        A:93 X:FF Y:00 P:B4 SP:FD
/// 087A  8D FF FF  STA $FFFF = 08                  A:08 X:FF Y:00 P:34 SP:FD # PCH: #$08
/// 087D  A9 35     LDA #$35                        A:08 X:FF Y:00 P:34 SP:FD
/// 087F  85 01     STA $01 = 35                    A:35 X:FF Y:00 P:34 SP:FD # DREG(?): #$35
/// 0881  AD 11 D0  LDA $D011 = 18                  A:35 X:FF Y:00 P:34 SP:FD
/// 0884  30 07     BMI $088D                       A:18 X:FF Y:00 P:34 SP:FD
/// 0886  AD 12 D0  LDA $D012 = 00                  A:18 X:FF Y:00 P:34 SP:FD
/// 0889  C9 1E     CMP #$1E                        A:00 X:FF Y:00 P:36 SP:FD
/// 088B  B0 F9     BCS $0886                       A:00 X:FF Y:00 P:B4 SP:FD
///
/// 088D  A9 19     LDA #$19                        A:00 X:FF Y:00 P:B4 SP:FD
/// 088F  8D 0E DC  STA $DC0E = 00                  A:19 X:FF Y:00 P:34 SP:FD # CIACRA: START / FORCELOAD / ONESHOT (NONE)
/// TimerA Force Load
/// 0892  60        RTS                             A:19 X:FF Y:00 P:34 SP:FD
/// 0C72  AD 0D DC  LDA $DC0D = 81                  A:19 X:FF Y:00 P:34 SP:FF # CIAICR: TIMERA / INTERRUPT
/// TimerA OneShot
/// 0C75  C9 01     CMP #$01                        A:81 X:FF Y:00 P:B4 SP:FF
/// 0C77  D0 C0     BNE $0C39                       A:81 X:FF Y:00 P:B5 SP:FF
/// 0C39  20 F3 08  JSR $08F3                       A:81 X:FF Y:00 P:B5 SP:FF
/// 08F3  A9 37     LDA #$37                        A:81 X:FF Y:00 P:B5 SP:FD
/// 08F5  85 01     STA $01 = 35                    A:37 X:FF Y:00 P:35 SP:FD
/// 08F7  A9 23     LDA #$23                        A:37 X:FF Y:00 P:35 SP:FD
/// 08F9  8D 04 DC  STA $DC04 = 04                  A:23 X:FF Y:00 P:35 SP:FD
/// 08FC  A9 40     LDA #$40                        A:23 X:FF Y:00 P:35 SP:FD
/// 08FE  8D 05 DC  STA $DC05 = 00                  A:40 X:FF Y:00 P:35 SP:FD
/// 0901  A9 11     LDA #$11                        A:40 X:FF Y:00 P:35 SP:FD
/// 0903  8D 0E DC  STA $DC0E = 08                  A:11 X:FF Y:00 P:35 SP:FD # CIACRA: START / FORCELOAD (FORCELOAD)
/// TimerA Force Load
/// 0906  60        RTS                             A:11 X:FF Y:00 P:35 SP:FD
/// 0C3C  20 1C 08  JSR $081C                       A:11 X:FF Y:00 P:35 SP:FF
/// 081C  68        PLA                             A:11 X:FF Y:00 P:35 SP:FD
/// 081D  8D 27 08  STA $0827 = 51                  A:3E X:FF Y:00 P:35 SP:FE
/// 0820  68        PLA                             A:3E X:FF Y:00 P:35 SP:FE
/// 0821  8D 28 08  STA $0828 = 0C                  A:0C X:FF Y:00 P:35 SP:FF
/// 0824  A2 01     LDX #$01                        A:0C X:FF Y:00 P:35 SP:FF
/// 0826  BD 3E 0C  LDA $0C3E,X @ 0C3F = 0D         A:0C X:01 Y:00 P:35 SP:FF
/// 0829  F0 06     BEQ $0831                       A:0D X:01 Y:00 P:35 SP:FF
/// irqB  20 D2 FF  JSR $FFD2                       A:0D X:01 Y:00 P:35 SP:FF

pub fn testsuite() -> Unit {
  let c64 = @lib.C64::new(realSID=true, debug=true)
  let _ = c64.load(irq, offset=0xFF48)

  //
  let data = testcases["irq"].or_default()
  load(c64, data)

  //
  while c64.pc() != 0x0000 {
    let _ = c64.emulate()

  }
}

fn setup(c64 : @lib.C64, data : FixedArray[Int]) -> Unit {
  let addr = c64.load(data, has_load_address=true)

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
  c64.initCPU(baseaddress=Some(addr))

  //
  c64.clear_flags()
  // c64.set_interrupt_flag()
}

fn load(c64 : @lib.C64, data : FixedArray[Int]) -> Unit {
  let mut output = ""

  //
  setup(c64, data)

  //
  c64.hook(
    0xE16F,
    fn(pc) {
      let testcase = output
      match testcases[testcase] {
        Some(data) => setup(c64, data)
        _ => {
          println("\x1b[31;1;6m\{output} not found\x1b[0m")
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
        13 => {
          println("\x1b[33m\{output}\x1b[0m")
          output = ""
        }
        14 => output += "" // text mode
        145 => output += "\x1b[1A\x1b[1m" // ↑ up arrow
        147 => output += "\x1bc" // Clear
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
      c64[0x030C] = 0x00
    },
  )
  c64.hook(
    0x8000,
    fn(pc) {
      println("\x1b[31;1;6m\{output}\x1b[0m")
      abort("test failed")
    },
  )
  c64.hook(
    0xA474,
    fn(pc) {
      println("\x1b[31;1;6m\{output}\x1b[0m")
      abort("test failed")
    },
  )
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
