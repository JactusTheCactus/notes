def indent(n): "  " * n;
def to_md(level; kind):
	(
			if kind? == "bq" then
				"> "
			else
				""
		end
	) as $pre |
		if type == "object" then
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
		elif type == "array" then
			.[] | to_md(level; kind // null)
		else
				if kind == "bq" then
					indent(level)
					+ "- "
					+ tostring
						| gsub("- "; "<<<0>>>")
						| gsub("\n"; " \\\n<<<1>>>")
						| gsub("(?<=<<<[0-1]>>>)"; $pre)
						| gsub("<<<0>>>"; "- ")
						| gsub("<<<1>>>"; indent(level + 1))
				else
					indent(level)
					+ "- "
					+ tostring
						| gsub("\n"; " \\\n" + indent(level + 1))
			end
	end;
to_md(0; null)
