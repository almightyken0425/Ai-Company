#!/usr/bin/env bash

set -euo pipefail

WORKSPACE_ROOT="$HOME/Doc/ai-company"

usage() {
  printf 'Usage: %s [--workspace-root PATH]\n' "$(basename -- "$0")"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace-root)
      [[ $# -ge 2 ]] || {
        printf 'FAIL: --workspace-root requires a path\n' >&2
        exit 2
      }
      WORKSPACE_ROOT=$2
      shift 2
      ;;
    --workspace-root=*)
      WORKSPACE_ROOT=${1#*=}
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'FAIL: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -d "$WORKSPACE_ROOT" ]] || {
  printf 'FAIL: workspace root does not exist: %s\n' "$WORKSPACE_ROOT" >&2
  exit 2
}

WORKSPACE_ROOT="$(CDPATH= cd -- "$WORKSPACE_ROOT" && pwd)"

ROOT_TEMPLATE=$'# Claude Code 相容入口\n\n@AGENTS.md\n'
GENERIC_TEMPLATE=$'# Claude Code 相容入口\n\n- `AGENTS.md` 是本目錄的規則真相\n- 動工前完整讀取 `AGENTS.md`\n- 父層 `AGENTS.md` 仍持續適用\n- 本檔不得重複產品規則\n'
SUSUGIGI_TEMPLATE=$'# Claude 相容入口\n\n- 此檔只供跨工具相容。\n- 同目錄 `AGENTS.md` 是規則真相。\n- 執行任務前完整讀取該檔。\n- 不在此檔複製規則。\n'

EXPECTED_DIRS=(
  "."
  "product/Hatsuon"
  "product/Hatsuon/no3_product_specs/no1_pronunciation_app"
  "product/Hatsuon/no5_product_development/no1_pronunciation_app"
  "product/IGotThis"
  "product/IGotThis/no3_product_specs/no1_issue_system"
  "product/IGotThis/no4_product_designs/no1_issue_system"
  "product/IGotThis/no5_product_development/no1_issue_system"
  "product/LiquidGlassHeaderTemplate"
  "product/LiquidGlassHeaderTemplate/no3_product_specs/no1_liquid_glass_header"
  "product/LiquidGlassHeaderTemplate/no5_product_development/no1_liquid_glass_header"
  "product/SuSuGiGi"
  "product/SuSuGiGi/no2_product_planning/no2_product_map"
  "product/SuSuGiGi/no3_product_specs/no1_user_management"
  "product/SuSuGiGi/no3_product_specs/no2_accounting_app"
  "product/SuSuGiGi/no3_product_specs/no3_cloud_functions"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app/project/10_foundations"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app/project/10_foundations/component_tokens"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app/project/10_foundations/visualizers"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app/project/15_fixtures"
  "product/SuSuGiGi/no4_product_designs/no2_accounting_app/project/30_screens"
  "product/SuSuGiGi/no5_product_development/no2_accounting_app"
  "product/SuSuGiGi/no5_product_development/no3_cloud_functions"
  "product/SuSuGiGi/no5_product_development/no4_support_site"
  "product/SuSuGiGi/no6_product_quality/no2_accounting_app"
  "product/SuSuGiGi/no7_product_release/no2_accounting_app"
  "product/UndergroundRemake"
  "product/UndergroundRemake/no3_product_specs/no1_concept"
)

EXPECTED_COUNT=29
if [[ ${#EXPECTED_DIRS[@]} -ne $EXPECTED_COUNT ]]; then
  printf 'FAIL: internal expected directory count is %s, expected %s\n' \
    "${#EXPECTED_DIRS[@]}" "$EXPECTED_COUNT" >&2
  exit 2
fi

ERROR_COUNT=0

record_failure() {
  printf 'FAIL: %s\n' "$*" >&2
  ERROR_COUNT=$((ERROR_COUNT + 1))
}

is_expected_dir() {
  local candidate=$1
  local expected
  for expected in "${EXPECTED_DIRS[@]}"; do
    [[ "$candidate" == "$expected" ]] && return 0
  done
  return 1
}

file_matches_template() {
  local file=$1
  local relative_dir=$2
  local expected
  local actual_with_sentinel
  local expected_with_sentinel

  if [[ "$relative_dir" == "." ]]; then
    expected=$ROOT_TEMPLATE
  elif [[ "$relative_dir" == product/SuSuGiGi* ]]; then
    expected=$SUSUGIGI_TEMPLATE
  else
    expected=$GENERIC_TEMPLATE
  fi

  actual_with_sentinel="$(command cat -- "$file"; printf '\037')"
  expected_with_sentinel="$(printf '%s' "$expected"; printf '\037')"
  [[ "$actual_with_sentinel" == "$expected_with_sentinel" ]]
}

discover_instruction_files() {
  find "$WORKSPACE_ROOT" \
    \( -type d \( \
      -name .git -o \
      -name node_modules -o \
      -name Pods -o \
      -name vendor -o \
      -name .build -o \
      -name build -o \
      -name dist -o \
      -name coverage -o \
      -name .next -o \
      -name .expo -o \
      -name .gradle -o \
      -name .yarn -o \
      -name .pnpm-store -o \
      -name .venv -o \
      -name venv -o \
      -name target -o \
      -name DerivedData -o \
      -name ai-company-worktrees -o \
      -name worktrees -o \
      -name .worktrees -o \
      -name _worktrees \
    \) -prune \) -o \
    \( -type f \( -name AGENTS.md -o -name CLAUDE.md \) -print \)
}

FOUND_DIRS=()
while IFS= read -r relative_dir; do
  FOUND_DIRS+=("$relative_dir")
done < <(
  discover_instruction_files |
    while IFS= read -r file; do
      relative_path=${file#"$WORKSPACE_ROOT"/}
      relative_dir=${relative_path%/*}
      [[ "$relative_dir" == "$relative_path" ]] && relative_dir=.
      printf '%s\n' "$relative_dir"
    done |
    LC_ALL=C sort -u
)

for found_dir in "${FOUND_DIRS[@]}"; do
  if ! is_expected_dir "$found_dir"; then
    record_failure "unexpected instruction directory: $found_dir"
  fi
done

for expected_dir in "${EXPECTED_DIRS[@]}"; do
  if [[ "$expected_dir" == "." ]]; then
    absolute_dir=$WORKSPACE_ROOT
  else
    absolute_dir=$WORKSPACE_ROOT/$expected_dir
  fi

  agents_file=$absolute_dir/AGENTS.md
  claude_file=$absolute_dir/CLAUDE.md

  if [[ ! -f "$agents_file" ]]; then
    record_failure "missing AGENTS.md: $expected_dir"
  elif [[ ! -s "$agents_file" ]]; then
    record_failure "empty AGENTS.md: $expected_dir"
  fi

  if [[ ! -f "$claude_file" ]]; then
    record_failure "missing CLAUDE.md: $expected_dir"
    continue
  fi

  if ! file_matches_template "$claude_file" "$expected_dir"; then
    record_failure "CLAUDE.md template drift: $expected_dir"
  fi
done

if [[ ${#FOUND_DIRS[@]} -ne $EXPECTED_COUNT ]]; then
  record_failure "found ${#FOUND_DIRS[@]} instruction directories, expected $EXPECTED_COUNT"
fi

if [[ $ERROR_COUNT -ne 0 ]]; then
  printf 'Instruction drift check failed with %s error(s).\n' "$ERROR_COUNT" >&2
  exit 1
fi

printf 'PASS: %s instruction pairs match the canonical templates.\n' "$EXPECTED_COUNT"
