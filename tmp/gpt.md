Thoughts?
`.sh`
```sh
#!/usr/bin/env bash
set -euo pipefail
jq+() {
	local temp
	temp="$(mktemp)"
	trap "rm -f \"$temp\"" RETURN
	while read -r i
		do IN="$1" node $i > "$temp"
	done < <(find scripts -name \*.js)
	cp "$temp" tmp/jq+.jq
	jq -rf "$temp"
}
find . -empty -delete
DOC=README.md
rm -rf "$DOC" tmp &> /dev/null || :
mkdir -p tmp
touch "$DOC"
exec &> "$DOC"
tsc
while read -r i
	do
		# file names can be prefixed with numbers
		# if ordering is necessary
		# <#><filename>
		# e.g.
			# 0file.log
			# 1file.log
			# 2file.log
		printf '# %s\n' "$(perl -pe '
			s|^pages/\d*(\w+)\.\w+$|$1|g;
			s|_| |g;
			s|\b(\w)(\w*)\b|\u$1\L$2|g;
		' <<< "$i"
		)"
		page=""
		case "${i##*.}" in
			md)page="$(perl -pe 's|^#|##|g' "$i")";;
			yml)
				page="$(yq -o json "$i" \
					| jq+ scripts/yml-to-md.jq
				)"
			;;
		esac
		printf '%s\n' "$page"
done < <(find pages -type f | sort)
```
`scripts/switch-case.ts`
```ts
#!/usr/bin/env node
import fs from "fs";
export const transpiler: {
	depth: number;
	cases: Array<number>;
	switch_var: Array<string>;
	transpile: Function;
} = {
	depth: 0,
	cases: [],
	switch_var: [],
	transpile: function (jq_p: string): string {
		let jq = jq_p;
		while (/((?<!end )switch|case|default|end switch)/.test(jq)) {
			switch (jq.match(/((?<!end )switch|case|default|end switch)/)![1]) {
				case "switch":
					transpiler.depth++;
					transpiler.switch_var[transpiler.depth] =
						jq.match(/switch (\S+)/)![1]!;
					jq = jq.replace(/^.*?switch.*?\n/m, "");
					transpiler.cases[transpiler.depth] = 0;
					break;
				case "case":
					transpiler.cases[transpiler.depth]!++;
					jq = jq.replace(/case ([^\s]+)/, (_, m) => {
						return `${
							transpiler.cases[transpiler.depth] === 1 ? "" : "el"
						}if ${
							transpiler.switch_var[transpiler.depth]
						} == ${m} then`;
					});
					break;
				case "default":
					jq = jq.replace(/default/, "else");
					transpiler.cases[transpiler.depth] = 0;
					break;
				case "end switch":
					jq = jq.replace(/end switch/, "end");
					transpiler.depth--;
					break;
			}
		}
		return jq;
	},
};
console.log(
	transpiler.transpile(
		fs.readFileSync(process.env.IN!, { encoding: "utf-8" })
	)
);
```
`scripts/switch-case.awk`
```awk
/switch/ {
	depth++
	first_case[depth] = 1
	switch_var[depth] = $0
	sub("switch", "", $0)
	next
}
/case/ {
	sub("case", "", $0)
	if (first_case[depth]) {
		printf "if %s == %s then", switch_var[depth], $0
		first_case[depth] = 0
	} else {
		printf "elif %s == %s then", switch_var[depth], $0
	}
	next
}
/default/ {
	sub("default", "", $0)
	print "else"
	next
}
/end/ {
	print "end"
	delete switch_var[depth]
	delete first_case[depth]
	depth--
	next
}
{
	print $0
}
```
`scripts/yml-to-md.jq`
```jq
def indent(n): "  " * n;
def to_md(level; kind):
	(
		switch kind?
			case "bq"
				"> "
			default
				""
		end switch
	) as $pre |
	switch type
		case "object"
			if has("<bq>") then
				.["<bq>"]
					| to_md(level; "bq")
			else
				to_entries[]
					| indent(level)
				+ "- "
				+ $pre
				+ (.key | tostring),
					(.value | to_md(level + 1; kind // null))
			end
		case "array"
			.[] | to_md(level; kind // null)
		default
			switch kind
				case "bq"
					indent(level)
					+ "- "
					+ tostring
						| gsub("- "; "<<<0>>>")
						| gsub("\n"; " \\\n<<<1>>>")
						| gsub("(?<=<<<[0-1]>>>)"; $pre)
						| gsub("<<<0>>>"; "- ")
						| gsub("<<<1>>>"; indent(level + 1))
				default
					indent(level)
					+ "- "
					+ tostring
						| gsub("\n"; " \\\n" + indent(level + 1))
			end switch
	end switch;
to_md(0; null)
```
`scripts/switch-case.js`
```js
#!/usr/bin/env node
import fs from "fs";
export const transpiler = {
    depth: 0,
    cases: [],
    switch_var: [],
    transpile: function (jq_p) {
        let jq = jq_p;
        while (/((?<!end )switch|case|default|end switch)/.test(jq)) {
            switch (jq.match(/((?<!end )switch|case|default|end switch)/)[1]) {
                case "switch":
                    transpiler.depth++;
                    transpiler.switch_var[transpiler.depth] =
                        jq.match(/switch (\S+)/)[1];
                    jq = jq.replace(/^.*?switch.*?\n/m, "");
                    transpiler.cases[transpiler.depth] = 0;
                    break;
                case "case":
                    transpiler.cases[transpiler.depth]++;
                    jq = jq.replace(/case ([^\s]+)/, (_, m) => {
                        return `${transpiler.cases[transpiler.depth] === 1 ? "" : "el"}if ${transpiler.switch_var[transpiler.depth]} == ${m} then`;
                    });
                    break;
                case "default":
                    jq = jq.replace(/default/, "else");
                    transpiler.cases[transpiler.depth] = 0;
                    break;
                case "end switch":
                    jq = jq.replace(/end switch/, "end");
                    transpiler.depth--;
                    break;
            }
        }
        return jq;
    },
};
console.log(transpiler.transpile(fs.readFileSync(process.env.IN, { encoding: "utf-8" })));
```
`scripts/switch-case.d.ts`
```ts
#!/usr/bin/env node
export declare const transpiler: {
    depth: number;
    cases: Array<number>;
    switch_var: Array<string>;
    transpile: Function;
};
```
