#!/bin/bash
# Usage: ./task1.bash [-r] DIR
#   -r  raw output (plain list, exactly as in the assignment)
raw=0
if [ "$1" = "-r" ]; then raw=1; shift; fi
[ -d "$1" ] || { echo "Usage: $0 [-r] DIR" >&2; exit 1; }
export LC_ALL=C

if [ $raw -eq 1 ]; then
  find "$1" -type f
  exit
fi

if [ -t 1 ]; then
  B=$'\e[1;36m'; Y=$'\e[33m'; G=$'\e[32m'; R=$'\e[0m'
else
  B=; Y=; G=; R=
fi

printf '%s▶ Regular files in %s%s\n\n' "$B" "$1" "$R"

count=0; total=0
while IFS= read -r -d '' f; do
  ((count++))
  size=$(wc -c < "$f")
  ((total += size))
  printf '  %s%3d%s  %-30s %s%6d bytes%s\n' "$G" "$count" "$R" "$f" "$Y" "$size" "$R"
done < <(find "$1" -type f -print0 | sort -z)

printf '\n%sSummary:%s %d file(s), %d bytes in total\n' "$B" "$R" "$count" "$total"