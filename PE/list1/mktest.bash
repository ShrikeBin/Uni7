#!/bin/bash
# Usage: ./mk-testdata.bash [TARGET_DIR]   (default: ./a)
root=${1:-a}
rm -rf "$root"

mk() {
  local f="$root/$1"; shift
  mkdir -p "$(dirname "$f")"
  printf '%s\n' "$@" > "$f"
}

mk a/b/aab        "aa b"   "a a b"  "a ab"
mk aa/b/aaab      "aaa b"  "aa ab"  "a aab"
mk aaa/b/aaaab    "aaaab"
mk aab/b/aaabb    "aaabb"
mk ab/b/aabb      "aab b"  "aa bb"  "a abb"
mk aba/b/aabab    "aabab"
mk abb/b/aabbb    "aabbb"
mk b/ab           "a b"
mk b/b/abb        "ab b"   "a b b"  "a bb"
mk ba/b/abab      "aba b"  "ab ab"  "a bab"
mk baa/b/abaab    "abaab"
mk bab/b/ababb    "ababb"
mk bb/b/abbb      "abb b"  "ab bb"  "a bbb"
mk bba/b/abbab    "abbab"
mk bbb/b/abbbb    "abbbb"

cat > run_tests.bash <<'EOF'
#!/bin/bash
# Usage: ./run_tests.bash [-r] [DIR]
#   -r   raw mode: tasks 1,2,3,4,6 run with -r and task 5 with -q
#   DIR  test directory (default: ./a)
raw=0
[ "$1" = "-r" ] && { raw=1; shift; }
dir=${1:-./a}
[ -d "$dir" ] || { echo "Directory '$dir' not found. Run ./mk-testdata.bash first." >&2; exit 1; }

if [ -t 1 ]; then
  B=$'\e[1;36m'; X=$'\e[1;31m'; D=$'\e[2m'; R=$'\e[0m'
else
  B=; X=; D=; R=
fi

banner() {
  local bar; bar=$(printf '═%.0s' {1..14})
  printf '\n%s╔%s╗\n║ %-12s ║\n╚%s╝%s\n\n' "$B" "$bar" "$1" "$bar" "$R"
}

mode_flag() {
  [ $raw -eq 1 ] || return
  case "$1" in
    1|2|3|4|6) echo "-r" ;;
    5)     echo "-q" ;;
  esac
}

fail=0
for n in 1 2 3 4 6 5 2; do
  flag=$(mode_flag "$n")
  cmd="./task${n}.bash ${flag:+$flag }$dir"

  banner "task $n:"
  printf '%s$ %s%s\n\n' "$D" "$cmd" "$R"

  $cmd
  rc=$?
  if [ $rc -ne 0 ]; then
    printf '\n%s✘ task %s failed (exit code %d)%s\n' "$X" "$n" "$rc" "$R"
    ((fail++))
  fi
done

[ $fail -eq 0 ]
EOF
chmod +x run_tests.bash task*.bash 2>/dev/null

echo "Test data created in '$root'."
command -v tree >/dev/null && tree "$root"