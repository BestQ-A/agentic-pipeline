#!/usr/bin/env bash
# Install the Agentic Pipeline skill and subagent profiles into Devin CLI.
#
# Usage:
#   ./install-devin.sh              # user/global scope (default)
#   ./install-devin.sh --project    # current project's .devin/ directory
#   ./install-devin.sh --force      # overwrite existing destinations
#
# Targets (user scope):
#   Skills -> ~/.config/devin/skills/<name>/      (Linux/macOS)
#             %APPDATA%/devin/skills/<name>/      (Windows, via $APPDATA)
#   Agents -> ~/.config/devin/agents/<name>/      (Linux/macOS)
#             %APPDATA%/devin/agents/<name>/      (Windows, via $APPDATA)
set -euo pipefail

SCOPE="user"
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --project) SCOPE="project" ;;
    --user)    SCOPE="user" ;;
    --force)   FORCE=1 ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_SKILL="$REPO_ROOT/.devin/skills/agentic-pipeline"
SRC_AGENTS="$REPO_ROOT/.devin/agents"

[ -d "$SRC_SKILL" ]  || { echo "Missing source skill: $SRC_SKILL"  >&2; exit 1; }
[ -d "$SRC_AGENTS" ] || { echo "Missing source agents: $SRC_AGENTS" >&2; exit 1; }

if [ "$SCOPE" = "user" ]; then
  if [ -n "${APPDATA:-}" ] && [ -d "$APPDATA" ]; then
    DEST_SKILLS_ROOT="$APPDATA/devin/skills"
    DEST_AGENTS_ROOT="$APPDATA/devin/agents"
  else
    DEST_SKILLS_ROOT="${HOME}/.config/devin/skills"
    DEST_AGENTS_ROOT="${HOME}/.config/devin/agents"
  fi
else
  DEST_SKILLS_ROOT="$(pwd)/.devin/skills"
  DEST_AGENTS_ROOT="$(pwd)/.devin/agents"
fi

echo "Installing Agentic Pipeline for Devin ($SCOPE scope)"
echo "  Skills  -> $DEST_SKILLS_ROOT"
echo "  Agents  -> $DEST_AGENTS_ROOT"

DEST_SKILL="$DEST_SKILLS_ROOT/agentic-pipeline"
if [ -d "$DEST_SKILL" ] && [ "$FORCE" -ne 1 ]; then
  echo "  WARN: skill already exists at $DEST_SKILL (use --force to overwrite)"
else
  mkdir -p "$DEST_SKILL"
  cp -R "$SRC_SKILL/." "$DEST_SKILL/"
  echo "  Installed skill: agentic-pipeline"
fi

agent_count=0
for src_agent in "$SRC_AGENTS"/*/; do
  [ -d "$src_agent" ] || continue
  name="$(basename "$src_agent")"
  dest_agent="$DEST_AGENTS_ROOT/$name"
  if [ -d "$dest_agent" ] && [ "$FORCE" -ne 1 ]; then
    echo "  WARN: agent already exists: $name (use --force to overwrite)"
    continue
  fi
  mkdir -p "$dest_agent"
  cp -R "$src_agent/." "$dest_agent/"
  agent_count=$((agent_count + 1))
done
echo "  Installed $agent_count agent profile(s)."

echo ""
echo "Done. Start a new Devin session, then invoke:"
echo "  /agentic-pipeline [project-root]"
