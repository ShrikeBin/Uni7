#!/bin/bash
# Usage: ./task5.bash [-q] DIR
#   -q  quiet mode (no report, like the original version)
quiet=0
[ "$1" = "-q" ] && { quiet=1; shift; }
[ -d "$1" ] || { echo "Usage: $0 [-q] DIR" >&2; exit 1; }
export LC_ALL=C

# colors only when writing to a terminal
if [ -t 1 ]; then
  G=$'\e[32m'; Y=$'\e[33m'; D=$'\e[2m'; B=$'\e[1;36m'; R=$'\e[0m'
else
  G=; Y=; D=; B=; R=
fi

files=0; changed=0; replaced=0

[ $quiet -eq 0 ] && printf '%s▶ Replacing a → A in %s%s\n\n' "$B" "$1" "$R"

while IFS= read -r -d '' f; do
  ((files++))
  n=$(tr -cd 'a' < "$f" | wc -c)      # number of 'a' characters in this file
  if [ "$n" -gt 0 ]; then
    sed -i 's/a/A/g' "$f"
    ((changed++)); ((replaced += n))
    [ $quiet -eq 0 ] && printf '  %s✔%s %-30s %s%3d replacement(s)%s\n' "$G" "$R" "$f" "$Y" "$n" "$R"
  else
    [ $quiet -eq 0 ] && printf '  %s· %-30s     nothing to replace%s\n' "$D" "$f" "$R"
  fi
done < <(find "$1" -type f -print0 | sort -z)

if [ $quiet -eq 0 ]; then
  printf '\n%sSummary:%s %d file(s) scanned, %d modified, %d replacement(s) in total\n' \
    "$B" "$R" "$files" "$changed" "$replaced"
fi