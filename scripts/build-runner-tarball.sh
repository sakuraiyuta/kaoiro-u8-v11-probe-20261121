#!/usr/bin/env bash
set -euo pipefail

[[ "$#" == 5 && "$1" == --require-tagged && "$2" == --target && "$4" == --out ]]
target=$3
out=$5
case "$target" in linux-x64|darwin-arm64) ;; *) exit 64 ;; esac
tag=$(git describe --exact-match --tags HEAD)
revision=$(git rev-parse HEAD)
stem="kaoiro-runner-$revision-$target"
temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
mkdir -p "$temp/$stem/dist"
jq -n --arg revision "$revision" --arg version "${tag#v}" \
  '{revision:$revision,version:$version,dirty:false}' \
  > "$temp/$stem/dist/build-info.json"
printf '%s\n' 'Disposable test data only.' > "$temp/$stem/README.md"
tar -czf "$out/$stem.tar.gz" -C "$temp" "$stem"
