#!/usr/bin/env bash
# Moves each supported version to the latest patch in its line, once that patch
# has a manifest entry and a CI image.
set -euo pipefail

VERSIONS=${VERSIONS:-.github/actions/magento/supported-versions/versions.json}
MANIFEST=${MANIFEST:-.github/actions/magento/compute-software-requirements/manifest.json}
MAGENTO_PACKAGES=${MAGENTO_PACKAGES:-https://mirror.mage-os.org/p2/magento/product-community-edition.json}
MAGEOS_PACKAGES=${MAGEOS_PACKAGES:-https://repo.mage-os.org/p2/mage-os/product-community-edition.json}
IMAGE_TAGS=${IMAGE_TAGS:-https://hub.docker.com/v2/repositories/samjuk}
CHANGES_FILE=${CHANGES_FILE:-/dev/stdout}
SORT=${SORT:-sort}

declare -A releases
releases[magento]=$(curl -sfL --retry 3 --max-time 60 "$MAGENTO_PACKAGES" | jq -r '.packages[][].version | select(test("^2\\.4\\.[0-9]+(-p[0-9]+)?$"))' | $SORT -V || true)
releases[mage-os]=$(curl -sfL --retry 3 --max-time 60 "$MAGEOS_PACKAGES" | jq -r '.packages[][].version | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' | $SORT -V || true)

# 2.4.8-p5 -> 2.4.8. Mage-OS releases minors, so its line is the major: 3.6.0 -> 3.
line() {
  if [[ $1 == magento ]]; then echo "${2%%-*}"; else echo "${2%%.*}"; fi
}

latest() {
  local want v
  want=$(line "$1" "$2")
  while read -r v; do
    if [[ $(line "$1" "$v") == "$want" ]]; then echo "$v"; fi
  done <<< "${releases[$1]}" | tail -1
}

has_image() {
  local repo=magento-ci-testing-env
  [[ $1 == mage-os ]] && repo=mage-os-ci-testing-env
  curl -sfL --retry 3 --max-time 30 -o /dev/null "$IMAGE_TAGS/$repo/tags/$2-php$3"
}

for dist in magento mage-os; do
  [[ -n ${releases[$dist]} ]] || { echo "::error::Couldn't fetch $dist releases"; exit 1; }
done

for dist in magento mage-os; do
  for current in $(jq -r --arg d "$dist" '.[$d][]?' "$VERSIONS"); do
    newest=$(latest "$dist" "$current")
    [[ -z $newest || $newest == "$current" ]] && continue

    php=$(jq -r --arg d "$dist" --arg v "$newest" '.[$d][$v].php // empty' "$MANIFEST")
    if [[ -z $php ]]; then
      echo "::warning::$dist $newest has no manifest.json entry yet, skipping"
      continue
    fi
    if ! has_image "$dist" "$newest" "$php"; then
      echo "::warning::No image for $dist $newest (php$php) yet, skipping"
      continue
    fi

    jq --indent 4 --arg d "$dist" --arg old "$current" --arg new "$newest" \
      '.[$d] |= map(if . == $old then $new else . end)' "$VERSIONS" > "$VERSIONS.tmp"
    mv "$VERSIONS.tmp" "$VERSIONS"
    echo "- $dist $current -> $newest" >> "$CHANGES_FILE"
  done

  newest_line=$(line "$dist" "$(tail -1 <<< "${releases[$dist]}")")
  lines=$(jq -r --arg d "$dist" '.[$d][]?' "$VERSIONS" | while read -r v; do line "$dist" "$v"; done)
  grep -qxF "$newest_line" <<< "$lines" || echo "::notice::$dist $newest_line is out but not supported yet"
done
