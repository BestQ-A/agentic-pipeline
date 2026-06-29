#!/usr/bin/env bash
set -euo pipefail

scope="user"
force=0
hermes_home="${HERMES_HOME:-}"

usage() {
  cat <<'EOF'
Install the Agentic Pipeline skill into Hermes Agent.

Usage:
  scripts/install-hermes.sh [--user|--project] [--force] [--hermes-home PATH]

Targets:
  user:    ${HERMES_HOME:-$HOME/.hermes}/skills/software-development/agentic-pipeline
  project: ./.hermes/skills/software-development/agentic-pipeline
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --user) scope="user" ;;
    --project) scope="project" ;;
    --force) force=1 ;;
    --hermes-home)
      shift
      [ "$#" -gt 0 ] || { echo "--hermes-home requires a path" >&2; exit 2; }
      hermes_home="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
src_skill="$repo_root/.hermes/skills/software-development/agentic-pipeline"

[ -f "$src_skill/SKILL.md" ] || { echo "Source Hermes skill not found: $src_skill" >&2; exit 1; }

if [ "$scope" = "user" ]; then
  if [ -z "$hermes_home" ]; then
    hermes_home="$HOME/.hermes"
  fi
  dest_root="$hermes_home/skills/software-development"
else
  dest_root="$(pwd)/.hermes/skills/software-development"
fi

dest_skill="$dest_root/agentic-pipeline"

echo "Installing Agentic Pipeline for Hermes Agent ($scope scope)"
echo "  Source -> $src_skill"
echo "  Target -> $dest_skill"

if [ -d "$dest_skill" ] && [ "$force" -ne 1 ]; then
  echo "  WARN: skill already exists at $dest_skill. Use --force to overwrite."
else
  mkdir -p "$dest_skill"
  cp -R "$src_skill/." "$dest_skill/"
  echo "  Installed skill: agentic-pipeline"
fi

if command -v pwsh >/dev/null 2>&1 && [ -f "$dest_skill/scripts/validate_agentic_pipeline_contract.ps1" ]; then
  pwsh -NoProfile -ExecutionPolicy Bypass -File "$dest_skill/scripts/validate_agentic_pipeline_contract.ps1" -SkillRoot "$dest_skill"
fi

echo ""
echo "Done. Start a new Hermes session or reload skills, then use one of:"
echo "  hermes -s agentic-pipeline"
echo "  /skill agentic-pipeline"
echo '  hermes -s agentic-pipeline -z "Standardize this project'\''s agent pipeline."'
