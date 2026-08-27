#!/usr/bin/env bash
#
# Symlink the skills in this repository into your personal skills directory.
#
# Claude Code discovers skills at ~/.claude/skills/<name>/SKILL.md, one level
# deep, so a clone of this repo can't be dropped there directly. Symlinking each
# skill puts it at the depth Claude Code expects while leaving the clone under
# git, so `git pull` updates every installed skill at once.
#
#   ./install.sh                   # link every skill
#   ./install.sh <name>...         # link only the named skills
#   ./install.sh --uninstall       # remove links that point back at this repo
#   ./install.sh --target DIR      # link somewhere other than ~/.claude/skills
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_DIR="$REPO/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
UNINSTALL=0
NAMES=()

usage() {
  sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -u | --uninstall)
      UNINSTALL=1
      shift
      ;;
    -t | --target)
      [[ $# -ge 2 ]] || {
        echo "install.sh: --target needs a directory" >&2
        exit 2
      }
      TARGET_DIR="$2"
      shift 2
      ;;
    --target=*)
      TARGET_DIR="${1#--target=}"
      shift
      ;;
    -*)
      echo "install.sh: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      NAMES+=("$1")
      shift
      ;;
  esac
done

if [[ ${#NAMES[@]} -eq 0 ]]; then
  for dir in "$SOURCE_DIR"/*/; do
    [[ -f "$dir/SKILL.md" ]] && NAMES+=("$(basename "$dir")")
  done
fi

if [[ ${#NAMES[@]} -eq 0 ]]; then
  echo "install.sh: no skills found in $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
status=0
linked=0

for name in "${NAMES[@]}"; do
  source="$SOURCE_DIR/$name"
  link="$TARGET_DIR/$name"

  if [[ ! -f "$source/SKILL.md" ]]; then
    echo "  skip  $name (no $source/SKILL.md)" >&2
    status=1
    continue
  fi

  if [[ $UNINSTALL -eq 1 ]]; then
    if [[ ! -L "$link" ]]; then
      [[ -e "$link" ]] && echo "  skip  $name (not a symlink, leaving it alone)" >&2
      continue
    fi
    if [[ "$(cd "$(dirname "$link")" && cd "$(readlink "$link")" && pwd -P)" != "$source" ]]; then
      echo "  skip  $name (symlink points elsewhere, leaving it alone)" >&2
      continue
    fi
    rm "$link"
    echo "remove  $name"
    continue
  fi

  if [[ -L "$link" ]]; then
    rm "$link"
  elif [[ -e "$link" ]]; then
    echo "  skip  $name ($link already exists and is not a symlink)" >&2
    status=1
    continue
  fi

  ln -s "$source" "$link"
  echo "  link  $name -> $link"
  linked=$((linked + 1))
done

if [[ $linked -gt 0 ]]; then
  echo
  echo "Restart Claude Code, then run /help to confirm the skills are listed."
fi

exit "$status"
