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
  "mmu____": @testsuite.mmu // FIXME
  ,
  "cpuport": @testsuite.cpuport // FIXME
  ,
  "cputiming": @testsuite.cputiming // FIXME
  ,
  "irq": @testsuite.irq,
}

pub fn testsuite() -> Unit {
  let c64 = @lib.C64::new(realSID=true, debug=false)
  let _ = c64.load(irq, offset=0xFF48)

  //
  let data = testcases["mmufetch"].or_default()
  load(c64, data)

  // c64[0xEA31] = 0x40
  // let _ = c64.load(
  //   [
  //     // SEI
  //     0x78,

  //     // LDA #$51 // START | FORCELOAD | COUNT_TIMERA
  //      0xA9, 0x51,
  //     // STA $DC0F
  //      0x8D, 0x0F, 0xDC,

  //     // LDA #$FC
  //      0xA9, 0x08, //
  //     // STA $DC04
  //      0x8D, 0x04, 0xDC,
  //     // LDA #$03
  //      0xA9, 0x00, //
  //     // STA $DC05
  //      0x8D, 0x05, 0xDC,

  //     // LDA #$FF
  //      0xA9, 0x01,
  //     // STA $DC06
  //      0x8D, 0x06, 0xDC,
  //     // STA $DC07
  //      0x8D, 0x07, 0xDC,

  //     // <timer
  //     // LDA #$2C
  //      0xA9, 0x2C,
  //     // STA $0314
  //      0x8D, 0x14, 0x03,
  //     // >timer
  //     // LDA #$08
  //      0xA9, 0x08,
  //     // STA $0315
  //      0x8D, 0x15, 0x03,

  //     // LDA #$11 // START | FORCELOAD
  //      0xA9, 0x11,
  //     // STA $DC0E
  //      0x8D, 0x0E, 0xDC,

  //     // CLI
  //      0x58,
  //     // JMP $083A
  //      0x4C, 0x3A, 0x08, // main

  //     // timer
  //     // INC $0400
  //      0xEE, 0x00, 0x04,
  //     // LDA #$7F
  //      0xA9, 0x7F, // all interrupts
  //     // STA $DC0D
  //      0x8D, 0x0D, 0xDC,
  //     // LDA $DC0D
  //      0xAD, 0x0D, 0xDC,
  //     // JMP $EA31
  //      0x4C, 0x31, 0xEA,

  //     // main
  //     // LDA #$01
  //      0xA9, 0x01,
  //     // STA $D800
  //      0x8D, 0x00, 0xD8,

  //     // loop
  //     // JMP $083F
  //      0x4C, 0x3F, 0x08, // loop
  //     // RTS
  //      0x60,

  //     /// codebase64.org
  //     // // disable maskable IRQs
  //     // 0x78, // SEI             ; 2

  //     // // disable timer interrupts which can be generated by the two CIA chips
  //     // // the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better
  //     // // stop it.
  //     //  0xA9, 0x7F, // LDA #$7F        ; 2
  //     //  0x8D, 0x0D, 0xDC, // STA $DC0D       ; 4
  //     //  0x8D, 0x0D, 0xDD, // STA $DD0D       ; 4

  //     // // by reading this two registers we negate any pending CIA irqs.
  //     // // if we don't do this, a pending CIA irq might occur after we finish setting up our irq.
  //     // // we don't want that to happen.
  //     //  0xAD, 0x0D, 0xDC, // LDA $DC0D       ; 4
  //     //  0xAD, 0x0D, 0xDD, // LDA $DD0D       ; 4

  //     // // this is how to tell the VICII to generate a raster interrupt
  //     //  0xA9, 0x01, // LDA #$01        ; 2
  //     //  0x8D, 0x1A, 0xD0, // STA $D01A       ; 4

  //     // // this is how to tell at which rasterline we want the irq to be triggered
  //     //  0xA9, 0x02, // LDA #$64        ; 2
  //     //  0x8D, 0x12, 0xD0, // STA $D012       ; 4

  //     // // as there are more than 256 rasterlines, the topmost bit of $d011 serves as
  //     // // the 9th bit for the rasterline we want our irq to be triggered.
  //     // // here we simply set up a character screen, leaving the topmost bit 0.
  //     //  0xA9, 0x1B, // LDA #$1B        ; 2
  //     //  0x8D, 0x11, 0xD0, // STA $D011       ; 4

  //     // // we turn off the BASIC and KERNAL rom here
  //     // // the cpu now sees RAM everywhere except at $d000-$e000, where still the registers of
  //     // // SID/VICII/etc are visible
  //     //  0xA9, 0x35, // LDA #$35        ; 2
  //     //  0x85, 0x01, // STA $01         ; 3

  //     // // this is how we set up
  //     // // the address of our interrupt code
  //     //  0xA9, 0x31, // LDA #$31        ; 2
  //     //  0x8D, 0xFE, 0xFF, // STA $FFFE       ; 4
  //     //  0xA9, 0x08, // LDA #$08        ; 2
  //     //  0x8D, 0xFF, 0xFF, // STA $FFFF       ; 4

  //     // // enable maskable interrupts again
  //     //  0x58, // CLI             ; 2

  //     // // we better don't RTS, the ROMS are now switched off, there's no way back to the system
  //     //  0x4C, 0x2E, 0x08, // JMP $082E       ; 3

  //     // // Being all kernal irq handlers switched off we have to do more work by ourselves.
  //     // // When an interrupt happens the CPU will stop what its doing, store the status and return address
  //     // // into the stack, and then jump to the interrupt routine. It will not store other registers, and if
  //     // // we destroy the value of A/X/Y in the interrupt routine, then when returning from the interrupt to
  //     // // what the CPU was doing will lead to unpredictable results (most probably a crash). So we better
  //     // // store those registers, and restore their original value before reentering the code the CPU was
  //     // // interrupted running.
  //     // // If you won't change the value of a register you are safe to not to store / restore its value.
  //     // // However, it's easy to screw up code like that with later modifying it to use another register too
  //     // // and forgetting about storing its state.
  //     // // The method shown here to store the registers is the most orthodox and most failsafe.

  //     // // store register A in stack
  //     //  0x48, // PHA             ; 3
  //     //  0x8A, // TXA             ; 2
  //     // // store register X in stack
  //     //  0x48, // PHA             ; 3
  //     //  0x98, // TYA             ; 2
  //     // // store register Y in stack
  //     //  0x48, // PHA             ; 3

  //     // // this is the orthodox and safe way of clearing the interrupt condition of the VICII.
  //     //  0xA9, 0xFF, // LDA #$FF        ; 2
  //     // // if you don't do this the interrupt condition will be present all the time and you end
  //     // // up having the CPU running the interrupt code all the time, as when it exists the
  //     // // interrupt, the interrupt request from the VICII will be there again regardless of the
  //     // // rasterline counter.

  //     // // it's pretty safe to use inc $d019 (or any other rmw instruction) for brevity, they
  //     // // will only fail on hardware like c65 or supercpu. c64dtv is ok with this though.
  //     //  0x8D, 0x19, 0xD0, // STA $D019       ; 4

  //     // // restore register Y from stack (remember stack is FIFO: First In First Out)
  //     //  0x68, // PLA             ; 4
  //     //  0xA8, // TAY             ; 2
  //     //  0x68, // PLA
  //     //  0xAA, // TAX
  //     //  0x68, // PLA
  //     //  0x40, // RTI
  //   ],
  //   offset=0x0801,
  // )
  // c64.initCPU(baseaddress=0x0801)
  // c64.clear_flags()
  // // c64.set_interrupt_flag()

  //
  let mut i = 0
  while c64.pc() != 0x0000 && i < 10000000 {
    let _ = c64.emulate()
    i += 1
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
  c64.initCPU(baseaddress=(addr))

  //
  c64.clear_flags()
  c64.set_interrupt_flag()
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
      let a = c64.cpu.a()._
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
