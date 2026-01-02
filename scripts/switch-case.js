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
