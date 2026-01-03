import fs from "fs";
class JQ_P {
    body;
    constructor(source, str = "") {
        switch (source) {
            case "string":
                this.body = str;
                break;
            case "file":
                this.body = fs.readFileSync(str, { encoding: "utf-8" });
                break;
        }
    }
    switch_case() {
        let depth = 0;
        const cases = [];
        const switch_var = [];
        const switch_case_regex = new RegExp(`(${[/(?<!end )switch/, /case/, /default/, /end switch/]
            .map((i) => `${i}`.replace(/\/(.*?)\/\w*/, (_, m) => `\\b${m}\\b`))
            .join("|")})`);
        while (switch_case_regex.test(this.body)) {
            switch (this.body.match(switch_case_regex)[1]) {
                case "switch":
                    depth++;
                    switch_var[depth] = this.body.match(/\bswitch (\S+)/)[1];
                    this.body = this.body.replace(/^.*?switch.*?\n/m, "");
                    cases[depth] = 0;
                    break;
                case "case":
                    cases[depth]++;
                    this.body = this.body.replace(/\bcase ([^\s]+)/, (_, m) => {
                        return `${cases[depth] === 1 ? "" : "el"}if ${switch_var[depth]} == ${m} then`;
                    });
                    break;
                case "default":
                    this.body = this.body.replace(/\bdefault\b/, "else");
                    cases[depth] = 0;
                    break;
                case "end switch":
                    this.body = this.body.replace(/\bend switch\b/, "end");
                    depth--;
                    break;
            }
        }
        return this.body;
    }
}
console.log(new JQ_P(process.argv[2], process.argv[3]).switch_case());
