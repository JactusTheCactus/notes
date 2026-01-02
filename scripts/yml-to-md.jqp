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