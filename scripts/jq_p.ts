import fs from "fs";
class JQ_P {
	body: string;
	constructor(source: "file" | "string", str: string = "") {
		switch (source) {
			case "string":
				this.body = str;
				break;
			case "file":
				this.body = fs.readFileSync(str, { encoding: "utf-8" });
				break;
		}
	}
	switch_case(): string {
		let depth: number = 0;
		const cases: Array<number> = [];
		const switch_var: Array<string> = [];
		const switch_case_regex = new RegExp(
			`\\b(${[/end switch/, /switch/, /case/, /default/]
				.map((i) => `${i}`.replace(/\/(.*?)\/\w*/, (_, m) => m))
				.join("|")})\\b`
		);
		while (switch_case_regex.test(this.body)) {
			switch (this.body.match(switch_case_regex)![1]) {
				case "switch":
					depth++;
					switch_var[depth] = this.body.match(/\bswitch (\S+)/)![1]!;
					this.body = this.body.replace(/^.*?switch.*?\n/m, "");
					cases[depth] = 0;
					break;
				case "case":
					cases[depth]!++;
					this.body = this.body.replace(/\bcase ([^\s]+)/, (_, m) => {
						return [
							cases[depth]! === 1 ? "if" : "elif",
							switch_var[depth],
							"==",
							m,
							"then",
						].join(" ");
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
	to_jq() {
		return this.switch_case();
	}
}
console.log(
	new JQ_P(process.argv[2] as "file" | "string", process.argv[3]).to_jq()
);
