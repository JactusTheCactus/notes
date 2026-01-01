def indent(n): ("\t" * n);
def to_md(level):
	if type == "object" then
		to_entries[]
		| indent(level) + "- " + (.key | tostring),
			(.value | to_md(level + 1))
	elif type == "array" then
		.[]
		| indent(level) + "- " + (tostring),
			(to_md(level + 1)?)
	else
		indent(level) + "- " + (tostring)
	end;
to_md(0)