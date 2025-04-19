const fs = require('node:fs')

fs.readFile('test_mpu6502.py', 'utf8', (err, data) => {
    if (err) {
        console.error(err)
        return
    }

    const re = new RegExp(`def test_(.*)\\(self\\)`, "i")
    const reAssert = new RegExp(`self.assert(Not)?Equal\\((.*), (.*)\\)`)
    const reLength = new RegExp(`len\\((.*?)\\)`)
    let testcase = []
    let name = ""

    let block_statement = false
    let array_statement = false

    let step = 0
    const steps = [4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 6, 6, 5, 5, 4, 4, 2, 2, 2, 2, 2, 6, 6, 6, 6, 5, 5, 5, 5, 7, 7, 7, 7, 6, 6, 6, 6, 3, 3, 2, 3, 3, 2, 3, 3, 2, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 2, 3, 3, 2, 7, 3, 3, 2, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 5, 5, 5, 7, 7, 7, 6, 6, 6, 2, 2, 2, 2, 2, 2, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 6, 6, 5, 5, 4, 4, 6, 6, 6, 5, 5, 5, 7, 7, 7, 6, 6, 6, 2, 2, 2, 2, 2, 2, 3, 5, 6, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 4, 4, 6, 6, 5, 5, 4, 4, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 2, 2, 2, 6, 6, 6, 5, 5, 5, 7, 7, 7, 6, 6, 6, 2, 4, 4, 3, 3, 2, 2, 4, 4, 4, 4, 6, 6, 5, 5, 4, 4, 3, 3, 4, 4, 2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 2, 2, 2, 2, 6, 6, 6, 6, 5, 5, 5, 5, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 2, 2, 2, 4, 4, 3, 3, 5, 5, 5, 5, 6, 6, 6, 6, 4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 3, 3, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 6, 2, 2, 2, 6, 5, 4, 5, 7, 7, 6, 5, 6, 5, 6, 5, 4, 5, 5, 5,]

    let skip = false

    console.log([
        `///! mpu6502`,
        `/// https://github.com/mnaberez/py65/blob/main/py65/tests/devices/test_mpu6502.py`,
        ``,
        `//`,
        `const DEBUG_TEST = true`,
    ].join("\n"))

    const lines = data.split("\n")
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i]
        // console.error(i, line)

        if (line.trim().length === 0) {
            if (i < lines.length - 1 && lines[i + 1].startsWith("        ")) {
                testcase.push(``)

                continue
            }

            if (testcase.length > 0) {
                // console.error(name)

                if (block_statement) {
                    testcase.push(`  }`)
                    block_statement = false
                }
                testcase.push(`}`)
                console.log(testcase.join("\n"))
            }

            testcase = []
            name = ""

            skip = false
        }

        if (testcase.length > 0 && !skip) {
            // console.log(line)
            line = line.replace(`"""`, `# `)

            if (!line.trim().startsWith("#")) {
                line = line.replace(`target = `, `let target = `)

                if (line.includes(`self._make_mpu`)) {
                    line = line.replace(`mpu = self._make_mpu(`, `let cpu = CPU::new!(`)
                    line = line.replace(`pc=None`, ``)

                    if (line.endsWith(`()`)) {
                        line = line.replace(`()`, `(debug=DEBUG_TEST)`)
                    } else {
                        line = line.replace(`)`, `, debug=DEBUG_TEST)`)
                    }
                }

                line = line.replace(`(mpu.CARRY, mpu.CARRY)`, `(mpu.CARRY, mpu.p & mpu.CARRY)`)
                if (line.includes(`self._write`)) {
                    if (!line.includes(`))`)) {
                        array_statement = true
                    }
                    line = line.replace(`(`, `[`).replace(`)`, `]`).replace("self._write[mpu.memory, ", `cpu.load!(`).replace(` (`, ` [`).replace(`)`, `) |> ignore`)
                } else if (array_statement) {
                    if (line.includes(`))`)) {
                        line = line.replace(`))`, `,`) + `\n  ]) |> ignore`

                        array_statement = false
                    }
                } else if (line.includes(`self.assert`)) {
                    const assert = reAssert.exec(line)
                    // console.log(assert)
                    if (assert) {
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.NEGATIVE)`, `assert_eq!(cpu.flags[N], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.OVERFLOW)`, `assert_eq!(cpu.flags[V], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.DECIMAL)`, `assert_eq!(cpu.flags[D], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.INTERRUPT)`, `assert_eq!(cpu.flags[I], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.UNUSED)`, `assert_eq!(cpu.flags[U], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.BREAK)`, `assert_eq!(cpu.flags[B], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.ZERO)`, `assert_eq!(cpu.flags[Z], false)`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.CARRY)`, `assert_eq!(cpu.flags[C], false)`)

                        line = line.replace(`self.assertEqual(mpu.NEGATIVE, mpu.p & mpu.NEGATIVE)`, `assert_eq!(cpu.flags[N], true)`)
                        line = line.replace(`self.assertEqual(mpu.OVERFLOW, mpu.p & mpu.OVERFLOW)`, `assert_eq!(cpu.flags[V], true)`)
                        line = line.replace(`self.assertEqual(mpu.DECIMAL, mpu.p & mpu.DECIMAL)`, `assert_eq!(cpu.flags[D], true)`)
                        line = line.replace(`self.assertEqual(mpu.INTERRUPT, mpu.p & mpu.INTERRUPT)`, `assert_eq!(cpu.flags[I], true)`)
                        line = line.replace(`self.assertEqual(mpu.UNUSED, mpu.p & mpu.UNUSED)`, `assert_eq!(cpu.flags[U], true)`)
                        line = line.replace(`self.assertEqual(mpu.BREAK, mpu.p & mpu.BREAK)`, `assert_eq!(cpu.flags[B], true)`)
                        line = line.replace(`self.assertEqual(mpu.ZERO, mpu.p & mpu.ZERO)`, `assert_eq!(cpu.flags[Z], true)`)
                        line = line.replace(`self.assertEqual(mpu.CARRY, mpu.p & mpu.CARRY)`, `assert_eq!(cpu.flags[C], true)`)

                        line = line.replace(`self.assertNotEqual(mpu.CARRY, mpu.p & mpu.CARRY)`, `assert_eq!(cpu.flags[C], false)`)

                        if (assert[1] !== undefined) {
                            line = line.replace(`self.assertNotEqual`, `assert_ne!`)
                        } else {
                            line = line.replace(`self.assertEqual`, `assert_eq!`)
                        }
                        if (assert[3].startsWith("mpu.")) {
                            line = line.replace(assert[2], `___`).replace(assert[3], `###`).replace(`___`, assert[3]).replace(`###`, assert[2])
                        }
                    } else {
                        exit()
                    }
                }
                line = line.replace(`mpu.memory`, `cpu.mem`)
                line = line.replace(`mpu.processorCycles`, `cpu.cycles`)
                line = line.replace(`mpu.pc`, `cpu.pc`)

                if (line.includes(`mpu.p = flags = `))
                    line = line.replace(`mpu.p = flags = `, `let flags = cpu.flags.set(`).replace(` & ~(mpu.`, ` ^ `)
                line = line.replace(`mpu.p = mpu.CARRY`, `cpu.flags[C] = true`)
                line = line.replace(`mpu.p |= mpu.CARRY`, `cpu.flags[C] = true`)
                line = line.replace(`mpu.p = mpu.ZERO`, `cpu.flags[Z] = true`)
                line = line.replace(`mpu.p |= mpu.ZERO`, `cpu.flags[Z] = true`)
                line = line.replace(`mpu.p = mpu.DECIMAL`, `cpu.flags[D] = true`)
                line = line.replace(`mpu.p |= mpu.DECIMAL`, `cpu.flags[D] = true`)
                line = line.replace(`mpu.p = mpu.INTERRUPT`, `cpu.flags[I] = true`)
                line = line.replace(`mpu.p |= mpu.INTERRUPT`, `cpu.flags[I] = true`)
                line = line.replace(`mpu.p = mpu.OVERFLOW`, `cpu.flags[V] = true`)
                line = line.replace(`mpu.p |= mpu.OVERFLOW`, `cpu.flags[V] = true`)
                line = line.replace(`mpu.p = mpu.NEGATIVE`, `cpu.flags[N] = true`)
                line = line.replace(`mpu.p |= mpu.NEGATIVE`, `cpu.flags[N] = true`)
                line = line.replace(`mpu.p &= ~(mpu.NEGATIVE)`, `cpu.flags[N] = false`)
                line = line.replace(`mpu.p &= ~(mpu.OVERFLOW)`, `cpu.flags[V] = false`)
                line = line.replace(`mpu.p &= ~(mpu.INTERRUPT)`, `cpu.flags[I] = false`)
                line = line.replace(`mpu.p &= ~(mpu.DECIMAL)`, `cpu.flags[D] = false`)
                line = line.replace(`mpu.p &= ~mpu.DECIMAL`, `cpu.flags[D] = false`)
                line = line.replace(`mpu.p &= ~(mpu.ZERO)`, `cpu.flags[Z] = false`)
                line = line.replace(`mpu.p &= ~mpu.ZERO`, `cpu.flags[Z] = false`)
                line = line.replace(`mpu.p &= ~(mpu.CARRY)`, `cpu.flags[C] = false`)
                line = line.replace(`mpu.p &= ~mpu.CARRY`, `cpu.flags[C] = false`)

                line = line.replace(`mpu.RESET`, `RESET`)
                line = line.replace(`mpu.BREAK`, `BREAK`)
                line = line.replace(`mpu.UNUSED`, `UNUSED`)
                line = line.replace(`mpu.INTERRUPT`, `INTERRUPT`)

                if (line.includes(`mpu.p = `))
                    line = line.replace(`mpu.p = `, `cpu.flags.set(`) + `) |> ignore`
                line = line.replace(`mpu.p`, `cpu.flags.get()`)
                line = line.replace(` + mpu.sp`, ` + cpu.registers[SP]._`)
                line = line.replace(` + mpu.a`, ` + cpu.registers[A]._`)
                line = line.replace(` + mpu.x`, ` + cpu.registers[X]._`)
                line = line.replace(` + mpu.y`, ` + cpu.registers[Y]._`)
                line = line.replace(`mpu.sp`, `cpu.registers[SP]`)
                line = line.replace(`mpu.a`, `cpu.registers[A]`)
                line = line.replace(`mpu.x`, `cpu.registers[X]`)
                line = line.replace(`mpu.y`, `cpu.registers[Y]`)
                if (line.includes(`mpu.step()`))
                    line = line.replace(`mpu.step()`, `assert_eq!(cpu.step(), ${steps[step++]})`)
                line = line.replace(`mpu.`, `cpu.`)

                line = line.replace(`0xFFFA`, `NMI`)
                line = line.replace(`0xFFFC`, `RESET`)
                line = line.replace(`0xFFFE`, `IRQ`)

                line = line.replace(`rel = `, `let rel = `)
                line = line.replace(`, rel`, `, rel.to_byte()`)

                if (line.includes(`assert_eq!`)) {
                    line = line.replace(`])`, `]._)`).replace(`())`, `()._)`)
                }

                if (line.includes(`for`)) {
                    line = line.replace(`range(`, `0..<`).replace(`):`, ` {`)
                    block_statement = true
                }

                const assertLen = line.match(reLength)
                if (assertLen) {
                    line = line.replace(assertLen[0], `${assertLen[1]}.length()`)
                }
            } else line = line.replace(`"""`, ``)

            line = line.replace(` #`, ` //`)
            line = line.replace("        ", "  ")

            testcase.push(line)
        } else if (line.includes("# def test")) {
            skip = true
        } else if (line.includes("def test")) {
            name = re.exec(line)
            if (name) {
                name = name[1]
                // console.log(name)

                testcase.push(`
///|
test "${name}" {`)
            }
        }
    }
})