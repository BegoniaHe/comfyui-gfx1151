#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
cd "$ROOT_DIR"

if [[ $# -eq 0 ]]; then
  exit 0
fi

if ! command -v ruff >/dev/null 2>&1; then
  echo "ruff is not installed or not in PATH" >&2
  exit 1
fi

PRETTIER_BIN=""

if [[ -x "$ROOT_DIR/node_modules/.bin/prettier" ]]; then
  PRETTIER_BIN="$ROOT_DIR/node_modules/.bin/prettier"
elif command -v prettier >/dev/null 2>&1; then
  PRETTIER_BIN=$(command -v prettier)
fi

python_files=()
prettier_files=()

for file_path in "$@"; do
  if [[ ! -f "$file_path" ]]; then
    continue
  fi

  case "$file_path" in
    *.py)
      python_files+=("$file_path")
      ;;
    *.md|*.json|*.jsonc|*.yaml|*.yml)
      prettier_files+=("$file_path")
      ;;
  esac
done

if (( ${#python_files[@]} > 0 )); then
  ruff check --fix "${python_files[@]}"
  ruff format "${python_files[@]}"
  ruff check "${python_files[@]}"
fi

if (( ${#prettier_files[@]} > 0 )); then
  if [[ -z "$PRETTIER_BIN" ]]; then
    echo "prettier is not installed. Run 'npm install' in the repository root." >&2
    exit 1
  fi

  "$PRETTIER_BIN" --write "${prettier_files[@]}"
fi

git add -- "${python_files[@]}" "${prettier_files[@]}"