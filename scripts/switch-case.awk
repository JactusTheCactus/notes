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