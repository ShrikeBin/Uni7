#!/bin/bash
# Usage: ./task3.bash [-r] DIR
#   -r  raw output ("word: N", alphabetical, as in the assignment)
raw=0
[ "$1" = "-r" ] && { raw=1; shift; }
[ -d "$1" ] || { echo "Usage: $0 [-r] DIR" >&2; exit 1; }
export LC_ALL=C

# one line per (file, distinct word)
per_file_words() {
  find "$1" -type f -print0 \
    | while IFS= read -r -d '' f; do
        tr -s '[:space:]' '\n' < "$f" | grep -v '^$' | sort -u
      done
}

if [ $raw -eq 1 ]; then
  per_file_words "$1" | sort | uniq -c | awk '{print $2 ": " $1}'
  exit
fi

if [ -t 1 ]; then
  B=$'\e[1;36m'; Y=$'\e[33m'; G=$'\e[32m'; R=$'\e[0m'
else
  B=; Y=; G=; R=
fi

nfiles=$(find "$1" -type f | wc -l)

printf '%s▶ Number of files containing each word in %s%s\n\n' "$B" "$1" "$R"

per_file_words "$1" | sort | uniq -c | sort -k1,1nr -k2,2 \
  | awk -v B="$B" -v Y="$Y" -v G="$G" -v R="$R" -v nf="$nfiles" '
      { c[NR] = $1; w[NR] = $2
        if (length($2) > wl) wl = length($2) }
      END {
        printf "  %s%-*s  %s%s\n", B, wl, "WORD", "FILES", R
        for (i = 1; i <= NR; i++) {
          n = int(c[i] * 20 / nf); if (n < 1) n = 1
          bar = ""; for (j = 0; j < n; j++) bar = bar "█"
          printf "  %-*s  %s%2d/%-2d%s  %s%s%s\n", wl, w[i], Y, c[i], nf, R, G, bar, R
        }
        printf "\n%sSummary:%s %d distinct word(s) in %d file(s)\n", B, R, NR, nf
      }'