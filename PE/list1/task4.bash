#!/bin/bash
# Usage: ./task4.bash [-r] DIR
#   -r  raw output
raw=0
[ "$1" = "-r" ] && { raw=1; shift; }
[ -d "$1" ] || { echo "Usage: $0 [-r] DIR" >&2; exit 1; }
export LC_ALL=C
dir=$1

all_words() {
  find "$dir" -type f -exec cat {} + | tr -s '[:space:]' '\n' | grep -v '^$' | sort -u
}

# matches of one word: file:line:text (files in sorted order)
matches() {
  find "$dir" -type f -print0 | sort -z | xargs -0 grep -HnwF -- "$1"
}

if [ $raw -eq 1 ]; then
  all_words | while IFS= read -r w; do
    echo "$w:"
    matches "$w"
  done
  exit
fi

if [ -t 1 ]; then
  B=$'\e[1;36m'; F=$'\e[33m'; N=$'\e[32m'; R=$'\e[0m'
else
  B=; F=; N=; R=
fi

printf '%s▶ Lines containing each word in %s%s\n' "$B" "$dir" "$R"

all_words | while IFS= read -r w; do
  matches "$w" | sed "s/^/$w\t/"          # prefix every match with its word
done \
  | awk -F'\t' -v B="$B" -v F="$F" -v N="$N" -v R="$R" '
      { w[NR] = $1
        # $2 is "file:line:text" (file names are assumed not to contain ":")
        split($2, p, ":")
        f[NR] = p[1]; n[NR] = p[2]
        t[NR] = substr($2, length(p[1]) + length(p[2]) + 3)
        cnt[$1]++
        if (length(p[1]) > max) max = length(p[1]) }
      END {
        for (i = 1; i <= NR; i++) {
          if (w[i] != prev) {
            printf "\n%s■ %s%s  (%d match%s)\n", B, w[i], R, cnt[w[i]], (cnt[w[i]] == 1 ? "" : "es")
            prev = w[i]
          }
          printf "  %s%-*s%s  line %s%-3d%s │ %s\n", F, max, f[i], R, N, n[i], R, t[i]
        }
      }'