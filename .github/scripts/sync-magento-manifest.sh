#!/usr/bin/env bash
# Syncs manifest.json from magento-compatability's tested baselines.
# Only fields a baseline sets change.
set -euo pipefail

MANIFEST=${MANIFEST:-.github/actions/magento/compute-software-requirements/manifest.json}
MATRIX=${MATRIX:-https://raw.githubusercontent.com/SamJUK/magento-compatability/master/matrix.yml}
IMAGE_TAGS=${IMAGE_TAGS:-https://hub.docker.com/v2/repositories}
CHANGES_FILE=${CHANGES_FILE:-/dev/stdout}

products=$(curl -sfL --retry 3 --max-time 60 "$MATRIX" | yq -o=json '.products' || true)
[[ $products == \[* ]] || { echo "::error::Couldn't fetch $MATRIX"; exit 1; }

image() {
  case $1 in
    mariadb|mysql|redis) echo "library/$1" ;;
    valkey) echo valkey/valkey ;;
    opensearch) echo wardenenv/opensearch ;;
  esac
}

# Matrix versions don't always match an image tag (OpenSearch "3" is tagged "3.0").
tags='{}'
while IFS=$'\t' read -r type version; do
  repo=$(image "$type")
  [[ -n $repo ]] || continue
  found=
  for tag in "$version" "$version.0"; do
    if curl -sfL --retry 3 --max-time 30 -o /dev/null "$IMAGE_TAGS/$repo/tags/$tag"; then
      found=$tag
      break
    fi
  done
  if [[ -z $found ]]; then
    echo "::warning::No $repo:$version image, keeping the current $type versions"
    continue
  fi
  tags=$(jq --arg k "$type:$version" --arg t "$found" '.[$k] = $t' <<< "$tags")
done < <(jq -r '[.[].versions[].baseline | .db, .search, .cache | select(.) | "\(.type)\t\(.version)"] | unique[]' <<< "$products")

# No image: keep the current service. New patch: copy its line's latest entry. New line: by hand.
updated=$(jq --indent 4 --argjson products "$products" --argjson tags "$tags" '
  def line($d): if $d == "magento" then split("-")[0] else split(".")[0] end;
  def order: [scan("[0-9]+") | tonumber];
  def service: if . then {(.type): $tags["\(.type):\(.version)"]} | with_entries(select(.value)) else {} end;
  def fields: .baseline
    | {php, varnish} + (.db | service) + (.search | service) + (.cache | service)
      + (if .queue then {(.queue.type): .queue.version} else {} end)
      + (if (.db | service) != {} then {database: .db.type} else {} end)
      + (if (.cache | service) != {} then {cache: .cache.type} else {} end)
    | with_entries(select(.value != null) | .value |= tostring);
  reduce ($products[] | (if .name == "mageos" then "mage-os" else .name end) as $d
          | .versions[] | {d: $d, v: .version, f: fields}) as $e (.;
    if .[$e.d][$e.v] then .[$e.d][$e.v] += $e.f
    else
      ((.[$e.d] // {}) | to_entries | map(select(.key | line($e.d) == ($e.v | line($e.d))))
        | max_by(.key | order) // null) as $latest
      | if $latest and ($e.v | order) > ($latest.key | order) then .[$e.d][$e.v] = $latest.value + $e.f else . end
    end)
' "$MANIFEST")

jq -r --argjson old "$(cat "$MANIFEST")" '
  to_entries[] | .key as $d | .value | to_entries[] | .key as $v | .value as $n | $old[$d][$v] as $o
  | if $o == null then "- \($d) \($v): added"
    else [$n | to_entries[] | select($o[.key] != .value) | "\(.key) \($o[.key] // "none") -> \(.value)"]
      | select(length > 0) | "- \($d) \($v): \(join(", "))" end
' <<< "$updated" >> "$CHANGES_FILE"

printf '%s\n' "$updated" > "$MANIFEST"
