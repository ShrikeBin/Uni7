#!/bin/bash
# Usage: ./mk-bigtest.bash [TARGET_DIR]   (default: ./big)
root=${1:-big}
rm -rf "$root"

mk() {
  local f="$root/$1"; shift
  mkdir -p "$(dirname "$f")"
  printf '%s\n' "$@" > "$f"
}

# ---- original ----
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

# ---- repeats inside one line (task 6) ----
mk rep/one/x          "a a a a a"
mk rep/one/y          "b b b b b b b b"
mk rep/one/z          "ab ab ab ba ba ba"
mk rep/two/x          "hello world hello world"
mk rep/two/y          "the cat and the dog and the bird"
mk rep/two/z          "one two three" "one one two two three three" "four five six"
mk rep/deep/er/est/x  "abba abba baab baab abba"
mk rep/deep/er/est/y  "no repeats here at all" "yes yes repeats here"

# ---- longer words and shared prefixes ----
mk words/prefix/p1    "ab abc abcd abcde" "abcde abcd abc ab"
mk words/prefix/p2    "ba bab baba babab" "bababa babab baba bab ba"
mk words/prefix/p3    "aaaaaaaaaa" "aaaaaaaaa aaaaaaaaaa"
mk words/prefix/p4    "bbbbbbbbbbbb a bbbbbbbbbbbb"
mk words/long/l1      "supercalifragilisticexpialidocious" "pneumonoultramicroscopicsilicovolcanoconiosis"
mk words/long/l2      "abcdefghijklmnopqrstuvwxyz" "zyxwvutsrqponmlkjihgfedcba"
mk words/long/l3      "abababababababababababababababab" "babababababababababababababababa"

# ---- uppercase and mixed case ----
mk case/c1            "Apple apple APPLE aPPle" "apple Apple"
mk case/c2            "Banana banana BANANA" "banana banana banana"
mk case/c3            "A a A a" "B b B b"

# ---- whitespace madness ----
mk ws/multi           "a    b     c" "   leading spaces" "trailing spaces   " "   both   "
mk ws/blank           "" "" ""
mk ws/gaps            "first" "" "second" "" "" "third"
mk ws/single_space    " "
mk ws/wide            "x                              y                              z"
mk ws/mixed           "  a  a  b  b  " "" "  c  " "c    c"

# ---- many small files in a wide directory ----
for i in 01 02 03 04 05 06 07 08; do
  mk "wide/f$i"       "common word" "file number f$i" "common common"
done

# ---- deep nesting ----
mk deep/d1/d2/d3/d4/d5/d6/bottom      "deep deep down below" "very very deep"
mk deep/d1/d2/d3/side                 "side by side by side"
mk deep/d1/d2/mid                     "middle of the tree"
mk deep/d1/top                        "top of the tree tree"

# ---- same word spread over many files ----
mk spread/s1          "everywhere"
mk spread/s2          "everywhere everywhere"
mk spread/s3          "nowhere" "everywhere"
mk spread/s4/s5       "everywhere nowhere somewhere"
mk spread/s4/s6       "somewhere" "somewhere somewhere"

# ---- one word per line, and one huge line ----
mk lines/oneper       "alpha" "beta" "gamma" "alpha" "beta" "alpha"
mk lines/huge         "a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b a b"

# ---- words without the letter a ----
mk noa/n1             "hello world yes no" "tree bush hill"
mk noa/n2             "bbb ccc ddd" "eee fff ggg" "bbb eee"

echo "Big test data created in '$root' ($(find "$root" -type f | wc -l) files)."
echo "Run:  ./run_tests.bash $root created by ./mktest"
command -v tree >/dev/null && tree "$root"
