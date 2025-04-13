const fs = require('node:fs')

const tests = []

fs.readFile('test_mpu6502.py', 'utf8', (err, data) => {
    if (err) {
        console.error(err)
        return
    }

    const re = new RegExp(`def test_(.*)\\(self\\)`, "i")
    const reAssert = new RegExp(`self.assert(Not)?Equal\\((.*), (.*)\\)`)
    const reWrite = new RegExp(`mpu.memory\\[(.*)\\] = \\(?(.*)\\)?`)
    let testcase = []

    for (let line of data.split("\n")) {
        // console.log(line)
        if (line.trim().length === 0) {
            if (testcase.length > 0) {
                testcase.push(`}`)
                console.log(testcase.join("\n"))
            }

            testcase = []
        }

        if (testcase.length > 0) {
            // console.log(line)
            if (!line.trim().startsWith("#")) {
                line = line.replace(`mpu = self._make_mpu(`, `let cpu = CPU::new(`)
                line = line.replace(`(mpu.CARRY, mpu.CARRY)`, `(mpu.CARRY, mpu.p & mpu.CARRY)`)
                if (line.includes(`self._write`)) {
                    line = line.replace(`(`, `[`).replace(`)`, `]`).replace("self._write[mpu.memory, ", `cpu.load(`).replace(` (`, ` [`)
                    // } else if (line.includes(`mpu.memory[`)) {
                    //     const write = reWrite.exec(line)
                    //     // console.log(write)
                    //     if (write) {
                    //         let comment = write[2].split(" # ")
                    //         line = line.replace(write[0], `cpu.write(${write[1]}, ${comment[0]})` + (comment[1] ? ` # ${comment[1]}` : ""))
                    //     } else {
                    //         line = line.replace(`mpu.memory[`, `cpu.read(`).replace(`]`, `)`)
                    //         // line = line.replace(`mpu.memory[`, `cpu.write(`).replace(`] = `, `, `).replace(` #`, `) #`)
                    //         // if (!line.includes(`) #`) && !line.endsWith(`)`)) {
                    //         //     line += `)`
                    //         // }
                    //     }
                } else if (line.includes(`self.assert`)) {
                    const assert = reAssert.exec(line)
                    // console.log(assert)
                    if (assert) {
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.NEGATIVE)`, `@test.eq(cpu.flags[N], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.OVERFLOW)`, `@test.eq(cpu.flags[V], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.DECIMAL)`, `@test.eq(cpu.flags[D], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.INTERRUPT)`, `@test.eq(cpu.flags[I], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.BREAK)`, `@test.eq(cpu.flags[B], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.ZERO)`, `@test.eq(cpu.flags[Z], false)!`)
                        line = line.replace(`self.assertEqual(0, mpu.p & mpu.CARRY)`, `@test.eq(cpu.flags[C], false)!`)

                        line = line.replace(`self.assertEqual(mpu.NEGATIVE, mpu.p & mpu.NEGATIVE)`, `@test.eq(cpu.flags[N], true)!`)
                        line = line.replace(`self.assertEqual(mpu.OVERFLOW, mpu.p & mpu.OVERFLOW)`, `@test.eq(cpu.flags[V], true)!`)
                        line = line.replace(`self.assertEqual(mpu.DECIMAL, mpu.p & mpu.DECIMAL)`, `@test.eq(cpu.flags[D], true)!`)
                        line = line.replace(`self.assertEqual(mpu.INTERRUPT, mpu.p & mpu.INTERRUPT)`, `@test.eq(cpu.flags[I], true)!`)
                        line = line.replace(`self.assertEqual(mpu.BREAK, mpu.p & mpu.BREAK)`, `@test.eq(cpu.flags[B], true)!`)
                        line = line.replace(`self.assertEqual(mpu.ZERO, mpu.p & mpu.ZERO)`, `@test.eq(cpu.flags[Z], true)!`)
                        line = line.replace(`self.assertEqual(mpu.CARRY, mpu.p & mpu.CARRY)`, `@test.eq(cpu.flags[C], true)!`)

                        line = line.replace(`self.assertNotEqual(mpu.CARRY, mpu.p & mpu.CARRY)`, `@test.eq(cpu.flags[C], false)!`)

                        if (assert[1] !== undefined) {
                            line = line.replace(`self.assertNotEqual`, `@test.ne`)
                        } else {
                            line = line.replace(`self.assertEqual`, `@test.eq`)
                        }
                        if (assert[3].startsWith("mpu.")) {
                            line = line.replace(assert[2], `___`).replace(assert[3], `###`).replace(`___`, assert[3]).replace(`###`, assert[2])
                        }

                        line = line.replace(`)`, `)!`).replace(`)!!`, `)!`)
                    } else {
                        exit()
                    }
                }
                line = line.replace(`mpu.memory`, `cpu.mem`)
                line = line.replace(`mpu.processorCycles`, `cpu.cycles`)
                line = line.replace(`mpu.pc`, `cpu.pc`)
                line = line.replace(`mpu.BREAK`, `B`)
                line = line.replace(`mpu.UNUSED`, `U`)
                line = line.replace(`mpu.INTERRUPT`, `I`)
                line = line.replace(` | `, ` + `)
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
                if (line.includes(`mpu.p = `))
                    line = line.replace(`mpu.p = `, `cpu.flags.set_flags(`) + `)`
                line = line.replace(`mpu.p`, `cpu.flags.get_flags()`)
                line = line.replace(`mpu.sp`, `cpu.registers[SP]`)
                line = line.replace(`mpu.a`, `cpu.registers[A]`)
                line = line.replace(`mpu.x`, `cpu.registers[X]`)
                line = line.replace(`mpu.y`, `cpu.registers[Y]`)
                line = line.replace(`mpu.step()`, `@test.eq(cpu.step(), 0)!`)
                line = line.replace(`mpu.`, `cpu.`)
            }
            line = line.replace(` #`, ` //`)
            testcase.push(line)
        } else if (line.includes("def test")) {
            const name = re.exec(line)
            if (name) {
                // console.log(name[1])

                testcase.push(`test "${name[1]}" {`)
            }
        }
    }
})