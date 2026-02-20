# `fzf`
pipe an array into fzf, which is command substituted into a map as a key
```bash
declare -A KEYS=(
	[a]=1
	[b]=2
	[c]=3
)
key="$(fzf <<< "${KEYS[@]}")" # select b
echo "<${MAP[$key]}>" # <2>
```
