#!/usr/bin/env bash
# Runs the DialCatz CLI with the action's inputs (INPUT_*).
set -uo pipefail

node_major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)
if [ "$node_major" -lt 20 ]; then
  echo "::error::DialCatz needs Node 20 or later: add actions/setup-node before this step."
  exit 2
fi

json="${RUNNER_TEMP:-/tmp}/dialcatz-$$.json"
args=(run "$INPUT_PATH" --reporter cli --reporter github --reporter "json=$json")
[ -n "${INPUT_COLLECTION:-}" ] && args+=(--collection "$INPUT_COLLECTION")
[ -n "${INPUT_FOLDER:-}" ] && args+=(--folder "$INPUT_FOLDER")
[ -n "${INPUT_ENV_FILE:-}" ] && args+=(--env-file "$INPUT_ENV_FILE")
[ -n "${INPUT_DATA:-}" ] && args+=(--data "$INPUT_DATA")
[ -n "${INPUT_SPEC:-}" ] && args+=(--spec "$INPUT_SPEC")
[ -n "${INPUT_RETRIES:-}" ] && args+=(--retries "$INPUT_RETRIES")
[ "${INPUT_BAIL:-}" = true ] && args+=(--bail)
[ -n "${INPUT_REPORT:-}" ] && args+=(--reporter "html=$INPUT_REPORT")
[ "${INPUT_DETAILS:-}" = true ] && args+=(--details)
[ -n "${INPUT_JUNIT:-}" ] && args+=(--reporter "junit=$INPUT_JUNIT")
while IFS= read -r line || [ -n "$line" ]; do
  line=${line%$'\r'}
  [ -n "$line" ] && args+=(--var "$line")
done <<< "${INPUT_VARS:-}"
while IFS= read -r line || [ -n "$line" ]; do
  line=${line%$'\r'}
  [ -n "$line" ] && args+=("$line")
done <<< "${INPUT_ARGS:-}"

# A version on npm, or (for trying a build) a folder or tarball.
case "${INPUT_VERSION:-1}" in
  ./* | /* | *.tgz) package=$INPUT_VERSION ;;
  *) package="dialcatz@${INPUT_VERSION:-1}" ;;
esac
npx --yes --package "$package" -- dialcatz "${args[@]}"
code=$?

if [ -n "${GITHUB_OUTPUT:-}" ] && [ -f "$json" ]; then
  REPORT="$json" node -e '
    const r = JSON.parse(require("node:fs").readFileSync(process.env.REPORT, "utf8"));
    require("node:fs").appendFileSync(process.env.GITHUB_OUTPUT, `passed=${r.passed === true}\nrequests=${Number(r.requests)}\nfailed=${Number(r.failed)}\n`);
  '
fi
rm -f "$json"
exit $code
