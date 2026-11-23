#!/usr/bin/env bash
# Tag a release per family whose files changed since its last tag: <family>/vX.Y.Z.
# Each tag gets its own commit (HEAD's tree, HEAD as parent, on no branch), so Dependabot reads one family per commit.
# Usage: bin/release.sh [--dry-run]   (needs gh, signed in or GH_TOKEN, and the family tags fetched)
set -euo pipefail
cd "$(dirname "$0")/.."

declare -A families=(
    [magento-module]=".github/workflows/magento2-module.yaml"
    [magento-store]=".github/workflows/magento-store.yaml .github/workflows/published-build.yaml .github/workflows/composer-changes.yml .github/workflows/docker-prune-pr.yaml"
)
dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true
repo=${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
head=$(git rev-parse HEAD)

# Every file a family runs: its entry points and whatever they reach through $/ references, docs excluded.
closure() {
    local -A seen=()
    local queue=("$@") path f
    while ((${#queue[@]})); do
        path=${queue[0]}
        queue=("${queue[@]:1}")
        [[ -n ${seen[$path]:-} ]] && continue
        seen[$path]=1
        while read -r f; do
            [[ $f == *.md ]] && continue
            echo "$f"
            if [[ $f == *.yml || $f == *.yaml ]]; then
                while read -r ref; do queue+=("$ref"); done < <(grep -oE 'uses: *\$/[^ #"]+' "$f" | sed -E 's|uses: *\$/||')
            fi
        done < <(git ls-files -- "$path")
    done | sort -u
}

for family in "${!families[@]}"; do
    read -ra entries <<< "${families[$family]}"
    mapfile -t files < <(closure "${entries[@]}")
    if ((${#files[@]} == 0)); then
        echo "$family: not in this repository"
        continue
    fi
    last=$(git tag -l "$family/v*" --sort=-v:refname | head -1)

    if [[ -z $last ]]; then
        version=v1.0.0
        log=$(git log --format='- %s' -n 20 -- "${files[@]}")
    else
        log=$(git log --format='- %s' "$last..$head" -- "${files[@]}")
        if [[ -z $log ]]; then
            echo "$family: nothing since $last"
            continue
        fi
        IFS=. read -r major minor patch <<< "${last#"$family"/v}"
        if git log --format='%s%n%b' "$last..$head" -- "${files[@]}" | grep -qE '^[a-z]+(\([^)]*\))?!:|^BREAKING CHANGE:'; then
            version=v$((major + 1)).0.0
        elif grep -qE '^- feat(\([^)]*\))?:' <<< "$log"; then
            version=v$major.$((minor + 1)).0
        else
            version=v$major.$minor.$((patch + 1))
        fi
    fi

    tag=$family/$version
    echo "$family: ${last:-none} -> $tag (${#files[@]} files)"
    echo "$log"
    $dry_run && continue

    commit=$(gh api "repos/$repo/git/commits" -f message="$tag" -f tree="$(git rev-parse "$head^{tree}")" -f "parents[]=$head" -q .sha)
    gh api "repos/$repo/git/refs" -f ref="refs/tags/$tag" -f sha="$commit" --silent
    gh release create "$tag" --repo "$repo" --verify-tag --latest=false --title "$tag" --notes "$log"
done
