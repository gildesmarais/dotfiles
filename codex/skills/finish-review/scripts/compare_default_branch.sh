#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)

# Determine default branch (prefer origin/HEAD, then remote show, then main/master)
default_branch=""
if git symbolic-ref --quiet refs/remotes/origin/HEAD >/dev/null 2>&1; then
  default_branch=$(git symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
elif git remote show origin >/dev/null 2>&1; then
  default_branch=$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')
fi

if [[ -z "${default_branch}" ]]; then
  if git show-ref --verify --quiet refs/heads/main; then
    default_branch="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    default_branch="master"
  else
    echo "Could not determine default branch (no origin/HEAD, main, or master)." >&2
    exit 1
  fi
fi

base_ref="origin/${default_branch}"
if ! git show-ref --verify --quiet "refs/remotes/${base_ref}"; then
  base_ref="${default_branch}"
fi

printf "Current branch: %s\n" "${current_branch}"
printf "Default branch: %s\n" "${default_branch}"
printf "Base ref: %s\n\n" "${base_ref}"

# Fetch only if needed and origin exists. Silence fetch errors in restricted environments.
if git remote get-url origin >/dev/null 2>&1; then
  git fetch -q origin "${default_branch}" >/dev/null 2>&1 || true
fi

printf "Commits ahead/behind (base...HEAD):\n"
git rev-list --left-right --count "${base_ref}...HEAD"

printf "\nDiffstat (base...HEAD):\n"
git --no-pager diff --stat "${base_ref}...HEAD"

printf "\nChanged files (name-status, base...HEAD):\n"
git --no-pager diff --name-status "${base_ref}...HEAD"
