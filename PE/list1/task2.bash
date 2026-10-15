#!/bin/bash
# Usage: ./task2.bash [-r] DIR
#   -r  raw output
raw=0
[ "$1" = "-r" ] && { raw=1; shift; }
[ -d "$1" ] || { echo "Usage: $0 [-r] DIR" >&2; exit 1; }
export LC_ALL=C

words() {
  find "$1" -type f -exec cat {} + | tr -s '[:space:]' '\n' | grep -v '^$'
}

if [ $raw -eq 1 ]; then
  words "$1" | sort | uniq -c | awk '{print $1, $2}'
  exit
fi

if [ -t 1 ]; then
  B=$'\e[1;36m'; Y=$'\e[33m'; G=$'\e[32m'; R=$'\e[0m'
else
  B=; Y=; G=; R=
fi

printf '%s▶ Word frequencies in %s%s\n\n' "$B" "$1" "$R"

words "$1" | sort | uniq -c | sort -k1,1nr -k2,2 \
  | awk -v B="$B" -v Y="$Y" -v G="$G" -v R="$R" '
      { c[NR] = $1; w[NR] = $2; total += $1
        if ($1 > max) max = $1
        if (length($2) > wl) wl = length($2) }
      END {
        printf "  %s%-*s  %6s%s\n", B, wl, "WORD", "COUNT", R
        for (i = 1; i <= NR; i++) {
          n = int(c[i] * 20 / max); if (n < 1) n = 1
          bar = ""; for (j = 0; j < n; j++) bar = bar "█"
          printf "  %-*s  %s%6d%s  %s%s%s\n", wl, w[i], Y, c[i], R, G, bar, R
        }
        printf "\n%sSummary:%s %d word(s) in total, %d distinct\n", B, R, total, NR
      }'