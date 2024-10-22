const { readFileSync, readdirSync, writeFileSync, lstatSync} = require("fs");

let args = {
    main: null,
    modules: [],
    output: null
}

function parseArgs(){
    for (let i = 0; i < process.argv.length; i++){
        switch (process.argv[i]){
            case "-m": case "--main": {
                args.main = process.argv[++i];
                break;
            }
            case "-o": case "--output": {
                args.output = process.argv[++i];
                break;
            }
            case "-n": {
                i++;
                while (i < process.argv.length && !process.argv[i].startsWith("-")) {
                    args.modules.push(process.argv[i++]);
                }
            }
        }
    }
}

parseArgs()

let modules = [];

function find_modules(path = "modules"){
    readdirSync(path).forEach((p) => {
        let stat = lstatSync(`${path}/${p}`);
        if (stat.isDirectory()) {
            find_modules(`${path}/${p}`);
        } else if (stat.isFile() && p.endsWith(".lua")) {
            let name = (path !== "modules" ? path.replace(/^modules\//, "") + "/" : '') + p.replace(/\.lua$/, "");
            console.log(name)
            if (name && args.modules.includes(name)) {
                modules.push({
                    name,
                    path: `${path}/${p}`
                });
            }
        }
    })
}

find_modules();

let buff = "";

modules.reverse().forEach((m) => {
    buff += readFileSync(m.path, "utf-8")
    buff += "\n";
});

buff += readFileSync(args.main, "utf-8");

writeFileSync(args.output, buff)