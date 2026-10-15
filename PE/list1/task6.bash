#!/bin/bash
# Usage: ./task6.bash [-r] DIR
#   -r  raw output
raw=0
if [ "$1" = "-r" ]; then raw=1; shift; fi
[ -d "$1" ] || { echo "Usage: $0 [-r] DIR" >&2; exit 1; }
export LC_ALL=C

# one tab-separated record per repeated word: word, file, line number, line text
repeated() {
  find "$1" -type f -print0 \
    | xargs -0 awk '
        { delete c
          for (i = 1; i <= NF; i++)
            if (++c[$i] == 2)          # report each word once per line
              printf "%s\t%s\t%d\t%s\n", $i, FILENAME, FNR, $0 }' \
    | sort -s -t$'\t' -k1,1
}

if [ $raw -eq 1 ]; then
  repeated "$1" \
    | awk -F'\t' '$1 != prev { print $1 ":"; prev = $1 } { print $2 ":" $3 ":" $4 }'
  exit
fi

if [ -t 1 ]; then
  B=$'\e[1;36m'; F=$'\e[33m'; N=$'\e[32m'; R=$'\e[0m'
else
  B=; F=; N=; R=
fi

repeated "$1" \
  | awk -F'\t' -v B="$B" -v F="$F" -v N="$N" -v R="$R" '
      { w[NR] = $1; f[NR] = $2; n[NR] = $3; t[NR] = $4
        if (length($2) > max) max = length($2) }
      END {
        for (i = 1; i <= NR; i++) {
          if (w[i] != prev) {
            if (i > 1) print ""
            printf "%s▶ %s%s\n", B, w[i], R
            prev = w[i]
          }
          printf "  %s%-*s%s  line %s%-3d%s │ %s\n", F, max, f[i], R, N, n[i], R, t[i]
        }
      }'