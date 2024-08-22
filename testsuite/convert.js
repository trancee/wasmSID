const { glob } = require("glob")
const fs = require("fs")
const path = require("path")

const convert = async () => {
    const files = await glob("bin/*", { nodir: true, })
    // console.log(files)

    for (file of files) {
        const name = path.basename(file).replace("(", "").replace(")", "")
        // console.log(name)

        const data = fs.readFileSync(file)
        const buffer = Buffer.from(data, "ascii")

        let output = `pub let ${name.replace(" ", "_")} : FixedArray[Int] = [`
        for (const [index, value] of buffer.entries()) {
            if ((index) % 14 === 0) {
                output += `\n  `
            }
            const hex = value.toString(16).toUpperCase().padStart(2, "0")
            output += `0x${hex}, `
            if (index === 1) {
                output += `// LoadAddress`
                output += `\n  `
            }
        }
        output += `\n]`

        // console.log(output)

        fs.writeFileSync(`${name}.mbt`, output)
    }
}

convert()
