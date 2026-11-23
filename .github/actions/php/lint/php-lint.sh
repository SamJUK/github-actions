#!/bin/sh
# php -l on every tracked .php and .phtml file. POSIX sh: the Alpine CI images have no bash.
set -eu

files=$(mktemp)
out=$(mktemp)
git ls-files -z -- '*.php' '*.phtml' > "$files"
# shellcheck disable=SC2016 # $f expands in the inner sh, not here.
if ! xargs -0 -r -n 20 -P "$(nproc)" sh -c 'rc=0; for f; do php -d display_errors=stderr -d log_errors=0 -l "$f" || rc=1; done; exit $rc' _ < "$files" > "$out" 2>&1; then
    grep -v '^No syntax errors detected' "$out"
    exit 1
fi
echo "$(grep -c '^No syntax errors detected' "$out" || true) files OK"
