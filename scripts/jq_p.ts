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
	compile(): string {
		let depth: number = 0;
		const cases: Array<number> = [];
		const switch_var: Array<string> = [];
		const keys: Record<string, Function> = {
			"end switch": function (body: string): string {
				body = body.replace(/\bend switch\b/, "end");
				depth--;
				return body;
			},
			switch: function (body: string): string {
				depth++;
				switch_var[depth] = body.match(/\bswitch (\S+)/)![1]!;
				body = body.replace(/^.*?switch.*?\n/m, "");
				cases[depth] = 0;
				return body;
			},
			case: function (body: string): string {
				cases[depth]!++;
				body = body.replace(
					/\bcase ([^\s]+)/,
					(_, m) =>
						`${cases[depth] === 1 ? "if" : "elif"} ${
							switch_var[depth]
						} == ${m} then`
				);
				return body;
			},
			default: function (body: string): string {
				body = body.replace(/\bdefault\b/, "else");
				cases[depth] = 0;
				return body;
			},
		};
		const re = new RegExp(`\\b(${Object.keys(keys).join("|")})\\b`);
		while (re.test(this.body)) {
			this.body = keys[this.body.match(re)![1]!]!(this.body);
		}
		return this.body;
	}
}
console.log(
	new JQ_P(process.argv[2] as "file" | "string", process.argv[3]).compile()
);
