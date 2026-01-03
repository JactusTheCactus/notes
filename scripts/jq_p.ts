import fs from "fs";
class JQ_P {
	body: string;
	constructor(str: string = "") {
		this.body = str;
	}
	set(str: string) {
		this.body = str;
	}
	get() {
		return this.body;
	}
	switch_case(jq_p: string): string {
		const jq = new JQ_P(jq_p);
		let depth: number = 0;
		const cases: Array<number> = [];
		const switch_var: Array<string> = [];
		while (/((?<!end )switch|case|default|end switch)/.test(jq.get())) {
			switch (
				jq.get().match(/((?<!end )switch|case|default|end switch)/)![1]
			) {
				case "switch":
					depth++;
					switch_var[depth] = jq.get().match(/switch (\S+)/)![1]!;
					jq.set(jq.get().replace(/^.*?switch.*?\n/m, ""));
					cases[depth] = 0;
					break;
				case "case":
					cases[depth]!++;
					jq.set(
						jq.get().replace(/case ([^\s]+)/, (_, m) => {
							return `${cases[depth] === 1 ? "" : "el"}if ${
								switch_var[depth]
							} == ${m} then`;
						})
					);
					break;
				case "default":
					jq.set(jq.get().replace(/default/, "else"));
					cases[depth] = 0;
					break;
				case "end switch":
					jq.set(jq.get().replace(/end switch/, "end"));
					depth--;
					break;
			}
		}
		return jq.get();
	}
}
console.log(
	new JQ_P().switch_case(
		fs.readFileSync(process.env["IN"]!, { encoding: "utf-8" })
	)
);
